%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Yi-Chao Chen @ UT Austin
%%
%% - Input:
%%   - X: 2D matrix
%%   - opt:
%%     > percentile
%%     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [r] = cal_rank(X, opt)
    %% --------------------
    %% DEBUG
    %% --------------------
    DEBUG0 = 0;
    DEBUG1 = 1;
    DEBUG2 = 1;  %% progress
    DEBUG3 = 1;  %% verbose
    DEBUG4 = 1;  %% results


    %% --------------------
    %% Check input
    %% --------------------
    if nargin < 2, opt = ''; end
    

    %% --------------------
    %% Main starts
    %% --------------------
    [percentile] = get_cal_rank_opt(opt);
    [cdf_x, cdf_y, r] = cal_rank_energy_cdf(X, percentile);
    
end


%% get_rank_opt: function description
function [percentile] = get_cal_rank_opt(opt)
    percentile = 0.8;

    opts = regexp(opt, ',', 'split');
    for this_opt = opts
        eval([char(this_opt) ';']);
    end
end
