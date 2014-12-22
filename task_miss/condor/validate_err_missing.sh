ls -alh ~/warp/condor_data/task_miss/condor/log_missing/*err | awk -F' ' '{if($5!=108 && $5!=0) print $9}' | awk -F'/' '{print $9}' | awk -F'.err' '{print "condor_submit ./tmp."$1".condor"}'
