%% get_rank: function description
%% opt:
%% - percentile
%% - num_seg
%% - r_method
%%   > 1: fill in shorter clusters with 0s
%%   > 2: sum of the ranks of each cluster
function r = get_rank(X_cluster, opt)
    [percentile, num_seg, method] = get_rank_opt(opt);

    if method == 1
        r = get_seg_rank(cluster2mat(X_cluster), num_seg, percentile);
    elseif method == 2
        r = [];
        for ci = 1:length(X_cluster)
            r(ci, :) = get_seg_rank(my_cell2mat(X_cluster{ci}), num_seg, percentile);
        end
    else
        error(['wrong rank cluster method: ' opt]);
    end

    r = sum(r(:));
end


function r = get_seg_rank(mat, num_seg, percentile)
    seg_size = ceil(size(mat,2) / num_seg);
    % num_seg = floor(size(mat, 2) / seg_size);

    for si = 1:num_seg
        mat_seg = mat(:, (si-1)*seg_size+1:min(end, si*seg_size));
        [cdf_x, cdf_y, r(1, si)] = get_rank_energy_cdf(mat_seg, percentile);
    end
end


%% get_rank_opt: function description
function [percentile, num_seg, r_method] = get_rank_opt(opt)
    percentile = 0.8;
    num_seg = 1;
    r_method = 1;

    opts = regexp(opt, ',', 'split');
    for this_opt = opts
        eval([char(this_opt) ';']);
    end
end
