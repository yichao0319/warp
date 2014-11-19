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
%%   [mae, mae_orig] = do_missing_exp('test_sine_shift', 'na', 'percentile=0.8,num_seg=1,r_method=1', 1, 0.1, 'elem', 'ind', 1, 'na', 'lens', 1, 'kmeans', 'shift', 'num_seg=1', 1);
%%   [mae, mae_orig] = do_missing_exp('p300', 'subject=1,session=1,img_idx=0', 'percentile=0.8,num_seg=1,r_method=1', 1, 0.1, 'elem', 'ind', 1, 'na', 'lens', 1, 'kmeans', 'shift', 'num_seg=1', 1);
function [mae, mae_orig] = do_missing_exp(trace_name, trace_opt, ...
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

    if DEBUG3, figbase = ['./tmp/' trace_name];
    else, figbase = ''; end


    %% --------------------------
    %% Input parameters
    % if num_cluster < 0
    %     num_cluster = Inf;
    % end
    %% END Input parameters
    %% --------------------------


    %% --------------------
    %% load data
    %% --------------------
    if DEBUG2, fprintf('load data\n'); end

    [X, r, bin, alpha, lambda] = get_trace(trace_name, trace_opt);
    fprintf('X size: %dx%d\n', size(my_cell2mat(X)));
    tmp{1} = X;
    if DEBUG3, plot_ts(tmp, ['./tmp/' trace_name '.orig']); end


    %% --------------------
    %% drop values
    %% --------------------
    if DEBUG2, fprintf('drop values\n'); end

    [X_drop, M] = do_drop(my_cell2mat(X), elem_frac, loss_rate, elem_mode, loss_mode, burst_size);

    if DEBUG3
        fprintf('  size of X: %dx%d\n', size(X_drop));
        fprintf('  size of M: %dx%d\n', size(M));
        fprintf('  # missing = %d (%f)\n', nnz(~M), nnz(~M) / prod(size(M)));
    end


    %% --------------------
    %% label all missing elements with 1,2,3,...,#drop
    %% --------------------
    drop_idx = find(M == 0);
    invM = zeros(size(M));
    invM(drop_idx) = 1:length(drop_idx);


    %% --------------------
    %% initital estimation
    %% --------------------
    if DEBUG2, fprintf('initital estimation\n'); end

    est_opt = ['r=' num2str(r) ',alpha=' num2str(alpha) ',lambda=' num2str(lambda)];
    tmp = do_estimate(X_drop, M, init_esti_method, est_opt);
    X_est = num2cell(tmp, 2);
    M_est = num2cell(M, 2);
    invM_est = num2cell(invM, 2);

    
    %% --------------------
    %% clustering
    %% --------------------
    if DEBUG2, fprintf('clustering\n'); end
    
    other_mat = {};
    other_mat{1} = M_est;
    other_mat{2} = X;
    other_mat{3} = invM_est;
    other_cluster = {};

    [X_cluster, other_cluster] = do_cluster(X_est, num_cluster, cluster_method, figbase, other_mat);
    fprintf('  # cluster: %d\n', length(X_cluster));


    %% --------------------
    %% warping
    %% --------------------
    if DEBUG2, fprintf('warping\n'); end

    other_mat = {};
    other_mat{1} = other_cluster{1};
    other_mat{2} = other_cluster{2};
    other_mat{3} = other_cluster{3};
    other_cluster = {};

    [X_warp, other_cluster] = do_warp(X_cluster, warp_method, warp_opt, other_mat, figbase);
    M_warp = cluster2mat(other_cluster{1});
    X_orig = cluster2mat(other_cluster{2});
    invM_warp = cluster2mat(other_cluster{3});
    
    if DEBUG3
        fprintf('  NaN in X = %d, # missing in M = %d\n', nnz(isnan(cluster2mat(X_warp))), length(find(M_warp == 0)));
        fprintf('    same location? %d\n', ~nnz((isnan(cluster2mat(X_warp)) - ~M_warp)) );
        fprintf('  NaN in X = %d, # missing in invM = %d\n', nnz(isnan(cluster2mat(X_warp))), length(find(invM_warp > 0)));
        fprintf('    same location? %d\n', ~nnz((isnan(cluster2mat(X_warp)) - min(invM_warp,1)) ));
    end

    
    %% --------------------
    %% estimation
    %% --------------------
    if DEBUG2, fprintf('final estimation\n'); end

    X_est = do_estimate(cluster2mat(X_warp), M_warp, final_esti_method, est_opt);

    %% estimate without warping
    invM_ind = invM_warp(find(invM_warp > 0));
    invM_orig = ~ismember(invM, invM_ind);
    % X_orig_est = do_estimate(my_cell2mat(X), invM_orig, final_esti_method, est_opt);
    X_orig_est = do_estimate(my_cell2mat(X), M, final_esti_method, est_opt);


    if DEBUG3
        fprintf('  size of X: %dx%d\n', size(X_est));
        fprintf('  size of M: %dx%d\n', size(M_warp));
        fprintf('  size of invM: %dx%d\n', size(invM_warp));
        fprintf('  size of invM_orig: %dx%d\n', size(invM_orig));
        fprintf('  # missing = %d (%f)\n', nnz(~M_warp), nnz(~M_warp) / prod(size(M_warp)));
        fprintf('  # missing (invM) = %d\n', length(find(invM_warp > 0)));
        fprintf('  # missing (invM_orig) = %d\n', nnz(~invM_orig));

        tmp  = {}; tmp{1}  = num2cell(cluster2mat(X_warp), 2);
        tmp2 = {}; tmp2{1} = num2cell(X_orig, 2);
        tmp3 = {}; tmp3{1} = num2cell(M_warp, 2);
        plot_missing_ts(tmp, tmp2, tmp3, ['./tmp/' trace_name '.missing']);
        tmp  = {}; tmp{1}  = num2cell(X_est, 2);
        tmp2 = {}; tmp2{1} = num2cell(X_orig, 2);
        tmp3 = {}; tmp3{1} = num2cell(M_warp, 2);
        plot_missing_ts(tmp, tmp2, tmp3, ['./tmp/' trace_name '.est']);
        tmp  = {}; tmp{1}  = num2cell(X_orig_est, 2);
        tmp2 = {}; tmp2{1} = X;
        tmp3 = {}; tmp3{1} = num2cell(invM_orig, 2);
        plot_missing_ts(tmp, tmp2, tmp3, ['./tmp/' trace_name '.est_orig']);
    end


    %% --------------------
    %% evaluate
    %% --------------------
    if DEBUG2, fprintf('evaluate\n'); end

    %% --------------
    %% for shift:
    %%    only evaluate the overlay part.
    %%    If shift - 
    %% --------------
    mae = calculate_mae(X_orig, X_est, M_warp);
    mae_orig = calculate_mae(my_cell2mat(X), X_orig_est, invM_orig);


    %% --------------------
    %% calculate rank
    %% --------------------
    if DEBUG2, fprintf('calculate rank\n'); end





    % trace_name, trace_opt, ...
    % rank_opt, ...
    % elem_frac, loss_rate, elem_mode, loss_mode, burst_size, ...
    % init_esti_method, final_esti_method, ...
    % num_cluster, cluster_method, ...
    % warp_method, warp_opt, ...
    % seed
    dlmwrite([output_dir trace_name '.' trace_opt '.' cluster_method '.c' num2str(num_cluster) '.' warp_method '.' warp_opt '.' rank_opt '.elem' num2str(elem_frac) '.lr' num2str(loss_rate) '.' elem_mode '.' loss_mode '.' num2str(burst_size) '.' init_esti_method '.' final_esti_method '.s' num2str(seed) '.txt'], [mae, mae_orig]);
end


%% calculate_mae: function description
function [mae] = calculate_mae(X, X_est, M)
    meanX = mean(abs(X(~M)));
    mae = mean(abs((X(~M) - X_est(~M)))) / meanX;
end


function plot_missing_ts(ts, orig_ts, M, figname, range)
    if nargin < 5, range = Inf; end

    fh = figure(11); clf;

    font_size = 18;
    colors   = {'r', 'b', [0 0.8 0], 'm', [1 0.85 0], [0 0 0.47], [0.45 0.17 0.48], 'k'};
    lines    = {'-', '--'};
    markers  = {'+', 'o', '*', '.', 'x', 's', 'd', '^', '>', '<', 'p', 'h'};

    lc = 0;
    max_grp = 2;
    max_line = Inf;
    for tsi = 1:length(ts)
        if tsi > max_grp, break; end

        for li = 1:length(ts{tsi})
            if li > max_line, break; end

            lc = lc + 1;
            this_ts = ts{tsi}{li}(1:min(range,end));
            lh{lc} = plot(this_ts);
            set(lh{lc}, 'Color', colors{mod(lc-1,length(colors))+1});
            set(lh{lc}, 'LineStyle', lines{mod(lc-1,length(lines))+1});
            set(lh{lc}, 'LineWidth', 1);
            legends{lc} = ['grp' int2str(tsi) ' ln' int2str(li)];
            hold on;

            this_ts = ts{tsi}{li}(1:min(range,end));
            this_m  = M{tsi}{li}(1:min(range,end));
            miss_ts_x = find(this_m == 0);
            miss_ts_y = this_ts(miss_ts_x);
            lh_miss = plot(miss_ts_x, miss_ts_y, 'o');
            set(lh_miss, 'Color', colors{mod(lc-1,length(colors))+1});
            hold on;

            this_ts = orig_ts{tsi}{li}(1:min(range,end));
            this_m  = M{tsi}{li}(1:min(range,end));
            miss_ts_x = find(this_m == 0);
            miss_ts_y = this_ts(miss_ts_x);
            lh_miss = plot(miss_ts_x, miss_ts_y, '+');
            set(lh_miss, 'Color', colors{mod(lc-1,length(colors))+1});
            hold on;       
        end
    end

    set(gca, 'FontSize', font_size);
    xlabel('Time', 'FontSize', font_size);
    ylabel('Mean-centered mag', 'FontSize', font_size);
    xlim([1 length(this_ts)]);
    % legend(legends);

    print(fh, '-depsc', [figname '.eps']);
end
