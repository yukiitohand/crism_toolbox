/* =====================================================================
 * cahvor_iaumars_proj_crism2MSLDEM_v6_mex.c
 * Read MSLDEM image data
 * Perform projection of crism pixel centers onto MSLDEM data in the IAU_MARS 
 * planetocentric coordinate system
 * 
 * INPUTS:
 * 0 msldem_imgpath        char*
 * 1 msldem_header         struct
 * 2 mslrad_offset         Double Scalar
 * 3 msldemc_header        struct
 * 4 msldemc_latitude      Double array [L_demc]
 * 5 msldemc_longitude     Double array [S_demc]
 * 6 msldemc_imFOVmask     Boolean [L_demc x S_demc]
 * 7 lList_lofst           int32 scalar
 * 8 lList_lines           int32 scalar
 * 9 lList_cofst           int32 [msldemc_lines x 1]
 * 10 lList_cols           int32 [msldemc_lines x 1]
 * 11 S_im                  int
 * 12 L_im                  int
 * 13 cahv_mdl             CAHV_MODEL
 * 14 PmCx                 Double [L_im*S_im]
 * 15 PmCy                 Double [L_im*S_im]
 * 16 PmCz                 Double [L_im*S_im]
 * 
 * 
 * OUTPUTS:
 * 0  im_xiaumars    [L_im x S_im]   Double / Float
 * 1  im_yiaumars    [L_im x S_im]
 * 2  im_ziaumars    [L_im x S_im]
 * 3  im_refx        [L_im x S_im]   Integer
 * 4  im_refy        [L_im x S_im]   Integer
 * 5  im_refs        [L_im x S_im]   Integer
 * 6  im_range       [L_im x S_im]       Double / Float
 * 7  im_nnx         [L_im x S_im]   Integer
 * 8  im_nny         [L_im x S_im]   Integer
//  * 9  im_cosemi      [L_im x S_im]   Double - cosine of emmission angles
//  * 10 im_pnx         [L_im x S_im]   x of surface plane normal vector 
//  * 11 im_pny         [L_im x S_im]   y of surface plane normal vector
//  * 12 im_pnz         [L_im x S_im]   z of surface plane normal vector
//  * 13 im_pc          [L_im x S_im]   surface plane constant
 * 
 * Note: plane normal vectors are always looking into the side of the origin. 
 *
 * This is a MEX file for MATLAB.
 *
 * Copyright (C) 2021 Yuki Itoh <yukiitohand@gmail.com>
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

double get_sqr_dst_2d(double ux,double uy,double vx,double vy)
{
    double dst;
    double t;
    t=ux-vx;
    dst = t*t;
    t=uy-vy;
    dst += t*t;
    return dst;
}

/* main computation routine */
void proj_mastcam2MSLDEM(char *msldem_imgpath, EnviHeader msldem_header, 
        int32_T msldemc_imxy_sample_offset, int32_T msldemc_imxy_line_offset,
        int32_T msldemc_samples, int32_T msldemc_lines,
        double *msldemc_latitude, double *msldemc_longitude, double mslrad_offset,
        int8_T **msldemc_imFOVmask,
        int32_t lList_lofst, int32_t lList_lines,
        int32_t *lList_cofst, int32_t *lList_cols,
        int32_T S_im, int32_T L_im, CAHV_MODEL cahv_mdl,
        double **PmCx, double **PmCy, double **PmCz,
        double **im_xiaumars, double **im_yiaumars, double **im_ziaumars,
        int32_T **im_refx, int32_T **im_refy, int32_T **im_refs,
        double **im_range, int32_T **im_nnx, int32_T **im_nny)
        //double **im_cosemi, double **im_pnx, double **im_pny, double **im_pnz,
        //double **im_pc)
{
    int32_T c,l;
    int32_T L_demcm1,S_demcm1;
    int32_t s0,send,l0,lend;
    int16_T sxy;
    long skip_pri;
    long skip_l, skip_r;
    float *elevl,*elevlp1;
    size_t ncpy;
    size_t msldemc_samples_size_t;
    const int sz=sizeof(float);
    FILE *fid;
    double ppv1gx,ppv1gy,ppv1gz,ppv2gx,ppv2gy,ppv2gz,ppv3gx,ppv3gy,ppv3gz,ppv4gx,ppv4gy,ppv4gz;
    double pmcv1x,pmcv1y,pmcv1z;
    double pmcv2x,pmcv2y,pmcv2z;
    double pmcv3x,pmcv3y,pmcv3z;
    double ppv1x,ppv1y,ppv2x,ppv2y,ppv3x,ppv3y; /* Plane Position Vectors */
    double pdv1x,pdv1y,pdv1z,pdv2x,pdv2y,pdv2z;
    double detM;
    // double M[2][2];
    double Minv[3][3];
    //double Minvp[2][3];
    int32_T x_min,y_min,x_max,y_max;
    int32_T xi,yi;
    // double pipvx,pipvy;
    double pipvgx,pipvgy,pipvgz;
    // double pipvgppv1x,pipvgppv1y,pipvgppv1z;
    double rnge;
    double pprm_s,pprm_t,pprm_u;
    // double pprm_sd,pprm_td; /* plane parameter for projected image plane */
    // double dv1,dv2,dv3;
    // double pd1,pd2,pd3,pp_sum,pd_dem;
    // double pprm_s,pprm_t,pprm_1st;
    int32_T ppvx[3];
    int32_T ppvy[3];
    // double dst_ppv[3];
    // double dst_nn;
    // int32_T di,di_dst_min;
    bool isinFOVd,isinFOV;
    // double pmcx_xiyi,pmcy_xiyi,pmcz_xiyi;
    
    double pnx,pny,pnz; /* Plane Normal vectors */
    double pn_len;
    double pc; /* Plane Constant */
    double lprm,lprm_nume; /* line parameters */
    
    int32_T ***bin_im_c, **bin_im_c_base;
    int32_T ***bin_im_l, **bin_im_l_base;
    
    int32_t **PmC_imxap, **PmC_imyap;
    int32_t *PmC_imxap_base, *PmC_imyap_base;
    int32_T **bin_count_im, *bin_count_im_base;
    int32_T S_imm1,L_imm1;
    double pmcx,pmcy,pmcz,apmc,hpmc,vpmc;
    
    double *cam_C, *cam_A, *cam_H, *cam_V;
    
    int32_T xbi,ybi;
    // double xap_xiyi,yap_xiyi;
    
    int32_T n;
    
    double *cos_lon, *sin_lon;
    double radius_tmp;
    double cos_lonc, sin_lonc, cos_latl, sin_latl, cos_latlp1, sin_latlp1;
    
    
    
    cam_C = cahv_mdl.C; cam_A = cahv_mdl.A; cam_H = cahv_mdl.H;
    cam_V = cahv_mdl.V;
    
    
    
    S_imm1 = S_im - 1; L_imm1 = L_im - 1;
    /*********************************************************************/
    /* compute the direct projection of pmc to a camera image plane 
     * They are apparent image coordinate. */
    createInt32Matrix(&PmC_imxap, &PmC_imxap_base, (size_t) S_im, (size_t) L_im);
    createInt32Matrix(&PmC_imyap, &PmC_imyap_base, (size_t) S_im, (size_t) L_im);
    for(xi=0;xi<S_im;xi++){
        for(yi=0;yi<L_im;yi++){
            pmcx = PmCx[xi][yi];
            pmcy = PmCy[xi][yi];
            pmcz = PmCz[xi][yi];
            apmc = cam_A[0]*pmcx + cam_A[1]*pmcy + cam_A[2]*pmcz;
            hpmc = cam_H[0]*pmcx + cam_H[1]*pmcy + cam_H[2]*pmcz;
            vpmc = cam_V[0]*pmcx + cam_V[1]*pmcy + cam_V[2]*pmcz;
            PmC_imxap[xi][yi] = (int32_t) floor(hpmc/apmc+0.5);
            PmC_imyap[xi][yi] = (int32_t) floor(vpmc/apmc+0.5);            
        }
    }
    /*********************************************************************/
    
    /* bin images of (imx_d, imy_d) apparent imx,imy */
    createInt32Matrix(&bin_count_im,&bin_count_im_base,(size_t) S_im, (size_t) L_im);
    /* initialization */
    for(xi=0;xi<S_im;xi++){
        for(yi=0;yi<L_im;yi++){
            bin_count_im[xi][yi] = 0;
        }
    }
    for(xi=0;xi<S_im;xi++){
        for(yi=0;yi<L_im;yi++){
            c = PmC_imxap[xi][yi];
            l = PmC_imyap[xi][yi];
            if(c<0)
                c=0;
            else if(c>S_imm1)
                c = S_imm1;

            if(l<0)
                l=0;
            else if(l>L_imm1)
                l = L_imm1;
            ++bin_count_im[c][l];
        }
    }
    
    
    createInt32PMatrix(&bin_im_c, &bin_im_c_base, (size_t) S_im, (size_t) L_im);
    createInt32PMatrix(&bin_im_l, &bin_im_l_base, (size_t) S_im, (size_t) L_im);
    
    for(xi=0;xi<S_im;xi++){
        for(yi=0;yi<L_im;yi++){
            if(bin_count_im[xi][yi]>0){
                bin_im_c[xi][yi] = (int32_T*) malloc(bin_count_im[xi][yi]*sizeof(int32_T));
                bin_im_l[xi][yi] = (int32_T*) malloc(bin_count_im[xi][yi]*sizeof(int32_T));
            } else {
                bin_im_c[xi][yi] = NULL;
                bin_im_l[xi][yi] = NULL;
            }
        }
    }
    
    for(xi=0;xi<S_im;xi++){
        for(yi=0;yi<L_im;yi++){
            bin_count_im[xi][yi] = 0;
        }
    }
    
    
    for(xi=0;xi<S_im;xi++){
        for(yi=0;yi<L_im;yi++){
            c = PmC_imxap[xi][yi];
            l = PmC_imyap[xi][yi];
            if(c<0)
                c=0;
            else if(c>S_imm1)
                c = S_imm1;

            if(l<0)
                l=0;
            else if(l>L_imm1)
                l = L_imm1;

            bin_im_c[c][l][bin_count_im[c][l]] = xi;
            bin_im_l[c][l][bin_count_im[c][l]] = yi;
            ++bin_count_im[c][l];
        }
    }
    
    
    
    /*********************************************************************/
    msldemc_samples_size_t = (size_t) msldemc_samples;
    fid = fopen(msldem_imgpath,"rb");
    l0 = lList_lofst; lend = l0+lList_lines-1;
    /* skip lines */
    skip_pri = (long) msldem_header.samples * ((long) msldemc_imxy_line_offset+(long) l0) * (long) sz;
    // printf("%d*%d*%d=%ld\n",msldem_header.samples,msldemc_imxy_line_offset,s,skip_pri);
    fseek(fid,skip_pri,SEEK_CUR);
    
    /* read the data */
    elevl = (float*) malloc(sz*msldemc_samples);
    elevlp1 = (float*) malloc(sz*msldemc_samples);
    skip_l = (long) sz * (long) msldemc_imxy_sample_offset;
    skip_r = ((long) msldem_header.samples - (long) msldemc_samples)* (long) sz - skip_l;
    ncpy = (size_t) msldemc_samples * sz;
    fseek(fid,skip_l,SEEK_CUR);
    fread(elevlp1,sz,msldemc_samples_size_t,fid);
    fseek(fid,skip_r,SEEK_CUR);
    
    L_demcm1 = msldemc_lines-1;
    S_demcm1 = msldemc_samples-1;
    
    cos_lon = (double*) malloc(sizeof(double) * (size_t) msldemc_samples);
    sin_lon = (double*) malloc(sizeof(double) * (size_t) msldemc_samples);
    for(c=0;c<msldemc_samples;c++){
        cos_lon[c] = cos(msldemc_longitude[c]);
        sin_lon[c] = sin(msldemc_longitude[c]);
    }
    
    // printf("%d,%d,%d\n",skip_l,msldemc_samples*s,skip_r);
    for(l=l0;l<lend;l++){
        memcpy(elevl,elevlp1,ncpy);
        fseek(fid,skip_l,SEEK_CUR);
        fread(elevlp1,sz,msldemc_samples_size_t,fid);
        fseek(fid,skip_r,SEEK_CUR);
        //printf("l=%d\n",l);
        // decide the first and last indexes to be assessed.
        cos_latl   = cos(msldemc_latitude[l]);
        sin_latl   = sin(msldemc_latitude[l]);
        cos_latlp1 = cos(msldemc_latitude[l+1]);
        sin_latlp1 = sin(msldemc_latitude[l+1]);
        s0 = lList_cofst[l]-1; send = lList_cofst[l]+lList_cols[l];
        if(s0<0){s0 = 0;}
        if(send>S_demcm1){send=S_demcm1;}
        for(c=s0;c<send;c++){
            // process if 
            //printf("c=%d,mask_lc = %d,mask_lp1c = %d\n",c,msldemc_imFOVmask[c][l],msldemc_imFOVmask[c][l+1]);
            if(msldemc_imFOVmask[c][l]>0 || msldemc_imFOVmask[c][l+1]>0){
                //printf("c=%d\n",c);
                for(sxy=0;sxy<2;sxy++){
                    if(sxy==0){
                        /* 
                         *   v1     
                         *      c    c+1 
                         *    l o-----o v2
                         *      |   /
                         *      | /
                         *  l+1 o
                         *      v3
                         */
                        radius_tmp = (double) elevl[c] + mslrad_offset;
                        ppv1gx = radius_tmp * cos_latl * cos_lon[c];
                        ppv1gy = radius_tmp * cos_latl * sin_lon[c];
                        ppv1gz = radius_tmp * sin_latl;
                        radius_tmp = (double) elevl[c+1] + mslrad_offset;
                        ppv2gx = radius_tmp * cos_latl * cos_lon[c+1];
                        ppv2gy = radius_tmp * cos_latl * sin_lon[c+1];
                        ppv2gz = radius_tmp * sin_latl;
                        radius_tmp = (double) elevlp1[c] + mslrad_offset;
                        ppv3gx = radius_tmp * cos_latlp1 * cos_lon[c];
                        ppv3gy = radius_tmp * cos_latlp1 * sin_lon[c];
                        ppv3gz = radius_tmp * sin_latlp1;
                        // radius_tmp = (double) elevlp1[c+1] + mslrad_offset;
                        // ppv4gx = radius_tmp * cos_latlp1 * cos_lon[c+1];
                        // ppv4gy = radius_tmp * cos_latlp1 * sin_lon[c+1];
                        // ppv4gz = radius_tmp * sin_latlp1;
                        ppvx[0] = c; ppvx[1] = c+1; ppvx[2] = c  ; // ppvx[3] = c+1;
                        ppvy[0] = l; ppvy[1] = l  ; ppvy[2] = l+1; // ppvy[3] = l+1;
                        isinFOVd = (msldemc_imFOVmask[c][l]>1 && msldemc_imFOVmask[c+1][l]>1 && msldemc_imFOVmask[c][l+1]>1);
                        isinFOV  = (msldemc_imFOVmask[c][l]>0 && msldemc_imFOVmask[c+1][l]>0 && msldemc_imFOVmask[c][l+1]>0);
                        
                    }
                    else{
                        /* 
                         *            
                         *      c    c+1 
                         *    l       o v3
                         *          / |
                         *        /   |
                         *  l+1 o-----o
                         *      v2    v1
                         */
                        radius_tmp = (double) elevlp1[c+1] + mslrad_offset;
                        ppv1gx = radius_tmp * cos_latlp1 * cos_lon[c+1];
                        ppv1gy = radius_tmp * cos_latlp1 * sin_lon[c+1];
                        ppv1gz = radius_tmp * sin_latlp1;
                        radius_tmp = (double) elevlp1[c] + mslrad_offset;
                        ppv2gx = radius_tmp * cos_latlp1 * cos_lon[c];
                        ppv2gy = radius_tmp * cos_latlp1 * sin_lon[c];
                        ppv2gz = radius_tmp * sin_latlp1;
                        radius_tmp = (double) elevl[c+1] + mslrad_offset;
                        ppv3gx = radius_tmp * cos_latl * cos_lon[c+1];
                        ppv3gy = radius_tmp * cos_latl * sin_lon[c+1];
                        ppv3gz = radius_tmp * sin_latl;
                        // radius_tmp = (double) elevl[c] + mslrad_offset;
                        // ppv4gx = radius_tmp * cos_latl * cos_lon[c];
                        // ppv4gy = radius_tmp * cos_latl * sin_lon[c];
                        // ppv4gz = radius_tmp * sin_latl;
                        ppvx[0] = c+1; ppvx[1] = c  ; ppvx[2] = c+1; // ppvx[3] = c;
                        ppvy[0] = l+1; ppvy[1] = l+1; ppvy[2] = l  ; // ppvy[3] = l;
                        isinFOVd = (msldemc_imFOVmask[c+1][l+1]>1 && msldemc_imFOVmask[c][l+1]>1 && msldemc_imFOVmask[c+1][l]>1);
                        isinFOV  = (msldemc_imFOVmask[c+1][l+1]>0 && msldemc_imFOVmask[c][l+1]>0 && msldemc_imFOVmask[c+1][l]>0);
                        
                    }
                    //printf("sxy=%d\n",sxy);
                    //printf("isinFOVd=%d\n",isinFOVd);
                    if(isinFOVd)
                    {
                        /* projection */
                        pmcv1x  = ppv1gx - cam_C[0];
                        pmcv1y  = ppv1gy - cam_C[1];
                        pmcv1z  = ppv1gz - cam_C[2];
                        apmc  =  pmcv1x*cam_A[0] + pmcv1y*cam_A[1] + pmcv1z*cam_A[2];
                        ppv1x = (pmcv1x*cam_H[0] + pmcv1y*cam_H[1] + pmcv1z*cam_H[2])/apmc;
                        ppv1y = (pmcv1x*cam_V[0] + pmcv1y*cam_V[1] + pmcv1z*cam_V[2])/apmc;
                        
                        pmcv2x  = ppv2gx - cam_C[0];
                        pmcv2y  = ppv2gy - cam_C[1];
                        pmcv2z  = ppv2gz - cam_C[2];
                        apmc  =  pmcv2x*cam_A[0] + pmcv2y*cam_A[1] + pmcv2z*cam_A[2];
                        ppv2x = (pmcv2x*cam_H[0] + pmcv2y*cam_H[1] + pmcv2z*cam_H[2])/apmc;
                        ppv2y = (pmcv2x*cam_V[0] + pmcv2y*cam_V[1] + pmcv2z*cam_V[2])/apmc;
                        
                        
                        // pmcx = ppv3gx; pmcy = ppv3gy; pmcz = ppv3gz;
                        pmcv3x  = ppv3gx - cam_C[0];
                        pmcv3y  = ppv3gy - cam_C[1];
                        pmcv3z  = ppv3gz - cam_C[2];
                        apmc  =  pmcv3x*cam_A[0] + pmcv3y*cam_A[1] + pmcv3z*cam_A[2];
                        ppv3x = (pmcv3x*cam_H[0] + pmcv3y*cam_H[1] + pmcv3z*cam_H[2])/apmc;
                        ppv3y = (pmcv3x*cam_V[0] + pmcv3y*cam_V[1] + pmcv3z*cam_V[2])/apmc;
                        
                        //printf("c=%d\n",l);
                        Minv[0][0] = pmcv2y*pmcv3z - pmcv3y*pmcv2z;
                        Minv[0][1] = pmcv2z*pmcv3x - pmcv3z*pmcv2x;
                        Minv[0][2] = pmcv2x*pmcv3y - pmcv3x*pmcv2y;
                        detM = pmcv1x*Minv[0][0] + pmcv1y * Minv[0][1] + pmcv1z * Minv[0][2];
                        Minv[0][0] /= detM;
                        Minv[0][1] /= detM;
                        Minv[0][2] /= detM;
                        Minv[1][0] = (pmcv3y*pmcv1z-pmcv1y*pmcv3z)/detM;
                        Minv[1][1] = (pmcv3z*pmcv1x-pmcv1z*pmcv3x)/detM;
                        Minv[1][2] = (pmcv3x*pmcv1y-pmcv1x*pmcv3y)/detM;
                        Minv[2][0] = (pmcv1y*pmcv2z-pmcv2y*pmcv1z)/detM;
                        Minv[2][1] = (pmcv1z*pmcv2x-pmcv2z*pmcv1x)/detM;
                        Minv[2][2] = (pmcv1x*pmcv2y-pmcv2x*pmcv1y)/detM;
                        
                        // vector in the 3d domain for angle calculation
                        // 2020.09.11 by Yuki.
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
//                         
//                         pc = pnx * ppv1gx + pny * ppv1gy + pnz * ppv1gz;
//                         if(pc>0){
//                             /* pc is the plane constant, how much shifted from
//                              * the origin. We want to set the normal vector so 
//                              * that it points to the origin side.
//                              * */
//                             pnx *= -1; pny *= -1; pnz *= -1;
//                             pc *= -1;
//                         }
                        
                        x_min = (int32_T) floor(fmin(fmin(ppv1x,ppv2x),ppv3x)+0.5);
                        y_min = (int32_T) floor(fmin(fmin(ppv1y,ppv2y),ppv3y)+0.5);
                        x_max = (int32_T) floor(fmax(fmax(ppv1x,ppv2x),ppv3x)+1.5);
                        y_max = (int32_T) floor(fmax(fmax(ppv1y,ppv2y),ppv3y)+1.5);
                        
                        if(x_min<0){
                            x_min = 0;
                        } else if(x_min>S_imm1){
                            x_min = S_imm1;
                        }
                        if(x_max<1){
                            x_max = 1;
                        } else if(x_max>S_im) {
                            x_max = S_im;
                        }
                        
                        if(y_min<0){
                            y_min = 0;
                        }else if(y_min>L_imm1){
                            y_min = L_imm1;
                        }
                        if(y_max<1){
                            y_max = 1;
                        }else if(y_max>L_im){
                            y_max = L_im;
                        }
                        
                        /* xbi: x bin index, ybi: y bin index */
                        for(xbi=x_min;xbi<x_max;xbi++){
                            for(ybi=y_min;ybi<y_max;ybi++){
                                for (n=0;n<bin_count_im[xbi][ybi];n++){
                                    xi = bin_im_c[xbi][ybi][n];
                                    yi = bin_im_l[xbi][ybi][n];
                                    pmcx = PmCx[xi][yi];
                                    pmcy = PmCy[xi][yi];
                                    pmcz = PmCz[xi][yi];
                                    pprm_s = Minv[0][0]*pmcx+Minv[0][1]*pmcy+Minv[0][2]*pmcz;
                                    if(pprm_s>0){
                                        pprm_t = Minv[1][0]*pmcx+Minv[1][1]*pmcy+Minv[1][2]*pmcz;
                                        if(pprm_t>0){
                                            pprm_u = Minv[2][0]*pmcx+Minv[2][1]*pmcy+Minv[2][2]*pmcz;
                                            if(pprm_u>0){
                                                rnge = 1/(pprm_s + pprm_t + pprm_u);
                                                if(rnge < im_range[xi][yi]){
                                                    /* get the parameter at the intersection
                                                     * by extending the pmc */
                                                    pprm_s *=rnge; pprm_t *= rnge; pprm_u *=rnge;
                                                    pipvgx = pprm_s*ppv1gx+pprm_t*ppv2gx+pprm_u*ppv3gx;
                                                    pipvgy = pprm_s*ppv1gy+pprm_t*ppv2gy+pprm_u*ppv3gy;
                                                    pipvgz = pprm_s*ppv1gz+pprm_t*ppv2gz+pprm_u*ppv3gz;
                                                    im_range[xi][yi] = rnge;
                                                    im_xiaumars[xi][yi] = pipvgx;
                                                    im_yiaumars[xi][yi] = pipvgy;
                                                    im_ziaumars[xi][yi] = pipvgz;
                                                    im_refx[xi][yi]  = (int32_T) c;
                                                    im_refy[xi][yi]  = (int32_T) l;
                                                    im_refs[xi][yi]  = (int32_T) sxy;
                                                    
                                                    /* emission angle information */
                                                    // im_pnx[xi][yi] = pnx;
                                                    // im_pny[xi][yi] = pny;
                                                    // im_pnz[xi][yi] = pnz;
                                                    // im_pc[xi][yi] = pc;
                                                    // im_cosemi[xi][yi] = PmCx[xi][yi]*pnx+PmCy[xi][yi]*pny+PmCz[xi][yi]*pnz;
                                                    
                                                    /* Following nearest neighbor only works for the specific assignment of v1 v2 v3
                                                     * in this implementation.
                                                     * Use distance based method for more general triangles.    
                                                     *     v1      
                                                     *    o--+--o v2
                                                     *    |__|/ 
                                                     *    | /
                                                     *    o'
                                                     *      v3
                                                     */
                                                    if(pprm_t>0.5){
                                                        im_nnx[xi][yi] = ppvx[1];
                                                        im_nny[xi][yi] = ppvy[1];
                                                    } else if(pprm_u>0.5){
                                                        im_nnx[xi][yi] = ppvx[2];
                                                        im_nny[xi][yi] = ppvy[2];
                                                    } else {
                                                        im_nnx[xi][yi] = ppvx[0];
                                                        im_nny[xi][yi] = ppvy[0];
                                                    }
                                                    
                                                    // dst_ppv[0] = get_sqr_dst_2d(pipvgx,pipvgy,ppv1gx,ppv1gy);
                                                    // dst_ppv[1] = get_sqr_dst_2d(pipvgx,pipvgy,ppv2gx,ppv2gy);
                                                    // dst_ppv[2] = get_sqr_dst_2d(pipvgx,pipvgy,ppv3gx,ppv3gy);
                                                    // dst_ppv[3] = get_sqr_dst_2d(pipvgx,pipvgy,ppv4gx,ppv4gy);
                                                    //printf("isinFOVd=%d\n",isinFOVd);
                                                    // dst_nn = dst_ppv[0]; di_dst_min = 0;
                                                    // for(di=1;di<3;di++){
                                                    //     if(dst_nn > dst_ppv[di]){
                                                    //         dst_nn = dst_ppv[di];
                                                    //         di_dst_min = di;
                                                    //     }
                                                    // }
                                                    // im_nnx[xi][yi] = ppvx[di_dst_min];
                                                    // im_nny[xi][yi] = ppvy[di_dst_min];
                                                    
                                                }
                                            }
                                        }
                                    }
                                    
                                    //xap_xiyi = PmC_imxap[xi][yi];
                                    //yap_xiyi = PmC_imyap[xi][yi];
                                    //pipvx = xap_xiyi - ppv1x; pipvy = yap_xiyi - ppv1y; 
                                    //pprm_sd = Minv[0][0]*pipvx+Minv[0][1]*pipvy;
                                    //pprm_td = Minv[1][0]*pipvx+Minv[1][1]*pipvy;
                                    //pp_sum = pprm_sd+pprm_td;
//                                     if(pprm_sd>=0 && pprm_td>=0 && pp_sum<=1){
//                                         // Conversion from plane parameters in the image plane
//                                         // into plane parameters on the polygonal surface.
//                                         pd2 = pprm_sd / dv2;
//                                         pd3 = pprm_td / dv3;
//                                         pd1 = (1-pp_sum) / dv1;
//                                         pd_dem = pd1+pd2+pd3;
//                                         pprm_s = pd2 / pd_dem;
//                                         pprm_t = pd3 / pd_dem;
//                                         pprm_1st = 1 - pprm_s - pprm_t;
//                                         //printf("isinFOVd=%d\n",isinFOVd);
// 
//                                         // Evaluate distance
//                                         //pipvgx = (1-pp_sum)*ppv1gx+pprm_px*ppv2gx+pprm_py*ppv3gx;
//                                         //pipvgy = (1-pp_sum)*ppv1gy+pprm_px*ppv2gy+pprm_py*ppv3gy;
//                                         //pipvgz = (1-pp_sum)*ppv1gz+pprm_px*ppv2gz+pprm_py*ppv3gz;
//                                         pipvgx = pprm_1st*ppv1gx+pprm_s*ppv2gx+pprm_t*ppv3gx;
//                                         pipvgy = pprm_1st*ppv1gy+pprm_s*ppv2gy+pprm_t*ppv3gy;
//                                         pipvgz = pprm_1st*ppv1gz+pprm_s*ppv2gz+pprm_t*ppv3gz;
//                                         //printf("isinFOVd=%d\n",isinFOVd);
// 
//                                         rnge = pow(pipvgx-cam_C[0],2) + pow(pipvgy-cam_C[1],2) + pow(pipvgz-cam_C[2],2);
//                                         // printf("isinFOVd=%d\n",isinFOVd);
//                                         // printf("rnge=%f\n",rnge);
//                                         // printf("im_range[%d][%d]=%f\n",xi,yi,im_range[xi][yi]);
// 
// 
//                                         if(rnge < im_range[xi][yi])
//                                         {
//                                             //printf("isinFOVd=%d\n",isinFOVd);
//                                             im_range[xi][yi] = rnge;
//                                             im_xiaumars[xi][yi] = pipvgx;
//                                             im_yiaumars[xi][yi] = pipvgy;
//                                             im_ziaumars[xi][yi] = pipvgz;
//                                             im_refx[xi][yi]  = (int32_T) c;
//                                             im_refy[xi][yi]  = (int32_T) l;
//                                             im_refs[xi][yi]  = (int32_T) sxy;
// 
//                                             // provide angle information
//                                             im_pnx[xi][yi] = pnx;
//                                             im_pny[xi][yi] = pny;
//                                             im_pnz[xi][yi] = pnz;
//                                             im_pc[xi][yi] = pc;
//                                             im_cosemi[xi][yi] = PmCx[xi][yi]*pnx+PmCy[xi][yi]*pny+PmCz[xi][yi]*pnz;
//                                             /* Note that plane normal vector is looking downward
//                                              */
//                                             //printf("isinFOVd=%d\n",isinFOVd);
// 
//                                             // evaluate nearest neighbor
//                                             //dst_ppv[0] = pow(pipvgx-ppv1gx,2)+pow(pipvgy-ppv1gy,2)+pow(pipvgz-ppv1gz,2);
//                                             //dst_ppv[1] = pow(pipvgx-ppv2gx,2)+pow(pipvgy-ppv2gy,2)+pow(pipvgz-ppv2gz,2);
//                                             //dst_ppv[2] = pow(pipvgx-ppv3gx,2)+pow(pipvgy-ppv3gy,2)+pow(pipvgz-ppv3gz,2);
//                                             //dst_ppv[3] = pow(pipvgx-ppv4gx,2)+pow(pipvgy-ppv4gy,2)+pow(pipvgz-ppv4gz,2);
//                                             // dst_ppv[0] = get_sqr_dst(pipvgx,pipvgy,pipvgz,ppv1gx,ppv1gy,ppv1gz);
//                                             // dst_ppv[1] = get_sqr_dst(pipvgx,pipvgy,pipvgz,ppv2gx,ppv2gy,ppv2gz);
//                                             // dst_ppv[2] = get_sqr_dst(pipvgx,pipvgy,pipvgz,ppv3gx,ppv3gy,ppv3gz);
//                                             // dst_ppv[3] = get_sqr_dst(pipvgx,pipvgy,pipvgz,ppv4gx,ppv4gy,ppv4gz);
//                                             dst_ppv[0] = get_sqr_dst_2d(pipvgx,pipvgy,ppv1gx,ppv1gy);
//                                             dst_ppv[1] = get_sqr_dst_2d(pipvgx,pipvgy,ppv2gx,ppv2gy);
//                                             dst_ppv[2] = get_sqr_dst_2d(pipvgx,pipvgy,ppv3gx,ppv3gy);
//                                             dst_ppv[3] = get_sqr_dst_2d(pipvgx,pipvgy,ppv4gx,ppv4gy);
//                                             //printf("isinFOVd=%d\n",isinFOVd);
//                                             dst_nn = dst_ppv[0]; di_dst_min = 0;
//                                             for(di=1;di<4;di++){
//                                                 if(dst_nn > dst_ppv[di]){
//                                                     dst_nn = dst_ppv[di];
//                                                     di_dst_min = di;
//                                                 }
//                                             }
//                                             im_nnx[xi][yi] = ppvx[di_dst_min];
//                                             im_nny[xi][yi] = ppvy[di_dst_min];
// 
//                                         }
//                                     }
                                }
                                
                            }
                        }
                    }
                    else if(isinFOV) // if(isinFOV) This mode is rarely invoked and not debugged well.
                    {
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
//                                                 im_xiaumars[xi][yi] = pipvgx;
//                                                 im_yiaumars[xi][yi] = pipvgy;
//                                                 im_ziaumars[xi][yi] = pipvgz;
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
                    }    
                }
            } 
        }
    }
    
    for(xi=0;xi<S_im;xi++){
        for(yi=0;yi<L_im;yi++){
            if(bin_count_im[xi][yi]>0){
                free(bin_im_c[xi][yi]);
                free(bin_im_l[xi][yi]);
            }
        }
    }
    
    free(PmC_imxap);
    free(PmC_imxap_base);
    free(PmC_imyap);
    free(PmC_imyap_base);
    free(bin_count_im);
    free(bin_count_im_base);
    free(bin_im_c);
    free(bin_im_c_base);
    free(bin_im_l);
    free(bin_im_l_base);
    free(elevl);
    free(elevlp1);
    free(cos_lon);
    free(sin_lon);
    fclose(fid);
}

/* The gateway function */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
    char *msldem_imgpath;
    EnviHeader msldem_header;
    CAHV_MODEL cahv_mdl;
    mwSize msldemc_sample_offset,msldemc_line_offset;
    double *msldemc_latitude;
    double *msldemc_longitude;
    double mslrad_offset;
    int8_T **msldemc_imFOVmask;
    int32_t lList_lofst, lList_lines;
    int32_t *lList_cofst, *lList_cols;
    mwSize S_im,L_im;
    double **PmCx, **PmCy, **PmCz;
    
    double **im_xiaumars;
    double **im_yiaumars;
    double **im_ziaumars;
    int32_T **im_refx;
    int32_T **im_refy;
    int32_T **im_refs;
    double **im_range;
    int32_T **im_nnx;
    int32_T **im_nny;
//     double **im_cosemi;
//     double **im_pnx;
//     double **im_pny;
//     double **im_pnz;
//     double **im_pc;
    
    mwIndex si,li;
    mwSize msldemc_samples, msldemc_lines;

    /* -----------------------------------------------------------------
     * CHECK PROPER NUMBER OF INPUTS AND OUTPUTS
     * ----------------------------------------------------------------- */
    if(nrhs!=17) {
        mexErrMsgIdAndTxt("cahvor_iaumars_proj_crism2MSLDEM_v6_mex:nrhs","17 inputs required.");
    }
    if(nlhs!=9) {
        mexErrMsgIdAndTxt("cahvor_iaumars_proj_crism2MSLDEM_v6_mex:nlhs","9 outputs required.");
    }
    
    /* make sure the first input argument is scalar */
    /*
    if( !mxIsChar(prhs[0]) ) {
        mexErrMsgIdAndTxt("proj_mastcam2MSLDEM_v4_mex:notChar","Input 0 needs to be a character vector.");
    }
    */
    /* -----------------------------------------------------------------
     * I/O SETUPs
     * ----------------------------------------------------------------- */
    
    /* INPUT 0 msldem_imgpath */
    msldem_imgpath = mxArrayToString(prhs[0]);
    
    /* INPUT 1 msldem_header */
    msldem_header = mxGetEnviHeader(prhs[1]);
    mslrad_offset     = mxGetScalar(prhs[2]);
    
    /* INPUT 2 msldemc_sheader*/
    msldemc_sample_offset = (mwSize) mxGetScalar(mxGetField(prhs[3],0,"sample_offset"));
    msldemc_line_offset   = (mwSize) mxGetScalar(mxGetField(prhs[3],0,"line_offset"));
    msldemc_samples       = (mwSize) mxGetScalar(mxGetField(prhs[3],0,"samples"));
    msldemc_lines         = (mwSize) mxGetScalar(mxGetField(prhs[3],0,"lines"));
    
    /* INPUT 3 msldem northing easting */
    msldemc_latitude  = mxGetDoubles(prhs[4]) + msldemc_line_offset  ;
    msldemc_longitude = mxGetDoubles(prhs[5]) + msldemc_sample_offset;
    
    
    /* INPUT 7 msldem imFOV */
    msldemc_imFOVmask = set_mxInt8Matrix(prhs[6]);

    lList_lofst = (int32_t) mxGetScalar(prhs[7]);
    lList_lines = (int32_t) mxGetScalar(prhs[8]);
    lList_cofst = mxGetInt32s(prhs[9]);
    lList_cols  = mxGetInt32s(prhs[10]);
    
    /* INPUT 8/9 image S_im, L_im */
    S_im = (mwSize) mxGetScalar(prhs[11]);
    L_im = (mwSize) mxGetScalar(prhs[12]);
    
    /* INPUT 10/11 camera model */
    cahv_mdl = mxGet_CAHV_MODEL(prhs[13]);
    
    /* INPUT 12/13/14 PmC */
    PmCx = set_mxDoubleMatrix(prhs[14]);
    PmCy = set_mxDoubleMatrix(prhs[15]);
    PmCz = set_mxDoubleMatrix(prhs[16]);
    
    /* OUTPUT 0/1/2 north-east-elevation */
    plhs[0]     = mxCreateDoubleMatrix(L_im,S_im,mxREAL);
    im_xiaumars = set_mxDoubleMatrix(plhs[0]);
    
    plhs[1]     = mxCreateDoubleMatrix(L_im,S_im,mxREAL);
    im_yiaumars = set_mxDoubleMatrix(plhs[1]);
    
    plhs[2]     = mxCreateDoubleMatrix(L_im,S_im,mxREAL);
    im_ziaumars = set_mxDoubleMatrix(plhs[2]);
    
    /* OUTPUT 3/4/5 im_ref x/y/zs */
    plhs[3] = mxCreateNumericMatrix(L_im,S_im,mxINT32_CLASS,mxREAL);
    im_refx = set_mxInt32Matrix(plhs[3]);
    
    plhs[4] = mxCreateNumericMatrix(L_im,S_im,mxINT32_CLASS,mxREAL);
    im_refy = set_mxInt32Matrix(plhs[4]);
    
    plhs[5] = mxCreateNumericMatrix(L_im,S_im,mxINT32_CLASS,mxREAL);
    im_refs = set_mxInt32Matrix(plhs[5]);
    
    /* OUTPUT 6 im_range */
    plhs[6] = mxCreateDoubleMatrix(L_im,S_im,mxREAL);
    im_range = set_mxDoubleMatrix(plhs[6]);
    
    /* OUTPUT 7/8 im_nn x/y */
    plhs[7] = mxCreateNumericMatrix(L_im,S_im,mxINT32_CLASS,mxREAL);
    im_nnx = set_mxInt32Matrix(plhs[7]);
    
    plhs[8] = mxCreateNumericMatrix(L_im,S_im,mxINT32_CLASS,mxREAL);
    im_nny = set_mxInt32Matrix(plhs[8]);
    
//     /* OUTPUT 9 emission angle */
//     plhs[9] = mxCreateDoubleMatrix(L_im,S_im,mxREAL);
//     im_cosemi = set_mxDoubleMatrix(plhs[9]);
//     
//     /* OUTPUT 10/11/12 surface plane normal vectors */
//     plhs[10] = mxCreateDoubleMatrix(L_im,S_im,mxREAL);
//     im_pnx = set_mxDoubleMatrix(plhs[10]);
//     plhs[11] = mxCreateDoubleMatrix(L_im,S_im,mxREAL);
//     im_pny = set_mxDoubleMatrix(plhs[11]);
//     plhs[12] = mxCreateDoubleMatrix(L_im,S_im,mxREAL);
//     im_pnz = set_mxDoubleMatrix(plhs[12]);
//     
//     /* OUTPUT 13/14/15 surface plane normal vectors */
//     plhs[13] = mxCreateDoubleMatrix(L_im,S_im,mxREAL);
//     im_pc = set_mxDoubleMatrix(plhs[13]);
    
    // Initialize matrices
    for(si=0;si<S_im;si++){
        for(li=0;li<L_im;li++){
            im_xiaumars[si][li] = NAN;
            im_yiaumars[si][li] = NAN;
            im_ziaumars[si][li] = NAN;
            im_range[si][li] = INFINITY;
            im_refx[si][li] = -1;
            im_refy[si][li] = -1;
            im_refs[si][li] = -1;
            im_nnx[si][li] = -1;
            im_nny[si][li] = -1;
            // im_cosemi[si][li] = NAN;
            // im_pnx[si][li] = NAN;
            // im_pny[si][li] = NAN;
            // im_pnz[si][li] = NAN;
            // im_pc[si][li] = NAN; 
        }
    }
    
    /* -----------------------------------------------------------------
     * CALL MAIN COMPUTATION ROUTINE
     * ----------------------------------------------------------------- */
    proj_mastcam2MSLDEM(msldem_imgpath, msldem_header, 
       (int32_T) msldemc_sample_offset, (int32_T) msldemc_line_offset,
       (int32_T) msldemc_samples, (int32_T) msldemc_lines,
       msldemc_latitude, msldemc_longitude, mslrad_offset,
       msldemc_imFOVmask,lList_lofst,lList_lines,lList_cofst,lList_cols,
       (int32_T) S_im, (int32_T) L_im, cahv_mdl,
       PmCx,PmCy,PmCz, im_xiaumars, im_yiaumars, im_ziaumars,
       im_refx, im_refy, im_refs,
       im_range, im_nnx, im_nny);
       //im_cosemi,im_pnx,im_pny,im_pnz,im_pc);
    
    /* free memories */
    mxFree(msldem_imgpath);
    mxFree(msldemc_imFOVmask);
    mxFree(PmCx);
    mxFree(PmCy);
    mxFree(PmCz);
    mxFree(im_xiaumars);
    mxFree(im_yiaumars);
    mxFree(im_ziaumars);
    mxFree(im_refx);
    mxFree(im_refy);
    mxFree(im_refs);
    mxFree(im_range);
    mxFree(im_nnx);
    mxFree(im_nny);
//     mxFree(im_cosemi);
//     mxFree(im_pnx);
//     mxFree(im_pny);
//     mxFree(im_pnz);
//     mxFree(im_pc);
    
}
