%% do_cluster: function description
%% - cluster_opt:
%%   > num_cluster
%%   > head_type
%%     > random
%%     > best
%%     > worst
%%   > sync_type
%%     > na
%%     > shift
%%     > stretch
%%     > dtw
%%   > metric_type
%%     > dist: euclidean distance
%%     > dtw_dist: DTW distance
%%     > coef
%%     > graph
function [X_cluster, other_cluster] = do_cluster(X, method, cluster_opt, figbase, other_mat)
    addpath('/u/yichao/warp/git_repository/utils/spectral_cluster');

    if nargin < 2, method = 'kmeans'; end
    if nargin < 3, cluster_opt = ''; end
    if nargin < 4, figbase = ''; end
    if nargin < 5, other_mat = {}; end

    [num_cluster, head_type, sync_type, metric_type, sigma] = get_cluster_opt(cluster_opt);
    other_cluster = {};
    cluster_head = [];
    affinity_mat = [];
    

    if num_cluster == Inf
        %% ------------------
        %% no cluster
        cluster_idx = 1:length(X);
        
    elseif num_cluster == 1
        %% ------------------
        %% 1 cluster
        cluster_idx = ones(1, length(X));
    else
        %% ------------------
        %% k-means
        if strcmp(method, 'kmeans')
            if strcmp(sync_type, 'na') & strcmp(metric_type, 'dist')
                %% euclidean dist
                cluster_idx = kmeans(my_cell2mat(X), num_cluster);
            else
                form_type = 'mat';
                affinity_opt = '';
                [affinity_mat, tmp_ws] = get_affinity_mat(X, sync_type, metric_type, form_type);
                [cluster_idx, cluster_head, cluster_affinity] = my_kmeans(my_cell2mat(X), num_cluster, affinity_mat);
            end

        %% ------------------
        %% hierarchical clustering
        elseif strcmp(method, 'hierarchical')
            if strcmp(sync_type, 'na') & strcmp(metric_type, 'dist')
                %% euclidean dist
                dist = pdist(my_cell2mat(X));
                cluster_tree = linkage(dist);
                cluster_idx = cluster(cluster_tree, 'maxclust', num_cluster);
            else
                [dist, tmp_ws] = get_affinity_mat(X, sync_type, metric_type);
                cluster_tree = linkage(dist);
                cluster_idx = cluster(cluster_tree, 'maxclust', num_cluster);
            end

        %% ------------------
        %% spectral clustering
        elseif strcmp(method, 'spectral')
            X_tmp = my_cell2mat(X);
            X_tmp(isnan(X_tmp)) = 0;
            X_tmp = num2cell(X_tmp, 2);
            affinity_opt = ['sigma=' num2str(sigma)];
            form_type = 'mat';
            [affinity_mat, tmp_ws] = get_affinity_mat(X_tmp, sync_type, metric_type, form_type, affinity_opt);
            % affinity_mat(1:10, 1:10)
            % function [idx] = spectral_cluster(A,k,lap_opt,kmax)
            cluster_idx = spectral_cluster(affinity_mat, num_cluster);

        %% ------------------
        %% subspace clustering
        elseif strcmp(method, 'subspace')
            [cluster_idx, cluster_head, cluster_affinity] = subspace_cluster(X, num_cluster, sync_type, head_type);

        else
            error(['wrong method name: ' method])
        end
    end

    %% --------------------------
    %% only use cluster idx > 0
    uniq_cluster_idx = unique(cluster_idx(find(cluster_idx>0)));
    num_cluster = length(uniq_cluster_idx);
    num_rows    = length(X);


    %% --------------------------
    %% find cluster head
    if length(cluster_head) == 0
        %% prepare for the affinity matrix
        if ~strcmp(head_type, 'random') & length(affinity_mat) == 0
            X_tmp = my_cell2mat(X);
            X_tmp(isnan(X_tmp)) = 0;
            X_tmp = num2cell(X_tmp, 2);
            [affinity_mat, tmp_ws] = get_affinity_mat(X_tmp, 'shift', 'coef', 'mat');
        end

        for ci = 1:num_cluster
            idx = find(cluster_idx == uniq_cluster_idx(ci));
            tmp_X = {};
            for ii = 1:length(idx)
                tmp_X{ii} = X{idx(ii)};
            end
            tmp_X = my_cell2mat(tmp_X);
            if length(affinity_mat) > 0
                tmp_affinity_mat = affinity_mat(idx, idx);
            else
                tmp_affinity_mat = [];
            end
            [tmp_idx, tmp_aff] = select_head(tmp_X, head_type, tmp_affinity_mat);
            cluster_head(ci) = idx(tmp_idx);
            cluster_affinity(ci) = tmp_aff;
        end
    end


    %% --------------------------
    %% DEBUG
    %% only choose the cluster w/ highest affinity
    % [val, best_clust_idx] = max(cluster_affinity);
    % new_cluster_idx = zeros(size(cluster_idx));
    % idx = find(cluster_idx == best_clust_idx);
    % new_cluster_idx(idx) = 1;

    % tmp = cluster_head(best_clust_idx);
    % cluster_head = [];
    % cluster_head(1) = tmp;

    % tmp = cluster_affinity(best_clust_idx);
    % cluster_affinity = [];
    % cluster_affinity(1) = tmp;

    % cluster_idx = new_cluster_idx;
    % uniq_cluster_idx = unique(cluster_idx(find(cluster_idx>0)));
    % num_cluster = length(uniq_cluster_idx);
    %% END DEBUG
    %% --------------------------


    %% --------------------------
    %% cluster rows according to cluster_idx
    for ci = 1:num_cluster
        idx = find(cluster_idx == uniq_cluster_idx(ci));
        cluster_sizes(ci) = length(idx);

        %% cluster head
        X_cluster{ci}{1} = X{cluster_head(ci)};
        if nargin >= 5
            for oi = 1:length(other_mat)
                other_cluster{oi}{ci}{1} = other_mat{oi}{cluster_head(ci)};
            end
        end
        idx = idx(idx ~= cluster_head(ci));
        fprintf('  cluster %d head = %d\n', ci, cluster_head(ci));

        %% other member
        for iidx = 1:length(idx)

            X_cluster{ci}{iidx+1} = X{idx(iidx)};
            
            % M_cluster{ci}{iidx} = M{idx(iidx)};
            if nargin >= 5
                % other_cluster = {};
                for oi = 1:length(other_mat)
                    other_cluster{oi}{ci}{iidx+1} = other_mat{oi}{idx(iidx)};
                end
            end
        end
        % size(X_cluster{ci})
    end


    %% --------------
    %% DEBUG
    if ~strcmp(figbase, '')
        plot_cluster_size(cluster_sizes, num_rows, [figbase '.' cluster_opt '.clust_size']);
    end
end


%% get_dtw_opt: function description
function [num_cluster, head_type, sync_type, metric_type, sigma] = get_cluster_opt(opt)
    num_cluster = 1;
    head_type = 'random';
    sync_type = 'na';
    metric_type = 'coef';
    sigma = 1;
    if nargin < 1, return; end

    opts = regexp(opt, ',', 'split');
    for this_opt = opts
        eval([char(this_opt) ';']);
    end
end


%% select_head:
function [head_idx, cluster_affinity] = select_head(X, head_type, affinity_mat)
    row_affinity = mean(affinity_mat, 2);

    if strcmp(head_type, 'random')
        %% rand head
        head_idx = randi(size(X,1));
        cluster_affinity = row_affinity(head_idx);

    elseif strcmp(head_type, 'best')
        [cluster_affinity, head_idx] = max(row_affinity);

    elseif strcmp(head_type, 'worst')
        [cluster_affinity, head_idx] = min(row_affinity);

    else
        error(['wrong head type = ' head_type]);

    end
        
end



%% plot_cluster_size: function description
function plot_cluster_size(cluster_sizes, num_rows, figname)
    font_size = 12;
    colors   = {'r', 'b', [0 0.8 0], 'm', [1 0.85 0], [0 0 0.47], [0.45 0.17 0.48], 'k'};
    lines    = {'-', '--'};
    markers  = {'+', 'o', '*', '.', 'x', 's', 'd', '^', '>', '<', 'p', 'h'};


    %% cluster size
    [f, x] = ecdf(cluster_sizes);

    fh = figure(1); clf;
    li = 1;
    lh{li} = plot(x, f, '-x');
    set(lh{li}, 'Color', colors{mod(li-1,length(colors))+1});
    set(lh{li}, 'LineStyle', lines{mod(li-1,length(lines))+1});  %% line  : -|--|:|-.
    set(lh{li}, 'LineWidth', 4);
    set(lh{li}, 'MarkerSize', 5);
    legends{li} = ['#cluster=' num2str(length(cluster_sizes)) ', #rows=' num2str(num_rows)];
    

    set(gca, 'FontSize', font_size);
    xlabel('size of each cluster', 'FontSize', font_size);
    ylabel('CDF', 'FontSize', font_size);

    legend(legends, 'Location', 'SouthEast');
    % legend(legends, 'Location', 'NorthEast');
    print(fh, '-depsc', [figname '.eps']);
end


%% plot_affinity: function description
function plot_affinity(affinity, figname)
    font_size = 12;
    colors   = {'r', 'b', [0 0.8 0], 'm', [1 0.85 0], [0 0 0.47], [0.45 0.17 0.48], 'k'};
    lines    = {'-', '--'};
    markers  = {'+', 'o', '*', '.', 'x', 's', 'd', '^', '>', '<', 'p', 'h'};

    %% affinity
    [f, x] = ecdf(affinity);

    fh = figure(1); clf;
    li = 1;
    lh{li} = plot(x, f, '-x');
    set(lh{li}, 'Color', colors{mod(li-1,length(colors))+1});
    set(lh{li}, 'LineStyle', lines{mod(li-1,length(lines))+1});  %% line  : -|--|:|-.
    set(lh{li}, 'LineWidth', 4);
    set(lh{li}, 'MarkerSize', 5);

    set(gca, 'FontSize', font_size);
    xlabel('Affinity', 'FontSize', font_size);
    ylabel('CDF', 'FontSize', font_size);

    % legend(legends, 'Location', 'SouthEast');
    % legend(legends, 'Location', 'NorthEast');
    print(fh, '-depsc', [figname '.eps']);
end