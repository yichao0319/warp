#!/bin/bash

func="do_missing_exp"

num_jobs=70
cnt=0

## clean log files
rm /u/yichao/warp/condor_data/task_dtw/condor/log_missing/*

## DAG 
rm tmp.$func.dag*
echo "" > tmp.$func.dag


## trace
# trace_names=("abilene" "geant" "wifi" "3g" "1ch-csi" "cister" "cu" "ucsb" "umich" "p300" "4sq")
trace_names=("geant" "3g" "4sq")
# "test_sine_shift" "test_sine_scale" "blink" "multi-ch-csi"


## dropping elements
elem_frac=1
loss_rates=(0.05 0.1 0.15 0.2)
elem_mode="elem"
loss_mode="ind"
burst_size=1


## cluster
# cluster_methods=("subspace" "spectral")
# cluster_methods=("spectral")
cluster_methods=("kmeans")
# num_clusters=(0 5000)
# head_types=("best" "random" "worst")
head_types=("best")
sync_type="shift"
# metric_types=("graph" "coef")
metric_types=("coef")


## warp
# warp_methods=("na" "dtw" "shift" "stretch")
warp_methods=("shift_limit")
# warp_methods=("stretch")
warp_opt="num_seg=1"


## evaluation
eval_opts=("no_dup=1")


## rank
rank_seg=1
rank_percnetile=0.8
rank_cluster_method=1
rank_opt="percentile=${rank_percnetile},num_seg=${rank_seg},r_method=${rank_cluster_method}"

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
                ## eval
                for eval_opt in ${eval_opts[@]}; do
                    ## cluster method
                    for cluster_method in ${cluster_methods[@]}; do

                        if [[ ${cluster_method} == "subspace" ]]; then
                            num_clusters=(5000)
                        elif [[ ${cluster_method} == "spectral" ]]; then
                            num_clusters=(-1)
                        else
                            num_clusters=(2 3 5 10)
                        fi

                        for num_cluster in ${num_clusters[@]}; do
                            for head_type in ${head_types[@]}; do
                                for metric_type in ${metric_types[@]}; do

                                    if [[ ${metric_type} == "graph" ]]; then
                                        sigmas=(1 10 100)
                                    else
                                        sigmas=(1)
                                    fi
                                
                                    for sigma in ${sigmas[@]}; do

                                        cluster_opt="num_cluster=$num_cluster,head_type=''$head_type'',sync_type=''$sync_type'',metric_type=''$metric_type'',sigma=$sigma"

                                        ## estimation method
                                        for init_esti_method in ${init_esti_methods[@]}; do
                                            for final_esti_method in ${final_esti_methods[@]}; do
                                                # TRACE_NAME.TRACE_OPT.RANK_OPT.elemELEM_FRAC.lrLOSS_RATE.ELEM_MODE.LOSS_MODE.BURST_SIZE.INIT_ESTI_METHOD.FINAL_ESTI_METHOD.CLUST_METHOD.cNUM_CLUST.WARP_METHOD.WARP_OPT.EVAL_OPT.sSEED
                                                name=${trace_name}.${trace_opt}.${rank_opt}.elem${elem_frac}.lr${loss_rate}.${elem_mode}.${loss_mode}.${burst_size}.${init_esti_method}.${final_esti_method}.${cluster_method}.${cluster_opt}.${warp_method}.${warp_opt}.${eval_opt}.s${seed}
                                                echo ${name}
                                                sed "s/TRACE_NAME/${trace_name}/g; s/TRACE_OPT/${trace_opt}/g; s/CLUST_METHOD/${cluster_method}/g; s/CLUST_OPT/${cluster_opt}/g; s/WARP_METHOD/${warp_method}/g; s/WARP_OPT/${warp_opt}/g; s/EVAL_OPT/${eval_opt}/g; s/RANK_OPT/${rank_opt}/g; s/ELEM_FRAC/${elem_frac}/g; s/LOSS_RATE/${loss_rate}/g; s/ELEM_MODE/${elem_mode}/g; s/LOSS_MODE/${loss_mode}/g; s/BURST_SIZE/${burst_size}/g; s/INIT_ESTI_METHOD/${init_esti_method}/g; s/FINAL_ESTI_METHOD/${final_esti_method}/g; s/SEED/${seed}/g; " ${func}.mother.sh > tmp.${name}.sh
                                                sed "s/XXX/${name}/g" ${func}.mother.condor > tmp.${name}.condor
                                                # condor_submit tmp.${name}.condor
                                                echo JOB J${cnt} tmp.${name}.condor >> tmp.$func.dag
                                                cnt=$((${cnt} + 1))
                                            done ## end final esti method
                                        done ## end init esti method
                                    done ## end sigma
                                done ## end metric types
                            done ## end head type
                        done ## end num cluster
                    done ## end cluster method
                done ## end eval opt
            done ## end warp method
        done
    done
done


condor_submit_dag -maxjobs ${num_jobs} tmp.${func}.dag



