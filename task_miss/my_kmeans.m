%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Yi-Chao Chen @ UT Austin
%%
%% kmeans
%% 1. randomly select k cluster heads
%% 2. while(true)
%% 3.   subjects join the cluster with maximal similarity to its head
%% 4.   remove cluster with #members < thresh
%% 5.   re-select the heads which have maximal avg similarity to all members
%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [cluster_idx, cluster_head, cluster_affinity] = my_kmeans(num_cluster, affinity)
    DEBUG3 = 0;

    N = size(affinity, 1);

    num_cluster = min([N, num_cluster]);

    if N == 1
        cluster_idx = [1];
        cluster_head(1) = 1;
        cluster_affinity(1) = 0;
        return;
    end

    index = randperm(N);
    center_idx = sort(index(1:num_cluster));
    index2 = randperm(N);
    center_idx_old = sort(index2(1:num_cluster));

    iter = 0;
    %% while prod(max(abs(v - v0))),
    while ((length(setxor(center_idx, center_idx_old)) > 0) || (iter == 0)) && (iter < 1000)
        iter = iter + 1;  
        center_idx_old = center_idx;

        %% Calculating the distances
        affinity_to_head = [];
        for ci = 1:length(center_idx)
            this_center = center_idx(ci);
            % fprintf(' center %d idx = %d\n', ci, this_center);
            affinity_to_head(ci, :) = affinity(this_center, :);
        end
        %% Assigning clusters
        [m, label] = max(affinity_to_head, [], 1);
        
        %% Calculating cluster head
        valid = [];
        for ci = 1:length(center_idx)
            index = find(label == ci);
            % fprintf('  cluster %d head = %d: # members = %d\n', ci, center_idx(ci), length(index));
            % if ~isempty(index)
            if length(index) > 1
                % dist = sum(affinity(index, index));
                % [tmp, cidx] = min(dist);
                % center_idx(ci) = index(cidx);
                % valid = [valid ci];
                affinity_to_head = sum(affinity(index, index), 2);
                [tmp, cidx] = max(affinity_to_head);
                center_idx(ci) = index(cidx);
                valid = [valid ci];
            end
        end
        if length(valid) == 0
            valid = [1];
        end
        center_idx = center_idx(valid);
    end

    %% Calculating the distances
    affinity_to_head = [];
    for ci = 1:length(center_idx)
        this_center = center_idx(ci);
        affinity_to_head(ci, :) = affinity(this_center, :);
    end
    
    %% Assigning clusters
    [m, cluster_idx] = max(affinity_to_head, [], 1);
    cluster_head = center_idx;

    %% Calculate cluster affinity
    cluster_affinity = [];
    for ci = 1:length(cluster_head)
        index = find(cluster_idx == ci);
        cluster_affinity(ci) = mean(affinity(cluster_head(ci), index));

        if DEBUG3, fprintf('  cluster %d head = %d: # members = %d, mean affinity = %f\n', ci, center_idx(ci), length(index), cluster_affinity(ci)); end
    end
end

