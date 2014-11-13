function cluster_idx = my_kmeans(X, num_cluster, affinity)
    X = clust_normalize(X);
    [N,n] = size(X);

    num_cluster = min(N, num_cluster-1);

    if N == 1
        cluster_idx = [1];
        return;
    end

    index = randperm(N);
    center_idx = sort(index(1:num_cluster));
    center_idx_old = sort(index(2:num_cluster+1));
    
    
    iter = 0;
    % while prod(max(abs(v - v0))),
    while ((length(setxor(center_idx, center_idx_old)) > 0) || (iter == 0)) && (iter < 1000)
        iter = iter + 1;  
        center_idx_old = center_idx;
        
        %Calculating the distances
        dist = [];
        for ci = 1:length(center_idx)
            this_center = center_idx(ci);
            dist(:, ci) = affinity(:, this_center);
        end
        %Assigning clusters
        [m, label] = min(dist');
          
        %Calculating cluster centers
        valid = [];
        for ci = 1:length(center_idx)
            index = find(label == ci);
            if ~isempty(index)
                dist = sum(affinity(index, index));
                [tmp, cidx] = min(dist);
                center_idx(ci) = index(cidx);
                valid = [valid ci];
            end
        end
        center_idx = center_idx(valid);
    end


    %Calculating the distances
    dist = [];
    for ci = 1:length(center_idx)
        this_center = center_idx(ci);
        dist(:, ci) = affinity(:, this_center);
    end
    %Assigning clusters
    [m, cluster_idx] = min(dist');


end


function X = clust_normalize(X)
    min_X = min(X);
    max_X = max(X);
    X = (X - repmat(min_X, size(X,1), 1)) ./ (repmat(max_X, size(X,1), 1) - repmat(min_X, size(X,1), 1));
end

