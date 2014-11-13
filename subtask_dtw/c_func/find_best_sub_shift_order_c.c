/**
 * Copyright (C) 2013 Quan Wang <wangq10@rpi.edu>,
 * Signal Analysis and Machine Perception Laboratory,
 * Department of Electrical, Computer, and Systems Engineering,
 * Rensselaer Polytechnic Institute, Troy, NY 12180, USA
 */

/** 
 * This is the C/MEX code of dynamic time warping of two signals
 *
 * compile: 
 *     mex dtw_c.c
 *
 * usage:
 *     d=dtw_c(s,t)  or  d=dtw_c(s,t,w)
 *     where s is signal 1, t is signal 2, w is window parameter 
 */

#include "mex.h"
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <string.h>

typedef struct
{
    int *ts1_idx;
    int *ts2_idx;
    int ns;
    int nt;
    double best_coeff;
} Output;


double corrcoef_c(double *ts1, double *ts2, int n)
{
    int i; 
    double xy, xsquare, ysquare, xsum, ysum, xysum, xsqr_sum, ysqr_sum;
    double num, deno;

    xsum = 0;
    ysum = 0;
    xysum = 0;
    xsqr_sum = 0;
    ysqr_sum = 0;

    for (i = 0; i < n; i ++) {
        xy = ts1[i] * ts2[i];
        xsquare = ts1[i] * ts1[i];
        ysquare = ts2[i] * ts2[i];
        xsum += ts1[i];
        ysum += ts2[i];
        xysum += xy;
        xsqr_sum += xsquare;
        ysqr_sum += ysquare;
    }

    num = (n * xysum) - (xsum * ysum);
    deno = (n * xsqr_sum - xsum * xsum) * (n * ysqr_sum - ysum * ysum);

    return (num / sqrt(deno));
}


/* double dtw_c(double *s, double *t, int w, int ns, int nt, int k) */
Output find_best_sub_shift_order_c(double *s, double *t, int ns, int nt)
{
    int i;
    int *ts1_idx, *ts2_idx;
    int *pad_ts2_idx;
    double *pad_ts2;
    double best_coeff, this_coeff;
    int best_nt;
    int offset;
    int num_pad_before, num_pad_after;
    Output ret;
    
    
    best_coeff = -1;

    ts1_idx = (int *)malloc( ns * sizeof(int *) );
    for(i = 0; i < ns; i ++) {
        ts1_idx[i] = i + 1;
    }

    ts2_idx = (int *)malloc( ns * sizeof(int *) );
    for(i = 0; i < ns; i ++) {
        if(i < nt) {
            ts2_idx[i] = i + 1;
        }
        else {
            ts2_idx[i] = nt;
        }
    }
    best_nt = nt;


    for(offset = 1; offset <= 1+ns-nt; offset ++) {
        num_pad_before = offset - 1;
        num_pad_after  = ns - nt - offset + 1;

        pad_ts2 = (double *)malloc( (num_pad_before+nt+num_pad_after) * sizeof(double *) );
        pad_ts2_idx = (int *)malloc( (num_pad_before+nt+num_pad_after) * sizeof(int *) );

        for(i = 0; i < num_pad_before+nt+num_pad_after; i ++) {
            /* pad before */
            if(i < num_pad_before) {
                pad_ts2[i] = t[1];
                pad_ts2_idx[i] = 1;
            }
            /* ts2 */
            else if(i < num_pad_before+nt) {
                pad_ts2[i] = t[i-num_pad_before];
                pad_ts2_idx[i] = i - num_pad_before + 1;
            }
            /* pad after */
            else {
                pad_ts2[i] = t[nt-1];
                pad_ts2_idx[i] = nt;
            }
        }

        this_coeff = corrcoef_c(s, pad_ts2, ns);
        if(this_coeff >= best_coeff) {
            best_coeff = this_coeff;
            free(ts2_idx);
            ts2_idx = pad_ts2_idx;
            best_nt = num_pad_before + nt + num_pad_after;
        }
        else {
            free(pad_ts2_idx);
        }
        free(pad_ts2);
    }

    ret.ts1_idx = ts1_idx;
    ret.ts2_idx = ts2_idx;
    ret.ns = ns;
    ret.nt = ns;
    ret.best_coeff = best_coeff;
    return ret;
}

/* the gateway function */
void mexFunction( int nlhs, mxArray *plhs[],
        int nrhs, const mxArray *prhs[])
{
    int i;

    double *s, *t;
    int ns, nt;

    int *ts1_idx, *ts2_idx;
    double *best_coeff;
    Output ret;
    

    
    /*  check for proper number of arguments */
    if(nrhs!=2)
    {
        mexErrMsgIdAndTxt( "MATLAB:find_best_sub_shift_order_c:invalidNumInputs",
                "Two inputs required.");
    }
    if(nlhs != 3)
    {
        mexErrMsgIdAndTxt( "MATLAB:find_best_sub_shift_order_c:invalidNumOutputs",
                "find_best_sub_shift_order_c: Three output required.");
    }
    
    
    
    /*  create a pointer to the input matrix s */
    s = mxGetPr(prhs[0]);
    
    /*  create a pointer to the input matrix t */
    t = mxGetPr(prhs[1]);
    
    /*  get the dimensions of the matrix input s */
    ns = mxGetN(prhs[0]);
    
    /*  get the dimensions of the matrix input t */
    nt = mxGetN(prhs[1]);
    

    ret = find_best_sub_shift_order_c(s,t,ns,nt);
    plhs[0] = mxCreateNumericMatrix( 1, ret.ns, mxINT32_CLASS, mxREAL); /* ts1_idx */
    plhs[1] = mxCreateNumericMatrix( 1, ret.nt, mxINT32_CLASS, mxREAL); /* ts2_idx */
    plhs[2] = mxCreateDoubleMatrix( 1, 1, mxREAL); /* best_coeff */
    
    ts1_idx = (int *)mxGetPr(plhs[0]);
    ts2_idx = (int *)mxGetPr(plhs[1]);
    for(i = 0; i < ret.ns; i++) {
        ts1_idx[i] = ret.ts1_idx[i];
        ts2_idx[i] = ret.ts2_idx[i];
    }

    best_coeff = (double *)mxGetData(plhs[2]);
    best_coeff[0] = ret.best_coeff;
    
    return;
    
}

