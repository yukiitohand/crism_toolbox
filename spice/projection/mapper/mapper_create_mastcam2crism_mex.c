/* =====================================================================
 * msl_create_mapper_mastcam2crism_mex.c
 * Create a mapping cell array from MASTCAM image to CRISM image
 * 
 * INPUTS:
 * 0 crismFOVcell_onmstimg   [Lcrm x Scrm] cell array
 * 1 crismFOV_sofst_onmstimg [Lcrm x Scrm]  int16_t
 * 2 crismFOV_lofst_onmstimg [Lcrm x Scrm]  int16_t
 * 3 crismFOV_smpls_onmstimg [Lcrm x Scrm]  int16_t
 * 4 crismFOV_lines_onmstimg [Lcrm x Scrm]  int16_t
 * 5 S_mst Scalar
 * 6 L_mst Scalar
 *
 * OUTPUTS:
 * 0 mapper_mst2crm cell array [L_mst x S_mst]
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


struct MST2CRM_LinkedList{
    int16_t c;
    int16_t l;
    float res;
    struct MST2CRM_LinkedList *next;
};


/* ---------------------------------------------------------------------
 *  Create 2d matrix for storing MST2CRM_LinkedList
 * --------------------------------------------------------------------- */
int createMST2CRM_LLMatrix(struct MST2CRM_LinkedList ****ar2d, 
        struct MST2CRM_LinkedList ***ar_base, size_t N, size_t M)
{
    size_t ni;
    int err=0;
    
    *ar2d = (struct MST2CRM_LinkedList***) malloc(sizeof(struct MST2CRM_LinkedList**) * N);
    if((*ar2d)==NULL){
        err=1;
    } else {
        *ar_base = (struct MST2CRM_LinkedList**) malloc(sizeof(struct MST2CRM_LinkedList*) * N * M);
        if((*ar_base)==NULL){ 
            free((*ar2d));
            err=1;
        } else {
            (*ar2d)[0] = &(*ar_base)[0];
            for(ni=1;ni<N;ni++){
                (*ar2d)[ni] = (*ar2d)[ni-1] + M;
            }
        }
    }
    return err;
}

void add_MST2CRM_LL_sortdesc(struct MST2CRM_LinkedList **ll_next, struct MST2CRM_LinkedList *new_item){
    int flg_cont=1;
    
    while(flg_cont){
        if(*ll_next==NULL || (new_item->res > (*ll_next)->res) ){
            new_item->next = *ll_next;
            *ll_next = new_item;
            flg_cont=0;
        } else {
            ll_next = &(*ll_next)->next;
        }
    }
}

int32_t get_NumberOfElements_MST2CRM_LL(struct MST2CRM_LinkedList **ll_next){
    int32_t count=0;
    while(*ll_next!=NULL){
        ll_next = &(*ll_next)->next;
        count++;
    }
    return count;
}

/* main computation routine */
void create_mapper_mastcam2crism(
        const mxArray *crismFOVcell_onmstimg, int32_t S_crm, int32_t L_crm,
        int16_t **crismFOV_sofst_onmstimg, int16_t **crismFOV_lofst_onmstimg,
        int16_t **crismFOV_smpls_onmstimg, int16_t **crismFOV_lines_onmstimg,
        mxArray *mapper_mst2crm, int32_t S_mst, int32_t L_mst)
{
    
    int32_t xi,yi;
    mwSize idx1d;
    int32_t smstofst,lmstofst,smplsmst,linesmst;
    struct MST2CRM_LinkedList ***mst2crm_llmat;
    struct MST2CRM_LinkedList **mst2crm_llmat_base;
    struct MST2CRM_LinkedList *ll_curr;
    struct MST2CRM_LinkedList **ll_xiyi;
    int32_t ss,ll;
    int32_t count;
    mxArray *pffmst_xiyi_mxar;
    float *pffmst_xiyi_float;
    int16_t *mst2crm_yixi;
    
    /* -----------------------------------------------------------------
     *  First get the image 
     * ----------------------------------------------------------------- */
    createMST2CRM_LLMatrix(&mst2crm_llmat,&mst2crm_llmat_base, 
            (size_t) S_mst, (size_t) L_mst);
    printf("a\n");
    for(xi=0;xi<S_crm;xi++){
        for(yi=0;yi<L_crm;yi++){
            idx1d = (mwSize) xi*L_crm+yi;
            pffmst_xiyi_mxar = mxGetCell(crismFOVcell_onmstimg,idx1d);
            pffmst_xiyi_float = mxGetSingles(pffmst_xiyi_mxar);
            smstofst = (int32_t) crismFOV_sofst_onmstimg[xi][yi];
            lmstofst = (int32_t) crismFOV_lofst_onmstimg[xi][yi];
            smplsmst = (int32_t) crismFOV_smpls_onmstimg[xi][yi];
            linesmst = (int32_t) crismFOV_lines_onmstimg[xi][yi];
            for(ss=0;ss<smplsmst;ss++){
                for(ll=0;ll<linesmst;ll++){
                    if(pffmst_xiyi_float[ss*linesmst+ll]>0){
                        ll_curr = malloc(sizeof(struct MST2CRM_LinkedList));
                        ll_curr->c = (int16_t) xi;
                        ll_curr->l = (int16_t) yi;
                        ll_curr->res = pffmst_xiyi_float[ss*linesmst+ll];
                        add_MST2CRM_LL_sortdesc(&mst2crm_llmat[ss+smstofst][ll+lmstofst],ll_curr);
                    }
                }
            }
            
            
        }
    }
    
    printf("a\n");
    for(xi=0;xi<S_mst;xi++){
        for(yi=0;yi<L_mst;yi++){
            count = get_NumberOfElements_MST2CRM_LL(&mst2crm_llmat[xi][yi]);
            idx1d = (mwSize) xi*L_mst+yi;
            mxSetCell(mapper_mst2crm,idx1d,mxCreateNumericMatrix(
                    2,(mwSize) count, mxINT16_CLASS, mxREAL));
            mst2crm_yixi = mxGetInt16s(mxGetCell(mapper_mst2crm,idx1d));
            
            ll_xiyi=&mst2crm_llmat[xi][yi];
            for(ss=0;ss<count;ss++){
                mst2crm_yixi[0] = (*ll_xiyi)->c + 1;
                mst2crm_yixi[1] = (*ll_xiyi)->l + 1;
                mst2crm_yixi += 2;
                ll_xiyi = &(*ll_xiyi)->next;
            }
            
        }
    }
    printf("a\n");
    /* Freeing memories */
    for(xi=0;xi<S_mst;xi++){
        for(yi=0;yi<L_mst;yi++){
            while(mst2crm_llmat[xi][yi] != NULL){
                ll_curr   = mst2crm_llmat[xi][yi];
                mst2crm_llmat[xi][yi] = ll_curr->next;
                free(ll_curr);
            }
        }
    }
    free(mst2crm_llmat);
    free(mst2crm_llmat_base);
    
    
}

/* The gateway function */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
    const mxArray *crismFOVcell_onmstimg;
    mwSize S_crm, L_crm;
    int16_t **crismFOV_sofst_onmstimg, **crismFOV_lofst_onmstimg;
    int16_t **crismFOV_smpls_onmstimg, **crismFOV_lines_onmstimg;
    mxArray *mapper_mst2crm;
    mwSize S_mst, L_mst;
    

    /* -----------------------------------------------------------------
     * CHECK PROPER NUMBER OF INPUTS AND OUTPUTS
     * ----------------------------------------------------------------- */
    if(nrhs!=7) {
        mexErrMsgIdAndTxt("msl_create_mapper_crism2mastcam_mex:nrhs","Seven inputs required.");
    }
    if(nlhs!=1) {
        mexErrMsgIdAndTxt("msl_create_mapper_crism2mastcam_mex:nlhs","One output required.");
    }
    /* -----------------------------------------------------------------
     * I/O SETUPs
     * ----------------------------------------------------------------- */
    
    /* INPUT 0 FOVcell */
    crismFOVcell_onmstimg = prhs[0];
    L_crm = mxGetM(prhs[0]);
    S_crm = mxGetN(prhs[0]);
    
    /* INPUT 1 sample offset of the each of the FOVcells projecting to MASTCAM image  */
    crismFOV_sofst_onmstimg = set_mxInt16Matrix(prhs[1]);
    
    /* INPUT 2 line offset of the each of the FOVcells projecting to MASTCAM image  */
    crismFOV_lofst_onmstimg = set_mxInt16Matrix(prhs[2]);
    
    /* INPUT 3 #samples of the each of the FOVcells projecting to MASTCAM image  */
    crismFOV_smpls_onmstimg = set_mxInt16Matrix(prhs[3]);
    
    /* INPUT 4 #samples of the each of the FOVcells projecting to MASTCAM image  */
    crismFOV_lines_onmstimg = set_mxInt16Matrix(prhs[4]);
    
    /* INPUT 5/6 samples and lines for MASTCAM image  */
    S_mst = (mwSize) mxGetScalar(prhs[5]);
    L_mst = (mwSize) mxGetScalar(prhs[6]);
    
    /* OUTPUT 0 mapper_mastcam2crism*/
    mapper_mst2crm = mxCreateCellMatrix(L_mst,S_mst);
    plhs[0] = mapper_mst2crm;
    
    printf("a\n");
    /* -----------------------------------------------------------------
     * CALL MAIN COMPUTATION ROUTINE
     * ----------------------------------------------------------------- */
    create_mapper_mastcam2crism(
            crismFOVcell_onmstimg, (int32_t) S_crm, (int32_t) L_crm,
            crismFOV_sofst_onmstimg,crismFOV_lofst_onmstimg,
            crismFOV_smpls_onmstimg,crismFOV_lines_onmstimg,
            mapper_mst2crm, (int32_t) S_mst, (int32_t) L_mst
        );
    
    /* free memories */
    mxFree(crismFOV_sofst_onmstimg);
    mxFree(crismFOV_lofst_onmstimg);
    mxFree(crismFOV_smpls_onmstimg);
    mxFree(crismFOV_lines_onmstimg);    
}