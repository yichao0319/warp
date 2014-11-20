%% do_cluster: function description
function [X_cluster, other_cluster] = do_cluster(X, num_cluster, method, figbase, other_mat)
    addpath('/u/yichao/warp/git_repository/utils/spectral_cluster');

    if nargin < 2, num_cluster = 1; end
    if nargin < 3, method = 'kmeans'; end
    if nargin < 4, figbase = ''; end
    if nargin < 5, other_mat = {}; end


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
        elseif strcmp(method, 'hier_dtw')
            [dtw_dist, tmp_ws] = get_affinity_mat(X, 'dtw_dist');
            cluster_tree = linkage(dtw_dist);
            cluster_idx = cluster(cluster_tree, 'maxclust', num_cluster);
        elseif strcmp(method, 'kmeans_dtw')
            tic;
            [dtw_dist, tmp_ws] = get_affinity_mat(X, 'dtw_dist');
            fprintf('  done getting dtw dist mat: %f\n', toc);
            dtw_dist_mat = squareform(dtw_dist);
            tic;
            cluster_idx = my_kmeans(my_cell2mat(X), num_cluster, dtw_dist_mat);
            fprintf('  done clustering: %f\n', toc);
        elseif strcmp(method, 'spectral_dtw')
            X_tmp = my_cell2mat(X);
            X_tmp(isnan(X_tmp)) = 0;
            X_tmp = num2cell(X_tmp, 2);
            [dtw_dist, tmp_ws] = get_affinity_mat(X_tmp, 'dtw_dist');
            affinity_mat = 1 ./ squareform(dtw_dist);
            cluster_idx = spectral_cluster(affinity_mat);
        elseif strcmp(method, 'spectral_cc')
            X_tmp = my_cell2mat(X);
            X_tmp(isnan(X_tmp)) = 0;
            X_tmp = num2cell(X_tmp, 2);
            [affinity, tmp_ws] = get_affinity_mat(X_tmp, 'coef');
            affinity_mat = squareform(affinity);
            cluster_idx = spectral_cluster(affinity_mat);
        elseif strcmp(method, 'spectral_shift_cc')
            X_tmp = my_cell2mat(X);
            X_tmp(isnan(X_tmp)) = 0;
            X_tmp = num2cell(X_tmp, 2);
            [affinity, tmp_ws] = get_affinity_mat(X_tmp, 'shift_coef');
            affinity_mat = squareform(affinity);
            cluster_idx = spectral_cluster(affinity_mat);

            if ~strcmp(figbase, '')
                plot_affinity(affinity, [figbase '.affinity']);
            end
        else
            error(['wrong method name: ' method])
        end
    end

    uniq_cluster_idx = unique(cluster_idx);
    num_cluster = length(uniq_cluster_idx);
    num_rows    = length(X);
    for ci = 1:num_cluster
        idx = find(cluster_idx == uniq_cluster_idx(ci));
        cluster_sizes(ci) = length(idx);
        for iidx = 1:length(idx)
            X_cluster{ci}{iidx} = X{idx(iidx)};
            
            % M_cluster{ci}{iidx} = M{idx(iidx)};
            if nargin >= 5
                % other_cluster = {};
                for oi = 1:length(other_mat)
                    other_cluster{oi}{ci}{iidx} = other_mat{oi}{idx(iidx)};
                end
            end
        end
    end


    %% --------------
    %% DEBUG
    if ~strcmp(figbase, '')
        plot_cluster_size(cluster_sizes, num_rows, [figbase '.clust_size']);
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