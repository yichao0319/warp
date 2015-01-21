%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Yi-Chao Chen @ UT Austin
%%
%% - Input:
%%   - opt
%%     > video: the EEG while watching this video
%%
%% - Output:
%%   - X
%%      subject 1, channel 1: sample time series
%%      ...
%%      subject 1, channel 40: sample time series
%%      ...
%%      subject 32, channel 1: sample time series
%%      ...
%%      subject 32, channel 40: sample time series
%%
%% example:
%%
%%     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [X, r, bin] = get_trace_deap(opt)
    
    %% --------------------
    %% DEBUG
    %% --------------------
    DEBUG0 = 0;
    DEBUG1 = 1;
    DEBUG2 = 1;  %% progress
    DEBUG3 = 1;  %% verbose
    DEBUG4 = 1;  %% results


    %% --------------------
    %% Constant
    %% --------------------


    %% --------------------
    %% Variable
    %% --------------------
    input_dir  = '/scratch/cluster/yichao/warp/data/eeg/DEAP/data_preprocessed_matlab/';
    subjects = 1:32;
    channels = 31:40;
    init_pos = 1000;
    num_samples = 1000;
    

    %% --------------------
    %% Check input
    %% --------------------
    if nargin < 1, opt = ''; end
    

    %% --------------------
    %% Main starts
    %% --------------------
    [video] = get_deap_opt(opt);

    X = [];
    for si = subjects

        filename = [input_dir sprintf('s%02d.mat', si)];
        tmp = load(filename);
        raw = squeeze(tmp.data(video, channels, init_pos:init_pos+num_samples-1));

        X = [X; raw];
    end

    r = 64;
    bin = 1;
end


function [video] = get_deap_opt(opt)
    video = 1;

    opts = regexp(opt, ',', 'split');
    for this_opt = opts
        eval([char(this_opt) ';']);
    end
end
