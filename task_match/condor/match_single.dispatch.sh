#!/bin/bash

func="match_single"

num_jobs=70
cnt=0

## clean log files
rm /u/yichao/warp/condor_data/task_match/condor/log/*

## DAG 
rm tmp.$func.dag*
echo "" > tmp.$func.dag


## trace
# trace_names=("word" "acc-chest")
trace_names=("acc-wrist")
# trace_names=("deap")

## trace opt: depends on trace
# trace_opts=("feature=''mfcc''")

## divide opt
train_ratios=(0 0.2 0.5 0.8 1)

## seed
# seeds=(1 2 3 4 5)
seeds=(1 2)


for seed in ${seeds[@]}; do
    for trace_name in ${trace_names[@]}; do

        if [[ ${trace_name} == "deap" ]]; then
            # trace_opts=("feature=''raw'',channel=1" "feature=''spectrogram'',channel=1" "feature=''mfcc'',channel=1" "feature=''lowrank'',channel=1" "feature=''raw'',channel=35" "feature=''spectrogram'',channel=35" "feature=''mfcc'',channel=35" "feature=''lowrank'',channel=35")
            trace_opts=("feature=''spectrogram'',channel=1" "feature=''mfcc'',channel=1" "feature=''raw'',channel=1" "feature=''lowrank'',channel=1")
        elif [[ ${trace_name} == "word" ]]; then
            trace_opts=("feature=''raw''" "feature=''mfcc''" "feature=''spectrogram''" "feature=''lowrank''")
        elif [[ ${trace_name} == "acc-chest" ]]; then
            trace_opts=("feature=''raw''" "feature=''mag''" "feature=''percentile''" "feature=''mag_percentile''" "feature=''lowrank''" "feature=''lowrank_percentile''")
        elif [[ ${trace_name} == "acc-wrist" ]]; then
            trace_opts=("feature=''raw'',set=1" "feature=''mag'',set=1" "feature=''percentile'',set=1" "feature=''mag_percentile'',set=1" "feature=''lowrank'',set=1" "feature=''lowrank_percentile'',set=1" "feature=''raw'',set=2" "feature=''mag'',set=2" "feature=''percentile'',set=2" "feature=''mag_percentile'',set=2" "feature=''lowrank'',set=2" "feature=''lowrank_percentile'',set=2" "feature=''raw'',set=3" "feature=''mag'',set=3" "feature=''percentile'',set=3" "feature=''mag_percentile'',set=3" "feature=''lowrank'',set=3" "feature=''lowrank_percentile'',set=3")
        fi

        for trace_opt in ${trace_opts[@]}; do
            for train_ratio in ${train_ratios[@]}; do
                divide_opt="ratio=${train_ratio}"
                
                name=${trace_name}.${trace_opt}.${divide_opt}.${seed}
                echo ${name}
                sed "s/TRACE_NAME/${trace_name}/g; s/TRACE_OPT/${trace_opt}/g; s/DIVIDE_OPT/${divide_opt}/g; s/SEED/${seed}/g; " ${func}.mother.sh > tmp.${name}.sh
                sed "s/XXX/${name}/g" ${func}.mother.condor > tmp.${name}.condor
                # condor_submit tmp.${name}.condor
                echo JOB J${cnt} tmp.${name}.condor >> tmp.$func.dag
                cnt=$((${cnt} + 1))
            done ## end train ratio
        done ## end trace opt
    done ## end trace name
done ## end seed


condor_submit_dag -maxjobs ${num_jobs} tmp.${func}.dag

