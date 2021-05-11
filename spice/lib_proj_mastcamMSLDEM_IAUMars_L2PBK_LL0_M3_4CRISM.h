/* =====================================================================
 * lib_proj_mastcamMSLDEM_IAUMars_L2PBK_LL0_M3_4CRISM.h 
 * L2  : msldemc will be read from a file not an input.
 * PBK : Prior Binning into bins with the auxiliary size defined by two parameters K_L and K_S
 * LL0 : Linked List with least basic information (c,l,radius), this is most memory efficient
 * M3  : 3x3 matrix inversion object image coordinate.
 *
 *
 * Two functions are included
 * mask_obstructed_pts_in_msldemt_using_msldemc_iaumars_L2PBK_LL0DYU_M3_4CRISM
 * mask_obstructed_pts_in_msldemt_using_msldemc_iaumars_L2PBK_LL0_M3_4CRISM
 * 
 * DYU : DYnamic Update of Linked List by removing invisible points at the time it is labelled.
 *
 * ===================================================================== */


#ifndef LIB_PROJ_MASTCAMMSLDEM_IAUMARS_L2PBK_LL0_M3_4CRISM_H
#define LIB_PROJ_MASTCAMMSLDEM_IAUMARS_L2PBK_LL0_M3_4CRISM_H

#include <stdint.h>
#include "io64.h"
#include "math.h"
#include "matrix.h"
#include <string.h>
#include <stdio.h>

#include <stdlib.h>
#include "envi.h"
#include "cahvor.h"
#include "mex_create_array.h"

struct MSLDEMmask_LinkedList{
    int32_t c;
    int32_t l;
    double radius;
    struct MSLDEMmask_LinkedList *next;
    struct MSLDEMmask_LinkedList *prev;
};

void createMSLDEMmask_LLMatrix(struct MSLDEMmask_LinkedList ****ar2d, 
        struct MSLDEMmask_LinkedList ***ar_base, size_t N, size_t M)
{
    size_t ni;
    
    *ar2d = (struct MSLDEMmask_LinkedList***) malloc(sizeof(struct MSLDEMmask_LinkedList**) * N);
    *ar_base = (struct MSLDEMmask_LinkedList**) malloc(sizeof(struct MSLDEMmask_LinkedList*) * N * M);
    (*ar2d)[0] = &(*ar_base)[0];
    for(ni=1;ni<N;ni++){
        (*ar2d)[ni] = (*ar2d)[ni-1] + M;
    }
}

/* main computation routine */
void mask_obstructed_pts_in_msldemt_using_msldemc_iaumars_L2PBK_LL0DYU_M3_4CRISM(
        char *msldem_imgpath, EnviHeader msldem_header, double mslrad_offset,
        int32_T msldemc_imxy_sample_offset, int32_T msldemc_imxy_line_offset,
        int32_T msldemc_samples, int32_T msldemc_lines,
        double *msldemc_latitude, double *msldemc_longitude, int8_T **msldemc_imFOVmask,
        int32_T msldemt_samples, int32_T msldemt_lines,
        double *msldemt_latitude, double *msldemt_longitude, int8_T **msldemt_inImage,
        double K_L, double K_S,
        struct MSLDEMmask_LinkedList ***ll_papmc_bin,
        struct MSLDEMmask_LinkedList *ll_napmc,
        double S_im, double L_im, CAHV_MODEL cahv_mdl,
        int32_t *lList_exist, int32_t **lList_crange)
{
    int32_T c,l,cc,ll;
    int32_t l0,lend,s0,send;
    int32_T cv1,cv2,cv3,lv1,lv2,lv3; /* v indicates vertex */
    int32_T L_demcm1,S_demcm1;
    int16_T ti; /* triangle index */
    long skip_pri;
    long skip_l, skip_r;
    float *elevl,*elevlp1;
    long ncpy;
    const int sz=sizeof(float);
    FILE *fid;
    double ppv1x,ppv1y,ppv2x,ppv2y,ppv3x,ppv3y; /* Plane Position Vectors */
    double ppv1gx,ppv1gy,ppv1gz,ppv2gx,ppv2gy,ppv2gz,ppv3gx,ppv3gy,ppv3gz;
    //double pdv1x,pdv1y,pdv2x,pdv2y;
    //double pdv1gx,pdv1gy,pdv1gz,pdv2gx,pdv2gy,pdv2gz;
    double pmcv1x,pmcv1y,pmcv1z;
    double pmcv2x,pmcv2y,pmcv2z;
    double pmcv3x,pmcv3y,pmcv3z;
    double detM;
    //double M[2][2];
    double Minv[3][3];
    //double Minvp[2][3];
    double x_min,y_min,x_max,y_max;
    //double pipvx,pipvy;
    //double pipvgx,pipvgy,pipvgz;
    //double pdv1z,pdv2z;
    //double pprm_sd,pprm_td,pprm_1std; /* plane parameter for projected image plane */
    //double pipvgppv1x,pipvgppv1y,pipvgppv1z;
    //double pprm_s,pprm_t,pprm_1st;
    double pprm_s,pprm_t,pprm_u;
    bool isinFOVd,isinFOV;
    
    //double pnx,pny,pnz; /* Plane Normal vectors */
    //double lprm_nume;
    //double lprm; /* line parameters */
    
    int32_T xi,yi;
    int32_T x_min_int,x_max_int,y_min_int,y_max_int;
    int32_T n;
    int32_t binL,binS;
    int32_t binLm1,binSm1;
    
    double apmc,pmcx,pmcy,pmcz;
    double ppvgx,ppvgy,ppvgz,ppvx,ppvy;
    double *cam_C,*cam_A,*cam_H,*cam_V;
    
    double *cos_clon, *sin_clon, *cos_tlon, *sin_tlon;
    double *cos_tlat, *sin_tlat;
    double radius_tmp;
    double cos_clatl, sin_clatl, cos_clatlp1, sin_clatlp1, cos_tlatl, sin_tlatl;
    double x_iaumars, y_iaumars, z_iaumars;
    
    struct MSLDEMmask_LinkedList *ll_papmc_next;
    struct MSLDEMmask_LinkedList *ll_napmc_next;
    struct MSLDEMmask_LinkedList *ll_tmp;
    
    cos_clon = (double*) malloc(sizeof(double) * (size_t) msldemc_samples);
    sin_clon = (double*) malloc(sizeof(double) * (size_t) msldemc_samples);
    for(c=0;c<msldemc_samples;c++){
        cos_clon[c] = cos(msldemc_longitude[c]);
        sin_clon[c] = sin(msldemc_longitude[c]);
    }
    
    if(msldemt_latitude==NULL){
        msldemt_latitude = msldemc_latitude;
    }
    if(msldemt_longitude==NULL){
        msldemt_longitude = msldemc_longitude;
        cos_tlon = cos_clon; sin_tlon = sin_clon;
    } else {
        cos_tlon = (double*) malloc(sizeof(double) * (size_t) msldemt_samples);
        sin_tlon = (double*) malloc(sizeof(double) * (size_t) msldemt_samples);
        for(c=0;c<msldemt_samples;c++){
            cos_tlon[c] = cos(msldemt_longitude[c]);
            sin_tlon[c] = sin(msldemt_longitude[c]);
        }
    }
    
    cos_tlat = (double*) malloc(sizeof(double) * (size_t) msldemt_lines);
    sin_tlat = (double*) malloc(sizeof(double) * (size_t) msldemt_lines);
    for(l=0;l<msldemt_lines;l++){
        cos_tlat[l] = cos(msldemt_latitude[l]);
        sin_tlat[l] = sin(msldemt_latitude[l]);
    }
    
    cam_C = cahv_mdl.C; cam_A = cahv_mdl.A; cam_H = cahv_mdl.H; cam_V = cahv_mdl.V;
    
    L_demcm1 = msldemc_lines-1;
    S_demcm1 = msldemc_samples-1;
    // S_imm1 = S_im - 1;
    // L_imm1 = L_im - 1;
    binL = (int32_t) (K_L * L_im); binS = (int32_t) (K_S * S_im);
    binLm1 = binL-1; binSm1 = binS-1;
    
    /*********************************************************************/
    
    
    /*********************************************************************/
    /*** Pre-binning of the msldem pixels ********************************/
    /* create an bin image counting the number of demc pixels that falls
     * within the 
     */
    /* Dynamic memory allocations */
    
    
    
    
    /* Main Loop *********************************************************/
    
//     find_hidden_main_loop(msldemc_samples, msldemc_lines, msldemc_imFOVmask,
//         msldemc_northing, msldemc_easting, msldemc_img,
//         cam_A, cam_H, cam_V,
//         S_im, L_im, bin_count_im, bin_im_c, bin_im_l, bin_imx, bin_imy,
//         msldemc_northing, msldemc_easting, msldemc_img, msldemc_inImage);
    l0 = lList_exist[0]; lend = lList_exist[1];
    fid = fopen(msldem_imgpath,"rb");
    
    /* skip lines */
    skip_pri = (long) msldem_header.samples * (long) (msldemc_imxy_line_offset+l0) * (long) sz;
    // printf("%d*%d*%d=%ld\n",msldem_header.samples,msldemc_imxy_line_offset,s,skip_pri);
    fseek(fid,skip_pri,SEEK_CUR);
    
    elevl = (float*) malloc(sz*msldemc_samples);
    elevlp1 = (float*) malloc(sz*msldemc_samples);
    skip_l = (long) sz * (long) msldemc_imxy_sample_offset;
    skip_r = ((long) msldem_header.samples - (long) msldemc_samples)* (long) sz - skip_l;
    ncpy = (long) msldemc_samples* (long)sz;
    fseek(fid,skip_l,SEEK_CUR);
    fread(elevlp1,sz,msldemc_samples,fid);
    fseek(fid,skip_r,SEEK_CUR);
    
    
    for(l=l0;l<lend;l++){
        memcpy(elevl,elevlp1,ncpy);
        fseek(fid,skip_l,SEEK_CUR);
        fread(elevlp1,sz,msldemc_samples,fid);
        fseek(fid,skip_r,SEEK_CUR);
        // decide the first and last indexes to be assessed.
        cos_clatl   = cos(msldemc_latitude[l]);
        sin_clatl   = sin(msldemc_latitude[l]);
        cos_clatlp1 = cos(msldemc_latitude[l+1]);
        sin_clatlp1 = sin(msldemc_latitude[l+1]);
        // printf("l=%d/%d\n",l,L_demcm1);
        s0 = lList_crange[l][0]-1; send = lList_crange[l][1]+1;
        if(s0<0){s0 = 0;}
        if(send>msldemc_samples){send=msldemc_samples;}
        for(c=s0;c<send;c++){
            // process if 
            //printf("c=%d,mask_lc = %d,mask_lp1c = %d\n",c,msldemc_imFOVmask[c][l],msldemc_imFOVmask[c][l+1]);
            if((msldemc_imFOVmask[c][l]>0) || (msldemc_imFOVmask[c][l+1]>0)){
                //printf("c=%d\n",c);
                for(ti=0;ti<2;ti++){
                    if(ti==0){
                        radius_tmp = (double) elevl[c] + mslrad_offset;
                        ppv1gx = radius_tmp * cos_clatl * cos_clon[c];
                        ppv1gy = radius_tmp * cos_clatl * sin_clon[c];
                        ppv1gz = radius_tmp * sin_clatl;
                        radius_tmp = (double) elevl[c+1] + mslrad_offset;
                        ppv2gx = radius_tmp * cos_clatl * cos_clon[c+1];
                        ppv2gy = radius_tmp * cos_clatl * sin_clon[c+1];
                        ppv2gz = radius_tmp * sin_clatl;
                        radius_tmp = (double) elevlp1[c] + mslrad_offset;
                        ppv3gx = radius_tmp * cos_clatlp1 * cos_clon[c];
                        ppv3gy = radius_tmp * cos_clatlp1 * sin_clon[c];
                        ppv3gz = radius_tmp * sin_clatlp1;
//                         ppv1gx = msldemc_xmc[l];
//                         ppv1gy = msldemc_ymc[c];
//                         ppv1gz = ((double) -elevl[c]) - cam_C[2];
//                         ppv2gx = msldemc_xmc[l];
//                         ppv2gy = msldemc_ymc[c+1];
//                         ppv2gz = ((double) -elevl[c+1]) - cam_C[2];
//                         ppv3gx = msldemc_xmc[l+1];
//                         ppv3gy = msldemc_ymc[c];
//                         ppv3gz = ((double) -elevlp1[c]) - cam_C[2];
                        isinFOVd = ((msldemc_imFOVmask[c][l]>1) && (msldemc_imFOVmask[c+1][l]>1) && (msldemc_imFOVmask[c][l+1]>1));
                        isinFOV = ((msldemc_imFOVmask[c][l]>0) && (msldemc_imFOVmask[c+1][l]>0) && (msldemc_imFOVmask[c][l+1]>0));
                        cv1 = c;   lv1 = l;
                        cv2 = c+1; lv2 = l;
                        cv3 = c;   lv3 = l+1;
                        // cv4 = c+1; lv4 = l+1;
                    }
                    else{
                        radius_tmp = (double) elevl[c+1] + mslrad_offset;
                        ppv1gx = radius_tmp * cos_clatl * cos_clon[c+1];
                        ppv1gy = radius_tmp * cos_clatl * sin_clon[c+1];
                        ppv1gz = radius_tmp * sin_clatl;
                        radius_tmp = (double) elevlp1[c+1] + mslrad_offset;
                        ppv2gx = radius_tmp * cos_clatlp1 * cos_clon[c+1];
                        ppv2gy = radius_tmp * cos_clatlp1 * sin_clon[c+1];
                        ppv2gz = radius_tmp * sin_clatlp1;
                        radius_tmp = (double) elevlp1[c] + mslrad_offset;
                        ppv3gx = radius_tmp * cos_clatlp1 * cos_clon[c];
                        ppv3gy = radius_tmp * cos_clatlp1 * sin_clon[c];
                        ppv3gz = radius_tmp * sin_clatlp1;
//                         ppv1gx = msldemc_xmc[l];
//                         ppv1gy = msldemc_ymc[c+1];
//                         ppv1gz = ((double) -elevl[c+1]) - cam_C[2];
//                         ppv2gx = msldemc_xmc[l+1];
//                         ppv2gy = msldemc_ymc[c+1];
//                         ppv2gz = ((double) -elevlp1[c+1]) - cam_C[2];
//                         ppv3gx = msldemc_xmc[l+1];
//                         ppv3gy = msldemc_ymc[c];
//                         ppv3gz = ((double) -elevlp1[c]) - cam_C[2];
                        cv1 = c+1; lv1 = l;
                        cv2 = c+1; lv2 = l+1;
                        cv3 = c;   lv3 = l+1;
                        // cv4 = c;   lv4 = l;
                        isinFOVd = ((msldemc_imFOVmask[c+1][l]>1) && (msldemc_imFOVmask[c+1][l+1]>1) && (msldemc_imFOVmask[c][l+1]>1));
                        isinFOV = ((msldemc_imFOVmask[c+1][l]>0) && (msldemc_imFOVmask[c+1][l+1]>0) && (msldemc_imFOVmask[c][l+1]>0));
                    }
                    
                    if(isinFOVd){
                        /* Evaluate the projection */
                        // pmcx = ppv1gx; pmcy = ppv1gy; pmcz = ppv1gz;
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

                        // define some plane parameters
                        //pdv1x = ppv2x - ppv1x; pdv1y = ppv2y - ppv1y;
                        //pdv2x = ppv3x - ppv1x; pdv2y = ppv3y - ppv1y;
                        //detM = pdv1x*pdv2y - pdv1y*pdv2x;
                        //Minv[0][0] = pdv2y/detM;
                        //Minv[0][1] = -pdv2x/detM;
                        //Minv[1][0] = -pdv1y/detM;
                        //Minv[1][1] = pdv1x/detM;
                        
                        // pdv1gx = ppv2gx - ppv1gx;
                        // pdv1gy = ppv2gy - ppv1gy;
                        // pdv1gz = ppv2gz - ppv1gz;
                        // pdv2gx = ppv3gx - ppv1gx;
                        // pdv2gy = ppv3gy - ppv1gy;
                        // pdv2gz = ppv3gz - ppv1gz;
                        /* parameters for plane equations
                         * plane normal vector (pn)
                         * plane constant (pc)
                        */
                        // pnx = pdv1gy*pdv2gz - pdv1gz*pdv2gy;
                        // pny = pdv1gz*pdv2gx - pdv1gx*pdv2gz;
                        // pnz = pdv1gx*pdv2gy - pdv1gy*pdv2gx;
                        // lprm_nume = pnx*(ppv1gx-cam_C[0])+pny*(ppv1gy-cam_C[1])+pnz*(ppv1gz-cam_C[2]);
                        
                        /* for pre-screening */
                        x_min = fmin(fmin(ppv1x,ppv2x),ppv3x);
                        y_min = fmin(fmin(ppv1y,ppv2y),ppv3y);
                        x_max = fmax(fmax(ppv1x,ppv2x),ppv3x);
                        y_max = fmax(fmax(ppv1y,ppv2y),ppv3y);
                        
                        x_min_int = (int32_T) floor(K_S*(x_min+0.5));
                        y_min_int = (int32_T) floor(K_L*(y_min+0.5));
                        x_max_int = (int32_T) floor(K_S*(x_max+0.5)+1.0);
                        y_max_int = (int32_T) floor(K_L*(y_max+0.5)+1.0);
                        
                        if(x_min_int<0){
                            x_min_int=0;   
                        }else if(x_min_int>binSm1){
                            x_min_int=binSm1;
                        }
                        if(x_max_int<1){
                            x_max_int=1;
                        }else if(x_max_int>binS){
                            x_max_int=binS;
                        }
                        
                        if(y_min_int<0){
                            y_min_int=0;
                        }else if(y_min_int>binLm1){
                            y_min_int=binLm1;
                        }
                        if(y_max_int<1){
                            y_max_int=1;
                        }else if(y_max_int>binL){
                            y_max_int=binL;
                        }
                        for(xi=x_min_int;xi<x_max_int;xi++){
                            for(yi=y_min_int;yi<y_max_int;yi++){
                                ll_papmc_next = ll_papmc_bin[xi][yi];
                                // ll=2147483647;
                                while(ll_papmc_next!=NULL){
                                    cc = ll_papmc_next->c;
                                    ll = ll_papmc_next->l;
                                    radius_tmp = ll_papmc_next->radius;
                                    /* evaluate line param */
                                    x_iaumars  = radius_tmp * cos_tlat[ll] * cos_tlon[cc];
                                    y_iaumars  = radius_tmp * cos_tlat[ll] * sin_tlon[cc];
                                    z_iaumars  = radius_tmp * sin_tlat[ll];
                                    pmcx = x_iaumars - cam_C[0];
                                    pmcy = y_iaumars - cam_C[1];
                                    pmcz = z_iaumars - cam_C[2];
                                    pprm_s = Minv[0][0]*pmcx+Minv[0][1]*pmcy+Minv[0][2]*pmcz;
                                    if(pprm_s>0){
                                        pprm_t = Minv[1][0]*pmcx+Minv[1][1]*pmcy+Minv[1][2]*pmcz;
                                        if(pprm_t>0){
                                            pprm_u = Minv[2][0]*pmcx+Minv[2][1]*pmcy+Minv[2][2]*pmcz;
                                            if( (pprm_u>0) && (pprm_s+pprm_t+pprm_u>1) ){
                                                if((cc==cv1 && ll==lv1) || (cc==cv2 && ll==lv2) || (cc==cv3 && ll==lv3)){
                                                    ll_papmc_next = ll_papmc_next->next;
                                                } else {
                                                    msldemt_inImage[cc][ll] = 0;
                                                    if(ll_papmc_next->next!=NULL){
                                                        ll_papmc_next->next->prev = ll_papmc_next->prev;
                                                    }
                                                    if(ll_papmc_next->prev!=NULL){
                                                        ll_papmc_next->prev->next = ll_papmc_next->next;
                                                    } else {
                                                        ll_papmc_bin[xi][yi] = ll_papmc_next->next;
                                                    }
                                                    ll_tmp = ll_papmc_next;
                                                    ll_papmc_next = ll_papmc_next->next;
                                                    free(ll_tmp);
                                                }
                                            } else {
                                                ll_papmc_next = ll_papmc_next->next;
                                            }
                                        } else {
                                            ll_papmc_next = ll_papmc_next->next;
                                        }
                                    } else {
                                        ll_papmc_next = ll_papmc_next->next;
                                    }
                                }
                            }
                        }
                    } else if(isinFOV){
//                         pdv1x = ppv2gx - ppv1gx;
//                         pdv1y = ppv2gy - ppv1gy;
//                         pdv1z = ppv2gz - ppv1gz;
//                         pdv2x = ppv3gx - ppv1gx;
//                         pdv2y = ppv3gy - ppv1gy;
//                         pdv2z = ppv3gz - ppv1gz;
//                         pnx = pdv1y*pdv2z - pdv1z*pdv2y;
//                         pny = pdv1z*pdv2x - pdv1x*pdv2z;
//                         pnz = pdv1x*pdv2y - pdv1y*pdv2x;
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
                        
                        /* parameters for plane equations
                         * plane normal vector (pn)
                         * plane constant (pc)
                        */
                        //pnx = pdv1gy*pdv2gz - pdv1gz*pdv2gy;
                        //pny = pdv1gz*pdv2gx - pdv1gx*pdv2gz;
                        //pnz = pdv1gx*pdv2gy - pdv1gy*pdv2gx;
                        //lprm_nume = pnx*(ppv1gx-cam_C[0])+pny*(ppv1gy-cam_C[1])+pnz*(ppv1gz-cam_C[2]);
                        
//                         for(xi=0;xi<binS;xi++){
//                             for(yi=0;yi<binL;yi++){
//                                 for (n=0;n<bin_count_im[xi][yi];n++){
//                                     cc = bin_im_c[xi][yi][n];
//                                     ll = bin_im_l[xi][yi][n];
//                                     /* evaluate line param */
//                                     radius_tmp = bin_rad[xi][yi][n];
//                                     x_iaumars  = radius_tmp * cos_tlat[ll] * cos_tlon[cc];
//                                     y_iaumars  = radius_tmp * cos_tlat[ll] * sin_tlon[cc];
//                                     z_iaumars  = radius_tmp * sin_tlat[ll];
//                                     pmcx = x_iaumars - cam_C[0];
//                                     pmcy = y_iaumars - cam_C[1];
//                                     pmcz = z_iaumars - cam_C[2];
//                                     //lprm = lprm_nume/(pnx*pmcx+pny*pmcy+pnz*pmcz);
//                                     // if(lprm<1 && lprm>0){
//                                         /* evaluate the test vector is inside the triangle. */
//                                         //pipvgppv1x = lprm*pmcx - ppv1gx;
//                                         //pipvgppv1y = lprm*pmcy - ppv1gy;
//                                         //pipvgppv1z = lprm*pmcz - ppv1gy;
//                                         //pprm_s = Minvp[0][0]*pipvgppv1x+Minvp[0][1]*pipvgppv1y+Minvp[0][2]*pipvgppv1z;
//                                         //pprm_t = Minvp[1][0]*pipvgppv1x+Minvp[1][1]*pipvgppv1y+Minvp[1][2]*pipvgppv1z;
//                                         //pprm_1st = 1 - pprm_s - pprm_t;
//                                         //if(pprm_s>0 && pprm_t>0 && pprm_1st>0){
//                                         //    if((cc==cv1 && ll==lv1) || (cc==cv2 && ll==lv2) || (cc==cv3 && ll==lv3)){
//                                         //    } else {
//                                         //    msldemt_inImage[cc][ll] = 0;
//                                         //    }
//                                         //}
//                                     //}
//                                 }
//                             }
//                         }
                        
                        /* test vectors with napmc<0 */
//                         if(count_napmc>0){
//                             for(n=0;n<count_napmc;n++){
//                                 cc = c_napmc[n]; ll = l_napmc[n];
//                                 radius_tmp = rad_napmc[n];
//                                 x_iaumars  = radius_tmp * cos_tlat[ll] * cos_tlon[cc];
//                                 y_iaumars  = radius_tmp * cos_tlat[ll] * sin_tlon[cc];
//                                 z_iaumars  = radius_tmp * sin_tlat[ll];
//                                 pmcx = x_iaumars - cam_C[0];
//                                 pmcy = y_iaumars - cam_C[1];
//                                 pmcz = z_iaumars - cam_C[2];
//                                 //lprm = lprm_nume/(pnx*pmcx+pny*pmcy+pnz*pmcz);
//                                 //if(lprm<1 && lprm>0){
//                                     /* evaluate the test vector is inside the triangle. */
//                                     //pipvgppv1x = lprm*pmcx - ppv1gx;
//                                     //pipvgppv1y = lprm*pmcy - ppv1gy;
//                                     //pipvgppv1z = lprm*pmcz - ppv1gy;
//                                     //pprm_s = Minvp[0][0]*pipvgppv1x+Minvp[0][1]*pipvgppv1y+Minvp[0][2]*pipvgppv1z;
//                                     //pprm_t = Minvp[1][0]*pipvgppv1x+Minvp[1][1]*pipvgppv1y+Minvp[1][2]*pipvgppv1z;
//                                     //pprm_1st = 1 - pprm_s - pprm_t;
//                                     //if(pprm_s>0 && pprm_t>0 && pprm_1st>0){
//                                     //    if((cc==cv1 && ll==lv1) || (cc==cv2 && ll==lv2) || (cc==cv3 && ll==lv3)){
//                                     //    } else {
//                                     //    msldemt_inImage[cc][ll] = 0;
//                                     //    }
//                                     //}
//                                 //}
//                             }
//                         }
                        
                    }
                }
            }
        }
    }
    

    
    /* free dynamically allocated memories */
    free(cos_clon);
    free(sin_clon);
    if(cos_tlon)
        free(cos_tlon);
    if(sin_tlon)
        free(sin_tlon);
    free(cos_tlat);
    free(sin_tlat);
    free(elevl);
    free(elevlp1);
    fclose(fid);
    
}

/* without dynamic update version */
void mask_obstructed_pts_in_msldemt_using_msldemc_iaumars_L2PBK_LL0_M3(
        char *msldem_imgpath, EnviHeader msldem_header, double mslrad_offset,
        int32_T msldemc_imxy_sample_offset, int32_T msldemc_imxy_line_offset,
        int32_T msldemc_samples, int32_T msldemc_lines,
        double *msldemc_latitude, double *msldemc_longitude, int8_T **msldemc_imFOVmask,
        int32_T msldemt_samples, int32_T msldemt_lines,
        double *msldemt_latitude, double *msldemt_longitude, int8_T **msldemt_inImage,
        double K_L, double K_S,
        struct MSLDEMmask_LinkedList ***ll_papmc_bin,
        struct MSLDEMmask_LinkedList *ll_napmc,
        double S_im, double L_im, CAHV_MODEL cahv_mdl)
{
    int32_T c,l,cc,ll;
    int32_T cv1,cv2,cv3,lv1,lv2,lv3; /* v indicates vertex */
    int32_T L_demcm1,S_demcm1;
    int16_T ti; /* triangle index */
    long skip_pri;
    long skip_l, skip_r;
    float *elevl,*elevlp1;
    long ncpy;
    const int sz=sizeof(float);
    FILE *fid;
    double ppv1x,ppv1y,ppv2x,ppv2y,ppv3x,ppv3y; /* Plane Position Vectors */
    double ppv1gx,ppv1gy,ppv1gz,ppv2gx,ppv2gy,ppv2gz,ppv3gx,ppv3gy,ppv3gz;
    //double pdv1x,pdv1y,pdv2x,pdv2y;
    //double pdv1gx,pdv1gy,pdv1gz,pdv2gx,pdv2gy,pdv2gz;
    double pmcv1x,pmcv1y,pmcv1z;
    double pmcv2x,pmcv2y,pmcv2z;
    double pmcv3x,pmcv3y,pmcv3z;
    double detM;
    //double M[2][2];
    double Minv[3][3];
    //double Minvp[2][3];
    double x_min,y_min,x_max,y_max;
    //double pipvx,pipvy;
    //double pipvgx,pipvgy,pipvgz;
    //double pdv1z,pdv2z;
    //double pprm_sd,pprm_td,pprm_1std; /* plane parameter for projected image plane */
    //double pipvgppv1x,pipvgppv1y,pipvgppv1z;
    //double pprm_s,pprm_t,pprm_1st;
    double pprm_s,pprm_t,pprm_u;
    bool isinFOVd,isinFOV;
    
    //double pnx,pny,pnz; /* Plane Normal vectors */
    //double lprm_nume;
    //double lprm; /* line parameters */
    
    int32_T xi,yi;
    int32_T x_min_int,x_max_int,y_min_int,y_max_int;
    int32_T n;
    int32_t binL,binS;
    int32_t binLm1,binSm1;
    
    double apmc,pmcx,pmcy,pmcz;
    double ppvgx,ppvgy,ppvgz,ppvx,ppvy;
    double *cam_C,*cam_A,*cam_H,*cam_V;
    
    double *cos_clon, *sin_clon, *cos_tlon, *sin_tlon;
    double *cos_tlat, *sin_tlat;
    double radius_tmp;
    double cos_clatl, sin_clatl, cos_clatlp1, sin_clatlp1, cos_tlatl, sin_tlatl;
    double x_iaumars, y_iaumars, z_iaumars;
    
    struct MSLDEMmask_LinkedList *ll_papmc_next;
    struct MSLDEMmask_LinkedList *ll_napmc_next;
    struct MSLDEMmask_LinkedList *ll_tmp;
    
    cos_clon = (double*) malloc(sizeof(double) * (size_t) msldemc_samples);
    sin_clon = (double*) malloc(sizeof(double) * (size_t) msldemc_samples);
    for(c=0;c<msldemc_samples;c++){
        cos_clon[c] = cos(msldemc_longitude[c]);
        sin_clon[c] = sin(msldemc_longitude[c]);
    }
    
    if(msldemt_latitude==NULL){
        msldemt_latitude = msldemc_latitude;
    }
    if(msldemt_longitude==NULL){
        msldemt_longitude = msldemc_longitude;
        cos_tlon = cos_clon; sin_tlon = sin_clon;
    } else {
        cos_tlon = (double*) malloc(sizeof(double) * (size_t) msldemt_samples);
        sin_tlon = (double*) malloc(sizeof(double) * (size_t) msldemt_samples);
        for(c=0;c<msldemt_samples;c++){
            cos_tlon[c] = cos(msldemt_longitude[c]);
            sin_tlon[c] = sin(msldemt_longitude[c]);
        }
    }
    
    cos_tlat = (double*) malloc(sizeof(double) * (size_t) msldemt_lines);
    sin_tlat = (double*) malloc(sizeof(double) * (size_t) msldemt_lines);
    for(l=0;l<msldemt_lines;l++){
        cos_tlat[l] = cos(msldemt_latitude[l]);
        sin_tlat[l] = sin(msldemt_latitude[l]);
    }
    
    cam_C = cahv_mdl.C; cam_A = cahv_mdl.A; cam_H = cahv_mdl.H; cam_V = cahv_mdl.V;
    
    L_demcm1 = msldemc_lines-1;
    S_demcm1 = msldemc_samples-1;
    // S_imm1 = S_im - 1;
    // L_imm1 = L_im - 1;
    binL = (int32_t) (K_L * L_im); binS = (int32_t) (K_S * S_im);
    binLm1 = binL-1; binSm1 = binS-1;
    
    /*********************************************************************/
    
    
    /*********************************************************************/
    /*** Pre-binning of the msldem pixels ********************************/
    /* create an bin image counting the number of demc pixels that falls
     * within the 
     */
    /* Dynamic memory allocations */
    
    
    
    
    /* Main Loop *********************************************************/
    
//     find_hidden_main_loop(msldemc_samples, msldemc_lines, msldemc_imFOVmask,
//         msldemc_northing, msldemc_easting, msldemc_img,
//         cam_A, cam_H, cam_V,
//         S_im, L_im, bin_count_im, bin_im_c, bin_im_l, bin_imx, bin_imy,
//         msldemc_northing, msldemc_easting, msldemc_img, msldemc_inImage);
    
    fid = fopen(msldem_imgpath,"rb");
    
    /* skip lines */
    skip_pri = (long) msldem_header.samples * (long) msldemc_imxy_line_offset * (long) sz;
    // printf("%d*%d*%d=%ld\n",msldem_header.samples,msldemc_imxy_line_offset,s,skip_pri);
    fseek(fid,skip_pri,SEEK_CUR);
    
    elevl = (float*) malloc(sz*msldemc_samples);
    elevlp1 = (float*) malloc(sz*msldemc_samples);
    skip_l = (long) sz * (long) msldemc_imxy_sample_offset;
    skip_r = ((long) msldem_header.samples - (long) msldemc_samples)* (long) sz - skip_l;
    ncpy = (long) msldemc_samples* (long)sz;
    fseek(fid,skip_l,SEEK_CUR);
    fread(elevlp1,sz,msldemc_samples,fid);
    fseek(fid,skip_r,SEEK_CUR);
    
    
    for(l=0;l<L_demcm1;l++){
        memcpy(elevl,elevlp1,ncpy);
        fseek(fid,skip_l,SEEK_CUR);
        fread(elevlp1,sz,msldemc_samples,fid);
        fseek(fid,skip_r,SEEK_CUR);
        // decide the first and last indexes to be assessed.
        cos_clatl   = cos(msldemc_latitude[l]);
        sin_clatl   = sin(msldemc_latitude[l]);
        cos_clatlp1 = cos(msldemc_latitude[l+1]);
        sin_clatlp1 = sin(msldemc_latitude[l+1]);
        // printf("l=%d/%d\n",l,L_demcm1);
        for(c=0;c<S_demcm1;c++){
            // process if 
            //printf("c=%d,mask_lc = %d,mask_lp1c = %d\n",c,msldemc_imFOVmask[c][l],msldemc_imFOVmask[c][l+1]);
            if((msldemc_imFOVmask[c][l]>0) || (msldemc_imFOVmask[c][l+1]>0)){
                //printf("c=%d\n",c);
                for(ti=0;ti<2;ti++){
                    if(ti==0){
                        radius_tmp = (double) elevl[c] + mslrad_offset;
                        ppv1gx = radius_tmp * cos_clatl * cos_clon[c];
                        ppv1gy = radius_tmp * cos_clatl * sin_clon[c];
                        ppv1gz = radius_tmp * sin_clatl;
                        radius_tmp = (double) elevl[c+1] + mslrad_offset;
                        ppv2gx = radius_tmp * cos_clatl * cos_clon[c+1];
                        ppv2gy = radius_tmp * cos_clatl * sin_clon[c+1];
                        ppv2gz = radius_tmp * sin_clatl;
                        radius_tmp = (double) elevlp1[c] + mslrad_offset;
                        ppv3gx = radius_tmp * cos_clatlp1 * cos_clon[c];
                        ppv3gy = radius_tmp * cos_clatlp1 * sin_clon[c];
                        ppv3gz = radius_tmp * sin_clatlp1;
//                         ppv1gx = msldemc_xmc[l];
//                         ppv1gy = msldemc_ymc[c];
//                         ppv1gz = ((double) -elevl[c]) - cam_C[2];
//                         ppv2gx = msldemc_xmc[l];
//                         ppv2gy = msldemc_ymc[c+1];
//                         ppv2gz = ((double) -elevl[c+1]) - cam_C[2];
//                         ppv3gx = msldemc_xmc[l+1];
//                         ppv3gy = msldemc_ymc[c];
//                         ppv3gz = ((double) -elevlp1[c]) - cam_C[2];
                        isinFOVd = ((msldemc_imFOVmask[c][l]>1) && (msldemc_imFOVmask[c+1][l]>1) && (msldemc_imFOVmask[c][l+1]>1));
                        isinFOV = ((msldemc_imFOVmask[c][l]>0) && (msldemc_imFOVmask[c+1][l]>0) && (msldemc_imFOVmask[c][l+1]>0));
                        cv1 = c;   lv1 = l;
                        cv2 = c+1; lv2 = l;
                        cv3 = c;   lv3 = l+1;
                        // cv4 = c+1; lv4 = l+1;
                    }
                    else{
                        radius_tmp = (double) elevl[c+1] + mslrad_offset;
                        ppv1gx = radius_tmp * cos_clatl * cos_clon[c+1];
                        ppv1gy = radius_tmp * cos_clatl * sin_clon[c+1];
                        ppv1gz = radius_tmp * sin_clatl;
                        radius_tmp = (double) elevlp1[c+1] + mslrad_offset;
                        ppv2gx = radius_tmp * cos_clatlp1 * cos_clon[c+1];
                        ppv2gy = radius_tmp * cos_clatlp1 * sin_clon[c+1];
                        ppv2gz = radius_tmp * sin_clatlp1;
                        radius_tmp = (double) elevlp1[c] + mslrad_offset;
                        ppv3gx = radius_tmp * cos_clatlp1 * cos_clon[c];
                        ppv3gy = radius_tmp * cos_clatlp1 * sin_clon[c];
                        ppv3gz = radius_tmp * sin_clatlp1;
//                         ppv1gx = msldemc_xmc[l];
//                         ppv1gy = msldemc_ymc[c+1];
//                         ppv1gz = ((double) -elevl[c+1]) - cam_C[2];
//                         ppv2gx = msldemc_xmc[l+1];
//                         ppv2gy = msldemc_ymc[c+1];
//                         ppv2gz = ((double) -elevlp1[c+1]) - cam_C[2];
//                         ppv3gx = msldemc_xmc[l+1];
//                         ppv3gy = msldemc_ymc[c];
//                         ppv3gz = ((double) -elevlp1[c]) - cam_C[2];
                        cv1 = c+1; lv1 = l;
                        cv2 = c+1; lv2 = l+1;
                        cv3 = c;   lv3 = l+1;
                        // cv4 = c;   lv4 = l;
                        isinFOVd = ((msldemc_imFOVmask[c+1][l]>1) && (msldemc_imFOVmask[c+1][l+1]>1) && (msldemc_imFOVmask[c][l+1]>1));
                        isinFOV = ((msldemc_imFOVmask[c+1][l]>0) && (msldemc_imFOVmask[c+1][l+1]>0) && (msldemc_imFOVmask[c][l+1]>0));
                    }
                    
                    if(isinFOVd){
                        /* Evaluate the projection */
                        // pmcx = ppv1gx; pmcy = ppv1gy; pmcz = ppv1gz;
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

                        // define some plane parameters
                        //pdv1x = ppv2x - ppv1x; pdv1y = ppv2y - ppv1y;
                        //pdv2x = ppv3x - ppv1x; pdv2y = ppv3y - ppv1y;
                        //detM = pdv1x*pdv2y - pdv1y*pdv2x;
                        //Minv[0][0] = pdv2y/detM;
                        //Minv[0][1] = -pdv2x/detM;
                        //Minv[1][0] = -pdv1y/detM;
                        //Minv[1][1] = pdv1x/detM;
                        
                        // pdv1gx = ppv2gx - ppv1gx;
                        // pdv1gy = ppv2gy - ppv1gy;
                        // pdv1gz = ppv2gz - ppv1gz;
                        // pdv2gx = ppv3gx - ppv1gx;
                        // pdv2gy = ppv3gy - ppv1gy;
                        // pdv2gz = ppv3gz - ppv1gz;
                        /* parameters for plane equations
                         * plane normal vector (pn)
                         * plane constant (pc)
                        */
                        // pnx = pdv1gy*pdv2gz - pdv1gz*pdv2gy;
                        // pny = pdv1gz*pdv2gx - pdv1gx*pdv2gz;
                        // pnz = pdv1gx*pdv2gy - pdv1gy*pdv2gx;
                        // lprm_nume = pnx*(ppv1gx-cam_C[0])+pny*(ppv1gy-cam_C[1])+pnz*(ppv1gz-cam_C[2]);
                        
                        /* for pre-screening */
                        x_min = fmin(fmin(ppv1x,ppv2x),ppv3x);
                        y_min = fmin(fmin(ppv1y,ppv2y),ppv3y);
                        x_max = fmax(fmax(ppv1x,ppv2x),ppv3x);
                        y_max = fmax(fmax(ppv1y,ppv2y),ppv3y);
                        
                        x_min_int = (int32_T) floor(K_S*(x_min+0.5));
                        y_min_int = (int32_T) floor(K_L*(y_min+0.5));
                        x_max_int = (int32_T) floor(K_S*(x_max+0.5)+1.0);
                        y_max_int = (int32_T) floor(K_L*(y_max+0.5)+1.0);
                        
                        if(x_min_int<0){
                            x_min_int=0;   
                        }else if(x_min_int>binSm1){
                            x_min_int=binSm1;
                        }
                        if(x_max_int<1){
                            x_max_int=1;
                        }else if(x_max_int>binS){
                            x_max_int=binS;
                        }
                        
                        if(y_min_int<0){
                            y_min_int=0;
                        }else if(y_min_int>binLm1){
                            y_min_int=binLm1;
                        }
                        if(y_max_int<1){
                            y_max_int=1;
                        }else if(y_max_int>binL){
                            y_max_int=binL;
                        }
                        for(xi=x_min_int;xi<x_max_int;xi++){
                            for(yi=y_min_int;yi<y_max_int;yi++){
                                ll_papmc_next = ll_papmc_bin[xi][yi];
                                while(ll_papmc_next!=NULL){
                                    cc = ll_papmc_next->c;
                                    ll = ll_papmc_next->l;
                                    radius_tmp = ll_papmc_next->radius;
                                    /* evaluate line param */
                                    x_iaumars  = radius_tmp * cos_tlat[ll] * cos_tlon[cc];
                                    y_iaumars  = radius_tmp * cos_tlat[ll] * sin_tlon[cc];
                                    z_iaumars  = radius_tmp * sin_tlat[ll];
                                    pmcx = x_iaumars - cam_C[0];
                                    pmcy = y_iaumars - cam_C[1];
                                    pmcz = z_iaumars - cam_C[2];
                                    pprm_s = Minv[0][0]*pmcx+Minv[0][1]*pmcy+Minv[0][2]*pmcz;
                                    if(pprm_s>0){
                                        pprm_t = Minv[1][0]*pmcx+Minv[1][1]*pmcy+Minv[1][2]*pmcz;
                                        if(pprm_t>0){
                                            pprm_u = Minv[2][0]*pmcx+Minv[2][1]*pmcy+Minv[2][2]*pmcz;
                                            if( (pprm_u>0) && (pprm_s+pprm_t+pprm_u>1) ){
                                                if((cc==cv1 && ll==lv1) || (cc==cv2 && ll==lv2) || (cc==cv3 && ll==lv3)){
                                                    ll_papmc_next = ll_papmc_next->next;
                                                } else {
                                                    msldemt_inImage[cc][ll] = 0;
                                                    // if(ll_papmc_next->next!=NULL){
                                                    //     ll_papmc_next->next->prev = ll_papmc_next->prev;
                                                    // }
                                                    // if(ll_papmc_next->prev!=NULL){
                                                    //     ll_papmc_next->prev->next = ll_papmc_next->next;
                                                    // } else {
                                                    //     ll_papmc_bin[xi][yi] = ll_papmc_next->next;
                                                    // }
                                                    // ll_tmp = ll_papmc_next;
                                                    ll_papmc_next = ll_papmc_next->next;
                                                    // free(ll_tmp);
                                                }
                                            } else {
                                                ll_papmc_next = ll_papmc_next->next;
                                            }
                                        } else {
                                            ll_papmc_next = ll_papmc_next->next;
                                        }
                                    } else {
                                        ll_papmc_next = ll_papmc_next->next;
                                    }
                                }
                            }
                        }
                    } else if(isinFOV){
//                         pdv1x = ppv2gx - ppv1gx;
//                         pdv1y = ppv2gy - ppv1gy;
//                         pdv1z = ppv2gz - ppv1gz;
//                         pdv2x = ppv3gx - ppv1gx;
//                         pdv2y = ppv3gy - ppv1gy;
//                         pdv2z = ppv3gz - ppv1gz;
//                         pnx = pdv1y*pdv2z - pdv1z*pdv2y;
//                         pny = pdv1z*pdv2x - pdv1x*pdv2z;
//                         pnz = pdv1x*pdv2y - pdv1y*pdv2x;
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
                        
                        /* parameters for plane equations
                         * plane normal vector (pn)
                         * plane constant (pc)
                        */
                        //pnx = pdv1gy*pdv2gz - pdv1gz*pdv2gy;
                        //pny = pdv1gz*pdv2gx - pdv1gx*pdv2gz;
                        //pnz = pdv1gx*pdv2gy - pdv1gy*pdv2gx;
                        //lprm_nume = pnx*(ppv1gx-cam_C[0])+pny*(ppv1gy-cam_C[1])+pnz*(ppv1gz-cam_C[2]);
                        
//                         for(xi=0;xi<binS;xi++){
//                             for(yi=0;yi<binL;yi++){
//                                 for (n=0;n<bin_count_im[xi][yi];n++){
//                                     cc = bin_im_c[xi][yi][n];
//                                     ll = bin_im_l[xi][yi][n];
//                                     /* evaluate line param */
//                                     radius_tmp = bin_rad[xi][yi][n];
//                                     x_iaumars  = radius_tmp * cos_tlat[ll] * cos_tlon[cc];
//                                     y_iaumars  = radius_tmp * cos_tlat[ll] * sin_tlon[cc];
//                                     z_iaumars  = radius_tmp * sin_tlat[ll];
//                                     pmcx = x_iaumars - cam_C[0];
//                                     pmcy = y_iaumars - cam_C[1];
//                                     pmcz = z_iaumars - cam_C[2];
//                                     //lprm = lprm_nume/(pnx*pmcx+pny*pmcy+pnz*pmcz);
//                                     // if(lprm<1 && lprm>0){
//                                         /* evaluate the test vector is inside the triangle. */
//                                         //pipvgppv1x = lprm*pmcx - ppv1gx;
//                                         //pipvgppv1y = lprm*pmcy - ppv1gy;
//                                         //pipvgppv1z = lprm*pmcz - ppv1gy;
//                                         //pprm_s = Minvp[0][0]*pipvgppv1x+Minvp[0][1]*pipvgppv1y+Minvp[0][2]*pipvgppv1z;
//                                         //pprm_t = Minvp[1][0]*pipvgppv1x+Minvp[1][1]*pipvgppv1y+Minvp[1][2]*pipvgppv1z;
//                                         //pprm_1st = 1 - pprm_s - pprm_t;
//                                         //if(pprm_s>0 && pprm_t>0 && pprm_1st>0){
//                                         //    if((cc==cv1 && ll==lv1) || (cc==cv2 && ll==lv2) || (cc==cv3 && ll==lv3)){
//                                         //    } else {
//                                         //    msldemt_inImage[cc][ll] = 0;
//                                         //    }
//                                         //}
//                                     //}
//                                 }
//                             }
//                         }
                        
                        /* test vectors with napmc<0 */
//                         if(count_napmc>0){
//                             for(n=0;n<count_napmc;n++){
//                                 cc = c_napmc[n]; ll = l_napmc[n];
//                                 radius_tmp = rad_napmc[n];
//                                 x_iaumars  = radius_tmp * cos_tlat[ll] * cos_tlon[cc];
//                                 y_iaumars  = radius_tmp * cos_tlat[ll] * sin_tlon[cc];
//                                 z_iaumars  = radius_tmp * sin_tlat[ll];
//                                 pmcx = x_iaumars - cam_C[0];
//                                 pmcy = y_iaumars - cam_C[1];
//                                 pmcz = z_iaumars - cam_C[2];
//                                 //lprm = lprm_nume/(pnx*pmcx+pny*pmcy+pnz*pmcz);
//                                 //if(lprm<1 && lprm>0){
//                                     /* evaluate the test vector is inside the triangle. */
//                                     //pipvgppv1x = lprm*pmcx - ppv1gx;
//                                     //pipvgppv1y = lprm*pmcy - ppv1gy;
//                                     //pipvgppv1z = lprm*pmcz - ppv1gy;
//                                     //pprm_s = Minvp[0][0]*pipvgppv1x+Minvp[0][1]*pipvgppv1y+Minvp[0][2]*pipvgppv1z;
//                                     //pprm_t = Minvp[1][0]*pipvgppv1x+Minvp[1][1]*pipvgppv1y+Minvp[1][2]*pipvgppv1z;
//                                     //pprm_1st = 1 - pprm_s - pprm_t;
//                                     //if(pprm_s>0 && pprm_t>0 && pprm_1st>0){
//                                     //    if((cc==cv1 && ll==lv1) || (cc==cv2 && ll==lv2) || (cc==cv3 && ll==lv3)){
//                                     //    } else {
//                                     //    msldemt_inImage[cc][ll] = 0;
//                                     //    }
//                                     //}
//                                 //}
//                             }
//                         }
                        
                    }
                }
            }
        }
    }
    

    
    /* free dynamically allocated memories */
    free(cos_clon);
    free(sin_clon);
    if(cos_tlon)
        free(cos_tlon);
    if(sin_tlon)
        free(sin_tlon);
    free(cos_tlat);
    free(sin_tlat);
    free(elevl);
    free(elevlp1);
    fclose(fid);
    
}


#endif