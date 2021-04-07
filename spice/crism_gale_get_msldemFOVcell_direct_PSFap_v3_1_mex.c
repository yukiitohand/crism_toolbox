/* =====================================================================
 * crism_gale_get_msldemFOV_direct_PSFap_v3_1_mex.c
 * Evaluate if pixels in the MSL DEM image are potentially in the images
 * 
 * INPUTS:
 * 0 msldem_radius         Single array [msldem_lines x msldem_samples]
 * 1 mslradius_offset      Double Scalar
 * 2 msldem_latitude       Double array [msldem_lines]
 * 3 msldem_longitude      Double array [msldem_samples]
 * 4 msldemc_hdr           Struct
 * 5 cahv_mdl              CAHV_MODEL
 * 6 crismPxl_srngs_ap     int32 array [2 x (Ncrism)]
 * 7 crismPxl_lrngs_ap     int32 array [2 x (Ncrism)]
 * 8 crism_PmCctr_imxy     Double array [2 x Ncrism] 
 *    xy coord of the pixel centers in the camera image plane.
 * 9 sigma                 Double Scalar
 * 10 mrgn                 double scalar 
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
#include "mex_create_array.h"
#include "cahvor.h"

/* main computation routine */
void get_imFOVmask_MSLDEM_direct(float **msldem_img_radius, double mslradius_offset,
        int32_t msldem_samples, int32_t msldem_lines,
        int16_t **msldemc_imFOVmask,
        int32_t msldemc_samples, int32_t msldemc_lines,
        int32_t sample_offset, int32_t line_offset,
        double *msldem_latitude, double *msldem_longitude, 
        CAHV_MODEL cahv_mdl,
        mxArray *crism_FOVcell, int16_t Ncrism,
        int32_t **crismPxl_srngs, int32_t **crismPxl_lrngs,
        int32_t **crismPxl_srngs_ap, int32_t **crismPxl_lrngs_ap,
        double **crismPmCctr_imxy, double sgm_psf, double mrgn)
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
    double *PmCbrd_imxap_min, *PmCbrd_imxap_max;
    double *pxlftprnt; /* pixel footprint */
    double x_min,x_max,y_min,y_max;
    int32_t s0,send,l0,lend;
    int32_t sz_c,sz_l;
    
    double Z,sgm_psf2;
    double xctr_xi,d,v,thrsh;
    double **msldemc_imx,**msldemc_imy;
    double *msldemc_imx_base,*msldemc_imy_base;
    // int16_t *msldemc_imFOVmask_base, **msldemc_imFOVmask;
    
    cam_C = cahv_mdl.C; cam_A = cahv_mdl.A; cam_H = cahv_mdl.H; cam_V = cahv_mdl.V;
    hs = cahv_mdl.hs; vs = cahv_mdl.vs; hc = cahv_mdl.hc; vc = cahv_mdl.vc;
    cam_Hd = cahv_mdl.Hdash; cam_Vd = cahv_mdl.Vdash;
    
    sgm_psf2 = (-2) * sgm_psf * sgm_psf;
    Z = sgm_psf * sgm_psf * 2 * M_PI;
    thrsh = 0.01;
    
    /*********************************************************************/
    /* calculate the projection of crism pixel borders onto camera image 
     * plane */
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
        cos_lon[c] = cos(msldem_longitude[c+sample_offset]);
        sin_lon[c] = sin(msldem_longitude[c+sample_offset]);
    }
    
    cos_lat = (double*) malloc(sizeof(double) * (size_t) msldemc_lines);
    sin_lat = (double*) malloc(sizeof(double) * (size_t) msldemc_lines);
    for(l=0;l<msldemc_lines;l++){
        cos_lat[l] = cos(msldem_latitude[l+line_offset]);
        sin_lat[l] = sin(msldem_latitude[l+line_offset]);
    }
    
//     createDoubleMatrix(&msldemc_imx, &msldemc_imx_base, 
//             (size_t) msldemc_samples, (size_t) msldemc_lines);
//     createDoubleMatrix(&msldemc_imy, &msldemc_imy_base, 
//             (size_t) msldemc_samples, (size_t) msldemc_lines);
    
//     createInt16Matrix(&msldemc_imFOVmask, &msldemc_imFOVmask_base, 
//             (size_t) msldemc_samples, (size_t) msldemc_lines);
    for(c=0;c<msldemc_samples;c++){
       for(l=0;l<msldemc_lines;l++){
           msldemc_imFOVmask[c][l] = 0;
       }
    }
    // printf("msldemc_samples=%d,msldemc_lines=%d\n",msldemc_samples,msldemc_lines);
    
    // printf("%d,%d,%d\n",skip_l,msldemc_samples*s,skip_r);
    // printf("a\n");
    // printf("x_min=%f,x_max=%f\n",x_min,x_max);
    for(xi=0;xi<Ncrism;xi++){
        s0   = crismPxl_srngs_ap[xi][0]   - sample_offset;
        send = crismPxl_srngs_ap[xi][1]+1 - sample_offset;
        l0   = crismPxl_lrngs_ap[xi][0]       - line_offset;
        lend = crismPxl_lrngs_ap[xi][1]+1   - line_offset;
        // printf("xi=%d, s0=%d send=%d, l0=%d, lend=%d\n",xi,s0,send,l0,lend);
        for(c=s0;c<send;c++){
            cos_lonc  = cos_lon[c];
            sin_lonc  = sin_lon[c];
            for(l=l0;l<lend;l++){
                if(!msldemc_imFOVmask[c][l]){
                    cos_latl = cos_lat[l];
                    sin_latl = sin_lat[l];
                    radius   = (double) msldem_img_radius[c+sample_offset][l+line_offset] + mslradius_offset;
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
                                    xii=0;
                                    while( xii<Ncrism && x_im>PmCbrd_imxap_min[xii]){
                                        if(x_im<PmCbrd_imxap_max[xii]){
                                            msldemc_imFOVmask[c][l] = 1;
                                            d = x_im-crismPmCctr_imxy[xii][0];
                                            v = exp((d*d+y_im*y_im)/sgm_psf2) / Z;
                                            if(v>thrsh){
                                                //msldemc_imFOVmask[c][l] = 1;
                                                if(c<crismPxl_srngs[xii][0]) {
                                                    crismPxl_srngs[xii][0] = c;
                                                }
                                                if(c>crismPxl_srngs[xii][1]) {
                                                    crismPxl_srngs[xii][1] = c;
                                                }
                                                if(l<crismPxl_lrngs[xii][0]) {
                                                    crismPxl_lrngs[xii][0] = l;
                                                }
                                                if(l>crismPxl_lrngs[xii][1]) {
                                                    crismPxl_lrngs[xii][1] = l;
                                                }
                                            }
                                        }
                                        xii++;
                                    }
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
            }
        }
    }
   
    
    /*********************************************************************/
    /* Second iteation */
    for(xi=0;xi<Ncrism;xi++){
        // printf("xi=%d\n",xi);
        s0 = crismPxl_srngs[xi][0]; send = crismPxl_srngs[xi][1]+1;
        l0 = crismPxl_lrngs[xi][0]; lend = crismPxl_lrngs[xi][1]+1;
        sz_c = send - s0;
        sz_l = lend - l0;
        // printf("sz_c=%d,sz_l=%d\n",sz_c,sz_l);
        // printf("xi=%d sz_c=%d,sz_l=%d\n",xi,sz_c,sz_l);
        mxSetCell(crism_FOVcell,(mwIndex) xi,
                mxCreateNumericMatrix((mwSize) sz_l, (mwSize) sz_c, mxDOUBLE_CLASS,mxREAL));
        pxlftprnt = mxGetDoubles(mxGetCell(crism_FOVcell,(mwIndex) xi));
        xctr_xi = crismPmCctr_imxy[xi][0];
        for(c=s0;c<send;c++){
            cos_lonc  = cos_lon[c];
            sin_lonc  = sin_lon[c];
            for(l=l0;l<lend;l++){
                if(msldemc_imFOVmask[c][l]){
                    cos_latl = cos_lat[l];
                    sin_latl = sin_lat[l];
                    radius   = (double) msldem_img_radius[c+sample_offset][l+line_offset] + mslradius_offset;
                    x_iaumars = radius * cos_latl * cos_lonc;
                    y_iaumars = radius * cos_latl * sin_lonc;
                    z_iaumars = radius * sin_latl;
                    pmcx = x_iaumars - cam_C[0];
                    pmcy = y_iaumars - cam_C[1];
                    pmcz = z_iaumars - cam_C[2];
                    apmc = cam_A[0] * pmcx + cam_A[1] * pmcy + cam_A[2] * pmcz;
                    vpmc = cam_V[0] * pmcx + cam_V[1] * pmcy + cam_V[2] * pmcz;
                    y_im = vpmc / apmc;
                    hpmc = cam_H[0] * pmcx + cam_H[1] * pmcy + cam_H[2] * pmcz;
                    x_im = hpmc / apmc;
//                     x_im = msldemc_imx[c][l];
//                     y_im = msldemc_imy[c][l];
                    
                    if(x_im>PmCbrd_imxap_min[xi] && x_im<PmCbrd_imxap_max[xi]){
                        d = x_im-xctr_xi;
                        v = exp((d*d+y_im*y_im)/sgm_psf2) / Z;
                        if(v>thrsh){
                            pxlftprnt[(c-s0)*sz_l+l-l0] = v;
                        }
                    } else {
                        pxlftprnt[(c-s0)*sz_l+l-l0] = 0L;
                    }
                }
            }
        }
    }
            
    
    // free(msldemc_imFOVmask);
    // free(msldemc_imFOVmask_base);
    free(cos_lon);
    free(sin_lon);
    free(cos_lat);
    free(sin_lat);
    free(PmCbrd_imxap_min);
    free(PmCbrd_imxap_max);
//     free(msldemc_imx);
//     free(msldemc_imy);
//     free(msldemc_imx_base);
//     free(msldemc_imy_base);
    
    
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
    int16_t **msldemc_imFOVmask;
    mxArray *crism_FOVcell;
    int32_t **crismPxl_srngs,**crismPxl_lrngs;
    int32_t **crismPxl_srngs_ap, **crismPxl_lrngs_ap;
    double **crism_PmCctr_imxy;
    double sgm_psf;
    double mrgn;
    
    mwSize si,li;
    mwSize msldem_samples, msldem_lines;
    mwSize Ncrism;
    mwSize sz_FOVcell[2];
    mwSize xi;
    int32_t s0,send,l0,lend;

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

    /* INPUT 3/4 msldem northing easting */
    msldem_latitude = mxGetDoubles(prhs[2]);
    msldem_longitude = mxGetDoubles(prhs[3]);
    
    /* INPUT 1/2 sample offset and line offset */
    sample_offset = (mwSize) mxGetScalar(mxGetField(prhs[4],0,"sample_offset"));
    line_offset   = (mwSize) mxGetScalar(mxGetField(prhs[4],0,"line_offset"));
    msldemc_samples = (mwSize) mxGetScalar(mxGetField(prhs[4],0,"samples"));
    msldemc_lines   = (mwSize) mxGetScalar(mxGetField(prhs[4],0,"lines"));
    
    /* INPUT 5 camera model */
    cahv_mdl = mxGet_CAHV_MODEL(prhs[5]);
    
    crismPxl_srngs_ap = set_mxInt32Matrix(prhs[6]);
    crismPxl_lrngs_ap = set_mxInt32Matrix(prhs[7]);
    
    /* */
    crism_PmCctr_imxy = set_mxDoubleMatrix(prhs[8]);
    Ncrism = mxGetN(prhs[8]);
    
    sgm_psf = mxGetScalar(prhs[9]);
    
    mrgn = mxGetScalar(prhs[10]);
    
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
    
    
    for(si=0;si<Ncrism;si++){
        s0   = crismPxl_srngs_ap[si][0]   - sample_offset;
        send = crismPxl_srngs_ap[si][1]+1 - sample_offset;
        l0   = crismPxl_lrngs_ap[si][0]   - line_offset;
        lend = crismPxl_lrngs_ap[si][1]+1 - line_offset;
        if(s0<0 || l0<0 || send>msldemc_samples || lend>msldemc_lines){
            mexErrMsgIdAndTxt(
                    "crism_gale_get_msldemFOV_direct_PSFap_v3_1_mex:InputInvalid",
                    "cell ranges are invalid.");
        }
    }
    
    
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
            cahv_mdl,
            crism_FOVcell, (int16_t) Ncrism,
            crismPxl_srngs,crismPxl_lrngs,crismPxl_srngs_ap,crismPxl_lrngs_ap,
            crism_PmCctr_imxy,sgm_psf,mrgn);
    
    /* free memories */
    mxFree(msldem_img_radius);
    mxFree(msldemc_imFOVmask);
    mxFree(crismPxl_srngs);
    mxFree(crismPxl_lrngs);
    mxFree(crismPxl_srngs_ap);
    mxFree(crismPxl_lrngs_ap);
    mxFree(crism_PmCctr_imxy);
    
    
}

