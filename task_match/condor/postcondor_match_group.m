%% postcondor_match_group: function description
function postcondor_match_group()
    addpath('../../utils/matlab/columnlegend/');


    input_dir = '~/warp/condor_data/task_match/condor/match_group/';
    % input_dir = '~/warp/condor_data/task_match/condor/match_group.2014.12.15.lim4/';
    % trace_names = {'word', 'deap1', 'deap2', 'acc-chest', 'acc-wrist1', 'acc-wrist2', 'acc-wrist3'};
    trace_names = {'word', 'acc-wrist1', 'acc-wrist2', 'acc-wrist3'};
    % trace_names = {'word', 'acc-wrist1'};
    % trace_names = {'word'};

    %% trace opt: depends on trace
    % trace_opts = {"feature=''mfcc''"};

    %% feature_opt
    feature_nums = [-1 0 0.2 0.5 0.8];

    %% divide opt
    train_ratios = [0 0.2 0.5 0.8 1];

    %% cluster_opt
    method = 'kmeans';
    cluster_nums = [1 2 3 5];

    %% sync_opt
    % syncs = {'na', 'shift'};
    syncs = {'shift'};
    % metrics = {'coeff', 'dist'};
    metrics = {'coeff'};

    %% seed
    seeds = [1 2 3 4 5];


    %% plot line: 
    %%   x axis: train ratio
    %%   lines: # clusters + base lines
    % compare_line_cluster_num(input_dir, './figs_match_group/', trace_names, feature_nums, train_ratios, method, cluster_nums, syncs, metrics, seeds, 'line_cluster_num');

    % plot_classification(input_dir, './figs_match_group/', trace_names, train_ratios, seeds, 'table_class');


    %% plot line: 
    %%   x axis: train ratio
    %%   lines: # features + base lines
    % cluster_nums = [1];
    compare_line_feature_num(input_dir, './figs_match_group/', trace_names, feature_nums, train_ratios, method, cluster_nums, syncs, metrics, seeds, 'line_feature_num');


end


%% get_trace_opt
function [trace_name, trace_opts] = get_trace_opts(trace_name)
    if strcmp(trace_name, 'deap1')
        trace_name = 'deap';
        % trace_opts = {'feature=''raw'',channel=1' 'feature=''spectrogram'',channel=1' 'feature=''mfcc'',channel=1' 'feature=''lowrank'',channel=1'};
        trace_opts = {'feature=''raw'',channel=1' 'feature=''spectrogram'',channel=1'};
    elseif strcmp(trace_name, 'deap2')
        trace_name = 'deap';
        trace_opts = {'feature=''raw'',channel=35' 'feature=''spectrogram'',channel=35' 'feature=''mfcc'',channel=35' 'feature=''lowrank'',channel=35'};
    
    elseif strcmp(trace_name, 'word')
        trace_name = 'word';
        % trace_opts = {'feature=''raw''' 'feature=''mfcc''' 'feature=''spectrogram''' 'feature=''lowrank'''};
        % trace_opts = {'feature=''mfcc''' 'feature=''spectrogram'''};
        trace_opts = {'feature=''mfcc'''};
    elseif strcmp(trace_name, 'acc-chest')
        trace_name = 'acc-chest';
        trace_opts = {'feature=''raw''' 'feature=''mag''' 'feature=''quantization''' 'feature=''mag_quantization''' 'feature=''lowrank''' 'feature=''lowrank_quantization'''};
    elseif strcmp(trace_name, 'acc-wrist1')
        trace_name = 'acc-wrist';
        % trace_opts = {'feature=''raw'',set=1' 'feature=''quantization'',set=1' 'feature=''mag_quantization'',set=1' 'feature=''lowrank'',set=1' 'feature=''lowrank_quantization'',set=1'};
        % trace_opts = {'feature=''raw'',set=1' 'feature=''quantization'',set=1'};
        trace_opts = {'feature=''raw'',set=1'};
    elseif strcmp(trace_name, 'acc-wrist2')
        trace_name = 'acc-wrist';
        % trace_opts = {'feature=''raw'',set=2' 'feature=''mag'',set=2' 'feature=''quantization'',set=2' 'feature=''mag_quantization'',set=2' 'feature=''lowrank'',set=2' 'feature=''lowrank_quantization'',set=2'};
        % trace_opts = {'feature=''raw'',set=2' 'feature=''quantization'',set=2'};
        trace_opts = {'feature=''raw'',set=2'};
    elseif strcmp(trace_name, 'acc-wrist3')
        trace_name = 'acc-wrist';
        % trace_opts = {'feature=''raw'',set=3' 'feature=''mag'',set=3' 'feature=''quantization'',set=3' 'feature=''mag_quantization'',set=3' 'feature=''lowrank'',set=3' 'feature=''lowrank_quantization'',set=3'};
        % trace_opts = {'feature=''raw'',set=3' 'feature=''quantization'',set=3'};
        trace_opts = {'feature=''raw'',set=3'};
    end
end


%% get_results: function description
function [accuracy, elapsed_time, classification] = get_results(input_dir, trace_name, trace_opt, feature_opt, divide_opt, cluster_opt, sync_opt, seeds)

    cnt = 0;
    basename = [input_dir trace_name '.' trace_opt '.' feature_opt '.' divide_opt '.' cluster_opt '.' sync_opt];
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
%% compare cluster numbers + base lines
function compare_line_cluster_num(input_dir, output_dir, trace_names, feature_nums, train_ratios, method, cluster_nums, syncs, metrics, seeds, fig_prefix)

    
    for trace_name = trace_names
        trace_name = char(trace_name);

        
        
        [this_trace_name, trace_opts] = get_trace_opts(trace_name);
        for trace_opt = trace_opts
            trace_opt = char(trace_opt);

            for feature_num = feature_nums
                for sync = syncs
                    sync = char(sync);

                    for metric = metrics
                        metric = char(metric);

                        plot_line_cluster_num(input_dir, this_trace_name, trace_opt, feature_num, train_ratios, method, cluster_nums, sync, metric, seeds, [output_dir fig_prefix]);
                    end
                end
            end
        end
    end
end


function plot_line_cluster_num(input_dir, trace_name, trace_opt, feature_num, train_ratios, method, cluster_nums, sync, metric, seeds, figname)

    fh = figure; clf;
    font_size = 16;
    colors   = {'r', 'b', [0 0.8 0], 'm', [1 0.85 0], [0 0 0.47], [0.45 0.17 0.48], 'k'};
    lines    = {'-', '--', '-.'};
    markers  = {'+', 'o', '*', '.', 'x', 's', 'd', '^', '>', '<', 'p', 'h'};

    
    accuracy = [];
    elapsed_time = [];
    classification = {};

    %% base line 1: no sync, no cluster, original length
    lc = 1;
    base1_cluster_num = 1;
    base1_sync = 'na';
    legends{lc} = 'unsync';

    feature_opt = ['num=' num2str(feature_num)];
    cluster_opt = ['method=''' method ''',num=' num2str(base1_cluster_num)];
    
    for ri = 1:length(train_ratios)
        train_ratio = train_ratios(ri);

        divide_opt = ['ratio=' num2str(train_ratio)];

        cnt = 0;
        % for base_metric = {'dist' 'coeff'}
        for base_metric = {metric}
            base_metric = char(base_metric);
            sync_opt = ['sync=''' base1_sync ''',metric=''' base_metric ''''];
        
            [tmp1, tmp2, tmp3] = get_results(input_dir, trace_name, trace_opt, feature_opt, divide_opt, cluster_opt, sync_opt, seeds);
            if(length(tmp1) > 0)
                if cnt == 0
                    ret1 = tmp1; 
                    ret2 = tmp2; 
                    ret3 = tmp3;
                else
                    ret1 = ret1 + tmp1; 
                    ret2 = ret2 + tmp2; 
                    ret3 = ret3 + tmp3;
                end
                cnt = cnt + 1;
            end
        end
        if cnt > 0
            accuracy(lc, ri) = ret1 / cnt;
            elapsed_time(lc, ri) = ret2 / cnt;
            classification{lc}{ri} = ret3 / cnt;
        else
            accuracy(lc, ri) = NaN;
            elapsed_time(lc, ri) = NaN;
            classification{lc}{ri} = [];
        end
    end


    %% base line 2: no sync, no cluster, same length as sync
    lc = lc + 1;
    base2_cluster_num = 1;
    base2_sync = 'nafair';
    legends{lc} = 'unsync, short';

    feature_opt = ['num=' num2str(feature_num)];
    cluster_opt = ['method=''' method ''',num=' num2str(base2_cluster_num)];
    
    for ri = 1:length(train_ratios)
        train_ratio = train_ratios(ri);

        divide_opt = ['ratio=' num2str(train_ratio)];

        cnt = 0;
        % for base_metric = {'dist' 'coeff'}
        for base_metric = {metric}
            base_metric = char(base_metric);
            sync_opt = ['sync=''' base2_sync ''',metric=''' base_metric ''''];
        
            [tmp1, tmp2, tmp3] = get_results(input_dir, trace_name, trace_opt, feature_opt, divide_opt, cluster_opt, sync_opt, seeds);
            if(length(tmp1) > 0)
                if cnt == 0
                    ret1 = tmp1; 
                    ret2 = tmp2; 
                    ret3 = tmp3;
                else
                    ret1 = ret1 + tmp1; 
                    ret2 = ret2 + tmp2; 
                    ret3 = ret3 + tmp3;
                end
                cnt = cnt + 1;
            end
        end
        if cnt > 0
            accuracy(lc, ri) = ret1 / cnt;
            elapsed_time(lc, ri) = ret2 / cnt;
            classification{lc}{ri} = ret3 / cnt;
        else
            accuracy(lc, ri) = NaN;
            elapsed_time(lc, ri) = NaN;
            classification{lc}{ri} = [];
        end
    end


    %% cluster num
    for cluster_num = cluster_nums
        lc = lc + 1;
        legends{lc} = [sync ', #clust=' num2str(cluster_num)];

        feature_opt = ['num=' num2str(feature_num)];
        cluster_opt = ['method=''' method ''',num=' num2str(cluster_num)];
        sync_opt = ['sync=''' sync ''',metric=''' metric ''''];
        
        for ri = 1:length(train_ratios)
            train_ratio = train_ratios(ri);

            divide_opt = ['ratio=' num2str(train_ratio)];
            [ret1, ret2, ret3] = get_results(input_dir, trace_name, trace_opt, feature_opt, divide_opt, cluster_opt, sync_opt, seeds);
            if(length(ret1) > 0)
                accuracy(lc, ri) = ret1;
                elapsed_time(lc, ri) = ret2;
                classification{lc}{ri} = ret3;
            else
                accuracy(lc, ri) = NaN;
                elapsed_time(lc, ri) = NaN;
                classification{lc}{ri} = [];
            end
        end
    end



    %% plot
    %% - accuracy
    subplot(100, 1, [1:55]);
    for li = 1:lc
        lh1{li} = plot(train_ratios, accuracy(li, :));
        set(lh1{li}, 'Color', colors{mod(li-1,length(colors))+1});
        set(lh1{li}, 'LineStyle', lines{mod(li-1,length(lines))+1});
        set(lh1{li}, 'LineWidth', 2);
        set(lh1{li}, 'marker', markers{mod(li-1,length(markers))+1});
        set(lh1{li}, 'MarkerSize', 10);
        hold on;
    end
    set(gca, 'FontSize', font_size);
    ys = get(gca, 'YLim'); ys(2) = ys(2) + 0.01;
    set(gca, 'YLim', ys);
    xlabel('train ratio', 'FontSize', font_size);
    ylabel('accuracy', 'FontSize', font_size);

    % ytics = get(gca, 'YTick');
    % max_y = max(ytics) * 1.3;
    % set(gca, 'YLim', [0 max_y]);
    % legend(legends, 'Location', 'NorthOutside', 'Interpreter', 'none', 'Orientation', 'horizontal');
    % legend(legends, 'Location', 'NorthOutside', 'Interpreter', 'none', 'Orientation', 'horizontal');
    columnlegend(3, legends, 'Location', 'NorthOutside', 'Orientation', 'Horizontal');
    pos = get(gca, 'Position');
    pos(4) = pos(4) - 0.15;
    set(gca, 'Position', pos);

    %% - time
    subplot(100, 1, [70:100]);
    for li = 1:lc
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
    maxy = max(get(gca, 'YLim'));
    miny = min(get(gca, 'YLim'));
    maxyi = ceil(log(maxy) / log(10));
    minyi = floor(log(miny) / log(10));
    yticks = 10 .^ [minyi:maxyi];
    % yticks = yticks(find(yticks <= maxy));
    set(gca, 'YTick', [yticks]);
    set(gca, 'YLim', [min([yticks, miny]) max(yticks)]);
    xlabel('train ratio', 'FontSize', font_size);
    ylabel('running time', 'FontSize', font_size);


    feature_opt = ['num=' num2str(feature_num)];
    cluster_opt = ['method=''' method ''',num=' num2str(cluster_num)];
    sync_opt = ['sync=''' sync ''',metric=''' metric ''''];
    figname = [figname '.' trace_name '.' trace_opt '.' feature_opt '.' cluster_opt '.' sync_opt];
    print(fh, '-depsc', [figname '.eps']);

end
%% END compare line #cluster 
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


%% ------------------------------------------
%% compare # features
function compare_line_feature_num(input_dir, output_dir, trace_names, feature_nums, train_ratios, method, cluster_nums, syncs, metrics, seeds, fig_prefix)

    
    for trace_name = trace_names
        trace_name = char(trace_name);

        
        
        [this_trace_name, trace_opts] = get_trace_opts(trace_name);
        for trace_opt = trace_opts
            trace_opt = char(trace_opt);

            for cluster_num = cluster_nums
                for sync = syncs
                    sync = char(sync);

                    for metric = metrics
                        metric = char(metric);

                        plot_line_feature_num(input_dir, this_trace_name, trace_opt, feature_nums, train_ratios, method, cluster_num, sync, metric, seeds, [output_dir fig_prefix]);
                    end
                end
            end
        end
    end
end


function plot_line_feature_num(input_dir, trace_name, trace_opt, feature_nums, train_ratios, method, cluster_num, sync, metric, seeds, figname)

    fh = figure; clf;
    font_size = 16;
    colors   = {'r', 'b', [0 0.8 0], 'm', [1 0.85 0], [0 0 0.47], [0.45 0.17 0.48], 'k'};
    lines    = {'-', '--', '-.'};
    markers  = {'+', 'o', '*', '.', 'x', 's', 'd', '^', '>', '<', 'p', 'h'};

    
    accuracy = [];
    elapsed_time = [];
    classification = {};

    %% base line 1: no sync, no cluster, original length
    lc = 1;
    base1_cluster_num = 1;
    base1_sync = 'na';
    base1_feature_num = -1;
    legends{lc} = 'unsync';

    feature_opt = ['num=' num2str(base1_feature_num)];
    cluster_opt = ['method=''' method ''',num=' num2str(base1_cluster_num)];
    
    for ri = 1:length(train_ratios)
        train_ratio = train_ratios(ri);

        divide_opt = ['ratio=' num2str(train_ratio)];

        cnt = 0;
        % for base_metric = {'dist' 'coeff'}
        for base_metric = {metric}
            base_metric = char(base_metric);
            sync_opt = ['sync=''' base1_sync ''',metric=''' base_metric ''''];
        
            [tmp1, tmp2, tmp3] = get_results(input_dir, trace_name, trace_opt, feature_opt, divide_opt, cluster_opt, sync_opt, seeds);
            if(length(tmp1) > 0)
                if cnt == 0
                    ret1 = tmp1; 
                    ret2 = tmp2; 
                    ret3 = tmp3;
                else
                    ret1 = ret1 + tmp1; 
                    ret2 = ret2 + tmp2; 
                    ret3 = ret3 + tmp3;
                end
                cnt = cnt + 1;
            end
        end
        if cnt > 0
            accuracy(lc, ri) = ret1 / cnt;
            elapsed_time(lc, ri) = ret2 / cnt;
            classification{lc}{ri} = ret3 / cnt;
        else
            accuracy(lc, ri) = NaN;
            elapsed_time(lc, ri) = NaN;
            classification{lc}{ri} = [];
        end
    end


    %% base line 2: no sync, no cluster, same length as sync
    lc = lc + 1;
    base2_cluster_num = 1;
    base2_sync = 'nafair';
    base2_feature_num = 0;
    legends{lc} = 'unsync, short';

    feature_opt = ['num=' num2str(base2_feature_num)];
    cluster_opt = ['method=''' method ''',num=' num2str(base2_cluster_num)];
    
    for ri = 1:length(train_ratios)
        train_ratio = train_ratios(ri);

        divide_opt = ['ratio=' num2str(train_ratio)];

        cnt = 0;
        % for base_metric = {'dist' 'coeff'}
        for base_metric = {metric}
            base_metric = char(base_metric);
            sync_opt = ['sync=''' base2_sync ''',metric=''' base_metric ''''];
        
            [tmp1, tmp2, tmp3] = get_results(input_dir, trace_name, trace_opt, feature_opt, divide_opt, cluster_opt, sync_opt, seeds);
            if(length(tmp1) > 0)
                if cnt == 0
                    ret1 = tmp1; 
                    ret2 = tmp2; 
                    ret3 = tmp3;
                else
                    ret1 = ret1 + tmp1; 
                    ret2 = ret2 + tmp2; 
                    ret3 = ret3 + tmp3;
                end
                cnt = cnt + 1;
            end
        end
        if cnt > 0
            accuracy(lc, ri) = ret1 / cnt;
            elapsed_time(lc, ri) = ret2 / cnt;
            classification{lc}{ri} = ret3 / cnt;
        else
            accuracy(lc, ri) = NaN;
            elapsed_time(lc, ri) = NaN;
            classification{lc}{ri} = [];
        end
    end


    %% cluster num
    for feature_num = feature_nums
        lc = lc + 1;
        if feature_num < 0
            legends{lc} = [sync ', all features'];
        elseif feature_num == 0
            legends{lc} = [sync ', selection alg.'];
        else
            legends{lc} = [sync ', ratio=' num2str(feature_num)];
        end

        feature_opt = ['num=' num2str(feature_num)];
        cluster_opt = ['method=''' method ''',num=' num2str(cluster_num)];
        sync_opt = ['sync=''' sync ''',metric=''' metric ''''];
        
        for ri = 1:length(train_ratios)
            train_ratio = train_ratios(ri);

            divide_opt = ['ratio=' num2str(train_ratio)];
            [ret1, ret2, ret3] = get_results(input_dir, trace_name, trace_opt, feature_opt, divide_opt, cluster_opt, sync_opt, seeds);
            if(length(ret1) > 0)
                accuracy(lc, ri) = ret1;
                elapsed_time(lc, ri) = ret2;
                classification{lc}{ri} = ret3;
            else
                accuracy(lc, ri) = NaN;
                elapsed_time(lc, ri) = NaN;
                classification{lc}{ri} = [];
            end
        end
    end



    %% plot
    %% - accuracy
    subplot(100, 1, [1:55]);
    for li = 1:lc
        lh1{li} = plot(train_ratios, accuracy(li, :));
        set(lh1{li}, 'Color', colors{mod(li-1,length(colors))+1});
        set(lh1{li}, 'LineStyle', lines{mod(li-1,length(lines))+1});
        set(lh1{li}, 'LineWidth', 2);
        set(lh1{li}, 'marker', markers{mod(li-1,length(markers))+1});
        set(lh1{li}, 'MarkerSize', 10);
        hold on;
    end
    set(gca, 'FontSize', font_size);
    ys = get(gca, 'YLim'); ys(2) = ys(2) + 0.01;
    set(gca, 'YLim', ys);
    xlabel('train ratio', 'FontSize', font_size);
    ylabel('accuracy', 'FontSize', font_size);

    % ytics = get(gca, 'YTick');
    % max_y = max(ytics) * 1.3;
    % set(gca, 'YLim', [0 max_y]);
    % legend(legends, 'Location', 'NorthOutside', 'Interpreter', 'none', 'Orientation', 'horizontal');
    % legend(legends, 'Location', 'NorthOutside', 'Interpreter', 'none', 'Orientation', 'horizontal');
    columnlegend(3, legends, 'Location', 'NorthOutside', 'Orientation', 'Horizontal');
    pos = get(gca, 'Position');
    pos(4) = pos(4) - 0.15;
    set(gca, 'Position', pos);

    %% - time
    subplot(100, 1, [70:100]);
    for li = 1:lc
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
    maxy = max(get(gca, 'YLim'));
    miny = min(get(gca, 'YLim'));
    maxyi = ceil(log(maxy) / log(10));
    minyi = floor(log(miny) / log(10));
    yticks = 10 .^ [minyi:maxyi];
    % yticks = yticks(find(yticks <= maxy));
    set(gca, 'YTick', [yticks]);
    set(gca, 'YLim', [min([yticks, miny]) max(yticks)]);
    xlabel('train ratio', 'FontSize', font_size);
    ylabel('running time', 'FontSize', font_size);


    feature_opt = ['num=' num2str(feature_num)];
    cluster_opt = ['method=''' method ''',num=' num2str(cluster_num)];
    sync_opt = ['sync=''' sync ''',metric=''' metric ''''];
    figname = [figname '.' trace_name '.' trace_opt '.' feature_opt '.' cluster_opt '.' sync_opt];
    print(fh, '-depsc', [figname '.eps']);

end
%% END compare line #features
%% ------------------------------------------
