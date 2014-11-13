%% get_affinity_mat: function description
function [affinity_X, ws] = get_affinity_mat(X)
    addpath('./c_func');

    nr = length(X);
    cnt = 0;
    for fi = 1:nr-1
        for fj = fi+1:nr
            cnt = cnt + 1;
            % [dist, D_mat, k, w] = dtw_c(X{fi}', X{fj}');
            dist = dtw_c_orig(X{fi}', X{fj}');
            affinity_X(cnt) = dist;
            ws{fi, fj} = 1;
        end
    end
end
