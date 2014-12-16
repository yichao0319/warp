#!/bin/bash

func="match_group"

num_jobs=70
cnt=0

## clean log files
rm /u/yichao/warp/condor_data/task_match/condor/log_group/*

## DAG 
rm tmp.$func.dag*
echo "" > tmp.$func.dag


## trace
# trace_names=("word" "acc-chest")
trace_names=("word" "acc-wrist")
# trace_names=("acc-wrist")
# trace_names=("deap")

## trace opt: depends on trace
# trace_opts=("feature=''mfcc''")

## feature_opt
feature_nums=(-1 0 0.2 0.5 0.8)

## divide opt
train_ratios=(0 0.2 0.5 0.8 1)

## cluster_opt
method="kmeans"
cluster_nums=(1 2 3 5)

## sync_opt
syncs=("na" "nafair" "shift")
# metrics=("coeff" "dist")
metrics=("coeff")

## seed
seeds=(1 2)


for seed in ${seeds[@]}; do
    for trace_name in ${trace_names[@]}; do

        if [[ ${trace_name} == "deap" ]]; then
            trace_opts=("feature=''spectrogram'',channel=1" "feature=''raw'',channel=1")
        elif [[ ${trace_name} == "word" ]]; then
            # trace_opts=("feature=''mfcc''" "feature=''spectrogram''")
            trace_opts=("feature=''mfcc''")
        elif [[ ${trace_name} == "acc-chest" ]]; then
            # trace_opts=("feature=''raw''" "feature=''quantization''")
            trace_opts=("feature=''raw''")
        elif [[ ${trace_name} == "acc-wrist" ]]; then
            # trace_opts=("feature=''raw'',set=1" "feature=''quantization'',set=1" "feature=''raw'',set=2" "feature=''quantization'',set=2" "feature=''raw'',set=3" "feature=''quantization'',set=3")
            trace_opts=("feature=''raw'',set=1" "feature=''raw'',set=2" "feature=''raw'',set=3")
        fi

        for trace_opt in ${trace_opts[@]}; do
            for feature_num in ${feature_nums[@]}; do
                feature_opt="num=${feature_num}"
                
                for train_ratio in ${train_ratios[@]}; do
                    divide_opt="ratio=${train_ratio}"

                    for cluster_num in ${cluster_nums[@]}; do
                        cluster_opt="method=''${method}'',num=${cluster_num}"

                        for sync in ${syncs[@]}; do
                            for metric in ${metrics[@]}; do
                                sync_opt="sync=''${sync}'',metric=''${metric}''"
                    
                                name=${trace_name}.${trace_opt}.${feature_opt}.${divide_opt}.${cluster_opt}.${sync_opt}.${seed}
                                echo ${name}
                                sed "s/TRACE_NAME/${trace_name}/g; s/TRACE_OPT/${trace_opt}/g; s/FEATURE_OPT/${feature_opt}/g; s/DIVIDE_OPT/${divide_opt}/g; s/CLUSTER_OPT/${cluster_opt}/g; s/SYNC_OPT/${sync_opt}/g; s/SEED/${seed}/g; " ${func}.mother.sh > tmp.${name}.sh
                                sed "s/XXX/${name}/g" ${func}.mother.condor > tmp.${name}.condor
                                # condor_submit tmp.${name}.condor
                                echo JOB J${cnt} tmp.${name}.condor >> tmp.$func.dag
                                cnt=$((${cnt} + 1))
                            done ## end metrics
                        done ## end syncs
                    done ## end cluster num
                done ## end train ratio
            done ## end feature num
        done ## end trace opt
    done ## end trace name
done ## end seed


condor_submit_dag -maxjobs ${num_jobs} tmp.${func}.dag

