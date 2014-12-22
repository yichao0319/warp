%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Yi-Chao Chen @ UT Austin
%%
%% - Input:
%%   - est_collection
%%     - (1): orig value
%%     - (2): est value
%%     - (3): cluster idx
%%     - (4): cluster similarity
%%     - (5): missing element idx
%%
%%
%% - Output:
%%
%%
%% e.g.
%%
%%     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [mae, select_miss_elem] = evaluate_est_collection(est_collection, opt)
    %% --------------------
    %% DEBUG
    %% --------------------
    DEBUG0 = 0;
    DEBUG1 = 1;
    DEBUG2 = 1;

    
    %% --------------------
    %% Check input
    %% --------------------
    if nargin < 2, opt = ''; end
    

    %% --------------------
    %% Main starts
    %% --------------------
    no_dup = get_eval_opt(opt);


    select_miss_elem = [];
    if no_dup == 1
        %% --------------------
        %% only evaluate missing elements without being duplicate
        miss_cnt = histc(est_collection(5, :), 1:max(est_collection(5, :)));
        select_miss_elem = find(miss_cnt == 1);
        select_idx = find(ismember(est_collection(5,:), select_miss_elem) == 1);

        meanX = mean(abs(est_collection(1, select_idx)));
        mae = mean(abs((est_collection(1, select_idx) - est_collection(2, select_idx)))) / meanX;
    elseif no_dup == 2
        %% --------------------
        %% evaluate duplicate missing elements with avg
        cnt = 0;
        for miss_elem = 1:max(est_collection(5,:))
            miss_idx = find(est_collection(5,:) == miss_elem);
            if length(miss_idx) == 0
                continue;
            end

            cnt = cnt + 1;
            select_miss_elem = [select_miss_elem, miss_elem];
            avg_est(cnt) = mean(est_collection(2, miss_idx));
            avg_orig(cnt) = mean(est_collection(1, miss_idx));
            if avg_orig(cnt) ~= est_collection(1, miss_idx(1))
                error('different orig values for the same missing element');
            end
        end

        meanX = mean(abs(avg_orig(:)));
        mae = mean(abs((avg_est(:) - avg_orig(:)))) / meanX;
        
    elseif no_dup == 3
        %% --------------------
        %% pick the value from cluster with highest similarity
        cnt = 0;
        for miss_elem = 1:max(est_collection(5,:))
            miss_idx = find(est_collection(5,:) == miss_elem);
            if length(miss_idx) == 0
                continue;
            end

            cnt = cnt + 1;
            select_miss_elem = [select_miss_elem, miss_elem];
            %% find those with highest cluster similarity
            sim = max(est_collection(4, miss_idx));
            select_idx = find(est_collection(5,:) == miss_elem & est_collection(4, :) == sim);

            avg_est(cnt) = mean(est_collection(2, select_idx));
            avg_orig(cnt) = mean(est_collection(1, select_idx));
            if avg_orig(cnt) ~= est_collection(1, select_idx(1))
                error('different orig values for the same missing element');
            end
        end

        meanX = mean(abs(avg_orig(:)));
        mae = mean(abs((avg_est(:) - avg_orig(:)))) / meanX;

    else
        %% --------------------
        %% treat them equally
        select_miss_elem = unique(est_collection(5,:));

        meanX = mean(abs(est_collection(1,:)));
        mae = mean(abs((est_collection(2,:) - est_collection(1,:)))) / meanX;
    end

    
end


%% get_eval_opt: function description
function [no_dup] = get_eval_opt(opt)
    no_dup = 0;
    if nargin < 1, return; end

    opts = regexp(opt, ',', 'split');
    for this_opt = opts
        eval([char(this_opt) ';']);
    end
end

