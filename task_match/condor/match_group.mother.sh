#!/bin/bash

# trace_name, trace_opt, feature_opt, divide_opt, cluster_opt, sync_opt, seed
matlab -r "out_file = ['/u/yichao/warp/condor_data/task_match/condor/match_group/TRACE_NAME.TRACE_OPT.FEATURE_OPT.DIVIDE_OPT.CLUSTER_OPT.SYNC_OPT.SEED.accuracy.txt']; if(exist(out_file)), exit; end; match_group('TRACE_NAME', 'TRACE_OPT', 'FEATURE_OPT', 'DIVIDE_OPT', 'CLUSTER_OPT', 'SYNC_OPT', SEED); exit;"
