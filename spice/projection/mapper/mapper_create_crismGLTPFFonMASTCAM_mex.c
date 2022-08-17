/* =====================================================================
 * mapper_create_crismGLTPFFonMASTCAM_mex.c
 * Create a mapping cell array from CRISM image to MASTCAM image using GLT 
 * image.
 * 
 * INPUTS:
 * 0 S_crm                  (Scalar) # of samples of CRISM
 * 1 L_crm                  (Scalar) # of lines of CRISM
 * 2 mst2crm_gltxy          [L_mest x S_mst x 2] int16 array
 *
 * 
 * OUTPUTS:
 * 0 crismGLTPFFonMASTCAM  [Lcrm x Scrm] cell array each (l,s) element has 
 *     the pixel footprint function (PFF) at the 
 * 1 crm2mst_sample_offset [Lcrm x Scrm] int32_t
 * 2 crm2mst_line_offset   [Lcrm x Scrm] int32_t
 * 3 crm2mst_samples       [Lcrm x Scrm] int32_t
 * 4 crm2mst_lines         [Lcrm x Scrm] int32_t
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

/* main computation routine */
void create_mapper_crm2mst_wglt(int32_t S_crm, int32_t L_crm, 
        int16_t **mst2crm_gltx,int16_t **mst2crm_glty,
        int32_t S_mst, int32_t L_mst, 
        int16_t **crm2mst_sample_offset, int16_t **crm2mst_line_offset,
        int16_t **crm2mst_samples, int16_t **crm2mst_lines,
        mxArray *crismGLTPFFonMASTCAM)
{
    int32_t **sample1_mat, *sample1_mat_base;
    int32_t **sampleEnd_mat, *sampleEnd_mat_base;
    int32_t **line1_mat, *line1_mat_base;
    int32_t **lineEnd_mat, *lineEnd_mat_base;
    int32_t xi,yi,n;
    int32_t smpls,lines,smpl_ofst,line_ofst;
    int32_t s,l;
    int8_t *pff_xiyi;
    mwIndex idx1d;
    
    
    /* ----------------------------------------------------------------- * 
     * Evaluate the sample offset and line offsets
     * ----------------------------------------------------------------- */
    createInt32Matrix(&sample1_mat, &sample1_mat_base, (size_t) S_crm, (size_t) L_crm);
    createInt32Matrix(&sampleEnd_mat, &sampleEnd_mat_base, (size_t) S_crm, (size_t) L_crm);
    createInt32Matrix(&line1_mat, &line1_mat_base, (size_t) S_crm, (size_t) L_crm);
    createInt32Matrix(&lineEnd_mat, &lineEnd_mat_base, (size_t) S_crm, (size_t) L_crm);
    
    /* Initialization of the indices of the both edges */
    for(xi=0;xi<S_crm;xi++){
        for(yi=0;yi<L_crm;yi++){
            sample1_mat[xi][yi]   = 32767; // maximum value of int16
            sampleEnd_mat[xi][yi] = -1;
            line1_mat[xi][yi]     = 32767;
            lineEnd_mat[xi][yi]   = -1;
        }
    }
    
    for(s=0;s<S_mst;s++){
        for(l=0;l<L_mst;l++){
            xi = mst2crm_gltx[s][l];
            yi = mst2crm_glty[s][l];
            if(xi>-1){
                xi--; yi--; // convert the MATLAB style to C style indexing.
                if(s<sample1_mat[xi][yi])
                    sample1_mat[xi][yi] = s;
                if(s>sampleEnd_mat[xi][yi])
                    sampleEnd_mat[xi][yi] = s;
                if(l<line1_mat[xi][yi])
                    line1_mat[xi][yi] = l;
                if(l>lineEnd_mat[xi][yi])
                    lineEnd_mat[xi][yi] = l;
            }
        }
    }
    
    printf("a\n");
    idx1d = 0; // Index for the cell matrix
    for(xi=0;xi<S_crm;xi++){
        for(yi=0;yi<L_crm;yi++){
            if(sampleEnd_mat[xi][yi]>-1){
                smpl_ofst = sample1_mat[xi][yi];
                line_ofst = line1_mat[xi][yi];
                smpls = sampleEnd_mat[xi][yi] - smpl_ofst + 1;
                lines = lineEnd_mat[xi][yi]   - line_ofst + 1;
                
                crm2mst_sample_offset[xi][yi] = (int16_t) smpl_ofst;
                crm2mst_line_offset[xi][yi]   = (int16_t) line_ofst;
                crm2mst_samples[xi][yi] = (int16_t) smpls;
                crm2mst_lines[xi][yi]   = (int16_t) lines;
                
                mxSetCell(crismGLTPFFonMASTCAM,idx1d, mxCreateNumericMatrix((mwSize) lines, (mwSize) smpls, mxINT8_CLASS, mxREAL));
                pff_xiyi = mxGetInt8s(mxGetCell(crismGLTPFFonMASTCAM,idx1d));

                for(s=0;s<smpls;s++){
                    for(l=0;l<lines;l++){
                        if(mst2crm_gltx[s+smpl_ofst][l+line_ofst]==(xi+1) && mst2crm_glty[s+smpl_ofst][l+line_ofst]==(yi+1)){
                            pff_xiyi[s*lines+l] = 1;
                        } else {
                            pff_xiyi[s*lines+l] = 0;
                        }
                    }
                }
            } else {
                crm2mst_sample_offset[xi][yi] = -1;
                crm2mst_line_offset[xi][yi]   = -1;
                crm2mst_samples[xi][yi] = 0;
                crm2mst_lines[xi][yi]   = 0;
                /* Create empty matrix */
                mxSetCell(crismGLTPFFonMASTCAM,idx1d,
                        mxCreateNumericMatrix(0,0,mxINT8_CLASS,mxREAL));
            }            
            idx1d++; // increment the index for the cell matrix
        }
        
    }
    
    /* ----------------------------------------------------------------- *
     * Freeing allocated memory space by malloc
     * ----------------------------------------------------------------- */
    free(sample1_mat);
    free(sample1_mat_base);
    free(sampleEnd_mat);
    free(sampleEnd_mat_base);
    free(line1_mat);
    free(line1_mat_base);
    free(lineEnd_mat);
    free(lineEnd_mat_base);
    
}

/* The gateway function */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
    
    mwSize S_crm, L_crm;
    mwSize S_mst, L_mst;
    int16_t ***mst2crm_gltxy;
    int16_t **mst2crm_gltx, **mst2crm_glty;
    // mwSize msldemc_lines,msldemc_samples;
    const mwSize *ndims_mst_glt;
    int16_t **crm2mst_sample_offset,**crm2mst_line_offset;
    int16_t **crm2mst_samples,**crm2mst_lines;
    mxArray *crismGLTPFFonMASTCAM;
    int err;
    
    

    /* -----------------------------------------------------------------
     * CHECK PROPER NUMBER OF INPUTS AND OUTPUTS
     * ----------------------------------------------------------------- */
    if(nrhs!=3) {
        mexErrMsgIdAndTxt("mapper_create_crismGLTPFFonMASTCAM_mex:nrhs","Five inputs required.");
    }
    if(nlhs!=5) {
        mexErrMsgIdAndTxt("mapper_create_crismGLTPFFonMASTCAM_mex:nlhs","Four outputs required.");
    }
    /* -----------------------------------------------------------------
     * I/O SETUPs
     * ----------------------------------------------------------------- */
    
    /* INPUT 0/1 S_crm and L_crm */
    S_crm = (mwSize) mxGetScalar(prhs[0]);
    L_crm = (mwSize) mxGetScalar(prhs[1]);
    if(S_crm==0)
        mexErrMsgIdAndTxt("mapper_create_crismGLTPFFonMASTCAM_mex","Input S_crm is invalid");
    if(L_crm==0)
        mexErrMsgIdAndTxt("mapper_create_crismGLTPFFonMASTCAM_mex","Input L_crm is invalid");
    
    /* INPUT 2 GLT xy */
    mst2crm_gltxy = set_mxInt16MatrixMultBand(prhs[2]);
    mst2crm_gltx  = mst2crm_gltxy[0];
    mst2crm_glty  = mst2crm_gltxy[1];
    ndims_mst_glt = mxGetDimensions(prhs[2]);
    L_mst = ndims_mst_glt[0];
    S_mst = ndims_mst_glt[1];    

    /* OUTPUT 0/1 offset matrix */
    plhs[0] = mxCreateCellMatrix(L_crm,S_crm);
    crismGLTPFFonMASTCAM = plhs[0];
    
    plhs[1] = mxCreateNumericMatrix(L_crm,S_crm,mxINT16_CLASS,mxREAL);
    crm2mst_sample_offset = set_mxInt16Matrix(plhs[1]);
    
    plhs[2] = mxCreateNumericMatrix(L_crm,S_crm,mxINT16_CLASS,mxREAL);
    crm2mst_line_offset = set_mxInt16Matrix(plhs[2]);
    
    plhs[3] = mxCreateNumericMatrix(L_crm,S_crm,mxINT16_CLASS,mxREAL);
    crm2mst_samples = set_mxInt16Matrix(plhs[3]);
    
    plhs[4] = mxCreateNumericMatrix(L_crm,S_crm,mxINT16_CLASS,mxREAL);
    crm2mst_lines = set_mxInt16Matrix(plhs[4]);
    
    
    
    /* -----------------------------------------------------------------
     * CALL MAIN COMPUTATION ROUTINE
     * ----------------------------------------------------------------- */
    create_mapper_crm2mst_wglt((int32_t) S_crm,(int32_t) L_crm,
            mst2crm_gltx, mst2crm_glty,(int32_t) S_mst, (int32_t) L_mst, 
            crm2mst_sample_offset,crm2mst_line_offset,
            crm2mst_samples, crm2mst_lines,crismGLTPFFonMASTCAM);
    
    /* free memories */
    mxFree(mst2crm_gltx);
    mxFree(mst2crm_glty);
    mxFree(mst2crm_gltxy);
    mxFree(crm2mst_sample_offset);
    mxFree(crm2mst_line_offset);
    mxFree(crm2mst_samples);
    mxFree(crm2mst_lines);
    
    
}
