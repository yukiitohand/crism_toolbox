/* =====================================================================
 * crism_gale_get_msldemFOVcell.c
 * Evaluate if pixels in the MSL DEM image are potentially in 
 * 
 * INPUTS:
 * 0 msldem_radius         Double array [msldem_lines x msldem_samples]
 * 1 msldem_latitude       Double array [msldem_lines]
 * 2 msldem_longitude      Double array [msldem_samples]
 * 3 cahv_mdl              CAHV_MODEL
 * 4 msldemc_imFOVmask     int8 [L_dem x S_dem]
 *    5: inside the FOV (srange[0]<x<srange[1] && lrange[0]<y<lrange[1])
 *    4: tightest margin of the FOV (any of 8 neighbors is marked as 5)
 *    0: outside FOV
 *   -1: invalid dem value
 * 5 pmc_brd               Double array [3 x (Ncrism+1)]
 *
 * OUTPUTS
 * 0 crism_FOVcell        cell array [Ncrism]
 * 1 vls                  valid samples [2 x Ncrism]
 * 2 vlj                  valid lines   [2 x Ncrism]
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
void get_imFOVmask_MSLDEM_scf(double **msldem_img_radius, int32_T msldem_lines,
        int32_T msldem_samples,
        double *msldem_latitude, double *msldem_longitude, 
        CAHV_MODEL cahv_mdl, double *srange, double *lrange,
        int8_T **msldem_imFOVmask)
{
    int32_t c,l,cc,ll;
    double *cos_lon, *sin_lon;
    double cos_latl, sin_latl, cos_lonc, sin_lonc;
    double radius;
    double x_iaumars, y_iaumars, z_iaumars;
    double pmcx, pmcy, pmcz;
    double apmc, hpmc, vpmc;
    double x_im, y_im;
    double *cam_C, *cam_A, *cam_H, *cam_V, *cam_Hd, *cam_Vd;
    double hc,vc,hs,vs;
    
    int32_t lList_exist[2];
    int32_t *lList_crange;
    int32_t l_min,l_max,c_min,c_max;
    
    cam_C = cahv_mdl.C; cam_A = cahv_mdl.A; cam_H = cahv_mdl.H; cam_V = cahv_mdl.V;
    hs = cahv_mdl.hs; vs = cahv_mdl.vs; hc = cahv_mdl.hc; vc = cahv_mdl.vc;
    cam_Hd = cahv_mdl.Hdash; cam_Vd = cahv_mdl.Vdash;
    
    cos_lon = (double*) malloc(sizeof(double) * (size_t) msldem_samples);
    sin_lon = (double*) malloc(sizeof(double) * (size_t) msldem_samples);
    for(c=0;c<msldem_samples;c++){
        cos_lon[c] = cos(msldem_longitude[c]);
        sin_lon[c] = sin(msldem_longitude[c]);
    }
    
    lList_exist[0] = -1; lList_exist[1] = -1;
    lList_crange = (int32_t*) malloc(sizeof(int32_t)* (size_t) msldem_lines * 2);
    for(l=0;l<msldem_lines;l++){
        lList_crange[2*l] = -1;
        lList_crange[2*l+1] = -1;
    }
    
    
    // printf("%d,%d,%d\n",skip_l,msldemc_samples*s,skip_r);
    for(l=0;l<msldem_lines;l++){
        // printf("l=%d \n",l);
        cos_latl = cos(msldem_latitude[l]);
        sin_latl = sin(msldem_latitude[l]);
        c_min = -1; c_max = -1;
        for(c=0;c<msldem_samples;c++){
            /* transform radius-lat-lon to IAU_MARS XYZ */
            cos_lonc  = cos_lon[c];
            sin_lonc  = sin_lon[c];
            radius    = msldem_img_radius[c][l];
            if(isnan(radius)){
                msldem_imFOVmask[c][l] = -1;
            } else {
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

                    if (x_im>srange[0] && x_im<srange[1] && 
                            y_im>lrange[0] && y_im<lrange[1]){
                        msldem_imFOVmask[c][l] = 5;
                        if(c_min==-1)
                            c_min = c;
                        c_max = c;
                    }
                } else {
                    /* Evaluate */


                }
            }

        }
        c_max = c_max+1;
        lList_crange[2*l] = c_min; lList_crange[2*l+1] = c_max;
        if(c_min>-1){
            if(lList_exist[0]==-1)
                lList_exist[0] = l;
            lList_exist[1] = l;
        }

    }
    free(cos_lon);
    free(sin_lon);
    
    lList_exist[1] = lList_exist[1] + 1;
    /* Last step: complementation of the surroundings */
    /* This step is costly, since it is performed on the whole image 
     * can be speeded up in a more elaborated way. */
    if(lList_exist[0]>-1){
        for(l=lList_exist[0];l<lList_exist[1];l++){
            if(lList_crange[2*l]>-1){
                l_min = (l-1>0) ? (l-1) : 0;
                l_max = (l+2<msldem_lines) ? (l+2) : msldem_lines;
                for(c=lList_crange[2*l];c<lList_crange[2*l+1];c++){
                    if(msldem_imFOVmask[c][l]==5){
                        c_min = (c-1>0) ? (c-1) : 0;
                        c_max = (c+2<msldem_samples) ? (c+2) : msldem_samples;
                        for(cc=c_min;cc<c_max;cc++){
                            for(ll=l_min;ll<l_max;ll++){
                                if(msldem_imFOVmask[cc][ll]==0)
                                    // || msldem_imFOVmask[cc][ll]==2 || msldem_imFOVmask[cc][ll]==3) 
                                    msldem_imFOVmask[cc][ll] = 4;
                            }
                        }
                    }
                }
            }
        }
    }
    free(lList_crange);
    
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
    
    /* INPUT 6 camera model */
    cahv_mdl = mxGet_CAHV_MODEL(prhs[3]);
    
    /* INPUT 4/5 image srange, lrange */
    msldem_imFOVmask = set_mxInt8Matrix(prhs[4]);
    
    

    /* OUTPUT 1 msldem imFOV */
    plhs[0] = 
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
    get_imFOVmask_MSLDEM_scf(msldem_img_radius,
            (int32_T) msldem_lines, (int32_T) msldem_samples,
            msldem_latitude, msldem_longitude, 
            cahv_mdl,srange,lrange,
            msldem_imFOVmask);
    
    /* free memories */
    mxFree(msldem_img_radius);
    // mxFree(msldem_imFOVmask);
    mxFree(msldem_imFOVmask);
    
}

