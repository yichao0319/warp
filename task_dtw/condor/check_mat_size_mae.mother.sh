#!/bin/bash

matlab -r "out_file = ['/u/yichao/warp/condor_data/task_dtw/condor/check_mat_size_mae/TRACE_NAME.TRACE_OPT.elemELEM_FRAC.lrLOSS_RATE.ELEM_MODE.LOSS_MODE.BURST_SIZE.SUB_RATIO.sSEED.txt']; if(exist(out_file)), exit; end; check_mat_size_mae('TRACE_NAME', 'TRACE_OPT', ELEM_FRAC, LOSS_RATE, 'ELEM_MODE', 'LOSS_MODE', BURST_SIZE, SUB_RATIO, SEED); exit;"
