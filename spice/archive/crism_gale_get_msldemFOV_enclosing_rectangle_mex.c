/* =====================================================================
 * crism_gale_get_msldemFOV_enclosing_rectangle.c
 * Evaluate if pixels in the MSL DEM image are potentially in 
 * 
 * INPUTS:
 * 0 msldem_radius         Double array [msldem_lines x msldem_samples]
 * 1 msldem_latitude       Double array [msldem_lines]
 * 2 msldem_longitude      Double array [msldem_samples]
 * 3 cahv_mdl              CAHV_MODEL
 * 4 srange
 * 5 lrange
 * 6 coef_mrgn             coefficient for the margin
 * 
 * 
 * OUTPUTS:
 * 0 msldemc_imFOVmaskd    int8 [L_dem x S_dem]
 * // 1 msldemc_imFOVmaskd    Boolean [L_dem x S_dem]
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
void get_imFOVmask_MSLDEM(double **msldem_img_radius, int32_T msldem_lines,
        int32_T msldem_samples,
        double *msldem_latitude, double *msldem_longitude, 
        CAHV_MODEL cahv_mdl, double *srange, double *lrange,
        int8_T **msldem_imFOVmask, double coef_mrgn)
{
    int32_T c,l;
    double *cos_lon, *sin_lon;
    double cos_latl, sin_latl, cos_lonc, sin_lonc;
    double radius;
    double x_iaumars, y_iaumars, z_iaumars;
    double pmcx, pmcy, pmcz;
    double apmc, hpmc, vpmc;
    double x_im, y_im;
    double resol;
    double mrgnh,mrgnv;
    double *cam_C, *cam_A, *cam_H, *cam_V, *cam_Hd, *cam_Vd;
    double hc,vc,hs,vs;
    
    cam_C = cahv_mdl.C; cam_A = cahv_mdl.A; cam_H = cahv_mdl.H; cam_V = cahv_mdl.V;
    hs = cahv_mdl.hs; vs = cahv_mdl.vs; hc = cahv_mdl.hc; vc = cahv_mdl.vc;
    cam_Hd = cahv_mdl.Hdash; cam_Vd = cahv_mdl.Vdash;
    
    cos_lon = (double*) malloc(sizeof(double) * (size_t) msldem_samples);
    sin_lon = (double*) malloc(sizeof(double) * (size_t) msldem_samples);
    for(c=0;c<msldem_samples;c++){
        cos_lon[c] = cos(msldem_longitude[c]);
        sin_lon[c] = sin(msldem_longitude[c]);
    }
    
    
    
    // printf("%d \n",L_dem);
    
    resol = sqrt(3);
    
    // printf("%d,%d,%d\n",skip_l,msldemc_samples*s,skip_r);
    for(l=0;l<msldem_lines;l++){
        // printf("l=%d \n",l);
        cos_latl = cos(msldem_latitude[l]);
        sin_latl = sin(msldem_latitude[l]);
        
        for(c=0;c<msldem_samples;c++){
            /* transform radius-lat-lon to IAU_MARS XYZ */
            cos_lonc  = cos_lon[c];
            sin_lonc  = sin_lon[c];
            radius    = msldem_img_radius[c][l];
            x_iaumars = radius * cos_latl * cos_lonc;
            y_iaumars = radius * cos_latl * sin_lonc;
            z_iaumars = radius * sin_latl;
            
            pmcx = x_iaumars - cam_C[0];
            pmcy = y_iaumars - cam_C[1];
            pmcz = z_iaumars - cam_C[2];

            apmc = cam_A[0] * pmcx + cam_A[1] * pmcy + cam_A[2] * pmcz;

            if(apmc>0){
                hpmc = cam_H[0] * pmcx + cam_H[1] * pmcy + cam_H[2] * pmcz;
                vpmc = cam_V[0] * pmcx + cam_V[1] * pmcy + cam_V[2] * pmcz;
                x_im = hpmc / apmc;
                y_im = vpmc / apmc;
                
                /* Evaluate resolution */
                /* assumed to be constant */
                 
                mrgnh = coef_mrgn*hs/apmc * resol;
                mrgnv = coef_mrgn*vs/apmc * resol;
                
                if (x_im>srange[0]-mrgnh && x_im<srange[1]+mrgnh && 
                        y_im>lrange[0]-mrgnv && y_im<lrange[1]+mrgnv){
                    msldem_imFOVmask[c][l] = 4;
                }                
            } else {
                /* Evaluate */
                
                
            }

        }

    }
    free(cos_lon);
    free(sin_lon);
    
    /* safeguarding not implemented yet */
    
    
}

/* The gateway function */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
    double **msldem_img_radius;
    double *msldem_latitude;
    double *msldem_longitude;
    int8_T **msldem_imFOVmask;
    CAHV_MODEL cahv_mdl;
    double *srange, *lrange;
    
    double coef_mrgn;
    
    mwSize si,li;
    mwSize msldem_samples, msldem_lines;

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
    
    /* INPUT 0 msldem_imgpath */
    msldem_img_radius = set_mxDoubleMatrix(prhs[0]);
    msldem_lines = mxGetM(prhs[0]);
    msldem_samples = mxGetN(prhs[0]);
    
    
    /* INPUT 2/3 msldem northing easting */
    msldem_latitude = mxGetDoubles(prhs[1]);
    msldem_longitude = mxGetDoubles(prhs[2]);

    /* INPUT 4/5 image S_im, L_im */
    
    /* INPUT 6 camera model */
    cahv_mdl = mxGet_CAHV_MODEL(prhs[3]);
    
    /* INPUT 4/5 image S_im, L_im */
    srange = mxGetDoubles(prhs[4]);
    lrange = mxGetDoubles(prhs[5]);

    coef_mrgn = mxGetScalar(prhs[6]);

    /* OUTPUT 1 msldem imFOV */
    plhs[0] = mxCreateNumericMatrix(msldem_lines,msldem_samples,mxINT8_CLASS,mxREAL);
    msldem_imFOVmask = set_mxInt8Matrix(plhs[0]);
    
    // Initialize matrices
    for(si=0;si<msldem_samples;si++){
        for(li=0;li<msldem_lines;li++){
            msldem_imFOVmask[si][li] = 0;
        }
    }
    // printf("sim = %d\n",S_im);
    /* -----------------------------------------------------------------
     * CALL MAIN COMPUTATION ROUTINE
     * ----------------------------------------------------------------- */
    get_imFOVmask_MSLDEM(msldem_img_radius,
            (int32_T) msldem_lines, (int32_T) msldem_samples,
            msldem_latitude, msldem_longitude, 
            cahv_mdl,srange,lrange,
            msldem_imFOVmask,coef_mrgn);
    
    /* free memories */
    mxFree(msldem_img_radius);
    // mxFree(msldem_imFOVmask);
    mxFree(msldem_imFOVmask);
    
}
