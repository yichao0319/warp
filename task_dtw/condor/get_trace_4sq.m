%% get_trace_4sq: function description
%% opt:
%%   - num_loc: number of rows to get
%%   - num_rep: number of replicates in columns
%%   - loc_type: the way to choose rows
%%         > 1: volume
%%         > 2: correlation coefficient
%%         > 3: dtw distance
%%         > 4: manually choose
function [X, bin, r] = get_trace_4sq(opt)
    [num_loc, num_rep, loc_type] = get_4sq_opt(opt);

    %% 3927*72
    %% Each row is a Place
    %% 12 2-hour slot*6 months = 72 columns (All checkins are aggregated monthly at 2-hourly slots)
    input_dir='/u/yichao/warp/data/foursquare/';
    X = load([input_dir 'foursquare.mat']);
    X = X.data;
    X(find(isnan(X))) = 0;
    X = X(:, 1:50);
    
    %% -----------
    %% modify 4sq
    X = repmat(X, 1, num_rep);
    %% -----------

    if loc_type == 1
        %% volumn
        X = get_subset_ts_vol(X, num_loc);
    elseif loc_type == 2
        %% correlation coefficient
        X = get_subset_ts_cc(X, num_loc);
    elseif loc_type == 3
        %% dtw distance
        X = X(1:1000, :);
        X = get_subset_ts_dtw(X, num_loc);
    elseif loc_type == 4
        %% manual choose
        X = get_subset_ts_vol2(X, num_loc);
    end
    
    r = 20;
    bin = 2*60*60;
end


%% get_4sq_opt: function description
function [num_loc, num_rep, loc_type] = get_4sq_opt(opt)
    num_loc = Inf;
    num_rep = 1;
    loc_type = 1;

    opts = regexp(opt, ',', 'split');
    for this_opt = opts
        eval([char(this_opt) ';']);
    end
end


%% get_subset_ts_cc: function description
function [X_subset] = get_subset_ts_cc(X, k)
    best_r = 1;
    best_cc = 0;
    cc = corrcoef(X');
    for ri = 1:size(cc, 1)
        tmp = sort(cc(ri, :), 'descend');
        top_cc = sum(tmp(1:min(k,end)));
        if top_cc > best_cc
            best_cc = top_cc;
            best_r = ri;
        end
    end

    [tmp, best_idx] = sort(cc(best_r, :), 'descend');
    best_idx = best_idx(1:k);
    X_subset = X(best_idx, :);
end

%% get_subset_ts_cc: function description
function [X_subset] = get_subset_ts_dtw(X, k)
    best_r = 1;
    best_affinity = 0;

    % 
    affinity = zeros(size(X,1), size(X,1));
    for x1 = 1:size(X, 1)-1
        for x2 = x1+1:size(X, 1)
            dist = dtw_c_orig(X(x1,:)' ,X(x2,:)');
            affinity(x1, x2) = -dist;
            affinity(x2, x1) = -dist;
        end
    end
    
    for ri = 1:size(affinity, 1)
        tmp = sort(affinity(ri, :), 'descend');
        top_affinity = sum(tmp(1:min(k,end)));
        if top_affinity > best_affinity
            best_affinity = top_affinity;
            best_r = ri;
        end
    end

    [tmp, best_idx] = sort(affinity(best_r, :), 'descend');
    best_idx = best_idx(1:k);
    X_subset = X(best_idx, :);
end

%% get_subset_ts_vol: function description
function [X_subset] = get_subset_ts_vol(X, k)
    x_size = sum(X, 2);
    [tmp, size_idx] = sort(x_size, 'descend');
    X_subset = X(size_idx(1:min(k, end)), :);
end

function [X_subset] = get_subset_ts_vol2(X, k)
    x_size = sum(X, 2);
    [tmp, size_idx] = sort(x_size, 'descend');

    % for tsi = 1:5:100
    %     fh = figure(1); clf;
    %     plot(X(size_idx(tsi:tsi+4), :)');
    %     legend({});
    %     print(fh, '-depsc', ['./tmp/tmp.ts' num2str(tsi) '.eps']);
    % end

    % not_ok_idx = [8, 18, 19, 23, 27, 32, 34, 45];
    % ok_idx = setxor([1:10], not_ok_idx);
    ok_idx = [1:10];
    % X_subset = X(size_idx(ok_idx), :);

    X_set1 = X(size_idx(ok_idx), 10:end);
    X_set2 = X(size_idx(ok_idx), 1:end-9);
    X_set3 = X(size_idx(ok_idx), 2:end-8);
    X_set4 = X(size_idx(ok_idx), 3:end-7);
    X_set5 = X(size_idx(ok_idx), 4:end-6);
    X_set6 = X(size_idx(ok_idx), 5:end-5);
    X_set7 = X(size_idx(ok_idx), 6:end-4);
    X_set8 = X(size_idx(ok_idx), 7:end-3);
    X_set9 = X(size_idx(ok_idx), 8:end-2);
    X_set10 = X(size_idx(ok_idx), 9:end-1);
    X_subset = [X_set1; X_set2; X_set3; X_set4; X_set5; X_set6; X_set7; X_set8; X_set9; X_set10];

end