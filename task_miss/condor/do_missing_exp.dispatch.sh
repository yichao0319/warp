#!/bin/bash

func="do_missing_exp"

num_jobs=70
cnt=0

## clean log files
rm -rf /u/yichao/warp/condor_data/task_miss/condor/log_missing
mkdir /u/yichao/warp/condor_data/task_miss/condor/log_missing

## DAG 
rm tmp.$func.dag*
echo "" > tmp.$func.dag


## trace
# trace_names=("abilene" "geant" "wifi" "3g" "1ch-csi" "cister" "cu" "ucsb" "umich" "p300" "4sq" "deap" "muse" "multi-ch-csi")
# trace_names=("muse" "p300" "deap" "wifi" "1ch-csi" "abilene" "umich" "cister" "multi-ch-csi")
trace_names=("abilene" "geant" "wifi" "3g" "1ch-csi" "cister" "cu" "ucsb" "umich" "p300" "4sq" "deap" "muse" "multi-ch-csi")
# trace_names=("multi-ch-csi")
# "test_sine_shift" "test_sine_scale" "blink" 


## dropping elements
elem_frac=1
loss_rates=(0.05 0.1 0.15 0.2)
elem_mode="elem"
loss_mode="ind"
burst_size=1

## sync
# sync_methods=("na" "dtw" "shift" "stretch")
sync_methods=("shift")
# sync_methods=("stretch")
metrics=("coeff")
num_seg=1

## cluster
# cluster_methods=("subspace" "spectral")
# cluster_methods=("spectral")
cluster_methods=("kmeans" "subspace")
# num_clusters=(0 5000)
# head_types=("best" "random" "worst")
head_types=("best" "worst")
merges=("num" "top")

## evaluation
dups=("no" "best" "avg" "equal")

# init_esti_methods=("na" "lens")
init_esti_methods=("na")
final_esti_methods=("lens")

# seeds=(1 2 3 4 5)
seeds=(3)


for seed in ${seeds[@]}; do
    for trace_name in ${trace_names[@]}; do

        if [[ ${trace_name} == "p300" ]]; then
            trace_opt="subject=1,session=1,img_idx=0"
        elif [[ ${trace_name} == "4sq" ]]; then
            trace_opt="num_loc=100,num_rep=1,loc_type=1"
        elif [[ ${trace_name} == "deap" ]]; then
            trace_opt="video=1"
        elif [[ ${trace_name} == "muse" ]]; then
            trace_opt="muse=''4ch''"
        else
            trace_opt="na"
        fi
        
        for loss_rate in ${loss_rates[@]}; do

            drop_opt="frac=${elem_frac},lr=${loss_rate},elem_mode=''${elem_mode}'',loss_mode=''${loss_mode}'',burst=${burst_size}"

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

                            if [[ ${cluster_method} == "subspace" ]]; then
                                num_clusters=(5000)
                            elif [[ ${cluster_method} == "spectral" ]]; then
                                num_clusters=(0)
                            else
                                num_clusters=(1 2 4 8)
                            fi

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

                                            ## eval
                                            for dup in ${dups[@]}; do
                                                
                                                eval_opt="dup=''${dup}''"

                                                ## estimation method
                                                for init_esti_method in ${init_esti_methods[@]}; do
                                                    for final_esti_method in ${final_esti_methods[@]}; do
                                                        
                                                        # trace_name, trace_opt, drop_opt, ...
                                                        # sync_opt, cluster_opt, eval_opt, ...
                                                        # init_esti_method, final_esti_method, ...
                                                        # seed
                                                        name=${trace_name}.${trace_opt}.${drop_opt}.${sync_opt}.${cluster_opt}.${eval_opt}.${init_esti_method}.${final_esti_method}.${seed}
                                                        echo ${name}
                                                        sed "s/TRACE_NAME/${trace_name}/g; s/TRACE_OPT/${trace_opt}/g; s/DROP_OPT/${drop_opt}/g; s/SYNC_OPT/${sync_opt}/g; s/CLUSTER_OPT/${cluster_opt}/g; s/EVAL_OPT/${eval_opt}/g; s/INIT_ESTI_METHOD/${init_esti_method}/g; s/FINAL_ESTI_METHOD/${final_esti_method}/g; s/SEED/${seed}/g; " ${func}.mother.sh > tmp.${name}.sh
                                                        sed "s/XXX/${name}/g" ${func}.mother.condor > tmp.${name}.condor
                                                        # condor_submit tmp.${name}.condor
                                                        echo JOB J${cnt} tmp.${name}.condor >> tmp.$func.dag
                                                        cnt=$((${cnt} + 1))
                                                    done ## end final esti method
                                                done ## end init esti method
                                            done ## end eval opt
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
done


condor_submit_dag -maxjobs ${num_jobs} tmp.${func}.dag



