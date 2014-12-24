% function [ts1_idx, ts2_idx, best_coeff] = find_best_sub_shift(ts1, ts2)
%     best_coeff = -1;
%     if length(ts1) >= length(ts2)
%         ts1_idx = 1:length(ts1);
%         ts2_idx = [1:length(ts2), repmat(length(ts2), 1, length(ts1)-length(ts2))];
%     else
%         ts2_idx = 1:length(ts2);
%         ts1_idx = [1:length(ts1), repmat(length(ts1), 1, length(ts2)-length(ts1))];
%     end
% end


function [ts1_idx, ts2_idx, best_coeff] = find_best_sub_shift(ts1, ts2)
    addpath('/u/yichao/warp/git_repository/task_miss/c_func');

    if length(ts1) >= length(ts2)
        % [ts1_idx, ts2_idx, best_coeff] = find_best_sub_shift_order(ts1, ts2);
        [ts1_idx, ts2_idx, best_coeff] = find_best_sub_shift_order_c(ts1, ts2);
    else
        % [ts2_idx, ts1_idx, best_coeff] = find_best_sub_shift_order(ts2, ts1);
        [ts2_idx, ts1_idx, best_coeff] = find_best_sub_shift_order_c(ts2, ts1);
    end

    % size(ts1_idx)
    % size(ts2_idx)
    % ts1_idx(1:10)
    % ts2_idx(1:10)
    % input('........')
end


%% find_best_sub_shift_order: function description
function [ts1_idx, ts2_idx, best_coeff] = find_best_sub_shift_order(ts1, ts2)
    if length(ts1) < length(ts2)
        error('find_best_sub_shift_order: wrong order');
    end

    shift_offsets = 1:(1 + length(ts1) - length(ts2));

    ts1_idx = 1:length(ts1);
    ts2_idx = 1:length(ts2);


    best_coeff = -1;
    for offset = shift_offsets
        pad_before = ones(1, offset - 1) * ts2(1);
        pad_after  = ones(1, length(ts1) - length(ts2) - offset + 1)  * ts2(end);
        
        pad_before_idx = ones(1, offset - 1);
        pad_after_idx  = ones(1, length(ts1) - length(ts2) - offset + 1)  * length(ts2);
        
        pad_ts2 = [pad_before, ts2, pad_after];
        pad_ts2_idx = [pad_before_idx, 1:length(ts2), pad_after_idx];

        % this_coeff = corrcoef(ts1', pad_ts2');
        this_coeff = my_corrcoef(ts1', pad_ts2');
        this_coeff = this_coeff(1,2);

        if this_coeff > best_coeff
            best_coeff = this_coeff;
            ts2_idx = pad_ts2_idx;
        end
    end

end
