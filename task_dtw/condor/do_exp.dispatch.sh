#!/bin/bash

func="do_exp"

num_jobs=100
cnt=0

## clean log files
rm /u/yichao/warp/condor_data/task_dtw/condor/log/*

## DAG 
rm tmp.$func.dag*
echo "" > tmp.$func.dag

warp_methods=("dtw" "shift" "stretch")
warp_opt="num_seg=1"
cluster_methods=("kmeans" "hierarchical" "hier_affinity" "kmeans_affinity")
num_clusters=("Inf" 1 5)
rank_seg=1
rank_percnetile=0.8
rank_cluster_methods=(1 2)

trace_names=("abilene" "geant" "wifi" "3g" "1ch-csi" "cister" "cu" "multi-ch-csi" "ucsb" "umich" "test_sine_shift" "test_sine_scale")

for num_cluster in ${num_clusters[@]}; do
    for cluster_method in ${cluster_methods[@]}; do
        if [[ ${num_cluster} -eq "Inf" ]] || [[ ${num_cluster} -eq 1 ]]; then
            if [[ ${cluster_method} != "kmeans" ]]; then
                continue;
            fi
        fi

        for rank_cluster_method in ${rank_cluster_methods[@]}; do

            if [[ ${num_cluster} -eq "Inf" ]] || [[ ${num_cluster} -eq 1 ]]; then
                if [[ ${rank_cluster_method} -ne 1 ]]; then
                    continue;
                fi
            fi

            rank_opt="percentile=${rank_percnetile},num_seg=${rank_seg},r_method=${rank_cluster_method}"

            for warp_method in ${warp_methods[@]}; do

                if [[ ${num_cluster} == "Inf" ]] && [[ ${warp_method} != "dtw" ]]; then
                    continue;
                fi

                #####################################
                ## 4sq
                trace_name="4sq"
                trace_opts=("loc_type=4" "num_loc=100,num_rep=1,loc_type=1" "num_loc=10,num_rep=1,loc_type=1")

                for trace_opt in ${trace_opts[@]}; do

                    name=${trace_name}.${trace_opt}.${cluster_method}.${num_cluster}.${warp_method}.${rank_opt}.${warp_opt}
                    echo ${name}
                    sed "s/TRACE_NAME/${trace_name}/g; s/TRACE_OPT/${trace_opt}/g; s/CLUST_METHOD/${cluster_method}/g; s/NUM_CLUST/${num_cluster}/g; s/WARP_METHOD/${warp_method}/g; s/RANK_OPT/${rank_opt}/g; s/WARP_OPT/${warp_opt}/g; " ${func}.mother.sh > tmp.${name}.sh
                    sed "s/XXX/${name}/g" ${func}.mother.condor > tmp.${name}.condor
                    # condor_submit tmp.${name}.condor
                    echo JOB J${cnt} tmp.${name}.condor >> tmp.$func.dag
                    cnt=$((${cnt} + 1))
                done

                #####################################
                ## p300: subject=1,session=1,img_idx=7
                trace_name="p300"
                subjects=(1 6)
                sessions=(1)
                img_idces=(0 7 2)

                for subject in ${subjects[@]}; do
                    for session in ${sessions[@]}; do
                        for img_idx in ${img_idces[@]}; do

                            trace_opt="subject=${subject},session=${session},img_idx=${img_idx}"

                            name=${trace_name}.${trace_opt}.${cluster_method}.${num_cluster}.${warp_method}.${rank_seg}.${rank_opt}.${warp_opt}
                            echo ${name}
                            sed "s/TRACE_NAME/${trace_name}/g; s/TRACE_OPT/${trace_opt}/g; s/CLUST_METHOD/${cluster_method}/g; s/NUM_CLUST/${num_cluster}/g; s/WARP_METHOD/${warp_method}/g; s/RANK_OPT/${rank_opt}/g; s/WARP_OPT/${warp_opt}/g; " ${func}.mother.sh > tmp.${name}.sh
                            sed "s/XXX/${name}/g" ${func}.mother.condor > tmp.${name}.condor
                            # condor_submit tmp.${name}.condor
                            echo JOB J${cnt} tmp.${name}.condor >> tmp.$func.dag
                            cnt=$((${cnt} + 1))
                        done
                    done
                done


                #####################################
                ## other traces
                trace_opt="na"

                for trace_name in ${trace_names[@]}; do

                    name=${trace_name}.${trace_opt}.${cluster_method}.${num_cluster}.${warp_method}.${rank_opt}.${warp_opt}
                    echo ${name}
                    sed "s/TRACE_NAME/${trace_name}/g; s/TRACE_OPT/${trace_opt}/g; s/CLUST_METHOD/${cluster_method}/g; s/NUM_CLUST/${num_cluster}/g; s/WARP_METHOD/${warp_method}/g; s/RANK_OPT/${rank_opt}/g; s/WARP_OPT/${warp_opt}/g; " ${func}.mother.sh > tmp.${name}.sh
                    sed "s/XXX/${name}/g" ${func}.mother.condor > tmp.${name}.condor
                    # condor_submit tmp.${name}.condor
                    echo JOB J${cnt} tmp.${name}.condor >> tmp.$func.dag
                    cnt=$((${cnt} + 1))
                done

            done
        done
    done
done


condor_submit_dag -maxjobs ${num_jobs} tmp.${func}.dag



