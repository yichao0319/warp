%% postcondor_match_single: function description
function postcondor_match_single()
    input_dir = '~/warp/condor_data/task_match/condor/match_single/';
    trace_names = {'word', 'deap1', 'deap2', 'acc-chest', 'acc-wrist1', 'acc-wrist2', 'acc-wrist3'};

    %% trace opt: depends on trace
    % trace_opts = {"feature=''mfcc''"};

    %% divide opt
    train_ratios = [0 0.2 0.5 0.8 1];

    %% seed
    seeds = [1 2 3 4 5];


    %% plot line: 
    %%   x axis: loss rates
    %%   lines: interpolation methods
    compare_line_trace_opt(input_dir, './figs_match_single/', trace_names, train_ratios, seeds, 'line_trace_opt');

    plot_classification(input_dir, './figs_match_single/', trace_names, train_ratios, seeds, 'table_class');

end


%% get_trace_opt
function [trace_name, trace_opts] = get_trace_opts(trace_name)
    if strcmp(trace_name, 'deap1')
        trace_name = 'deap';
        trace_opts = {'feature=''raw'',channel=1' 'feature=''spectrogram'',channel=1' 'feature=''mfcc'',channel=1' 'feature=''lowrank'',channel=1'};
    elseif strcmp(trace_name, 'deap2')
        trace_name = 'deap';
        trace_opts = {'feature=''raw'',channel=35' 'feature=''spectrogram'',channel=35' 'feature=''mfcc'',channel=35' 'feature=''lowrank'',channel=35'};
    
    elseif strcmp(trace_name, 'word')
        trace_name = 'word';
        trace_opts = {'feature=''raw''' 'feature=''mfcc''' 'feature=''spectrogram''' 'feature=''lowrank'''};
    elseif strcmp(trace_name, 'acc-chest')
        trace_name = 'acc-chest';
        trace_opts = {'feature=''raw''' 'feature=''mag''' 'feature=''percentile''' 'feature=''mag_percentile''' 'feature=''lowrank''' 'feature=''lowrank_percentile'''};
    elseif strcmp(trace_name, 'acc-wrist1')
        trace_name = 'acc-wrist';
        trace_opts = {'feature=''raw'',set=1' 'feature=''mag'',set=1' 'feature=''percentile'',set=1' 'feature=''mag_percentile'',set=1' 'feature=''lowrank'',set=1' 'feature=''lowrank_percentile'',set=1'};
    elseif strcmp(trace_name, 'acc-wrist2')
        trace_name = 'acc-wrist';
        trace_opts = {'feature=''raw'',set=2' 'feature=''mag'',set=2' 'feature=''percentile'',set=2' 'feature=''mag_percentile'',set=2' 'feature=''lowrank'',set=2' 'feature=''lowrank_percentile'',set=2'};
    elseif strcmp(trace_name, 'acc-wrist3')
        trace_name = 'acc-wrist';
        trace_opts = {'feature=''raw'',set=3' 'feature=''mag'',set=3' 'feature=''percentile'',set=3' 'feature=''mag_percentile'',set=3' 'feature=''lowrank'',set=3' 'feature=''lowrank_percentile'',set=3'};
    end
end


%% get_results: function description
function [accuracy, elapsed_time, classification] = get_results(input_dir, trace_name, trace_opt, divide_opt, seeds)

    cnt = 0;
    basename = [input_dir trace_name '.' trace_opt '.' divide_opt];
    fprintf('%s\n', basename);

    for seed = seeds
        filename1 = [basename '.' num2str(seed) '.accuracy.txt'];
        filename2 = [basename '.' num2str(seed) '.class.txt'];
        
        if exist(filename1) ~= 0
            cnt = cnt + 1;
            data1 = load(filename1);

            ret_accuracy(1, cnt) = data1(1);
            ret_elapsed_time(1, cnt) = data1(2);
            fprintf('  accuracy=%f,time=%f\n', data1);


            data2 = load(filename2);
            if cnt == 1
                ret_class = data2;
            else
                ret_class = ret_class + data2;
            end
        end
    end %% end seed

    if cnt > 0
        accuracy = mean(ret_accuracy);
        elapsed_time = mean(ret_elapsed_time);
        classification = ret_class / cnt;
    else
        accuracy       = [];
        elapsed_time   = [];
        classification = [];
    end

end


%% ------------------------------------------
%% compare interpolation method
function compare_line_trace_opt(input_dir, output_dir, trace_names, train_ratios, seeds, fig_prefix)

    
    for trace_name = trace_names
        trace_name = char(trace_name);
        figname = [output_dir fig_prefix '.' trace_name];
        
        [trace_name, trace_opts] = get_trace_opts(trace_name);
        plot_line_trace_opt(input_dir, trace_name, trace_opts, train_ratios, seeds, figname);
    end
end


%% plot_line_interpolation_method
function plot_line_trace_opt(input_dir, trace_name, trace_opts, train_ratios, seeds, figname)

    fh = figure; clf;
    font_size = 16;
    colors   = {'r', 'b', [0 0.8 0], 'm', [1 0.85 0], [0 0 0.47], [0.45 0.17 0.48], 'k'};
    lines    = {'-', '--', '-.'};
    markers  = {'+', 'o', '*', '.', 'x', 's', 'd', '^', '>', '<', 'p', 'h'};

    num_lines = length(trace_opts);

    accuracy = [];
    elapsed_time = [];
    classification = {};
    for li = 1:length(trace_opts)
        trace_opt = char(trace_opts(li));
        legends{li} = trace_opt;

        for ri = 1:length(train_ratios)
            train_ratio = train_ratios(ri);
            divide_opt = ['ratio=' num2str(train_ratio)];
        
            [ret1, ret2, ret3] = get_results(input_dir, trace_name, trace_opt, divide_opt, seeds);

            if(length(ret1) > 0)
                accuracy(li, ri) = ret1;
                elapsed_time(li, ri) = ret2;
                classification{li}{ri} = ret3;
            else
                accuracy(li, ri) = NaN;
                elapsed_time(li, ri) = NaN;
                classification{li}{ri} = [];
            end
        end
    end


    %% plot
    %% - accuracy
    subplot(100, 1, [1:55]);
    for li = 1:length(trace_opts)
        lh1{li} = plot(train_ratios, accuracy(li, :));
        set(lh1{li}, 'Color', colors{mod(li-1,length(colors))+1});
        set(lh1{li}, 'LineStyle', lines{mod(li-1,length(lines))+1});
        set(lh1{li}, 'LineWidth', 2);
        set(lh1{li}, 'marker', markers{mod(li-1,length(markers))+1});
        set(lh1{li}, 'MarkerSize', 10);
        hold on;
    end
    set(gca, 'FontSize', font_size);
    xlabel('train ratio', 'FontSize', font_size);
    ylabel('accuracy', 'FontSize', font_size);

    % ytics = get(gca, 'YTick');
    % max_y = max(ytics) * 1.3;
    % set(gca, 'YLim', [0 max_y]);
    legend(legends, 'Location', 'NorthOutside', 'Interpreter', 'none');
    

    %% - time
    subplot(100, 1, [70:100]);
    for li = 1:length(trace_opts)
        lh2{li} = plot(train_ratios, elapsed_time(li, :));
        set(lh2{li}, 'Color', colors{mod(li-1,length(colors))+1});
        set(lh2{li}, 'LineStyle', lines{mod(li-1,length(lines))+1});
        set(lh2{li}, 'LineWidth', 2);
        set(lh2{li}, 'marker', markers{mod(li-1,length(markers))+1});
        set(lh2{li}, 'MarkerSize', 10);
        hold on;
    end
    set(gca, 'FontSize', font_size);
    set(gca, 'YScale', 'log');
    maxy = max(get(gca, 'YTick'));
    yticks = 10 .^ [0:10];
    yticks = yticks(find(yticks <= maxy));
    set(gca, 'YTick', [yticks]);
    xlabel('train ratio', 'FontSize', font_size);
    ylabel('running time', 'FontSize', font_size);

    
    print(fh, '-depsc', [figname '.eps']);

end
%% END compare trace opts
%% ------------------------------------------
    

%% ------------------------------------------
function plot_classification(input_dir, output_dir, trace_names, train_ratios, seeds, fig_prefix)
    
    for trace_name = trace_names
        trace_name = char(trace_name);
        figname_base = [output_dir fig_prefix '.' trace_name];
        [trace_name, trace_opts] = get_trace_opts(trace_name);

        for trace_opt = trace_opts
            trace_opt = char(trace_opt);

            for train_ratio = train_ratios
                divide_opt = ['ratio=' num2str(train_ratio)];

                [ret1, ret2, ret3] = get_results(input_dir, trace_name, trace_opt, divide_opt, seeds);
                
                if prod(size(ret3)) > 0
                    ret3 = ret3 ./ (repmat(sum(ret3,2), 1, size(ret3,2)));
                    dlmwrite([figname_base '.' trace_opt '.' divide_opt '.class.csv'], ret3, 'delimiter', ',');
                    
                end

            end
        end
    end
end
%% END plot classification table
%% ------------------------------------------
