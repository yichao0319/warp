%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 
%% get_trace_seg_word:
%%
%% - Output
%%   - X: the 3D data
%%        1st dim (cell): subjects / words / ...
%%        2nd dim (matrix): features
%%        3rd dim (matrix): samples over time
%%   - sample_class: 2D data
%%        the class that each sample belongs to
%%        the classes are always labeled from 1, 2, 3, ...
%%        1st dim (cell): subjects / words /...
%%        2nd dim (vector): class of samples
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [X, sample_class] = get_trace_seg_word(opt)
    addpath('/v/filer4b/v27q002/ut-wireless/yichao/warp/git_repository/task_match/mfcc');

    DEBUG2 = 1;

    if nargin < 1, opt = ''; end

    
    inputdir = '/scratch/cluster/yichao/warp/data/speech_word/';
    words = {'home', 'how', 'house', 'buy', 'texas', 'tex', 'university'};
    subjects = 1:5;
    
    Fs = 44100;
    
    %% -----------------------
    %% get option 
    [feature, num] = get_trace_seg_word_opt(opt);


    %% -----------------------
    %% select words to concatenate
    if num <= 0, num = length(words); end
    select_idx = 1:num;


    %% -----------------------
    %% read data
    if DEBUG2, fprintf('    read raw data\n'); end 

    for ri = subjects
        X{ri} = [];
        sample_class{ri} = [];

        for si = select_idx
            filename = [inputdir char(words{si}) num2str(ri) '.wav'];
            wav = wavread(filename);
            wav = wav(:, 1)';
            % wav = [zeros(1, randi(1*Fs)) wav zeros(1, randi(1*Fs))];

            %% -----------------------
            %% preprocessing
            prep_data = preporcess_wav(wav, feature);
            this_class = ones(1, size(prep_data,2)) * si;

            X{ri} = [X{ri} prep_data];
            sample_class{ri} = [sample_class{ri} this_class];
        end
    end

end


%% get_dtw_opt: function description
function [feature, num] = get_trace_seg_word_opt(opt)
    feature = 'raw';
    num = 0;
    if nargin < 1, return; end

    opts = regexp(opt, ',', 'split');
    for this_opt = opts
        eval([char(this_opt) ';']);
    end
end


%% preporcess_wav
function [prep_data] = preporcess_wav(wav, feature)
    
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

    if strcmp(feature, 'raw')
        prep_data = wav;
    elseif strcmp(feature, 'mfcc')
        %% do MFCC
    
        [MFCCs, FBEs, frames] = mfcc(wav, Fs, Tw, Ts, alpha, @hamming, [LF HF], M, C+1, L );
        idx = find(isnan(MFCCs));
        MFCCs(idx) = 0;

        prep_data = MFCCs;

    elseif strcmp(feature, 'spectrogram')
    
        window = floor(Fs * Tw / 1000);
        noverlap = floor(window * Ts / Tw);
        Nfft = Fs;

        [S,F,T,P] = spectrogram(wav, window, noverlap, Nfft, Fs);

        LF_ind = freq2ind(LF, Fs/2, length(F));
        HF_ind = freq2ind(HF, Fs/2, length(F));    
        prep_data = 10*log10(P(LF_ind:HF_ind, :));

    elseif strcmp(feature, 'lowrank')
    
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

        
        prep_data = U_lr * S_lr * V_lr';

    else
        error(['wrong feature: ' feature]);
    end
end


%% freq2ind
function [ind] = freq2ind(freq, max_freq, F_len)
    ind = floor(freq / max_freq * F_len);
end