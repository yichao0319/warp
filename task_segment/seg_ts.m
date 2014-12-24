%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Yi-Chao Chen @ UT Austin
%%
%% seg_ts: 
%% 
%% Partition sensor data by finding sliding windows with local minimum rank.
%% The idea is if subjects are doing the same activity, 
%% the synchronized sensor data should be similar and 
%% therefore be low rank. While during the time between 
%% activities, subjects may move arbitrarily so the windows 
%% containing these periods have higher rank.
%%
%% Step 1. Read sensor data and organize as a 2D matrix:
%%             subject 1 feature 1 sensor data time series: t_{1,1,t1}
%%             ...
%%             subject 1 feature n, sensor data time series: t_{1,n,t1}
%%             ...
%%             subject m feature 1, sensor data time series: t_{m,1,tm}
%%             ...
%%             subject m feature n, sensor data time series: t_{m,n,tm}
%% Step 2. Synchronize rows using DTW
%% Step 3. Calculate the ranks of sliding windows with different sizes
%% Step 4. Finding the local minimum ranks as the change points
%%
%%
%% - Input:
%%
%%   1. trace_name:
%%     > word, acc-wrist
%%
%%   2. trace_opt
%%     > feature:
%%       The preprocessing of the data
%%       - raw, mfcc, spectrogram, lowrank, quantization, mag, and etc
%%     > set:
%%       The class set to use (for acc-wrist)
%%       set = 1, 2, or 3
%%     > num:
%%       Number of classes to be concategated
%%       - num == 0: use all classes
%%
%%   3. sync_opt
%%     > sync: na, dtw, shift, stretch
%%     > metric: coeff, dist
%%     > num_seg: number of segments (do sync for each segment)
%%
%%   4. rank_opt
%%     > percentile
%%
%% example:
%%   seg_ts('word', 'feature=''mfcc'',num=3', 'sync=''dtw'',metric=''dist'',num_seg=1', 'percentile=0.8', 1)
%%   
%%   seg_ts('acc-wrist', 'feature=''raw'',num=3', 'sync=''dtw'',metric=''dist'',num_seg=1', 'percentile=0.8', 1)
%%   
function [change_points] = seg_ts(trace_name, trace_opt, sync_opt, rank_opt, seed)
    addpath('/u/yichao/warp/git_repository/task_dtw/c_func');
    % addpath('/u/yichao/lens/utils/compressive_sensing');

    %% --------------------
    %% DEBUG
    %% --------------------
    DEBUG0 = 0;
    DEBUG1 = 1;
    DEBUG2 = 1;  %% progress
    DEBUG3 = 1;  %% verbose
    DEBUG4 = 1;  %% results

    PERFECT_SYNC = 0;   %% set to 1 if assuming perfect synchronization


    %% --------------------
    %% Variables
    %% --------------------
    rand('seed', seed);
    randn('seed', seed);

    % output_dir = '../../processed_data/task_dtw/do_exp/';
    % output_dir = '/u/yichao/warp/condor_data/task_dtw/condor/do_exp/';


    %% --------------------
    %% load data
    %% --------------------
    if DEBUG2, fprintf('load data\n'); end

    [X, sample_class] = get_trace_seg(trace_name, trace_opt);
    
    if DEBUG3
        fprintf('  #subjects=%d, #activities=%d\n', length(X), length(unique(sample_class{1})));
    end

    
    %% --------------------
    %% clustering
    %% --------------------
    % if DEBUG2, fprintf('clustering\n'); end
    
    
    %% --------------------
    %% sync
    %% --------------------
    if DEBUG2, fprintf('sync\n'); end

    if PERFECT_SYNC
        %% -------------------
        %% Perfect synchronization:
        %%   all activities are sync before concatenated 
        [X_sync, sample_class_sync] = perfect_sync_data(X, sample_class, sync_opt);
        %% -------------------
    else
        %% -------------------
        %% synchronize the whole traces:
        other_mat{1} = sample_class;
        [X_sync, other_sync] = sync_data(X, sync_opt, other_mat);
        sample_class_sync = other_sync{1};
        %% -------------------
    end
        

    if DEBUG3
        fprintf('  #subjects=%d, #activities=%d\n', length(X_sync), length(unique(sample_class_sync{1})));
        fprintf('  len of subject 1 = %d\n', size(X_sync{1}, 2));
    end


    %% --------------------
    %% calculate ranks for sliding windows
    %% --------------------
    if DEBUG2, fprintf('calculate ranks for sliding windows\n'); end

    len = size(X_sync{1},2);
    %% ----------
    % num_win = 5;
    % wr_std = 1/4;
    % wr_end = 1/2;
    % win_start = floor(len * wr_std);
    % win_end = floor(len * wr_end);
    % itvl = max(1, floor((win_end - win_start) / num_win));
    % windows = [win_start:itvl:win_end];
    %% ----------
    % windows = [400 500 600 700 800];
    % windows = [100:100:800];
    windows = [80:20:300]; %% > good for perfect synchronization
    % windows = [50:50:1000];
    % windows = [30 40 50 80 100];
    % windows = [10:10:100];
    if DEBUG3, 
        % fprintf('  data len=%d, window size: %d:%d:%d\n', len, win_start, itvl, win_end);
        fprintf('  win: ');
        fprintf('%d,', windows);
        fprintf('\n');
    end


    for wi = 1:length(windows)
        win = windows(wi);
        if DEBUG3, fprintf('    win=%d\n', win); end

        mat_X = my_cell2mat(X_sync);
            
        for idx = 1:len-win+1
            slide_X = mat_X(:, idx:idx+win-1);
            ranks{wi}(1, idx) = cal_rank(slide_X, rank_opt);
        end
    end

    plot_ts_sync_rank(X, sample_class, X_sync, sample_class_sync, ranks, windows, ['./tmp/' trace_name '.' trace_opt '.' sync_opt '.' rank_opt '.' num2str(seed)]);


    %% --------------------
    %% Find the local minimum ranks as change points
    %% --------------------
    if DEBUG2, fprintf('XXX: find change points\n'); end

    change_points = [];
end


%% plot_ts_sync_rank
function plot_ts_sync_rank(X, sample_class, X_sync, sample_class_sync, ranks, windows, figname)
    clf;
    fh = figure;
    font_size = 16;
    
    colors   = {'b', [0 0.8 0], 'm', [1 0.85 0], [0 0 0.47], [0.45 0.17 0.48], 'k'};
    lines    = {'-', '--', '-.', ':'};
    markers  = {'+', 'o', '*', '.', 'x', 's', 'd', '^', '>', '<', 'p', 'h'};


    %% original time series
    subplot(3, 1, 1);
    for ri = 1:length(X)
        lh{ri} = plot(X{ri}(1,:));
        set(lh{ri}, 'Color', colors{mod(ri-1,length(colors))+1});
        set(lh{ri}, 'LineStyle', char(lines{mod(ri-1,length(lines))+1}));
        set(lh{ri}, 'LineWidth', 2);
        % set(lh{ri}, 'marker', markers{mod(ri-1,length(markers))+1});
        % set(lh{ri}, 'MarkerSize', 7);
        hold on;

        uniq_class = unique(sample_class{ri});
        idx = [];
        for ci = uniq_class
            tmp = find(sample_class{ri} == ci);
            idx = [idx tmp(1)];
        end
        tmp = ones(1, length(X{ri}(1,:))) * NaN;
        tmp(idx) = X{ri}(1,idx);
        lh_sample{ri} = plot(tmp);
        set(lh_sample{ri}, 'Color', colors{mod(ri-1,length(colors))+1});
        set(lh_sample{ri}, 'marker', 'o');
        set(lh_sample{ri}, 'MarkerSize', 10);
    end

    set(gca, 'FontSize', font_size);
    % xlabel('Time', 'FontSize', font_size);
    ylabel('feature1', 'FontSize', font_size);
    

    %% sync time series
    len = length(X_sync{1}(1,:));
    subplot(3, 1, 2);
    for ri = 1:length(X_sync)
        lh{ri} = plot(X_sync{ri}(1,:));
        set(lh{ri}, 'Color', colors{mod(ri-1,length(colors))+1});
        set(lh{ri}, 'LineStyle', char(lines{mod(ri-1,length(lines))+1}));
        set(lh{ri}, 'LineWidth', 1);
        % set(lh{ri}, 'marker', markers{mod(ri-1,length(markers))+1});
        % set(lh{ri}, 'MarkerSize', 7);
        hold on;

        uniq_class = unique(sample_class_sync{ri});
        idx = [];
        for ci = uniq_class
            tmp = find(sample_class_sync{ri} == ci);
            idx = [idx tmp(1)];
        end
        tmp = ones(1, len) * NaN;
        tmp(idx) = X_sync{ri}(1,idx);
        lh_sample{ri} = plot(tmp);
        set(lh_sample{ri}, 'Color', colors{mod(ri-1,length(colors))+1});
        set(lh_sample{ri}, 'marker', 'o');
        set(lh_sample{ri}, 'MarkerSize', 10);
    end

    set(gca, 'XLim', [0 len]);
    set(gca, 'FontSize', font_size);
    % xlabel('Time', 'FontSize', font_size);
    ylabel('feature1', 'FontSize', font_size);

    %% ranks
    r_sum = zeros(1, len);
    r_cnt = zeros(1, len);
    subplot(3, 1, 3);
    for ri = 1:length(windows)
        normalize_r = ranks{ri};
        normalize_r = normalize_r - min(normalize_r);
        normalize_r = normalize_r / max(normalize_r);
        lh{ri} = plot(normalize_r);
        set(lh{ri}, 'Color', colors{mod(ri-1,length(colors))+1});
        % set(lh{ri}, 'LineStyle', char(lines{mod(ri-1,length(lines))+1}));
        % set(lh{ri}, 'LineWidth', 2);
        set(lh{ri}, 'LineStyle', '-');
        set(lh{ri}, 'LineWidth', 1);
        hold on;

        %% get avg
        r_sum = r_sum + [normalize_r zeros(1, len-length(normalize_r))];
        r_cnt = r_cnt + [ones(1, length(normalize_r)) zeros(1, len-length(normalize_r))];
    end

    ri = ri + 1;
    idx = find(r_cnt > 0);
    r_avg = r_sum(idx) ./ r_cnt(idx);
    lh{ri} = plot(idx, r_avg, '-r');
    set(lh{ri}, 'LineWidth', 3);

    set(gca, 'XLim', [0 length(X_sync{1}(1,:))]);
    set(gca, 'FontSize', font_size);
    xlabel('Time', 'FontSize', font_size);
    ylabel('rank', 'FontSize', font_size);

    print(fh, '-depsc', [figname '.eps']);
end