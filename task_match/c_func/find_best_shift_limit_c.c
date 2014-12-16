
#include "mex.h"
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <string.h>

#define max(a,b) \
   ({ __typeof__ (a) _a = (a); \
       __typeof__ (b) _b = (b); \
     _a >= _b ? _a : _b; })

#define min(a,b) \
   ({ __typeof__ (a) _a = (a); \
       __typeof__ (b) _b = (b); \
     _a <= _b ? _a : _b; })


typedef struct
{
    int *shift_idx1;
    int *shift_idx2;
    int len;
    double *cc;
    int cc_len;
} Output1;


typedef struct
{
    int *idx1_padded;
    int *idx2_padded;
    int len;
} Output2;


Output2 shift_pad_c(int len1, int len2, int idx)
{
    int i;
    int final_len;
    int *idx1_padded, *idx2_padded;
    Output2 ret;

    
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


double corrcoef_c(double **ts1, double **ts2, int n, int k)
{
    int i, x; 
    double xy, xsquare, ysquare, xsum, ysum, xysum, xsqr_sum, ysqr_sum;
    double num, deno;
    int cnt;
    double sum_coeff;


    sum_coeff = 0;

    for(x = 0; x < k; x ++) {
        xsum = 0;
        ysum = 0;
        xysum = 0;
        xsqr_sum = 0;
        ysqr_sum = 0;
        cnt = 0;

        for (i = 0; i < n; i ++) {
            if(mxIsNaN(ts1[i][x]) || mxIsNaN(ts2[i][x])) {
                continue;
            }
            cnt ++;
            xy = ts1[i][x] * ts2[i][x];
            xsquare = ts1[i][x] * ts1[i][x];
            ysquare = ts2[i][x] * ts2[i][x];
            xsum += ts1[i][x];
            ysum += ts2[i][x];
            xysum += xy;
            xsqr_sum += xsquare;
            ysqr_sum += ysquare;
        }

        num = (cnt * xysum) - (xsum * ysum);
        deno = (cnt * xsqr_sum - xsum * xsum) * (cnt * ysqr_sum - ysum * ysum);

        if(deno == 0) {
            sum_coeff += (-1);
        }
        else {
            sum_coeff += (num / sqrt(deno));
        }
    }

    return (sum_coeff / k);
}


double get_distance(double **ts1, double **ts2, int n, int k)
{
    double dist;
    double ss,tt;
    int i, x;

    dist = 0;
    for(i = 0; i < n; i ++) {
        for(x = 0; x < k; x ++) {
            ss = ts1[i][x];
            tt = ts2[i][x];
            dist += ((ss-tt)*(ss-tt));
        }
    }
    dist = sqrt(dist);

    return dist;
}



/* double dtw_c(double *s, double *t, int w, int ns, int nt, int k) */
Output1 find_best_shift_limit_c(double *s, double *t, int ns, int nt, int k, double lim_left, double lim_right, int metric)
{
    int i, j, x;
    double best_cc, coeff;
    int ts1_left, ts1_right;
    int lim_idx_left, lim_idx_right;
    int idx;
    Output2 pad_ret;
    int tmp1, tmp2;
    int new_len;
    int *idx1_padded, *idx2_padded;
    double **ts1_padded, **ts2_padded;
    Output1 ret;
    
    
    best_cc = -1;

    ts1_left  = max(1, floor(ns*lim_left));
    ts1_right = min(ns, ceil(ns*lim_right));
    /* the overlay length may be larger than the length of ts2 */
    if(ts1_right - ts1_left + 1 > nt) {
        ts1_right = ts1_left + nt - 1;
    }
    
    lim_idx_left  = ts1_right - nt;
    lim_idx_right = ts1_left - 1;
    new_len = ts1_right - ts1_left + 1;
    /*mexPrintf("ts1 left=%d, ts1 right=%d, ts2 len=%d\n", ts1_left, ts1_right, nt);
    mexPrintf("left=%d, right=%d, len=%d\n", lim_idx_left, lim_idx_right, new_len);*/

    ret.len = new_len;
    ret.cc_len = lim_idx_right + nt;
    ret.shift_idx1 = (int *)malloc(new_len * sizeof(int));
    ret.shift_idx2 = (int *)malloc(new_len * sizeof(int));
    ret.cc = (double *)malloc((lim_idx_right+nt) * sizeof(double));
    for(i = 0; i < (lim_idx_right+nt); ++i) {
        ret.cc[i] = -1;
    }

    for(idx = lim_idx_left; idx <= lim_idx_right; ++idx) {
        pad_ret = shift_pad_c(ns, nt, idx);
        
        idx1_padded = (int *)malloc(new_len * sizeof(int));
        idx2_padded = (int *)malloc(new_len * sizeof(int));
        ts1_padded = (double **)malloc(new_len * sizeof(double *));
        for(i = 0; i < new_len; i ++) {
            ts1_padded[i] = (double *)malloc(k * sizeof(double));
        }
        ts2_padded = (double **)malloc(new_len * sizeof(double *));
        for(i = 0; i < new_len; i ++) {
            ts2_padded[i] = (double *)malloc(k * sizeof(double));
        }

        j = 0;
        for(i = 0; i < pad_ret.len; ++i) {
            /* assume ts1_left > 1 */
            /* assume ts1_right < nt */
            if(pad_ret.idx1_padded[i] < ts1_left || pad_ret.idx1_padded[i] > ts1_right) {
                continue;
            }
            if(pad_ret.idx1_padded[i] == ts1_left && pad_ret.idx1_padded[i+1] == ts1_left) {
                continue;
            }
            if(pad_ret.idx1_padded[i] == ts1_right && pad_ret.idx1_padded[i-1] == ts1_right) {
                break;
            }
            /*mexPrintf("  i=%d, j=%d: idx1=%d, idx2=%d\n", i, j, pad_ret.idx1_padded[i], pad_ret.idx2_padded[i]);*/

            idx1_padded[j] = pad_ret.idx1_padded[i];
            idx2_padded[j] = pad_ret.idx2_padded[i];

            for(x = 0; x < k; x ++) {
                ts1_padded[j][x] = s[idx1_padded[j]-1 + ns*x];
            }
            for(x = 0; x < k; x ++) {
                ts2_padded[j][x] = t[idx2_padded[j]-1 + nt*x];
            }
            /*mexPrintf("  i=%d,j=%d: idx1=%d, idx2=%d, ts1=%f, ts2=%f\n", i, j, idx1_padded[j], idx2_padded[j], ts1_padded[j], ts2_padded[j]);*/
            j ++;
        }

        if(metric == 1) {
            coeff = corrcoef_c(ts1_padded, ts2_padded, new_len, k);
            ret.cc[idx+nt-1] = coeff;
            if(ret.cc[idx+nt-1] > best_cc) {
                best_cc = ret.cc[idx+nt-1];
                memcpy(ret.shift_idx1, idx1_padded, new_len*sizeof(int));
                memcpy(ret.shift_idx2, idx2_padded, new_len*sizeof(int));
            }
            else if(best_cc == -1 && idx == 0) {
                memcpy(ret.shift_idx1, idx1_padded, new_len*sizeof(int));
                memcpy(ret.shift_idx2, idx2_padded, new_len*sizeof(int));
            }
        }
        else {
            coeff = get_distance(ts1_padded, ts2_padded, new_len, k);
            ret.cc[idx+nt-1] = coeff;
            if((ret.cc[idx+nt-1] < best_cc) || best_cc < 0) {
                best_cc = ret.cc[idx+nt-1];
                memcpy(ret.shift_idx1, idx1_padded, new_len*sizeof(int));
                memcpy(ret.shift_idx2, idx2_padded, new_len*sizeof(int));
            }
            else if(best_cc == -1 && idx == 0) {
                memcpy(ret.shift_idx1, idx1_padded, new_len*sizeof(int));
                memcpy(ret.shift_idx2, idx2_padded, new_len*sizeof(int));
            }
        }
        
        
        /*mexPrintf("\nidx=%d: coef=%f\n", idx, ret.cc[idx+nt-1]);*/

        

        free(idx1_padded);
        free(idx2_padded);
        for(i = 0; i < new_len; i ++) {
            free(ts1_padded[i]);
        }
        free(ts1_padded);
        for(i = 0; i < new_len; i ++) {
            free(ts2_padded[i]);
        }
        free(ts2_padded);
        free(pad_ret.idx1_padded);
        free(pad_ret.idx2_padded);

    }

    return ret;
}

/* the gateway function */
void mexFunction( int nlhs, mxArray *plhs[],
        int nrhs, const mxArray *prhs[])
{
    int i;

    double *s, *t;
    int ns, nt, k;
    int metric;
    double lim_left, lim_right;

    int *shift_idx1, *shift_idx2;
    double *cc;
    Output1 ret;
    

    
    /*  check for proper number of arguments */
    if(nrhs!=5)
    {
        mexErrMsgIdAndTxt( "MATLAB:find_best_shift_limit_c:invalidNumInputs",
                "5 inputs required.");
    }
    if(nlhs != 3)
    {
        mexErrMsgIdAndTxt( "MATLAB:find_best_shift_limit_c:invalidNumOutputs",
                "find_best_shift_limit_c: Three output required.");
    }
    
    
    
    /*  create a pointer to the input matrix s */
    s  = mxGetPr(prhs[0]);
    ns = mxGetM(prhs[0]);
    k  = mxGetN(prhs[0]);

    /*  create a pointer to the input matrix t */
    t  = mxGetPr(prhs[1]);
    nt = mxGetM(prhs[1]);
    if(mxGetN(prhs[1]) != k) {
        mexErrMsgIdAndTxt( "MATLAB:find_best_shift_limit_c:dimNotMatch",
                    "find_best_shift_limit_c: Dimensions of input s and t must match.");
    }  

    /*  lim_left */
    lim_left = mxGetScalar(prhs[2]);
    
    /*  lim_right */
    lim_right = mxGetScalar(prhs[3]);

    /*  metric */
    metric = mxGetScalar(prhs[4]);
    

    ret = find_best_shift_limit_c(s, t, ns, nt, k, lim_left, lim_right, metric);
    plhs[0] = mxCreateNumericMatrix( 1, ret.len, mxINT32_CLASS, mxREAL); /* shift_idx1 */
    plhs[1] = mxCreateNumericMatrix( 1, ret.len, mxINT32_CLASS, mxREAL); /* shift_idx2 */
    plhs[2] = mxCreateDoubleMatrix( 1, ret.cc_len, mxREAL); /* cc */
    
    shift_idx1 = (int *)mxGetPr(plhs[0]);
    shift_idx2 = (int *)mxGetPr(plhs[1]);
    for(i = 0; i < ret.len; i++) {
        shift_idx1[i] = ret.shift_idx1[i];
        shift_idx2[i] = ret.shift_idx2[i];
    }

    cc = (double *)mxGetData(plhs[2]);
    for(i = 0; i < ret.cc_len; i++) {
        cc[i] = ret.cc[i];
    }
    
    return;
    
}

