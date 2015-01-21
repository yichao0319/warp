## do_exp: 

# trace_names=("abilene" "geant" "wifi" "3g" "1ch-csi" "cister" "cu" "multi-ch-csi" "ucsb" "umich" "test_sine_shift" "test_sine_scale" "p300" "4sq" "blink")

# cluster_method="kmeans"
# num_cluster=1
# sync_method="shift_limit"

# for trace_name in ${trace_names[@]}; do

#     if [[ ${trace_name} == "p300" ]]; then
#         trace_opt="subject=1,session=1,img_idx=0"

#     elif [[ ${trace_name} == "4sq" ]]; then
#         trace_opt="num_loc=100,num_rep=1,loc_type=1"

#     else
#         trace_opt="na"
#     fi
    
#     matlab -r "do_exp('${trace_name}', '${trace_opt}', 'percentile=0.8,num_seg=1,r_method=1', $num_cluster, '$cluster_method', '$sync_method', 'num_seg=1'); exit;"
# done


do_exp('multi-ch-csi', 'na', 'num_seg=1,sync=''shift'',metric=''coeff'',sigma=1', 'method=''kmeans'',num=2,head=''best'',merge=''num'',thresh=30', 'percentile=0.8,num_seg=1,r_method=1', 1);


do_exp('abilene', 'na', 'num_seg=1,sync=''shift'',metric=''coeff'',sigma=1', 'method=''kmeans'',num=2,head=''best'',merge=''top'',thresh=1', 'percentile=0.8,num_seg=1,r_method=1', 1);

do_exp('1ch-csi', 'na', 'num_seg=1,sync=''shift'',metric=''coeff'',sigma=1', 'method=''kmeans'',num=1,head=''best'',merge=''num'',thresh=30', 'percentile=0.8,num_seg=1,r_method=1', 1);

do_exp('3g', 'na', 'num_seg=1,sync=''shift'',metric=''coeff'',sigma=1', 'method=''kmeans'',num=1,head=''best'',merge=''num'',thresh=30', 'percentile=0.8,num_seg=1,r_method=1', 1);

do_exp('4sq', 'num_loc=100,num_rep=1,loc_type=1', 'num_seg=1,sync=''shift'',metric=''coeff'',sigma=1', 'method=''kmeans'',num=1,head=''best'',merge=''num'',thresh=30', 'percentile=0.8,num_seg=1,r_method=1', 1);

do_exp('cister', 'na', 'num_seg=1,sync=''shift'',metric=''coeff'',sigma=1', 'method=''kmeans'',num=8,head=''best'',merge=''top'',thresh=1', 'percentile=0.8,num_seg=1,r_method=1', 1);

do_exp('cu', 'na', 'num_seg=1,sync=''shift'',metric=''coeff'',sigma=1', 'method=''kmeans'',num=8,head=''best'',merge=''num'',thresh=30', 'percentile=0.8,num_seg=1,r_method=1', 1);

do_exp('deap', 'video=1', 'num_seg=1,sync=''shift'',metric=''coeff'',sigma=1', 'method=''kmeans'',num=8,head=''best'',merge=''num'',thresh=30', 'percentile=0.8,num_seg=1,r_method=1', 1);

do_exp('geant', 'na', 'num_seg=1,sync=''shift'',metric=''coeff'',sigma=1', 'method=''kmeans'',num=8,head=''best'',merge=''num'',thresh=30', 'percentile=0.8,num_seg=1,r_method=1', 1);

do_exp('muse', 'muse=''4ch''', 'num_seg=1,sync=''shift'',metric=''coeff'',sigma=1', 'method=''kmeans'',num=4,head=''best'',merge=''top'',thresh=1', 'percentile=0.8,num_seg=1,r_method=1', 1);

do_exp('p300', 'subject=1,session=1,img_idx=0', 'num_seg=1,sync=''shift'',metric=''coeff'',sigma=1', 'method=''kmeans'',num=4,head=''best'',merge=''num'',thresh=30', 'percentile=0.8,num_seg=1,r_method=1', 1);

do_exp('ucsb', 'na', 'num_seg=1,sync=''shift'',metric=''coeff'',sigma=1', 'method=''kmeans'',num=4,head=''best'',merge=''num'',thresh=30', 'percentile=0.8,num_seg=1,r_method=1', 1);

do_exp('umich', 'na', 'num_seg=1,sync=''shift'',metric=''coeff'',sigma=1', 'method=''kmeans'',num=1,head=''best'',merge=''num'',thresh=30', 'percentile=0.8,num_seg=1,r_method=1', 1);

do_exp('wifi', 'na', 'num_seg=1,sync=''shift'',metric=''coeff'',sigma=1', 'method=''kmeans'',num=2,head=''worst'',merge=''num'',thresh=30', 'percentile=0.8,num_seg=1,r_method=1', 1);
