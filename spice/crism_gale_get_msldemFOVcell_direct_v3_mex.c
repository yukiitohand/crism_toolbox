/* =====================================================================
 * crism_gale_get_msldemFOV_direct_v3_mex.c
 * Evaluate if pixels in the MSL DEM image are potentially in 
 * 
 * INPUTS:
 * 0 msldem_radius         Double array [msldem_lines x msldem_samples]
 * 1 msldemc_samples       Scalar
 * 2 msldemc_lines         Scalar
 * 1 sample_offset         Scalar
 * 2 line_offset           Scalar
 * 3 msldem_latitude       Double array [msldem_lines]
 * 4 msldem_longitude      Double array [msldem_samples]
 * 5 cahv_mdl              CAHV_MODEL
 * 6 crism_PmCbrd          Double array [3 x (Ncrism+1)]
 * 7 valid_samples         int32 array [2 x (Ncrism)]
 * 8 valid_lines           int32 array [2 x (Ncrism)]
 * 
 * 
 * OUTPUTS:
 * 0 crism_FOVcell        cell array [Ncrism]
 * 1 crismPxl_srngs       valid samples [2 x Ncrism]
 * 2 crismPxl_lrngs       valid lines   [2 x Ncrism]
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
void get_imFOVmask_MSLDEM_direct(float **msldem_img_radius, double mslradius_offset,
        int32_t msldem_samples, int32_t msldem_lines,
        int16_t **msldemc_imFOVmask,
        int32_t msldemc_samples, int32_t msldemc_lines,
        int32_t sample_offset, int32_t line_offset,
        double *msldem_latitude, double *msldem_longitude, 
        CAHV_MODEL cahv_mdl, double **crism_PmCbrd, int16_t Npmc_brd,
        mxArray *crism_FOVcell, int16_t Ncrism,
        int32_t **crismPxl_srngs, int32_t **crismPxl_lrngs,
        int32_t **valid_samples, int32_t **valid_lines)
{
    int32_t c,l;
    int16_t xi,xii;
    double *cos_lon, *sin_lon, *cos_lat, *sin_lat;
    double cos_latl, sin_latl, cos_lonc, sin_lonc;
    double radius;
    // float  radius_float;
    double x_iaumars, y_iaumars, z_iaumars;
    double pmcx, pmcy, pmcz;
    double apmc, hpmc, vpmc;
    double x_im, y_im;
    double *cam_C, *cam_A, *cam_H, *cam_V, *cam_Hd, *cam_Vd;
    double hc,vc,hs,vs;
    double *PmCbrd_imxap;
    int8_t *pxlftprnt; /* pixel footprint */
    double x_min,x_max,y_min,y_max;
    int32_t s0,send,l0,lend;
    int32_t sz_c,sz_l;
    // int16_t *msldemc_imFOVmask_base, **msldemc_imFOVmask;
    
    cam_C = cahv_mdl.C; cam_A = cahv_mdl.A; cam_H = cahv_mdl.H; cam_V = cahv_mdl.V;
    hs = cahv_mdl.hs; vs = cahv_mdl.vs; hc = cahv_mdl.hc; vc = cahv_mdl.vc;
    cam_Hd = cahv_mdl.Hdash; cam_Vd = cahv_mdl.Vdash;
    
    /*********************************************************************/
    /* calculate the projection of crism pixel borders onto camera image 
     * plane */
    PmCbrd_imxap = (double*) malloc(sizeof(double) * (size_t) Npmc_brd);
    for(xi=0;xi<Npmc_brd;xi++){
        pmcx = crism_PmCbrd[xi][0];
        pmcy = crism_PmCbrd[xi][1];
        pmcz = crism_PmCbrd[xi][2];
        apmc = cam_A[0]*pmcx + cam_A[1]*pmcy + cam_A[2]*pmcz;
        hpmc = cam_H[0]*pmcx + cam_H[1]*pmcy + cam_H[2]*pmcz;
        PmCbrd_imxap[xi] = hpmc/apmc;
    }
    y_min = -0.5; y_max = 0.5;
    x_min = PmCbrd_imxap[0]; x_max = PmCbrd_imxap[Npmc_brd-1];
    
    
    
    /*********************************************************************/
    cos_lon = (double*) malloc(sizeof(double) * (size_t) msldemc_samples);
    sin_lon = (double*) malloc(sizeof(double) * (size_t) msldemc_samples);
    for(c=0;c<msldemc_samples;c++){
        cos_lon[c] = cos(msldem_longitude[c+sample_offset]);
        sin_lon[c] = sin(msldem_longitude[c+sample_offset]);
    }
    
    cos_lat = (double*) malloc(sizeof(double) * (size_t) msldemc_lines);
    sin_lat = (double*) malloc(sizeof(double) * (size_t) msldemc_lines);
    for(l=0;l<msldemc_lines;l++){
        cos_lat[l] = cos(msldem_latitude[l+line_offset]);
        sin_lat[l] = sin(msldem_latitude[l+line_offset]);
    }
    
//     createInt16Matrix(&msldemc_imFOVmask, &msldemc_imFOVmask_base, 
//             (size_t) msldemc_samples, (size_t) msldemc_lines);
    for(c=0;c<msldemc_samples;c++){
        for(l=0;l<msldemc_lines;l++){
            msldemc_imFOVmask[c][l] = -3;
        }
    }
    
    // printf("%d,%d,%d\n",skip_l,msldemc_samples*s,skip_r);
    // printf("a\n");
    for(xi=0;xi<Ncrism;xi++){
        s0 = valid_samples[xi][0]; send = valid_samples[xi][1]+1;
        l0 = valid_lines[xi][0]; lend = valid_lines[xi][1]+1;
        // printf("xi=%d, s0=%d send=%d, l0=%d, lend=%d\n",xi,s0,send,l0,lend);
        for(c=s0;c<send;c++){
            cos_lonc  = cos_lon[c-sample_offset];
            sin_lonc  = sin_lon[c-sample_offset];
            for(l=l0;l<lend;l++){
                if(msldemc_imFOVmask[c-sample_offset][l-line_offset]==-3){
                    cos_latl = cos_lat[l-line_offset];
                    sin_latl = sin_lat[l-line_offset];
                    radius   = (double) msldem_img_radius[c][l] + mslradius_offset;
                    if(isnan(radius)){
                        msldemc_imFOVmask[c-sample_offset][l-line_offset] = -2;
                    } else {
                        /* transform radius-lat-lon to IAU_MARS XYZ */
                        x_iaumars = radius * cos_latl * cos_lonc;
                        y_iaumars = radius * cos_latl * sin_lonc;
                        z_iaumars = radius * sin_latl;
                        pmcx = x_iaumars - cam_C[0];
                        pmcy = y_iaumars - cam_C[1];
                        pmcz = z_iaumars - cam_C[2];

                        apmc = cam_A[0] * pmcx + cam_A[1] * pmcy + cam_A[2] * pmcz;
                        if(apmc>0){
                            vpmc = cam_V[0] * pmcx + cam_V[1] * pmcy + cam_V[2] * pmcz;
                            y_im = vpmc / apmc;
                            if(y_im>y_min && y_im<y_max){
                                hpmc = cam_H[0] * pmcx + cam_H[1] * pmcy + cam_H[2] * pmcz;
                                x_im = hpmc / apmc;
                                if(x_im>x_min && x_im<x_max){
                                    xii=0;
                                    while( x_im>PmCbrd_imxap[xii] ){
                                        xii++;
                                    }
                                    xii--;
                                    msldemc_imFOVmask[c-sample_offset][l-line_offset] = xii;
                                    if(c<crismPxl_srngs[xii][0]) {
                                        crismPxl_srngs[xii][0] = c;
                                    } else if(c>crismPxl_srngs[xii][1]) {
                                        crismPxl_srngs[xii][1] = c;
                                    }
                                    if(l<crismPxl_lrngs[xii][0]) {
                                        crismPxl_lrngs[xii][0] = l;
                                    } else if(l>crismPxl_lrngs[xii][1]) {
                                        crismPxl_lrngs[xii][1] = l;
                                    }
                                } else {
                                    msldemc_imFOVmask[c-sample_offset][l-line_offset] = -1;
                                }
                            } else {
                                msldemc_imFOVmask[c-sample_offset][l-line_offset] = -1;
                            }
                        } else {
                            /* Evaluate */
                        }
                    }
                }
            }
        }
    }
   
    
    /*********************************************************************/
    /* Second iteation */
    for(xi=0;xi<Ncrism;xi++){
        s0 = crismPxl_srngs[xi][0]; send = crismPxl_srngs[xi][1]+1;
        l0 = crismPxl_lrngs[xi][0]; lend = crismPxl_lrngs[xi][1]+1;
        sz_c = crismPxl_srngs[xi][1] - s0+1;
        sz_l = crismPxl_lrngs[xi][1] - l0+1;
        // printf("xi=%d sz_c=%d,sz_l=%d\n",xi,sz_c,sz_l);
        mxSetCell(crism_FOVcell,(mwIndex) xi,
                mxCreateNumericMatrix((mwSize) sz_l, (mwSize) sz_c, mxINT8_CLASS,mxREAL));
        pxlftprnt = mxGetInt8s(mxGetCell(crism_FOVcell,(mwIndex) xi));
        for(c=s0;c<send;c++){
            for(l=l0;l<lend;l++){
                if(msldemc_imFOVmask[c-sample_offset][l-line_offset]==xi){
                    pxlftprnt[(c-s0)*sz_l+l-l0] = 1;
                } else {
                    pxlftprnt[(c-s0)*sz_l+l-l0] = 0;
                }
            }
        }
//         for(l=0;l<sz_l;l++){
//             cos_latl = cos(msldem_latitude[l+line_offset]);
//             sin_latl = sin(msldem_latitude[l+line_offset]);
//             for(c=0;c<sz_c;c++){
//                 cos_lonc  = cos_lon[c];
//                 sin_lonc  = sin_lon[c];
//                 
//                 radius = (double) msldem_img_radius[c+sample_offset][l+line_offset] + mslradius_offset;
//                 if(isnan(radius)){
//                 } else {
//                     x_iaumars = radius * cos_latl * cos_lonc;
//                     y_iaumars = radius * cos_latl * sin_lonc;
//                     z_iaumars = radius * sin_latl;
// 
//                     pmcx = x_iaumars - cam_C[0];
//                     pmcy = y_iaumars - cam_C[1];
//                     pmcz = z_iaumars - cam_C[2];
//                     apmc = cam_A[0] * pmcx + cam_A[1] * pmcy + cam_A[2] * pmcz;
//                     vpmc = cam_V[0] * pmcx + cam_V[1] * pmcy + cam_V[2] * pmcz;
//                     y_im = vpmc / apmc;
//                     hpmc = cam_H[0] * pmcx + cam_H[1] * pmcy + cam_H[2] * pmcz;
//                     x_im = hpmc / apmc;
//                     if(y_im>y_min && y_im<y_max && x_im>x_min && x_im<x_max){
//                         xii=0;
//                         while( x_im>PmCbrd_imxap[xii] ){
//                             xii++;
//                         }
//                         xii--;
//                         if(xii==xi){
//                             pxlftprnt[c*sz_l+l] = 1;
//                         } else {
//                             pxlftprnt[c*sz_l+l] = 0;
//                         }
//                     }
//                 }
//             }
//         }
        
    }
            
    
    // free(msldemc_imFOVmask);
    // free(msldemc_imFOVmask_base);
    free(cos_lon);
    free(sin_lon);
    free(cos_lat);
    free(sin_lat);
    
    
}

/* The gateway function */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
    float **msldem_img_radius;
    double mslradius_offset;
    mwSize msldemc_samples, msldemc_lines, sample_offset, line_offset;
    double *msldem_latitude;
    double *msldem_longitude;
    CAHV_MODEL cahv_mdl;
    double **crism_PmCbrd;
    int16_t **msldemc_imFOVmask;
    mxArray *crism_FOVcell;
    int32_t **crismPxl_srngs,**crismPxl_lrngs;
    int32_t **valid_samples, **valid_lines;
    
    mwSize si,li;
    mwSize msldem_samples, msldem_lines;
    mwSize Npmc_brd, Ncrism;
    mwSize sz_FOVcell[2];

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
    
    /* INPUT 0 msldem_img */
    msldem_img_radius = set_mxSingleMatrix(prhs[0]);
    mslradius_offset = mxGetScalar(prhs[1]);
    msldem_lines = mxGetM(prhs[0]);
    msldem_samples = mxGetN(prhs[0]);
    
    /* INPUT 1/2 sample offset and line offset */
    msldemc_samples = (mwSize) mxGetScalar(prhs[2]);
    msldemc_lines   = (mwSize) mxGetScalar(prhs[3]);
    sample_offset = (mwSize) mxGetScalar(prhs[4]);
    line_offset   = (mwSize) mxGetScalar(prhs[5]);
    
    /* INPUT 3/4 msldem northing easting */
    msldem_latitude = mxGetDoubles(prhs[6]);
    msldem_longitude = mxGetDoubles(prhs[7]);
    
    /* INPUT 5 camera model */
    cahv_mdl = mxGet_CAHV_MODEL(prhs[8]);
    
    /* INPUT 6 (P-C) vectors at the pixel borders */
    crism_PmCbrd = set_mxDoubleMatrix(prhs[9]);
    Npmc_brd     = mxGetN(prhs[9]); /* the number of borders */
    /* the number of pixels are one minus number of borders */
    Ncrism = Npmc_brd - 1; 
    
    valid_samples = set_mxInt32Matrix(prhs[10]);
    valid_lines   = set_mxInt32Matrix(prhs[11]);
    
    /* OUTPUT 0 msldem imFOV */
    plhs[0] = mxCreateNumericMatrix(msldemc_lines,msldemc_samples,mxINT16_CLASS,mxREAL);
    msldemc_imFOVmask = set_mxInt16Matrix(plhs[0]);
    
    /* OUTPUT 1 */
    sz_FOVcell[0] = 1;
    sz_FOVcell[1] = Ncrism;
    crism_FOVcell = mxCreateCellArray(2,sz_FOVcell);
    plhs[1] = crism_FOVcell;
    
    plhs[2] = mxCreateNumericMatrix(2,Ncrism,mxINT32_CLASS,mxREAL);
    crismPxl_srngs = set_mxInt32Matrix(plhs[2]);
    plhs[3] = mxCreateNumericMatrix(2,Ncrism,mxINT32_CLASS,mxREAL);
    crismPxl_lrngs = set_mxInt32Matrix(plhs[3]);
    
    // Initialize matrices
    
    for(si=0;si<Ncrism;si++){
        crismPxl_srngs[si][0] = 2147483647;
        crismPxl_lrngs[si][0] = 2147483647;
        crismPxl_srngs[si][1] = -1;
        crismPxl_lrngs[si][1] = -1;
    }
    // printf("sim = %d\n",S_im);
    /* -----------------------------------------------------------------
     * CALL MAIN COMPUTATION ROUTINE
     * ----------------------------------------------------------------- */
    
    get_imFOVmask_MSLDEM_direct(msldem_img_radius, mslradius_offset,
            (int32_t) msldem_samples, (int32_t) msldem_lines,
            msldemc_imFOVmask,
            (int32_t) msldemc_samples, (int32_t) msldemc_lines,
            (int32_t) sample_offset, (int32_t) line_offset,
            msldem_latitude, msldem_longitude, 
            cahv_mdl,crism_PmCbrd, (int16_t) Npmc_brd,
            crism_FOVcell, (int16_t) Ncrism,
            crismPxl_srngs,crismPxl_lrngs,valid_samples,valid_lines);
    
    /* free memories */
    mxFree(msldem_img_radius);
    mxFree(crism_PmCbrd);
    mxFree(msldemc_imFOVmask);
    mxFree(crismPxl_srngs);
    mxFree(crismPxl_lrngs);
    mxFree(valid_samples);
    mxFree(valid_lines);
    
    
}

