%% postcondor_warp: function description
function postcondor_missing()
    input_dir = '~/warp/condor_data/task_miss/condor/do_missing_exp/';
    % input_dir = '~/warp/condor_data/task_miss/condor/bak.do_missing_exp.1202.kmeans.top1_cluster/';
    %% trace
    % , 'multi-ch-csi', 'blink'
    % trace_names = {'abilene', 'geant', 'wifi', '3g', '1ch-csi', 'cister', 'cu', 'ucsb', 'umich', 'p300', '4sq'};
    trace_names = {'geant', '3g', '4sq'};


    %% dropping elements
    elem_frac  = 1;
    loss_rates = [0.05 0.1 0.15 0.2];
    elem_mode  = 'elem';
    loss_mode  = 'ind';
    burst_size = 1;


    %% cluster
    % cluster_methods = {'subspace', 'spectral'};
    % cluster_methods = {'spectral'};
    cluster_methods = {'kmeans'};
    % num_clusters=(0 5000)
    % head_types = {'best', 'random', 'worst'};
    head_types = {'best'};
    sync_type = 'shift';
    % metric_types = {'graph', 'coef'};
    metric_types = {'coef'};
    % sigmas = [1];



    %% warp
    % warp_methods = {'na' 'dtw', 'shift', 'shift_limit', 'stretch'};
    warp_methods = {'shift_limit'};
    warp_opt = 'num_seg=1';


    %% evaluation
    eval_opts = {'no_dup=1'};


    %% rank
    rank_seg = 1;
    rank_percnetile = 0.8;
    rank_cluster_method = 1;
    rank_opt = ['percentile=' num2str(rank_percnetile) ',num_seg=' num2str(rank_seg) ',r_method=' num2str(rank_cluster_method)];


    % init_esti_methods = {'na', 'lens'};
    init_esti_methods = {'na'};
    final_esti_methods = {'lens'};

    seeds = [1 2 3 4 5];


    %% plot line: 
    %%   x axis: loss rates
    %%   lines: interpolation methods
    compare_line_interpolation_method(input_dir, './figs_missing/', trace_names, rank_opt, elem_frac, loss_rates, elem_mode, loss_mode, burst_size, init_esti_methods, final_esti_methods, cluster_methods, head_types, sync_type, metric_types, warp_methods, warp_opt, eval_opts, seeds, 'line_interp_method');

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
function [mae_mean, mae_std] = get_results(input_dir, trace_name, trace_opt, rank_opt, elem_frac, loss_rate, elem_mode, loss_mode, burst_size, init_esti_method, final_esti_method, cluster_method, cluster_opt, warp_method, warp_opt, eval_opt, seeds)

    cnt = 0;
    basename = [input_dir trace_name '.' trace_opt '.' rank_opt '.elem' num2str(elem_frac) '.lr' num2str(loss_rate) '.' elem_mode '.' loss_mode '.' num2str(burst_size) '.' init_esti_method '.' final_esti_method '.' cluster_method '.' cluster_opt '.' warp_method '.' warp_opt '.' eval_opt];
    fprintf('%s\n', basename);

    for seed = seeds
        filename = [basename '.s' num2str(seed) '.txt'];
        
        if exist(filename) ~= 0
            cnt = cnt + 1;
            data = load(filename);

            ret(:, cnt) = data';
            fprintf('  ');
            fprintf('%f,', data);
            fprintf('\n');
        end
    end %% end seed

    if cnt > 1
        for mi = 1:size(ret,1)
            tmp = ret(mi,:); tmp = tmp(tmp~=max(tmp));
            mae_mean(mi)  = mean(tmp);
            mae_std(mi)   = std(tmp);
        end
    elseif cnt > 0
        for mi = 1:size(ret,1)
            tmp = ret(mi,:);
            mae_mean(mi)  = mean(tmp);
            mae_std(mi)   = std(tmp);
        end
    else
        mae_mean  = [];
        mae_std   = [];
    end

end


%% ------------------------------------------
%% compare interpolation method
function compare_line_interpolation_method(input_dir, output_dir, trace_names, rank_opt, elem_frac, loss_rates, elem_mode, loss_mode, burst_size, init_esti_methods, final_esti_methods, cluster_methods, head_types, sync_type, metric_types, warp_methods, warp_opt, eval_opts, seeds, fig_prefix)

    
    for trace_name = trace_names
        trace_name = char(trace_name);
        trace_opt = get_trace_opt(trace_name);

        for cluster_method = cluster_methods
            cluster_method = char(cluster_method);

            if strcmp(cluster_method, 'subspace')
                num_clusters = [5000];
            elseif strcmp(cluster_method, 'spectral')
                num_clusters = [-1];
            else
                num_clusters = [2 3 5 10];
            end
                
            for num_cluster = num_clusters
                for head_type = head_types
                    head_type = char(head_type);
                    for metric_type = metric_types
                        metric_type = char(metric_type);

                        if strcmp(metric_type, 'graph')
                            sigmas = [1 10 100];
                        else
                            sigmas = [1];
                        end

                        for sigma = sigmas
                    
                            cluster_opt = ['num_cluster=' num2str(num_cluster) ',head_type=''' head_type ''',sync_type=''' sync_type ''',metric_type=''' metric_type ''',sigma=' num2str(sigma)];

                            for warp_method = warp_methods
                                warp_method = char(warp_method);
                            
                                for eval_opt = eval_opts
                                    eval_opt = char(eval_opt);

                                    for init_esti_method = init_esti_methods
                                        init_esti_method = char(init_esti_method);
                                        for final_esti_method = final_esti_methods
                                            final_esti_method = char(final_esti_method);

                                            figname = [output_dir fig_prefix '.' trace_name '.' trace_opt '.' rank_opt '.elem' num2str(elem_frac) '.' elem_mode '.' loss_mode '.' num2str(burst_size) '.' init_esti_method '.' final_esti_method '.' cluster_method '.' cluster_opt '.' warp_method '.' warp_opt '.' eval_opt];
                                            plot_line_interpolation_method(input_dir, trace_name, trace_opt, rank_opt, elem_frac, loss_rates, elem_mode, loss_mode, burst_size, init_esti_method, final_esti_method, cluster_method, cluster_opt, warp_method, warp_opt, eval_opt, seeds, figname);

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
end


%% plot_line_interpolation_method
function plot_line_interpolation_method(input_dir, trace_name, trace_opt, rank_opt, elem_frac, loss_rates, elem_mode, loss_mode, burst_size, init_esti_method, final_esti_method, cluster_method, cluster_opt, warp_method, warp_opt, eval_opt, seeds, figname)

    num_lines = 2;

    fh = figure; clf;
    font_size = 16;
    colors   = {'r', 'b', [0 0.8 0], 'm', [1 0.85 0], [0 0 0.47], [0.45 0.17 0.48], 'k'};
    lines    = {'-', '--', '-.'};
    markers  = {'+', 'o', '*', '.', 'x', 's', 'd', '^', '>', '<', 'p', 'h'};


    % select_line = [7:-1:1];
    % legends = {'knn', 'SRMF+KNN', 'SRMF', 'SVD base+KNN', 'SVD base', ['LENS w/o ' warp_method], ['LENS w/ ' warp_method]};
    % select_line = [3 5 2 1];
    % legends = {'SVD base', 'SRMF', ['LENS w/o ' warp_method], ['LENS w/ ' warp_method]};
    % select_line = [5 2 1];
    % legends = {'SRMF', ['LENS w/o ' warp_method], ['LENS w/ ' warp_method]};
    select_line = [2 1];
    legends = {['LENS w/o ' warp_method], ['LENS w/ ' warp_method]};

    ret_mean = zeros(num_lines, length(loss_rates));
    ret_std  = zeros(num_lines, length(loss_rates));
    for li = 1:length(loss_rates)
        loss_rate = loss_rates(li);
        
        [mae_mean, mae_std] = get_results(input_dir, trace_name, trace_opt, rank_opt, elem_frac, loss_rate, elem_mode, loss_mode, burst_size, init_esti_method, final_esti_method, cluster_method, cluster_opt, warp_method, warp_opt, eval_opt, seeds);
        if(length(mae_mean) > 0)
            ret_mean(:, li) = mae_mean;
            ret_std(:, li) = mae_std;
        else
            ret_mean(:, li) = 0;
            ret_std(:, li) = 0;
        end
    end

    ret_mean = ret_mean(select_line, :);
    ret_std = ret_std(select_line, :);


    %% line
    for li = 1:length(select_line)
        lh{li} = plot(loss_rates, ret_mean(li, :));
        % lh{li} = errorbar(loss_rates, ret_mean(li, :), ret_std(li, :));
        set(lh{li}, 'Color', colors{mod(li-1,length(colors))+1});
        set(lh{li}, 'LineStyle', lines{mod(li-1,length(lines))+1});
        set(lh{li}, 'LineWidth', 2);
        set(lh{li}, 'marker', markers{mod(li-1,length(markers))+1});
        set(lh{li}, 'MarkerSize', 10);
        hold on;
    end

    set(gca, 'FontSize', font_size);
    xlabel('loss rates', 'FontSize', font_size);
    ylabel('NMAE', 'FontSize', font_size);

    ytics = get(gca, 'YTick');
    max_y = max(ytics) * 1.3;
    set(gca, 'YLim', [0 max_y]);
    legend(legends, 'Interpreter', 'none', 'Location', 'NorthEast');

    % set(gca, 'OuterPosition', [LEFT BOTTOM WIDTH HEIGHT]);  %% normalized value, [0 0 1 1] in default
    % set(gca, 'Position', [0.1 0.2 0.7 0.75]);

    print(fh, '-depsc', [figname '.eps']);

end
%% END compare interpolation method
%% ------------------------------------------
    
