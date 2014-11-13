
function [dtw_ts] = do_dtw(ts, opt)
    DEBUG_TIME = 0;

    num_seg = get_dtw_opt(opt);

    for ci = 1:length(ts)
        % dtw_ts{1} = ts{1};
        if length(ts{ci}) == 1
            dtw_ts{ci} = ts{ci};
            continue;
        end

        seg_size1 = ceil(length(ts{ci}{1}) / num_seg);
        for tsi = 2:length(ts{ci})
            seg_size2 = ceil(length(ts{ci}{tsi}) / num_seg);
            ws{tsi} = [];

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
        dtw_ts{ci} = align_cluster(ts{ci}, ws);
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

