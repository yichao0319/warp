%% subspace_cluster
%% - head_type
%%   > random
%%   > best
%%   > worst
function [cluster_idx, cluster_head, cluster_affinity] = subspace_cluster(X, num_cluster, method, head_type)
    addpath('./c_func');

    if nargin < 4, head_type = 'best'; end


    shift_lim_left  = 1/3;
    shift_lim_right = 2/3;
    num_rows = length(X);
    best_cc_thresh = min(0.8, 1-40/num_rows);
    % best_cc_thresh = 0.2;

    
    tmp = randperm(num_rows);
    seed_idces = tmp(1:min(num_cluster, num_rows));

    for si = 1:length(seed_idces)
        seed_idx = seed_idces(si);
        
        cc = ones(1, num_rows) * -1;
        for tsi = 1:num_rows
            if tsi == seed_idx, continue; end

            if strcmp(method, 'shift')
                [shift_idx1, shift_idx2, this_cc] = find_best_shift_limit_c(X{seed_idx}, X{tsi}, shift_lim_left, shift_lim_right);
            elseif strcmp(method, 'stretch')
                [shift_idx1, shift_idx2, this_cc] = find_best_stretch(X{seed_idx}, X{tsi});
            else
                error(['wrong subspace method: ' method]);
            end
                    
            cc(tsi) = max(this_cc);
        end

        [f, x] = ecdf(cc);
        idx = find(f > best_cc_thresh);
        thresh = min(x(idx(1)), 0.7);
        % thresh = x(idx(1));
        select_idx = find(cc > thresh);
        subspace_coef(si) = mean(cc(select_idx));
        subspace_idx{si} = [seed_idx, select_idx];
    end

    [val, select_ss_idx] = max(subspace_coef);
    cluster_idx = zeros(1, num_rows);
    cluster_idx(subspace_idx{select_ss_idx}) = 1;
    if strcmp(head_type, 'random')
        %% rand
        cluster_head(1) = subspace_idx{select_ss_idx}(end);
        cluster_affinity(1) = subspace_coef(select_ss_idx);
    elseif strcmp(head_type, 'best')
        %% max corrcoef
        cluster_head(1) = subspace_idx{select_ss_idx}(1);
        cluster_affinity(1) = subspace_coef(select_ss_idx); %% XXX: fix
    elseif strcmp(head_type, 'worst')
        %% max corrcoef
        cluster_head(1) = subspace_idx{select_ss_idx}(end);
        cluster_affinity(1) = subspace_coef(select_ss_idx); %% XXX: fix
    else
        error(['wrong input of head_type: ' num2str(head_type)]);
    end

    fprintf('  select subspace coef = %f\n', val);
    fprintf('  cluster head = %d\n', cluster_head(1));
end
