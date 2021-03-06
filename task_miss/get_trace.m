%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Yi-Chao Chen @ UT Austin
%%
%% get_trace:
%%
%% - Input:
%%   - opt
%%     > 4sq: num_loc, num_rep, loc_type
%%     > p300: subject, session, img_idx, mat_type
%%     > deap: video
%%     > muse: muse
%%
%% - Output:
%%   - mat: 2D data
%%       1st dim (cell): subjects / flows / ...
%%       2nd dim (vector): time series
%%   - r: rank
%%   - bin: time bin size of one sample (s)
%%   - alpha, lambda: parameters for SRMF
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [mat, r, bin, alpha, lambda] = get_trace(trace_name, opt)
    if nargin < 2, opt = 'na'; end

    test_time = 100;

    if strcmp(trace_name, 'abilene')
        input_dir  = '/u/yzhang/MRA/data/';
        X = load([input_dir 'AbileneAnukool/raw/X']); %% 1008x121
        X = X';

        % r = 32;
        r = 4;
        bin = 10*60;
        alpha = 10;
        lambda = 1;
        % alpha = 10;
        % lambda = 100;

    elseif strcmp(trace_name, 'geant')
        input_dir  = '/u/yzhang/MRA/data/';
        files = dir([input_dir 'GeantTotemAnon/TM/2005/04/IntraTM-2005-04-*.xml']);
        t0 = 0;
        tmax = 7*24*4;
        X = [];
        for i = 1:tmax
            file = files(t0+i).name;
            tm_file = [input_dir 'GeantTotemAnon/TM/2005/04/' file '.tm'];
            tm_data = textread(tm_file, '', 'commentstyle', 'shell', 'delimiter', ' ');
            X = [X reshape(tm_data,[],1)];
        end

        % r = 32;
        r = 300;
        bin = 15*60;
        alpha = 1;
        lambda = 100000;

    elseif strcmp(trace_name, 'wifi')
        filename = 'tm_sjtu_wifi.ap_load.all.bin600.top50.txt';
        input_dir='/u/yichao/lens/condor_data/subtask_parse_sjtu_wifi/tm/';
        num_frames=100;
        width=50;
        height=1;

        X = load([input_dir filename])';
        X = X(:, 1:num_frames);

        % r = 8;
        r = 16;
        bin = 10*60;
        alpha = 100;
        lambda = 100;

    elseif strcmp(trace_name, '3g')
        filename = 'tm_3g.cell.bs.bs3.all.bin10.txt';
        input_dir='/u/yichao/lens/condor_data/subtask_parse_huawei_3g/bs_tm/';
        num_frames=144;
        width=472;
        height=1;

        X = load([input_dir filename])';
        X = X(:, 1:num_frames);

        % r = 32;
        r = 8;
        bin = 10*60;
        alpha = 100;
        lambda = 0.00001;

    elseif strcmp(trace_name, 'cu')
        filename = 'tm_multi_loc_rssi.txt';
        input_dir='/u/yichao/lens/condor_data/subtask_parse_multi_loc_rssi/tm/';
        num_frames=500;
        width=895;
        height=1;

        X = load([input_dir filename])';
        X = X(:, 1:num_frames);
        % X = X(1:100, 1:num_frames);

        r = 64;
        bin = 1;
        alpha = 0.1;
        lambda = 10;

    elseif strcmp(trace_name, 'cister')
        filename = 'tm_telos_rssi.txt';
        input_dir='/u/yichao/lens/condor_data/subtask_parse_telos_rssi/tm/';
        num_frames=500;
        width=16;
        height=1;

        X = load([input_dir filename])';
        X = X(:, 1:num_frames);

        % r = 8;
        % r = 64;
        r = 128;
        bin = 1;
        alpha = 100;
        lambda = 0;

    elseif strcmp(trace_name, 'umich')
        filename = 'tm_umich_rss.txt';
        input_dir='/u/yichao/lens/condor_data/subtask_parse_umich_rss/tm/';
        num_frames=1000;
        width=182;
        height=1;

        X = load([input_dir filename])';
        X = X(:, 1:num_frames);

        % r = 32;
        r = 64;
        bin = 1;
        alpha = 1;
        lambda = 0.0001;

    elseif strcmp(trace_name, '1ch-csi')
        filename = 'Mob-Recv1run1.dat0_matrix.mat_dB.txt';
        input_dir='/u/yichao/lens/condor_data/csi/mobile/';
        num_frames=1000;
        width=90;
        height=1;

        X = load([input_dir filename])';
        X = X(:, 1:num_frames);

        % r = 16;
        % r = 90;
        r = 8;
        bin = 1;
        alpha = 0.1;
        lambda = 0.1;

    elseif strcmp(trace_name, 'multi-ch-csi')
        filename = 'static_trace13.ant1.mag.txt';
        input_dir='/u/yichao/lens/condor_data/subtask_parse_csi_channel/csi/';
        num_frames=1000;
        width=270;
        height=1;

        X = load([input_dir filename])';
        X = X(:, 1:num_frames);

        % r = 16;
        % r = 270;
        r = 8;
        bin = 1;
        alpha = 1;
        lambda = 0.0001;

    elseif strcmp(trace_name, 'ucsb')
        filename = 'tm_ucsb_meshnet.connected.txt';
        input_dir='/u/yichao/lens/condor_data/subtask_parse_ucsb_meshnet/tm/';
        num_frames=1000;
        width=425;
        height=1;

        X = load([input_dir filename])';
        X = X(:, 1:num_frames);

        % r = 16;
        r = 300;
        bin = 1*60;
        alpha = 0;
        lambda = 1000;

    elseif strcmp(trace_name, 'speech')
        %% get_speech_data: function description
        inputdir = '/scratch/cluster/yichao/warp/data/speach/';
        files = {'Orig', '093', '088', '085', '082', '078', '075', '072', '069', '064'};

        down_sample = 1000;

        for fi = 1:length(files)
            filename = [inputdir char(files{fi}) '.wav'];
            wav = wavread(filename);
            wav = wav(:, 1)';
            % fprintf('%s\n\t%d\n', filename, length(wav));
            % X{fi} = wav(1:down_sample:end)';
            idx = find(wav(:) > 0.1);
            X{fi} = wav(1, idx(1):min(idx(1)+down_sample,end));
            % fprintf('\t%d\n', length(X{fi}));
        end

        r = 8;
        bin = 1;
        alpha = 0;
        lambda = 1;

    elseif strcmp(trace_name, '4sq')
        [X, r, bin] = get_trace_4sq(opt);
        alpha = 1;
        lambda = 100;

    elseif strcmp(trace_name, 'blink')
        basename = 'new_blink_';
        input_dir='/u/yichao/warp/data/eeg/blinks/';
        file_cnt = [1:12];
        
        min_len = -1;
        for fi = 1:length(file_cnt)
            filename = [input_dir basename num2str(file_cnt(fi)) '.txt'];
            % textread(filename, '%f:%f:%f:%f', -1);
            tmp = textread(filename, '', 'commentstyle', 'shell', 'delimiter', ':')';
            smooth_e0 = smooth2a(tmp(1, :), 10, 1);
            smooth_e3 = smooth2a(tmp(4, :), 10, 1);

            if length(smooth_e0) < min_len || min_len < 0
                min_len = length(smooth_e0);
            end

            X{fi} = smooth_e3;
        end

        for xi = 1:length(X)
            X{xi} = X{xi}(1:min_len);
        end
        
        % r = 16;
        r = length(file_cnt) / 2;
        bin = 1;
        alpha = 10;
        lambda = 0.0001;

    elseif strcmp(trace_name, 'p300')
        [X, r, bin] = get_trace_p300(opt);
        alpha = 10;
        lambda = 10;

    elseif strcmp(trace_name, 'deap')
        [X, r, bin] = get_trace_deap(opt);
        alpha = 10;
        lambda = 10;

    elseif strcmp(trace_name, 'muse')
        [X, r, bin] = get_trace_muse(opt);
        alpha = 10;
        lambda = 10;

    elseif strcmp(trace_name, 'test')
        nr = 20;
        test_time = 1000;
        X = reshape(1:nr*test_time, test_time, nr)';
        r = 3;
        bin = 1;
        alpha = 1;
        lambda = 1;

    elseif strcmp(trace_name, 'test_sine_shift')
        %% y(x, t) = A sin(kx + wt + whi) + D
        %%    x: location
        %%    y: time
        %%    k = 2*pi*f/v = 2*pi/wavlength
        %%    w = 2*pi*f
        %%    whi: phase
        fs = 32;
        wavlen1 = 1;
        k1 = 2*pi/wavlen1;
        x1 = [0:wavlen1/fs:5*wavlen1];

        nr = 5; X = [];
        for ri = 1:nr
            X = [X; rand(1)*4*sin(k1*x1 + rand(1)*pi)];
        end

        r = 2;
        bin = 1;
        alpha = 0;
        lambda = 0;
    
    elseif strcmp(trace_name, 'test_sine_scale')
        fs = 32;
        wavlen1 = 1;
        k1 = 2*pi/wavlen1;
        x1 = [0:wavlen1/fs:20*wavlen1];

        nr = 5; 
        X = [sin(k1*x1)];
        % for ri = 1:nr
        %     X = [X; sin(2*pi/(rand(1)*4)*x1)];
        % end
        X = [X; sin(2*pi/0.5*x1)];
        X = [X; sin(2*pi/4*x1)];
        X = [X; sin(2*pi/2*x1)];
        X = [X; sin(2*pi/3*x1)];

        r = 2;
        bin = 1;
        alpha = 1000;
        lambda = 0.00001;

    elseif strcmp(trace_name, 'test3')
        fs = 32;
        wavlen1 = 1;
        x1 = [0:wavlen1/fs:5*wavlen1];
        k1 = 2*pi/wavlen1;
        wavlen2 = 3;
        k2 = 2*pi/wavlen2;
        
        nr = 10; X = [];
        for ri = 1:nr
            X = [X; rand(1)*4*sin(k1*x1 + rand(1)*pi)];
        end
        nr = 5;
        for ri = 1:nr
            X = [X; rand(1)*4*sin(k2*x1 + rand(1)*pi)];
        end

        r = 2;
        bin = 1;
        alpha = 1000;
        lambda = 0.00001;
    else
        error(['wrong trace name: ' trace_name]);
    
    end

    if iscell(X)
        mat = X;
    else
        mat = num2cell(X, 2);
    end
end

