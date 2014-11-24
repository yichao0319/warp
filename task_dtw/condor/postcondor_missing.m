%% postcondor_warp: function description
function postcondor_missing()
    input_dir = '~/warp/condor_data/task_dtw/condor/do_missing_exp/';

    % , 'multi-ch-csi', 'blink'
    trace_names = {'abilene', 'geant', 'wifi', '3g', '1ch-csi', 'cister', 'cu', 'ucsb', 'umich', 'p300', '4sq'};
    % trace_names = {'ucsb'};


    % warp_methods = {'na' 'dtw', 'shift', 'stretch'};
    warp_methods = {'shift_limit'};
    warp_opt = 'num_seg=1';

    eval_opts = {'no_dup=1'};

    % cluster_methods = {'kmeans'};
    % num_clusters = [1];
    % cluster_methods = {'spectral_shift_cc'};
    % num_clusters = [0];
    cluster_methods = {'subspace'};
    num_clusters = [1000];

    
    rank_seg = 1;
    rank_percnetile = 0.8;
    rank_cluster_method = 1;
    rank_opt = ['percentile=' num2str(rank_percnetile) ',num_seg=' num2str(rank_seg) ',r_method=' num2str(rank_cluster_method)];

    elem_frac  = 1;
    loss_rates = [0.01 0.05 0.1 0.15 0.2];
    elem_mode  = 'elem';
    loss_mode  = 'ind';
    burst_size = 1;

    % init_esti_methods = {'na', 'lens'};
    init_esti_methods = {'na'};
    final_esti_methods = {'lens'};

    seeds = [1 2 3 4 5];


    %% plot bar: 
    %%   x axis: warp methods, group by estimation methods
    % arrange_bar_warp_group_by_esti(input_dir, './figs_missing/', trace_names, cluster_methods, num_clusters, warp_methods, warp_opt, rank_opt, elem_frac, loss_rates, elem_mode, loss_mode, burst_size, init_esti_methods, final_esti_methods, seeds, 'bar_warp_est');

    %% plot line: 
    %%   x axis: loss rates
    %%   lines: cluster method, w/ or w/o shift
    arrange_line_clust_warp(input_dir, './figs_missing/', trace_names, cluster_methods, num_clusters, warp_methods, warp_opt, rank_opt, elem_frac, loss_rates, elem_mode, loss_mode, burst_size, init_esti_methods, final_esti_methods, eval_opts, seeds, 'line_clust_warp');

end


%% get_trace_opt
function [trace_opt] = get_trace_opt(trace_name)
    if strcmp(trace_name, 'p300')
        trace_opt = 'subject=1,session=1,img_idx=0';
    elseif strcmp(trace_name, '4sq')
        trace_opt = 'num_loc=100,num_rep=1,loc_type=1';
    else
        trace_opt = 'na';
    end
end


%% get_results: function description
function [warp_mae_mean, warp_mae_std, orig_mae_mean, orig_mae_std] = get_results(basename, seeds)
    cnt = 0;
    for seed = seeds
        filename = [basename '.s' num2str(seed) '.txt'];
        if exist(filename) ~= 0
            cnt = cnt + 1;
            data = load(filename);

            ret(1, cnt) = data(1);  %% w/ warp
            ret(2, cnt) = data(2);  %% w/o warp
            % ret(3, cnt) = data(3);  %% w/o warp 2
            fprintf('  orig=%f, warp=%f\n', data(2), data(1));
        end
    end %% end seed

    if cnt > 0
        warp_mae_mean  = mean(ret(1,:));
        warp_mae_std   = std(ret(1,:));
        orig_mae_mean  = mean(ret(2,:));
        orig_mae_std   = std(ret(2,:));
        % orig_mae_mean2 = mean(ret(3,:));
        % orig_mae_std2  = std(ret(3,:));
    else
        warp_mae_mean  = 0;
        warp_mae_std   = 0;
        orig_mae_mean  = 0;
        orig_mae_std   = 0;
        % orig_mae_mean2 = 0;
        % orig_mae_std2  = 0;
    end

end



%% ------------------------------------------
%% plot line: 
%%   x axis: loss rates
%%   lines: cluster method, w/ or w/o shift
function arrange_line_clust_warp(input_dir, output_dir, trace_names, cluster_methods, num_clusters, warp_methods, warp_opt, rank_opt, elem_frac, loss_rates, elem_mode, loss_mode, burst_size, init_esti_methods, final_esti_methods, eval_opts, seeds, fig_prefix)
    
    for trace_name = trace_names
        trace_name = char(trace_name);
        trace_opt = get_trace_opt(trace_name);

        for eval_opt = eval_opts
            eval_opt = char(eval_opt);

            for init_esti_method = init_esti_methods
                init_esti_method = char(init_esti_method);
                for final_esti_method = final_esti_methods
                    final_esti_method = char(final_esti_method);

                    figname = [output_dir fig_prefix '.' trace_name '.' trace_opt '.' rank_opt '.elem' num2str(elem_frac) '.' elem_mode '.' loss_mode '.' num2str(burst_size) '.' init_esti_method '.' final_esti_method '.' eval_opt];
                    plot_line_clust_warp(input_dir, trace_name, trace_opt, cluster_methods, num_clusters, warp_methods, warp_opt, rank_opt, elem_frac, loss_rates, elem_mode, loss_mode, burst_size, init_esti_method, final_esti_method, eval_opt, seeds, figname);

                end
            end
        end
    end
end

%% plot_warp_rank: function description
function plot_line_clust_warp(input_dir, trace_name, trace_opt, cluster_methods, num_clusters, warp_methods, warp_opt, rank_opt, elem_frac, loss_rates, elem_mode, loss_mode, burst_size, init_esti_method, final_esti_method, eval_opt, seeds, figname)

    fh = figure; clf;
    font_size = 16;
    colors   = {'r', 'b', [0 0.8 0], 'm', [1 0.85 0], [0 0 0.47], [0.45 0.17 0.48], 'k'};
    lines    = {'-', '--', '-.', ':'};
    markers  = {'+', 'o', '*', '.', 'x', 's', 'd', '^', '>', '<', 'p', 'h'};


    line_cnt = 0;
    for cluster_method = cluster_methods
        cluster_method = char(cluster_method);
        for num_cluster = num_clusters
            for warp_method = warp_methods
                warp_method = char(warp_method);

                line_cnt = line_cnt + 1;

                for li = 1:length(loss_rates) 
                    loss_rate = loss_rates(li);

                    basename = [input_dir trace_name '.' trace_opt '.' rank_opt '.elem' num2str(elem_frac) '.lr' num2str(loss_rate) '.' elem_mode '.' loss_mode '.' num2str(burst_size) '.' init_esti_method '.' final_esti_method '.' cluster_method '.c' num2str(num_cluster) '.' warp_method '.' warp_opt '.' eval_opt];
                    fprintf([basename '\n']);
                    [warp_mae_mean, warp_mae_std, orig_mae_mean, orig_mae_std] = get_results(basename, seeds);
                    % fprintf('  orig=%f(%f), warp=%f(%f)\n', orig_mae_mean, orig_mae_std, warp_mae_mean, warp_mae_std);

                    num_compare = 2;
                    ret_mean((line_cnt-1)*num_compare+1, li) = orig_mae_mean;
                    ret_std((line_cnt-1)*num_compare+1, li)  = orig_mae_std;
                    legends{(line_cnt-1)*num_compare+1} = [cluster_method ',#' num2str(num_clusters) ',w/o ' warp_method];

                    % ret_mean((line_cnt-1)*num_compare+2, li) = orig_mae_mean2;
                    % ret_std((line_cnt-1)*num_compare+2, li)  = orig_mae_std2;
                    % legends{(line_cnt-1)*num_compare+2} = [cluster_method ',#' num2str(num_clusters) ',w/o ' warp_method ' 2'];

                    ret_mean((line_cnt-1)*num_compare+2, li) = warp_mae_mean;
                    ret_std((line_cnt-1)*num_compare+2, li)  = warp_mae_std;
                    legends{(line_cnt-1)*num_compare+2} = [cluster_method ',#' num2str(num_clusters) ',w/ ' warp_method];
                end
            end 
        end
    end


    %% line
    for li = 1:size(ret_mean, 1)
        % lh{li} = plot(loss_rates, ret(li, :));
        lh{li} = errorbar(loss_rates, ret_mean(li, :), ret_std(li, :));
        set(lh{li}, 'Color', colors{mod(li-1,length(colors))+1});
        set(lh{li}, 'LineStyle', lines{mod(li-1,length(lines))+1});
        set(lh{li}, 'LineWidth', 2);
        set(lh{li}, 'marker', markers{mod(li-1,length(markers))+1});
        set(lh{li}, 'MarkerSize', 10);
        hold on;
    end

    set(gca, 'FontSize', font_size);
    xlabel('loss rates', 'FontSize', font_size);
    ylabel('MAE', 'FontSize', font_size);

    ytics = get(gca, 'YTick');
    max_y = max(ytics) * 1.3;
    set(gca, 'YLim', [0 max_y]);
    legend(legends, 'Interpreter', 'none', 'Location', 'NorthEast');

    % set(gca, 'OuterPosition', [LEFT BOTTOM WIDTH HEIGHT]);  %% normalized value, [0 0 1 1] in default
    % set(gca, 'Position', [0.1 0.2 0.7 0.75]);

    print(fh, '-depsc', [figname '.eps']);
end
%% END plot line
%% ------------------------------------------


%% ------------------------------------------
%% plot bar: 
%%   x axis: warp methods, group by estimation methods
function arrange_bar_warp_group_by_esti(input_dir, output_dir, trace_names, cluster_methods, num_clusters, warp_methods, warp_opt, rank_opt, elem_frac, loss_rates, elem_mode, loss_mode, burst_size, init_esti_methods, final_esti_methods, seeds, fig_prefix)
    
    for loss_rate = loss_rates
        for trace_name = trace_names
            trace_name = char(trace_name);
            trace_opt = get_trace_opt(trace_name);

            for cluster_method = cluster_methods
                cluster_method = char(cluster_method);
                for num_cluster = num_clusters

                    figname = [output_dir fig_prefix '.' trace_name '.' trace_opt '.' cluster_method '.' num2str(num_cluster) '.' rank_opt '.elem' num2str(elem_frac) '.lr' num2str(loss_rate) '.' elem_mode '.' loss_mode '.' num2str(burst_size)];
                    plot_bar_warp_group_by_esti(input_dir, trace_name, trace_opt, cluster_method, num_cluster, warp_methods, warp_opt, rank_opt, elem_frac, loss_rate, elem_mode, loss_mode, burst_size, init_esti_methods, final_esti_methods, seeds, figname);

                end
            end %% end cluster method
        end
    end
end


%% plot_warp_rank: function description
function plot_bar_warp_group_by_esti(input_dir, trace_name, trace_opt, cluster_method, num_cluster, warp_methods, warp_opt, rank_opt, elem_frac, loss_rate, elem_mode, loss_mode, burst_size, init_esti_methods, final_esti_methods, seeds, figname)

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

                warp_mae = 0;
                orig_mae = 0;
                cnt = 0;
                for seed = seeds
                    filename = [input_dir trace_name '.' trace_opt '.' cluster_method '.c' num2str(num_cluster) '.' warp_method '.' warp_opt '.' rank_opt '.elem' num2str(elem_frac) '.lr' num2str(loss_rate) '.' elem_mode '.' loss_mode '.' num2str(burst_size) '.' init_esti_method '.' final_esti_method '.s' num2str(seed) '.txt'];
                    if exist(filename) == 0
                        %% no such file
                        warp_mae = warp_mae + 0;
                        orig_mae = orig_mae + 0;
                    else
                        cnt = cnt + 1;
                        data = load(filename);
                        warp_mae = warp_mae + data(1);
                        orig_mae = orig_mae + data(2);
                    end
                end %% end seed

                if cnt > 0
                    warp_mae = warp_mae / cnt;
                    orig_mae = orig_mae / cnt;
                else
                    warp_mae = 0;
                    orig_mae = 0;
                end

                warp_maes(est_meth_cnt, warp_meth_cnt) = warp_mae;
                orig_maes(est_meth_cnt, warp_meth_cnt) = orig_mae;

            end %% end warp method

        end %% end final esti method
    end %% end init esti method

    orig_maes = mean(orig_maes, 2);
    
    %% bar
    bh1 = bar([orig_maes, warp_maes]);
    set(bh1, 'BarWidth', 0.6);

    set(gca, 'FontSize', font_size);
    ylabel('MAE', 'FontSize', font_size);

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

    legends{1} = 'orig';
    for wi = 1:length(warp_methods)
        legends{wi+1} = warp_methods{wi};
    end
    legend(legends);

    % set(gca, 'OuterPosition', [LEFT BOTTOM WIDTH HEIGHT]);  %% normalized value, [0 0 1 1] in default
    % set(gca, 'Position', [0.1 0.2 0.7 0.75]);


    print(fh, '-depsc', [figname '.eps']);
end
%% END plot bar: x axis: warp methods, group by estimation methods
%% ------------------------------------------

