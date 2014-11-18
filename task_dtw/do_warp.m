%% do_warp(X_cluster, warp_method)
function [X_warp, other_warp] = do_warp(X_cluster, warp_method, opt, other_mat, figbase)
    DEBUG_TIME = 0;

    if nargin < 5, figbase = ''; end
    

    t1 = tic;
    if strcmp(warp_method, 'dtw')
        fprintf(['  do dtw: ' opt '\n']);
        [X_warp, other_warp] = do_dtw(X_cluster, opt, other_mat);

    elseif strcmp(warp_method, 'shift')
        fprintf('  do shift\n');
        [X_warp, other_warp] = do_shift(X_cluster, other_mat);

    elseif strcmp(warp_method, 'shift_limit')
        fprintf('  do shift limit (make sure all ts have common parts)\n');
        [X_warp, other_warp] = do_shift_limit(X_cluster, other_mat, figbase);

    elseif strcmp(warp_method, 'stretch')
        fprintf('  do stretch\n');
        [X_warp, other_warp] = do_stretch(X_cluster, other_mat);
        
    elseif strcmp(warp_method, 'na')
        fprintf('  no warp\n');
        X_warp = X_cluster;
        other_warp = other_mat;
    else
        error(['wrong warp method: ' warp_method]);
    end
    if DEBUG_TIME, fprintf('[TIME] do warp (%s): %f\n', warp_method, toc(t1)); end
end
