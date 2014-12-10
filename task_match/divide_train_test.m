%% divide_train_test:
%% Output
%%   - X_train, X_test: 3D format
%%        1st dim (cell): words/subjects/...
%%        2nd dim (matrix): features
%%        3rd dim (matrix): samples over time
%%   - X_train_class, X_test_class: vector of ground-truth class 
%%        the class the word belongs to.
%%
function [X_train, X_test, X_train_class, X_test_class] = divide_train_test(X, gt_class, divide_opt)
    DEBUG2 = 0;

    if nargin < 3, divide_opt = ''; end

    [train_ratio] = get_divide_opt(divide_opt);


    train_cnt = 0;
    test_cnt = 0;    
    for ci = 1:max(gt_class)
        idx = find(gt_class == ci);
        %% -----------
        %% DEBUG
        if DEBUG2,
            fprintf('    class %d: ', ci);
            fprintf('%d,', idx);
            fprintf('\n');
        end
        %% -----------
        
        rand_iidx = randperm(length(idx));
        num_train = floor(length(idx)*train_ratio);
        num_train = min(length(idx)-1, max(1, num_train) );

        for ti = 1:length(idx)
            iidx = rand_iidx(ti);
            this_idx = idx(iidx);

            if ti <= num_train
                %% train

                %% -----------
                %% DEBUG
                if DEBUG2,
                    if ti == 1
                        fprintf('    train: ');
                    end
                    fprintf('%d,', this_idx);
                    if ti == num_train
                        fprintf('\n');
                    end
                end
                %% -----------

                train_cnt = train_cnt + 1;
                X_train{train_cnt} = X{this_idx};
                X_train_class(train_cnt) = ci;
            else
                %% test

                %% -----------
                %% DEBUG
                if DEBUG2,
                    if ti == num_train+1
                        fprintf('    test: ');
                    end
                    fprintf('%d,', this_idx);
                    if ti == length(idx)
                        fprintf('\n');
                    end
                end
                %% -----------

                test_cnt = test_cnt + 1;
                X_test{test_cnt} = X{this_idx};
                X_test_class(test_cnt) = ci;
            end
        end
    end
    
end


function [ratio] = get_divide_opt(opt)
    [ratio] = 0.5;
    if nargin < 1, return; end

    opts = regexp(opt, ',', 'split');
    for this_opt = opts
        eval([char(this_opt) ';']);
    end
end