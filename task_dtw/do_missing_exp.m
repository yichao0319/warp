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
%% - cluster_opt:
%%   > num_cluster
%%   > head_type
%%     > random
%%     > coef
%%     > dist
%%     > worst
%%   > sync_type
%%     > na
%%     > shift
%%     > stretch
%%     > dtw
%%   > metric_type
%%     > dist: 2-norm
%%     > coef
%%     > dtw_dist: DTW distance
%%     > graph
%%   > sigma
%% - sync_opt: 
%%   > num_seg
%% - eval_opt:
%%   > no_dup
%%     > 0: evaluate all
%%     > 1: only evaluate non-duplicate part
%%
%% e.g.
%%   [maes] = do_missing_exp('test_sine_shift', 'na', 'percentile=0.8,num_seg=1,r_method=1', 1, 0.1, 'elem', 'ind', 1, 'na', 'lens', 'kmeans', 'num_cluster=1,head_type=''random'',sync_type=''na'',metric_type=''coef''', 'shift', 'num_seg=1', 'no_dup=0', 1);
function [maes] = do_missing_exp(trace_name, trace_opt, ...
                rank_opt, ...
                elem_frac, loss_rate, elem_mode, loss_mode, burst_size, ...
                init_esti_method, final_esti_method, ...
                cluster_method, cluster_opt, ...
                sync_method, sync_opt, ...
                eval_opt, ...
                seed)
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
    rand('seed', seed);
    randn('seed', seed);

    output_dir = '../../processed_data/task_dtw/do_missing_exp/';
    % output_dir = '/u/yichao/warp/condor_data/task_dtw/condor/do_missing_exp/';

    if DEBUG3, figbase = ['./tmp/' trace_name];
    else, figbase = ['/u/yichao/warp/condor_data/task_dtw/condor/do_missing_exp.fig/' trace_name]; end


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
    %% - revM: label all missing elements with 1,2,3,...,#drop
    %% - revX: label all elements with original index
    %% --------------------
    drop_idx = find(M == 0);
    revM = zeros(size(M));
    revM(drop_idx) = 1:length(drop_idx);

    tmp = size(X_drop);
    revX = reshape(1:prod(size(X_drop)), tmp(2), tmp(1))';
    

    %% --------------------
    %% initital estimation
    %% --------------------
    if DEBUG2, fprintf('initital estimation\n'); end

    est_opt = ['r=' num2str(r) ',alpha=' num2str(alpha) ',lambda=' num2str(lambda)];
    tmp = do_estimate(X_drop, M, init_esti_method, est_opt);
    X_est = num2cell(tmp, 2);
    M_est = num2cell(M, 2);
    revM_est = num2cell(revM, 2);
    revX_est = num2cell(revX, 2);

    
    %% --------------------
    %% clustering
    %% --------------------
    if DEBUG2, fprintf('clustering\n'); end

    other_mat = {};
    other_mat{1} = M_est;
    other_mat{2} = X;
    other_mat{3} = revM_est;
    other_mat{4} = revX_est;
    other_cluster = {};

    [X_cluster, other_cluster] = do_cluster(X_est, cluster_method, cluster_opt, figbase, other_mat);
    fprintf('  # cluster: %d\n', length(X_cluster));


    %% --------------------
    %% synchronization
    %% --------------------
    if DEBUG2, fprintf('synchronization\n'); end

    other_mat = {};
    other_mat{1} = other_cluster{1};
    other_mat{2} = other_cluster{2};
    other_mat{3} = other_cluster{3};
    other_mat{4} = other_cluster{4};
    other_cluster = {};

    [X_sync, other_cluster] = do_sync(X_cluster, sync_method, sync_opt, other_mat, figbase);


    %% --------------------
    %% estimation of original matrix
    %% --------------------
    X_orig_est = do_estimate(my_cell2mat(X), M, final_esti_method, est_opt);
    % X_svd_base_est = do_estimate(my_cell2mat(X), M, 'svd_base', est_opt);
    % X_svd_base_knn_est = do_estimate(my_cell2mat(X), M, 'svd_base_knn', est_opt);
    % X_srmf_est = do_estimate(my_cell2mat(X), M, 'srmf', est_opt);
    % X_srmf_knn_est = do_estimate(my_cell2mat(X), M, 'srmf_knn', est_opt);
    % X_knn_est = do_estimate(my_cell2mat(X), M, 'knn', est_opt);

    maes(1) = 0;
    maes(2) = 0;

    for ci = 1:length(X_sync)
        this_X_sync = my_cell2mat(X_sync{ci});
        this_M_sync = my_cell2mat(other_cluster{1}{ci});
        this_X_orig = my_cell2mat(other_cluster{2}{ci});
        this_revM_sync = my_cell2mat(other_cluster{3}{ci});
        this_revX_sync = my_cell2mat(other_cluster{4}{ci});

        % X_sync = cluster2mat(X_sync);
        % M_sync = cluster2mat(other_cluster{1});
        % X_orig = cluster2mat(other_cluster{2});
        % revM_sync = cluster2mat(other_cluster{3});
        % revX_sync = cluster2mat(other_cluster{4});

        if DEBUG3
            fprintf('  NaN in X = %d, # missing in M = %d\n', nnz(isnan(this_X_sync)), length(find(this_M_sync == 0)));
            fprintf('    same location? %d\n', ~nnz((isnan(this_X_sync) - ~this_M_sync)) );
            fprintf('  NaN in X = %d, # missing in revM = %d\n', nnz(isnan(this_X_sync)), length(find(this_revM_sync > 0)));
            fprintf('    same location? %d\n', ~nnz((isnan(this_X_sync) - min(this_revM_sync,1)) ));
        end


        %% --------------------
        %% estimation
        %% --------------------
        if DEBUG2, fprintf('final estimation\n'); end

        X_est = do_estimate(this_X_sync, this_M_sync, final_esti_method, est_opt);


        %% --------------------
        %% evaluate
        %% --------------------
        if DEBUG2, fprintf('evaluate\n'); end

        no_dup = get_eval_opt(eval_opt);
        if no_dup == 1
            %% --------------------
            %% only evaluate missing elements without being duplicate
            revM_cnt = histc(this_revM_sync(:), 1:max(this_revM_sync(:)));
            no_dup_M_idx = find(revM_cnt == 1);
            this_M_sync = ~ismember(this_revM_sync, no_dup_M_idx);

            revM_orig = ~ismember(revM, no_dup_M_idx);

        elseif no_dup == 2
            %% --------------------
            %% XXX: evaluate duplicate missing elements with avg
            
        else
            %% estimate without sync
            revM_ind = this_revM_sync(find(this_revM_sync > 0));
            revM_orig = ~ismember(revM, revM_ind);

        end

        maes(1) = maes(1) + calculate_mae(this_X_orig, X_est, this_M_sync);
        maes(2) = maes(2) + calculate_mae(my_cell2mat(X), X_orig_est, revM_orig);
        % maes(3) = calculate_mae(my_cell2mat(X), X_svd_base_est, revM_orig);
        % maes(4) = calculate_mae(my_cell2mat(X), X_svd_base_knn_est, revM_orig);
        % maes(5) = calculate_mae(my_cell2mat(X), X_srmf_est, revM_orig);
        % maes(6) = calculate_mae(my_cell2mat(X), X_srmf_knn_est, revM_orig);
        % maes(7) = calculate_mae(my_cell2mat(X), X_knn_est, revM_orig);


        if DEBUG3
            fprintf('  size of X: %dx%d\n', size(X_est));
            fprintf('  size of M: %dx%d\n', size(this_M_sync));
            fprintf('  size of revM: %dx%d\n', size(this_revM_sync));
            fprintf('  size of revM_orig: %dx%d\n', size(revM_orig));
            fprintf('  # missing = %d (%f)\n', nnz(~this_M_sync), nnz(~this_M_sync) / prod(size(this_M_sync)));
            tmp = length(unique(this_revM_sync(find(this_revM_sync > 0))));
            fprintf('  # missing (revM) = %d, # unique = %d\n', length(find(this_revM_sync > 0)), tmp);
            fprintf('  # missing (revM_orig) = %d\n', nnz(~revM_orig));

            tmp  = {}; tmp{1}  = num2cell(this_X_sync, 2);
            tmp2 = {}; tmp2{1} = num2cell(this_X_orig, 2);
            tmp3 = {}; tmp3{1} = num2cell(this_M_sync, 2);
            plot_missing_ts(tmp, tmp2, tmp3, ['./tmp/' trace_name '.missing']);
            tmp  = {}; tmp{1}  = num2cell(X_est, 2);
            tmp2 = {}; tmp2{1} = num2cell(this_X_orig, 2);
            tmp3 = {}; tmp3{1} = num2cell(this_M_sync, 2);
            plot_missing_ts(tmp, tmp2, tmp3, ['./tmp/' trace_name '.est']);
            tmp  = {}; tmp{1}  = num2cell(X_orig_est, 2);
            tmp2 = {}; tmp2{1} = X;
            tmp3 = {}; tmp3{1} = num2cell(revM_orig, 2);
            plot_missing_ts(tmp, tmp2, tmp3, ['./tmp/' trace_name '.est_orig']);
        end
    end %% END for estimate/evaluate each cluster

    maes(1) = maes(1) / length(X_sync);
    maes(2) = maes(2) / length(X_sync);


    % TRACE_NAME.TRACE_OPT.RANK_OPT.elemELEM_FRAC.lrLOSS_RATE.ELEM_MODE.LOSS_MODE.BURST_SIZE.INIT_ESTI_METHOD.FINAL_ESTI_METHOD.CLUST_METHOD.cNUM_CLUST.SYNC_METHOD.SYNC_OPT.EVAL_OPT.sSEED
    dlmwrite([output_dir trace_name '.' trace_opt '.' rank_opt '.elem' num2str(elem_frac) '.lr' num2str(loss_rate) '.' elem_mode '.' loss_mode '.' num2str(burst_size) '.' init_esti_method '.' final_esti_method '.' cluster_method '.' cluster_opt '.' sync_method '.' sync_opt '.' eval_opt '.s' num2str(seed) '.txt'], maes);
end


%% get_eval_opt: function description
function [no_dup] = get_eval_opt(opt)
    no_dup = 0;
    if nargin < 1, return; end

    opts = regexp(opt, ',', 'split');
    for this_opt = opts
        eval([char(this_opt) ';']);
    end
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
