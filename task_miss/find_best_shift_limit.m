
%% find_best_shift_limit
function [shift_idx1, shift_idx2, cc] = find_best_shift_limit(ts1, ts2, lim_left, lim_right)
    addpath('/u/yichao/warp/git_repository/task_miss/c_func')
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
        [idx1_padded, idx2_padded] = shift_pad_c(length(ts1), length(ts2), idx);
        tmp1 = find(idx1_padded == ts1_left);
        tmp2 = find(idx1_padded == ts1_right);
        idx1_padded = idx1_padded(tmp1(end):tmp2(1));
        idx2_padded = idx2_padded(tmp1(end):tmp2(1));
        ts1_padded = ts1(idx1_padded);
        ts2_padded = ts2(idx2_padded);
        
        coeff = my_corrcoef(ts1_padded', ts2_padded');
        cc(1, idx+length(ts2)) = coeff(1,2);
        % fprintf(['idx=' num2str(idx) ': coef=' num2str(coeff(1,2)) '\n']);

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
        [shift_idx1, shift_idx2] = shift_pad_c(length(ts1), length(ts2), 0);
        tmp1 = find(shift_idx1 == ts1_left);
        tmp2 = find(shift_idx1 == ts1_right);
        shift_idx1 = shift_idx1(tmp1(1):tmp2(end));
        shift_idx2 = shift_idx2(tmp1(1):tmp2(end));
    end
end
