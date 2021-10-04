/* =====================================================================
 * msl_create_mapper_crism2mastcam_mex.c
 * Create a mapping cell array from CRISM image to MASTCAM image
 * 
 * INPUTS:
 * 0 basename_com_crism_FOVcell   char* common basename
 * 1 dirpath_crism_FOVcell        char* directory path
 * 2 crismPxl_sofst    int32 [L x Ncrism]
 * 3 crismPxl_lofst    int32 [L x Ncrism]
 * 4 crismPxl_smpls    int32 [L x Ncrism]
 * 5 crismPxl_lines    int32 [L x Ncrism]
 * 6 mapper_msldemc2mastcam_mat
 * 7 mapper_msldemc2mastcam_cell
 * 8 msldemc_mastcam_hdr struct
 * 
 * OUTPUTS:
 * 0 crismFOVcell_onmstimg   [Lcrm x Scrm] cell array
 * 1 crismFOV_sofst_onmstimg [Lcrm x Scrm]  int16_t
 * 2 crismFOV_lofst_onmstimg [Lcrm x Scrm]  int16_t
 * 3 crismFOV_smpls_onmstimg [Lcrm x Scrm]  int16_t
 * 4 crismFOV_lines_onmstimg [Lcrm x Scrm]  int16_t

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
void create_mapper_crism2mastcam_single(
        char* basename_com_crism_FOVcell,char* dirpath_crism_FOVcell,
        int32_t **crismPxl_sofst,int32_t **crismPxl_lofst,
        int32_t **crismPxl_smpls,int32_t **crismPxl_lines,
        int32_t S_crm, int32_t L_crm,
        int16_t*** mapper_msldemc2mastcam,int16_t** mapper_msldemc2mastcam_count,
        MSLDEMC_HEADER *msldemc_mastcam_hdr,
        mxArray *crismFOVcell_onmstimg, 
        int16_t **crismFOV_sofst_onmstimg,int16_t **crismFOV_lofst_onmstimg,
        int16_t **crismFOV_smpls_onmstimg,int16_t **crismFOV_lines_onmstimg)
{
    int32_t xi,yi;
    char *filepath;
    MATFile *pmat;
    mxArray *crism_FOVcell_lcomb;
    float *pff_xiyi;
    int32_t smpls_xiyi,lines_xiyi,sofst_xiyi,lofst_xiyi;
    int32_t lofst_msldemc_mastcam, sofst_msldemc_mastcam;
    int32_t smpls_msldemc_mastcam,lines_msldemc_mastcam;
    int32_t s_msldemc_mastcam,l_msldemc_mastcam;
    int16_t *mapper_msldemc2mastcam_sl;
    int16_t s1_mst, send_mst, l1_mst, lend_mst;
    int16_t smstofst,lmstofst,smplsmst,linesmst;
    int16_t x_mst,y_mst,n,mapper_msldemc2mastcam_sl_count;
    int32_t ss,ll;
    float *pffmst_xiyi;
    mxArray *pffmst_xiyi_count;
    int16_t *pffmst_xiyi_count_pr;
    mwIndex idx1d;
    
    sofst_msldemc_mastcam = msldemc_mastcam_hdr->sample_offset;
    lofst_msldemc_mastcam = msldemc_mastcam_hdr->line_offset;
    smpls_msldemc_mastcam = msldemc_mastcam_hdr->samples;
    lines_msldemc_mastcam = msldemc_mastcam_hdr->lines;
    // printf("sofst_msldemc_mastcam = %d\n",sofst_msldemc_mastcam);
    // printf("lofst_msldemc_mastcam = %d\n",lofst_msldemc_mastcam);
    // printf("smpls_msldemc_mastcam = %d\n",smpls_msldemc_mastcam);
    // printf("lines_msldemc_mastcam = %d\n",lines_msldemc_mastcam);
    
    filepath = malloc(sizeof(char)*(strlen(dirpath_crism_FOVcell)+strlen(basename_com_crism_FOVcell)+12));
    
    
    for(yi=0;yi<L_crm;yi++){
        /* Load MAT file and get FOVcell on msldemc */
        sprintf(filepath,"%s/%s_l%03d.mat",dirpath_crism_FOVcell,basename_com_crism_FOVcell,yi+1);
        pmat = matOpen(filepath,"r");
        if(pmat==NULL){
            printf("Cannot open %s\n",filepath);
            mexErrMsgIdAndTxt("create_mapper_crism2mastcam","Error");
        }
        crism_FOVcell_lcomb = matGetVariable(pmat,"crism_FOVcell_lcomb");
        if(crism_FOVcell_lcomb==NULL){
            printf("Cannot get crism_FOVcell_lcomb from %s\n",filepath);
            mexErrMsgIdAndTxt("create_mapper_crism2mastcam","Error");
        }
        
        for(xi=0;xi<S_crm;xi++){
            /* Get pixel footprint function (pff) and its sample and line
             * offsets and height and width. */
            pff_xiyi = mxGetSingles(mxGetCell(crism_FOVcell_lcomb,(mwIndex) xi));
            if(pff_xiyi==NULL)
                mexErrMsgIdAndTxt("create_mapper_crism2mastcam_single:TypeError","data type of PFF is not single.");
            
            smpls_xiyi = crismPxl_smpls[xi][yi];
            lines_xiyi = crismPxl_lines[xi][yi];
            sofst_xiyi = crismPxl_sofst[xi][yi];
            lofst_xiyi = crismPxl_lofst[xi][yi];
            /* ----------------------------------------------------------------- *
             * In the first iteration, find out the minimum enclosing rectangle of 
             * the pixel footprint function on the MASTCAM image
             * ----------------------------------------------------------------- */
            s1_mst   = 32767;
            send_mst = -1;
            l1_mst   = 32767;
            lend_mst = -1;
            for(ss=0;ss<smpls_xiyi;ss++){
                // printf("ss=%d\n",ss);
                s_msldemc_mastcam = ss+sofst_xiyi-sofst_msldemc_mastcam;
                if(s_msldemc_mastcam>-1 && s_msldemc_mastcam<smpls_msldemc_mastcam){
                    for(ll=0;ll<lines_xiyi;ll++){
                        // printf("ss=%d,ll=%d\n",ss,ll);
                        l_msldemc_mastcam = ll+lofst_xiyi-lofst_msldemc_mastcam;
                        if(l_msldemc_mastcam>-1 && l_msldemc_mastcam<lines_msldemc_mastcam){
                            //////
                            if(pff_xiyi[ss*lines_xiyi+ll]>0){
                                mapper_msldemc2mastcam_sl_count = mapper_msldemc2mastcam_count[s_msldemc_mastcam][l_msldemc_mastcam];
                                if(mapper_msldemc2mastcam_sl_count>0){
                                    mapper_msldemc2mastcam_sl = mapper_msldemc2mastcam[s_msldemc_mastcam][l_msldemc_mastcam];
                                    for(n=0;n<mapper_msldemc2mastcam_sl_count;n++){
                                        x_mst = mapper_msldemc2mastcam_sl[0]-1;
                                        y_mst = mapper_msldemc2mastcam_sl[1]-1;

                                        if(x_mst<s1_mst){
                                            s1_mst = x_mst;
                                        }
                                        if(x_mst>send_mst){
                                            send_mst = x_mst;
                                        }
                                        if(y_mst<l1_mst){
                                            l1_mst = y_mst;
                                        }
                                        if(y_mst>lend_mst){
                                            lend_mst = y_mst;
                                        }
                                        mapper_msldemc2mastcam_sl += 2;
                                    }
                                }
                            }
                            //////
                        }

                    }
                }
            }
            
            /* ----------------------------------------------------------------- *
             * If the pixel footprint is not empty, fill the rectangle with the 
             * value of the pixel footprint function.
             * ----------------------------------------------------------------- */
            if(send_mst>-1){
                smstofst = s1_mst;
                lmstofst = l1_mst;
                smplsmst = send_mst-smstofst+1;
                linesmst = lend_mst-lmstofst+1;
                crismFOV_sofst_onmstimg[xi][yi] = smstofst;
                crismFOV_lofst_onmstimg[xi][yi] = lmstofst;
                crismFOV_smpls_onmstimg[xi][yi] = smplsmst;
                crismFOV_lines_onmstimg[xi][yi] = linesmst;
                // printf("yi=%d,xi=%d, smplsmst=%d,linesmst=%d\n",yi,xi,smplsmst,linesmst);
                /* Fill the crismFOV cell */
                idx1d = (mwIndex) xi*L_crm+yi;
                mxSetCell(crismFOVcell_onmstimg,idx1d,
                        mxCreateNumericMatrix(linesmst,smplsmst,mxSINGLE_CLASS,mxREAL));
                pffmst_xiyi = mxGetSingles(mxGetCell(crismFOVcell_onmstimg,idx1d));

                /* Counter */
                pffmst_xiyi_count = mxCreateNumericMatrix(linesmst,smplsmst,mxINT16_CLASS,mxREAL);
                pffmst_xiyi_count_pr = mxGetInt16s(pffmst_xiyi_count);
                for(ss=0;ss<smpls_xiyi;ss++){
                    s_msldemc_mastcam = ss+sofst_xiyi-sofst_msldemc_mastcam;
                    for(ll=0;ll<lines_xiyi;ll++){
                        l_msldemc_mastcam = ll+lofst_xiyi-lofst_msldemc_mastcam;
                        if(l_msldemc_mastcam>-1 && l_msldemc_mastcam<lines_msldemc_mastcam &&
                            s_msldemc_mastcam>-1 && s_msldemc_mastcam<smpls_msldemc_mastcam){
                            ///
                            if(pff_xiyi[ss*lines_xiyi+ll]>0){
                                mapper_msldemc2mastcam_sl_count = mapper_msldemc2mastcam_count[s_msldemc_mastcam][l_msldemc_mastcam];
                                if(mapper_msldemc2mastcam_sl_count>0){
                                    mapper_msldemc2mastcam_sl = mapper_msldemc2mastcam[s_msldemc_mastcam][l_msldemc_mastcam];
                                    for(n=0;n<mapper_msldemc2mastcam_sl_count;n++){
                                        x_mst = mapper_msldemc2mastcam_sl[0]-1-smstofst;
                                        y_mst = mapper_msldemc2mastcam_sl[1]-1-lmstofst;
                                        pffmst_xiyi[x_mst*linesmst+y_mst] += pff_xiyi[ss*lines_xiyi+ll];
                                        pffmst_xiyi_count_pr[x_mst*linesmst+y_mst]++;
                                        mapper_msldemc2mastcam_sl += 2;
                                    }
                                }
                            }
                            ///
                        }
                    }
                }
                for(x_mst=0;x_mst<smplsmst;x_mst++){
                    for(y_mst=0;y_mst<linesmst;y_mst++){
                        if(pffmst_xiyi[x_mst*linesmst+y_mst]>0){
                            pffmst_xiyi[x_mst*linesmst+y_mst] /= (float) pffmst_xiyi_count_pr[x_mst*linesmst+y_mst];
                        }
                    }
                }
                mxDestroyArray(pffmst_xiyi_count);
            } else {
                crismFOV_sofst_onmstimg[xi][yi] = -1;
                crismFOV_lofst_onmstimg[xi][yi] = -1;
                crismFOV_smpls_onmstimg[xi][yi] =  0;
                crismFOV_lines_onmstimg[xi][yi] =  0;
            }
            
        }
        mxDestroyArray(crism_FOVcell_lcomb);
        if (matClose(pmat) != 0) {
            printf("Error closing file %s\n",filepath);
            mexErrMsgIdAndTxt("create_mapper_crism2mastcam","Error");
        }
    }
    
    free(filepath);
    
}

/* The gateway function */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
    
    char *basename_com_crism_FOVcell;
    char *dirpath_crism_FOVcell;
    int32_t **crismPxl_sofst, **crismPxl_smpls;
    int32_t **crismPxl_lofst, **crismPxl_lines;
    mwSize S_crm,L_crm;
    int err;
    const mxArray *mapper_msldemc2mastcam_mat;
    const mxArray *mapper_msldemc2mastcam_cell;
    MSLDEMC_HEADER *msldemc_mastcam_hdr;
    mwSize msldemc_mst_samples,msldemc_mst_lines;
    bool issparse_mapper_msldemc2mastcam_mat;
    mxArray *crismFOVcell_onmstimg;
    int16_t **crismFOV_sofst_onmstimg, **crismFOV_lofst_onmstimg;
    int16_t **crismFOV_smpls_onmstimg, **crismFOV_lines_onmstimg;
    int16_t ***mapper_msldemc2mastcam, **mapper_msldemc2mastcam_base;
    int16_t **mapper_msldemc2mastcam_count, *mapper_msldemc2mastcam_count_base;
    mwSize s,l,idx1d;
    double *prs;
    mwIndex *irs, *jcs;
    mwIndex k;
    int32_t **mapper_msldemc2mastcam_mat2d;
    

    /* -----------------------------------------------------------------
     * CHECK PROPER NUMBER OF INPUTS AND OUTPUTS
     * ----------------------------------------------------------------- */
    if(nrhs!=9) {
        mexErrMsgIdAndTxt("msl_create_mapper_crism2mastcam_mex:nrhs","Nine inputs required.");
    }
    if(nlhs!=5) {
        mexErrMsgIdAndTxt("msl_create_mapper_crism2mastcam_mex:nlhs","Five outputs required.");
    }
    /* -----------------------------------------------------------------
     * I/O SETUPs
     * ----------------------------------------------------------------- */
    
    /* INPUT 0/1 basename_com_crism_FOVcell,dirpath_crism_FOVcell */
    basename_com_crism_FOVcell = mxArrayToString(prhs[0]);
    dirpath_crism_FOVcell = mxArrayToString(prhs[1]);
    
    /* INPUT 2 3 4 5 */
    crismPxl_sofst = set_mxInt32Matrix(prhs[2]);
    crismPxl_lofst = set_mxInt32Matrix(prhs[3]);
    crismPxl_smpls = set_mxInt32Matrix(prhs[4]);
    crismPxl_lines = set_mxInt32Matrix(prhs[5]);
    S_crm = mxGetN(prhs[2]);
    L_crm = mxGetM(prhs[2]);
    
    /* INPUT 7 mapper_msldemc2mastcam */
    mapper_msldemc2mastcam_mat  = prhs[6];
    mapper_msldemc2mastcam_cell = prhs[7];
    
    /* INPUT 9 msldemc_mastcam_hdr */
    msldemc_mastcam_hdr = malloc(sizeof(MSLDEMC_HEADER));
    err = mxGet_MSLDEMC_HEADER(prhs[8], msldemc_mastcam_hdr);
    if(err)
        mexErrMsgIdAndTxt("msl_create_mapper_crism2mastcam_mex:Input error","msldemc_mastcam_hdr is not right.");
    msldemc_mst_lines   = (mwSize) msldemc_mastcam_hdr->lines;
    msldemc_mst_samples = (mwSize) msldemc_mastcam_hdr->samples;

    /* OUTPUT 0 FOVcell */
    plhs[0] = mxCreateCellMatrix(L_crm,S_crm);
    crismFOVcell_onmstimg = plhs[0];
    
    /* OUTPUT 1 sample offset of the each of the FOVcells projecting to MASTCAM image  */
    plhs[1] = mxCreateNumericMatrix(L_crm,S_crm,mxINT16_CLASS,mxREAL);
    crismFOV_sofst_onmstimg = set_mxInt16Matrix(plhs[1]);
    
    /* OUTPUT 2 line offset of the each of the FOVcells projecting to MASTCAM image  */
    plhs[2] = mxCreateNumericMatrix(L_crm,S_crm,mxINT16_CLASS,mxREAL);
    crismFOV_lofst_onmstimg = set_mxInt16Matrix(plhs[2]);
    
    /* OUTPUT 3 #samples of the each of the FOVcells projecting to MASTCAM image  */
    plhs[3] = mxCreateNumericMatrix(L_crm,S_crm,mxINT16_CLASS,mxREAL);
    crismFOV_smpls_onmstimg = set_mxInt16Matrix(plhs[3]);
    
    /* OUTPUT 4 #samples of the each of the FOVcells projecting to MASTCAM image  */
    plhs[4] = mxCreateNumericMatrix(L_crm,S_crm,mxINT16_CLASS,mxREAL);
    crismFOV_lines_onmstimg = set_mxInt16Matrix(plhs[4]);
    
    /* -----------------------------------------------------------------
     * Organize input mapper msldemc -> mastcam
     * ----------------------------------------------------------------- */
    createInt16PMatrix(&mapper_msldemc2mastcam, &mapper_msldemc2mastcam_base,
            (size_t) msldemc_mst_samples, (size_t) msldemc_mst_lines);
    createInt16Matrix(&mapper_msldemc2mastcam_count, &mapper_msldemc2mastcam_count_base,
            (size_t) msldemc_mst_samples, (size_t) msldemc_mst_lines);
    issparse_mapper_msldemc2mastcam_mat = mxIsSparse(mapper_msldemc2mastcam_mat);
    if(issparse_mapper_msldemc2mastcam_mat){
        prs = mxGetDoubles(mapper_msldemc2mastcam_mat);
        jcs = mxGetJc(mapper_msldemc2mastcam_mat);
        irs = mxGetIr(mapper_msldemc2mastcam_mat);
        k=0;
        for(s=0;s<msldemc_mst_samples;s++){
            while(k<jcs[s+1]){
                l = irs[k];
                idx1d = (mwSize) prs[k] -1;
                mapper_msldemc2mastcam[s][l] = mxGetInt16s(mxGetCell(mapper_msldemc2mastcam_cell,idx1d));
                mapper_msldemc2mastcam_count[s][l] = mxGetN(mxGetCell(mapper_msldemc2mastcam_cell,idx1d));
                k++;
            }
        }
    } else {
        mapper_msldemc2mastcam_mat2d = set_mxInt32Matrix(mapper_msldemc2mastcam_mat);
        for(s=0;s<msldemc_mst_samples;s++){
            for(l=0;l<msldemc_mst_lines;l++){
                idx1d = (mwSize) mapper_msldemc2mastcam_mat2d[s][l];
                if(idx1d>0){
                    mapper_msldemc2mastcam[s][l] = mxGetInt16s(mxGetCell(mapper_msldemc2mastcam_cell,idx1d-1));
                    mapper_msldemc2mastcam_count[s][l] = mxGetN(mxGetCell(mapper_msldemc2mastcam_cell,idx1d-1));
                } else {
                    mapper_msldemc2mastcam[s][l] = NULL;
                    mapper_msldemc2mastcam_count[s][l] = 0;
                }
            }
        }
        mxFree(mapper_msldemc2mastcam_mat2d);
    }
    
    /* -----------------------------------------------------------------
     * CALL MAIN COMPUTATION ROUTINE
     * ----------------------------------------------------------------- */
    create_mapper_crism2mastcam_single(
            basename_com_crism_FOVcell,dirpath_crism_FOVcell,
            crismPxl_sofst,crismPxl_lofst,crismPxl_smpls,crismPxl_lines,
            (int32_t) S_crm, (int32_t) L_crm,
            mapper_msldemc2mastcam,mapper_msldemc2mastcam_count,msldemc_mastcam_hdr,
            crismFOVcell_onmstimg,
            crismFOV_sofst_onmstimg,crismFOV_lofst_onmstimg,
            crismFOV_smpls_onmstimg,crismFOV_lines_onmstimg
            );
    
    /* free memories */
    mxFree(basename_com_crism_FOVcell);
    mxFree(dirpath_crism_FOVcell);
    mxFree(crismPxl_sofst);
    mxFree(crismPxl_smpls);
    mxFree(crismPxl_lofst);
    mxFree(crismPxl_lines);
    mxFree(msldemc_mastcam_hdr);
    mxFree(crismFOV_sofst_onmstimg);
    mxFree(crismFOV_lofst_onmstimg);
    mxFree(crismFOV_smpls_onmstimg);
    mxFree(crismFOV_lines_onmstimg);
    free(mapper_msldemc2mastcam);
    free(mapper_msldemc2mastcam_base);
    free(mapper_msldemc2mastcam_count);
    free(mapper_msldemc2mastcam_count_base);
    
}