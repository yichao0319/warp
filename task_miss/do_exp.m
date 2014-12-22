%% do_exp: 
%% - trace_opt
%%   > 4sq: num_loc, num_rep, loc_type
%%   > p300: subject, session, img_idx, mat_type
%% - rank_opt
%%   > percentile
%%   > num_seg
%%   > r_method
%%     > 1: fill in shorter clusters with 0s
%%     > 2: sum of the ranks of each cluster
%% - sync_opt
%%   > num_seg
%%
%% e.g.
%%   do_exp('test_sine_shift', 'na', 'percentile=0.8,num_seg=1,r_method=1', 1, 'kmeans', 'dtw', 'num_seg=1');
function [r] = do_exp(trace_name, trace_opt, ...
                rank_opt, ...
                cluster_method, cluster_opt, ...
                sync_method, sync_opt)
    addpath('./c_func');
    addpath('/u/yichao/lens/utils/compressive_sensing');

    %% --------------------
    %% DEBUG
    %% --------------------
    DEBUG0 = 0;
    DEBUG1 = 1;
    DEBUG2 = 1;
    DEBUG3 = 1;
    DEBUG4 = 1;  %% results


    %% --------------------
    %% Variables
    %% --------------------
    seed = 2;
    rand('seed', seed);
    randn('seed', seed);

    output_dir = '../../processed_data/task_miss/do_exp/';
    % output_dir = '/u/yichao/warp/condor_data/task_miss/condor/do_exp/';

    if DEBUG3, figbase = ['./tmp/' trace_name];
    else, figbase = ''; end


    
    %% --------------------
    %% load data
    %% --------------------
    if DEBUG2, fprintf('load data\n'); end

    [X, r, bin, alpha, lambda] = get_trace(trace_name, trace_opt);
    fprintf('X size: %dx%d\n', size(my_cell2mat(X)));
    tmp{1} = X;
    if DEBUG3, plot_ts(tmp, ['./tmp/' trace_name '.orig']); end


    %% --------------------
    %% drop values -- no missing value
    %% --------------------
    if DEBUG2, fprintf('drop values -- drop rate = 0\n'); end

    [X, M] = do_drop(my_cell2mat(X), 0, 0, 'elem', 'rand', 1);
    X = num2cell(X, 2);
    M = num2cell(M, 2);

    
    %% --------------------
    %% clustering
    %% --------------------
    if DEBUG2, fprintf('clustering\n'); end
    
    other_mat = {};
    other_mat{1} = M;
    other_mat{2} = X;
    other_cluster = {};

    [X_cluster, other_cluster] = do_cluster(X, cluster_method, cluster_opt, figbase, other_mat);
    fprintf('  # cluster: %d\n', length(X_cluster));
    

    %% --------------------
    %% sync
    %% --------------------
    if DEBUG2, fprintf('sync\n'); end

    other_mat = {};
    other_mat{1} = other_cluster{1};
    other_mat{2} = other_cluster{2};
    other_cluster = {};

    [X_sync, other_cluster] = do_sync(X_cluster, sync_method, sync_opt, other_mat, figbase);

    % r = get_seg_rank(cluster2mat(X_sync), rank_num_seg, rank_percentile);
    r = get_rank(X_sync, rank_opt);
    if DEBUG3, plot_ts(X_sync, ['./tmp/' trace_name '.' sync_method]); end


    dlmwrite([output_dir trace_name '.' trace_opt '.' cluster_method '.' cluster_opt '.' sync_method '.' rank_opt '.txt'], r);
    
end
