/* =====================================================================
 * crism_gale_get_lonlatwndw_wRadiusMaxMin_mex.c
 * Return the range of samples and lines for the FOV of each detector cell. 
 * 
 * INPUTS:
 * 0 pos_mro_wrt_mars      Double [3 x 1] length vector
 * 1 pmc_pxlvrtcsCell      Cell array [1 x 640]. Each cell stores the cell 
 *                         vertex vector.
 * 2 radius_min            Double Scalar, lower limit of the radius
 * 3 radius_max            Double Scalar, upper limit of the radius
 * 
 * OUTPUTS:
 * 0 lon_min_crism      valid samples [2 x Ncrism] in degree
 * 1 lon_max_crism      valid samples [2 x Ncrism] in degree
 * 2 lat_min_crism      valid lines   [2 x Ncrism] in degree
 * 3 lat_max_crism      valid lines   [2 x Ncrism] in degree
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
#include "SpiceUsr.h"

/* main computation routine */
void crism_gale_get_latlonwndw_wRadiusMaxMin(double *pos_mro_wrt_mars,
        const mxArray *pmc_pxlvrtcsCell, mwSize Ncrism,
        double radius_min, double radius_max,
        double *lon_min_crism, double *lon_max_crism,
        double *lat_min_crism, double *lat_max_crism
        )
{
    mwSize i,ni,Ni;
    double *pmci;
    int found;
    SpiceDouble point[3];
    double radius;
    double longitude;
    double latitude;
    mxArray *pmci_mxar;
    double degprad;
    
    degprad = dpr_c();
    
    for(i=0;i<Ncrism;i++){
        pmci_mxar = mxGetCell(pmc_pxlvrtcsCell,i);
        pmci = mxGetDoubles(pmci_mxar);
        Ni   = mxGetN(pmci_mxar);
        for(ni=0;ni<Ni;ni++){
            surfpt_c( pos_mro_wrt_mars, pmci+ni*3, 
                    radius_min, radius_min, radius_min, point, &found);
            if(found){
                reclat_c( point, &radius, &longitude, &latitude);
                // longitude *= degprad;
                // latitude *= degprad;
                if(latitude<lat_min_crism[i]){
                    lat_min_crism[i] = latitude;
                }
                if(latitude>lat_max_crism[i]){
                    lat_max_crism[i] = latitude;
                }
                if(longitude<lon_min_crism[i]){
                    lon_min_crism[i] = longitude;
                }
                if(longitude>lon_max_crism[i]){
                    lon_max_crism[i] = longitude;
                }
            }
            
            surfpt_c( pos_mro_wrt_mars, pmci+ni*3, 
                    radius_max, radius_max, radius_max, point, &found);
            if(found){
                reclat_c( point, &radius, &longitude, &latitude);
                // longitude *= degprad;
                // latitude *= degprad;
                if(latitude<lat_min_crism[i]){
                    lat_min_crism[i] = latitude;
                }
                if(latitude>lat_max_crism[i]){
                    lat_max_crism[i] = latitude;
                }
                if(longitude<lon_min_crism[i]){
                    lon_min_crism[i] = longitude;
                }
                if(longitude>lon_max_crism[i]){
                    lon_max_crism[i] = longitude;
                }
            }
            
        }
        
        lat_min_crism[i] *= degprad;
        lat_max_crism[i] *= degprad;
        lon_min_crism[i] *= degprad;
        lon_max_crism[i] *= degprad;

    }
    
}

/* The gateway function */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
    double *pos_mro_wrt_mars;
    const mxArray *pmc_pxlvrtcsCell;
    double radius_max;
    double radius_min;
    double *lon_min_crism;
    double *lon_max_crism;
    double *lat_min_crism;
    double *lat_max_crism;
    
    mwSize i,Ncrism;

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
    
    /* INPUT 0 position of MRO with regard to Mars */
    pos_mro_wrt_mars = mxGetDoubles(prhs[0]);
    

    /* INPUT 1 cell array storing (P-C) of the vertices of each pixel */
    pmc_pxlvrtcsCell = prhs[1];
    Ncrism = mxGetNumberOfElements(pmc_pxlvrtcsCell);
    
    /* INPUT 2/3 upper and lower limit of radius */
    radius_min = mxGetScalar(prhs[2]);
    radius_max = mxGetScalar(prhs[3]);
    
    /* OUTPUT 0/1/2/3/4 */
    plhs[0] = mxCreateNumericMatrix(1,Ncrism,mxDOUBLE_CLASS,mxREAL);
    lon_min_crism = mxGetDoubles(plhs[0]);
    
    plhs[1] = mxCreateNumericMatrix(1,Ncrism,mxDOUBLE_CLASS,mxREAL);
    lon_max_crism = mxGetDoubles(plhs[1]);
    
    plhs[2] = mxCreateNumericMatrix(1,Ncrism,mxDOUBLE_CLASS,mxREAL);
    lat_min_crism = mxGetDoubles(plhs[2]);
    
    plhs[3] = mxCreateNumericMatrix(1,Ncrism,mxDOUBLE_CLASS,mxREAL);
    lat_max_crism = mxGetDoubles(plhs[3]);
    
    // Initialize matrices
    for(i=0;i<Ncrism;i++){
        lon_min_crism[i] =  INFINITY;
        lon_max_crism[i] = -INFINITY;
        lat_min_crism[i] =  INFINITY;
        lat_max_crism[i] = -INFINITY;
    }
    
    crism_gale_get_latlonwndw_wRadiusMaxMin(pos_mro_wrt_mars,
        pmc_pxlvrtcsCell, Ncrism, radius_min, radius_max,
        lon_min_crism, lon_max_crism, lat_min_crism, lat_max_crism);
    
    
}

