#!/bin/bash

matlab -r "out_file = ['/u/yichao/warp/condor_data/task_miss/condor/do_exp/TRACE_NAME.TRACE_OPT.SYNC_OPT.CLUSTER_OPT.RANK_OPT.SEED.txt']; if(exist(out_file)), exit; end; do_exp('TRACE_NAME', 'TRACE_OPT', 'SYNC_OPT', 'CLUSTER_OPT', 'RANK_OPT', SEED); exit;"
