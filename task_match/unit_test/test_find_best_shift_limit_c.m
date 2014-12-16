%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Yi-Chao Chen @ UT Austin
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function test_find_best_shift_limit_c()
    addpath('../c_func');
    
    %% --------------------
    %% DEBUG
    %% --------------------
    DEBUG0 = 0;
    DEBUG1 = 1;
    DEBUG2 = 1;


    %% --------------------
    %% Constant
    %% --------------------
    lim_left  = 1/4;
    lim_right = 3/4;
    % lim_left  = 0;
    % lim_right = 1;


    %% --------------------
    %% Variable
    %% --------------------
    cnt = 1;
    test{cnt} = 'coeff';
    metric{cnt} = 1; %% coeff
    X{cnt}{1}(1, :) = [1:5   10:-1:1  1:5];
    X{cnt}{1}(2, :) = [11:15 20:-1:11 11:15];

    X{cnt}{2}(1, :) = [11:15   20:-1:11  11:15];
    X{cnt}{2}(2, :) = [21:25 30:-1:21 21:25];

    
    cnt = cnt + 1;
    test{cnt} = 'dist';
    metric{cnt} = 2; %% coeff
    X{cnt}{1}(1, :) = [1:5   10:-1:1  1:5];
    X{cnt}{1}(2, :) = [11:15 20:-1:11 11:15];

    X{cnt}{2}(1, :) = [11:15   20:-1:11  11:15];
    X{cnt}{2}(2, :) = [21:25 30:-1:21 21:25];


    cnt = cnt + 1;
    test{cnt} = 'dist';
    metric{cnt} = 2; %% coeff
    X{cnt}{1}(1, :) = [ones(1,20)*99];
    
    X{cnt}{2}(1, :) = [ones(1,10) ones(1,10)*99];


    cnt = cnt + 1;
    test{cnt} = 'dist';
    metric{cnt} = 2; %% coeff
    X{cnt}{1}(1, :) = [ones(1,20)*99];
    
    X{cnt}{2}(1, :) = [ones(1,5) ones(1,5)*99 ones(1,10)*5];



    %% --------------------
    %% Main starts
    %% --------------------
    for ti = 1:length(test)
        fprintf('=====================================\n');
        fprintf('TEST: %s\n', char(test{ti}));
        X{ti}{1}
        X{ti}{2}
        [shift_idx1, shift_idx2, total_cc] = find_best_shift_limit_c(X{ti}{1}', X{ti}{2}', lim_left, lim_right, metric{ti});
        X{ti}{1}(:, shift_idx1)
        X{ti}{2}(:, shift_idx2)
        total_cc
        input('========================================\n');
    end
end