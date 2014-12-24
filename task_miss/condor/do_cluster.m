%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Yi-Chao Chen @ UT Austin
%%
%% do_cluster
%%
%% - Input:
%%   - X: 2D data
%%       1st dim (cell): subjects / flows / ...
%%       2nd dim (vector): time series
%%   - cluster_opt:
%%     > method: 
%%       - kmeans
%%       - spectral
%%     > num: number of clusters
%%     > head: the way to choose cluster head
%%       - rand
%%       - best
%%       - worst
%%     > merge: merge cluster if necessary
%%       - num: #members of a cluster < thresh
%%       - sim: similarity of a cluster < thresh 
%%       - top: top "thresh" clusters with highest similarity
%%       - na: don't merge
%%     > thresh
%%
%%     > sync
%%       - na
%%       - shift
%%       - stretch
%%       - dtw
%%     > metric
%%       - dist
%%       - coeff
%%       - graph
%%     > sigma: used for fully connected graph metric
%%     > num_seg: segment time series and sync each segment
%%
%%   - figbase:
%%       the path to output figures
%%       figbase=='': don't plot
%%   - other_mat: 3D data -- other matrices to be clustered as X
%%       1st dim (cell): 
%%       2nd dim (cell): subjects / flows / ...
%%       3rd dim (vector): time series
%%
%% - Output:
%%   - X_cluster: 3D data
%%       1st dim (cell): clusters
%%       2nd dim (cell): subjects / flows / ...
%%       3rd dim (vector): time series
%%   - other_cluster: 4D data
%%       1st dim (cell): 
%%       2nd dim (cell): clusters
%%       3rd dim (cell): subjects / flows / ...
%%       4th dim (vector): time series
%%   - cluster_affinity: vector
%%       c_i means the average affinity of cluster i
%%      
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [X_cluster, other_cluster, cluster_affinity] = do_cluster(X, cluster_opt, figbase, other_mat)
    addpath('/u/yichao/warp/git_repository/utils/spectral_cluster');

    DEBUG3 = 0;


    if nargin < 2, cluster_opt = ''; end
    if nargin < 3, figbase = ''; end
    if nargin < 4, other_mat = {}; end

    %% get options
    [method, num_cluster, head_type, merge, thresh, num_seg, sync, metric, sigma] = get_cluster_opt(cluster_opt);
    other_cluster = {};
    cluster_head = [];

    %% affinity matrix
    [affinity] = get_affinity(X, sync, metric, sigma);
    %%   replace Inf by max/min value
    inf_idx = isinf(affinity);
    idx = find(inf_idx & affinity > 0);
    max_val = max(affinity(~inf_idx));
    affinity(idx) = max_val(1);
    idx = find(inf_idx & affinity < 0);
    min_val = min(affinity(~inf_idx));
    affinity(idx) = min_val(1);


    if num_cluster == Inf
        %% ------------------
        %% no cluster
        cluster_idx = 1:length(X);
        cluster_head = 1:length(X);

    elseif num_cluster == 1
        %% ------------------
        %% 1 cluster
        cluster_idx = ones(1, length(X));

    else
        %% ------------------
        %% k-means
        if strcmp(method, 'kmeans')
            [cluster_idx, cluster_head, cluster_affinity] = my_kmeans(num_cluster, affinity);

        %% ------------------
        %% hierarchical clustering
        %%   XXX: only implement euclidean dist 
        elseif strcmp(method, 'hierarchical')
            dist = pdist(my_cell2mat(X));
            cluster_tree = linkage(dist);
            cluster_idx = cluster(cluster_tree, 'maxclust', num_cluster);

        %% ------------------
        %% spectral clustering
        elseif strcmp(method, 'spectral')
            cluster_idx = spectral_cluster(affinity, num_cluster);

        %% ------------------
        %% subspace clustering
        elseif strcmp(method, 'subspace')
            [cluster_idx, cluster_head, cluster_affinity] = subspace_cluster(X, num_cluster, sync, head_type);

        else
            error(['wrong method name: ' method])
        end
    end


    %% --------------------------
    %% find cluster head
    if length(cluster_head) == 0 | ~strcmp(head_type, 'best')
        
        for ci = 1:max(cluster_idx)
            idx = find(cluster_idx == ci);
            % tmp_X = {};
            % for ii = 1:length(idx)
            %     tmp_X{ii} = X{idx(ii)};
            % end
            % tmp_X = my_cell2mat(tmp_X);
            % if length(affinity) > 0
            %     tmp_affinity = affinity(idx, idx);
            % else
            %     tmp_affinity = [];
            % end
            tmp_affinity = affinity(idx, idx);

            [tmp_idx, tmp_aff] = select_head(head_type, tmp_affinity);
            cluster_head(ci) = idx(tmp_idx);
            cluster_affinity(ci) = tmp_aff;
        end
    end


    %% --------------------------
    %% merge cluster if necessary
    merge_opt = ['merge=''' merge ''',thresh=' num2str(thresh) ',head=''' head_type ''''];
    [cluster_members, cluster_head, cluster_affinity] = merge_cluster(cluster_idx, cluster_head, cluster_affinity, affinity, merge_opt);
    
    %% --------------------------
    %% cluster rows according to cluster_idx,
    %% and put the cluster head in the first place
    % for ci = 1:max(cluster_idx)
    %     idx = find(cluster_idx == ci);
    for ci = 1:length(cluster_members)
        idx = cluster_members{ci};
        cluster_sizes(ci) = length(idx);

        %% cluster head
        X_cluster{ci}{1} = X{cluster_head(ci)};
        for oi = 1:length(other_mat)
            other_cluster{oi}{ci}{1} = other_mat{oi}{cluster_head(ci)};
        end
        % idx = idx(idx ~= cluster_head(ci));
        idx = setxor(idx, cluster_head(ci));
        if DEBUG3, fprintf('  cluster %d head = %d\n', ci, cluster_head(ci)); end

        %% other member
        for iidx = 1:length(idx)

            X_cluster{ci}{iidx+1} = X{idx(iidx)};
            
            for oi = 1:length(other_mat)
                other_cluster{oi}{ci}{iidx+1} = other_mat{oi}{idx(iidx)};
            end
        end
        % size(X_cluster{ci})
    end


    %% --------------
    %% DEBUG
    if ~strcmp(figbase, '')
        plot_cluster_size(cluster_sizes, length(X), [figbase '.' cluster_opt '.clust_size']);
    end
end


%% get_dtw_opt: function description
function [method, num, head, merge, thresh, num_seg, sync, metric, sigma] = get_cluster_opt(opt)

    method  = 'kmeans';
    num     = 1;
    head    = 'rand';
    merge   = 'na';
    thresh  = 0;
    num_seg = 1;
    sync    = 'na';
    metric  = 'coeff';
    sigma   = 1;
    
    opts = regexp(opt, ',', 'split');
    for this_opt = opts
        eval([char(this_opt) ';']);
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