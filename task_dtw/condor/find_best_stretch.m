
function [best_stretch_idx1, best_stretch_idx2, best_coeff] = find_best_stretch(ts1, ts2)
    [best_stretch_idx1, best_stretch_idx2, best_coeff] = find_best_stretch_order(ts1, ts2);
    [stretch_idx2, stretch_idx1, coeff]                = find_best_stretch_order(ts2, ts1);
    
    if coeff > best_coeff
        best_coeff = coeff;
        best_stretch_idx1 = stretch_idx1;
        best_stretch_idx2 = stretch_idx2;
    end
end

%% find_best_stretch_order: function description
function [best_stretch_idx1, best_stretch_idx2, best_coeff] = find_best_stretch_order(ts1, ts2)
    DEBUG_TIME = 0;

    itvls = [2:6];
    insets = [1:5];

    best_coeff = -1;
    best_stretch_idx1 = 1:length(ts1);
    best_stretch_idx2 = 1:length(ts2);

    for itvl = itvls
        % fprintf('itvl: %d\n', itvl);
        tic;
        [stretch_ts1, stretch_idx1] = stretch_ts(ts1, itvl, 1);
        if DEBUG_TIME, fprintf('[TIME] stretch ts = %f\n', toc); end

        % fprintf('-- itvl %d ----------\n', itvl);
        % stretch_ts1
        % stretch_idx1
        % fprintf('-- end itvl %d ----------\n', itvl);
        stretch_ts2 = ts2;
        stretch_idx2 = 1:length(ts2);
        
        tic;
        [idx1, idx2, coeff] = find_best_sub_shift(stretch_ts1, stretch_ts2);
        if DEBUG_TIME, fprintf('[TIME] best sub shift = %f\n', toc); end
        % fprintf('-- itvl %d sub shift ----------\n', itvl);
        % coeff
        % idx1
        % idx2
        % fprintf('-- end itvl %d sub shift ----------\n', itvl);
        % input('...............')

        stretch_ts1 = stretch_ts1(idx1);
        stretch_idx1 = stretch_idx1(idx1);
        stretch_ts2 = stretch_ts2(idx2);
        stretch_idx2 = stretch_idx2(idx2);
        % fprintf('-- itvl %d final ----------\n', itvl);
        % stretch_idx1(end)
        % stretch_idx2(end)
        % fprintf('-- end itvl %d final ----------\n', itvl);
        % input('...............')

        %% -----------
        %% DEBUG
        % tmp_coeff = corrcoef(stretch_ts1', stretch_ts2');
        % if (tmp_coeff(1,2) - coeff) > eps
        %     error('something wrong...');
        % end
        %% -----------

        if coeff > best_coeff
            best_coeff = coeff;
            best_stretch_idx1 = stretch_idx1;
            best_stretch_idx2 = stretch_idx2;
        end
    end

    for inset = insets
        % fprintf('inset: %d\n', inset);
        tic;
        [stretch_ts1, stretch_idx1] = stretch_ts(ts1, 1, inset);
        if DEBUG_TIME, fprintf('[TIME] stretch ts = %f\n', toc); end
        stretch_ts2 = ts2;
        stretch_idx2 = 1:length(ts2);
        % fprintf('-- inset %d ----------\n', inset);
        % coeff
        % stretch_idx1(end)
        % stretch_idx2(end)
        % fprintf('-- end inset %d ----------\n', inset);
        % input('...............')
        
        tic;
        [idx1, idx2, coeff] = find_best_sub_shift(stretch_ts1, ts2);
        if DEBUG_TIME, fprintf('[TIME] best sub shift = %f\n', toc); end
        stretch_ts1 = stretch_ts1(idx1);
        stretch_idx1 = stretch_idx1(idx1);
        stretch_ts2 = stretch_ts2(idx2);
        stretch_idx2 = stretch_idx2(idx2);

        % fprintf('-- inset %d final ----------\n', inset);
        % coeff
        % stretch_idx1(end)
        % stretch_idx2(end)
        % fprintf('-- end inset %d final ----------\n', inset);
        % input('...............')

        %% -----------
        %% DEBUG
        % tmp_coeff = corrcoef(stretch_ts1', stretch_ts2');
        % if tmp_coeff(1,2) ~= coeff
        %     error('something wrong...');
        % end
        %% -----------

        if coeff > best_coeff
            best_coeff = coeff;
            best_stretch_idx1 = stretch_idx1;
            best_stretch_idx2 = stretch_idx2;
        end
    end
end

