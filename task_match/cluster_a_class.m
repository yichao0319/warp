%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Yi-Chao Chen @ UT Austin
%%
%% - Input:
%%   - X: the 3D data
%%        1st dim (cell): words / subjects / ...
%%        2nd dim (matrix): features
%%        3rd dim (matrix): samples over time
%%   - cluster_opt: method=''kmeans'',sync=''shift'',metric=''coeff'',num=2
%%        - method: kmeans
%%        - sync: shift, stretch
%%        - metric: coeff, dist
%%        - num: number of cluster
%% - Output:
%%   - X_cluster: a 4D cell containing the clusters of an activity
%%       1st dim [cell]: clusters
%%       2nd dim [cell]: subjects/words (the first one is the head of the cluster)
%%       3rd dim [matrix]: features 
%%       4th dim [matrix]: time
%%
%%     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [X_cluster] = cluster_a_class(X, cluster_opt)
    
    %% --------------------
    %% DEBUG
    %% --------------------
    DEBUG0 = 0;
    DEBUG1 = 1;
    DEBUG2 = 1;


    %% --------------------
    %% Check input
    %% --------------------
    if nargin < 2, cluster_opt = ''; end


    %% --------------------
    %% Main starts
    %% --------------------
    [method, sync, metric, num] = get_cluster_opt(cluster_opt);

    if strcmp(method, 'kmeans')
        aff_type = 'mat';
        affinity = get_affinity(X, sync, metric, aff_type);
        
        if strcmp(metric, 'dist')
            affinity = 1 ./ affinity;
            idx = isinf(affinity);
            
            if nnz(~idx) == 0
                affinity(idx) = 1;
            else
                affinity(idx) = max(affinity(~idx));
            end
        end
        [cluster_idx, cluster_head, cluster_affinity] = my_kmeans(num, affinity);
    else
        error(['wrong cluster method: ' method]);
    end


    %% --------------------------
    %% only use cluster idx > 0
    uniq_cluster_idx = unique(cluster_idx(find(cluster_idx>0)));
    num_cluster = length(uniq_cluster_idx);
    num_rows    = length(X);


    %% --------------------------
    %% cluster rows according to cluster_idx
    for ci = 1:num_cluster
        idx = find(cluster_idx == uniq_cluster_idx(ci));
        cluster_sizes(ci) = length(idx);

        %% cluster head
        X_cluster{ci}{1} = X{cluster_head(ci)};
        idx = idx(idx ~= cluster_head(ci));
        % if DEBUG2, fprintf('  cluster %d head = %d\n', ci, cluster_head(ci)); end

        %% other member
        for iidx = 1:length(idx)
            X_cluster{ci}{iidx+1} = X{idx(iidx)};
        end
    end
end


function [method, sync, metric, num] = get_cluster_opt(opt)
    method = 'kmeans';
    sync = 'shift';
    metric = 'coeff';
    num = 1;
    if nargin < 1, return; end

    opts = regexp(opt, ',', 'split');
    for this_opt = opts
        eval([char(this_opt) ';']);
    end
end
