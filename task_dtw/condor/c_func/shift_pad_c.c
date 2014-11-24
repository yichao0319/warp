/*****************************
shift_pad:
idx: -2 -1  0  1  2  3  4  5  6  7  8
ts1:        1  2  3  4  5  6
ts2:  1  2  3  
******************************/

#include "mex.h"
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <string.h>

typedef struct
{
    int *idx1_padded;
    int *idx2_padded;
    int len;
} Output;


/* double dtw_c(double *s, double *t, int w, int ns, int nt, int k) */
Output shift_pad_c(int len1, int len2, int idx)
{
    int i;
    int final_len;
    int *idx1_padded, *idx2_padded;
    Output ret;

    
    final_len = len1;
    if(idx < 0) {
        final_len -= idx;
    }
    if(idx + len2 > len1) {
        final_len += (idx + len2 - len1);
    }
    idx1_padded = (int *)malloc(final_len * sizeof(int *));
    idx2_padded = (int *)malloc(final_len * sizeof(int *));

    for(i = 0; i < final_len; ++i) {
        /* ts1 */
        if(idx < 0) {
            if(i < -idx) {
                idx1_padded[i] = 1;
            }
            else if(i < (len1-idx)) {
                idx1_padded[i] = i + idx + 1;
            }
            else {
                idx1_padded[i] = len1;
            }
        }
        else {
            if(idx >= 0 && i < len1) {
                idx1_padded[i] = i + 1;
            }
            else {
                idx1_padded[i] = len1;
            }
        }

        /* ts2 */
        if(idx > 0) {
            if(i < idx) {
                idx2_padded[i] = 1;
            }
            else if(i < (len2+idx)) {
                idx2_padded[i] = i - idx + 1;
            }
            else {
                idx2_padded[i] = len2;
            }
        }
        else {
            if(i < len2) {
                idx2_padded[i] = i + 1;
            }
            else {
                idx2_padded[i] = len2;
            }
        }
    }


    ret.idx1_padded = idx1_padded;
    ret.idx2_padded = idx2_padded;
    ret.len = final_len;
    return ret;
}

/* the gateway function */
void mexFunction( int nlhs, mxArray *plhs[],
        int nrhs, const mxArray *prhs[])
{
    int i;

    int *tmp;
    int ns, nt;
    int len1, len2, idx;

    int *idx1_padded, *idx2_padded;
    int final_len;
    Output ret;
    

    
    /*  check for proper number of arguments */
    if(nrhs!=3)
    {
        mexErrMsgIdAndTxt( "MATLAB:shift_pad_c:invalidNumInputs",
                "Three inputs required.");
    }
    if(nlhs != 2)
    {
        mexErrMsgIdAndTxt( "MATLAB:shift_pad_c:invalidNumOutputs",
                "shift_pad_c: Two output required.");
    }
    
    
    
    /*  Input: len1 */
    len1 = mxGetScalar(prhs[0]);

    /*  Input: len2 */
    len2 = mxGetScalar(prhs[1]);

    /*  Input: idx */
    idx = mxGetScalar(prhs[2]);
    

    ret = shift_pad_c(len1, len2, idx);
    plhs[0] = mxCreateNumericMatrix( 1, ret.len, mxINT32_CLASS, mxREAL); /* idx1_padded */
    plhs[1] = mxCreateNumericMatrix( 1, ret.len, mxINT32_CLASS, mxREAL); /* idx2_padded */
    
    idx1_padded = (int *)mxGetPr(plhs[0]);
    idx2_padded = (int *)mxGetPr(plhs[1]);
    for(i = 0; i < ret.len; i++) {
        idx1_padded[i] = ret.idx1_padded[i];
        idx2_padded[i] = ret.idx2_padded[i];
    }

    return;
}

