%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Yi-Chao Chen @ UT Austin
%%
%% cal_similarity:
%%   calculate the similarity to an activity
%%
%% - Input:
%%   - ts: a 2D matrix of time series to test
%%       2D: feature x time
%%   - X_cluster: a 4D cell containing the clusters of an activity
%%       1st dim [cell]: clusters
%%       2nd dim [cell]: subjects/words (the first one is the head of the cluster)
%%       3rd dim [matrix]: features 
%%       4th dim [matrix]: time
%%   - opt
%%       - sync: na, shift, stretch
%%       - metric: coeff, dist
%%
%% - Output:
%%   - similarity: the similarity to the class, the larger the better
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [similarity] = cal_similarity(ts, X_cluster, opt)
    
    %% --------------------
    %% DEBUG
    %% --------------------
    DEBUG0 = 0;
    DEBUG1 = 1;
    DEBUG2 = 1;
    DEBUG3 = 0;

    % lim_left  = 1/4;
    % lim_right = 3/4;
    lim_left  = 1/10;
    lim_right = 9/10;


    %% --------------------
    %% Check input
    %% --------------------
    if nargin < 3, opt = ''; end


    %% --------------------
    %% Main starts
    %% --------------------
    [sync, metric] = get_cal_similarity_opt(opt);

    similarity = [];
    for ci = 1:length(X_cluster)
        cluster_head = X_cluster{ci}{1};
        if strcmp(sync, 'na')
            % [shift_idx1, shift_idx2, total_cc] = find_best_shift_limit_c(cluster_head', ts', 0, 1, convert_metric4c(metric));
            len = min(size(cluster_head, 2), size(ts, 2));
            if strcmp(metric, 'coeff')
                tmp = my_corrcoef(cluster_head(:,1:len)', ts(:,1:len)');
                total_cc = tmp(1, 2);
            elseif strcmp(metric, 'dist')
                total_cc = norm(cluster_head(:,1:len)-ts(:,1:len), 2);
            else
                error(['wrong metric: ' metric]);
            end
        elseif strcmp(sync, 'nafair')
            %% use short length for comparison
            len1 = size(cluster_head, 2);
            len2 = size(ts, 2);
            len = min(floor(len1*(lim_right-lim_left)), len2);
            st1 = randi(len1-len+1);
            st2 = randi(len2-len+1);
            if strcmp(metric, 'coeff')
                tmp = my_corrcoef(cluster_head(:,st1:st1+len-1)', ts(:,st2:st2+len-1)');
                total_cc = tmp(1, 2);
            elseif strcmp(metric, 'dist')
                total_cc = norm(cluster_head(:,st1:st1+len-1)-ts(:,st2:st2+len-1), 2);
            else
                error(['wrong metric: ' metric]);
            end
        elseif strcmp(sync, 'shift')
            [shift_idx1, shift_idx2, total_cc] = find_best_shift_limit_c(cluster_head', ts', lim_left, lim_right, convert_metric4c(metric));
            % [shift_idx1, shift_idx2, total_cc] = find_best_shift_limit_c(ts', cluster_head', lim_left, lim_right, convert_metric4c(metric));
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
            
            similarity(ci) = cc;

        elseif strcmp(metric, 'dist')
            idx = find(total_cc >= 0);
            if length(idx) > 0
                cc = min(total_cc(idx));
                similarity(ci) = 1 / cc(1);
            else
                %% one of the row is too short to find best shift
                similarity(ci) = 0;
            end
            % cc = min(total_cc(idx));
            % similarity(ci) = 1 / cc(1);

        else
            error(['wrong metric: ' metric]);
        end
    end

    if DEBUG3,
        for ci = 1:length(X_cluster)
            fprintf('  cluster %d similarity = %f\n', ci, similarity(ci));
        end
    end

    similarity = max(similarity);
end


function [sync, metric] = get_cal_similarity_opt(opt)
    sync = 'shift';
    metric = 'dist';
    if nargin < 1, return; end

    opts = regexp(opt, ',', 'split');
    for this_opt = opts
        eval([char(this_opt) ';']);
    end
end
