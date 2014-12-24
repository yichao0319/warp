%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Yi-Chao Chen @ UT Austin
%%
%% align_for_sync
%%
%% - Input:
%%   - X: the 3D data
%%        1st dim (cell): subjects / words / ...
%%        2nd dim (matrix): features
%%        3rd dim (matrix): samples over time
%%
%%   - ws: a 3D data to indicate the new index to sync with 1st subject
%%        1st dim (cell): subjects, start from 2
%%        2nd/3rd dim (matrix): new index.
%%                              1st column for 1st subject;
%%                              2nd column for this subject.
%%
%%   - other_mat: the 4D data
%%        the matrices to be sync as X
%%        1st dim (cell): all matrices
%%        2nd dim (cell): subjects / words / ...
%%        3rd dim (matrix): features
%%        4th dim (matrix): samples over time
%%         
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [align_X, align_other] = align_for_sync(X, ws, other_mat)
    align_other = {};

    possible_ws_values = sort(unique(ws{2}(:,1)));
    max_num = {};

    % for ti = 1:length(X{1})
    for ti = possible_ws_values'
        max_num{ti} = 0;
        for tsi = 2:length(X)
            this_num = length(find(ws{tsi}(:,1) == ti));
            if this_num > max_num{ti}
                max_num{ti} = this_num;
            end
        end

        for tsi = 2:length(X)
            % ws{tsi}(:,1)'
            % tsi

            orig_ws_len = size(ws{tsi}, 1);
            idx = find(ws{tsi}(:,1) == ti);
            this_num = length(idx);
            num_dup = max_num{ti} - this_num + 1;

            % ws{tsi}(idx,1)'
            % ws{tsi}(idx,2)'
            
            dif = norm(abs( X{1}(:, ws{tsi}(idx,1)) - X{tsi}(:, ws{tsi}(idx,2)) ), 2);
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

    align_X{1} = X{1}(:, ws{2}(:,1));
    % align_M{1}  = M{1}(ws{2}(:,1));
    for oi = 1:length(other_mat)
        align_other{oi}{1} = other_mat{oi}{1}(:, ws{2}(:,1));
    end

    for tsi = 2:length(X)
        if nnz(ws{2}(:,1) - ws{tsi}(:,1)) > 0
            error('ws are different');
        end

        align_X{tsi} = X{tsi}(:, ws{tsi}(:,2));
        % align_M{tsi}  = M{tsi}(ws{tsi}(:,2));
        for oi = 1:length(other_mat)
            align_other{oi}{tsi} = other_mat{oi}{tsi}(:, ws{tsi}(:,2));
        end
    end
end
