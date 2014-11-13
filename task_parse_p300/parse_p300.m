addpath('/u/yichao/lens/utils/p300soft');
setpath;

input_dir = '/scratch/cluster/yichao/anomaly_compression/data/eeg/P300/';
output_dir = '/scratch/cluster/yichao/anomaly_compression/processed_data/subtask_parse_p300/';
subjects = [1, 2, 3, 4, 6, 7, 8, 9];
sessions = [1:4];

for sji = 1:length(subjects)
    sj = subjects(sji);

    for ssi = 1:length(sessions)
        ss = sessions(ssi);
        extracttrials([input_dir 'subject' int2str(sj) '/session' int2str(ss)], [output_dir 's' int2str(sj) int2str(ss)]);
    end
end