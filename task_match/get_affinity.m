%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Yi-Chao Chen @ UT Austin
%%
%% - Input:
%%   - X: the 3D data
%%        1st dim (cell): subjects / words / ...
%%        2nd dim (matrix): features
%%        3rd dim (matrix): samples over time
%%   - sync: na, shift, stretch
%%   - metric: coeff, dist
%%   - aff_type: mat, vec
%%
%% - Output:
%%   - affinity: the affinity matrix 
%%       a_ij: the similarity of subject i and j 
%%             (sync j toward i if sync is not 'na')
%%
%%     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [affinity] = get_affinity(X, sync, metric, aff_type)
    addpath('/u/yichao/warp/git_repository/task_match/c_func');

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
    if nargin < 3, metric = 'dist'; end
    if nargin < 4, aff_type = 'vec'; end


    % lim_left  = 1/4;
    % lim_right = 3/4;
    lim_left  = 1/10;
    lim_right = 9/10;

    
    %% --------------------
    %% Main starts
    %% --------------------
    if strcmp(aff_type, 'mat')
        for fi = 1:length(X)
            for fj = 1:length(X)

                if strcmp(sync, 'na')
                    % [shift_idx1, shift_idx2, total_cc] = find_best_shift_limit_c(X{fi}', X{fj}', 0, 1, convert_metric4c(metric));
                    len = min(size(X{fi}, 2), size(X{fj}, 2));
                    if strcmp(metric, 'coeff')
                        tmp = my_corrcoef(X{fi}(:,1:len)', X{fj}(:,1:len)');
                        total_cc = tmp(1, 2);
                    elseif strcmp(metric, 'dist')
                        total_cc = norm(X{fi}(:,1:len)-X{fj}(:,1:len), 2);
                    else
                        error(['wrong metric: ' metric]);
                    end
                elseif strcmp(sync, 'nafair')
                    %% use short length for comparison
                    len1 = size(X{fi}, 2);
                    len2 = size(X{fj}, 2);
                    len = min(floor(len1*(lim_right-lim_left)), len2);
                    st1 = randi(len1-len+1);
                    st2 = randi(len2-len+1);
                    if strcmp(metric, 'coeff')
                        tmp = my_corrcoef(X{fi}(:,st1:st1+len-1)', X{fj}(:,st2:st2+len-1)');
                        total_cc = tmp(1, 2);
                    elseif strcmp(metric, 'dist')
                        total_cc = norm(X{fi}(:,st1:st1+len-1)-X{fj}(:,st2:st2+len-1), 2);
                    else
                        error(['wrong metric: ' metric]);
                    end
                elseif strcmp(sync, 'shift')
                    [shift_idx1, shift_idx2, total_cc] = find_best_shift_limit_c(X{fi}', X{fj}', lim_left, lim_right, convert_metric4c(metric));
                elseif strcmp(sync, 'stretch')
                    error(['wrong sync: ' sync]);
                elseif strcmp(sync, 'dtw')
                    error(['wrong sync: ' sync]);
                else
                    error(['wrong sync: ' sync]);
                end

                if strcmp(metric, 'coeff')
                    cc = max(total_cc);
                    if isnan(cc), cc = -1; end
                    
                    affinity(fi, fj) = cc;
                elseif strcmp(metric, 'dist')
                    idx = find(total_cc >= 0);
                    if length(idx) > 0
                        cc = min(total_cc(idx));
                    else
                        %% one of the row is too short to find best shift
                        cc = Inf;
                    end
                    affinity(fi, fj) = cc;
                else
                    error(['wrong metric: ' metric]);
                end
                    
            end
        end
    elseif strcmp(aff_type, 'vec')
        error(['wrong aff_type: ' aff_type]);
    else
        error(['wrong aff_type: ' aff_type]);
    end     
end

