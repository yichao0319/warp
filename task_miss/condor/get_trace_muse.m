%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Yi-Chao Chen @ UT Austin
%%
%% - Input:
%%   - opt
%%     > muse: the type of MUSE matrix to generate
%%       - 4ch: use the raw data from 4 channels
%%              subject 1, channel 1: sample time series
%%              ...
%%              subject 1, channel 4: sample time series
%%              ...
%%              subject 10, channel 1: sample time series
%%              ...
%%              subject 10, channel 4: sample time series
%%       - freq: use the frequency of raw data (alpha, beta, ... wave)
%%
%% - Output:
%%
%%
%% example:
%%
%%     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [X, r, bin] = get_trace_muse(opt)
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
    input_dir  = '/u/swadhin/Datasets/MUSE_EEG_VIDEO/users/';
    init_pos = 1000;
    num_samples = 1000;


    %% --------------------
    %% Check input
    %% --------------------
    if nargin < 1, opt = ''; end
    

    %% --------------------
    %% Main starts
    %% --------------------
    [muse] = get_muse_opt(opt);

    X = [];
    if strcmp(muse, '4ch')
        subjects = dir([input_dir 'R*']);
        for si = 1:length(subjects)
            files = dir([input_dir subjects(si).name '/*_eeg.csv']);
            for fi = 1:length(files)
                filename = [input_dir subjects(si).name '/' files(fi).name];
                raw = load(filename)';
                X = [X; raw(:, init_pos:init_pos+num_samples-1)];
            end
        end

        r = 16;
        bin = 1;
    
    elseif strcmp(muse, 'freq')
        error(['not implemented yet: MUSE data with opt: ' opt]);

    else
        error(['wrong opt: ' opt]);
    end

end


function [muse] = get_muse_opt(opt)
    muse = '4ch';

    opts = regexp(opt, ',', 'split');
    for this_opt = opts
        eval([char(this_opt) ';']);
    end
end
