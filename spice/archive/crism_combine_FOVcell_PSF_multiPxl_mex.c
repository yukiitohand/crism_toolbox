/* =====================================================================
 * crism_combine_FOVcell_PSF_multiPxl_mex.c
 * Evaluate if pixels in the MSL DEM image are potentially in 
 * 
 * INPUTS:
 * 0 crism_FOVcell_in     cell array    [L x Ncrism]
 * 1 crismPxl_srngs_in    valid samples [(2*L) x Ncrism]
 * 2 crismPxl_lrngs_in    valid lines   [(2*L) x Ncrism]
 * 3 msldemc_hdr          struct
 *
 * Note: L is the number of lines.
 * 
 * OUTPUTS:
 * 0 msldemc_imFOVcount  : double [msldemc_lines x msldemc_samples]
 * 1 msldemc_imFOVsample : int16 [msldemc_lines x msldemc_samples]
 * 2 msldemc_imFOVline   : int16 [msldemc_lines x msldemc_samples]
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

/* The gateway function */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
    const mxArray *crism_FOVcell_in;
    int32_t **crismPxl_srngs_in,**crismPxl_lrngs_in;
    mwSize Ncrism,L;
    mwSize sz_FOVcell[2];
    mwSize msldemc_samples, msldemc_lines;
    mwSize sample_offset, line_offset;
    
    double **msldemc_imFOVcount;
    int16_t **msldemc_imFOVsample, **msldemc_imFOVline;
    
    double *pxlftprnt_xiyi;
    mwSize xi,yi, s0, l0, send, lend, sz_c, sz_l;
    mwSize c,l;

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
    
    /* INPUT 0 crism_FOVcell_in */
    crism_FOVcell_in = prhs[0];
    Ncrism = mxGetN(prhs[0]);
    L = mxGetM(prhs[0]);
    
    /* INPUT 1/2 crismPxl_srngs_in crismPxl_lrngs_in */
    crismPxl_srngs_in = set_mxInt32Matrix(prhs[1]);
    crismPxl_lrngs_in = set_mxInt32Matrix(prhs[2]);
    
    /* INPUT 3/4 crismPxl_srngs_out crismPxl_lrngs_out */
    sample_offset = (mwSize) mxGetScalar(mxGetField(prhs[3],0,"sample_offset"));
    line_offset   = (mwSize) mxGetScalar(mxGetField(prhs[3],0,"line_offset"));
    msldemc_samples = (mwSize) mxGetScalar(mxGetField(prhs[3],0,"samples"));
    msldemc_lines   = (mwSize) mxGetScalar(mxGetField(prhs[3],0,"lines"));
    
    /* OUTPUT 0 */
    plhs[0] = mxCreateDoubleMatrix(msldemc_lines,msldemc_samples,mxREAL);
    msldemc_imFOVcount = set_mxDoubleMatrix(plhs[0]);
    
    plhs[1] = mxCreateNumericMatrix(msldemc_lines,msldemc_samples,mxINT16_CLASS,mxREAL);
    msldemc_imFOVsample = set_mxInt16Matrix(plhs[1]);
    
    plhs[2] = mxCreateNumericMatrix(msldemc_lines,msldemc_samples,mxINT16_CLASS,mxREAL);
    msldemc_imFOVline = set_mxInt16Matrix(plhs[2]);
    
    for(c=0;c<msldemc_samples;c++){
        for(l=0;l<msldemc_lines;l++){
            msldemc_imFOVcount[c][l]  =  0;
            msldemc_imFOVsample[c][l] = -1;
            msldemc_imFOVline[c][l]   = -1;
        }
    }
    
    for(yi=0;yi<L;yi++){
        for(xi=0;xi<Ncrism;xi++){
            s0   = crismPxl_srngs_in[xi][2*yi]  ;
            send = crismPxl_srngs_in[xi][2*yi+1] + 1;
            l0   = crismPxl_lrngs_in[xi][2*yi]  ; 
            lend = crismPxl_lrngs_in[xi][2*yi+1] + 1;
            sz_c = send - s0;
            sz_l = lend - l0;
            
            pxlftprnt_xiyi = mxGetDoubles(mxGetCell(crism_FOVcell_in,(mwIndex) (xi*L+yi) ));
            if(pxlftprnt_xiyi != NULL){
                for(c=0;c<sz_c;c++){
                    for(l=0;l<sz_l;l++){
                        if(pxlftprnt_xiyi[c*sz_l+l] > msldemc_imFOVcount[c+s0][l+l0]){
                           msldemc_imFOVcount[c+s0][l+l0]  = pxlftprnt_xiyi[c*sz_l+l];
                           msldemc_imFOVsample[c+s0][l+l0] = (int16_t) xi;
                           msldemc_imFOVline[c+s0][l+l0]   = (int16_t) yi;
                        }
                    }
                }
            }
        }
    }
    
    
    
    
    /* free memories */
    mxFree(crismPxl_srngs_in);
    mxFree(crismPxl_lrngs_in);
    mxFree(msldemc_imFOVcount);
    mxFree(msldemc_imFOVsample);
    mxFree(msldemc_imFOVline);
    
    
}

