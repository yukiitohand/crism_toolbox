/* =====================================================================
 * crism_gale_get_msldemFOVcell_PFF_L2fa2_mex.c
 * Fast approximation (based on )
 * 
 * INPUTS:
 * 0 msldem_imgpath        char* path to the image
 * 1 msldem_hdr            EnviHeader
 * 2 mslrad_offset         Double Scalar
 * 3 msldemc_imFOVhdr      Struct
 * 4 msldemc_latitude      Double array [msldem_lines]
 * 5 msldemc_longitude     Double array [msldem_samples]
 * 6 msldemc_imFOVmask     
 * 7 lList_lofst           int32 scalar
 * 8 lList_lines           int32 scalar
 * 9 lList_cofst           int32 [msldemc_lines x 1]
 * 10 lList_cols           int32 [msldemc_lines x 1]
 * 11 cahv_mdl             CAHV_MODEL
 * 12 crism_PmCctr_imxy    Double array [2 x Ncrism]
 *    xy coord of the pixel centers in the camera image plane.
 * 13 sigma                Double Scalar
 * 14 mrgn                 double scalar
 * 15 thresh               double scalar
 * 
 * OUTPUTS:
 * 0 crism_FOVcell        cell array [Ncrism]
 * 1 crismPxl_sofst       int32 valid samples [1 x Ncrism]
 * 2 crismPxl_smpls       int32 valid samples [1 x Ncrism]
 * 3 crismPxl_lofst       int32 valid samples [1 x Ncrism]
 * 4 crismPxl_lines       int32 valid samples [1 x Ncrism]
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

#include <time.h>

/* main computation routine */
void get_crismFOVcell_msldem_PFF_L2(
        char *msldem_imgpath, EnviHeader msldem_hdr, double mslrad_offset,
        int32_t msldemc_sample_offset, int32_T msldemc_line_offset,
        int32_t msldemc_samples, int32_T msldemc_lines,
        int8_t **msldemc_imFOVmask,
        int32_t lList_lofst, int32_t lList_lines,
        int32_t *lList_cofst, int32_t *lList_cols,
        double *msldemc_latitude, double *msldemc_longitude, 
        CAHV_MODEL cahv_mdl,
        mxArray *crism_FOVcell, int16_t Ncrism,
        int32_t *crismPxl_sofst, int32_t *crismPxl_smpls,
        int32_t *crismPxl_lofst, int32_t *crismPxl_lines,
        double **crismPmCctr_imxy, double sgm_psf, double mrgn, 
        double thresh
        )
{
    long skip_pri;
    long skip_l, skip_r;
    float *elevl;
    size_t ncpy;
    size_t sz=sizeof(float);
    FILE *fid;

    int32_t c,l,cc,ll;
    int16_t xi,xii;
    double *cos_lon, *sin_lon, *cos_lat, *sin_lat;
    double cos_latl, sin_latl, cos_lonc, sin_lonc;
    double radius;
    // float  radius_float;
    double x_iaumars, y_iaumars, z_iaumars;
    double pmcx, pmcy, pmcz;
    double apmc, hpmc, vpmc;
    double x_im, y_im;
    double *cam_C, *cam_A, *cam_H, *cam_V, *cam_Hd, *cam_Vd;
    double hc,vc,hs,vs;
    double *PmCbrd_imxap_min, *PmCbrd_imxap_max;
    double *pxlftprnt; /* pixel footprint */
    double x_min,x_max,y_min,y_max;
    int32_t s0,send,l0,lend,lendp1;
    int32_t sz_c,sz_l;
    
    double Z,sgm_psf2;
    double xctr_xi,d,v,dy2;
    double **msldemc_rad,*msldemc_rad_base;
    int32_t **crismPxl_srngs, **crismPxl_lrngs;
    int32_t *crismPxl_srngs_base, *crismPxl_lrngs_base;
    int16_t x0,xend;
    
    cam_C = cahv_mdl.C; cam_A = cahv_mdl.A; cam_H = cahv_mdl.H; cam_V = cahv_mdl.V;
    hs = cahv_mdl.hs; vs = cahv_mdl.vs; hc = cahv_mdl.hc; vc = cahv_mdl.vc;
    cam_Hd = cahv_mdl.Hdash; cam_Vd = cahv_mdl.Vdash;
    
    sgm_psf2 = (-2) * sgm_psf * sgm_psf;
    Z = sgm_psf * sgm_psf * 2 * M_PI;
    // thrsh = 0.01;
    
    /*********************************************************************/
    /* calculate the projection of crism pixel borders onto camera image 
     * plane. For each pixel, values outside of the borders are not calculated.
     */
    PmCbrd_imxap_min = (double*) malloc(sizeof(double) * (size_t) Ncrism);
    PmCbrd_imxap_max = (double*) malloc(sizeof(double) * (size_t) Ncrism);
    y_max = 0.5+mrgn; y_min = -y_max;
    for(xi=0;xi<Ncrism;xi++){
        PmCbrd_imxap_min[xi] = crismPmCctr_imxy[xi][0] - y_max;
        PmCbrd_imxap_max[xi] = crismPmCctr_imxy[xi][0] + y_max;
    }
    x_min = PmCbrd_imxap_min[0]; x_max = PmCbrd_imxap_max[Ncrism-1];
    // printf("x_min=%f,x_max=%f\n",x_min,x_max);
    
    
    /*********************************************************************/
    createInt32Matrix(&crismPxl_srngs,&crismPxl_srngs_base,(size_t) Ncrism, (size_t) 2);
    createInt32Matrix(&crismPxl_lrngs,&crismPxl_lrngs_base,(size_t) Ncrism, (size_t) 2);
    for(xi=0;xi<Ncrism;xi++){
        crismPxl_srngs[xi][0] = 2147483647;
        crismPxl_lrngs[xi][0] = 2147483647;
        crismPxl_srngs[xi][1] = -1;
        crismPxl_lrngs[xi][1] = -1;
    }
    
    /*********************************************************************/
    cos_lon = (double*) malloc(sizeof(double) * (size_t) msldemc_samples);
    sin_lon = (double*) malloc(sizeof(double) * (size_t) msldemc_samples);
    for(c=0;c<msldemc_samples;c++){
        cos_lon[c] = cos(msldemc_longitude[c]);
        sin_lon[c] = sin(msldemc_longitude[c]);
    }
    
    cos_lat = (double*) malloc(sizeof(double) * (size_t) msldemc_lines);
    sin_lat = (double*) malloc(sizeof(double) * (size_t) msldemc_lines);
    for(l=0;l<msldemc_lines;l++){
        cos_lat[l] = cos(msldemc_latitude[l]);
        sin_lat[l] = sin(msldemc_latitude[l]);
    }
    
    // printf("msldemc_samples=%d,msldemc_lines=%d\n",msldemc_samples,msldemc_lines);
    /*********************************************************************/
    
    /*********************************************************************/
    createDoubleMatrix(&msldemc_rad, &msldemc_rad_base, 
            (size_t) msldemc_samples, (size_t) msldemc_lines);
    
    /*********************************************************************/
    /* Find out crismPxl_srngs and crismPxl_lrngs 
     * Namely, for each pixel, the rectangular area in msldemc minimally 
     * enclosing its footprint. 
     */
    l0 = lList_lofst; lend = l0+lList_lines;
    fid = fopen(msldem_imgpath,"rb");
    /* skip lines */
    skip_pri = (long) msldem_hdr.samples * (long) (msldemc_line_offset+l0) * (long) sz;
    // printf("%d*%d*%d=%ld\n",msldem_header.samples,msldemc_imxy_line_offset,s,skip_pri);
    fseek(fid,skip_pri,SEEK_CUR);
    /* read the data */
    ncpy = sz * (size_t) msldemc_samples;
    elevl = (float*) malloc(ncpy);
    skip_l = (long) sz * (long) msldemc_sample_offset;
    skip_r = ((long) msldem_hdr.samples - (long) msldemc_samples)* (long) sz - skip_l;
    
    // strt_time = clock();
    for(l=l0;l<lend;l++){
        fseek(fid,skip_l,SEEK_CUR);
        fread(elevl,sz,msldemc_samples,fid);
        fseek(fid,skip_r,SEEK_CUR);
        
        // the pixel of NANs should be already masked.
        // for(c=0;c<msldemc_samples;c++){
        //     if(elevl[c]<data_ignore_value_float)
        //         elevl[c] = NAN;
        // }
        
        cos_latl = cos_lat[l];
        sin_latl = sin_lat[l];
        s0 = lList_cofst[l]; send = s0 + lList_cols[l];
        for(c=s0;c<send;c++){
            /* If the pixel is in the FOV */
            if(msldemc_imFOVmask[c][l]>4){
                cos_lonc = cos_lon[c];
                sin_lonc = sin_lon[c];
                radius   = (double) elevl[c] + mslrad_offset;
                msldemc_rad[c][l] = radius;
                /* transform radius-lat-lon to IAU_MARS XYZ */
                x_iaumars = radius * cos_latl * cos_lonc;
                y_iaumars = radius * cos_latl * sin_lonc;
                z_iaumars = radius * sin_latl;
                pmcx = x_iaumars - cam_C[0];
                pmcy = y_iaumars - cam_C[1];
                pmcz = z_iaumars - cam_C[2];
                
                /* transform IAU_MARS to camera image plane */
                apmc = cam_A[0] * pmcx + cam_A[1] * pmcy + cam_A[2] * pmcz;
                vpmc = cam_V[0] * pmcx + cam_V[1] * pmcy + cam_V[2] * pmcz;
                y_im = vpmc / apmc;
                hpmc = cam_H[0] * pmcx + cam_H[1] * pmcy + cam_H[2] * pmcz;
                x_im = hpmc / apmc;
                
                /* Evaluate if the pixel [c][l] belongs to which CRISM image
                 * pixel */
                dy2 = y_im*y_im;
                x0   = (int16_t) floor(x_im-y_max-1);
                xend = (int16_t) ceil(x_im+y_max+1) + 1;
                
                if(x0<0){x0=0;} else if(x0>Ncrism){x0=Ncrism;}
                if(xend<0){xend=0;} else if(xend>Ncrism){xend=Ncrism;}
                for(xii=x0;xii<xend;xii++){
                    if(x_im>PmCbrd_imxap_min[xii] && x_im<PmCbrd_imxap_max[xii]){
                        d = x_im-crismPmCctr_imxy[xii][0];
                        v = exp((d*d+dy2)/sgm_psf2) / Z;

                        if(v>thresh){
                            if(c<crismPxl_srngs[xii][0]) {
                                crismPxl_srngs[xii][0] = c;
                            }
                            if(c>crismPxl_srngs[xii][1]) {
                                crismPxl_srngs[xii][1] = c;
                            }
                            if(l<crismPxl_lrngs[xii][0]) {
                                crismPxl_lrngs[xii][0] = l;
                            }
                            if(l>crismPxl_lrngs[xii][1]) {
                                crismPxl_lrngs[xii][1] = l;
                            }
                        }
                    }

                }

            }
        }
    }
    fclose(fid);
    free(elevl);
    
    
    /*********************************************************************/
    /* Second iteation */
    /* Once the */
    // strt_time = clock();
    for(xi=0;xi<Ncrism;xi++){
        // printf("xi=%d\n",xi);
        s0 = crismPxl_srngs[xi][0]; send = crismPxl_srngs[xi][1]+1;
        l0 = crismPxl_lrngs[xi][0]; lend = crismPxl_lrngs[xi][1]+1;
        sz_c = send - s0;
        sz_l = lend - l0;
        crismPxl_sofst[xi] = s0; crismPxl_smpls[xi] = sz_c;
        crismPxl_lofst[xi] = l0; crismPxl_lines[xi] = sz_l;
        // printf("sz_c=%d,sz_l=%d\n",sz_c,sz_l);
        // printf("xi=%d sz_c=%d,sz_l=%d\n",xi,sz_c,sz_l);
        mxSetCell(crism_FOVcell,(mwIndex) xi,
                mxCreateNumericMatrix((mwSize) sz_l, (mwSize) sz_c, mxDOUBLE_CLASS,mxREAL));
        pxlftprnt = mxGetDoubles(mxGetCell(crism_FOVcell,(mwIndex) xi));
        xctr_xi = crismPmCctr_imxy[xi][0];
        for(c=s0;c<send;c++){
            cos_lonc  = cos_lon[c];
            sin_lonc  = sin_lon[c];
            for(l=l0;l<lend;l++){
                if(msldemc_imFOVmask[c][l]>4){
                    cos_latl = cos_lat[l];
                    sin_latl = sin_lat[l];
                    radius   = msldemc_rad[c][l];
                    x_iaumars = radius * cos_latl * cos_lonc;
                    y_iaumars = radius * cos_latl * sin_lonc;
                    z_iaumars = radius * sin_latl;
                    pmcx = x_iaumars - cam_C[0];
                    pmcy = y_iaumars - cam_C[1];
                    pmcz = z_iaumars - cam_C[2];
                    apmc = cam_A[0] * pmcx + cam_A[1] * pmcy + cam_A[2] * pmcz;
                    vpmc = cam_V[0] * pmcx + cam_V[1] * pmcy + cam_V[2] * pmcz;
                    y_im = vpmc / apmc;
                    hpmc = cam_H[0] * pmcx + cam_H[1] * pmcy + cam_H[2] * pmcz;
                    x_im = hpmc / apmc;
                    
                    if(x_im>PmCbrd_imxap_min[xi] && x_im<PmCbrd_imxap_max[xi]){
                        d = x_im-xctr_xi;
                        v = exp((d*d+y_im*y_im)/sgm_psf2) / Z;
                        if(v>thresh){
                            pxlftprnt[(c-s0)*sz_l+l-l0] = v;
                        }
                    } else {
                        pxlftprnt[(c-s0)*sz_l+l-l0] = 0L;
                    }
                }
            }
        }
    }
    free(cos_lon);
    free(sin_lon);
    free(cos_lat);
    free(sin_lat);
    free(PmCbrd_imxap_min);
    free(PmCbrd_imxap_max);
    free(msldemc_rad);
    free(msldemc_rad_base);
    free(crismPxl_srngs);
    free(crismPxl_srngs_base);
    free(crismPxl_lrngs);
    free(crismPxl_lrngs_base);
    
    
}

/* The gateway function */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
    char *msldem_imgpath;
    EnviHeader msldem_header;
    double mslrad_offset;
    mwSize msldemc_sample_offset,msldemc_line_offset;
    mwSize msldemc_samples,msldemc_lines;
    double *msldemc_latitude;
    double *msldemc_longitude;
    CAHV_MODEL cahv_mdl;
    int8_t **msldemc_imFOVmask;
    int32_t lList_lofst, lList_lines;
    int32_t *lList_cofst, *lList_cols;
    mxArray *crism_FOVcell;
    int32_t *crismPxl_sofst,*crismPxl_smpls;
    int32_t *crismPxl_lofst,*crismPxl_lines;
    double **crism_PmCctr_imxy;
    double sgm_psf;
    double mrgn;
    double thresh;
    
    
    mwSize si,li;
    mwSize Ncrism;
    mwSize sz_FOVcell[2];
    int32_t s0,send,l0,lend;

    /* -----------------------------------------------------------------
     * CHECK PROPER NUMBER OF INPUTS AND OUTPUTS
     * ----------------------------------------------------------------- */
    if(nrhs!=16) {
        mexErrMsgIdAndTxt("crism_gale_get_msldemFOVcell_PFF_L2fa2_mex:nrhs","16 inputs required.");
    }
    if(nlhs!=5) {
        mexErrMsgIdAndTxt("crism_gale_get_msldemFOVcell_PFF_L2fa2_mex:nlhs","5 outputs required.");
    }
    
    /* make sure the first input argument is scalar */
    
    if( !mxIsChar(prhs[0]) ) {
        mexErrMsgIdAndTxt("crism_gale_get_msldemFOVcell_PFF_L2fa2_mex:notChar","Input 0 needs to be a character vector.");
    }
    
    /* -----------------------------------------------------------------
     * I/O SETUPs
     * ----------------------------------------------------------------- */
    
    /* INPUT 0 msldem_imgpath */
    msldem_imgpath = mxArrayToString(prhs[0]);
    
    /* INPUT 1 msldem_header and 2 radius offset */
    msldem_header = mxGetEnviHeader(prhs[1]);
    mslrad_offset     = mxGetScalar(prhs[2]);
    
    /* INPUT 3 msldemc_sheader*/
    msldemc_sample_offset = (mwSize) mxGetScalar(mxGetField(prhs[3],0,"sample_offset"));
    msldemc_line_offset   = (mwSize) mxGetScalar(mxGetField(prhs[3],0,"line_offset"));
    msldemc_samples       = (mwSize) mxGetScalar(mxGetField(prhs[3],0,"samples"));
    msldemc_lines         = (mwSize) mxGetScalar(mxGetField(prhs[3],0,"lines"));
    
    /* INPUT 4/5 msldem northing easting */
    msldemc_latitude  = mxGetDoubles(prhs[4]) + msldemc_line_offset  ;
    msldemc_longitude = mxGetDoubles(prhs[5]) + msldemc_sample_offset;
    
    /* imFOVmask */
    msldemc_imFOVmask = set_mxInt8Matrix(prhs[6]);
    
    lList_lofst = (int32_t) mxGetScalar(prhs[7]);
    lList_lines = (int32_t) mxGetScalar(prhs[8]);
    lList_cofst = mxGetInt32s(prhs[9]);
    lList_cols  = mxGetInt32s(prhs[10]);
    
    /* Below are CAMERA parameters */
    /* INPUT 9 camera model */
    cahv_mdl = mxGet_CAHV_MODEL(prhs[11]);
    /* INPUT 10 Array of the coordinate of the center of each pixel */
    crism_PmCctr_imxy = set_mxDoubleMatrix(prhs[12]);
    Ncrism = mxGetN(prhs[12]);
    /* INPUT 10 Sigma for the Gaussian of the Point Spread Function */
    sgm_psf = mxGetScalar(prhs[13]);
    /* INPUT 11 mrgn size in pixel you want to consider for pixel footprint (0.5+mrgn) is the wing */
    mrgn = mxGetScalar(prhs[14]);
    /* INPUT 12 threshold for the consideration as a valid footprint */
    thresh  = mxGetScalar(prhs[15]);
    

    
    /* OUTPUT 0 */
    sz_FOVcell[0] = 1;
    sz_FOVcell[1] = Ncrism;
    crism_FOVcell = mxCreateCellArray(2,sz_FOVcell);
    plhs[0] = crism_FOVcell;
    
    
    plhs[1] = mxCreateNumericArray(1,&Ncrism,mxINT32_CLASS,mxREAL);
    crismPxl_sofst = mxGetInt32s(plhs[1]);
    plhs[2] = mxCreateNumericArray(1,&Ncrism,mxINT32_CLASS,mxREAL);
    crismPxl_smpls = mxGetInt32s(plhs[2]);
    plhs[3] = mxCreateNumericArray(1,&Ncrism,mxINT32_CLASS,mxREAL);
    crismPxl_lofst = mxGetInt32s(plhs[3]);
    plhs[4] = mxCreateNumericArray(1,&Ncrism,mxINT32_CLASS,mxREAL);
    crismPxl_lines = mxGetInt32s(plhs[4]);
        
    
    // Initialize matrices
    // printf("sim = %d\n",S_im);
    /* -----------------------------------------------------------------
     * CALL MAIN COMPUTATION ROUTINE
     * ----------------------------------------------------------------- */
    
    get_crismFOVcell_msldem_PFF_L2(
        msldem_imgpath, msldem_header, mslrad_offset,
        (int32_t) msldemc_sample_offset, (int32_t) msldemc_line_offset,
        (int32_t) msldemc_samples, (int32_t) msldemc_lines,
        msldemc_imFOVmask,lList_lofst,lList_lines,lList_cofst,lList_cols,
        msldemc_latitude, msldemc_longitude, 
        cahv_mdl,
        crism_FOVcell, (int16_t) Ncrism,
        crismPxl_sofst, crismPxl_smpls, crismPxl_lofst, crismPxl_lines,
        crism_PmCctr_imxy, sgm_psf, mrgn, thresh);
    
    /* free memories */
    mxFree(msldem_imgpath);
    mxFree(msldemc_imFOVmask);
    mxFree(crism_PmCctr_imxy);
    
    
}
