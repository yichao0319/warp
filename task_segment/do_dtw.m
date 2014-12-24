%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Yi-Chao Chen @ UT Austin
%%
%% - Input:
%%   - X: the 3D data
%%        1st dim (cell): subjects / words / ...
%%        2nd dim (matrix): features
%%        3rd dim (matrix): samples over time
%%
%%   - opt
%%     > num_seg: number of segments (do sync for each segment)
%%
%%   - other_mat: the 4D data
%%        the matrices to be sync as X
%%        1st dim (cell): all matrices
%%        2nd dim (cell): subjects / words / ...
%%        3rd dim (matrix): features
%%        4th dim (matrix): samples over time
%%
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [dtw_X, dtw_other] = do_dtw(X, opt, other_mat)
    addpath('/u/yichao/warp/git_repository/task_dtw/c_func');
    
    
    if nargin < 2, opt = ''; end
    if nargin < 3, other_mat = {}; end

    dtw_other = {};


    %% -------------------
    %% get options
    num_seg = get_dtw_opt(opt);


    %% -------------------
    %% only has member so don't need to sync
    if length(X) == 1
        dtw_X = X;

        for oi = 1:length(other_mat)
            dtw_other{oi} = other_mat{oi};
        end
        return;
    end


    seg_size1 = ceil(length(X{1}) / num_seg);
    %% for each subject
    for tsi = 2:length(X)
        seg_size2 = ceil(length(X{tsi}) / num_seg);
        ws{tsi} = [];

        %% for each segment
        for segi = 1:num_seg

            ts1 = X{1}(:, (segi-1)*seg_size1+1:min(segi*seg_size1,end));
            ts2 = X{tsi}(:, (segi-1)*seg_size2+1:min(segi*seg_size2,end));
            [Dist, D, k, w] = dtw_c(ts1' ,ts2');
                
            % fprintf('  %d: w size=%dx%d\n', tsi, size(w));
            w(:, 1) = w(:, 1) + (segi-1)*seg_size1;
            w(:, 2) = w(:, 2) + (segi-1)*seg_size2;
            
            ws{tsi} = cat(1, ws{tsi}, w);
        end
    end

    [dtw_X, dtw_other] = align_for_sync(X, ws, other_mat);
    
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

