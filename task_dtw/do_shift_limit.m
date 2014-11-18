function [X_warp, other_warp] = do_shift_limit(X_cluster, other_mat, figbase)
    if nargin < 3, figbase = ''; end

    other_warp = {};

    shift_lim_left = 1/3;
    shift_lim_right = 2/3;
    % shift_lim_left = 1/5;
    % shift_lim_right = 4/5;

    for ci = 1:length(X_cluster)
        if length(X_cluster{ci}) == 1
            X_warp{ci} = X_cluster{ci};
            % M_warp{ci} = M_cluster{ci};
            if nargin >= 2
                for oi = 1:length(other_mat)
                    other_warp{oi}{ci} = other_mat{oi}{ci};
                end
            end
            continue;
        end

        cc = [];
        for tsi = 2:length(X_cluster{ci})
            ts1_len = length(X_cluster{ci}{1});
            ts2_len = length(X_cluster{ci}{tsi});
            
            [shift_idx1, shift_idx2, this_cc] = find_best_shift_limit(X_cluster{ci}{1}, X_cluster{ci}{tsi}, shift_lim_left, shift_lim_right);
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


        % [X_warp{ci}, M_warp{ci}] = align_cluster(X_cluster{ci}, ws, M_cluster{ci});
        tmp_other_mat = {};
        if nargin >= 2
            for oi = 1:length(other_mat)
                tmp_other_mat{oi} = other_mat{oi}{ci};
            end
        end
        [X_warp{ci}, tmp_other_warp] = align_cluster(X_cluster{ci}, ws, tmp_other_mat);
        if nargin >= 2
            for oi = 1:length(tmp_other_warp)
                other_warp{oi}{ci} = tmp_other_warp{oi};
            end
        end

        %% ----------
        %% DEBUG
        %%   plot cc
        if ~strcmp(figbase, '')
            range_left  = min(ts1_len, ceil(ts1_len*shift_lim_right));
            range_right = max(1, floor(ts1_len*shift_lim_left)) - 1 + ts2_len;
            range = [range_left:range_right];
            plot_cc(cc, range, ts2_len, [figbase '.do_shift.cc']);
            plot_offset(cc, range, ts2_len, [figbase '.do_shift.offset']);
            plot_best_cc(cc, range, ts2_len, [figbase '.do_shift.best_cc']);

            plot_rank_compare(X_cluster{ci}, ws, X_warp{ci}, [figbase '.do_shift.rank']);
        end
    end
end


%% find_best_shift_limit: function description
function [shift_idx1, shift_idx2, cc] = find_best_shift_limit(ts1, ts2, lim_left, lim_right)
    best_cc = -2;

    if length(ts2) < length(ts1) * (lim_right - lim_left)
        error(['ts1 len=' num2str(length(ts1)) ', ts2 len=' num2str(length(ts2))]);
    end
    
    % fprintf('ts1 %dx%d, ts2 %dx%d\n', size(ts1), size(ts2));
    % for idx = [1-length(ts2):length(ts1)-1]
    ts1_left  = max(1, floor(length(ts1)*lim_left));
    ts1_right = min(length(ts1), ceil(length(ts1)*lim_right));
    lim_idx_left  = ts1_right - length(ts2);
    lim_idx_right = ts1_left - 1;
    
    cc = ones(1, lim_idx_right+length(ts2)) * (-1);
    for idx = [lim_idx_left:lim_idx_right]
        [idx1_padded, idx2_padded] = shift_pad(length(ts1), length(ts2), idx);
        tmp1 = find(idx1_padded == ts1_left);
        tmp2 = find(idx1_padded == ts1_right);
        idx1_padded = idx1_padded(tmp1(1):tmp2(end));
        idx2_padded = idx2_padded(tmp1(1):tmp2(end));
        ts1_padded = ts1(idx1_padded);
        ts2_padded = ts2(idx2_padded);
        
        coeff = my_corrcoef(ts1_padded', ts2_padded');
        cc(1, idx+length(ts2)) = coeff(1,2);

        % fprintf('  idx %d: cc = %f (best = %f)\n', idx, cc(1, idx+length(ts2)), best_cc);
        if cc(1, idx+length(ts2)) > best_cc
            % fprintf('      > best\n');
            best_cc = cc(1, idx+length(ts2));
            shift_idx1 = idx1_padded;
            shift_idx2 = idx2_padded;
        end
    end

    %% best corrcoef is not updated -> ts2 might be all 0s
    if best_cc == -2
        [shift_idx1, shift_idx2] = shift_pad(length(ts1), length(ts2), 0);
        tmp1 = find(shift_idx1 == ts1_left);
        tmp2 = find(shift_idx1 == ts1_right);
        shift_idx1 = shift_idx1(tmp1(1):tmp2(end));
        shift_idx2 = shift_idx2(tmp1(1):tmp2(end));
    end
end


%% shift_pad: function description
%% idx: -2 -1  0  1  2  3  4  5  6  7  8
%% ts1:        1  2  3  4  5  6
%% ts2:  1  2  3  
function [idx1_padded, idx2_padded] = shift_pad(len1, len2, idx)
    idx1_padded = 1:len1;
    idx2_padded = 1:len2;

    %% ts1 padding
    ts1_pad_head = [];
    if idx < 0
        ts1_pad_head = ones(1, -idx) * idx1_padded(1);
    end
    
    ts1_pad_tail = [];
    if idx+len2 > len1
        ts1_pad_tail = ones(1, idx+len2-len1) * idx1_padded(end);
    end
    idx1_padded = [ts1_pad_head idx1_padded ts1_pad_tail];

    %% ts2 padding
    ts2_pad_head = [];
    if idx > 0
        ts2_pad_head = ones(1, idx) * idx2_padded(1);
    end
    
    ts2_pad_tail = [];
    if idx+len2 < len1
        ts2_pad_tail = ones(1, len1-idx-len2) * idx2_padded(end);
    end
    idx2_padded = [ts2_pad_head idx2_padded ts2_pad_tail];
end


%% ========================================
%% plot figures:

%% plot_cc: function description
function plot_cc(cc, range, ts2_len, figname)
    font_size = 12;
    colors   = {'r', 'b', [0 0.8 0], 'm', [1 0.85 0], [0 0 0.47], [0.45 0.17 0.48], 'k'};
    lines    = {'-', '--'};
    markers  = {'+', 'o', '*', '.', 'x', 's', 'd', '^', '>', '<', 'p', 'h'};

    max_cc = max(cc, [], 2);
    [tmp, sort_idx] = sort(max_cc, 'descend');
    plot_idx = sort_idx(1:min(5,end));
    
    fh = figure(1); clf;
    for li = 1:min(5, length(sort_idx))
        lh{li} = plot(range - ts2_len, cc(sort_idx(li), range));
        set(lh{li}, 'Color', colors{mod(li-1,length(colors))+1});
        set(lh{li}, 'LineStyle', lines{mod(li-1,length(lines))+1});  %% line  : -|--|:|-.
        set(lh{li}, 'LineWidth', 2);
        hold on;
        legends{li} = num2str(sort_idx(li));
    end

    set(gca, 'FontSize', font_size);
    xlabel('Offset', 'FontSize', font_size);
    ylabel('corrcoef', 'FontSize', font_size);

    % legend(legends, 'Location', 'Best');
    % legend(legends, 'Location', 'NorthEast');
    print(fh, '-depsc', [figname '.eps']);
end

%% plot_offset: function description
function plot_offset(cc, range, ts2_len, figname)
    font_size = 12;
    colors   = {'r', 'b', [0 0.8 0], 'm', [1 0.85 0], [0 0 0.47], [0.45 0.17 0.48], 'k'};
    lines    = {'-', '--'};
    markers  = {'+', 'o', '*', '.', 'x', 's', 'd', '^', '>', '<', 'p', 'h'};

    [max_cc, max_cc_idx] = max(cc(:, range), [], 2);
    max_cc_idx = range(max_cc_idx) - ts2_len;
    max_cc_idx(find(isnan(max_cc))) = 0;
    
    [f, x] = ecdf(max_cc_idx);
    p = f(2:end) - f(1:end-1);
    x = x(2:end);
    
    fh = figure(1); clf;
    li = 1;
    lh{li} = plot(x, p);
    set(lh{li}, 'Color', colors{mod(li-1,length(colors))+1});
    set(lh{li}, 'LineStyle', lines{mod(li-1,length(lines))+1});  %% line  : -|--|:|-.
    set(lh{li}, 'LineWidth', 4);
    
    set(gca, 'FontSize', font_size);
    xlabel('Offset', 'FontSize', font_size);
    ylabel('PDF', 'FontSize', font_size);

    % legend(legends, 'Location', 'Best');
    % legend(legends, 'Location', 'NorthEast');
    print(fh, '-depsc', [figname '.eps']);
end


%% plot_best_cc: function description
function plot_best_cc(cc, range, ts2_len, figname)
    font_size = 12;
    colors   = {'r', 'b', [0 0.8 0], 'm', [1 0.85 0], [0 0 0.47], [0.45 0.17 0.48], 'k'};
    lines    = {'-', '--'};
    markers  = {'+', 'o', '*', '.', 'x', 's', 'd', '^', '>', '<', 'p', 'h'};


    %% best corrcoef
    [max_cc, max_cc_idx] = max(cc(:, range), [], 2);
    [f, x] = ecdf(max_cc);

    fh = figure(1); clf;
    li = 1;
    lh{li} = plot(x, f);
    set(lh{li}, 'Color', colors{mod(li-1,length(colors))+1});
    set(lh{li}, 'LineStyle', lines{mod(li-1,length(lines))+1});  %% line  : -|--|:|-.
    set(lh{li}, 'LineWidth', 4);
    legends{li} = 'best cc';
    hold on;


    %% orig corrcoef
    offset0_cc = cc(:, ts2_len);
    [f, x] = ecdf(offset0_cc);
    
    li = li + 1;
    lh{li} = plot(x, f);
    set(lh{li}, 'Color', colors{mod(li-1,length(colors))+1});
    set(lh{li}, 'LineStyle', lines{mod(li-1,length(lines))+1});  %% line  : -|--|:|-.
    set(lh{li}, 'LineWidth', 4);
    legends{li} = 'orig cc';


    %% corrcoef improvement
    improve_cc = max_cc - offset0_cc;
    [f, x] = ecdf(improve_cc);
    
    li = li + 1;
    lh{li} = plot(x, f);
    set(lh{li}, 'Color', colors{mod(li-1,length(colors))+1});
    set(lh{li}, 'LineStyle', lines{mod(li-1,length(lines))+1});  %% line  : -|--|:|-.
    set(lh{li}, 'LineWidth', 4);
    legends{li} = 'cc improvement';

    
    set(gca, 'FontSize', font_size);
    xlabel('Best CorrCoef', 'FontSize', font_size);
    ylabel('CDF', 'FontSize', font_size);

    legend(legends, 'Location', 'NorthWest');
    % legend(legends, 'Location', 'NorthEast');
    print(fh, '-depsc', [figname '.eps']);
end

%% plot_rank_compare
function plot_rank_compare(X_cluster, ws, X_warp, figname)
    font_size = 12;
    colors   = {'r', 'b', [0 0.8 0], 'm', [1 0.85 0], [0 0 0.47], [0.45 0.17 0.48], 'k'};
    lines    = {'-', '--'};
    markers  = {'+', 'o', '*', '.', 'x', 's', 'd', '^', '>', '<', 'p', 'h'};


    %% ----------
    %% DEBUG
    for tsi = 3:length(ws)
        if nnz(ws{tsi}(:,1) - ws{2}(:,1)) > 0
            tsi
            [ws{2}(:,1) ws{tsi}(:,1)]
            error('should be the same');
        end
    end
    %% ----------

    tmp{1} = X_warp;
    rank_opt = 'percentile=0.8,num_seg=1,r_method=1';
    r_warp = get_rank(tmp, rank_opt);


    %% every ts shift to the "tsi" row
    for tsi = 1:length(ws)
        if tsi == 1
            this_ws = ws{2}(:, 1);
        else
            this_ws = ws{tsi}(:, 2);
        end

        tmp = {};
        for tsi2 = 1:length(ws)
            tmp{1}{tsi2} = X_cluster{tsi2}(this_ws);
        end
        r_other(tsi) = get_rank(tmp, rank_opt);
    end

    [f, x] = ecdf(r_other);


    fh = figure(1); clf;
    li = 1;
    lh{li} = plot(x, f);
    set(lh{li}, 'Color', colors{mod(li-1,length(colors))+1});
    set(lh{li}, 'LineStyle', lines{mod(li-1,length(lines))+1});  %% line  : -|--|:|-.
    set(lh{li}, 'LineWidth', 4);
    legends{li} = 'CDF of ranks';
    hold on;

    li = li + 1;
    lh{li} = plot([r_warp r_warp], [0 1]);
    set(lh{li}, 'Color', colors{mod(li-1,length(colors))+1});
    set(lh{li}, 'LineStyle', lines{mod(li-1,length(lines))+1});  %% line  : -|--|:|-.
    set(lh{li}, 'LineWidth', 4);
    legends{li} = 'rank after shift';


    r_other_mean = mean(r_other);
    li = li + 1;
    lh{li} = plot([r_other_mean r_other_mean], [0 1]);
    set(lh{li}, 'Color', colors{mod(li-1,length(colors))+1});
    set(lh{li}, 'LineStyle', lines{mod(li-1,length(lines))+1});  %% line  : -|--|:|-.
    set(lh{li}, 'LineWidth', 4);
    legends{li} = 'mean rank';


    set(gca, 'FontSize', font_size);
    xlabel('Rank', 'FontSize', font_size);
    ylabel('CDF', 'FontSize', font_size);

    legend(legends, 'Location', 'NorthWest');
    % legend(legends, 'Location', 'NorthEast');
    print(fh, '-depsc', [figname '.eps']);
end
