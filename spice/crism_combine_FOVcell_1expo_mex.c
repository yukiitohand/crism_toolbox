/* =====================================================================
 * crism_combine_FOVcell_1expo_mex.c
 * Evaluate if pixels in the MSL DEM image are potentially in 
 * 
 * INPUTS:
 * 0 crism_FOVcell_in     cell array [M x Ncrism]
 * 1 crismPxl_srngs_in    valid samples [(2*M) x Ncrism]
 * 2 crismPxl_lrngs_in    valid lines   [(2*M) x Ncrism]
 * 3 crismPxl_srngs_out   valid samples [2 x Ncrism]
 * 4 crismPxl_lrngs_out   valid lines   [2 x Ncrism]
 *
 * Note: M is the number of divisions within one exposure 
 * 
 * OUTPUTS:
 * 0 crism_FOVcell_out    cell array [Ncrism]

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
    mxArray *crism_FOVcell_out;
    int32_t **crismPxl_srngs_in,**crismPxl_lrngs_in;
    int32_t **crismPxl_srngs_out,**crismPxl_lrngs_out;
    mwSize Ncrism,M;
    mwSize sz_FOVcell[2];
    
    int8_t *pxlftprnt;
    int8_t *pxlftprnt_m;
    mwSize xi, s0, l0, send, lend, sz_c, sz_l;
    mwSize mi, ss0, ll0, ssend, llend, sz_cc, sz_ll;
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
    M = mxGetM(prhs[0]);
    
    /* INPUT 1/2 crismPxl_srngs_in crismPxl_lrngs_in */
    crismPxl_srngs_in = set_mxInt32Matrix(prhs[1]);
    crismPxl_lrngs_in = set_mxInt32Matrix(prhs[2]);
    
    /* INPUT 3/4 crismPxl_srngs_out crismPxl_lrngs_out */
    crismPxl_srngs_out = set_mxInt32Matrix(prhs[3]);
    crismPxl_lrngs_out = set_mxInt32Matrix(prhs[4]);
    
    /* OUTPUT 0 */
    sz_FOVcell[0] = 1;
    sz_FOVcell[1] = Ncrism;
    crism_FOVcell_out = mxCreateCellArray(2,sz_FOVcell);
    plhs[0] = crism_FOVcell_out;
    for(xi=0;xi<Ncrism;xi++){
        s0 = crismPxl_srngs_out[xi][0]; send = crismPxl_srngs_out[xi][1]+1;
        l0 = crismPxl_lrngs_out[xi][0]; lend = crismPxl_lrngs_out[xi][1]+1;
        sz_c = send - s0;
        sz_l = lend - l0;
        mxSetCell(crism_FOVcell_out,(mwIndex) xi,
                  mxCreateNumericMatrix(sz_l,sz_c, mxINT8_CLASS,mxREAL));
        pxlftprnt = mxGetInt8s(mxGetCell(crism_FOVcell_out,(mwIndex) xi));
        for(mi=0;mi<M;mi++){
            // printf("mi=%d\n",mi);
            pxlftprnt_m = mxGetInt8s(mxGetCell(crism_FOVcell_in,(mwIndex) (xi*M+mi) ));
            ss0   = crismPxl_srngs_in[xi][2*mi]   - s0;
            ssend = crismPxl_srngs_in[xi][2*mi+1] - s0 + 1;
            ll0   = crismPxl_lrngs_in[xi][2*mi]   - l0; 
            llend = crismPxl_lrngs_in[xi][2*mi+1] - l0 + 1;
            sz_cc = ssend - ss0;
            sz_ll = llend - ll0;
            for(c=0;c<sz_cc;c++){
                for(l=0;l<sz_ll;l++){
                    if(pxlftprnt_m[c*sz_ll+l]){
                       pxlftprnt[(c+ss0)*sz_l+(l+ll0)]++;
                    }
                }
            }
        }
    }
    
    
    
    
    /* free memories */
    mxFree(crismPxl_srngs_out);
    mxFree(crismPxl_lrngs_out);
    
    
}

