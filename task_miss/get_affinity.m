%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Yi-Chao Chen @ UT Austin
%%
%% - Input:
%%   - X: the 2D data
%%        1st dim (cell): subjects / flows / ...
%%        2nd dim (vector): samples over time
%%   - sync: na, shift, stretch, dtw
%%   - metric: coeff, dist, graph
%%   - sigma: the param for 'graph'
%%
%% - Output:
%%   - affinity: the affinity matrix 
%%       a_ij: the similarity of subject i and j 
%%             (sync j toward i if sync is not 'na')
%%     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [affinity] = get_affinity(X, sync, metric, sigma)
    addpath('/u/yichao/warp/git_repository/task_miss/c_func');

    %% --------------------
    %% DEBUG
    %% --------------------
    DEBUG0 = 0;
    DEBUG1 = 1;
    DEBUG2 = 1;


    %% --------------------
    %% Check input
    %% --------------------
    if nargin < 2, sync = 'na'; end
    if nargin < 3, metric = 'coeff'; end
    if nargin < 4, sigma = 1; end
    

    lim_left  = 1/4;
    lim_right = 3/4;
    % lim_left  = 1/10;
    % lim_right = 9/10;

    
    %% --------------------
    %% Main starts
    %% --------------------
    for fi = 1:length(X)
        for fj = 1:length(X)

            %% ----------------------
            %% don't synchronize
            if strcmp(sync, 'na')
                len = min(size(X{fi}, 2), size(X{fj}, 2));
                idx = find(~isnan(X{fi}(1:len)) & ~isnan(X{fj}(1:len)));
                
                if strcmp(metric, 'coeff')
                    tmp = my_corrcoef(X{fi}(idx)', X{fj}(idx)');
                    cc = tmp(1, 2);
                elseif strcmp(metric, 'dist')
                    cc = 1 ./ norm(X{fi}(idx) - X{fj}(idx), 2);
                elseif strcmp(metric, 'graph')
                    %% affinity = exp(-||xi - xj||^2 / 2*sigma^2)
                    cc = exp(-(norm(X{fi}(idx) - X{fj}(idx), 2) ^ 2) / (2*sigma^2));
                else
                    error(['wrong metric: ' metric]);
                end
            
            %% ----------------------
            %% best shift
            elseif strcmp(sync, 'shift')
                [shift_idx1, shift_idx2, cc_ts] = find_best_shift_limit_c(X{fi}', X{fj}', lim_left, lim_right, convert_metric4c(metric));
                
                if strcmp(metric, 'coeff')
                    cc = max(cc_ts);
                    if isnan(cc), cc = -1; end
                elseif strcmp(metric, 'dist')
                    idx = find(cc_ts >= 0);
                    if length(idx) > 0, 
                        cc = 1 / min(cc_ts(idx));
                    else, 
                        %% one of the row is too short to find best shift
                        cc = 0; 
                    end

                elseif strcmp(metric, 'graph')
                    idx = find(cc_ts >= 0);
                    if length(idx) > 0, 
                        cc = min(cc_ts(idx));
                        cc = exp(-(cc^2) / (2*sigma^2))
                    else, 
                        %% one of the row is too short to find best shift
                        cc = 0; 
                    end
                else
                    error(['wrong metric: ' metric]);
                end

            %% ----------------------
            %% best stretch
            %%   XXX: only metric=''coeff'' is implemented
            elseif strcmp(sync, 'stretch')
                % error(['wrong sync: ' sync]);
                [stretch_idx1, stretch_idx2, cc] = find_best_stretch(X{fi}, X{fj});
                if isnan(cc), cc = -1; end

            %% ----------------------
            %% DTW
            elseif strcmp(sync, 'dtw')
                idx1 = find(~isnan(X{fi}));
                tmp_ts1 = X{fi}(idx1);
                idx2 = find(~isnan(X{fj}));
                tmp_ts2 = X{fj}(idx2);

                cc = 1 ./ dtw_c_orig(tmp_ts1', tmp_ts2');

            else
                error(['wrong sync: ' sync]);
            end


            affinity(fi, fj) = cc;

        end
    end    
end

