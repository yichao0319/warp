%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Yi-Chao Chen @ UT Austin
%%
%% do_missing_exp
%%
%% - Input:
%%   1. trace_opt
%%      > 4sq: num_loc, num_rep, loc_type
%%      > p300: subject, session, img_idx, mat_type
%%      > deap: video
%%      > others: na
%%   2. drop_opt
%%      > frac: element fraction
%%      > lr: loss rate
%%      > elem_mode: elem, ..
%%      > loss_mode: ind, ..
%%      > burst: burst size
%%   3. sync_opt: 
%%      > num_seg
%%      > sync: na, shift, stretch, dtw
%%      > metric: dist, coeff, graph
%%      > sigma: used for fully connected graph metric
%%   4. cluster_opt:
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
%%   5. eval_opt:
%%      > dup: 
%%        how deal with duplicate missing elements
%%        - no: only evaluate missing elements without duplicate
%%        - avg: take average
%%        - best: pick the value from cluster with highest similarity
%%        - equal: treat all missing elements equally
%%   6. init_esti_method:
%%        the interpolation method before synchronzation
%%   7. final_esti_method:
%%        the final interpolation method
%%   8. seed
%%
%%
%% example:
%%   do_missing_exp('test_sine_shift', 'na', 'frac=1,lr=0.1,elem_mode=''elem'',loss_mode=''ind'',burst=1', 'num_seg=1,sync=''shift'',metric=''coeff'',sigma=1', 'method=''kmeans'',num=1,head=''best'',merge=''na'',thresh=0', 'dup=''best''', 'na', 'lens', 1);
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [maes] = do_missing_exp(trace_name, trace_opt, drop_opt, ...
                sync_opt, cluster_opt, eval_opt, ...
                init_esti_method, final_esti_method, ...
                seed)
    addpath('/u/yichao/warp/git_repository/task_miss/c_func');
    addpath('/u/yichao/lens/utils/compressive_sensing');
    
    %% --------------------
    %% DEBUG
    %% --------------------
    DEBUG0 = 0;
    DEBUG1 = 1;
    DEBUG2 = 1;  %% progress
    DEBUG3 = 1;  %% verbose
    DEBUG4 = 1;  %% results
    DEBUG5 = 0;  %% plot / output for debugging
    DEBUG6 = 1;  %% run locally (=1) or on condor (=0)


    %% --------------------
    %% Variables
    %% --------------------
    %% run locally
    if DEBUG6, output_dir = '../../processed_data/task_miss/do_missing_exp/';
    %% run on condor
    else, output_dir = '/u/yichao/warp/condor_data/task_miss/condor/do_missing_exp/'; end

    if DEBUG5, figbase = ['./tmp/' trace_name];
    else, figbase = ['/u/yichao/warp/condor_data/task_miss/condor/do_missing_exp.fig/' trace_name]; end


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
    %% drop values
    %% --------------------
    if DEBUG2, fprintf('drop values\n'); end

    [X_drop, M] = do_drop(my_cell2mat(X), drop_opt);

    if DEBUG3
        fprintf('  size of X: %dx%d\n', size(X_drop));
        fprintf('  size of M: %dx%d\n', size(M));
        fprintf('  # missing = %d (%f)\n', nnz(~M), nnz(~M) / prod(size(M)));
    end

    %% --------------------
    %% revM: label all missing elements with 1,2,3,...,#drop
    drop_idx = find(M == 0);
    revM = zeros(size(M));
    revM(drop_idx) = 1:length(drop_idx);


    %% --------------------
    %% initital estimation
    %% --------------------
    if DEBUG2, fprintf('initital estimation\n'); end

    est_opt = ['r=' num2str(r) ',alpha=' num2str(alpha) ',lambda=' num2str(lambda)];
    tmp = do_estimate(X_drop, M, init_esti_method, est_opt);
    X_est = num2cell(tmp, 2);
    M_est = num2cell(M, 2);
    revM_est = num2cell(revM, 2);
    
    
    %% --------------------
    %% clustering
    %% --------------------
    if DEBUG2, fprintf('clustering\n'); end

    other_mat = {};
    other_mat{1} = M_est;
    other_mat{2} = X;
    other_mat{3} = revM_est;
    other_cluster = {};

    this_cluster_opt = [cluster_opt ',' sync_opt];
    [X_cluster, other_cluster, cluster_affinity] = do_cluster(X_est, this_cluster_opt, figbase, other_mat);

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
    other_mat{1} = other_cluster{1};
    other_mat{2} = other_cluster{2};
    other_mat{3} = other_cluster{3};
    other_cluster = {};

    [X_sync, other_cluster] = do_sync(X_cluster, sync_opt, other_mat, figbase);


    %% --------------------
    %% interpolate missing values
    %% --------------------
    if DEBUG2, fprintf('final interpolation\n'); end
    
    %% --------------------
    %% estimation of original matrix (w/o sync)
    if DEBUG2, fprintf('  - unsync matrix\n'); end
    
    X_orig_est = do_estimate(my_cell2mat(X), M, final_esti_method, est_opt);
    % X_svd_base_est = do_estimate(my_cell2mat(X), M, 'svd_base', est_opt);
    % X_svd_base_knn_est = do_estimate(my_cell2mat(X), M, 'svd_base_knn', est_opt);
    % X_srmf_est = do_estimate(my_cell2mat(X), M, 'srmf', est_opt);
    % X_srmf_knn_est = do_estimate(my_cell2mat(X), M, 'srmf_knn', est_opt);
    % X_knn_est = do_estimate(my_cell2mat(X), M, 'knn', est_opt);

    maes(1) = 0;
    maes(2) = 0;
    est_collection = [];


    %% --------------------
    %% estimation of sync matrix:
    %%   do that in each cluster
    if DEBUG2, fprintf('  - sync matrix\n'); end

    for ci = 1:length(X_sync)
        this_X_sync = my_cell2mat(X_sync{ci});
        this_M_sync = my_cell2mat(other_cluster{1}{ci});
        this_X_orig = my_cell2mat(other_cluster{2}{ci});
        this_revM_sync = my_cell2mat(other_cluster{3}{ci});

        if DEBUG3
            fprintf('    cluster %d:\n', ci);
            fprintf('      NaN in X = %d, #missing in M = %d\n', nnz(isnan(this_X_sync)), length(find(this_M_sync == 0)));
            fprintf('        same location? %d\n', ~nnz((isnan(this_X_sync) - ~this_M_sync)) );
            fprintf('      NaN in X = %d, #missing in revM = %d\n', nnz(isnan(this_X_sync)), length(find(this_revM_sync > 0)));
            fprintf('        same location? %d\n', ~nnz((isnan(this_X_sync) - min(this_revM_sync,1)) ));
        end


        %% --------------------
        %% interpolate in this cluster
        X_est = do_estimate(this_X_sync, this_M_sync, final_esti_method, est_opt);


        %% --------------------
        %% collect the interpolated values
        est_collection = collect_estimation(this_X_orig, X_est, this_M_sync, this_revM_sync, ci, cluster_affinity(ci), est_collection);

    end %% END of interpolation for cluster


    %% --------------------
    %% get NMAE
    if DEBUG2, fprintf('calculate NMAE\n'); end

    [maes(1), select_miss_elem] = evaluate_est_collection(est_collection, eval_opt);
    revM_orig = ~ismember(revM, select_miss_elem);
    maes(2) = calculate_mae(my_cell2mat(X), X_orig_est, revM_orig);

    % maes(1) = maes(1) + calculate_mae(this_X_orig, X_est, this_M_sync);
    % maes(2) = maes(2) + calculate_mae(my_cell2mat(X), X_orig_est, revM_orig);
    % % maes(3) = calculate_mae(my_cell2mat(X), X_svd_base_est, revM_orig);
    % % maes(4) = calculate_mae(my_cell2mat(X), X_svd_base_knn_est, revM_orig);
    % % maes(5) = calculate_mae(my_cell2mat(X), X_srmf_est, revM_orig);
    % % maes(6) = calculate_mae(my_cell2mat(X), X_srmf_knn_est, revM_orig);
    % % maes(7) = calculate_mae(my_cell2mat(X), X_knn_est, revM_orig);

    if DEBUG4
        fprintf('MAE: sync=%f, unsync=%f (improve by %f)\n', maes(1), maes(2), (maes(2)-maes(1))/maes(2));
    end

    % trace_name, trace_opt, drop_opt, ...
    % sync_opt, cluster_opt, eval_opt, ...
    % init_esti_method, final_esti_method, ...
    % seed
    dlmwrite([output_dir trace_name '.' trace_opt '.' drop_opt '.' sync_opt '.' cluster_opt '.' eval_opt '.' init_esti_method '.' final_esti_method '.' num2str(seed) '.txt'], maes);
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
