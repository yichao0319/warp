%% - opt
%%   > num_seg
function [dtw_ts, dtw_other] = do_dtw(ts, opt, other_mat)
    DEBUG_TIME = 0;

    if nargin < 2, opt = ''; end
    if nargin < 3, other_mat = {}; end

    dtw_other = {};

    num_seg = get_dtw_opt(opt);

    %% for each cluster
    for ci = 1:length(ts)
        % dtw_ts{1} = ts{1};
        if length(ts{ci}) == 1
            dtw_ts{ci} = ts{ci};

            % dtw_M{ci} = M{ci};
            if nargin >= 3
                for oi = 1:length(other_mat)
                    dtw_other{oi}{ci} = other_mat{oi}{ci};
                end
            end
            continue;
        end

        seg_size1 = ceil(length(ts{ci}{1}) / num_seg);
        %% for each ts in the cluster
        for tsi = 2:length(ts{ci})
            seg_size2 = ceil(length(ts{ci}{tsi}) / num_seg);
            ws{tsi} = [];

            %% for each segment
            for segi = 1:num_seg

                ts1 = ts{ci}{1}(1, (segi-1)*seg_size1+1:min(segi*seg_size1,end));
                ts2 = ts{ci}{tsi}(1, (segi-1)*seg_size2+1:min(segi*seg_size2,end));
                [Dist, D, k, w] = dtw_c(ts1' ,ts2');
                    
                % fprintf('  %d: w size=%dx%d\n', tsi, size(w));
                w(:, 1) = w(:, 1) + (segi-1)*seg_size1;
                w(:, 2) = w(:, 2) + (segi-1)*seg_size2;
                
                ws{tsi} = cat(1, ws{tsi}, w);
            end
        end

        t1 = tic;

        tmp_other_mat = {};
        if nargin >= 3
            for oi = 1:length(other_mat)
                tmp_other_mat{oi} = other_mat{oi}{ci};
            end
        end
        [dtw_ts{ci}, tmp_dtw_other] = align_cluster(ts{ci}, ws, tmp_other_mat);
        if nargin >= 3
            for oi = 1:length(tmp_dtw_other)
                dtw_other{oi}{ci} = tmp_dtw_other{oi};
            end
        end

        if DEBUG_TIME, fprintf('[TIME] len:%d, time=%f\n', size(ws{2},1), toc(t1)); end
    end
end

%% get_dtw_opt: function description
function [num_seg] = get_dtw_opt(opt)
    num_seg = 1;
    if nargin < 1, return; end

    opts = regexp(opt, ',', 'split');
    for this_opt = opts
        eval([char(this_opt) ';']);
    end

    if num_seg < 0, num_seg = 1; end
end

