#!/bin/bash

func="do_exp"

num_jobs=70
cnt=0

## clean log files
rm -rf /u/yichao/warp/condor_data/task_miss/condor/log
mkdir /u/yichao/warp/condor_data/task_miss/condor/log

## DAG 
rm tmp.$func.dag*
echo "" > tmp.$func.dag


## trace
# trace_names=("abilene" "geant" "wifi" "3g" "1ch-csi" "cister" "cu" "ucsb" "umich" "p300" "4sq" "deap" "muse" "multi-ch-csi")
# trace_names=("muse" "p300" "deap" "wifi" "1ch-csi" "abilene" "umich" "cister" "multi-ch-csi")
trace_names=("abilene" "geant" "wifi" "3g" "1ch-csi" "cister" "cu" "ucsb" "umich" "p300" "4sq" "deap" "muse" "multi-ch-csi")
# trace_names=("multi-ch-csi")
# "test_sine_shift" "test_sine_scale" "blink" 


## sync
sync_methods=("shift")
metrics=("coeff")
num_seg=1

## cluster
cluster_methods=("kmeans")

## rank
percentile=0.8
num_seg=1
r_method=1
rank_opt="percentile=0.8,num_seg=1,r_method=1"

seeds=(1 2 3 4 5)
# seeds=(1 2)


for seed in ${seeds[@]}; do
    for trace_name in ${trace_names[@]}; do

        if [[ ${trace_name} == "p300" ]]; then
            trace_opt="subject=1,session=1,img_idx=0"
            num_clusters=(4)
            head_types=("best")
            merges=("num")
        elif [[ ${trace_name} == "4sq" ]]; then
            trace_opt="num_loc=100,num_rep=1,loc_type=1"
            num_clusters=(1)
            head_types=("best")
            merges=("num")
        elif [[ ${trace_name} == "deap" ]]; then
            trace_opt="video=1"
            num_clusters=(8)
            head_types=("best")
            merges=("num")
        elif [[ ${trace_name} == "muse" ]]; then
            trace_opt="muse=''4ch''"
            num_clusters=(4)
            head_types=("best")
            merges=("top")
        elif [[ ${trace_name} == "multi-ch-csi" ]]; then
            trace_opt="na"
            num_clusters=(2)
            head_types=("best")
            merges=("num")
        elif [[ ${trace_name} == "abilene" ]]; then
            trace_opt="na"
            num_clusters=(2)
            head_types=("best")
            merges=("top")
        elif [[ ${trace_name} == "1ch-csi" ]]; then
            trace_opt="na"
            num_clusters=(1)
            head_types=("best")
            merges=("num")
        elif [[ ${trace_name} == "3g" ]]; then
            trace_opt="na"
            num_clusters=(1)
            head_types=("best")
            merges=("num")
        elif [[ ${trace_name} == "cister" ]]; then
            trace_opt="na"
            num_clusters=(8)
            head_types=("best")
            merges=("top")
        elif [[ ${trace_name} == "cu" ]]; then
            trace_opt="na"
            num_clusters=(8)
            head_types=("best")
            merges=("num")
        elif [[ ${trace_name} == "geant" ]]; then
            trace_opt="na"
            num_clusters=(8)
            head_types=("best")
            merges=("num")
        elif [[ ${trace_name} == "ucsb" ]]; then
            trace_opt="na"
            num_clusters=(4)
            head_types=("best")
            merges=("num")
        elif [[ ${trace_name} == "umich" ]]; then
            trace_opt="na"
            num_clusters=(1)
            head_types=("best")
            merges=("num")
        elif [[ ${trace_name} == "wifi" ]]; then
            trace_opt="na"
            num_clusters=(2)
            head_types=("worst")
            merges=("num")
        fi
        
        ## sync
        for sync_method in ${sync_methods[@]}; do
            ## metric
            for metric in ${metrics[@]}; do

                if [[ ${metric_type} == "graph" ]]; then
                    sigmas=(1 10 100)
                else
                    sigmas=(1)
                fi

                ## sigma
                for sigma in ${sigmas[@]}; do

                    sync_opt="sync=''${sync_method}'',metric=''${metric}'',num_seg=${num_seg},sigma=${sigma}"

                    ## cluster method
                    for cluster_method in ${cluster_methods[@]}; do

                        ## number of clusters
                        for num_cluster in ${num_clusters[@]}; do
                            ## head types
                            for head_type in ${head_types[@]}; do
                                ## merge
                                for merge in ${merges[@]}; do

                                    if [[ ${merge} == "num" ]]; then
                                        threshs=(30)
                                    elif [[ ${merge} == "sim" ]]; then
                                        threshs=(0.5)
                                    elif [[ ${merge} == "top" ]]; then
                                        threshs=(1)
                                    elif [[ ${merge} == "na" ]]; then
                                        threshs=(0)
                                    else
                                        threshs=(0)
                                    fi

                                    ## thresh
                                    for thresh in ${threshs[@]}; do

                                        cluster_opt="method=''${cluster_method}'',num=${num_cluster},head=''${head_type}'',merge=''$merge'',thresh=${thresh}"

                                        
                                        name=${trace_name}.${trace_opt}.${sync_opt}.${cluster_opt}.${rank_opt}.${seed}
                                        echo ${name}
                                        sed "s/TRACE_NAME/${trace_name}/g; s/TRACE_OPT/${trace_opt}/g; s/SYNC_OPT/${sync_opt}/g; s/CLUSTER_OPT/${cluster_opt}/g; s/RANK_OPT/${rank_opt}/g; s/SEED/${seed}/g; " ${func}.mother.sh > tmp.${name}.sh
                                        sed "s/XXX/${name}/g" ${func}.mother.condor > tmp.${name}.condor
                                        # condor_submit tmp.${name}.condor
                                        echo JOB J${cnt} tmp.${name}.condor >> tmp.$func.dag
                                        cnt=$((${cnt} + 1))
                                    done ## end thresh
                                done ## end merge
                            done ## end head type
                        done ## end num cluster
                    done ## end cluster method
                done ## end sigma
            done ## end metric
        done ## end sync method
    done
done


condor_submit_dag -maxjobs ${num_jobs} tmp.${func}.dag



