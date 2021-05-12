/* =====================================================================
 * crism_rotate_pmcFOVcell_mex.c
 * Rotate (P-C) vectors stored in the cell array. 
 * 
 * INPUTS:
 * 0 pmc_pxlvrtcsCell      Cell array [1 x 640]. Each cell stores the cell 
 *                         vertex vector.
 * 1 R                     3 x 3, rotational matrix
 * 
 * OUTPUTS:
 * 0 pmc_pxlvrtcsCell_new  Cell array [1 x 640]. Each cell stores the cell 
 *                         vertex vectors.
 *
 * This is a MEX file for MATLAB.
 *
 * Copyright (C) 2021 Yuki Itoh <yukiitohand@gmail.com>
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


/* The gateway function */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
    double *pos_mro_wrt_mars;
    const mxArray *pmc_pxlvrtcsCell;
    double *pmci, *pmci_out;
    double **R;
    mxArray *pmc_pxlvrtcsCellnew;
    
    mwSize Ncrism;
    mwSize sz_cell[2];
    mwSize i,n,Ni;

    /* -----------------------------------------------------------------
     * CHECK PROPER NUMBER OF INPUTS AND OUTPUTS
     * ----------------------------------------------------------------- */
    if(nrhs!=2) {
        mexErrMsgIdAndTxt("crism_rotate_pmcFOVcell_mex:nrhs","Two inputs required.");
    }
    if(nlhs!=1) {
        mexErrMsgIdAndTxt("crism_rotate_pmcFOVcell_mex:nlhs","One output required.");
    }
    
    /* make sure the first input argument is scalar */
    if( !mxIsCell(prhs[0]) ) {
        mexErrMsgIdAndTxt("crism_rotate_pmcFOVcell_mex:notCell","Input 0 needs to be a cell array.");
    }
    if( !mxIsDouble(prhs[1]) ) {
        mexErrMsgIdAndTxt("crism_rotate_pmcFOVcell_mex:notDouble","Input 1 needs to be a double matrix.");
    }
    if( mxGetM(prhs[1])!=3 || mxGetN(prhs[1])!=3 ) {
        mexErrMsgIdAndTxt("crism_rotate_pmcFOVcell_mex:wrongSize","Input 1 needs to be a 3x3 matrix.");
    }
    /* -----------------------------------------------------------------
     * I/O SETUPs
     * ----------------------------------------------------------------- */
    
    /* INPUT 0 cell array storing (P-C) of the vertices of each pixel */
    pmc_pxlvrtcsCell = prhs[0];
    Ncrism = mxGetNumberOfElements(pmc_pxlvrtcsCell);
    
    /* INPUT 1 rotation matrix */
    R = set_mxDoubleMatrix(prhs[1]);
    
    
    /* OUTPUT 0 msldem imFOV */
    sz_cell[0] = 1;
    sz_cell[1] = Ncrism;
    pmc_pxlvrtcsCellnew = mxCreateCellArray(2,sz_cell);
    plhs[0] = pmc_pxlvrtcsCellnew;
    
    
    /* Actual computation */
    for(i=0;i<Ncrism;i++){
        pmci = mxGetDoubles(mxGetCell(pmc_pxlvrtcsCell,i));
        /* Get the number of vertices, namely columns */
        Ni = mxGetN(mxGetCell(pmc_pxlvrtcsCell,i));
        /* preparation of the output pmc vectors */
        mxSetCell(pmc_pxlvrtcsCellnew,i,mxCreateDoubleMatrix(3,Ni,mxREAL));
        pmci_out =mxGetDoubles(mxGetCell(pmc_pxlvrtcsCellnew,i));
        /* rotation */
        for(n=0;n<Ni;n++){
            pmci_out[n*3]   = R[0][0] * pmci[n*3] + R[1][0] * pmci[n*3+1] + R[2][0] * pmci[n*3+2];
            pmci_out[n*3+1] = R[0][1] * pmci[n*3] + R[1][1] * pmci[n*3+1] + R[2][1] * pmci[n*3+2];
            pmci_out[n*3+2] = R[0][2] * pmci[n*3] + R[1][2] * pmci[n*3+1] + R[2][2] * pmci[n*3+2];
        }
    }
    
    mxFree(R);
    
    
}