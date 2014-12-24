%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Yi-Chao Chen @ UT Austin
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function test_get_seg()
    addpath('../');
    
    %% --------------------
    %% DEBUG
    %% --------------------
    DEBUG0 = 0;
    DEBUG1 = 1;
    DEBUG2 = 1;


    %% --------------------
    %% Variable
    %% --------------------
    output_dir = '../tmp/';
    cnt = 0;


    %% -----------------------------
    if 0
        cnt = cnt + 1;
        test{cnt} = 'word, 2 words';
        trace_name{cnt} = 'word';
        feature{cnt} = 'mfcc';
        num(cnt) = 2;
        
        cnt = cnt + 1;
        test{cnt} = 'word, all words';
        trace_name{cnt} = 'word';
        feature{cnt} = 'mfcc';
        num(cnt) = 0;
    end
    %% -----------------------------


    %% -----------------------------
    if 1
        cnt = cnt + 1;
        test{cnt} = 'acc-wrist, 2 activities';
        trace_name{cnt} = 'acc-wrist';
        feature{cnt} = 'raw';
        num(cnt) = 2;

        cnt = cnt + 1;
        test{cnt} = 'acc-wrist, all activities';
        trace_name{cnt} = 'acc-wrist';
        feature{cnt} = 'raw';
        num(cnt) = 0;
    end
    %% -----------------------------
    

    %% --------------------
    %% Main starts
    %% --------------------
    for ti = 1:length(test)
        fprintf('=====================================\n');
        fprintf('TEST %d: %s\n', ti, char(test{ti}));
        
        opt = ['feature=''' char(feature{ti}) ''',num=' num2str(num(ti))];
        [X, sample_class] = get_trace_seg(char(trace_name{ti}), opt);
        plot_ts_with_class(X, sample_class, [output_dir 'ts.' char(trace_name{ti}) '.' opt]);
        fprintf('  #subjects=%d, #activities=%d\n', length(X), length(unique(sample_class{1})));
        fprintf('=====================================\n');
        % input('========================================\n');
    end
    
end


%% plot_ts_with_class
function plot_ts_with_class(X, sample_class, figname)
    clf;
    fh = figure;
    font_size = 28;

    colors   = {'b', [0 0.8 0], 'm', [1 0.85 0], [0 0 0.47], [0.45 0.17 0.48], 'k'};
    lines    = {'-', '--', '-.', ':'};
    markers  = {'+', 'o', '*', '.', 'x', 's', 'd', '^', '>', '<', 'p', 'h'};


    
    for ri = 1:length(X)
        lh{ri} = plot(X{ri}(1,:));
        set(lh{ri}, 'Color', colors{mod(ri-1,length(colors))+1});
        set(lh{ri}, 'LineStyle', char(lines{mod(ri-1,length(lines))+1}));
        set(lh{ri}, 'LineWidth', 2);
        % set(lh{ri}, 'marker', markers{mod(ri-1,length(markers))+1});
        % set(lh{ri}, 'MarkerSize', 7);
        hold on;

        uniq_class = unique(sample_class{ri});
        idx = [];
        for ci = uniq_class
            tmp = find(sample_class{ri} == ci);
            idx = [idx tmp(1)];
        end
        tmp = ones(1, length(X{ri}(1,:))) * NaN;
        tmp(idx) = X{ri}(1,idx);
        lh_sample{ri} = plot(tmp);
        set(lh_sample{ri}, 'Color', colors{mod(ri-1,length(colors))+1});
        set(lh_sample{ri}, 'marker', 'o');
        set(lh_sample{ri}, 'MarkerSize', 10);
    end

    set(gca, 'FontSize', font_size);
    xlabel('Time', 'FontSize', font_size);
    ylabel('feature 1', 'FontSize', font_size);
    % xlim([1 length(this_ts)]);
    % legend(legends);

    print(fh, '-depsc', [figname '.eps']);
end