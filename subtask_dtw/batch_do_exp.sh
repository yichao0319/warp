#!/bin/bash
# function do_exp(trace_name, trace_opt1, ...
#                 rank_num_seg, rank_percentile, ...
#                 num_cluster, cluster_method, ...
#                 warp_method, warp_opt1, warp_opt2)
matlab -r "do_exp('4sq', 10, 1, 0.8, Inf, 'kmeans', 'dtw', '', 1); exit;"
matlab -r "do_exp('4sq', 10, 1, 0.8, 1, 'kmeans', 'dtw', 'dtw_c', 1); exit;"
matlab -r "do_exp('4sq', 10, 1, 0.8, 1, 'kmeans', 'shift', '', 1); exit;"
# matlab -r "do_exp('4sq', 10, 1, 0.8, 1, 'kmeans', 'stretch', '', 1); exit;"


matlab -r "do_exp('abilene', 0, 1, 0.8, Inf, 'kmeans', 'dtw', '', 1); exit;"
matlab -r "do_exp('abilene', 0, 1, 0.8, 1, 'kmeans', 'dtw', 'dtw_c', 1); exit;"
matlab -r "do_exp('abilene', 0, 1, 0.8, 1, 'kmeans', 'shift', '', 1); exit;"
# matlab -r "do_exp('abilene', 0, 1, 0.8, 1, 'kmeans', 'stretch', '', 1); exit;"

matlab -r "do_exp('abilene', 0, 1, 0.8, 5, 'kmeans', 'dtw', 'dtw_c', 1); exit;"
matlab -r "do_exp('abilene', 0, 1, 0.8, 5, 'kmeans', 'shift', '', 1); exit;"
# matlab -r "do_exp('abilene', 0, 1, 0.8, 5, 'kmeans', 'stretch', '', 1); exit;"


matlab -r "do_exp('geant', 0, 1, 0.8, Inf, 'kmeans', 'dtw', '', 1); exit;"
matlab -r "do_exp('geant', 0, 1, 0.8, 1, 'kmeans', 'dtw', 'dtw_c', 1); exit;"
matlab -r "do_exp('geant', 0, 1, 0.8, 1, 'kmeans', 'shift', '', 1); exit;"
# matlab -r "do_exp('geant', 0, 1, 0.8, 1, 'kmeans', 'stretch', '', 1); exit;"

matlab -r "do_exp('geant', 0, 1, 0.8, 5, 'kmeans', 'dtw', 'dtw_c', 1); exit;"
matlab -r "do_exp('geant', 0, 1, 0.8, 5, 'kmeans', 'shift', '', 1); exit;"
# matlab -r "do_exp('geant', 0, 1, 0.8, 5, 'kmeans', 'stretch', '', 1); exit;"

matlab -r "do_exp('geant', 0, 1, 0.8, 10, 'kmeans', 'dtw', 'dtw_c', 1); exit;"
matlab -r "do_exp('geant', 0, 1, 0.8, 10, 'kmeans', 'shift', '', 1); exit;"
# matlab -r "do_exp('geant', 0, 1, 0.8, 10, 'kmeans', 'stretch', '', 1); exit;"
