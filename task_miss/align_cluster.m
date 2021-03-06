%% align_cluster: function description
function [align_ts, align_other] = align_cluster(ts, ws, other_mat)
    align_other = {};

    possible_ws_values = sort(unique(ws{2}(:,1)));
    max_num = {};

    % for ti = 1:length(ts{1})
    for ti = possible_ws_values'
        max_num{ti} = 0;
        for tsi = 2:length(ts)
            this_num = length(find(ws{tsi}(:,1) == ti));
            if this_num > max_num{ti}
                max_num{ti} = this_num;
            end
        end

        for tsi = 2:length(ts)
            % ws{tsi}(:,1)'
            % tsi

            orig_ws_len = size(ws{tsi}, 1);
            idx = find(ws{tsi}(:,1) == ti);
            this_num = length(idx);
            num_dup = max_num{ti} - this_num + 1;

            % ws{tsi}(idx,1)'
            % ws{tsi}(idx,2)'
            
            dif = abs( ts{1}(ws{tsi}(idx,1)) - ts{tsi}(ws{tsi}(idx,2)) );
            [tmp, min_iidx] = min(dif);
            % min_iidx
            dup_idx = idx(min_iidx);
            tmp_w = [];
            tmp_w(1:dup_idx-1, :) = ws{tsi}(1:dup_idx-1, :);
            tmp_w(dup_idx:dup_idx+num_dup-1, :) = repmat(ws{tsi}(dup_idx, :), num_dup, 1);
            tmp_w(dup_idx+num_dup:num_dup+orig_ws_len-1, :) = ws{tsi}(dup_idx+1:end, :);
            ws{tsi} = tmp_w;

            idx = find(ws{tsi}(:,1) == ti);
            % ws{tsi}(idx,1)'
            % ws{tsi}(idx,2)'
            % if ti > 55
            %     input('----------------')
            % end
        end
    end

    align_ts{1} = ts{1}(ws{2}(:,1));
    % align_M{1}  = M{1}(ws{2}(:,1));
    if nargin >= 3
        for oi = 1:length(other_mat)
            align_other{oi}{1} = other_mat{oi}{1}(ws{2}(:,1));
        end
    end

    for tsi = 2:length(ts)
        if nnz(ws{2}(:,1) - ws{tsi}(:,1)) > 0
            error('ws are different');
        end

        align_ts{tsi} = ts{tsi}(ws{tsi}(:,2));
        % align_M{tsi}  = M{tsi}(ws{tsi}(:,2));
        if nargin >= 3
            for oi = 1:length(other_mat)
                align_other{oi}{tsi} = other_mat{oi}{tsi}(ws{tsi}(:,2));
            end
        end
    end
end
