## do_exp: 
## - trace_opt
##   > 4sq: num_loc, num_rep, loc_type
##   > p300: subject, session, img_idx, mat_type
## - rank_opt
##   > percentile
##   > num_seg
##   > r_method
##     > 1: fill in shorter clusters with 0s
##     > 2: sum of the ranks of each cluster
## - warp_opt
##   > num_seg
##
## function [r] = do_exp(trace_name, trace_opt, ...
##                rank_opt, ...
##                num_cluster, cluster_method, ...
##                warp_method, warp_opt)
matlab -r "do_exp('test_sine_shift', 'na', 'percentile=0.8,num_seg=1,r_method=1', 1, 'kmeans', 'dtw', 'num_seg=1'); exit;"
