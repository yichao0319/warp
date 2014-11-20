%% get_affinity_mat: function description
function [affinity_X, ws] = get_affinity_mat(X, affinity_type)
    addpath('./c_func');

    if strcmp(affinity_type, 'dtw_dist')
        [affinity_X, ws] = get_dtw_dist(X);
    elseif strcmp(affinity_type, 'coef')
        [affinity_X, ws] = get_cc_mat(X);
    elseif strcmp(affinity_type, 'shift_coef')
        [affinity_X, ws] = get_shift_cc_mat(X);
    else
        error(['wrong type: ' affinity_type]);
    end
    
end


%% get_dtw_dist: function description
function [dtw_dist, ws] = get_dtw_dist(X)
    nr = length(X);
    cnt = 0;
    for fi = 1:nr-1
        for fj = fi+1:nr
            cnt = cnt + 1;
            % [dist, D_mat, k, w] = dtw_c(X{fi}', X{fj}');
            dist = dtw_c_orig(X{fi}', X{fj}');
            dtw_dist(cnt) = dist;
            ws{fi, fj} = 1;
        end
    end
end


function [affinity_X, ws] = get_cc_mat(X)
    nr = length(X);
    cnt = 0;
    for fi = 1:nr-1
        for fj = fi+1:nr
            cnt = cnt + 1;
            cc = my_corrcoef(X{fi}', X{fj}');
            cc = cc(1, 2);
            if isnan(cc)
                cc = -1;
            end
            affinity_X(cnt) = cc;
            ws{fi, fj} = 1;
        end
    end
end


function [affinity_X, ws] = get_shift_cc_mat(X)
    nr = length(X);
    cnt = 0;
    lim_left  = 1/3;
    lim_right = 2/3;

    for fi = 1:nr-1
        for fj = fi+1:nr
            cnt = cnt + 1;
            % cc = my_corrcoef(X{fi}', X{fj}');
            [shift_idx1, shift_idx2, total_cc] = find_best_shift_limit(X{fi}, X{fj}, lim_left, lim_right);
            cc = max(total_cc);
            if isnan(cc)
                cc = -1;
            end
            affinity_X(cnt) = cc;
            ws{fi, fj} = 1;
        end
    end
end
