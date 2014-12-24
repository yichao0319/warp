%% select_head:
function [head_idx, cluster_affinity] = select_head(head_type, affinity)
    row_affinity = mean(affinity, 2);

    if strcmp(head_type, 'rand')
        %% rand head
        head_idx = randi(size(affinity,1));
        % cluster_affinity = row_affinity(head_idx);
        cluster_affinity = 0;

    elseif strcmp(head_type, 'best')
        [cluster_affinity, head_idx] = max(row_affinity);

    elseif strcmp(head_type, 'worst')
        [cluster_affinity, head_idx] = min(row_affinity);

    else
        error(['wrong head type = ' head_type]);
    end
    
    head_idx = head_idx(1);
    cluster_affinity = cluster_affinity(1);
end


