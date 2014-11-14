%% do_missing_exp
%% - trace_opt
%%   > 4sq: num_loc, num_rep, loc_type
%%   > p300: subject, session, img_idx, mat_type
%% - rank_opt
%%   > percentile
%%   > num_seg
%%   > r_method
%%     > 1: fill in shorter clusters with 0s
%%     > 2: sum of the ranks of each cluster
%% - elem_frac: 1
%% - loss_rate: 0.1
%% - elem_mode: 'elem'
%% - loss_mode: 'ind'
%% - warp_opt: 
%% - warp_opt
%%   > num_seg
function [mae] = do_missing_exp(trace_name, trace_opt, ...
                rank_opt, ...
                elem_frac, loss_rate, elem_mode, loss_mode, burst_size, ...
                init_esti_method, final_esti_method, ...
                num_cluster, cluster_method, ...
                warp_method, warp_opt, ...
                seed)
    addpath('./c_func');
    addpath('/u/yichao/lens/utils/compressive_sensing');
    
    %% --------------------
    %% DEBUG
    %% --------------------
    DEBUG0 = 0;
    DEBUG1 = 0;
    DEBUG2 = 0;
    DEBUG3 = 0;
    DEBUG4 = 0;  %% results


    %% --------------------
    %% Variables
    %% --------------------
    rand('seed', seed);
    randn('seed', seed);

    % output_dir = '../../processed_data/task_dtw/do_missing_exp/';
    output_dir = '/u/yichao/warp/condor_data/task_dtw/condor/do_missing_exp/';


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
    %% drop values
    %% --------------------
    if DEBUG2, fprintf('drop values\n'); end

    [X_drop, M] = do_drop(my_cell2mat(X), elem_frac, loss_rate, elem_mode, loss_mode, burst_size);


    %% --------------------
    %% initital estimation
    %% --------------------
    if DEBUG2, fprintf('initital estimation\n'); end

    est_opt = ['r=' num2str(r)];
    tmp = do_estimate(X_drop, M, init_esti_method, est_opt);
    X_est = num2cell(tmp, 2);
    M_est = num2cell(M, 2);

    
    %% --------------------
    %% clustering
    %% --------------------
    if DEBUG2, fprintf('clustering\n'); end
    
    other_mat = {};
    other_mat{1} = M_est;
    other_mat{2} = X;
    other_cluster = {};

    [X_cluster, other_cluster] = do_cluster(X_est, num_cluster, cluster_method, other_mat);
    fprintf('  # cluster: %d\n', length(X_cluster));


    %% --------------------
    %% warping
    %% --------------------
    if DEBUG2, fprintf('warping\n'); end

    other_mat = {};
    other_mat{1} = other_cluster{1};
    other_mat{2} = other_cluster{2};
    other_cluster = {};

    [X_warp, other_cluster] = do_warp(X_cluster, warp_method, warp_opt, other_mat);

    
    %% --------------------
    %% estimation
    %% --------------------
    if DEBUG2, fprintf('final estimation\n'); end

    M_warp = cluster2mat(other_cluster{1});
    X_final = do_estimate(cluster2mat(X_warp), M_warp, final_esti_method, est_opt);


    %% --------------------
    %% evaluate
    %% --------------------
    if DEBUG2, fprintf('evaluate\n'); end

    X_orig  = cluster2mat(other_cluster{2});

    meanX = mean(X_orig(~M_warp));
    mae = mean(abs((X_orig(~M_warp) - X_final(~M_warp)))) / meanX;

    % trace_name, trace_opt, ...
    % rank_opt, ...
    % elem_frac, loss_rate, elem_mode, loss_mode, burst_size, ...
    % init_esti_method, final_esti_method, ...
    % num_cluster, cluster_method, ...
    % warp_method, warp_opt, ...
    % seed
    dlmwrite([output_dir trace_name '.' trace_opt '.' cluster_method '.c' num2str(num_cluster) '.' warp_method '.' warp_opt '.' rank_opt '.elem' num2str(elem_frac) '.lr' num2str(loss_rate) '.' elem_mode '.' loss_mode '.' num2str(burst_size) '.' init_esti_method '.' final_esti_method '.s' num2str(seed) '.txt'], mae);
end
