/* =====================================================================
 * crism_combine_FOVap_mex.c
 * Efficiently combine FOV ap
 * 
 * INPUTS:
 * 0 msldemc_hdr           Struct
 * 1 crismPxl_smplofst_ap  int32 array  [1 x (Ncrism)]
 * 2 crismPxl_smpls_ap     int32 array  [1 x (Ncrism)]
 * 3 crismPxl_lineofst_ap  int32 array  [1 x (Ncrism)]
 * 4 crismPxl_lines_ap     int32 array  [1 x (Ncrism)]
 * The indices of crismPxl_srngs_ap and crismPxl_lrngs_ap are based on the 
 * subimage defined by msldemc_hdr, meaning offsets are not included.
 * 
 * OUTPUTS:
 * 0 lList_cofst           int32 array [1 x msldemc_lines]
 * 1 lList_cols            int32 array [1 x msldemc_lines]
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
void crism_combine_FOVap(
        int32_t msldemc_samples, int32_t msldemc_lines,
        int32_t msldemc_sample_offset, int32_t msldemc_line_offset,
        int32_t *crismPxl_smplofst_ap, int32_t *crismPxl_smpls_ap,
        int32_t *crismPxl_lineofst_ap, int32_t *crismPxl_lines_ap,
        int32_t Ncrism, int32_t *lList_cofst, int32_t *lList_cols)
{
    int32_t c,l,c0,cend,l0,lend;
    int32_t xi;
    int32_t *lList_c0;
    int32_t *lList_cend;
    
    lList_c0   = (int32_t*) malloc(sizeof(int32_t) * ((size_t) msldemc_lines));
    lList_cend = (int32_t*) malloc(sizeof(int32_t) * ((size_t) msldemc_lines));
    
    for(l=0;l<msldemc_lines;l++){
        lList_c0[l]   = -1;
        lList_cend[l] = -1;
    }
    
    for(xi=0;xi<Ncrism;xi++){
        l0   = crismPxl_lineofst_ap[xi];
        lend = l0 + crismPxl_lines_ap[xi];
        c0   = crismPxl_smplofst_ap[xi];
        cend = c0 + crismPxl_smpls_ap[xi];
        if(l0<0){
            l0=0;
        }
        if(lend>msldemc_lines){
            lend=msldemc_lines;
        }
        for(l=l0;l<lend;l++){
            if(lList_c0[l]==-1){
                lList_c0[l]   = c0;
                lList_cend[l] = cend;
            } else {
                if(c0<lList_c0[l]){
                    lList_c0[l] = c0;
                }
                if(cend>lList_cend[l]){
                    lList_cend[l] = cend;
                }
            }
        }
    }
    
    /* Convert lList_c0 and lList_cend to lList_cofst and lList_cols */
    for(l=0;l<msldemc_lines;l++){
        lList_cofst[l] = lList_c0[l];
        lList_cols[l]  = lList_cend[l] - lList_c0[l];
    }
    
    free(lList_c0); free(lList_cend);
    
        
    
}

/* The gateway function */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
    mwSize msldemc_samples, msldemc_lines;
    mwSize msldemc_sample_offset, msldemc_line_offset;
    int32_t *crismPxl_smplofst_ap, *crismPxl_smpls_ap;
    int32_t *crismPxl_lineofst_ap, *crismPxl_lines_ap;
    int32_t *lList_cofst, *lList_cols;
    mwSize li,Ncrism;
    

    /* -----------------------------------------------------------------
     * CHECK PROPER NUMBER OF INPUTS AND OUTPUTS
     * ----------------------------------------------------------------- */
    if(nrhs!=5) {
        mexErrMsgIdAndTxt("crism_combine_FOVap_mex:nrhs","5 inputs required.");
    }
    if(nlhs!=2) {
        mexErrMsgIdAndTxt("crism_combine_FOVap_mex:nlhs","2 outputs required.");
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
    
    /* INPUT 0 sample offset and line offset */
    msldemc_sample_offset = (mwSize) mxGetScalar(mxGetField(prhs[0],0,"sample_offset"));
    msldemc_line_offset   = (mwSize) mxGetScalar(mxGetField(prhs[0],0,"line_offset"));
    msldemc_samples = (mwSize) mxGetScalar(mxGetField(prhs[0],0,"samples"));
    msldemc_lines   = (mwSize) mxGetScalar(mxGetField(prhs[0],0,"lines"));
    
    
    crismPxl_smplofst_ap = mxGetInt32s(prhs[1]);
    crismPxl_smpls_ap    = mxGetInt32s(prhs[2]);
    crismPxl_lineofst_ap = mxGetInt32s(prhs[3]);
    crismPxl_lines_ap    = mxGetInt32s(prhs[4]);
    Ncrism = mxGetNumberOfElements(prhs[1]);
    
    /* OUTPUT 0 lList_crange */
    plhs[0] = mxCreateNumericArray(1,&msldemc_lines,mxINT32_CLASS,mxREAL);
    lList_cofst = mxGetInt32s(plhs[0]);
    
    plhs[1] = mxCreateNumericArray(1,&msldemc_lines,mxINT32_CLASS,mxREAL);
    lList_cols = mxGetInt32s(plhs[1]);
    
    
    
    // Initialize output variables
    // for(li=0;li<msldemc_lines;li++){
    //     lList_cofst[li] = -1;
    //     lList_cols[li]  = -1;
    // }
    
    
    // printf("sim = %d\n",S_im);
    /* -----------------------------------------------------------------
     * CALL MAIN COMPUTATION ROUTINE
     * ----------------------------------------------------------------- */
    
    crism_combine_FOVap(
        (int32_t) msldemc_samples, (int32_t) msldemc_lines,
        (int32_t) msldemc_sample_offset, (int32_t) msldemc_line_offset,
        crismPxl_smplofst_ap, crismPxl_smpls_ap,
        crismPxl_lineofst_ap, crismPxl_lines_ap,
        (int32_t) Ncrism, lList_cofst,lList_cols);
    
    /* free memories */
    
}

