%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Yi-Chao Chen @ UT Austin
%%
%% - Input:
%%   - X: 3D data
%%        1st dim (cell): subjects / words / ...
%%        2nd dim (matrix): features
%%        3rd dim (matrix): samples over time
%%
%%   - opt:
%%     > sync: na, dtw, shift, stretch
%%     > metric: coeff, dist
%%     > num_seg: number of segments (do sync for each segment)
%%
%%   - other_mat: 4D data
%%        the matrices to be sync as X
%%        1st dim (cell): all matrices
%%        2nd dim (cell): subjects / words / ...
%%        3rd dim (matrix): features
%%        4th dim (matrix): samples over time
%%
%% - Output:
%%   - X_sync: 3D data, same as input X
%%   - other_sync: 4D data, same as input other_mat
%%
%% e.g.
%%
%%     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [X_sync, other_sync] = sync_data(X, opt, other_mat)
    
    %% --------------------
    %% DEBUG
    %% --------------------
    DEBUG0 = 0;
    DEBUG1 = 1;
    DEBUG2 = 1;  %% progress
    DEBUG3 = 1;  %% verbose
    DEBUG4 = 1;  %% results


    %% --------------------
    %% Variable
    %% --------------------
    

    %% --------------------
    %% Check input
    %% --------------------
    if nargin < 2, opt = ''; end
    if nargin < 3, other_mat = {}; end
    

    %% --------------------
    %% Main starts
    %% --------------------
    [sync, metric, num_seg] = get_sync_opt(opt);


    if strcmp(sync, 'dtw')
        if DEBUG2, fprintf(['  do dtw: ' opt '\n']); end

        dtw_opt = ['num_seg=' num2str(num_seg)];
        [X_sync, other_sync] = do_dtw(X, dtw_opt, other_mat);

    elseif strcmp(sync, 'shift')
        % if DEBUG2, fprintf('  do shift\n'); end
        % [X_sync, other_sync] = do_shift(X, other_mat);
        error(['not implemented yet: ' sync]);

    elseif strcmp(sync, 'shift_limit')
        % if DEBUG2, fprintf('  do shift limit (make sure all ts have common parts)\n'); end
        % [X_sync, other_sync] = do_shift_limit(X, other_mat, figbase);
        error(['not implemented yet: ' sync]);

    elseif strcmp(sync, 'stretch')
        % if DEBUG2, fprintf('  do stretch\n'); end
        % [X_sync, other_sync] = do_stretch(X, other_mat);
        error(['not implemented yet: ' sync]);
        
    elseif strcmp(sync, 'na')
        if DEBUG2, fprintf('  no sync\n'); end
        X_sync = X;
        other_sync = other_mat;

    else
        error(['wrong sync method: ' sync]);
    end
end



%% get_sync_opt
function [sync, metric, num_seg] = get_sync_opt(opt)
    feature = 'na';
    metric = 'coeff';
    num_seg = 1;
    if nargin < 1, return; end

    opts = regexp(opt, ',', 'split');
    for this_opt = opts
        eval([char(this_opt) ';']);
    end
end

