/* =====================================================================
 * crism_gale_get_msldemFOV_scf2_L2_mex.c
 * Evaluate if pixels in the MSL DEM image are potentially in the images
 * 
 * INPUTS:
 * 0 msldem_imgpath        char* path to the image
 * 1 msldem_hdr            EnviHeader
 * 2 mslrad_offset         Double Scalar
 * 3 msldemc_imFOVhdr      Struct
 * 4 msldem_latitude       Double array [msldem_lines]
 * 5 msldem_longitude      Double array [msldem_samples]
 * 6 lList_cofst_ap        int32 [msldemc_lines x 1]
 * 7 lList_cols_ap         int32 [msldemc_lines x 1]
 * 8 cahv_mdl              CAHV_MODEL
 * 9 crism_PmCctr_imxy     Double array [2 x Ncrism]
 *    xy coord of the pixel centers in the camera image plane.
 * 10 sigma                Double Scalar
 * 11 mrgn                 double scalar
 * 
 * OUTPUTS:
 * 0 msldem_imFOVmask     int8 array [msldemc_lines x msldemc_samples]
 * 1 lList_lofst          int32
 * 2 lList_lines          int32 
 * 3 lList_cofst          int32 [msldemc_lines x 1]
 * 4 lList_cols           int32 [msldemc_lines x 1]
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
void get_imFOVmask_MSLDEM_direct(
        char *msldem_imgpath, EnviHeader msldem_hdr, double mslrad_offset,
        int32_t msldemc_sample_offset, int32_T msldemc_line_offset,
        int32_t msldemc_samples, int32_T msldemc_lines,
        int8_t **msldemc_imFOVmask,
        double *msldemc_latitude, double *msldemc_longitude, 
        int32_t *lList_cofst_ap, int32_t *lList_cols_ap,
        int32_t *lList_lofst, int32_t *lList_lines, 
        int32_t *lList_cofst, int32_t *lList_cols,
        CAHV_MODEL cahv_mdl, int16_t Ncrism,
        double **crismPmCctr_imxy, double sgm_psf, double mrgn)
{
    long skip_pri;
    long skip_l, skip_r;
    float *elevl;
    size_t ncpy;
    size_t sz=sizeof(float);
    FILE *fid;
    float data_ignore_value_float;
    
    
    int32_t c,l,cc,ll;
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
    double *PmCbrd_imxap_min, *PmCbrd_imxap_max;
    double *pxlftprnt; /* pixel footprint */
    double x_min,x_max,y_min,y_max;
    int32_t s0,send,l0,lend,lendp1;
    int32_t sz_c,sz_l;
    
    // double **msldemc_imx,**msldemc_imy;
    // double *msldemc_imx_base,*msldemc_imy_base;
    // int16_t *msldemc_imFOVmask_base, **msldemc_imFOVmask;
    
    /* variables for the evaluation of surroundings */
    int32_t lList_l0, lList_lend; /* stores the range of lines for the FOV */
    int32_t *lList_c0,*lList_cend; /* stores the range of columns of each lien for the FOV */
    int32_t c_min,c_max,l_min,l_max;
    
    
    
    cam_C = cahv_mdl.C; cam_A = cahv_mdl.A; cam_H = cahv_mdl.H; cam_V = cahv_mdl.V;
    hs = cahv_mdl.hs; vs = cahv_mdl.vs; hc = cahv_mdl.hc; vc = cahv_mdl.vc;
    cam_Hd = cahv_mdl.Hdash; cam_Vd = cahv_mdl.Vdash;
    
    /*********************************************************************/
    /* calculate the projection of crism pixel borders onto camera image 
     * plane. For each pixel, values outside of the borders are not calculated.
     */
    PmCbrd_imxap_min = (double*) malloc(sizeof(double) * (size_t) Ncrism);
    PmCbrd_imxap_max = (double*) malloc(sizeof(double) * (size_t) Ncrism);
    y_max = 0.5+mrgn; y_min = -y_max;
    for(xi=0;xi<Ncrism;xi++){
        PmCbrd_imxap_min[xi] = crismPmCctr_imxy[xi][0] - y_max;
        PmCbrd_imxap_max[xi] = crismPmCctr_imxy[xi][0] + y_max;
    }
    x_min = PmCbrd_imxap_min[0]; x_max = PmCbrd_imxap_max[Ncrism-1];
    // printf("x_min=%f,x_max=%f\n",x_min,x_max);
    
    
    /*********************************************************************/
    cos_lon = (double*) malloc(sizeof(double) * (size_t) msldemc_samples);
    sin_lon = (double*) malloc(sizeof(double) * (size_t) msldemc_samples);
    for(c=0;c<msldemc_samples;c++){
        cos_lon[c] = cos(msldemc_longitude[c]);
        sin_lon[c] = sin(msldemc_longitude[c]);
    }
    
    cos_lat = (double*) malloc(sizeof(double) * (size_t) msldemc_lines);
    sin_lat = (double*) malloc(sizeof(double) * (size_t) msldemc_lines);
    for(l=0;l<msldemc_lines;l++){
        cos_lat[l] = cos(msldemc_latitude[l]);
        sin_lat[l] = sin(msldemc_latitude[l]);
    }
    
    for(c=0;c<msldemc_samples;c++){
       for(l=0;l<msldemc_lines;l++){
           msldemc_imFOVmask[c][l]    = 0;
       }
    }
    // printf("msldemc_samples=%d,msldemc_lines=%d\n",msldemc_samples,msldemc_lines);
    
    // printf("%d,%d,%d\n",skip_l,msldemc_samples*s,skip_r);
    // printf("a\n");
    // printf("x_min=%f,x_max=%f\n",x_min,x_max);
    
    /* preparation for surrounding detection */
    lList_l0 = -1; lList_lend = -1;
    lList_c0   = (int32_t*) malloc(sizeof(int32_t) * (size_t) msldemc_lines);
    lList_cend = (int32_t*) malloc(sizeof(int32_t) * (size_t) msldemc_lines);
    for(l=0;l<msldemc_lines;l++){
        lList_c0[l]   = -1;
        lList_cend[l] = -1;
    }

    /*********************************************************************/
    
    /* Three things to be done */
    /* 1. Find out crismPxl_srngs and crismPxl_lrngs
     * 2. Prior binning for the 
     */
    
    fid = fopen(msldem_imgpath,"rb");
    /* skip lines */
    skip_pri = (long) msldem_hdr.samples * (long) msldemc_line_offset * (long) sz;
    // printf("%d*%d*%d=%ld\n",msldem_header.samples,msldemc_imxy_line_offset,s,skip_pri);
    fseek(fid,skip_pri,SEEK_CUR);
    /* read the data */
    ncpy = sz * (size_t) msldemc_samples;
    elevl = (float*) malloc(ncpy);
    skip_l = (long) sz * (long) msldemc_sample_offset;
    skip_r = ((long) msldem_hdr.samples - (long) msldemc_samples)* (long) sz - skip_l;
    data_ignore_value_float = (float) msldem_hdr.data_ignore_value + 1.0;
    
    
    for(l=0;l<msldemc_lines;l++){
        fseek(fid,skip_l,SEEK_CUR);
        fread(elevl,sz,msldemc_samples,fid);
        fseek(fid,skip_r,SEEK_CUR);
        for(c=0;c<msldemc_samples;c++){
            if(elevl[c]<data_ignore_value_float)
                elevl[c] = NAN;
        }
        cos_latl = cos_lat[l];
        sin_latl = sin_lat[l];
        s0 = lList_cofst_ap[l]; send = s0 + lList_cols_ap[l];
        c_min = -1; c_max = -1;
        for(c=s0;c<send;c++){
            cos_lonc  = cos_lon[c];
            sin_lonc  = sin_lon[c];
            radius   = (double) elevl[c] + mslrad_offset;
            if(isnan(radius)){
                msldemc_imFOVmask[c][l] = -2;
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
                        //msldemc_imx[c][l] = x_im;
                        //msldemc_imy[c][l] = y_im;
                        if(x_im>x_min && x_im<x_max){
                            msldemc_imFOVmask[c][l] = 5;
                            xii=0;

                            /* for the surrounding detection, second iteration */
                            if(c_min==-1)
                                c_min = c;
                            c_max = c;

                        } else {
                            msldemc_imFOVmask[c][l] = -1;
                        }
                    } else {
                        msldemc_imFOVmask[c][l] = -1;
                    }
                } else {
                    /* Evaluate */
                }
            }
        }
        /* for the surrounding detection, second iteration */
        lList_c0[l] = c_min; lList_cend[l] = c_max;
        if(c_min>-1){
            if(lList_l0==-1)
                lList_l0 = l;
            lList_lend = l;
        }

    }
    
    fclose(fid);
    free(elevl);
    free(cos_lon);
    free(sin_lon);
    free(cos_lat);
    free(sin_lat);
    free(PmCbrd_imxap_min);
    free(PmCbrd_imxap_max);
    
    /*********************************************************************/
    /* Second step
     * Get surrounding neighbors for the evaluation of invisible points
     */
    if(lList_l0>-1){
        lendp1 = lList_lend+1;
        for(l=lList_l0;l<lendp1;l++){
            if(lList_c0[l]>-1){
                l_min = (l-1>0) ? (l-1) : 0;
                l_max = (l+2<msldemc_lines) ? (l+2) : msldemc_lines;
                s0 = lList_c0[l]; send = lList_cend[l]+1;
                for(c=s0;c<send;c++){
                    if(msldemc_imFOVmask[c][l]==5){
                        c_min = (c-1>0) ? (c-1) : 0;
                        c_max = (c+2<msldemc_samples) ? (c+2) : msldemc_samples;
                        for(cc=c_min;cc<c_max;cc++){
                            for(ll=l_min;ll<l_max;ll++){
                                if(msldemc_imFOVmask[cc][ll]==-1 || msldemc_imFOVmask[cc][ll]==0){ 
                                    msldemc_imFOVmask[cc][ll] = 4;
                                    // Extend the indices
                                    if(ll<l0){
                                        /* If the line was not previously selected, */
                                        lList_l0       = ll;
                                        lList_c0[ll]   = cc;
                                        lList_cend[ll] = cc;
                                    } else if(ll>lList_lend){
                                        /* If the line was not previously selected, */
                                        lList_lend     = ll;
                                        lList_c0[ll]   = cc;
                                        lList_cend[ll] = cc;
                                    } else {
                                        /* If the line was previously selected, evaluate the value of cc */
                                        if(cc<lList_c0[ll]){
                                            lList_c0[ll] = cc;
                                        } else if(cc>lList_cend[ll]){
                                            lList_cend[ll] = cc;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }   
    }
    
    /* Convert lList_c0 and lList_cend to lList_cofst and lList_cols */
    *lList_lofst = lList_l0;
    *lList_lines = lList_lend-lList_l0+1;
    for(l=0;l<msldemc_lines;l++){
        lList_cofst[l] = lList_c0[l];
        lList_cols[l]  = lList_cend[l] - lList_c0[l] + 1;
    }
    
    
    free(lList_c0);
    free(lList_cend);
    
}

/* The gateway function */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
    char *msldem_imgpath;
    EnviHeader msldem_header;
    double mslrad_offset;
    mwSize msldemc_sample_offset,msldemc_line_offset;
    mwSize msldemc_samples,msldemc_lines;
    double *msldemc_latitude;
    double *msldemc_longitude;
    CAHV_MODEL cahv_mdl;
    int8_t **msldemc_imFOVmask;
    int32_t *lList_cofst_ap, *lList_cols_ap;
    double **crism_PmCctr_imxy;
    double sgm_psf;
    double mrgn;
    int32_t *lList_lofst, *lList_lines;
    int32_t *lList_cofst, *lList_cols;
    
    mwSize li;
    mwSize Ncrism;
    mwSize sz_FOVcell[2];
    int32_t s0,send,l0,lend;

    /* -----------------------------------------------------------------
     * CHECK PROPER NUMBER OF INPUTS AND OUTPUTS
     * ----------------------------------------------------------------- */
    if(nrhs!=12) {
        mexErrMsgIdAndTxt("crism_gale_get_msldemFOV_scf2_L2_mex:nrhs","12 inputs required.");
    }
    if(nlhs!=5) {
        mexErrMsgIdAndTxt("crism_gale_get_msldemFOV_scf2_L2_mex:nlhs","5 outputs required.");
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
    
    /* INPUT 1 msldem_header and 2 radius offset */
    msldem_header = mxGetEnviHeader(prhs[1]);
    
    mslrad_offset     = mxGetScalar(prhs[2]);
    
    /* INPUT 3 msldemc_sheader*/
    msldemc_sample_offset = (mwSize) mxGetScalar(mxGetField(prhs[3],0,"sample_offset"));
    msldemc_line_offset   = (mwSize) mxGetScalar(mxGetField(prhs[3],0,"line_offset"));
    msldemc_samples       = (mwSize) mxGetScalar(mxGetField(prhs[3],0,"samples"));
    msldemc_lines         = (mwSize) mxGetScalar(mxGetField(prhs[3],0,"lines"));
    
    /* INPUT 4/5 msldem northing easting */
    msldemc_latitude  = mxGetDoubles(prhs[4]) + msldemc_line_offset  ;
    msldemc_longitude = mxGetDoubles(prhs[5]) + msldemc_sample_offset;
    
    lList_cofst_ap = mxGetInt32s(prhs[6]);
    lList_cols_ap  = mxGetInt32s(prhs[7]);
    
    /* INPUT 8 camera model */
    cahv_mdl = mxGet_CAHV_MODEL(prhs[8]);
    
    /* */
    crism_PmCctr_imxy = set_mxDoubleMatrix(prhs[9]);
    Ncrism = mxGetN(prhs[9]);
    
    sgm_psf = mxGetScalar(prhs[10]);
    
    mrgn = mxGetScalar(prhs[11]);
    
    /* OUTPUT 0 msldem imFOV */
    plhs[0] = mxCreateNumericMatrix(msldemc_lines,msldemc_samples,mxINT8_CLASS,mxREAL);
    msldemc_imFOVmask = set_mxInt8Matrix(plhs[0]);
    
    plhs[1] = mxCreateNumericMatrix(1,1,mxINT32_CLASS,mxREAL);
    lList_lofst = mxGetInt32s(plhs[1]);
    
    plhs[2] = mxCreateNumericMatrix(1,1,mxINT32_CLASS,mxREAL);
    lList_lines = mxGetInt32s(plhs[2]);
    
    plhs[3] = mxCreateNumericArray(1,&msldemc_lines,mxINT32_CLASS,mxREAL);
    lList_cofst = mxGetInt32s(plhs[3]);
    
    plhs[4] = mxCreateNumericArray(1,&msldemc_lines,mxINT32_CLASS,mxREAL);
    lList_cols = mxGetInt32s(plhs[4]);
    

    // printf("sim = %d\n",S_im);
    /* -----------------------------------------------------------------
     * CALL MAIN COMPUTATION ROUTINE
     * ----------------------------------------------------------------- */
    
    get_imFOVmask_MSLDEM_direct(
        msldem_imgpath, msldem_header, mslrad_offset,
        (int32_t) msldemc_sample_offset, (int32_t) msldemc_line_offset,
        (int32_t) msldemc_samples, (int32_t) msldemc_lines,
        msldemc_imFOVmask,
        msldemc_latitude, msldemc_longitude, 
        lList_cofst_ap, lList_cols_ap,
        lList_lofst, lList_lines, lList_cofst, lList_cols,
        cahv_mdl, (int16_t) Ncrism,
        crism_PmCctr_imxy, sgm_psf, mrgn);
    
    /* free memories */
    mxFree(msldem_imgpath);
    mxFree(msldemc_imFOVmask);
    mxFree(crism_PmCctr_imxy);
    
    
}

