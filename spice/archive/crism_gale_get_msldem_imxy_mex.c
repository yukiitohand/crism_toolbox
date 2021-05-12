/* =====================================================================
 * crism_gale_get_msldem_imxy_mex.c
 * Evaluate if pixels in the MSL DEM image are potentially in 
 * 
 * INPUTS:
 * 0 msldem_radius         Double array [msldem_lines x msldem_samples]
 * 1 msldem_latitude       Double array [msldem_lines]
 * 2 msldem_longitude      Double array [msldem_samples]
 * 3 cahv_mdl              CAHV_MODEL
 * 4 srange
 * 5 lrange
 * 
 * 
 * OUTPUTS:
 * 0 msldemc_imx    double [L_dem x S_dem]
 * 1 msldemc_imy    double [L_dem x S_dem]
 * 2 msldemc_imx_int int16 [L_dem x S_dem]
 * 3 msldemc_imy_int int16 [L_dem x S_dem] 
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
void get_imxy_MSLDEM(double **msldem_img_radius, int32_T msldem_lines,
        int32_T msldem_samples,
        double *msldem_latitude, double *msldem_longitude, 
        CAHV_MODEL cahv_mdl, double **crism_PmCbrd, int32_t Npmcb,
        double **msldem_imx, double **msldem_imy, 
        int16_t **msldem_imx_int, int16_t **msldem_imy_int)
{
    int32_T c,l;
    int16_t xi;
    double *cos_lon, *sin_lon;
    double cos_latl, sin_latl, cos_lonc, sin_lonc;
    double radius;
    double x_iaumars, y_iaumars, z_iaumars;
    double pmcx, pmcy, pmcz;
    double apmc, hpmc, vpmc;
    double x_im, y_im;
    double *cam_C, *cam_A, *cam_H, *cam_V, *cam_Hd, *cam_Vd;
    double hc,vc,hs,vs;
    double **PmCbrd_imxyap;
    double *PmCbrd_imxyap_base;
    
    cam_C = cahv_mdl.C; cam_A = cahv_mdl.A; cam_H = cahv_mdl.H; cam_V = cahv_mdl.V;
    hs = cahv_mdl.hs; vs = cahv_mdl.vs; hc = cahv_mdl.hc; vc = cahv_mdl.vc;
    cam_Hd = cahv_mdl.Hdash; cam_Vd = cahv_mdl.Vdash;
    
    /*********************************************************************/
    createDoubleMatrix(&PmCbrd_imxyap, &PmCbrd_imxyap_base, 
            (size_t) Npmcb, (size_t) 2);
    for(xi=0;xi<Npmcb;xi++){
        pmcx = crism_PmCbrd[xi][0];
        pmcy = crism_PmCbrd[xi][1];
        pmcz = crism_PmCbrd[xi][2];
        apmc = cam_A[0]*pmcx + cam_A[1]*pmcy + cam_A[2]*pmcz;
        hpmc = cam_H[0]*pmcx + cam_H[1]*pmcy + cam_H[2]*pmcz;
        vpmc = cam_V[0]*pmcx + cam_V[1]*pmcy + cam_V[2]*pmcz;
        PmCbrd_imxyap[xi][0] = hpmc/apmc;
        PmCbrd_imxyap[xi][1] = vpmc/apmc;
    }
    
    /*********************************************************************/
    cos_lon = (double*) malloc(sizeof(double) * (size_t) msldem_samples);
    sin_lon = (double*) malloc(sizeof(double) * (size_t) msldem_samples);
    for(c=0;c<msldem_samples;c++){
        cos_lon[c] = cos(msldem_longitude[c]);
        sin_lon[c] = sin(msldem_longitude[c]);
    }
    
    // printf("%d,%d,%d\n",skip_l,msldemc_samples*s,skip_r);
    for(l=0;l<msldem_lines;l++){
        // printf("l=%d \n",l);
        cos_latl = cos(msldem_latitude[l]);
        sin_latl = sin(msldem_latitude[l]);
        // printf("l=%d\n",l);
        for(c=0;c<msldem_samples;c++){
            /* transform radius-lat-lon to IAU_MARS XYZ */
            // printf("c=%d\n",c);
            cos_lonc  = cos_lon[c];
            sin_lonc  = sin_lon[c];
            // printf("c=%d\n",c);
            radius    = msldem_img_radius[c][l];
            // printf("c=%d\n",c);
            x_iaumars = radius * cos_latl * cos_lonc;
            y_iaumars = radius * cos_latl * sin_lonc;
            z_iaumars = radius * sin_latl;
            
            pmcx = x_iaumars - cam_C[0];
            pmcy = y_iaumars - cam_C[1];
            pmcz = z_iaumars - cam_C[2];
            // printf("c=%d\n",c);
            apmc = cam_A[0] * pmcx + cam_A[1] * pmcy + cam_A[2] * pmcz;

            if(apmc>0){
                hpmc = cam_H[0] * pmcx + cam_H[1] * pmcy + cam_H[2] * pmcz;
                vpmc = cam_V[0] * pmcx + cam_V[1] * pmcy + cam_V[2] * pmcz;
                x_im = hpmc / apmc;
                y_im = vpmc / apmc;
                
                
                if(y_im>-0.5 && y_im<0.5 
                        && x_im>PmCbrd_imxyap[0][0] 
                        && x_im<PmCbrd_imxyap[Npmcb-1][0]){
                    xi=0;
                    while( x_im>PmCbrd_imxyap[xi][0] ){
                        xi++;
                    }
                    msldem_imx_int[c][l] = xi-1;
                    msldem_imy_int[c][l] = 0;
                }
                msldem_imx[c][l] = x_im;
                msldem_imy[c][l] = y_im;
                              
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
    double **msldem_imx, **msldem_imy;
    int16_T **msldem_imx_int, **msldem_imy_int;
    CAHV_MODEL cahv_mdl;
    double **pmc_brd;
    mwSize Npmcb;
    
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
    msldem_lines      = mxGetM(prhs[0]);
    msldem_samples    = mxGetN(prhs[0]);
    
    
    /* INPUT 1/2 msldem northing easting */
    msldem_latitude  = mxGetDoubles(prhs[1]);
    msldem_longitude = mxGetDoubles(prhs[2]);
    
    /* INPUT 3 camera model */
    cahv_mdl = mxGet_CAHV_MODEL(prhs[3]);
    
    /* INPUT 4 pmc_borders */
    pmc_brd = set_mxDoubleMatrix(prhs[4]);
    Npmcb   = mxGetN(prhs[4]);
    

    /* OUTPUT 1 msldem imFOV */
    plhs[0] = mxCreateDoubleMatrix(msldem_lines,msldem_samples,mxREAL);
    msldem_imx = set_mxDoubleMatrix(plhs[0]);
    
    plhs[1] = mxCreateDoubleMatrix(msldem_lines,msldem_samples,mxREAL);
    msldem_imy = set_mxDoubleMatrix(plhs[1]);
    
    plhs[2] = mxCreateNumericMatrix(msldem_lines,msldem_samples,mxINT16_CLASS,mxREAL);
    msldem_imx_int = set_mxInt16Matrix(plhs[2]);
    
    plhs[3] = mxCreateNumericMatrix(msldem_lines,msldem_samples,mxINT16_CLASS,mxREAL);
    msldem_imy_int = set_mxInt16Matrix(plhs[3]);
    
    // Initialize matrices
    for(si=0;si<msldem_samples;si++){
        for(li=0;li<msldem_lines;li++){
            msldem_imx[si][li] = NAN;
            msldem_imy[si][li] = NAN;
            msldem_imx_int[si][li] = -1;
            msldem_imy_int[si][li] = -1;
        }
    }
    
    /* -----------------------------------------------------------------
     * CALL MAIN COMPUTATION ROUTINE
     * ----------------------------------------------------------------- */
    get_imxy_MSLDEM(msldem_img_radius,
            (int32_T) msldem_lines, (int32_T) msldem_samples,
            msldem_latitude, msldem_longitude, 
            cahv_mdl, pmc_brd, (int32_t) Npmcb,
            msldem_imx, msldem_imy,msldem_imx_int,msldem_imy_int);
    
    /* free memories */
    mxFree(msldem_img_radius);
    mxFree(msldem_imx);
    mxFree(msldem_imy);
    mxFree(msldem_imx_int);
    mxFree(msldem_imy_int);
    mxFree(pmc_brd);
    
}