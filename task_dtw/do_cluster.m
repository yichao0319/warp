%% do_cluster: function description
function [X_cluster, other_cluster] = do_cluster(X, num_cluster, method, other_mat)
    addpath('/u/yichao/warp/git_repository/utils/spectral_cluster');

    if nargin < 2, num_cluster = 1; end
    if nargin < 3, method = 'kmeans'; end

    other_cluster = {};
    

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
        elseif strcmp(method, 'spectral')
            X_tmp = my_cell2mat(X);
            X_tmp(isnan(X_tmp)) = 0;
            X_tmp = num2cell(X_tmp, 2);
            [affinity_mat, tmp_ws] = get_affinity_mat(X_tmp);
            affinity = 1 ./ squareform(affinity_mat);
            cluster_idx = spectral_cluster(affinity);
        else
            error(['wrong method name: ' method])
        end
    end

    uniq_cluster_idx = unique(cluster_idx);
    for ci = 1:length(uniq_cluster_idx)
        idx = find(cluster_idx == uniq_cluster_idx(ci));
        for iidx = 1:length(idx)
            X_cluster{ci}{iidx} = X{idx(iidx)};
            
            % M_cluster{ci}{iidx} = M{idx(iidx)};
            if nargin >= 4
                % other_cluster = {};
                for oi = 1:length(other_mat)
                    other_cluster{oi}{ci}{iidx} = other_mat{oi}{idx(iidx)};
                end
            end
        end
    end
end

