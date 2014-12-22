%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Yi-Chao Chen @ UT Austin
%%
%% - Input:
%%
%%
%% - Output:
%%   - est_collection
%%     - (1): orig value
%%     - (2): est value
%%     - (3): cluster idx
%%     - (4): cluster similarity
%%     - (5): missing element idx
%%
%% e.g.
%%
%%     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [est_collection] = collect_estimation(X, X_est, M, revM, cluster_idx, cluster_sim, est_collection)
    addpath('../utils');
    
    %% --------------------
    %% DEBUG
    %% --------------------
    DEBUG0 = 0;
    DEBUG1 = 1;
    DEBUG2 = 1;


    %% --------------------
    %% Main starts
    %% --------------------
    missing_idx = find(M == 0);
    if nnz(missing_idx == find(revM>0)) ~= length(missing_idx)
        error('error in collect_estimation');
    end


    tmp(1, :) = X(missing_idx);
    tmp(2, :) = X_est(missing_idx);
    tmp(3, :) = ones(1, length(missing_idx)) * cluster_idx;
    tmp(4, :) = ones(1, length(missing_idx)) * cluster_sim;
    tmp(5, :) = revM(missing_idx);

    est_collection = [est_collection, tmp];
end