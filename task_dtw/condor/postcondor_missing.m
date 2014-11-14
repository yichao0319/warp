%% postcondor_warp: function description
function postcondor_missing()
    input_dir = '~/warp/condor_data/task_dtw/condor/do_missing_exp/';

    trace_names = {'abilene', 'geant', 'wifi', '3g', '1ch-csi', 'cister', 'cu', 'multi-ch-csi', 'ucsb', 'umich', 'test_sine_shift', 'test_sine_scale', 'p300', '4sq'};

    warp_methods = {'na' 'dtw', 'shift', 'stretch'};
    warp_opt = 'num_seg=1';

    cluster_methods = {'kmeans'};
    num_clusters = [1];
    
    rank_seg = 1;
    rank_percnetile = 0.8;
    rank_cluster_method = 1;
    rank_opt = ['percentile=' num2str(rank_percnetile) ',num_seg=' num2str(rank_seg) ',r_method=' num2str(rank_cluster_method)];

    elem_frac  = 1;
    loss_rate  = 0.1;
    elem_mode  = 'elem';
    loss_mode  = 'ind';
    burst_size = 1;

    init_esti_methods = {'na', 'lens'};
    final_esti_methods = {'lens'};

    seeds = [1];


    for trace_name = trace_names
        trace_name = char(trace_name);

        if strcmp(trace_name, 'p300')
            trace_opt = 'subject=1,session=1,img_idx=0';
        elseif strcmp(trace_name, '4sq')
            trace_opt = 'num_loc=100,num_rep=1,loc_type=1';
        else
            trace_opt = 'na';
        end

        
        for cluster_method = cluster_methods
            cluster_method = char(cluster_method);
            for num_cluster = num_clusters

                plot_missing_mae(input_dir, trace_name, trace_opt, cluster_method, num_cluster, warp_methods, warp_opt, rank_opt, elem_frac, loss_rate, elem_mode, loss_mode, burst_size, init_esti_methods, final_esti_methods, seeds, ['./figs_missing/' trace_name '.' trace_opt '.' cluster_method '.' num2str(num_cluster) '.' rank_opt '.elem' num2str(elem_frac) '.lr' num2str(loss_rate) '.' elem_mode '.' loss_mode '.' num2str(burst_size)]);

            end
        end %% end cluster method
    end
end


%% plot_warp_rank: function description
function plot_missing_mae(input_dir, trace_name, trace_opt, cluster_method, num_cluster, warp_methods, warp_opt, rank_opt, elem_frac, loss_rate, elem_mode, loss_mode, burst_size, init_esti_methods, final_esti_methods, seeds, figname)

    fh = figure; clf;
    font_size = 16;
    colors   = {'r', 'b', [0 0.8 0], 'm', [1 0.85 0], [0 0 0.47], [0.45 0.17 0.48], 'k'};
    lines    = {'-', '--', '-.', ':'};
    markers  = {'+', 'o', '*', '.', 'x', 's', 'd', '^', '>', '<', 'p', 'h'};


    est_meth_cnt = 0;
    for init_esti_method = init_esti_methods
        init_esti_method = char(init_esti_method);
        for final_esti_method = final_esti_methods
            final_esti_method = char(final_esti_method);

            est_meth_cnt = est_meth_cnt + 1;
            x_ticks{est_meth_cnt} = ['Before:' init_esti_method ';After:' final_esti_method];
            warp_meth_cnt = 0;

            for warp_method = warp_methods
                warp_method = char(warp_method);

                warp_meth_cnt = warp_meth_cnt + 1;

                ret = 0;
                cnt = 0;
                for seed = seeds
                    filename = [input_dir trace_name '.' trace_opt '.' cluster_method '.c' num2str(num_cluster) '.' warp_method '.' warp_opt '.' rank_opt '.elem' num2str(elem_frac) '.lr' num2str(loss_rate) '.' elem_mode '.' loss_mode '.' num2str(burst_size) '.' init_esti_method '.' final_esti_method '.s' num2str(seed) '.txt'];
                    if exist(filename) == 0
                        %% no such file
                        ret = ret + 0;
                    else
                        cnt = cnt + 1;
                        ret = ret + load(filename);
                    end
                end %% end seed

                if cnt > 0
                    ret = ret / cnt;
                else
                    ret = 0;
                end

                maes(est_meth_cnt, warp_meth_cnt) = ret;

            end %% end warp method

        end %% end final esti method
    end %% end init esti method

    
    %% bar
    bh1 = bar(maes);
    set(bh1, 'BarWidth', 0.6);

    set(gca, 'FontSize', font_size);
    ylabel('rank', 'FontSize', font_size);

    set(gca, 'XTick', [1:est_meth_cnt]);
    %% rotate x tick
    set(gca, 'XTickLabel', ' ');
    ytics = get(gca, 'YTick');
    max_y = max(ytics) * 1.3;
    set(gca, 'YLim', [0 max_y]);
    y = repmat(0, length(x_ticks), 1) - max_y/50;
    fs = get(gca, 'fontsize');
    hText = text([1:est_meth_cnt], y, x_ticks, 'fontsize', fs);
    
    set(hText, 'Rotation', 0, 'HorizontalAlignment', 'left');
    legend(warp_methods);

    % set(gca, 'OuterPosition', [LEFT BOTTOM WIDTH HEIGHT]);  %% normalized value, [0 0 1 1] in default
    % set(gca, 'Position', [0.1 0.2 0.7 0.75]);


    print(fh, '-depsc', [figname '.eps']);
end

