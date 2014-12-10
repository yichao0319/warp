#!/bin/bash

matlab -r "out_file = ['/u/yichao/warp/condor_data/task_match/condor/match_single/TRACE_NAME.TRACE_OPT.DIVIDE_OPT.SEED.accuracy.txt']; if(exist(out_file)), exit; end; match_single('TRACE_NAME', 'TRACE_OPT', 'DIVIDE_OPT', SEED); exit;"
