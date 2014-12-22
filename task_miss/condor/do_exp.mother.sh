#!/bin/bash

matlab -r "out_file = ['/u/yichao/warp/condor_data/task_miss/condor/do_exp/TRACE_NAME.TRACE_OPT.CLUST_METHOD.cNUM_CLUST.WARP_METHOD.RANK_OPT.txt']; if(exist(out_file)), exit; end; [r] = do_exp('TRACE_NAME', 'TRACE_OPT', 'RANK_OPT', NUM_CLUST, 'CLUST_METHOD', 'WARP_METHOD', 'WARP_OPT'); exit;"
