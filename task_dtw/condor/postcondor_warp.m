%% postcondor_warp: function description
function postcondor_warp()
    input_dir = '~/warp/condor_data/task_dtw/condor/do_exp/';

    warp_methods = {'dtw', 'shift', 'stretch'};
    warp_opt = 'num_seg=1';
    cluster_methods = {'kmeans', 'hierarchical', 'hier_affinity', 'kmeans_affinity'};
    num_clusters = [Inf 1 5];
    rank_seg = 1;
    rank_percnetile = 0.8;
    % rank_cluster_methods = [1 2];
    rank_cluster_methods = [1];


    %% =================================
    %% 4sq
    trace_name = '4sq';
    trace_opts = {'loc_type=4', 'num_loc=100,num_rep=1,loc_type=1', 'num_loc=10,num_rep=1,loc_type=1'};

    for toi = 1:length(trace_opts)
        trace_opt = char(trace_opts(toi));
        for ci = 1:length(cluster_methods)
            cluster_method = char(cluster_methods{ci});

            plot_warp_rank(input_dir, trace_name, trace_opt, cluster_method, num_clusters, warp_methods, rank_seg, rank_percnetile, rank_cluster_methods, warp_opt, ['./figs/' trace_name '.' trace_opt '.' cluster_method '.r' num2str(rank_seg) '.' num2str(rank_percnetile)]);
        end
    end
    % return

    %% =================================
    %% p300
    trace_name = 'p300';
    subjects = [1 6];
    sessions = [1];
    img_idces = [0 7 2];

    for subject = subjects
        for session = sessions
            for img_idx = img_idces
                for ci = 1:length(cluster_methods)
                    cluster_method = char(cluster_methods{ci});

                    trace_opt = ['subject=' num2str(subject) ',session=' num2str(session) ',img_idx=' num2str(img_idx)];

                    plot_warp_rank(input_dir, trace_name, trace_opt, cluster_method, num_clusters, warp_methods, rank_seg, rank_percnetile, rank_cluster_methods, warp_opt, ['./figs/' trace_name '.' trace_opt '.' cluster_method '.r' num2str(rank_seg) '.' num2str(rank_percnetile)]);
                end
            end
        end
    end


    %% =================================
    %% other traces
    trace_names = {'abilene', 'geant', 'wifi', '3g', '1ch-csi', 'cister', 'cu', 'multi-ch-csi', 'ucsb', 'umich', 'test_sine_shift', 'test_sine_scale'};
    trace_opt = 'na';

    for trace_name = trace_names
        trace_name = char(trace_name);

        for ci = 1:length(cluster_methods)
            cluster_method = char(cluster_methods{ci});

            plot_warp_rank(input_dir, trace_name, trace_opt, cluster_method, num_clusters, warp_methods, rank_seg, rank_percnetile, rank_cluster_methods, warp_opt, ['./figs/' trace_name '.' trace_opt '.' cluster_method '.r' num2str(rank_seg) '.' num2str(rank_percnetile)]);
        end
    end
end


%% plot_warp_rank: function description
function plot_warp_rank(input_dir, trace_name, trace_opt, cluster_method, num_clusters, warp_methods, rank_seg, rank_percnetile, rank_cluster_methods, warp_opt, figname);

    fh = figure; clf;
    font_size = 16;
    colors   = {'r', 'b', [0 0.8 0], 'm', [1 0.85 0], [0 0 0.47], [0.45 0.17 0.48], 'k'};
    lines    = {'-', '--', '-.', ':'};
    markers  = {'+', 'o', '*', '.', 'x', 's', 'd', '^', '>', '<', 'p', 'h'};


    
    bc = 0;
    ranks = [];
    for nci = 1:length(num_clusters)
        num_cluster = num_clusters(nci);

        for rci = 1:length(rank_cluster_methods)
            rank_cluster_method = rank_cluster_methods(rci);

            if (isinf(num_cluster) || num_cluster == 1) && (rank_cluster_method > 1), continue; end
            rank_opt = ['percentile=' num2str(rank_percnetile) ',num_seg=' num2str(rank_seg) ',r_method=' num2str(rank_cluster_method)];

            for wmi = 1:length(warp_methods)
                warp_method = char(warp_methods(wmi));

                if isinf(num_cluster) && (wmi > 1), continue; end
                if isinf(num_cluster) || num_cluster == 1, 
                    this_cluster_method = 'kmeans';
                else
                    this_cluster_method = cluster_method;
                end

                bc = bc + 1;

                filename = [input_dir trace_name '.' trace_opt '.' this_cluster_method '.c' num2str(num_cluster) '.' warp_method '.' warp_opt '.' rank_opt '.txt'];
                if exist(filename) == 0
                    ranks(bc) = 0;
                    legends{bc} = [warp_method ',#clust=' num2str(num_cluster) '[X],r meth=' num2str(rank_cluster_method)];
                else
                    ranks(bc) = load(filename);
                    legends{bc} = [warp_method ',#clust=' num2str(num_cluster) ',r meth=' num2str(rank_cluster_method)];
                end

                if isinf(num_cluster)
                    legends{bc} = 'orig';
                    base_r = ranks(bc);
                else
                    improve = (base_r - ranks(bc)) / base_r;
                    fprintf([trace_name ',' trace_opt ',' warp_method ',#clust=' num2str(num_cluster) ':' num2str(improve) '\n']);
                end
            end
        end
    end

    %% bar
    bh1 = bar(ranks);
    set(bh1, 'BarWidth', 0.6);

    set(gca, 'FontSize', font_size);
    ylabel('rank', 'FontSize', font_size);

    set(gca, 'XTick', [1:bc]);
    %% rotate x tick
    set(gca, 'XTickLabel', ' ');
    ytics = get(gca, 'YTick');
    y = repmat(0, length(legends), 1) - max(ytics)/50;
    fs = get(gca, 'fontsize');
    hText = text(1:bc, y, legends, 'fontsize', fs);
    set(hText, 'Rotation', -20, 'HorizontalAlignment', 'left');

    % set(gca, 'OuterPosition', [LEFT BOTTOM WIDTH HEIGHT]);  %% normalized value, [0 0 1 1] in default
    set(gca, 'Position', [0.1 0.2 0.7 0.75]);


    print(fh, '-depsc', [figname '.eps']);
end

