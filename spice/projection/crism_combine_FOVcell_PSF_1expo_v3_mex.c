/* =====================================================================
 * crism_combine_FOVcell_PSF_1expo_v3_mex.c
 * Combine FOV cells into one FOV for each pixel. Version 2 is 
 * 
 * INPUTS:
 * 0 crism_FOVcell_in     cell array [M x Ncrism]
 * 1 crismPxl_sofst_in    int32_t [M x Ncrism]
 * 2 crismPxl_smpls_in    int32_t [M x Ncrism]
 * 3 crismPxl_lofst_in    int32_t [M x Ncrism]
 * 4 crismPxl_lines_in    int32_t [M x Ncrism]
 *
 * Note: M is the number of divisions within one exposure 
 * 
 * OUTPUTS:
 * 0 crism_FOVcell_out    cell array [Ncrism]
 * 1 crismPxl_sofst_out   int32_t [1 x Ncrism]
 * 2 crismPxl_smpls_out   int32_t [1 x Ncrism]
 * 3 crismPxl_lofst_out   int32_t [1 x Ncrism]
 * 4 crismPxl_lmpls_out   int32_t [1 x Ncrism]
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


void crism_combine_1expo(const mxArray *crism_FOVcell_in,
        int32_t M, int32_t Ncrism,
        int32_t **crismPxl_sofst_in, int32_t **crismPxl_smpls_in,
        int32_t **crismPxl_lofst_in, int32_t **crismPxl_lines_in, 
        mxArray *crism_FOVcell_out,
        int32_t *crismPxl_sofst_out,int32_t *crismPxl_smpls_out,
        int32_t *crismPxl_lofst_out,int32_t *crismPxl_lines_out)
{
    int32_t xi,mi;
    int32_t **crismPxl_srngs, **crismPxl_lrngs;
    int32_t *crismPxl_srngs_base, *crismPxl_lrngs_base;
    double *pxlftprnt;
    double *pxlftprnt_m;
    int32_t s0, l0, send, lend, sz_c, sz_l;
    int32_t ss0, ll0, sz_cc, sz_ll;
    mwSize c,l;
    
    /* First determine the window size of the each pixel after combined */
    createInt32Matrix(&crismPxl_srngs,&crismPxl_srngs_base,(size_t) Ncrism, (size_t) 2);
    createInt32Matrix(&crismPxl_lrngs,&crismPxl_lrngs_base,(size_t) Ncrism, (size_t) 2);
    for(xi=0;xi<Ncrism;xi++){
        /* Initialization */
        crismPxl_srngs[xi][0] = 2147483647;
        crismPxl_lrngs[xi][0] = 2147483647;
        crismPxl_srngs[xi][1] = -1;
        crismPxl_lrngs[xi][1] = -1;
        for(mi=0;mi<M;mi++){
            s0   = crismPxl_sofst_in[xi][mi];
            send = s0 + crismPxl_smpls_in[xi][mi];
            l0   = crismPxl_lofst_in[xi][mi];
            lend = l0 + crismPxl_lines_in[xi][mi];
            if(s0<crismPxl_srngs[xi][0]){
                crismPxl_srngs[xi][0] = s0;
            }
            if(send>crismPxl_srngs[xi][1]){
                crismPxl_srngs[xi][1] = send;
            }
            if(l0<crismPxl_lrngs[xi][0]){
                crismPxl_lrngs[xi][0] = l0;
            }
            if(lend>crismPxl_lrngs[xi][1]){
                crismPxl_lrngs[xi][1] = lend;
            }
            
        }
    }
    
    /* Second, add up the value in the combined window for each pixel */
    for(xi=0;xi<Ncrism;xi++){
        s0 = crismPxl_srngs[xi][0]; send = crismPxl_srngs[xi][1];
        l0 = crismPxl_lrngs[xi][0]; lend = crismPxl_lrngs[xi][1];
        sz_c = send - s0;
        sz_l = lend - l0;
        crismPxl_sofst_out[xi] = s0; crismPxl_smpls_out[xi] = sz_c;
        crismPxl_lofst_out[xi] = l0; crismPxl_lines_out[xi] = sz_l;
        mxSetCell(crism_FOVcell_out,(mwIndex) xi,
                  mxCreateDoubleMatrix(sz_l,sz_c,mxREAL));
        pxlftprnt = mxGetDoubles(mxGetCell(crism_FOVcell_out,(mwIndex) xi));
        
        for(mi=0;mi<M;mi++){
            // printf("mi=%d\n",mi);
            pxlftprnt_m = mxGetDoubles(mxGetCell(crism_FOVcell_in,(mwIndex) (xi*M+mi) ));
            if(pxlftprnt_m){
                ss0   = crismPxl_sofst_in[xi][mi] - s0;
                ll0   = crismPxl_lofst_in[xi][mi] - l0; 
                sz_cc = crismPxl_smpls_in[xi][mi];
                sz_ll = crismPxl_lines_in[xi][mi];
                for(c=0;c<sz_cc;c++){
                    for(l=0;l<sz_ll;l++){
                       pxlftprnt[(c+ss0)*sz_l+(l+ll0)] += pxlftprnt_m[c*sz_ll+l];
                    }
                }
            }
        }
    }
    
    
    free(crismPxl_srngs);
    free(crismPxl_srngs_base);
    free(crismPxl_lrngs);
    free(crismPxl_lrngs_base);
    
}

/* The gateway function */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
    const mxArray *crism_FOVcell_in;
    mxArray *crism_FOVcell_out;
    int32_t **crismPxl_sofst_in,**crismPxl_smpls_in;
    int32_t **crismPxl_lofst_in,**crismPxl_lines_in;
    int32_t *crismPxl_sofst_out, *crismPxl_smpls_out;
    int32_t *crismPxl_lofst_out, *crismPxl_lines_out;
    mwSize Ncrism,M;
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
    
    /* INPUT 0 crism_FOVcell_in */
    crism_FOVcell_in = prhs[0];
    Ncrism = mxGetN(prhs[0]);
    M = mxGetM(prhs[0]);
    
    /* INPUT 1/2/3/4 crism input pixel offset and #  matrix */
    crismPxl_sofst_in = set_mxInt32Matrix(prhs[1]);
    crismPxl_smpls_in = set_mxInt32Matrix(prhs[2]);
    crismPxl_lofst_in = set_mxInt32Matrix(prhs[3]);
    crismPxl_lines_in = set_mxInt32Matrix(prhs[4]);
    
    /* OUTPUT 0 */
    sz_FOVcell[0] = 1;
    sz_FOVcell[1] = Ncrism;
    crism_FOVcell_out = mxCreateCellArray(2,sz_FOVcell);
    plhs[0] = crism_FOVcell_out;
    
    plhs[1] = mxCreateNumericArray(2,sz_FOVcell,mxINT32_CLASS,mxREAL);
    crismPxl_sofst_out = mxGetInt32s(plhs[1]);
    plhs[2] = mxCreateNumericArray(2,sz_FOVcell,mxINT32_CLASS,mxREAL);
    crismPxl_smpls_out = mxGetInt32s(plhs[2]);
    plhs[3] = mxCreateNumericArray(2,sz_FOVcell,mxINT32_CLASS,mxREAL);
    crismPxl_lofst_out = mxGetInt32s(plhs[3]);
    plhs[4] = mxCreateNumericArray(2,sz_FOVcell,mxINT32_CLASS,mxREAL);
    crismPxl_lines_out = mxGetInt32s(plhs[4]);
    
    
    
    

    
    crism_combine_1expo(crism_FOVcell_in, (int32_t) M, (int32_t) Ncrism,
            crismPxl_sofst_in, crismPxl_smpls_in,
            crismPxl_lofst_in, crismPxl_lines_in, 
            crism_FOVcell_out,
            crismPxl_sofst_out, crismPxl_smpls_out,
            crismPxl_lofst_out, crismPxl_lines_out);
    
    
    /* free memories */
    mxFree(crismPxl_sofst_in);
    mxFree(crismPxl_smpls_in);
    mxFree(crismPxl_lofst_in);
    mxFree(crismPxl_lines_in);
    
    
}

