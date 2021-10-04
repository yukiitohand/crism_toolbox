/* =====================================================================
 * mapper_create_crismGLTPFFonMSLDEM_mex.c
 * Create a mapping cell array from CRISM image to MSLDEM image.
 * 
 * INPUTS:
 * 0 S_crm                        (Scalar) # of samples of CRISM
 * 1 L_crm                        (Scalar) # of lines of CRISM
 * 2 msldem2crism_gltxy           [Ldemc x Sdemc x 2] int16 array
 * 3 msldemc_hdr                  Struct
 * 4 basename_com                 char* basename (common part)
 * 5 dirpath                      char* directory path

 * 
 * OUTPUTS:
 * 0 crism2msldem_sample_offset [Lcrm x Scrm]  int32_t
 * 1 crism2msldem_line_offset   [Lcrm x Scrm]  int32_t
 * 2 crism2msldem_samples       [Lcrm x Scrm]  int32_t
 * 3 crism2msldem_lines         [Lcrm x Scrm]  int32_t
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
void create_mapper_crism2msldemc_wglt(int32_t S_crm, int32_t L_crm, 
        int16_t **msldemc2crism_gltx,int16_t **msldemc2crism_glty,
        MSLDEMC_HEADER *msldemc_hdr,
        int32_t **crism2msldem_sample_offset, int32_t **crism2msldem_line_offset,
        int32_t **crism2msldem_samples, int32_t **crism2msldem_lines,
        char *dirpath, char *basename_com)
{
    int32_t msldemc_samples, msldemc_lines;
    int32_t **sample1_mat, *sample1_mat_base;
    int32_t **sampleEnd_mat, *sampleEnd_mat_base;
    int32_t **line1_mat, *line1_mat_base;
    int32_t **lineEnd_mat, *lineEnd_mat_base;
    int32_t xi,yi,n;
    int32_t smpls,lines,smpl_ofst,line_ofst;
    int32_t s,l;
    mxArray *map_crism2msldemc;
    char *filepath;
    MATFile *pmat;
    int8_t *pff_xiyi;
    int status;
    int32_t msldemc_sample_offset, msldemc_line_offset;

    filepath = malloc(sizeof(char)*(strlen(dirpath)+strlen(basename_com)+12));
    
    msldemc_lines   = msldemc_hdr->lines;
    msldemc_samples = msldemc_hdr->samples;
    msldemc_sample_offset = msldemc_hdr->sample_offset;
    msldemc_line_offset = msldemc_hdr->line_offset;
    
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
            sample1_mat[xi][yi] = 2147483647; // maximum value of int32
            sampleEnd_mat[xi][yi] = -1;
            line1_mat[xi][yi] = 2147483647;
            lineEnd_mat[xi][yi] = -1;
        }
    }
    
    printf("msldemc_lines=%d,msldemc_samples=%d\n",msldemc_lines,msldemc_samples);
    for(s=0;s<msldemc_samples;s++){
        for(l=0;l<msldemc_lines;l++){
            xi = msldemc2crism_gltx[s][l];
            yi = msldemc2crism_glty[s][l];
            if(xi>-1){
                xi--; yi--;
                if(s<sample1_mat[xi][yi])
                    sample1_mat[xi][yi]   = s;
                if(s>sampleEnd_mat[xi][yi])
                    sampleEnd_mat[xi][yi] = s;
                if(l<line1_mat[xi][yi])
                    line1_mat[xi][yi]     = l;
                if(l>lineEnd_mat[xi][yi])
                    lineEnd_mat[xi][yi]   = l;
            }
        }
    }
    
    printf("a\n");
    for(yi=0;yi<L_crm;yi++){
        map_crism2msldemc = mxCreateCellMatrix(1,S_crm);
        
        for(xi=0;xi<S_crm;xi++){
            if(sampleEnd_mat[xi][yi]>-1){
                smpl_ofst = sample1_mat[xi][yi];
                line_ofst = line1_mat[xi][yi];
                smpls = sampleEnd_mat[xi][yi] - smpl_ofst + 1;
                lines = lineEnd_mat[xi][yi]   - line_ofst + 1;
                crism2msldem_sample_offset[xi][yi] = smpl_ofst;
                crism2msldem_line_offset[xi][yi]   = line_ofst;
                crism2msldem_samples[xi][yi] = smpls;
                crism2msldem_lines[xi][yi]   = lines;

                mxSetCell(map_crism2msldemc,(mwIndex) xi,
                        mxCreateNumericMatrix(lines,smpls,mxINT8_CLASS,mxREAL));
                pff_xiyi = mxGetInt8s(mxGetCell(map_crism2msldemc,(mwIndex) xi));

                for(s=0;s<smpls;s++){
                    for(l=0;l<lines;l++){
                        if(msldemc2crism_gltx[s+smpl_ofst][l+line_ofst]==(xi+1) && msldemc2crism_glty[s+smpl_ofst][l+line_ofst]==(yi+1)){
                            pff_xiyi[s*lines+l] = 1;
                        } else {
                            pff_xiyi[s*lines+l] = 0;
                        }
                    }
                }
            } else {
                crism2msldem_sample_offset[xi][yi] = -1;
                crism2msldem_line_offset[xi][yi]   = -1;
                crism2msldem_samples[xi][yi] = 0;
                crism2msldem_lines[xi][yi]   = 0;
                mxSetCell(map_crism2msldemc,(mwIndex) xi,
                        mxCreateNumericMatrix(0,0,mxINT8_CLASS,mxREAL));
            }
        }
        /* Save to mat file */
        sprintf(filepath,"%s/%s_l%03d.mat",dirpath,basename_com,yi+1);
        printf("Saving to %s\n",filepath);
        pmat = matOpen(filepath,"w");
        if (pmat == NULL) {
            printf("Error creating file %s\n", filepath);
            printf("(Do you have write permission in this directory?)\n");
            mexErrMsgIdAndTxt("mapper_create_crismGLTPFFonMSLDEM_mex:create_mapper_crism2msldemc_wglt","Error");
        }
        status = matPutVariable(pmat, "crism_FOVcell_lcomb", map_crism2msldemc);
        if (matClose(pmat) != 0) {
            printf("Error closing file %s\n",filepath);
            mexErrMsgIdAndTxt("mapper_create_crismGLTPFFonMSLDEM_mex:create_mapper_crism2msldemc_wglt","Error");
        }
        /* Destroy cell array */
        mxDestroyArray(map_crism2msldemc);
        
    }
    
    /* Finally move the index with offsets to align MSLDEM */
    for(yi=0;yi<L_crm;yi++){
        for(xi=0;xi<S_crm;xi++){
            if(crism2msldem_sample_offset[xi][yi]>-1){
                crism2msldem_sample_offset[xi][yi] += msldemc_sample_offset;
                crism2msldem_line_offset[xi][yi]   += msldemc_line_offset;
            }
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
    free(filepath);
    
}

/* The gateway function */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
    
    mwSize S_crm, L_crm;
    int16_t ***msldemc2crism_gltxy;
    int16_t **msldemc2crism_gltx, **msldemc2crism_glty;
    // mwSize msldemc_lines,msldemc_samples;
    const mwSize *ndims_msldemc_glt;
    int32_t **crism2msldem_sample_offset,**crism2msldem_line_offset;
    int32_t **crism2msldem_samples,**crism2msldem_lines;
    char *dirpath,*basename_com;
    MSLDEMC_HEADER *msldemc_hdr;
    int err;
    
    

    /* -----------------------------------------------------------------
     * CHECK PROPER NUMBER OF INPUTS AND OUTPUTS
     * ----------------------------------------------------------------- */
    if(nrhs!=6) {
        mexErrMsgIdAndTxt("mapper_create_crismGLTPFFonMSLDEM_mex:nrhs","Six inputs required.");
    }
    if(nlhs!=4) {
        mexErrMsgIdAndTxt("mapper_create_crismGLTPFFonMSLDEM_mex:nlhs","Four outputs required.");
    }
    /* -----------------------------------------------------------------
     * I/O SETUPs
     * ----------------------------------------------------------------- */
    
    /* INPUT 0/1 S_crm and L_crm */
    S_crm = (mwSize) mxGetScalar(prhs[0]);
    L_crm = (mwSize) mxGetScalar(prhs[1]);
    if(S_crm==0)
        mexErrMsgIdAndTxt("msl_create_mapper_crism2msldemc_wglt_mex","Input S_crm is invalid");
    if(L_crm==0)
        mexErrMsgIdAndTxt("msl_create_mapper_crism2msldemc_wglt_mex","Input L_crm is invalid");
    
    /* INPUT 2 GLT xy */
    msldemc2crism_gltxy = set_mxInt16MatrixMultBand(prhs[2]);
    msldemc2crism_gltx  = msldemc2crism_gltxy[0];
    msldemc2crism_glty  = msldemc2crism_gltxy[1];
    ndims_msldemc_glt = mxGetDimensions(prhs[2]);
    // msldemc_lines   = ndims_msldemc_glt[0];
    // msldemc_samples = ndims_msldemc_glt[1];
    
    msldemc_hdr = malloc(sizeof(MSLDEMC_HEADER));
    mxGet_MSLDEMC_HEADER(prhs[3],msldemc_hdr);
    
    /* INPUT 4/5 */
    basename_com = mxArrayToString(prhs[4]);
    dirpath = mxArrayToString(prhs[5]);
    

    /* OUTPUT 0/1 offset matrix */
    plhs[0] = mxCreateNumericMatrix(L_crm,S_crm,mxINT32_CLASS,mxREAL);
    crism2msldem_sample_offset = set_mxInt32Matrix(plhs[0]);
    
    plhs[1] = mxCreateNumericMatrix(L_crm,S_crm,mxINT32_CLASS,mxREAL);
    crism2msldem_line_offset = set_mxInt32Matrix(plhs[1]);
    
    plhs[2] = mxCreateNumericMatrix(L_crm,S_crm,mxINT32_CLASS,mxREAL);
    crism2msldem_samples = set_mxInt32Matrix(plhs[2]);
    
    plhs[3] = mxCreateNumericMatrix(L_crm,S_crm,mxINT32_CLASS,mxREAL);
    crism2msldem_lines = set_mxInt32Matrix(plhs[3]);
    
    
    
    /* -----------------------------------------------------------------
     * CALL MAIN COMPUTATION ROUTINE
     * ----------------------------------------------------------------- */
    create_mapper_crism2msldemc_wglt((int32_t) S_crm,(int32_t) L_crm,
            msldemc2crism_gltx, msldemc2crism_glty,msldemc_hdr, 
            crism2msldem_sample_offset,crism2msldem_line_offset,
            crism2msldem_samples, crism2msldem_lines,
            dirpath, basename_com);
    
    /* free memories */
    mxFree(msldemc2crism_gltx);
    mxFree(msldemc2crism_glty);
    mxFree(msldemc2crism_gltxy);
    mxFree(crism2msldem_sample_offset);
    mxFree(crism2msldem_line_offset);
    mxFree(crism2msldem_samples);
    mxFree(crism2msldem_lines);
    mxFree(dirpath);
    mxFree(basename_com);
    free(msldemc_hdr);
    
}
