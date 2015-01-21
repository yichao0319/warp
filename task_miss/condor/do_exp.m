%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Yi-Chao Chen @ UT Austin
%%
%% do_exp: calculate the rank
%%
%% - Input:
%%   1. trace_opt
%%      > 4sq: num_loc, num_rep, loc_type
%%      > p300: subject, session, img_idx, mat_type
%%      > deap: video
%%      > others: na
%%   2. sync_opt: 
%%      > num_seg
%%      > sync: na, shift, stretch, dtw
%%      > metric: dist, coeff, graph
%%      > sigma: used for fully connected graph metric
%%   3. cluster_opt:
%%      > method: 'kmeans', 'spectral'
%%      > num: number of clusters
%%      > head: the way to choose cluster head
%%        - random
%%        - best
%%        - worst
%%      > merge: merge cluster if necessary
%%        - num: #members of a cluster < thresh
%%        - sim: similarity of a cluster < thresh 
%%        - top: top "thresh" clusters with highest similarity
%%        - na: don't merge
%%     > thresh
%%   4. rank_opt
%%      > percentile
%%      > num_seg
%%      > r_method
%%        - 1: fill in shorter clusters with 0s
%%        - 2: sum of the ranks of each cluster
%%   5. seed
%%
%%
%% example:
%%   do_exp('test_sine_shift', 'na', 'num_seg=1,sync=''shift'',metric=''coeff'',sigma=1', 'method=''kmeans'',num=1,head=''best'',merge=''na'',thresh=0', 'percentile=0.8,num_seg=1,r_method=1', 1);
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function do_exp(trace_name, trace_opt, ...
                sync_opt, cluster_opt, rank_opt, seed)
    addpath('/u/yichao/warp/git_repository/utils/matlab/columnlegend');
    addpath('/u/yichao/warp/git_repository/task_miss/c_func');
    addpath('/u/yichao/lens/utils/compressive_sensing');
    
    %% --------------------
    %% DEBUG
    %% --------------------
    DEBUG0 = 0;
    DEBUG1 = 0;
    DEBUG2 = 0;  %% progress
    DEBUG3 = 0;  %% verbose
    DEBUG4 = 0;  %% results
    DEBUG5 = 0;  %% plot / output for debugging
    DEBUG6 = 0;  %% run locally (=1) or on condor (=0)


    %% --------------------
    %% Variables
    %% --------------------
    %% run locally
    if DEBUG6, output_dir = '../../processed_data/task_miss/do_exp/';
    %% run on condor
    else, output_dir = '/u/yichao/warp/condor_data/task_miss/condor/do_exp/'; end

    if DEBUG5, figbase = ['./tmp/' trace_name];
    else, figbase = ''; end
    % else, figbase = ['/u/yichao/warp/condor_data/task_miss/condor/do_exp.fig/' trace_name]; end


    rand('seed', seed);
    randn('seed', seed);


    %% --------------------
    %% load data
    %% --------------------
    if DEBUG2, fprintf('load data\n'); end

    [X, r, bin, alpha, lambda] = get_trace(trace_name, trace_opt);
    % X = my_cell2mat(X);
    % X = X / mean(X(:));
    % X = num2cell(X, 2);
    X_orig = X;
    if DEBUG3, 
        fprintf('  X size: %dx%d\n', size(my_cell2mat(X)));
    end
    if DEBUG5, 
        tmp{1} = X;
        plot_ts(tmp, [figbase '.orig']); 
    end


    %% --------------------
    %% desync data
    %% --------------------
    if DEBUG2, fprintf('desync data\n'); end
    
    other_mat = {};
    desync_opt = 'desync=0.15';
    [X_desync, other_desync] = desync_data(X, other_mat, desync_opt);
    X = X_desync;

    if DEBUG3, 
        fprintf('  X size: %dx%d\n', size(my_cell2mat(X)));
    end
    

    %% --------------------
    %% clustering
    %% --------------------
    if DEBUG2, fprintf('clustering\n'); end

    other_mat = {};
    other_cluster = {};

    this_cluster_opt = [cluster_opt ',' sync_opt];
    [X_cluster, other_cluster, cluster_affinity] = do_cluster(X, this_cluster_opt, figbase, other_mat);

    if DEBUG3
        fprintf('  # cluster: %d\n', length(X_cluster));
        for ci = 1:length(X_cluster)
            fprintf('    cluster %d: #members=%d, affinity=%f\n', ci, length(X_cluster{ci}), cluster_affinity(ci));
        end
    end


    %% --------------------
    %% synchronization
    %% --------------------
    if DEBUG2, fprintf('synchronization\n'); end

    other_mat = {};
    other_cluster = {};

    [X_sync, other_cluster] = do_sync(X_cluster, sync_opt, other_mat, figbase);


    %% --------------------
    %% calculate rank
    %% --------------------
    if DEBUG2, fprintf('calculate rank\n'); end

    %% sync
    r_sync = get_rank(X_sync, rank_opt);

    X_sync_mat = cluster2mat(X_sync);
    [nrow, ncol] = size(X_sync_mat);
    if DEBUG3, fprintf('  length of sync X = %dx%d\n', nrow, ncol); end

    %% desync
    sub_X_mat = {};
    sub_X_mat{1} = X;
    r_entire = get_rank(sub_X_mat, rank_opt);

    X_mat = my_cell2mat(X);
    r_sub = [];
    for ci = 1:size(X_mat,2)-ncol+1
        sub_X_mat = {};
        sub_X_mat{1} = num2cell(X_mat(:, ci:ci+ncol-1), 2);
        r_sub(ci) = get_rank(sub_X_mat, rank_opt);
    end

    %% orig
    sub_X_mat = {};
    sub_X_mat{1} = X_orig;
    r_orig_entire = get_rank(sub_X_mat, rank_opt);

    X_mat = my_cell2mat(X_orig);
    r_orig_sub = [];
    for ci = 1:size(X_mat,2)-ncol+1
        sub_X_mat = {};
        sub_X_mat{1} = num2cell(X_mat(:, ci:ci+ncol-1), 2);
        r_orig_sub(ci) = get_rank(sub_X_mat, rank_opt);
    end

    
    if DEBUG4
        fprintf('  r-sync           = %f\n', r_sync);
        fprintf('  r-desync         = %f\n', r_entire);
        fprintf('  r-desync-sub avg = %f\n', mean(r_sub));
        fprintf('  r-desync-sub max = %f\n', max(r_sub));
        fprintf('  r-desync-sub min = %f\n', min(r_sub));
        fprintf('  r-orig           = %f\n', r_orig_entire);
        fprintf('  r-sub avg        = %f\n', mean(r_orig_sub));
        fprintf('  r-sub max        = %f\n', max(r_orig_sub));
        fprintf('  r-sub min        = %f\n', min(r_orig_sub));
        plot_rank(r_sync, r_entire, r_sub, r_orig_entire, r_orig_sub, [figbase '.rank']);
    end

    
    fid = fopen([output_dir trace_name '.' trace_opt '.' sync_opt '.' cluster_opt '.' rank_opt '.' num2str(seed) '.txt'], 'w');
    fprintf(fid, '%f\n', r_sync);
    fprintf(fid, '%f\n', r_entire);
    fprintf(fid, '%d\n', length(r_sub));
    fprintf(fid, '%f,', r_sub);
    fprintf(fid, '\n');
    fprintf(fid, '%f\n', r_orig_entire);
    fprintf(fid, '%d\n', length(r_orig_sub));
    fprintf(fid, '%f,', r_orig_sub);
    fprintf(fid, '\n');
    fclose(fid);
end


function plot_rank(r_sync, r_entire, r_sub, r_orig_entire, r_orig_sub, figname)
    font_size = 18;
    colors   = {'r', 'b', [0 0.8 0], 'm', [1 0.85 0], [0 0 0.47], [0.45 0.17 0.48], 'k'};
    lines    = {'-'};
    markers  = {'+', 'o', '*', '.', 'x', 's', 'd', '^', '>', '<', 'p', 'h'};

    r_sync = ones(1, max(length(r_sub), length(r_orig_sub))) * r_sync;
    r_entire = ones(1, max(length(r_sub), length(r_orig_sub))) * r_entire;
    r_orig_entire = ones(1, max(length(r_sub), length(r_orig_sub))) * r_orig_entire;

    fh = figure(); clf;
    legend_str = [];

    lc = 1;
    lh{lc} = plot(r_sync);
    set(lh{lc}, 'Color', colors{mod(lc-1,length(colors))+1});
    set(lh{lc}, 'LineStyle', lines{mod(lc-1,length(lines))+1});
    set(lh{lc}, 'LineWidth', 1);
    legends{lc} = ['sync'];
    legend_str = [legend_str; {'sync'}];
    hold on;

    lc = lc + 1;
    lh{lc} = plot(r_entire);
    set(lh{lc}, 'Color', colors{mod(lc-1,length(colors))+1});
    set(lh{lc}, 'LineStyle', lines{mod(lc-1,length(lines))+1});
    set(lh{lc}, 'LineWidth', 1);
    legends{lc} = ['desync entire'];
    legend_str = [legend_str; {'desync entire'}];
    hold on;

    lc = lc + 1;
    lh{lc} = plot(r_sub);
    set(lh{lc}, 'Color', colors{mod(lc-1,length(colors))+1});
    set(lh{lc}, 'LineStyle', lines{mod(lc-1,length(lines))+1});
    set(lh{lc}, 'LineWidth', 1);
    legends{lc} = ['desync sub-mat'];
    legend_str = [legend_str; {'desync sub-mat'}];
    hold on;

    lc = lc + 1;
    lh{lc} = plot(r_orig_entire);
    set(lh{lc}, 'Color', colors{mod(lc-1,length(colors))+1});
    set(lh{lc}, 'LineStyle', lines{mod(lc-1,length(lines))+1});
    set(lh{lc}, 'LineWidth', 1);
    legends{lc} = ['orig entire'];
    legend_str = [legend_str; {'orig entire'}];
    hold on;

    lc = lc + 1;
    lh{lc} = plot(r_orig_sub);
    set(lh{lc}, 'Color', colors{mod(lc-1,length(colors))+1});
    set(lh{lc}, 'LineStyle', lines{mod(lc-1,length(lines))+1});
    set(lh{lc}, 'LineWidth', 1);
    legends{lc} = ['orig sub-mat'];
    legend_str = [legend_str; {'orig sub-mat'}];
    hold on;

    set(gca, 'FontSize', font_size);
    xlabel('Time', 'FontSize', font_size);
    ylabel('rank', 'FontSize', font_size);

    columnlegend(3, legends, 'Location', 'NorthOutside', 'Orientation', 'Horizontal');
    pos = [0.1 0.1 0.8 0.7];
    set(gca, 'Position', pos);

    print(fh, '-depsc', [figname '.eps']);
end
