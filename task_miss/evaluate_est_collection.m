%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Yi-Chao Chen @ UT Austin
%%
%% - Input:
%%   - est_collection: 2D data
%%       (1,:): orig value
%%       (2,:): est value
%%       (3,:): cluster idx
%%       (4,:): cluster similarity
%%       (5,:): missing element idx
%%   - opt
%%     > dup: 
%%       how deal with duplicate missing elements
%%       - no: only evaluate missing elements without duplicate
%%       - avg: take average
%%       - best: pick the value from cluster with highest similarity
%%       - equal: treat all missing elements equally
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
    DEBUG3 = 1;

    
    %% --------------------
    %% Check input
    %% --------------------
    if nargin < 2, opt = ''; end
    

    %% --------------------
    %% Main starts
    %% --------------------
    dup = get_eval_opt(opt);


    select_miss_elem = [];
    if strcmp(dup, 'no')
        %% --------------------
        %% only evaluate missing elements without duplicate
        miss_cnt = histc(est_collection(5, :), 1:max(est_collection(5, :)));
        select_miss_elem = find(miss_cnt == 1);
        select_idx = find(ismember(est_collection(5,:), select_miss_elem) == 1);

        if DEBUG3
            fprintf('    orig (len=%d): ', length(est_collection(1, select_idx)));
            for si = 1:min(length(est_collection(1, select_idx)), 10)
                fprintf('%.2f,', est_collection(1, select_idx(si)));
            end
            fprintf('\n');
            fprintf('    esti (len=%d): ', length(est_collection(2, select_idx)));
            for si = 1:min(length(est_collection(2, select_idx)), 10)
                fprintf('%.2f,', est_collection(2, select_idx(si)));
            end
            fprintf('\n');
        end

        if length(select_idx) > 0
            meanX = mean(abs(est_collection(1, select_idx)));
            mae = mean(abs((est_collection(1, select_idx) - est_collection(2, select_idx)))) / meanX;
        else
            mae = NaN;
        end
            

    elseif strcmp(dup, 'avg')
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

        if DEBUG3
            fprintf('    orig (len=%d): ', length(avg_orig));
            for si = 1:min(length(avg_orig), 10)
                fprintf('%.2f,', avg_orig(1,si));
            end
            fprintf('\n');
            fprintf('    esti (len=%d): ', length(avg_est));
            for si = 1:min(length(avg_est), 10)
                fprintf('%.2f,', avg_est(1,si));
            end
            fprintf('\n');
        end

        meanX = mean(abs(avg_orig(:)));
        mae = mean(abs((avg_est(:) - avg_orig(:)))) / meanX;
        
    elseif strcmp(dup, 'best')
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
        
        if DEBUG3
            fprintf('    orig (len=%d): ', length(avg_orig));
            for si = 1:min(length(avg_orig), 10)
                fprintf('%.2f,', avg_orig(1,si));
            end
            fprintf('\n');
            fprintf('    esti (len=%d): ', length(avg_est));
            for si = 1:min(length(avg_est), 10)
                fprintf('%.2f,', avg_est(1,si));
            end
            fprintf('\n');
        end

        meanX = mean(abs(avg_orig(:)));
        mae = mean(abs((avg_est(:) - avg_orig(:)))) / meanX;
        
    elseif strcmp(dup, 'equal')
        %% --------------------
        %% treat them equally
        select_miss_elem = unique(est_collection(5,:));

        if DEBUG3
            fprintf('    orig (len=%d): ', length(est_collection(1,:)));
            for si = 1:min(length(est_collection(1,:)), 10)
                fprintf('%.2f,', est_collection(1,si));
            end
            fprintf('\n');
            fprintf('    esti (len=%d): ', length(est_collection(2,:)));
            for si = 1:min(length(est_collection(2,:)), 10)
                fprintf('%.2f,', est_collection(2,si));
            end
            fprintf('\n');
        end

        meanX = mean(abs(est_collection(1,:)));
        mae = mean(abs((est_collection(2,:) - est_collection(1,:)))) / meanX;
    end

end


%% get_eval_opt: function description
function [dup] = get_eval_opt(opt)
    dup = 'avg';
    
    opts = regexp(opt, ',', 'split');
    for this_opt = opts
        eval([char(this_opt) ';']);
    end
end

