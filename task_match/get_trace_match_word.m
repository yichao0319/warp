%% get_trace_match_word:
%% Output
%%   - X: the 3D data
%%        1st dim (cell): words
%%        2nd dim (matrix): features
%%        3rd dim (matrix): samples over time
%%   - gt_class: vector of ground-truth class 
%%        the class the word belongs to.
%%        always labeled as 1, 2, 3, ...
function [X, gt_class] = get_trace_match_word(opt)
    addpath('/v/filer4b/v27q002/ut-wireless/yichao/warp/git_repository/task_dtw');

    DEBUG2 = 1;

    if nargin < 1, opt = ''; end

    [feature] = get_trace_match_word_opt(opt);

    inputdir = '/scratch/cluster/yichao/warp/data/speech_word/';
    words = {'home', 'how', 'house', 'buy', 'texas', 'tex', 'university'};
    repeats = 1:5;
    
    % Define variables for MFCC
    Fs = 44100;
    Tw = 25;                % analysis frame duration (ms)
    Ts = 10;                % analysis frame shift (ms)
    alpha = 0.97;           % preemphasis coefficient
    M = 20;                 % number of filterbank channels 
    C = 12;                 % number of cepstral coefficients
    L = 22;                 % cepstral sine lifter parameter
    LF = 300;               % lower frequency limit (Hz)
    HF = 3700;              % upper frequency limit (Hz)

    r0 = C;



    %% read the raw wav data
    if DEBUG2, fprintf('    read raw data\n'); end 

    tsc = 0;
    max_len = 0;
    for wi = 1:length(words)
        for ri = repeats
            tsc = tsc + 1;
            filename = [inputdir char(words{wi}) num2str(ri) '.wav'];
            wav = wavread(filename);
            % raw_X{tsc} = [zeros(1, 2*Fs) wav(:, 1)' zeros(1, 2*Fs)];
            raw_X{tsc} = [wav(:, 1)'];
            if length(raw_X{tsc}) > max_len
                max_len = length(raw_X{tsc});
            end

            gt_class(tsc) = wi;
        end
    end


    %% prepare for the output
    for tsi = 1:length(raw_X)
        % %% make raw wav the same size
        % pad_len = max_len - length(raw_X{tsi});
        % wav = [raw_X{tsi} zeros(1, pad_len)];
        wav = raw_X{tsi};

        if strcmp(feature, 'raw')
            X{tsi} = wav;
        elseif strcmp(feature, 'mfcc')
            %% do MFCC
            if DEBUG2 & tsi == 1, fprintf('    MFCC\n'); end 

            [MFCCs, FBEs, frames] = mfcc(wav, Fs, Tw, Ts, alpha, @hamming, [LF HF], M, C+1, L );
            idx = find(isnan(MFCCs));
            MFCCs(idx) = 0;

            X{tsi} = MFCCs;

        elseif strcmp(feature, 'spectrogram')
            if DEBUG2 & tsi == 1, fprintf('    spectrogram\n'); end 

            window = floor(Fs * Tw / 1000);
            noverlap = floor(window * Ts / Tw);
            Nfft = Fs;

            [S,F,T,P] = spectrogram(wav, window, noverlap, Nfft, Fs);

            LF_ind = freq2ind(LF, Fs/2, length(F));
            HF_ind = freq2ind(HF, Fs/2, length(F));    
            X{tsi} = 10*log10(P(LF_ind:HF_ind, :));

        elseif strcmp(feature, 'lowrank')
            if DEBUG2 & tsi == 1, fprintf('    low rank\n'); end 

            window = floor(Fs * Tw / 1000);
            noverlap = floor(window * Ts / Tw);
            Nfft = Fs;
            [S,F,T,P] = spectrogram(wav, window, noverlap, Nfft, Fs);

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
function [feature] = get_trace_match_word_opt(opt)
    feature = 'raw';
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