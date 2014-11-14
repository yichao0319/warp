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
%% - warp_opt
%%   > num_seg
function [r] = do_exp(trace_name, trace_opt, ...
                rank_opt, ...
                num_cluster, cluster_method, ...
                warp_method, warp_opt)
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

    output_dir = '../../processed_data/task_dtw/do_exp/';
    % output_dir = '/u/yichao/warp/condor_data/task_dtw/condor/do_exp/';


    %% --------------------------
    %% Input parameters
    if num_cluster < 0
        num_cluster = Inf;
    end
    %% END Input parameters
    %% --------------------------


    %% --------------------
    %% load data
    %% --------------------
    if DEBUG2, fprintf('load data\n'); end

    [X, r, bin] = get_trace(trace_name, trace_opt);
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
    
    [X_cluster, M_cluster] = do_cluster(X, num_cluster, cluster_method, M);
    fprintf('  # cluster: %d\n', length(X_cluster));
    

    %% --------------------
    %% warping
    %% --------------------
    if DEBUG2, fprintf('warping\n'); end

    [X_warp, M_cluster] = do_warp(X_cluster, warp_method, warp_opt, M_cluster);
    

    % r = get_seg_rank(cluster2mat(X_warp), rank_num_seg, rank_percentile);
    r = get_rank(X_warp, rank_opt);
    if DEBUG3, plot_ts(X_warp, ['./tmp/' trace_name '.' warp_method]); end


    dlmwrite([output_dir trace_name '.' trace_opt '.' cluster_method '.c' num2str(num_cluster) '.' warp_method '.' rank_opt '.txt'], r);
    
end