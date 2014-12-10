%% class_test: function description
function [pred_class] = classify_test(X_train, X_test, X_train_class)
    addpath('/v/filer4b/v27q002/ut-wireless/yichao/warp/git_repository/task_dtw/c_func');

    DEBUG2 = 1;
    DEBUG3 = 1;

    for test_i = 1:length(X_test)
        if DEBUG2, fprintf('    test %d:\n', test_i); end

        dist = [];
        for ci = 1:max(X_train_class)
            train_idx = find(X_train_class == ci);
            if DEBUG3, fprintf('      class %d: #train=%d ', ci, length(train_idx)); end

            for train_i = 1:length(train_idx)
                this_train_idx = train_idx(train_i);
                dist(ci, train_i) = dtw_c_orig(X_test{test_i}', X_train{this_train_idx}');

                if DEBUG3, fprintf('%f,', dist(ci, train_i)); end
            end

            if DEBUG3, fprintf(' (%f)\n', mean(dist(ci,:))); end
        end

        [val, min_dist_class] = min(mean(dist, 2));
        pred_class(test_i) = min_dist_class;
        if DEBUG2, fprintf('      > class %d\n', pred_class(test_i)); end
    end
end
