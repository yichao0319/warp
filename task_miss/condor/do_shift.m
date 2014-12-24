%% do_shift: function description
function [X_sync, other_sync] = do_shift(X_cluster, other_mat)
    other_sync = {};

    for ci = 1:length(X_cluster)
        if length(X_cluster{ci}) == 1
            X_sync{ci} = X_cluster{ci};
            % M_sync{ci} = M_cluster{ci};
            if nargin >= 2
                for oi = 1:length(other_mat)
                    other_sync{oi}{ci} = other_mat{oi}{ci};
                end
            end
            continue;
        end

        cc = [];
        for tsi = 2:length(X_cluster{ci})
            [shift_idx1, shift_idx2, this_cc] = find_best_shift(X_cluster{ci}{1}, X_cluster{ci}{tsi});
            cc(tsi-1, :) = this_cc;
            ws{tsi} = [];
            ws{tsi}(:, 1) = shift_idx1';
            ws{tsi}(:, 2) = shift_idx2';

            % fprintf('-- ws ----------------\n')
            % length(X_cluster{ci}{1})
            % length(X_cluster{ci}{tsi})
            % ws{tsi}(:, 1)'
            % ws{tsi}(:, 2)'
            % fprintf('-- end ws ----------------\n')
            % input('..........')
        end


        % [X_sync{ci}, M_sync{ci}] = align_cluster(X_cluster{ci}, ws, M_cluster{ci});
        tmp_other_mat = {};
        if nargin >= 2
            for oi = 1:length(other_mat)
                tmp_other_mat{oi} = other_mat{oi}{ci};
            end
        end
        [X_sync{ci}, tmp_other_sync] = align_cluster(X_cluster{ci}, ws, tmp_other_mat);
        if nargin >= 2
            for oi = 1:length(tmp_other_sync)
                other_sync{oi}{ci} = tmp_other_sync{oi};
            end
        end

        %% ----------
        %% DEBUG
        %%   plot cc
        plot_cc(cc, ['./tmp/tmp.do_shift.cc']);
    end
end


%% find_best_shift: function description
function [shift_idx1, shift_idx2, cc] = find_best_shift(ts1, ts2)
    best_cc = -2;
    
    % fprintf('ts1 %dx%d, ts2 %dx%d\n', size(ts1), size(ts2));
    for idx2 = [1-length(ts2):length(ts1)-1]
        [idx1_padded, idx2_padded] = shift_pad(length(ts1), length(ts2), idx2);
        ts1_padded = ts1(idx1_padded);
        ts2_padded = ts2(idx2_padded);
        
        coeff = my_corrcoef(ts1_padded', ts2_padded');
        cc(1, idx2+length(ts2)) = coeff(1,2);

        % fprintf('  idx %d: cc = %f (best = %f)\n', idx2, cc(1, idx2+length(ts2)), best_cc);
        if cc(1, idx2+length(ts2)) > best_cc
            % fprintf('      > best\n');
            best_cc = cc(1, idx2+length(ts2));
            shift_idx1 = idx1_padded;
            shift_idx2 = idx2_padded;
        end
    end

    %% best corrcoef is not updated -> ts2 might be all 0s
    if best_cc == -2
        [shift_idx1, shift_idx2] = shift_pad(length(ts1), length(ts2), 0);
    end
end


%% shift_pad: function description
%% idx: -2 -1  0  1  2  3  4  5  6  7  8
%% ts1:        1  2  3  4  5  6
%% ts2:  1  2  3  
% function [idx1_padded, idx2_padded] = shift_pad(len1, len2, idx)



%% ========================================
%% plot figures:

%% plot_cc: function description
function plot_cc(cc, figname)
    font_size = 12;
    colors   = {'r', 'b', [0 0.8 0], 'm', [1 0.85 0], [0 0 0.47], [0.45 0.17 0.48], 'k'};
    lines    = {'-', '--'};
    markers  = {'+', 'o', '*', '.', 'x', 's', 'd', '^', '>', '<', 'p', 'h'};

    max_cc = max(cc, [], 2);
    [tmp, sort_idx] = sort(max_cc, 'descend');
    plot_idx = sort_idx(1:min(5,end));
    
    fh = figure(1); clf;
    for li = 1:min(5, length(sort_idx))
        lh{li} = plot(cc(sort_idx(li), :));
        set(lh{li}, 'Color', colors{mod(li-1,length(colors))+1});
        set(lh{li}, 'LineStyle', lines{mod(li-1,length(lines))+1});  %% line  : -|--|:|-.
        set(lh{li}, 'LineWidth', 2);
        hold on;
        legends{li} = num2str(sort_idx(li));
    end

    set(gca, 'FontSize', font_size);
    xlabel('samples', 'FontSize', font_size);
    ylabel('corrcoef', 'FontSize', font_size);

    % legend(legends, 'Location', 'Best');
    % legend(legends, 'Location', 'NorthEast');
    print(fh, '-depsc', [figname '.eps']);
end

