%% do_missing_exp
%% - rank_opt:
%% - elem_frac: 1
%% - loss_rate: 0.1
%% - elem_mode: 'elem'
%% - loss_mode: 'ind'
%% - warp_opt: 
function [r] = do_missing_exp(trace_name, trace_opt, ...
                rank_opt, ...
                elem_frac, loss_rate, elem_mode, loss_mode, burst_size, ...
                init_esti_method, final_esti_method, ...
                num_cluster, cluster_method, ...
                warp_method, warp_opt, ...
                seed)
    addpath('./c_func');

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
    rand('seed', seed);
    randn('seed', seed);

    output_dir = '../../processed_data/task_dtw/do_missing_exp/';
    % output_dir = '/u/yichao/warp/condor_data/task_dtw/condor/do_missing_exp/';


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
    X_est = mat2cell(tmp, 2);
    M_est = mat2cell(M, 2);

    
    %% --------------------
    %% clustering
    %% --------------------
    if DEBUG2, fprintf('clustering\n'); end
    
    [X_cluster, M_cluster] = do_cluster(X_est, num_cluster, cluster_method, M);
    fprintf('  # cluster: %d\n', length(X_cluster));
    

    %% --------------------
    %% warping
    %% --------------------
    if DEBUG2, fprintf('warping\n'); end

    [X_warp, M_warp] = do_warp(X_cluster, warp_method, warp_opt, M_cluster);
    
    
    %% --------------------
    %% estimation
    %% --------------------
    tmp = do_estimate(cluster2mat(X_warp), cluster2mat(M_warp), final_esti_method);
    X_final = mat2cell(tmp, 2);
end
