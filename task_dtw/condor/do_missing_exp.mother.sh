#!/bin/bash

matlab -r "out_file = ['/u/yichao/warp/condor_data/task_dtw/condor/do_missing_exp/TRACE_NAME.TRACE_OPT.RANK_OPT.elemELEM_FRAC.lrLOSS_RATE.ELEM_MODE.LOSS_MODE.BURST_SIZE.INIT_ESTI_METHOD.FINAL_ESTI_METHOD.CLUST_METHOD.CLUST_OPT.WARP_METHOD.WARP_OPT.EVAL_OPT.sSEED.txt']; if(exist(out_file)), exit; end; do_missing_exp('TRACE_NAME', 'TRACE_OPT', 'RANK_OPT', ELEM_FRAC, LOSS_RATE, 'ELEM_MODE', 'LOSS_MODE', BURST_SIZE, 'INIT_ESTI_METHOD', 'FINAL_ESTI_METHOD', 'CLUST_METHOD', 'CLUST_OPT', 'WARP_METHOD', 'WARP_OPT', 'EVAL_OPT', SEED); exit;"
