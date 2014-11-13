%% do_cluster: function description
function [X_cluster, M_cluster] = do_cluster(X, num_cluster, method, M)

    if nargin < 2, num_cluster = 1; end
    if nargin < 3, method = 'kmeans'; end
    if nargin < 4, M = ones(size(X)); end


    if num_cluster == Inf
        %% ------------------
        %% no cluster
        cluster_idx = 1:length(X);
        
    elseif num_cluster == 1
        %% ------------------
        %% 1 cluster
        cluster_idx = ones(1, length(X));
    else
        if strcmp(method, 'kmeans')
            cluster_idx = kmeans(my_cell2mat(X), num_cluster);
        elseif strcmp(method, 'hierarchical')
            dist = pdist(my_cell2mat(X));
            cluster_tree = linkage(dist);
            cluster_idx = cluster(cluster_tree, 'maxclust', num_cluster);
        elseif strcmp(method, 'hier_affinity')
            [affinity_mat, tmp_ws] = get_affinity_mat(X);
            cluster_tree = linkage(affinity_mat);
            cluster_idx = cluster(cluster_tree, 'maxclust', num_cluster);
        elseif strcmp(method, 'kmeans_affinity')
            tic;
            [affinity_mat, tmp_ws] = get_affinity_mat(X);
            fprintf('  done getting affinity mat: %f\n', toc);
            affinity = squareform(affinity_mat);
            tic;
            cluster_idx = my_kmeans(my_cell2mat(X), num_cluster, affinity);
            fprintf('  done clustering: %f\n', toc);
        else
            error(['wrong method name: ' method])
        end
    end

    uniq_cluster_idx = unique(cluster_idx);
    for ci = 1:length(uniq_cluster_idx)
        idx = find(cluster_idx == uniq_cluster_idx(ci));
        for iidx = 1:length(idx)
            X_cluster{ci}{iidx} = X{idx(iidx)};
            M_cluster{ci}{iidx} = M{idx(iidx)};
        end
    end
end

