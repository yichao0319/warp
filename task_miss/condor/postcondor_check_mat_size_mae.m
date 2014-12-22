%% postcondor_warp: function description
function postcondor_missing()
    input_dir = '~/warp/condor_data/task_miss/condor/check_mat_size_mae/';

    trace_names = {'abilene', 'geant', 'wifi', '3g', '1ch-csi', 'cister', 'cu', 'multi-ch-csi', 'ucsb', 'umich', 'test_sine_shift', 'test_sine_scale', 'p300', '4sq', 'blink'};

    elem_frac  = 1;
    loss_rates = [0.01 0.05 0.1 0.15 0.2 0.4];
    elem_mode  = 'elem';
    loss_mode  = 'ind';
    burst_size = 1;

    submatrix_ratios = [0.1:0.2:0.9];

    seeds = [1 2 3 4 5];


    %% plot line: 
    %%   x axis: sub-matrix ratio
    %%   lines: mae using entire matrix or portion matrix
    arrange_line_subratio(input_dir, './figs_mat_size_mae/', trace_names, elem_frac, loss_rates, elem_mode, loss_mode, burst_size, submatrix_ratios, seeds, 'line_subratio');

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
function [mae1_mean, mae1_std, mae2_mean, mae2_std] = get_results(basename, seeds)
    cnt = 0;
    for seed = seeds
        filename = [basename '.s' num2str(seed) '.txt'];
        if exist(filename) ~= 0
            cnt = cnt + 1;
            data = load(filename);

            ret(1, cnt) = data(1);  %% mae all
            ret(2, cnt) = data(2);  %% mae sub
        end
    end %% end seed

    if cnt > 0
        mae1_mean  = mean(ret(1,:));
        mae1_std   = std(ret(1,:));
        mae2_mean  = mean(ret(2,:));
        mae2_std   = std(ret(2,:));
    else
        mae1_mean  = 0;
        mae1_std   = 0;
        mae2_mean  = 0;
        mae2_std   = 0;
    end
end



%% ------------------------------------------
%% plot line: 
%%   x axis: loss rates
%%   lines: cluster method, w/ or w/o shift
function arrange_line_subratio(input_dir, output_dir, trace_names, elem_frac, loss_rates, elem_mode, loss_mode, burst_size, submatrix_ratios, seeds, fig_prefix)
    
    for trace_name = trace_names
        trace_name = char(trace_name);
        trace_opt = get_trace_opt(trace_name);

        for loss_rate = loss_rates
            figname = [output_dir fig_prefix '.' trace_name '.' trace_opt '.elem' num2str(elem_frac) '.lr' num2str(loss_rate) '.' elem_mode '.' loss_mode '.' num2str(burst_size)];
            plot_line_subratio(input_dir, trace_name, trace_opt, elem_frac, loss_rate, elem_mode, loss_mode, burst_size, submatrix_ratios, seeds, figname);
        end
    end
end

%% plot_warp_rank: function description
function plot_line_subratio(input_dir, trace_name, trace_opt, elem_frac, loss_rate, elem_mode, loss_mode, burst_size, submatrix_ratios, seeds, figname)

    fh = figure; clf;
    font_size = 16;
    colors   = {'r', 'b', [0 0.8 0], 'm', [1 0.85 0], [0 0 0.47], [0.45 0.17 0.48], 'k'};
    lines    = {'-', '--', '-.', ':'};
    markers  = {'+', 'o', '*', '.', 'x', 's', 'd', '^', '>', '<', 'p', 'h'};



    for ri = 1:length(submatrix_ratios)
        submatrix_ratio = submatrix_ratios(ri);

        basename = [input_dir trace_name '.' trace_opt '.elem' num2str(elem_frac) '.lr' num2str(loss_rate) '.' elem_mode '.' loss_mode '.' num2str(burst_size) '.' num2str(submatrix_ratio)];
        % fprintf([basename '\n']);
        [mae1_mean, mae1_std, mae2_mean, mae2_std] = get_results(basename, seeds);

        num_compare = 2;
        ret_mean(1, ri) = mae1_mean;
        ret_std(1, ri)  = mae1_std;
        
        ret_mean(2, ri) = mae2_mean;
        ret_std(2, ri)  = mae2_std;
    end
    legends = {'orig', 'sub-mat'};


    %% line
    for li = 1:size(ret_mean, 1)
        % lh{li} = plot(loss_rates, ret(li, :));
        lh{li} = errorbar(submatrix_ratios, ret_mean(li, :), ret_std(li, :));
        set(lh{li}, 'Color', colors{mod(li-1,length(colors))+1});
        set(lh{li}, 'LineStyle', lines{mod(li-1,length(lines))+1});
        set(lh{li}, 'LineWidth', 2);
        set(lh{li}, 'marker', markers{mod(li-1,length(markers))+1});
        set(lh{li}, 'MarkerSize', 10);
        hold on;
    end

    set(gca, 'FontSize', font_size);
    xlabel('sub-matrix length', 'FontSize', font_size);
    ylabel('MAE', 'FontSize', font_size);

    ytics = get(gca, 'YTick');
    max_y = max(ytics) * 1.3;
    set(gca, 'YLim', [0 max_y]);
    % legend(legends, 'Interpreter', 'none', 'Location', 'NorthEast');
    legend(legends, 'Interpreter', 'none');

    % set(gca, 'OuterPosition', [LEFT BOTTOM WIDTH HEIGHT]);  %% normalized value, [0 0 1 1] in default
    % set(gca, 'Position', [0.1 0.2 0.7 0.75]);

    print(fh, '-depsc', [figname '.eps']);
end
%% END plot line
%% ------------------------------------------
