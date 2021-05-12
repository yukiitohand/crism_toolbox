/* =====================================================================
 * crism_get_FOVap_mask_from_lList_crange_mex.c
 * Efficiently combine FOV ap 
 * 
 * INPUTS:
 * 0 msldemc_hdr           Struct
 * 1 lList_cofst           [msldemc_lines x 1]
 * 2 lList_cols            [msldemc_lines x 1]
 * 
 * OUTPUTS:
 * 0 msldemc_imFOVmask     [msldemc_lines x msldemc_samples]
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
#include <stdio.h>

#include <stdlib.h>
#include "mex_create_array.h"

/* main computation routine */
void crism_get_FOVap_mask_from_lList_crange(
        int32_t msldemc_samples, int32_t msldemc_lines,
        int32_t **lList_crange, int8_t **msldemc_imFOVmask)
{
    int32_t c,l,c0,cend;
    
    for(l=0;l<msldemc_lines;l++){
        c0 = lList_crange[l][0];
        cend = lList_crange[l][1];
        for(c=c0;c<cend;c++){
            msldemc_imFOVmask[c][l] = 1;
        }
    }
    
        
    
}

/* The gateway function */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
    mwSize msldemc_samples, msldemc_lines;
    int32_t *lList_cofst, *lList_cols;
    mwSize si,li;
    int8_t **msldemc_imFOVmask;

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
    
    /* INPUT 0 sample offset and line offset */
    //sample_offset   = (mwSize) mxGetScalar(mxGetField(prhs[0],0,"sample_offset"));
    //line_offset     = (mwSize) mxGetScalar(mxGetField(prhs[0],0,"line_offset"));
    msldemc_samples = (mwSize) mxGetScalar(mxGetField(prhs[0],0,"samples"));
    msldemc_lines   = (mwSize) mxGetScalar(mxGetField(prhs[0],0,"lines"));
    
    lList_cofst = mxGetInt32s(prhs[1]);
    lLIst_cols  = mxGetInt32s(prhs[2]);
    
    /* OUTPUT 0 lList_crange */
    plhs[0] = mxCreateNumericMatrix(msldemc_lines,msldemc_samples,mxINT8_CLASS,mxREAL);
    msldemc_imFOVmask = set_mxInt8Matrix(plhs[0]);
    
    
    
    
    // Initialize matrices
    for(si=0;si<msldemc_samples;si++){
        for(li=0;li<msldemc_lines;li++){
            msldemc_imFOVmask[si][li] = 0;
        }
    }
    
    
    // printf("sim = %d\n",S_im);
    /* -----------------------------------------------------------------
     * CALL MAIN COMPUTATION ROUTINE
     * ----------------------------------------------------------------- */
    
    crism_get_FOVap_mask_from_lList_crange(
        (int32_t) msldemc_samples, (int32_t) msldemc_lines,
        lList_crange,msldemc_imFOVmask);
    
    /* free memories */
    mxFree(msldemc_imFOVmask);
    
}