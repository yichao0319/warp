%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Yi-Chao Chen @ UT Austin
%%
%%  match_group:
%%  1. get data in the format:
%%     user_1,feature_1: sample_1, 2, ..., s1
%%     ...
%%     user_1,feature_n: sample_1, 2, ..., s1
%%     user_2,feature_1: sample_1, 2, ..., s2
%%     ...
%%     user_2,feature_n: sample_1, 2, ..., s2
%%     ...
%% 2. find dominating features:
%%     project data points to each feature and apply greedy search
%% 3. in training data, cluster users in the same class/activity, and find cluster head
%% 4. in testing data, calculate the similarity to each cluster and 
%%      choose the one with max similarity as the similarity to the class/activity.
%% 5. the testing data is classified to the class with max similarity
%%
%% - Input:
%%   - trace_opt: to get trace data as the input
%%     e.g. feature=''raw''
%%     > feature: preprocessing of input data
%%       - speech: raw, mfcc, spectrogram, lowrank
%%       - EEG: raw, mfcc, spectrogram, lowrank
%%       - Accelerometer: raw, quantization, lowrank, lowrank_quantization, 
%%                        mag, mag_quantization
%%
%%   - feature_opt: to get the dominating features
%%     e.g. num=0
%%     > num: number of features. 
%%       - num < 0: use all features
%%       - num = 0: use the best number
%%
%%   - divide_opt: to divide data into training and testing set
%%     e.g. ratio=0.5
%%     > ratio: ratio of training data
%%
%%   - cluster_opt: to cluster training data within a class/activity
%%     e.g. method=''kmeans'',num=2
%%     > method: kmeans
%%     > num: number of cluster
%%
%%   - sync_opt: to sync rows
%%     e.g. sync=''shift'',metric=''coeff''
%%     > sync: shift, stretch
%%     > metric: coeff, dist
%%
%% - Output:
%%
%%
%% e.g.
%%   match_group('word', 'feature=''spectrogram''', 'num=0', 'ratio=0.5', 'method=''kmeans'',num=2', 'sync=''shift'',metric=''coeff''', 1)
%%     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [accuracy, classification] = match_group(trace_name, trace_opt, feature_opt, divide_opt, cluster_opt, sync_opt, seed)
    addpath('/v/filer4b/v27q002/ut-wireless/yichao/warp/git_repository/task_match/mfcc');
    addpath('/v/filer4b/v27q002/ut-wireless/yichao/warp/git_repository/task_match/c_func');
    % addpath('/v/filer4b/v27q002/ut-wireless/yichao/warp/git_repository/task_dtw');
    
    %% --------------------
    %% DEBUG
    %% --------------------
    DEBUG0 = 0;
    DEBUG1 = 0;
    DEBUG2 = 0;  %% progress
    DEBUG3 = 0;  %% verbose

    %% --------------------
    %% Constant
    %% --------------------
    

    %% --------------------
    %% Variable
    %% --------------------
    % output_dir = '../../processed_data/task_match/match_group/';
    output_dir = '/u/yichao/warp/condor_data/task_match/condor/match_group/';


    %% --------------------
    %% Check input
    %% --------------------
    if nargin < 1, trace_name = 'word'; end
    if nargin < 2, trace_opt = 'feature=''mfcc'''; end
    if nargin < 3, feature_opt = 'num=0'; end
    if nargin < 4, divide_opt = 'ratio=0.5'; end
    if nargin < 5, cluster_opt = 'method=''kmeans'',num=1'; end
    if nargin < 6, sync_opt = 'sync=''shift'',metric=''coeff'''; end
    if nargin < 7, seed = 1; end
    if nargin > 7, error(['wrong number of input:' num2str(nargin)]); end


    %% --------------------
    %% Main starts
    %% --------------------
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
    %% find the dominate features
    %% ======================
    if DEBUG2, fprintf('find the dominate features\n'); end

    this_feature_opt = [feature_opt ',' sync_opt];
    X_feature = extract_features(X, gt_class, this_feature_opt);
    if DEBUG3, 
        fprintf('  #features=%d\n', size(X_feature{1},1));
    end


    %% ======================
    %% divide training and testing
    %% ======================
    if DEBUG2, fprintf('divide training and testing\n'); end

    [X_train, X_test, X_train_class, X_test_class] = divide_train_test(X_feature, gt_class, divide_opt);
    fprintf('  #train class: %d\n', max(X_train_class));
    for ci = 1:max(X_train_class)
        fprintf('    class %d: #members=%d\n', ci, length(find(X_train_class==ci)));
    end
    fprintf('  #test class: %d\n', max(X_test_class));
    for ci = 1:max(X_test_class)
        fprintf('    class %d: #members=%d\n', ci, length(find(X_test_class==ci)));
    end


    %% ======================
    %% in training data, cluster each activity
    %% ======================
    if DEBUG2, fprintf('training data: cluster each class\n'); end

    for ai = 1:max(gt_class)
        this_opt = [cluster_opt ',' sync_opt];
        idx = find(X_train_class == ai);
        for ii = 1:length(idx)
            iidx = idx(ii);
            tmp_X{ii} = X_train{iidx};
        end

        X_cluster{ai} = cluster_a_class(tmp_X, this_opt);

        if DEBUG3, 
            fprintf('  activity %d: #cluster=%d\n', ai, length(X_cluster{ai}));
        end
    end


    %% ======================
    %% in testing data, compute the similarity to each cluster of an activity,
    %%   and pick the best one as the similarity to the activity
    %% ======================
    if DEBUG2, fprintf('testing data: classify data\n'); end

    for ti = 1:length(X_test_class)
        similarity = [];
        for ai = 1:max(gt_class)
            similarity(ai) = cal_similarity(X_test{ti}, X_cluster{ai}, sync_opt);
        end

        [val, idx] = max(similarity);
        est_class(ti) = idx;
    end

    elapsed_time = toc;
    fprintf('  time = %fs\n', elapsed_time);


    %% ======================
    %% evaluate classification
    %% ======================
    if DEBUG2, fprintf('evaluate classification\n'); end

    correct_cnt = nnz(~(est_class - X_test_class));
    accuracy = correct_cnt / length(X_test_class);
    fprintf('  accuracy = %f\n', accuracy);
    
    classification = zeros(max(gt_class), max(gt_class));
    for tsi = 1:length(X_test_class)
        classification(X_test_class(tsi), est_class(tsi)) = classification(X_test_class(tsi), est_class(tsi)) + 1;
    end
    fprintf('  classification:\n');
    classification


    %% ======================
    %% output
    %% ======================
    if DEBUG2, fprintf('output\n'); end

    % trace_name, trace_opt, feature_opt, divide_opt, cluster_opt, sync_opt, seed
    output_name = [output_dir trace_name '.' trace_opt '.' feature_opt '.' divide_opt '.' cluster_opt '.' sync_opt '.' num2str(seed)];
    dlmwrite([output_name '.accuracy.txt'], [accuracy, elapsed_time], 'delimiter', '\t');
    dlmwrite([output_name '.class.txt'], classification, 'delimiter', '\t');

end


