%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Yi-Chao Chen @ UT Austin
%%
%% do_sync
%%
%% - Input:
%%   - X_cluster: 3D data
%%      1st dim (cell): clusters
%%      2nd dim (cell): subjects / flows / ...
%%      3rd dim (vector): time series
%%   - opt:
%%      > num_seg
%%      > sync
%%        - na
%%        - shift
%%        - stretch
%%        - dtw
%%      > metric
%%        - dist
%%        - coeff
%%        - graph
%%      > sigma: used for fully connected graph metric
%%   - other_mat: 4D data -- other matrices to be sync as X_cluster
%%       1st dim (cell): 
%%       2nd dim (cell): clusters
%%       3rd dim (cell): subjects / flows / ...
%%       4th dim (vector): time series
%%   - figbase:
%%       the path to output figures
%%       figbase=='': don't plot
%%
%% - Output
%%   - X_sync: 3D data
%%      1st dim (cell): clusters
%%      2nd dim (cell): subjects / flows / ...
%%      3rd dim (vector): synchronized time series
%%   - other_sync: 4D data
%%       1st dim (cell): 
%%       2nd dim (cell): clusters
%%       3rd dim (cell): subjects / flows / ...
%%       4th dim (vector): synchronized time series
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [X_sync, other_sync] = do_sync(X_cluster, opt, other_mat, figbase)
    DEBUG_TIME = 0;
    DEBUG2 = 0;

    if nargin < 2, opt = ''; end
    if nargin < 3, other_mat = {}; end
    if nargin < 4, figbase = ''; end


    [num_seg, sync, metric, sigma] = get_sync_opt(opt);
    

    t1 = tic;
    %% -----------
    %% DTW
    if strcmp(sync, 'dtw')
        if DEBUG2, fprintf(['  do dtw: ' opt '\n']); end
        [X_sync, other_sync] = do_dtw(X_cluster, opt, other_mat);

    %% -----------
    %% shift: 
    %%   keep all elements and pad unaligned ones with zeros
    % elseif strcmp(sync, 'shift')
    %     if DEBUG2, fprintf('  do shift\n'); end
    %     [X_sync, other_sync] = do_shift(X_cluster, other_mat);

    %% -----------
    %% shift: 
    %%   only keep overlay part
    % elseif strcmp(sync, 'shift_limit')
    elseif strcmp(sync, 'shift')
        if DEBUG2, fprintf('  do shift limit (make sure all ts have common parts)\n'); end
        [X_sync, other_sync] = do_shift_limit(X_cluster, opt, figbase, other_mat);

    %% -----------
    %% stretch
    elseif strcmp(sync, 'stretch')
        if DEBUG2, fprintf('  do stretch\n'); end
        [X_sync, other_sync] = do_stretch(X_cluster, other_mat);
        
    %% -----------
    %% don't synchronize
    elseif strcmp(sync, 'na')
        if DEBUG2, fprintf('  no sync\n'); end
        X_sync = X_cluster;
        other_sync = other_mat;

    else
        error(['wrong sync method: ' sync]);
    end
    if DEBUG_TIME, fprintf('[TIME] do sync (%s): %f\n', sync, toc(t1)); end
end


function [num_seg, sync, metric, sigma] = get_sync_opt(opt)
    num_seg = 1;
    sync    = 'na';
    metric  = 'dist';
    sigma   = 1;
    
    opts = regexp(opt, ',', 'split');
    for this_opt = opts
        eval([char(this_opt) ';']);
    end
end
