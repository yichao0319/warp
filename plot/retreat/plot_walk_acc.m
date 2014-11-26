%% plot_acc: function description
function plot_walk_acc()
    addpath('../../task_dtw/c_func');
    addpath('../../task_dtw');
    addpath('/u/yichao/lens/utils/compressive_sensing');


    input_dir = '../../../processed_data/task_parse_walk_sensor/';
    filename = 'walk_acce_mag_handheld';
    output_dir = './tmp/';

    font_size = 12;
    colors   = {'r', 'b', [0 0.8 0], 'm', [1 0.85 0], [0 0 0.47], [0.45 0.17 0.48], 'k'};
    lines    = {'-', '--'};
    markers  = {'+', 'o', '*', '.', 'x', 's', 'd', '^', '>', '<', 'p', 'h'};


    X = load([input_dir filename '.txt']);
    range = 500:900;
    lines = 1:10;
    X = X(lines, range);
    % lc = 0;

    % fh = figure(1); clf;
    % for li = 1:size(X,1)
    %     fprintf('std=%f\n', std(X(li,:)));
    %     if std(X(li,:)) < 1
    %         continue;
    %     end
    %     lc = lc + 1;
    %     lh{lc} = plot(X(li,:));
    %     % lh{lc} = plot3(ones(1,length(range))*lc, 1:length(range), X(li,:));
    %     set(lh{lc}, 'Color', colors{mod(lc-1,length(colors))+1});
    %     hold on;        
    % end

    % set(gca, 'FontSize', font_size);
    % xlabel('Time', 'FontSize', font_size);
    % ylabel('Accelerometer Magnitude', 'FontSize', font_size);

    % % legend(legends, 'Location', 'NorthEast');
    % print(fh, '-depsc', [output_dir filename '.orig.eps']);


    %% --------------------------------
    %% warp
    warp_methods = {'na', 'na_1line', 'na_2line', 'dtw', 'shift_limit', 'shift', 'stretch'};
    tmp{1} = num2cell(X,2);

    for warp_method = warp_methods
        warp_method = char(warp_method);

        if strcmp(warp_method, 'na') | strcmp(warp_method, 'na_1line')  | strcmp(warp_method, 'na_2line')
            X_warp = X;
        else
            X_warp = do_warp(tmp, warp_method);
            X_warp = cluster2mat(X_warp);
        end


        if strcmp(warp_method, 'na')
            range = 1:size(X_warp, 2);
            lines = 1:size(X_warp, 1);
        elseif strcmp(warp_method, 'na_1line')
            range = 1:size(X_warp, 2);
            lines = 1;
        elseif strcmp(warp_method, 'na_2line')
            range = 1:size(X_warp, 2);
            lines = 1:2;
        elseif strcmp(warp_method, 'shift')
            range = 100:400;
            lines = 1:size(X_warp, 1);
        elseif strcmp(warp_method, 'stretch')
            range = 1500:2200;
            lines = [1 3:size(X_warp, 1)];
        else
            range = 1:size(X_warp,2);
            lines = 1:size(X_warp, 1);
        end
        % range = 1:size(X_warp,2);
        X_warp = X_warp(lines, range);
        
        lc = 0;
        fh = figure(2); clf;
        for li = 1:size(X_warp,1)
            fprintf('std=%f\n', std(X_warp(li,:)));
            if std(X_warp(li,:)) < 1
                continue;
            end
            lc = lc + 1;
            lh{lc} = plot(X_warp(li,:));
            % lh{lc} = plot3(ones(1,size(X_warp,2))*lc, 1:size(X_warp,2), X_warp(li,:));
            set(lh{lc}, 'Color', colors{mod(lc-1,length(colors))+1});
            hold on;        
        end

        set(gca, 'FontSize', font_size);
        xlabel('Time', 'FontSize', font_size);
        ylabel('Acceleration', 'FontSize', font_size);
        set(gca, 'XLim', [0 size(X_warp,2)]);

        set(gca, 'OuterPosition', [0 0 1 0.5]);  %% normalized value, [0 0 1 1] in default
        % set(gca, 'Position', [LEFT BOTTOM WIDTH HEIGHT]);


        % legend(legends, 'Location', 'NorthEast');
        print(fh, '-depsc', [output_dir filename '.' warp_method '.eps']);
    end
