#!/bin/bash

# trace_names=("abilene" "geant" "wifi" "3g" "1ch-csi" "cister" "cu" "multi-ch-csi" "ucsb" "umich" "p300" "4sq" "blink")
# "test_sine_shift" "test_sine_scale" 
trace_names=("4sq")


cluster_method="kmeans"
num_cluster=2
# cluster_method="subspace"
# num_cluster=5000

merge="top"
thresh=1
# merge="num"
# thresh=50
# merge="na"
# thresh=0

dup="best"
# dup="avg"
# dup="equal"
# dup="no"

sync="shift"
metric="coeff"


for trace_name in ${trace_names[@]}; do

    if [[ ${trace_name} == "p300" ]]; then
        trace_opt="subject=1,session=1,img_idx=0"

    elif [[ ${trace_name} == "4sq" ]]; then
        trace_opt="num_loc=100,num_rep=1,loc_type=1"

    else
        trace_opt="na"
    fi
    
    matlab -r "[mae] = do_missing_exp('${trace_name}', '${trace_opt}', 'frac=1,lr=0.1,elem_mode=''elem'',loss_mode=''ind'',burst=1', 'num_seg=1,sync=''${sync}'',metric=''${metric}'',sigma=1', 'method=''${cluster_method}'',num=${num_cluster},head=''best'',merge=''${merge}'',thresh=${thresh}', 'dup=''${dup}''', 'na', 'lens', 1); exit;"
done
