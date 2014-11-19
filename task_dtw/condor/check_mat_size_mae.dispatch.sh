#!/bin/bash

func="check_mat_size_mae"

num_jobs=50
cnt=0

## clean log files
rm /u/yichao/warp/condor_data/task_dtw/condor/log_check_mat_size_mae/*

## DAG 
rm tmp.$func.dag*
echo "" > tmp.$func.dag


trace_names=("abilene" "geant" "wifi" "3g" "1ch-csi" "cister" "cu" "multi-ch-csi" "ucsb" "umich" "p300" "4sq")

elem_frac=1
loss_rates=(0.01 0.05 0.1 0.15 0.2 0.4)
elem_mode="elem"
loss_mode="ind"
burst_size=1

submatrix_ratios=(0.1 0.3 0.5 0.7 0.9)

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

            for submatrix_ratio in ${submatrix_ratios[@]}; do
                
                name=${trace_name}.${trace_opt}.elem${elem_frac}.lr${loss_rate}.${elem_mode}.${loss_mode}.${burst_size}.${submatrix_ratio}.s${seed}
                echo ${name}
                sed "s/TRACE_NAME/${trace_name}/g; s/TRACE_OPT/${trace_opt}/g; s/ELEM_FRAC/${elem_frac}/g; s/LOSS_RATE/${loss_rate}/g; s/ELEM_MODE/${elem_mode}/g; s/LOSS_MODE/${loss_mode}/g; s/BURST_SIZE/${burst_size}/g; s/SUB_RATIO/${submatrix_ratio}/g; s/SEED/${seed}/g; " ${func}.mother.sh > tmp.${name}.sh
                sed "s/XXX/${name}/g" ${func}.mother.condor > tmp.${name}.condor
                # condor_submit tmp.${name}.condor
                echo JOB J${cnt} tmp.${name}.condor >> tmp.$func.dag
                cnt=$((${cnt} + 1))
            done
        done
    done
done


condor_submit_dag -maxjobs ${num_jobs} tmp.${func}.dag



