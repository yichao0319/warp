%% do_warp(X_cluster, warp_method)
function X_warp = do_warp(X_cluster, warp_method, opt, M_cluster)
    DEBUG_TIME = 0;

    t1 = tic;
    if strcmp(warp_method, 'dtw')
        fprintf(['  do dtw: ' opt '\n']);
        X_warp = do_dtw(X_cluster, opt);

    elseif strcmp(warp_method, 'shift')
        fprintf('  do shift\n');
        X_warp = do_shift(X_cluster);

    elseif strcmp(warp_method, 'stretch')
        fprintf('  do stretch\n');
        X_warp = do_stretch(X_cluster);
    else
        error(['wrong warp method: ' warp_method]);
    end
    if DEBUG_TIME, fprintf('[TIME] do warp (%s): %f\n', warp_method, toc(t1)); end
end
