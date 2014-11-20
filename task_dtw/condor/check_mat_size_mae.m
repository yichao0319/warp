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
%%
%% e.g.
%%   [mae_all, mae_sub] = check_mat_size_mae('test_sine_shift', 'na', 1, 0.1, 'elem', 'ind', 1, 1/3, 1);
%%   [mae_all, mae_sub] = check_mat_size_mae('p300', 'subject=1,session=1,img_idx=0', 1, 0.1, 'elem', 'ind', 1, 1/3, 1);
function [mae_all, mae_sub] = check_mat_size_mae(trace_name, trace_opt, ...
                elem_frac, loss_rate, elem_mode, loss_mode, burst_size, ...
                submatrix_ratio, ...
                seed)
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
    rand('seed', seed);
    randn('seed', seed);

    output_dir = './tmp/';
    % output_dir = '/u/yichao/warp/condor_data/task_dtw/condor/check_mat_size_mae/';
    
    if DEBUG3, figbase = ['./tmp/' trace_name];
    else, figbase = ''; end


    %% --------------------
    %% load data
    %% --------------------
    if DEBUG2, fprintf('load data\n'); end

    [X, r, bin, alpha, lambda] = get_trace(trace_name, trace_opt);
    fprintf('X size: %dx%d\n', size(my_cell2mat(X)));
    X = my_cell2mat(X);


    %% --------------------
    %% drop values
    %% --------------------
    if DEBUG2, fprintf('drop values\n'); end

    [X_drop, M] = do_drop(X, elem_frac, loss_rate, elem_mode, loss_mode, burst_size);

    if DEBUG3
        fprintf('  size of X: %dx%d\n', size(X_drop));
        fprintf('  size of M: %dx%d\n', size(M));
        fprintf('  # missing = %d (%f)\n', nnz(~M), nnz(~M) / prod(size(M)));
    end


    %% --------------------
    %% Select submatrix
    %% --------------------
    if DEBUG2, fprintf('Select submatrix\n'); end

    submatrix_len = ceil(size(X_drop, 2) * submatrix_ratio);
    offset = randi(size(X_drop, 2) - submatrix_len);
    X_sub = X(:, offset:offset+submatrix_len-1);
    X_sub_drop = X_drop(:, offset:offset+submatrix_len-1);
    M_sub = M(:, offset:offset+submatrix_len-1);
    M2 = ones(size(M));
    M2(:, offset:offset+submatrix_len-1) = M_sub;

    if DEBUG3
        fprintf('  size of X_sub: %dx%d\n', size(X_sub));
        fprintf('  size of M_sub: %dx%d\n', size(M_sub));
        fprintf('  # missing in M_sub= %d (%f)\n', nnz(~M_sub), nnz(~M_sub) / prod(size(M_sub)));
        fprintf('  size of M2: %dx%d\n', size(M2));
        fprintf('  # missing in M2= %d\n', nnz(~M2));
    end


    %% --------------------
    %% estimation
    %% --------------------
    if DEBUG2, fprintf('initital estimation\n'); end

    est_opt = ['r=' num2str(r) ',alpha=' num2str(alpha) ',lambda=' num2str(lambda)];
    X_sub_est = do_estimate(X_sub_drop, M_sub, 'lens', est_opt);
    X_est     = do_estimate(X_drop, M, 'lens', est_opt);
    mae_all = 0;
    mae_sub = 0;


    %% --------------------
    %% evaluate
    %% --------------------
    if DEBUG2, fprintf('evaluate\n'); end

    mae_sub = calculate_mae(X_sub, X_sub_est, M_sub);
    mae_all = calculate_mae(X, X_est, M2);


    % trace_name, trace_opt, ...
    % elem_frac, loss_rate, elem_mode, loss_mode, burst_size, ...
    % submatrix_ratio, ...
    % seed
    dlmwrite([output_dir trace_name '.' trace_opt '.elem' num2str(elem_frac) '.lr' num2str(loss_rate) '.' elem_mode '.' loss_mode '.' num2str(burst_size) '.' num2str(submatrix_ratio) '.s' num2str(seed) '.txt'], [mae_all, mae_sub]);
end


%% calculate_mae: function description
function [mae] = calculate_mae(X, X_est, M)
    meanX = mean(abs(X(~M)));
    mae = mean(abs((X(~M) - X_est(~M)))) / meanX;
end

