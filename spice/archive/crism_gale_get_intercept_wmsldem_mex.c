/* =====================================================================
 * crism_gale_get_intercept_wmsldem_mex.c
 * get intercept of the line-of-sight vector of each pixel
 * 
 * 
 * INPUTS:
 * 0 msldemc_radius         Double array [msldemc_lines x msldemc_samples]
 * 1 msldemc_latitude_rad   Double array [msldemc_lines] <unit radians>
 * 2 msldemc_longitude_rad  Double array [msldemc_samples] <unit radians>
 * 3 msldemc_imFOVmask      Double array [msldemc_lines x msldemc_samples]
 * 4 cahv_mdl               CAHV_MODEL
 * 5 crism_samples          Scalar              
 * 6 crism_PmC              Double [3*crism_samples]
 * 
 * 
 * OUTPUTS:
 * 0  crism_xyz      [3 x crism_samples]
 * 1  crism_ref      [3 x crism_samples]   Integer
 * 2  crism_cosemi   [crism_samples]       Double - cosine of emmission 
 *                                         angles
 * 3  crsim_pln      [4 x crism_samples]   xyz of surface plane normal 
 *                                         vector and plane constant
 * 
 *
 *
 * This is a MEX file for MATLAB.
 * ===================================================================== */
#include <stdint.h>
#include "io64.h"
#include "mex.h"
#include "math.h"
#include "matrix.h"
#include <string.h>
#include <stdio.h>

#include <stdlib.h>
#include "envi.h"
#include "mex_create_array.h"
#include "cahvor.h"



/* main computation routine */
void crism_get_incpt_msldemc(double **msldemc_radius, 
        int32_T msldemc_samples, int32_T msldemc_lines,
        double *msldemc_latitude_rad, double *msldemc_longitude_rad,
        int8_T **msldemc_imFOVmask,
        CAHV_MODEL cahv_mdl, int32_T crism_samples,
        double **crism_PmC, int32_T Npmc,
        double **crism_xyz, int32_T **crism_ref, double *crism_cosemi, 
        double **crism_pln)
{
    int32_T c,l;
    int32_T L_demcm1,S_demcm1;
    int16_T sxy;
    int32_T c1,c2,c3,l1,l2,l3;
    double *cos_lon, *sin_lon, *cos_lat, *sin_lat;
    double ppv1x,ppv1y,ppv2x,ppv2y,ppv3x,ppv3y; /* Plane Position Vectors */
    double ppv1gx,ppv1gy,ppv1gz,ppv2gx,ppv2gy,ppv2gz,ppv3gx,ppv3gy,ppv3gz; //,ppv4gx,ppv4gy,ppv4gz;
    double pdv1x,pdv1y,pdv1z,pdv2x,pdv2y,pdv2z;
    double detM;
    double M[2][2];
    double Minv[2][2];
    int32_T x_min,x_max;
    int32_T xi;
    double pipvx,pipvy;
    double pipvgx,pipvgy,pipvgz;
    double pipvgppv1x,pipvgppv1y,pipvgppv1z;
    double rnge;
    double pprm_sd,pprm_td; /* plane parameter for projected image plane */
    double dv1,dv2,dv3;
    double pd1,pd2,pd3,pp_sum,pd_dem;
    double pprm_s,pprm_t,pprm_1st;
    bool isinFOVd,isinFOV;
    double pmcx_xiyi,pmcy_xiyi,pmcz_xiyi;
    
    double pnx,pny,pnz; /* Plane Normal vectors */
    double pn_len;
    double pc; /* Plane Constant */
    double lprm,lprm_nume; /* line parameters */
    
    double **PmC_imxyap;
    double *PmC_imxyap_base;
    int32_T *bin_count;
    int32_T crism_samples_m1;
    int32_T **bin_im_c;
    double pmcx,pmcy,pmcz,apmc,hpmc,vpmc;
    double *cam_C, *cam_A, *cam_H, *cam_V;
    int32_T xbi;
    double xap_xiyi,yap_xiyi;
    int32_T n;
    double *crism_range;
    
    
    cam_C = cahv_mdl.C; cam_A = cahv_mdl.A; cam_H = cahv_mdl.H;
    cam_V = cahv_mdl.V;
    
    crism_samples_m1 = crism_samples - 1;
    L_demcm1 = msldemc_lines - 1;
    S_demcm1 = msldemc_samples - 1;
    
    /*********************************************************************/
    /* compute the direct projection of pmc to a camera image plane 
     * They are apparent image coordinate. */
    // createDoubleMatrix(PmC_imxap, PmC_imxap_base, (size_t) S_im, (size_t) L_im);
    
    // PmC_imxap = (double**) malloc(sizeof(double*) * (size_t) S_im);
    // PmC_imxap_base = (double*) malloc(sizeof(double) * (size_t) S_im * (size_t) L_im);
    // PmC_imxap[0] = &PmC_imxap_base[0];
    // for(xi=1;xi<S_im;xi++){
    //     PmC_imxap[xi] = PmC_imxap[xi-1] + L_im;
    // }
    
    createDoubleMatrix(&PmC_imxyap, &PmC_imxyap_base, 
            (size_t) Npmc, (size_t) 2);
    for(xi=0;xi<Npmc;xi++){
        pmcx = crism_PmC[xi][0];
        pmcy = crism_PmC[xi][1];
        pmcz = crism_PmC[xi][2];
        apmc = cam_A[0]*pmcx + cam_A[1]*pmcy + cam_A[2]*pmcz;
        hpmc = cam_H[0]*pmcx + cam_H[1]*pmcy + cam_H[2]*pmcz;
        vpmc = cam_V[0]*pmcx + cam_V[1]*pmcy + cam_V[2]*pmcz;
        PmC_imxyap[xi][0] = hpmc/apmc;
        PmC_imxyap[xi][1] = vpmc/apmc;
    }
    // printf("crism_sampels = %d\n",crism_samples);
    /*********************************************************************/
    
    /* bin images */
    bin_count = (int32_T*) malloc(sizeof(int32_T) * (size_t) crism_samples);
    /* initialization */
    for(xi=0;xi<crism_samples;xi++)
        bin_count[xi] = 0;
    
    for(xi=0;xi<Npmc;xi++){
        c = (int32_T) floor(PmC_imxyap[xi][0]+0.5);
        if(c<0)
            c=0;
        else if(c>crism_samples_m1)
            c = crism_samples_m1;
        
        ++bin_count[c];
    }
    
    bin_im_c = (int32_T**) malloc(sizeof(int32_T*) * (size_t) crism_samples);
    
    for(xi=0;xi<crism_samples;xi++){
        if(bin_count[xi]>0)
            bin_im_c[xi] = (int32_T*) malloc(sizeof(int32_T) * (size_t) bin_count[xi]);
        else
            bin_im_c[xi] = NULL;
    }
    
    for(xi=0;xi<crism_samples;xi++)
        bin_count[xi] = 0;
    
    
    for(xi=0;xi<Npmc;xi++){
        c = (int32_T) floor(PmC_imxyap[xi][0]+0.5);
        if(c<0)
            c=0;
        else if(c>crism_samples_m1)
            c = crism_samples_m1;
        bin_im_c[c][bin_count[c]] = xi;
        ++bin_count[c];
    }
    
    
    // printf("crism_sampels = %d\n",crism_samples);
    /*********************************************************************/
    cos_lon = (double*) malloc(sizeof(double) * (size_t) msldemc_samples);
    sin_lon = (double*) malloc(sizeof(double) * (size_t) msldemc_samples);
    for(c=0;c<msldemc_samples;c++){
        cos_lon[c] = cos(msldemc_longitude_rad[c]);
        sin_lon[c] = sin(msldemc_longitude_rad[c]);
    }
    
    cos_lat = (double*) malloc(sizeof(double) * (size_t) msldemc_lines);
    sin_lat = (double*) malloc(sizeof(double) * (size_t) msldemc_lines);
    for(l=0;l<msldemc_lines;l++){
        cos_lat[l] = cos(msldemc_latitude_rad[l]);
        sin_lat[l] = sin(msldemc_latitude_rad[l]);
    }
    
    crism_range = (double*) malloc(sizeof(double) * (size_t) Npmc);
    for(xi=0;xi<Npmc;xi++)
        crism_range[xi] = INFINITY;
    
    // printf("crism_sampels = %d\n",crism_samples);
    // printf("%d,%d,%d\n",skip_l,msldemc_samples*s,skip_r);
    for(l=0;l<L_demcm1;l++){
        //printf("l=%d\n",l);
        // decide the first and last indexes to be assessed.
        // printf("l = %d\n",l);
        for(c=0;c<S_demcm1;c++){
            // process if 
            //printf("c=%d,mask_lc = %d,mask_lp1c = %d\n",c,msldemc_imFOVmask[c][l],msldemc_imFOVmask[c][l+1]);
            if(msldemc_imFOVmask[c][l]>0 || msldemc_imFOVmask[c][l+1]>0){
                //printf("c=%d\n",c);
                for(sxy=0;sxy<2;sxy++){
                    if(sxy==0){
                        c1 = c;   l1 = l;
                        c2 = c+1; l2 = l;
                        c3 = c;   l3 = l+1;
                        // c4 = c+1; l4 = l+1;
                    }
                    else{
                        c1 = c+1; l1 = l;
                        c2 = c+1; l2 = l+1;
                        c3 = c;   l3 = l+1;
                        // c4 = c;   l4 = l;
                    }
                    isinFOVd = (msldemc_imFOVmask[c1][l1]>1 && msldemc_imFOVmask[c2][l2]>1 && msldemc_imFOVmask[c3][l3]>1);
                    isinFOV = (msldemc_imFOVmask[c1][l1]>0 && msldemc_imFOVmask[c2][l2]>0 && msldemc_imFOVmask[c3][l3]>0);
                    //printf("sxy=%d\n",sxy);
                    //printf("isinFOVd=%d\n",isinFOVd);
                    if(isinFOVd)
                    {
                        
                        /* get plane vectors in the xyz coordinate */
                        ppv1gx = msldemc_radius[c1][l1] * cos_lat[l1] * cos_lon[c1];
                        ppv1gy = msldemc_radius[c1][l1] * cos_lat[l1] * sin_lon[c1];
                        ppv1gz = msldemc_radius[c1][l1] * sin_lat[l1];
                        ppv2gx = msldemc_radius[c2][l2] * cos_lat[l2] * cos_lon[c2];
                        ppv2gy = msldemc_radius[c2][l2] * cos_lat[l2] * sin_lon[c2];
                        ppv2gz = msldemc_radius[c2][l2] * sin_lat[l2];
                        ppv3gx = msldemc_radius[c3][l3] * cos_lat[l3] * cos_lon[c3];
                        ppv3gy = msldemc_radius[c3][l3] * cos_lat[l3] * sin_lon[c3];
                        ppv3gz = msldemc_radius[c3][l3] * sin_lat[l3];
                        // ppv4gx = msldemc_img_radius[c4][l4] * cos_lat[l4] * cos_lon[c4];
                        // ppv4gy = msldemc_img_radius[c4][l4] * cos_lat[l4] * sin_lon[c4];
                        // ppv4gz = msldemc_img_radius[c4][l4] * sin_lat[l4];
                        /* projection */
                        pmcx = ppv1gx-cam_C[0]; pmcy = ppv1gy-cam_C[1]; pmcz = ppv1gz-cam_C[2];
                        dv1 = pmcx*cam_A[0] + pmcy*cam_A[1] + pmcz*cam_A[2];
                        ppv1x = (pmcx*cam_H[0] + pmcy*cam_H[1] + pmcz*cam_H[2])/dv1;
                        ppv1y = (pmcx*cam_V[0] + pmcy*cam_V[1] + pmcz*cam_V[2])/dv1;
                        
                        pmcx = ppv2gx-cam_C[0]; pmcy = ppv2gy-cam_C[1]; pmcz = ppv2gz-cam_C[2];
                        dv2 = pmcx*cam_A[0] + pmcy*cam_A[1] + pmcz*cam_A[2];
                        ppv2x = (pmcx*cam_H[0] + pmcy*cam_H[1] + pmcz*cam_H[2])/dv2;
                        ppv2y = (pmcx*cam_V[0] + pmcy*cam_V[1] + pmcz*cam_V[2])/dv2;
                        
                        pmcx = ppv3gx-cam_C[0]; pmcy = ppv3gy-cam_C[1]; pmcz = ppv3gz-cam_C[2];
                        dv3 = pmcx*cam_A[0] + pmcy*cam_A[1] + pmcz*cam_A[2];
                        ppv3x = (pmcx*cam_H[0] + pmcy*cam_H[1] + pmcz*cam_H[2])/dv3;
                        ppv3y = (pmcx*cam_V[0] + pmcy*cam_V[1] + pmcz*cam_V[2])/dv3;
                        
                        // define some plane parameters
                        pdv1x = ppv2x - ppv1x; pdv1y = ppv2y - ppv1y;
                        pdv2x = ppv3x - ppv1x; pdv2y = ppv3y - ppv1y;
                        detM = pdv1x*pdv2y - pdv1y*pdv2x;
                        Minv[0][0] = pdv2y/detM;
                        Minv[0][1] = -pdv2x/detM;
                        Minv[1][0] = -pdv1y/detM;
                        Minv[1][1] = pdv1x/detM;
                        
                        // vector in the 3d domain for angle calculation
                        // 2020.09.11 by Yuki.
                        pdv1x = ppv2gx - ppv1gx;
                        pdv1y = ppv2gy - ppv1gy;
                        pdv1z = ppv2gz - ppv1gz;
                        pdv2x = ppv3gx - ppv1gx;
                        pdv2y = ppv3gy - ppv1gy;
                        pdv2z = ppv3gz - ppv1gz;
                        pnx = pdv1y*pdv2z - pdv1z*pdv2y;
                        pny = pdv1z*pdv2x - pdv1x*pdv2z;
                        pnz = pdv1x*pdv2y - pdv1y*pdv2x;
                        // Normalize the plane normal vector.
                        pn_len = sqrt(pnx*pnx+pny*pny+pnz*pnz);
                        pnx /= pn_len; pny /= pn_len; pnz /= pn_len;
                        // If the normal vector is looking up, then flip its sign.
                        // note that z is positive in the downward direction.
                        if(pnz<0){
                            pnx = -pnx; pny = -pny; pnz = -pnz;
                        }
                        pc = pnx * ppv1gx + pny * ppv1gy + pnz * ppv1gz;
                        
                        
                        /* nth binned cell: n-0.5 <--> n+0.5 */
                        x_min = (int32_T) floor(fmin(fmin(ppv1x,ppv2x),ppv3x)+0.5);
                        x_max = (int32_T) ceil(fmax(fmax(ppv1x,ppv2x),ppv3x)+0.5);
                        
                        if(x_min<0){
                            x_min = 0;
                        } else if(x_min>crism_samples_m1){
                            x_min = crism_samples_m1;
                        }
                        if(x_max<1){
                            x_max = 1;
                        } else if(x_max>crism_samples) {
                            x_max = crism_samples;
                        }
                        
                        
                        /* xbi: x bin index, ybi: y bin index */
                        for(xbi=x_min;xbi<x_max;xbi++){
                            for (n=0;n<bin_count[xbi];n++){
                                xi = bin_im_c[xbi][n];
                                xap_xiyi = PmC_imxyap[xi][0];
                                yap_xiyi = PmC_imxyap[xi][1];
                                pipvx = xap_xiyi - ppv1x; pipvy = yap_xiyi - ppv1y; 
                                pprm_sd = Minv[0][0]*pipvx+Minv[0][1]*pipvy;
                                pprm_td = Minv[1][0]*pipvx+Minv[1][1]*pipvy;
                                pp_sum = pprm_sd+pprm_td;
                                if(pprm_sd>=0 && pprm_td>=0 && pp_sum<=1)
                                {
                                    // Conversion from plane parameters in the image plane
                                    // into plane parameters on the polygonal surface.
                                    pd2 = pprm_sd / dv2;
                                    pd3 = pprm_td / dv3;
                                    pd1 = (1-pp_sum) / dv1;
                                    pd_dem = pd1+pd2+pd3;
                                    pprm_s = pd2 / pd_dem;
                                    pprm_t = pd3 / pd_dem;
                                    pprm_1st = 1 - pprm_s - pprm_t;
                                    //printf("isinFOVd=%d\n",isinFOVd);

                                    // Evaluate distance
                                    //pipvgx = (1-pp_sum)*ppv1gx+pprm_px*ppv2gx+pprm_py*ppv3gx;
                                    //pipvgy = (1-pp_sum)*ppv1gy+pprm_px*ppv2gy+pprm_py*ppv3gy;
                                    //pipvgz = (1-pp_sum)*ppv1gz+pprm_px*ppv2gz+pprm_py*ppv3gz;
                                    pipvgx = pprm_1st*ppv1gx+pprm_s*ppv2gx+pprm_t*ppv3gx;
                                    pipvgy = pprm_1st*ppv1gy+pprm_s*ppv2gy+pprm_t*ppv3gy;
                                    pipvgz = pprm_1st*ppv1gz+pprm_s*ppv2gz+pprm_t*ppv3gz;
                                    //printf("isinFOVd=%d\n",isinFOVd);

                                    rnge = pow(pipvgx-cam_C[0],2) + pow(pipvgy-cam_C[1],2) + pow(pipvgz-cam_C[2],2);
                                    // printf("isinFOVd=%d\n",isinFOVd);
                                    // printf("rnge=%f\n",rnge);
                                    // printf("im_range[%d][%d]=%f\n",xi,yi,im_range[xi][yi]);


                                    if(rnge < crism_range[xi])
                                    {
                                        //printf("isinFOVd=%d\n",isinFOVd);
                                        crism_range[xi]  = rnge;
                                        crism_xyz[xi][0] = pipvgx;
                                        crism_xyz[xi][1] = pipvgy;
                                        crism_xyz[xi][2] = pipvgz;
                                        crism_ref[xi][0] = (int32_T) c;
                                        crism_ref[xi][1] = (int32_T) l;
                                        crism_ref[xi][2] = (int32_T) sxy;

                                        // provide angle information
                                        crism_pln[xi][0] = pnx;
                                        crism_pln[xi][1] = pny;
                                        crism_pln[xi][2] = pnz;
                                        crism_pln[xi][3] = pc;
                                        crism_cosemi[xi] = crism_PmC[xi][0]*pnx+crism_PmC[xi][1]*pny+crism_PmC[xi][2]*pnz;
                                    }
                                }
                            }
                                
                        }
                    }
//                     else if(isinFOV) // if(isinFOV) This mode is rarely invoked and not debugged well.
//                     {
//                         /* parameters for plane equations
//                          * plane normal vector (pn)
//                          * plane constant (pc)
//                         */
//                         pdv1x = ppv2gx - ppv1gx;
//                         pdv1y = ppv2gy - ppv1gy;
//                         pdv1z = ppv2gz - ppv1gz;
//                         pdv2x = ppv3gx - ppv1gx;
//                         pdv2y = ppv3gy - ppv1gy;
//                         pdv2z = ppv3gz - ppv1gz;
//                         pnx = pdv1y*pdv2z - pdv1z*pdv2y;
//                         pny = pdv1z*pdv2x - pdv1x*pdv2z;
//                         pnz = pdv1x*pdv2y - pdv1y*pdv2x;
//                         // Normalize the plane normal vector.
//                         pn_len = sqrt(pnx*pnx+pny*pny+pnz*pnz);
//                         pnx /= pn_len; pny /= pn_len; pnz /= pn_len;
//                         // If the normal vector is looking up, then flip its sign.
//                         // note that z is positive in the downward direction.
//                         if(pnz<0){
//                             pnx = -pnx; pny = -pny; pnz = -pnz;
//                         }
//                         pc = pnx * ppv1gx + pny * ppv1gy + pnz * ppv1gz;
//                         lprm_nume = pnx*(ppv1gx-cam_C[0])+pny*(ppv1gy-cam_C[1])+pnz*(ppv1gz-cam_C[2]);
//                         
//                         /* Get Plane parameters */
//                         M[0][0] = pdv1x*pdv1x + pdv1y*pdv1y + pdv1z*pdv1z;
//                         M[0][1] = pdv1x*pdv2x + pdv1y*pdv2y + pdv1z*pdv2z;
//                         M[1][0] = M[0][1];
//                         M[1][1] = pdv2x*pdv2x + pdv2y*pdv2y + pdv2z*pdv2z;
//                         detM = M[0][0]*M[1][1] - M[0][1]*M[0][1];
//                         Minv[0][0] = M[1][1]/detM;
//                         Minv[0][1] = -M[0][1]/detM;
//                         Minv[1][0] = -M[1][0]/detM;
//                         Minv[1][1] = M[0][0]/detM;
//                         Minvp[0][0] = Minv[0][0]*pdv1x+Minv[0][1]*pdv2x;
//                         Minvp[0][1] = Minv[0][0]*pdv1y+Minv[0][1]*pdv2y;
//                         Minvp[0][2] = Minv[0][0]*pdv1z+Minv[0][1]*pdv2z;
//                         Minvp[1][0] = Minv[1][0]*pdv1x+Minv[1][1]*pdv2x;
//                         Minvp[1][1] = Minv[1][0]*pdv1y+Minv[1][1]*pdv2y;
//                         Minvp[1][2] = Minv[1][0]*pdv1z+Minv[1][1]*pdv2z;
//                         
//                         // If isinFOV but not in FOVd
//                         for(xbi=0;xbi<S_im;xbi++){
//                             for(ybi=0;ybi<L_im;ybi++){
//                                 for (n=0;n<bin_count_im[xbi][ybi];n++){
//                                     xi = bin_im_c[xbi][ybi][n];
//                                     yi = bin_im_l[xbi][ybi][n];
//                                     pmcx_xiyi = PmCx[xi][yi];
//                                     pmcy_xiyi = PmCy[xi][yi];
//                                     pmcz_xiyi = PmCz[xi][yi];
//                                     // line plane intersect
//                                     lprm = lprm_nume/(pnx*pmcx_xiyi+pny*pmcy_xiyi+pnz*pmcz_xiyi);
//                                     /* if looking at the right direction */
//                                     if(lprm>0)
//                                     {
//                                         // plane intersection pointing vector
//                                         pipvgx = cam_C[0] + lprm*pmcx_xiyi;
//                                         pipvgy = cam_C[1] + lprm*pmcy_xiyi;
//                                         pipvgz = cam_C[2] + lprm*pmcz_xiyi;
// 
//                                         pipvgppv1x = pipvgx - ppv1gx;
//                                         pipvgppv1y = pipvgy - ppv1gy;
//                                         pipvgppv1z = pipvgz - ppv1gz;
// 
//                                         // Get plane coefficiets
//                                         pprm_s = Minvp[0][0]*pipvgppv1x+Minvp[0][1]*pipvgppv1y+Minvp[0][2]*pipvgppv1z;
//                                         pprm_t = Minvp[1][0]*pipvgppv1x+Minvp[1][1]*pipvgppv1y+Minvp[1][2]*pipvgppv1z;
//                                         pprm_1st = 1 - pprm_s - pprm_t;
//                                     
//                                         if(pprm_s>0 && pprm_t>0 && pprm_1st>0){
//                                             rnge = pow(pipvgx-cam_C[0],2) + pow(pipvgy-cam_C[1],2) + pow(pipvgz-cam_C[2],2);
//                                             if(rnge < im_range[xi][yi]){
//                                                 im_range[xi][yi] = rnge;
//                                                 im_north[xi][yi] = pipvgx;
//                                                 im_east[xi][yi]  = pipvgy;
//                                                 im_elev[xi][yi]  = -pipvgz;
//                                                 im_refx[xi][yi]  = (int32_T) c;
//                                                 im_refy[xi][yi]  = (int32_T) l;
//                                                 im_refs[xi][yi]  = (int32_T) sxy;
//                                                 //printf("isinFOVd=%d\n",isinFOVd);
//                                                 
//                                                 // provide angle information
//                                                 im_pnx[xi][yi] = pnx;
//                                                 im_pny[xi][yi] = pny;
//                                                 im_pnz[xi][yi] = pnz;
//                                                 im_pc[xi][yi] = pc;
//                                                 im_cosemi[xi][yi] = pmcx_xiyi*pnx+pmcy_xiyi*pny+pmcz_xiyi*pnz;
//                                                 /* Note that plane normal vector is looking downward.
//                                                  */
// 
//                                                 // evaluate nearest neighbor
//                                                 dst_ppv[0] = get_sqr_dst(pipvgx,pipvgy,pipvgz,ppv1gx,ppv1gy,ppv1gz);
//                                                 dst_ppv[1] = get_sqr_dst(pipvgx,pipvgy,pipvgz,ppv2gx,ppv2gy,ppv2gz);
//                                                 dst_ppv[2] = get_sqr_dst(pipvgx,pipvgy,pipvgz,ppv3gx,ppv3gy,ppv3gz);
//                                                 dst_ppv[3] = get_sqr_dst(pipvgx,pipvgy,pipvgz,ppv4gx,ppv4gy,ppv4gz);
//                                                 //printf("isinFOVd=%d\n",isinFOVd);
//                                                 dst_nn = dst_ppv[0]; di_dst_min = 0;
//                                                 for(di=1;di<4;di++){
//                                                     if(dst_nn > dst_ppv[di]){
//                                                         dst_nn = dst_ppv[di];
//                                                         di_dst_min = di;
//                                                     }
//                                                 }
//                                                 im_nnx[xi][yi] = ppvx[di_dst_min];
//                                                 im_nny[xi][yi] = ppvy[di_dst_min]; 
//                                             }
//                                         }
//                                     }
//                                 }
//                             }
//                         }
//                     }    
                }
            } 
        }
    }
    
    // printf("crism_sampels = %d\n",crism_samples);
    for(xi=0;xi<crism_samples;xi++){
        if(bin_count[xi]>0)
            free(bin_im_c[xi]);
    }
    free(PmC_imxyap);
    free(PmC_imxyap_base);
    free(bin_count);
    free(bin_im_c);
    free(cos_lon);
    free(cos_lat);
    free(sin_lon);
    free(sin_lat);
    free(crism_range);
}

/* The gateway function */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
    double **msldemc_radius;
    CAHV_MODEL cahv_mdl;
    double *msldemc_latitude_rad;
    double *msldemc_longitude_rad;
    int8_T **msldemc_imFOVmask;
    double **crism_PmC;
    
    double **crism_xyz;
    int32_T **crism_ref;
    double *crism_cosemi;
    double **crism_pln;
    
    mwIndex xi;
    mwSize msldemc_samples, msldemc_lines;
    mwSize crism_samples, Npmc;

    /* -----------------------------------------------------------------
     * CHECK PROPER NUMBER OF INPUTS AND OUTPUTS
     * ----------------------------------------------------------------- */
    /* if(nrhs!=11) {
        mexErrMsgIdAndTxt("proj_mastcam2MSLDEM_v4_mex:nrhs","Eleven inputs required.");
    }
    if(nlhs!=1) {
        mexErrMsgIdAndTxt("proj_mastcam2MSLDEM_v4_mex:nlhs","Five outputs required.");
    }
    */
    /* make sure the first input argument is scalar */
    /*
    if( !mxIsChar(prhs[0]) ) {
        mexErrMsgIdAndTxt("proj_mastcam2MSLDEM_v4_mex:notChar","Input 0 needs to be a character vector.");
    }
    */
    /* -----------------------------------------------------------------
     * I/O SETUPs
     * ----------------------------------------------------------------- */
    
    /* INPUT 0 msldem_radius */
    msldemc_radius  = set_mxDoubleMatrix(prhs[0]);
    msldemc_lines   = mxGetM(prhs[0]);
    msldemc_samples = mxGetN(prhs[0]);
    
    /* INPUT 1/2 latitude/longitude radians */
    msldemc_latitude_rad  = mxGetDoubles(prhs[1]);
    msldemc_longitude_rad = mxGetDoubles(prhs[2]);
    
    /* INPUT 3 msldemc_sheader*/
    msldemc_imFOVmask = set_mxInt8Matrix(prhs[3]);
    
    /* INPUT 4 camera model */
    cahv_mdl = mxGet_CAHV_MODEL(prhs[4]);
    
    /* INPUT 5 crism samples, used for binning */
    crism_samples = (mwSize) mxGetScalar(prhs[5]);
    
    /* INPUT 6 crism pmc vectors */
    crism_PmC = set_mxDoubleMatrix(prhs[6]);
    Npmc      = mxGetN(prhs[6]);
    

    /* 0  crism_xyz      [3 x crism_samples]
     * 1  crism_ref      [3 x crism_samples]   Integer
     * 2  crism_cosemi   [1 x crism_samples]   Double - cosine of emmission
     *                                         angles
     * 3  crism_pln      [4 x crism_samples]   xyz of surface plane normal 
     *                                         vector and plane constant
     */
    
    /* OUTPUT 0  */
    plhs[0]      = mxCreateDoubleMatrix(3,Npmc,mxREAL);
    crism_xyz    = set_mxDoubleMatrix(plhs[0]);
    
    plhs[1]      = mxCreateNumericMatrix(3,Npmc,mxINT32_CLASS,mxREAL);
    crism_ref    = set_mxInt32Matrix(plhs[1]);
    
    plhs[2]      = mxCreateNumericArray(1,&Npmc,mxDOUBLE_CLASS,mxREAL);
    crism_cosemi = mxGetDoubles(plhs[2]);
    
    plhs[3]      = mxCreateDoubleMatrix(4,Npmc,mxREAL);
    crism_pln    = set_mxDoubleMatrix(plhs[3]);
    
    // Initialize matrices
    for(xi=0;xi<Npmc;xi++){
            crism_xyz[xi][0] = NAN;
            crism_xyz[xi][1] = NAN;
            crism_xyz[xi][2] = NAN;
            crism_ref[xi][0] = -1;
            crism_ref[xi][1] = -1;
            crism_ref[xi][2] = -1;
            crism_cosemi[xi] = NAN;
            crism_pln[xi][0] = NAN;
            crism_pln[xi][1] = NAN;
            crism_pln[xi][2] = NAN;
    }
    // printf("crism_sampels = %d\n",crism_samples);
    /* -----------------------------------------------------------------
     * CALL MAIN COMPUTATION ROUTINE
     * ----------------------------------------------------------------- */
    crism_get_incpt_msldemc(msldemc_radius, 
            (int32_T) msldemc_samples, (int32_T) msldemc_lines,
            msldemc_latitude_rad, msldemc_longitude_rad,
            msldemc_imFOVmask, cahv_mdl, (int32_T) crism_samples, 
            crism_PmC, (int32_T) Npmc,
            crism_xyz, crism_ref,crism_cosemi, crism_pln);
    
    // printf("crism_sampels = %d\n",crism_samples);
    /* free memories */
    mxFree(msldemc_radius);
    mxFree(msldemc_imFOVmask);
    mxFree(crism_PmC);
    mxFree(crism_xyz);
    mxFree(crism_ref);
    mxFree(crism_pln);
    
}
