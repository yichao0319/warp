%% ====================================
%% Yi-Chao@UT Austin
%%
%% match_single:
%%   get data in 3D format, seperate to training and testing, DTW and classification
%%
%% e.g.
%% ====================================

function [accuracy, classification] = match_single(trace_name, trace_opt, divide_opt, seed)
    addpath('/v/filer4b/v27q002/ut-wireless/yichao/warp/git_repository/task_match/mfcc');
    addpath('/v/filer4b/v27q002/ut-wireless/yichao/warp/git_repository/task_dtw/c_func');
    addpath('/v/filer4b/v27q002/ut-wireless/yichao/warp/git_repository/task_dtw');

    DEBUG0 = 0;
    DEBUG1 = 0;
    DEBUG2 = 0;  %% progress
    DEBUG3 = 0;  %% basic info
    DEBUG4 = 0;  %% process info
    DEBUG5 = 0;  %% final output
    DEBUG6 = 0;  %% show frequency shift

    if nargin < 1, trace_name = 'word'; end
    if nargin < 2, trace_opt = 'feature=''mfcc'''; end
    if nargin < 3, divide_opt = 'ratio=0.5'; end
    if nargin < 4, seed = 1; end

    % output_dir = '../../processed_data/task_match/match_single/';
    output_dir = '/u/yichao/warp/condor_data/task_match/condor/match_single/';

    rand('seed', seed);
    randn('seed', seed);

    tic;

    %% ======================
    %% get traces
    %% ======================
    if DEBUG2, fprintf('Get traces\n'); end

    [X, gt_class] = get_trace_match(trace_name, trace_opt);
    fprintf('  X: #rows = %d\n', length(X));
    fprintf('     #class (#rows=%d): %d (', length(gt_class), max(gt_class));
    fprintf('%d,', unique(gt_class));
    fprintf(')\n');


    %% ======================
    %% divide training and testing
    %% ======================
    if DEBUG2, fprintf('divide training and testing\n'); end

    [X_train, X_test, X_train_class, X_test_class] = divide_train_test(X, gt_class, divide_opt);
    fprintf('  #train class: %d\n', max(X_train_class));
    for ci = 1:max(X_train_class)
        fprintf('    class %d: #members=%d\n', ci, length(find(X_train_class==ci)));
    end
    fprintf('  #test class: %d\n', max(X_test_class));
    for ci = 1:max(X_test_class)
        fprintf('    class %d: #members=%d\n', ci, length(find(X_test_class==ci)));
    end


    %% ======================
    %% classify testing data
    %% ======================
    if DEBUG2, fprintf('classify test data\n'); end

    [pred_class] = classify_test(X_train, X_test, X_train_class);


    %% ======================
    %% evaluate classification
    %% ======================
    if DEBUG2, fprintf('evaluate classification\n'); end

    correct_cnt = nnz(~(pred_class - X_test_class));
    accuracy = correct_cnt / length(X_test_class);
    fprintf('  accuracy = %f\n', accuracy);

    elapsed_time = toc;
    fprintf('  time = %fs\n', elapsed_time);

    classification = zeros(max(gt_class), max(gt_class));
    for tsi = 1:length(X_test_class)
        classification(X_test_class(tsi), pred_class(tsi)) = classification(X_test_class(tsi), pred_class(tsi)) + 1;
    end

    output_name = [output_dir trace_name '.' trace_opt '.' divide_opt '.' num2str(seed)];
    dlmwrite([output_name '.accuracy.txt'], [accuracy, elapsed_time], 'delimiter', '\t');
    dlmwrite([output_name '.class.txt'], classification, 'delimiter', '\t');
    
end



