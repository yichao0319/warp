%% postcondor_warp: function description
function postcondor_rank()
    input_dir = '~/warp/condor_data/task_miss/condor/do_exp/';
    
    %% trace
    % , 'multi-ch-csi', 'blink'
    trace_names = {'abilene' 'geant' 'wifi' '3g' '1ch-csi' 'cister' 'cu' 'ucsb' 'umich' 'p300' '4sq' 'deap' 'muse' 'multi-ch-csi'};
    % trace_names = {'muse' 'p300' 'deap' 'wifi' '1ch-csi' 'abilene' 'umich' 'cister' 'multi-ch-csi'};
    % trace_names = {'geant', '3g', '4sq'};
    % trace_names = {'multi-ch-csi'};


    %% sync
    sync_methods = {'shift'};
    metrics = {'coeff'};
    num_seg = 1;


    %% cluster
    cluster_methods = {'kmeans'};


    %% rank
    percentile = 0.8;
    num_seg = 1;
    r_method = 1;
    rank_opt = ['percentile=' num2str(percentile) ',num_seg=' num2str(num_seg) ',r_method=' num2str(r_method)];

    seeds = [1:5];


    %% plot bar: 
    %%   ranks
    compare_bar_ranks(input_dir, './figs/', trace_names, sync_methods, metrics, num_seg, cluster_methods, rank_opt, seeds, 'bar_ranks');

end


%% get_trace_opt
function [trace_opt, num_clusters, head_types, merges] = get_opt(trace_name)
    if strcmp(trace_name, 'p300')
        trace_opt = 'subject=1,session=1,img_idx=0';
        num_clusters = [4];
        head_types = {'best'};
        merges = {'num'};
    elseif strcmp(trace_name, '4sq')
        trace_opt = 'num_loc=100,num_rep=1,loc_type=1';
        num_clusters = [1];
        head_types = {'best'};
        merges = {'num'};
    elseif strcmp(trace_name, 'deap')
        trace_opt = 'video=1';
        num_clusters = [8];
        head_types = {'best'};
        merges = {'num'};
    elseif strcmp(trace_name, 'muse')
        trace_opt = 'muse=''4ch''';
        num_clusters = [4];
        head_types = {'best'};
        merges = {'top'};
    elseif strcmp(trace_name, 'multi-ch-csi')
        trace_opt = 'na';
        num_clusters = [2];
        head_types = {'best'};
        merges = {'num'};
    elseif strcmp(trace_name, 'abilene')
        trace_opt = 'na';
        num_clusters = [2];
        head_types = {'best'};
        merges = {'top'};
    elseif strcmp(trace_name, '1ch-csi')
        trace_opt = 'na';
        num_clusters = [1];
        head_types = {'best'};
        merges = {'num'};
    elseif strcmp(trace_name, '3g')
        trace_opt = 'na';
        num_clusters = [1];
        head_types = {'best'};
        merges = {'num'};
    elseif strcmp(trace_name, 'cister')
        trace_opt = 'na';
        num_clusters = [8];
        head_types = {'best'};
        merges = {'top'};
    elseif strcmp(trace_name, 'cu')
        trace_opt = 'na';
        num_clusters = [8];
        head_types = {'best'};
        merges = {'num'};
    elseif strcmp(trace_name, 'geant')
        trace_opt = 'na';
        num_clusters = [8];
        head_types = {'best'};
        merges = {'num'};
    elseif strcmp(trace_name, 'ucsb')
        trace_opt = 'na';
        num_clusters = [4];
        head_types = {'best'};
        merges = {'num'};
    elseif strcmp(trace_name, 'umich')
        trace_opt = 'na';
        num_clusters = [1];
        head_types = {'best'};
        merges = {'num'};
    elseif strcmp(trace_name, 'wifi')
        trace_opt = 'na';
        num_clusters = [2];
        head_types = {'worst'};
        merges = {'num'};
    end
end


%% get_results: function description
function [r_syncs, r_entires, r_subs, r_orig_entires, r_orig_subs] = get_results(input_dir, trace_name, trace_opt, sync_opt, cluster_opt, rank_opt, seeds)

    cnt = 0;
    basename = [input_dir trace_name '.' trace_opt '.' sync_opt '.' cluster_opt '.' rank_opt];
    fprintf('%s\n', basename);

    r_syncs = [];
    r_entires = [];
    r_subs = [];
    r_orig_entires = [];
    r_orig_subs = [];

    for seed = seeds
        filename = [basename '.' num2str(seed) '.txt'];
        
        if exist(filename) ~= 0
            cnt = cnt + 1;
            fid = fopen(filename, 'r');
            r_sync = fscanf(fid, '%f', [1, 1]);
            r_entire = fscanf(fid, '%f', [1, 1]);
            n1 = fscanf(fid, '%d', [1, 1]);
            r_sub = fscanf(fid, '%f,', [1, n1]);
            r_orig_entire = fscanf(fid, '%f', [1, 1]);
            n2 = fscanf(fid, '%d', [1, 1]);
            r_orig_sub = fscanf(fid, '%f,', [1, n2]);
            fclose(fid);

            r_syncs = [r_syncs, r_sync];
            r_entires = [r_entires, r_entire];
            r_subs = [r_subs, r_sub];
            r_orig_entires = [r_orig_entires, r_orig_entire];
            r_orig_subs = [r_orig_subs, r_orig_sub];

            fprintf('  r_sync = %f\n', r_sync);
            fprintf('  r_sub  = %f\n', mean(r_sub));
        end
    end %% end seed

end



%% ------------------------------------------
%% compare ranks
function compare_bar_ranks(input_dir, output_dir, trace_names, sync_methods, metrics, num_seg, cluster_methods, rank_opt, seeds, fig_prefix)

    
    for trace_name = trace_names
        trace_name = char(trace_name);
        [trace_opt, num_clusters, head_types, merges] = get_opt(trace_name);

        for sync_method = sync_methods
            sync_method = char(sync_method);

            for metric = metrics
                metric = char(metric);

                if strcmp(metric, 'graph')
                    sigmas = [1, 10, 100];
                else
                    sigmas = [1];
                end
                
                for sigma = sigmas

                    sync_opt = ['sync=''' sync_method ''',metric=''' metric ''',num_seg=' num2str(num_seg) ',sigma=' num2str(sigma)];
                    
                    for cluster_method = cluster_methods
                        cluster_method = char(cluster_method);
                        for num_cluster = num_clusters
                            for head_type = head_types
                                head_type = char(head_type);
                                for merge = merges
                                    merge = char(merge);

                                    if strcmp(merge, 'num')
                                        threshs = [30];
                                    elseif strcmp(merge, 'sim')
                                        threshs = [0.5];
                                    elseif strcmp(merge, 'top')
                                        threshs = [1];
                                    elseif strcmp(merge, 'na')
                                        threshs = [0];
                                    else
                                        threshs = [0];
                                    end

                                    for thresh = threshs

                                        cluster_opt = ['method=''' cluster_method ''',num=' num2str(num_cluster) ',head=''' head_type ''',merge=''' merge ''',thresh=' num2str(thresh)];

                                        figname = [output_dir fig_prefix '.' trace_name '.' trace_opt '.' sync_opt '.' cluster_opt '.' rank_opt];
                                        plot_bar_ranks(input_dir, trace_name, trace_opt, sync_opt, cluster_opt, rank_opt, seeds, figname);
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end


%% plot_line_interpolation_method
function plot_bar_ranks(input_dir, trace_name, trace_opt, sync_opt, cluster_opt, rank_opt, seeds, figname)

    fh = figure; clf;
    font_size = 16;
    colors   = {'r', 'b', [0 0.8 0], 'm', [1 0.85 0], [0 0 0.47], [0.45 0.17 0.48], 'k'};
    lines    = {'-', '--', '-.'};
    markers  = {'+', 'o', '*', '.', 'x', 's', 'd', '^', '>', '<', 'p', 'h'};

    [r_syncs, r_entires, r_subs, r_orig_entires, r_orig_subs] = get_results(input_dir, trace_name, trace_opt, sync_opt, cluster_opt, rank_opt, seeds);

    if length(r_syncs) == 0
        return;
    end

    % data = [mean(r_orig_subs), mean(r_subs), mean(r_syncs)];
    % data_err = [std(r_orig_subs), std(r_subs), std(r_syncs)];
    % labels = 'orig|rand shift|sync';
    data = [mean(r_subs), mean(r_syncs)];
    data_err = [std(r_subs), std(r_syncs)];
    labels = 'rand shift|sync';

    bh = bar(data);
    set(bh, 'BarWidth', 0.6);
    set(bh, 'EdgeColor', 'none');  %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
    set(bh, 'FaceColor', 'b');
    set(bh, 'LineStyle', '-');  %% line  : -|--|:|-.
    set(bh, 'LineWidth', 1);
    hold on;

    eh = errorbar(data, data_err);
    set(eh, 'LineStyle', 'none');  %% line  : -|--|:|-.
    set(eh, 'LineWidth', 2);
    set(eh, 'Color', 'r');
    hold on;

    set(gca, 'FontSize', font_size);
    ylabel('Rank', 'FontSize', font_size);
    set(gca, 'XTickLabel', labels);

    print(fh, '-depsc', [figname '.eps']);

end

%% END compare ranks
%% ------------------------------------------
    
