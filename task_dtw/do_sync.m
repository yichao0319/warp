%% do_sync(X_cluster, sync_method)
function [X_sync, other_sync] = do_sync(X_cluster, sync_method, opt, other_mat, figbase)
    DEBUG_TIME = 0;
    DEBUG2 = 0;

    if nargin < 3, opt = ''; end
    if nargin < 4, other_mat = {}; end
    if nargin < 5, figbase = ''; end
    

    t1 = tic;
    if strcmp(sync_method, 'dtw')
        if DEBUG2, fprintf(['  do dtw: ' opt '\n']); end
        [X_sync, other_sync] = do_dtw(X_cluster, opt, other_mat);

    elseif strcmp(sync_method, 'shift')
        if DEBUG2, fprintf('  do shift\n'); end
        [X_sync, other_sync] = do_shift(X_cluster, other_mat);

    elseif strcmp(sync_method, 'shift_limit')
        if DEBUG2, fprintf('  do shift limit (make sure all ts have common parts)\n'); end
        [X_sync, other_sync] = do_shift_limit(X_cluster, other_mat, figbase);

    elseif strcmp(sync_method, 'stretch')
        if DEBUG2, fprintf('  do stretch\n'); end
        [X_sync, other_sync] = do_stretch(X_cluster, other_mat);
        
    elseif strcmp(sync_method, 'na')
        if DEBUG2, fprintf('  no sync\n'); end
        X_sync = X_cluster;
        other_sync = other_mat;
    else
        error(['wrong sync method: ' sync_method]);
    end
    if DEBUG_TIME, fprintf('[TIME] do sync (%s): %f\n', sync_method, toc(t1)); end
end
