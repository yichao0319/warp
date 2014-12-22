%% test_dtw: function description
function test_dtw()
    addpath('./c_func');

    [X, r, bin] = get_trace_mat('test_sine_scale');
    % [X, r, bin] = get_trace_mat('test_sine_shift');
    % [X, r, bin] = get_trace_mat('4sq', 10);
    % [X, r, bin] = get_trace_mat('abilene');
    fprintf('X size: %dx%d\n', size(my_cell2mat(X)));
    tmp{1} = X;
    plot_ts(tmp, ['./tmp/tmp.orig']);

    % xmat = my_cell2mat(X);
    % xmat
    % sum(xmat, 2)'
    % return
    
    ex = 0;

    %% ==============================

    ex = ex + 1;

    num_seg = 1;
    percentile = 0.85;

    %% cluster
    X_cluster = do_cluster(X, 1, 'kmeans');
    fprintf('  # cluster: %d\n', length(X_cluster));
    % plot_ts(X_cluster, ['./tmp/tmp.cluster']);

    %% DTW
    X_sync = do_sync(X_cluster, 'dtw', 'dtw_c', 1);
    % [cdf_x_dtw, cdf_y_dtw, r_dtw] = get_rank_energy_cdf(cluster2mat(X_sync), percentile);
    r_dtw = get_seg_rank(cluster2mat(X_sync), num_seg, percentile);
    plot_ts(X_sync, ['./tmp/tmp.dtw' int2str(ex)]);
    fprintf('DTW rank = %f\n', mean(r_dtw));
    
    %% stretch
    X_sync = do_sync(X_cluster, 'stretch');
    [cdf_x_stretch, cdf_y_stretch, r_stretch] = get_rank_energy_cdf(cluster2mat(X_sync), percentile);
    r_stretch = get_seg_rank(cluster2mat(X_sync), num_seg, percentile);
    plot_ts(X_sync, ['./tmp/tmp.stretch' int2str(ex)]);
    fprintf('stretch rank = %f\n', mean(r_stretch));
    return

    %% shift
    X_sync = do_sync(X_cluster, 'shift');
    % [cdf_x_shift, cdf_y_shift, r_shift] = get_rank_energy_cdf(cluster2mat(X_sync), percentile);
    r_shift = get_seg_rank(cluster2mat(X_sync), num_seg, percentile);
    plot_ts(X_sync, ['./tmp/tmp.shift' int2str(ex)]);

    %% original
    X_cluster = do_cluster(X, Inf, 'kmeans');
    fprintf('  # cluster: %d\n', length(X_cluster));
    X_sync = do_sync(X_cluster, 'dtw', 'dtw_c', 1);
    % [cdf_x_orig, cdf_y_orig, r_orig] = get_rank_energy_cdf(cluster2mat(X_sync), percentile);
    r_orig = get_seg_rank(cluster2mat(X_sync), num_seg, percentile);

    
    % r_orig
    fprintf('original rank = %f\n', mean(r_orig));
    % r_dtw
    fprintf('DTW rank = %f\n', mean(r_dtw));
    % r_stretch
    fprintf('stretch rank = %f\n', mean(r_stretch));
    % r_shift
    fprintf('shift rank = %f\n', mean(r_shift));
    
    %% ==============================

end


