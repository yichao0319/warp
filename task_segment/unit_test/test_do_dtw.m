%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Yi-Chao Chen @ UT Austin
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function test_do_dtw()
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


    cnt = cnt + 1;
    test{cnt} = 'manual, num seg=1';
    num_seg(cnt) = 1;
    X{cnt}{1} = [ones(1,5)*5 ones(1,5)*10];
    X{cnt}{2} = [ones(1,3)*5 ones(1,3)*10];
    sample_class{cnt}{1} = [ones(1,5)*1 ones(1,5)*2];
    sample_class{cnt}{2} = [ones(1,3)*1 ones(1,3)*2];


    cnt = cnt + 1;
    test{cnt} = 'manual, num seg=1';
    num_seg(cnt) = 1;
    X{cnt}{1} = [1:10 20:-2:11];
    X{cnt}{2} = [1:2:10 20:-1:11];
    sample_class{cnt}{1} = [ones(1,10)*1 ones(1,5)*2];
    sample_class{cnt}{2} = [ones(1,5)*1 ones(1,10)*2];
    

    %% --------------------
    %% Main starts
    %% --------------------
    for ti = 1:length(test)
        fprintf('=====================================\n');
        fprintf('TEST %d: %s\n', ti, char(test{ti}));
        
        fprintf('  before\n');
        [X{ti}{1};
        sample_class{ti}{1}]
        
        [X{ti}{2};
        sample_class{ti}{2}]

        opt = ['num_seg=' num2str(num_seg(ti))];
        other_mat{1} = sample_class{ti};
        [dtw_X, dtw_other] = do_dtw(X{ti}, opt, other_mat);

        fprintf('  after\n');
        [dtw_X{1};
        dtw_other{1}{1}]
        
        [dtw_X{2};
        dtw_other{1}{2}]

        plot_ts_with_class(X{ti}, sample_class{ti}, [output_dir 'test_do_dtw.orig' num2str(ti)]);
        plot_ts_with_class(dtw_X, dtw_other{1}, [output_dir 'test_do_dtw.dtw' num2str(ti)]);
        input('========================================\n');
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