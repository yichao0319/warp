%% get_trace_match_deap:
%% Output
%%   - X: the 3D data
%%        1st dim (cell): words
%%        2nd dim (matrix): features
%%        3rd dim (matrix): samples over time
%%   - gt_class: vector of ground-truth class 
%%        the class the word belongs to.
%%        always labeled as 1, 2, 3, ...
function [X, gt_class] = get_trace_match_deap(opt)
    addpath('/v/filer4b/v27q002/ut-wireless/yichao/warp/git_repository/task_dtw');

    DEBUG2 = 1;

    if nargin < 1, opt = ''; end

    subjects = 1:32;
    videos = 1:40;
    [feature, channel] = get_trace_match_deap_opt(opt);

    inputdir = '/scratch/cluster/yichao/warp/data/eeg/DEAP/data_preprocessed_matlab/';

    % Define variables for MFCC
    Fs = 128;
    Tw = 50;                % analysis frame duration (ms)
    Ts = 20;                % analysis frame shift (ms)
    alpha = 0.97;           % preemphasis coefficient
    M = 5;                 % number of filterbank channels 
    C = 3;                 % number of cepstral coefficients
    L = 6;                 % cepstral sine lifter parameter
    LF = 1;               % lower frequency limit (Hz)
    HF = 40;              % upper frequency limit (Hz)

    r0 = 2;


    %% read the raw eeg data
    if DEBUG2, fprintf('    read raw data\n'); end 

    tsc = 0;
    for si = subjects
        filename = [inputdir sprintf('s%02d.mat', si)];
        %% X.data: [video, channel, time]
        tmp = load(filename);

        for vi = videos
            tsc = tsc + 1;    

            raw_X{tsc} = squeeze(tmp.data(vi, channel, :));
            gt_class(tsc) = vi;
        end
    end


    %% prepare for the output
    for tsi = 1:length(raw_X)
        eeg = raw_X{tsi};

        if strcmp(feature, 'raw')
            X{tsi} = eeg;
        elseif strcmp(feature, 'mfcc')
            %% do MFCC
            if DEBUG2 & tsi == 1, fprintf('    MFCC\n'); end 

            [MFCCs, FBEs, frames] = mfcc(eeg, Fs, Tw, Ts, alpha, @hamming, [LF HF], M, C+1, L );
            idx = find(isnan(MFCCs));
            MFCCs(idx) = 0;

            X{tsi} = MFCCs;

        elseif strcmp(feature, 'spectrogram')
            if DEBUG2 & tsi == 1, fprintf('    spectrogram\n'); end 

            window = floor(Fs * Tw / 1000);
            noverlap = floor(window * Ts / Tw);
            Nfft = Fs;
            % fprintf('    window=%d,noverlap=%d,Nfft=%d\n', window, noverlap, Nfft);
            [S,F,T,P] = spectrogram(eeg, window, noverlap, Nfft, Fs);
            
            LF_ind = freq2ind(LF, Fs/2, length(F));
            HF_ind = freq2ind(HF, Fs/2, length(F));    
            X{tsi} = 10*log10(P(LF_ind:HF_ind, :));

        elseif strcmp(feature, 'lowrank')
            if DEBUG2 & tsi == 1, fprintf('    low rank\n'); end 

            window = floor(Fs * Tw / 1000);
            noverlap = floor(window * Ts / Tw);
            Nfft = Fs;
            [S,F,T,P] = spectrogram(eeg, window, noverlap, Nfft, Fs);

            LF_ind = freq2ind(LF, Fs/2, length(F));
            HF_ind = freq2ind(HF, Fs/2, length(F));    
            mat = 10*log10(P(LF_ind:HF_ind, :));

            [U, S, V] = svd(mat);
            U_lr = U(:, 1:min(r0,end));
            S_lr = S(1:min(r0,end), 1:min(r0,end));
            V_lr = V(:, 1:min(r0,end));

            
            X{tsi} = U_lr * S_lr * V_lr';

        else
            error(['wrong feature: ' feature]);
        end
    end

end


%% get_dtw_opt: function description
function [feature, channel] = get_trace_match_deap_opt(opt)
    feature = 'raw';
    % subject = 1;  %% 1-32
    video = 1;    %% 1-40
    channel = 1;  %% 1-40
    if nargin < 1, return; end

    opts = regexp(opt, ',', 'split');
    for this_opt = opts
        eval([char(this_opt) ';']);
    end
end


%% freq2ind
function [ind] = freq2ind(freq, max_freq, F_len)
    ind = floor(freq / max_freq * F_len);
end