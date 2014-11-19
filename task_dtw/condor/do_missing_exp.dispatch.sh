#!/bin/bash

func="do_missing_exp"

num_jobs=50
cnt=0

## clean log files
rm /u/yichao/warp/condor_data/task_dtw/condor/log_missing/*

## DAG 
rm tmp.$func.dag*
echo "" > tmp.$func.dag


trace_names=("abilene" "geant" "wifi" "3g" "1ch-csi" "cister" "cu" "multi-ch-csi" "ucsb" "umich" "test_sine_shift" "test_sine_scale" "p300" "4sq" "blink")

# warp_methods=("na" "dtw" "shift" "stretch")
warp_methods=("shift_limit")
warp_opt="num_seg=1"

# cluster_methods=("kmeans" "hierarchical" "hier_affinity" "kmeans_affinity")
# cluster_methods=("kmeans")
# num_clusters=(1)
cluster_methods=("spectral_cc")
num_clusters=(0)

rank_seg=1
rank_percnetile=0.8
rank_cluster_method=1
rank_opt="percentile=${rank_percnetile},num_seg=${rank_seg},r_method=${rank_cluster_method}"

elem_frac=1
loss_rates=(0.01 0.05 0.1 0.15 0.2 0.4)
elem_mode="elem"
loss_mode="ind"
burst_size=1

# init_esti_methods=("na" "lens")
init_esti_methods=("na")
final_esti_methods=("lens")

seeds=(1 2 3 4 5)

for seed in ${seeds[@]}; do
    for loss_rate in ${loss_rates[@]}; do
        for trace_name in ${trace_names[@]}; do

            if [[ ${trace_name} == "p300" ]]; then
                trace_opt="subject=1,session=1,img_idx=0"

            elif [[ ${trace_name} == "4sq" ]]; then
                trace_opt="num_loc=100,num_rep=1,loc_type=1"

            else
                trace_opt="na"
            fi

            ## warp
            for warp_method in ${warp_methods[@]}; do
                ## cluster method
                for cluster_method in ${cluster_methods[@]}; do
                    for num_cluster in ${num_clusters[@]}; do
                        ## estimation method
                        for init_esti_method in ${init_esti_methods[@]}; do
                            for final_esti_method in ${final_esti_methods[@]}; do
                                # trace_name '.' trace_opt '.' cluster_method '.c' num2str(num_cluster) '.' warp_method '.' warp_opt '.' rank_opt '.elem' num2str(elem_frac) '.lr' num2str(loss_rate) '.' elem_mode '.' loss_mode '.' num2str(burst_size) '.' init_esti_method '.' final_esti_method '.s' num2str(seed) '.txt'
                                # trace_name, trace_opt, ...
                                # rank_opt, ...
                                # elem_frac, loss_rate, elem_mode, loss_mode, burst_size, ...
                                # init_esti_method, final_esti_method, ...
                                # num_cluster, cluster_method, ...
                                # warp_method, warp_opt, ...
                                # seed
                                name=${trace_name}.${trace_opt}.${cluster_method}.c${num_cluster}.${warp_method}.${warp_opt}.${rank_opt}.elem${elem_frac}.lr${loss_rate}.${elem_mode}.${loss_mode}.${burst_size}.${init_esti_method}.${final_esti_method}.s${seed}
                                echo ${name}
                                sed "s/TRACE_NAME/${trace_name}/g; s/TRACE_OPT/${trace_opt}/g; s/CLUST_METHOD/${cluster_method}/g; s/NUM_CLUST/${num_cluster}/g; s/WARP_METHOD/${warp_method}/g; s/WARP_OPT/${warp_opt}/g; s/RANK_OPT/${rank_opt}/g; s/ELEM_FRAC/${elem_frac}/g; s/LOSS_RATE/${loss_rate}/g; s/ELEM_MODE/${elem_mode}/g; s/LOSS_MODE/${loss_mode}/g; s/BURST_SIZE/${burst_size}/g; s/INIT_ESTI_METHOD/${init_esti_method}/g; s/FINAL_ESTI_METHOD/${final_esti_method}/g; s/SEED/${seed}/g; " ${func}.mother.sh > tmp.${name}.sh
                                sed "s/XXX/${name}/g" ${func}.mother.condor > tmp.${name}.condor
                                # condor_submit tmp.${name}.condor
                                echo JOB J${cnt} tmp.${name}.condor >> tmp.$func.dag
                                cnt=$((${cnt} + 1))
                            done ## end final esti method
                        done ## end init esti method
                    done ## end number of clusters
                done ## end cluster method
            done ## end warp method
        done
    done
done


condor_submit_dag -maxjobs ${num_jobs} tmp.${func}.dag



