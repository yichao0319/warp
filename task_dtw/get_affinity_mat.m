%% get_affinity_mat:
%% - affinity_opt
%%   > sigma: 
%%       used to calculate full connected graph simility
%% - sync_type
%%   > na
%%   > shift
%%   > stretch
%%   > dtw
%% - metric_type
%%   > dist: euclidean distance
%%   > dtw_dist: DTW distance
%%   > coef
%%   > graph
%% - form_type
%%   > vec: vector
%%   > mat: matrix
function [affinity_X, ws] = get_affinity_mat(X, sync_type, metric_type, form_type, affinity_opt)
    addpath('./c_func');

    if nargin < 4, form_type='vec'; end
    if nargin < 5, affinity_opt=''; end

    sigma = get_affinity_opt(affinity_opt);

    if strcmp(sync_type, 'dtw') & strcmp(metric_type, 'dtw_dist')
        [affinity_X, ws] = get_dtw_dist(X, form_type);
    elseif strcmp(metric_type, 'graph')
        [affinity_X, ws] = get_graph_affinity(X, form_type, sigma);
    elseif strcmp(sync_type, 'na') & strcmp(metric_type, 'coef')
        [affinity_X, ws] = get_cc_mat(X, form_type);
    elseif strcmp(sync_type, 'shift') & strcmp(metric_type, 'coef')
        tic;
        [affinity_X, ws] = get_shift_cc_mat(X, form_type);
        fprintf('  get affinity mat in %fs\n', toc);
    else
        error(['wrong type: ' affinity_opt]);
    end
end


%% get_affinity_opt: function description
function [sigma] = get_affinity_opt(opt)
    sigma = 1;
    if nargin < 1, return; end

    opts = regexp(opt, ',', 'split');
    for this_opt = opts
        eval([char(this_opt) ';']);
    end

end



%% get_dtw_dist: function description
function [dtw_dist, ws] = get_dtw_dist(X, form_type)
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

    if strcmp(form_type, 'mat')
        dtw_dist = squareform(dtw_dist);
    end
end


%% get_graph_affinity: function description
function [graph_affinity, ws] = get_graph_affinity(X, form_type, sigma)

    %% normalize X
    X = my_cell2mat(X);
    X = X / max(X(:));

    nr = size(X, 1);
    cnt = 0;
    for fi = 1:nr-1
        for fj = fi+1:nr
            cnt = cnt + 1;
            
            %% -------
            %% affinity = exp(-||xi - xj||^2 / 2*sigma^2)
            idx = find(~isnan(X(fi,:)) & ~isnan(X(fj,:) ));
            affinity = exp(-(norm(X(fi,idx) - X(fj,idx), 2) ^ 2) / (2*sigma^2));
            %% -------

            graph_affinity(cnt) = affinity;
            ws{fi, fj} = 1;
        end
    end

    if strcmp(form_type, 'mat')
        graph_affinity = squareform(graph_affinity);
        for fi = 1:nr
            affinity_X(fi, fi) = 1;
        end
    end
end


function [affinity_X, ws] = get_cc_mat(X, form_type)
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

    if strcmp(form_type, 'mat')
        affinity_X = squareform(affinity_X);
        for fi = 1:nr
            affinity_X(fi, fi) = 1;
        end
    end
end


function [affinity_X, ws] = get_shift_cc_mat(X, form_type)
    nr = length(X);
    lim_left  = 1/3;
    lim_right = 2/3;

    if strcmp(form_type, 'vec')
        cnt = 0;
        for fi = 1:nr-1
            for fj = fi+1:nr
                cnt = cnt + 1;
                % cc = my_corrcoef(X{fi}', X{fj}');
                % [shift_idx1, shift_idx2, total_cc] = find_best_shift_limit(X{fi}, X{fj}, lim_left, lim_right);
                [shift_idx1, shift_idx2, total_cc] = find_best_shift_limit_c(X{fi}, X{fj}, lim_left, lim_right);
                cc = max(total_cc);
                if isnan(cc)
                    cc = -1;
                end
                % cc = round(cc) * 100;
                % cc = round(cc / 0.2) * 100;
                
                affinity_X(cnt) = cc;
                ws{fi, fj} = 1;
            end
        end
    elseif strcmp(form_type, 'mat')
        for fi = 1:nr
            for fj = 1:nr
                if fi == fj
                    affinity_X(fi, fj) = 1;
                else
                    [shift_idx1, shift_idx2, total_cc] = find_best_shift_limit_c(X{fi}, X{fj}, lim_left, lim_right);
                    cc = max(total_cc);
                    if isnan(cc)
                        cc = -1;
                    end
                    affinity_X(fi, fj) = cc;
                end

                ws{fi, fj} = 1;
            end
        end

    else
        error(['wrong form: ' form_type]);
    end
end
