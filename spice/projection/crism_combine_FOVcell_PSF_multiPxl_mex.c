/* =====================================================================
 * crism_combine_FOVcell_PSF_multiPxl_mex.c
 * Combine the FOVcells of the lines given by the user. The range of lines 
 * are specified by two variables line_offset and Nl. Nl is the number of 
 * lines. It will read lines 
 * [line_offset, line_offset+1, ..., line_offset+Nl-1]
 * 
 * INPUTS:
 * 0 basename_com_crism_FOVcell char*
 * 1 dirpath_crism_FOVcell      char* 
 * 2 line_offset       int32 scalar,
 * 3 Nlines            int32 scalar, number of lines
 * 4 crismPxl_sofstc   int32 [L x Ncrism]
 * 5 crismPxl_smplsc   int32 [L x Ncrism]
 * 6 crismPxl_lofst    int32 [L x Ncrism]
 * 7 crismPxl_lines    int32 [L x Ncrism]
 * 8 msldemc_hdr       struct 
 *
 * Note: crismPxl_sofstc and crismPxl_lofstc are the offset based on the 
 *  cropped image (msldemc_hdr)
 * 
 * OUTPUTS:
 * 0 msldemc_imFOVres    : double [msldemc_lines x msldemc_samples]
 * 1 msldemc_imFOVsample : int16  [msldemc_lines x msldemc_samples]
 * 2 msldemc_imFOVline   : int16  [msldemc_lines x msldemc_samples]
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
#include "msldem_util.h"
#include "mat.h"
#include "mex.h"

/* main computation routine */
void combine_FOVcell_PSF_multiPxl(
        char *dirpath_crism_FOVcell, char *basename_com_crism_FOVcell,
        int32_t line_offset, int32_t Nlines,
        int32_t **crismPxl_sofstc, int32_t **crismPxl_lofstc,
        int32_t **crismPxl_smpls, int32_t **crismPxl_lines,
        float **msldemc_imFOVres, 
        int16_t **msldemc_imFOVsample,int16_t **msldemc_imFOVline)
{
    int16_t l,lend;
    int16_t  xi, Ncrism;
    int32_t ss,ll;
    int32_t smpls_lxi,lines_lxi,sofst_lxi,lofst_lxi;
    char *filepath;
    MATFile *pmat;
    mxArray *crism_FOVcell_lcomb;
    float *pff_lxi;
    float pff_lxi_ssll;
    int32_t s_msldemc, l_msldemc;
    
    filepath = malloc(sizeof(char)*(strlen(dirpath_crism_FOVcell)+strlen(basename_com_crism_FOVcell)+12));
    lend = line_offset+Nlines;
    // printf("a\n");
    for(l=line_offset;l<lend;l++){
        // printf("l=%d\n",l);
        /* Load MAT file and variable crism_FOVcell_lcomb */
        sprintf(filepath,"%s/%s_l%03d.mat",dirpath_crism_FOVcell,
                basename_com_crism_FOVcell,l+1);
        pmat = matOpen(filepath,"r");
        if(pmat==NULL){
            printf("Cannot open %s\n", filepath);
            mexErrMsgIdAndTxt("combine_FOVcell_PSF_multiPxl","Error");
        }
        crism_FOVcell_lcomb = matGetVariable(pmat, "crism_FOVcell_lcomb");
        if(crism_FOVcell_lcomb == NULL){
            printf("Cannot get crism_FOVcell_lcomb from %s\n", filepath);
            mexErrMsgIdAndTxt("combine_FOVcell_PSF_multiPxl","Error");
        }
        
        Ncrism = (int16_t) mxGetN(crism_FOVcell_lcomb);
        for(xi=0;xi<Ncrism;xi++){
            pff_lxi = mxGetSingles(mxGetCell(crism_FOVcell_lcomb,(mwIndex) xi));
            smpls_lxi = crismPxl_smpls[xi][l];
            lines_lxi = crismPxl_lines[xi][l];
            sofst_lxi = crismPxl_sofstc[xi][l];
            lofst_lxi = crismPxl_lofstc[xi][l];
            for(ss=0;ss<smpls_lxi;ss++){
                s_msldemc = ss+sofst_lxi;
                for(ll=0;ll<lines_lxi;ll++){
                    l_msldemc = ll+lofst_lxi;
                    pff_lxi_ssll = pff_lxi[ss*lines_lxi+ll];
                    if(pff_lxi_ssll>msldemc_imFOVres[s_msldemc][l_msldemc]){
                        msldemc_imFOVres[s_msldemc][l_msldemc] = pff_lxi_ssll;
                        // Indices are MATLAB style.
                        msldemc_imFOVsample[s_msldemc][l_msldemc] = xi+1;
                        msldemc_imFOVline[s_msldemc][l_msldemc]   = l+1;
                    }
                }
            }
        }
        mxDestroyArray(crism_FOVcell_lcomb);
        if (matClose(pmat) != 0) {
            printf("Error closing file %s\n",filepath);
            mexErrMsgIdAndTxt("combine_FOVcell_PSF_multiPxl","Error");
        }
    }
}

/* The gateway function */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
    char *dirpath_crism_FOVcell;
    char *basename_com_crism_FOVcell;
    mwSize line_offset;
    mwSize Nlines;
    int32_t **crismPxl_sofstc, **crismPxl_smpls;
    int32_t **crismPxl_lofstc, **crismPxl_lines;
    MSLDEMC_HEADER *msldemc_hdr;
    int err;
    mwSize samples,lines,s,l;
    float **msldemc_imFOVres;
    int16_t **msldemc_imFOVsample, **msldemc_imFOVline;
    

    /* -----------------------------------------------------------------
     * CHECK PROPER NUMBER OF INPUTS AND OUTPUTS
     * ----------------------------------------------------------------- */
    if(nrhs!=9) {
        mexErrMsgIdAndTxt("msl_create_mapper_mastcam2crism_mex:nrhs","Nine inputs required.");
    }
    if(nlhs!=3) {
        mexErrMsgIdAndTxt("msl_create_mapper_mastcam2crism_mex:nlhs","Three outputs required.");
    }
    /* -----------------------------------------------------------------
     * I/O SETUPs
     * ----------------------------------------------------------------- */
    
    /* INPUT 0/1 dirpath_crism_FOVcell basename_com_crism_FOVcell */
    basename_com_crism_FOVcell = mxArrayToString(prhs[0]);
    dirpath_crism_FOVcell = mxArrayToString(prhs[1]);
    
    
    /* INPUT 2/3 line_offset and # of lines */
    line_offset = (mwSize) mxGetScalar(prhs[2]);
    Nlines = (mwSize) mxGetScalar(prhs[3]);
    
    /* INPUT 4/5/6/7 */
    crismPxl_sofstc = set_mxInt32Matrix(prhs[4]);
    crismPxl_smpls  = set_mxInt32Matrix(prhs[5]);
    crismPxl_lofstc = set_mxInt32Matrix(prhs[6]);
    crismPxl_lines  = set_mxInt32Matrix(prhs[7]);
    
    /* INPUT 8 */
    msldemc_hdr = malloc(sizeof(MSLDEMC_HEADER));
    err = mxGet_MSLDEMC_HEADER(prhs[8], msldemc_hdr);
    if(err)
        mexErrMsgIdAndTxt("crism_combine_FOVcell_PSF_multiPxl_mex:Input error","msldemc_hdr is not right.");
    
    /* OUTPUTs  */
    samples = (mwSize) msldemc_hdr->samples;
    lines   = (mwSize) msldemc_hdr->lines;
    
    
    plhs[0] = mxCreateNumericMatrix(lines,samples,mxSINGLE_CLASS,mxREAL);
    msldemc_imFOVres = set_mxSingleMatrix(plhs[0]);
    
    plhs[1] = mxCreateNumericMatrix(lines,samples,mxINT16_CLASS,mxREAL);
    msldemc_imFOVsample = set_mxInt16Matrix(plhs[1]);
    
    plhs[2] = mxCreateNumericMatrix(lines,samples,mxINT16_CLASS,mxREAL);
    msldemc_imFOVline = set_mxInt16Matrix(plhs[2]);
    
    for(s=0;s<samples;s++){
        for(l=0;l<lines;l++){
            msldemc_imFOVsample[s][l] = -1;
            msldemc_imFOVline[s][l]   = -1;
            msldemc_imFOVsample[s][l] =  0;
        }
    }
    
    // printf("a\n");
    
    /* -----------------------------------------------------------------
     * CALL MAIN COMPUTATION ROUTINE
     * ----------------------------------------------------------------- */
    combine_FOVcell_PSF_multiPxl(
            dirpath_crism_FOVcell,basename_com_crism_FOVcell,
            (int32_t) line_offset, (int32_t) Nlines,
            crismPxl_sofstc,crismPxl_lofstc,crismPxl_smpls,crismPxl_lines,
            msldemc_imFOVres,msldemc_imFOVsample,msldemc_imFOVline
            );
    
    /* free memories */
    mxFree(dirpath_crism_FOVcell);
    mxFree(basename_com_crism_FOVcell);
    mxFree(crismPxl_sofstc);
    mxFree(crismPxl_lofstc);
    mxFree(crismPxl_smpls);
    mxFree(crismPxl_lines);
    free(msldemc_hdr);
    mxFree(msldemc_imFOVres);
    mxFree(msldemc_imFOVsample);
    mxFree(msldemc_imFOVline);
    
}
