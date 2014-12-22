## do_missing_exp
## - trace_opt
##   > 4sq: num_loc, num_rep, loc_type
##   > p300: subject, session, img_idx, mat_type
## - rank_opt
##   > percentile
##   > num_seg
##   > r_method
##     > 1: fill in shorter clusters with 0s
##     > 2: sum of the ranks of each cluster
## - elem_frac: 1
## - loss_rate: 0.1
## - elem_mode: 'elem'
## - loss_mode: 'ind'
## - sync_opt: 
## - sync_opt
##   > num_seg
##

trace_names=("abilene" "geant" "wifi" "3g" "1ch-csi" "cister" "cu" "multi-ch-csi" "ucsb" "umich" "p300" "4sq" "blink")
# "test_sine_shift" "test_sine_scale" 


# cluster_method="kmeans"
# num_cluster=1
cluster_method="spectral_cc"
num_cluster=0
sync_method="shift_limit"

for trace_name in ${trace_names[@]}; do

    if [[ ${trace_name} == "p300" ]]; then
        trace_opt="subject=1,session=1,img_idx=0"

    elif [[ ${trace_name} == "4sq" ]]; then
        trace_opt="num_loc=100,num_rep=1,loc_type=1"

    else
        trace_opt="na"
    fi
    
    matlab -r "[mae, mae_orig] = do_missing_exp('${trace_name}', '${trace_opt}', 'percentile=0.8,num_seg=1,r_method=1', 1, 0.1, 'elem', 'ind', 1, 'na', 'knn', ${num_cluster}, '${cluster_method}', '${sync_method}', 'num_seg=1', 1); exit;"
done
