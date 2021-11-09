/* =====================================================================
 * crism_vscor_patch_vs_artifact_v2_internal_mex.c
 * Perform CRISM volcano scan artifact correction
 * 
 * INPUTS:
 * 0 img_corr        [L x S x B] double image cube
 * 1 interp_bands    [2 x S] double matrix (-1 is the invalid value)
 * 2 vsart           [1 x S x B] double image cube
 * 3 avg_cont        [L x S] double matrix
 * 4 wng             double scalar
 * 
 * 
 * 
 * OUTPUTS:
 * 0  img_corr_patched     [L x S x B]  double image cube
 * 1  scale_factor         [L x S] double matrix
 * 2  outeval              [L x S] double matrix
 * 3  status               [L x S] int8 image cube
 * 
 *
 *
 * This is a MEX file for MATLAB.
 * ===================================================================== */
#include <stdint.h>
#include "mex.h"
#include "math.h"
#include "matrix.h"
#include <string.h>
#include <stdio.h>

#include <stdlib.h>
#include "envi.h"
#include "mex_create_array.h"

/* int cmpfunc_double(const void * a, const void * b)
 * The input variables are interpreted as double pointer and compared.
 * 
 */
int cmpfunc_double (const void * a, const void * b)
{
  if (*(double*)a > *(double*)b)
    return 1;
  else if (*(double*)a < *(double*)b)
    return -1;
  else
    return 0;  
}

/* void movmean(double *x, int32_t N, int32_t wng, double *x_out)
 *  Moving mean is calculated to the first N elements of the array *x and 
 *  stored to *x_out
 *  dobule *x     : input double array on which moving mean is calculated.
 *   N elements must be present.
 *  int32_t N     : the number of elemetns of *x (and *x_out)
 *  int32_t wng   : size of the wing, average window size would be wng*2+1
 *  double *x_out : output double array (need to be already allocated)
 */
void movmean(double *x, int32_t N, int32_t wng, double *x_out)
{
    int32_t n; /* counter */
    int32_t w; /* width w=wng*2+1 */
    double v, w_dbl;
    
    /* First, fill the edge pixels */
    // memcpy(x,x_out,((size_t) N)*sizeof(double));
    for(n=0;n<wng;n++){
        x_out[n]     = x[n];
        x_out[N-n-1] = x[N-n-1];
    }

    
    w = wng*2+1;
    w_dbl = (double) w;

    /* First get the moving mean of the first valid element x_out[wng] */
    v = 0;
    for(n=0;n<w;n++){
        v += x[n];
    }
    x_out[wng] = v / w_dbl;
    
    /* Fast update */
    for(n=wng+1;n<N-wng;n++){
        x_out[n] = x_out[n-1] + (x[n+wng]-x[n-wng-1]) / w_dbl;
    }

}
/* double evaluate_catvs_patch_2(double *patch, double *patch_smooth, 
                              double *dp, double *corr,double *dart,
                              int32_t N, int32_t wng)
 * Obtain the merit of the correction
 *  double *patch        : N elements must exist
 *  double *patch_smooth : N elements must exist
 *  double *dp           : N elements must exist
 *  double *corr         : (N-6) elements must exist
 *  double *dart         : N elements must exist
 *  int32_t N            : number of elemtns of *patch
 *  int32_t wng          : wing of the window of the moving mean
 *  Return
 *  double merit         : merit of the correction
 */
double evaluate_catvs_patch_2(double *patch, double *patch_smooth, 
                              double *dp, double *corr,double *dart,
                              int32_t N, int32_t wng)
{
    int32_t n;
    int32_t N_DROP;
    int32_t Ncorr;
    double merit;
    int32_t ndrp1, ndrp;
    
    N_DROP = 3;
    Ncorr  = N - 6;
    
    /* Perform moving mean to get smoothen signal */
    movmean(patch,N,wng,patch_smooth);

    for(n=0;n<N;n++){
        dp[n] = patch[n] - patch_smooth[n];
    }
    
    /* Get correlation and sort */
    for(n=0;n<Ncorr;n++){
        corr[n] = dp[n+3] * dart[n+3];
    }
    qsort(corr, Ncorr, sizeof(double), cmpfunc_double);
    ndrp1 = (int32_t) floor( (Ncorr-5)/2 );
    ndrp1 = ndrp1 < N_DROP ? ndrp1 : N_DROP;
    ndrp  = ndrp1 > 0 ? ndrp1 : 0;
    // ndrp = max( min( N_DROP , (int32_t) floor( (Ncorr-5)/2 ) ) , 0 );

    merit = 0;
    for(n=ndrp;n<Ncorr-ndrp;n++)
        merit += corr[n];

    return merit;


}


void patch_vs_artifact_v2(double *img_corr, int32_t L, int32_t S, int32_t B,
                          int32_t **interp_bands, 
                          double *vsart, double **avg_cont, int32_t wng,
                          double *img_corr_patched,
                          double **scale_factor, double **outeval,
                          int8_t **status)
{
    int32_t c,l,ib,n;
    int32_t ib1, ib2;
    int32_t Bx,N_SL;
    double *img_corr_clx;
    double *art_clx,*art_clx_smooth,*dart;
    double img_corr_clb, art_clb;
    bool *bdxes_valid_cl;
    double avg_cont_cl;
    double merit,merit2,dscl,scl_fac,scl_fac2;
    int32_t niter;
    double *patchx, *patchx2, *patchx_smooth, *dp, *corr;
    double delta,dmds;
    int32_t MAXITER;
    
    N_SL = S*L;
    MAXITER = 10;
    
    /* Instead of doing malloc inside, dynamically allocate here */
    img_corr_clx   = malloc(sizeof(double) * (size_t) B);
    art_clx        = malloc(sizeof(double) * (size_t) B);
    art_clx_smooth = malloc(sizeof(double) * (size_t) B);
    dart           = malloc(sizeof(double) * (size_t) B);
    patchx         = malloc(sizeof(double) * (size_t) B);
    patchx2        = malloc(sizeof(double) * (size_t) B);
    patchx_smooth  = malloc(sizeof(double) * (size_t) B);
    dp             = malloc(sizeof(double) * (size_t) B);
    corr           = malloc(sizeof(double) * (size_t) B);

    bdxes_valid_cl = malloc(sizeof(bool) * (size_t) B);

    for(c=0;c<S;c++){
        ib1 = interp_bands[c][0];
        ib2 = interp_bands[c][1];
        // printf("ib1=%d ib2=%d\n",ib1,ib2);
        /* Only if interp_bands are valid */
        if(ib1 > -1 && ib2 > -1){
            ib2++;
            for(l=0;l<L;l++){
                /* Extract a spectrum at (c,l) */
                Bx = 0;
                for(ib=ib1;ib<ib2;ib++){
                    img_corr_clb = img_corr[N_SL*ib+L*c+l];
                    art_clb = vsart[S*ib+c];
                    bdxes_valid_cl[ib] = ( !isnan(img_corr_clb) && !isnan(art_clb) );
                    /* Betwen interp_bands, only extract valid bands */
                    if(bdxes_valid_cl[ib]){
                        img_corr_clx[Bx] = img_corr_clb;
                        art_clx[Bx]      = art_clb;
                        Bx++;
                    }
                }
                /* img_corr_clx,art_cls: first Bx elements are of interest */
                avg_cont_cl = avg_cont[c][l];
                if(Bx>8 && !isnan(avg_cont_cl)){
                    
                    /* precompute dart instead of doing so in the merit function */
                    movmean(art_clx,Bx,wng,art_clx_smooth);
                    for(n=0;n<Bx;n++){
                        dart[n] = art_clx[n] - art_clx_smooth[n];
                    }

                    merit   = 1.0e23;
                    dscl    = 1.0e23;
                    scl_fac = 1.0;
                    niter   = 0;
                    while( (fabs(merit)>1.0e-6) && (fabs(dscl)>1.0e-4) ){
                        for(n=0;n<Bx;n++){
                            patchx[n] = img_corr_clx[n] + avg_cont_cl *scl_fac * art_clx[n];
                        }
                        merit  = evaluate_catvs_patch_2(
                            patchx, patchx_smooth, dp, corr, dart, Bx, wng);
                        delta  = fmax(fabs(scl_fac)*1.0e-3, 0.0003);
                        scl_fac2 = scl_fac + delta;
                        for(n=0;n<Bx;n++){
                            patchx2[n] = img_corr_clx[n] + avg_cont_cl * scl_fac2 * art_clx[n];
                        }
                        /* patchx_smooth, dp, corr are overwritten. It's okay.
                           Not used for further processing */
                        merit2 = evaluate_catvs_patch_2(
                            patchx2, patchx_smooth, dp, corr, dart, Bx, wng);
                        dmds   = (merit2-merit) / delta;
                        if(isinf(merit) || isinf(merit2)){
                            status[c][l] = -2; scl_fac = 0;
                            break;
                        }
                        if(isnan(merit) || isnan(merit2)){
                            status[c][l] = -2; scl_fac = 0;
                            break;
                        }
                        if(fabs(dmds)<1e-23){
                            status[c][l] = -3; scl_fac = 0;
                            break;
                        }
                        dscl = -merit/dmds;
                        scl_fac += dscl;
                        niter++;
                        if(niter>MAXITER){
                            status[c][l] = -4; scl_fac = 0.0;
                            break;
                        }
                    }
                    scale_factor[c][l] = scl_fac;
                    outeval[c][l]      = merit;

                    /* Apply the correction to the output image cube.
                     * This is a little tricky since */
                    ib = ib1;
                    for(n=0;n<Bx;n++){
                        while(!bdxes_valid_cl[ib]){
                            ib++;
                        }
                        img_corr_patched[N_SL*ib+L*c+l] += avg_cont_cl *scl_fac * art_clx[n];
                    }

                }
            }
        }
    }

    free(img_corr_clx);
    free(art_clx);
    free(art_clx_smooth);
    free(dart);
    free(patchx);
    free(patchx2);
    free(patchx_smooth);
    free(dp);
    free(corr);
    free(bdxes_valid_cl);
}


/* The gateway function */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
    double *img_corr;
    const mwSize *sz_img;
    mwSize L, S, B;
    int32_t **interp_bands;
    double *vsart;
    double **avg_cont;
    int32_t wng;
    double *img_corr_patched;
    double **scale_factor;
    double **outeval;
    int8_t **status;
    mwSize m,n,Nelem;
    //clock_t strt_time, end_time;
    //double cpu_time_used;

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
    
    /* INPUT 0 img_corr */
    img_corr = mxGetDoubles(prhs[0]);
    sz_img   = mxGetDimensions(prhs[0]);
    L = sz_img[0]; S = sz_img[1]; B = sz_img[2];
    Nelem = L * S * B;

    /* INPUT 1 interp_bands */
    interp_bands = set_mxInt32Matrix(prhs[1]);
    
    /* INPUT 2 vsart */
    vsart = mxGetDoubles(prhs[2]);

    /* INPUT 3 avg_cont */
    avg_cont = set_mxDoubleMatrix(prhs[3]);
    
    /* INPUT 4 wng */
    wng = (int32_t) mxGetScalar(prhs[4]);
    
    /* OUTPUT 0 img_corr_patched */
    plhs[0] = mxCreateNumericArray(3, sz_img, mxDOUBLE_CLASS, mxREAL);
    img_corr_patched = mxGetDoubles(plhs[0]);

    /* OUTPUT 1 scale_factor */
    plhs[1] = mxCreateDoubleMatrix(L,S,mxREAL);
    scale_factor = set_mxDoubleMatrix(plhs[1]);

    /* OUTPUT 2 outeval */
    plhs[2] = mxCreateDoubleMatrix(L,S,mxREAL);
    outeval = set_mxDoubleMatrix(plhs[2]);

    /* OUTPUT 1 scale_factor */
    plhs[3] = mxCreateNumericMatrix(L,S,mxINT8_CLASS,mxREAL);
    status  = set_mxInt8Matrix(plhs[3]);
    
    // Initialize OUTPUTS
    for(n=0;n<Nelem;n++){
        img_corr_patched[n] = img_corr[n];
    }
    for(n=0;n<S;n++){
        for(m=0;m<L;m++){
            scale_factor[n][m] = 0;
            outeval[n][m] = NAN;
            status[n][m]  = 0;
        }
    }
    printf("a\n");
    /* Main computation routine */
    patch_vs_artifact_v2(img_corr,(int32_t) L,(int32_t) S,(int32_t)B, 
                         interp_bands, vsart, avg_cont, (int32_t) wng,
                         img_corr_patched,scale_factor,outeval,
                         status);
    
    
    mxFree(interp_bands);
    mxFree(avg_cont);
    mxFree(scale_factor);
    mxFree(outeval);
    mxFree(status);

    
}