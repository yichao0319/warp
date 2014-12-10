ls -alh ~/warp/condor_data/task_match/condor/log/*err | awk -F' ' '{if($5!=108 && $5!=0) print $9}' | awk -F'/' '{print $9}' | awk -F'.err' '{print "condor_submit ./tmp."$1".condor"}'
