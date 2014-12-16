%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Yi-Chao Chen @ UT Austin
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function test_cal_cluster_obj()
    addpath('../');
    
    %% --------------------
    %% DEBUG
    %% --------------------
    DEBUG0 = 0;
    DEBUG1 = 1;
    DEBUG2 = 1;


    %% --------------------
    %% Constant
    %% --------------------
    

    %% --------------------
    %% Variable
    %% --------------------
    % get_affinity(X, sync, metric, aff_type)

    cnt = 1;
    test{cnt} = 'shift, coeff, mat';
    sync{cnt} = 'shift';
    metric{cnt} = 'coeff'; %% coeff
    X{cnt}{1}(1, :) = [1:20];
    X{cnt}{1}(2, :) = [11:30];
    % X{cnt}{1}(3, :) = randi(100, 1, 20);
    X{cnt}{2}(1, :) = [11:30];
    X{cnt}{2}(2, :) = [21:40];
    % X{cnt}{2}(3, :) = randi(100, 1, 20);
    X{cnt}{3}(1, :) = [20:-1:1];
    X{cnt}{3}(2, :) = [30:-1:11];
    % X{cnt}{3}(3, :) = randi(100, 1, 20);
    X{cnt}{4}(1, :) = [30:-1:11];
    X{cnt}{4}(2, :) = [40:-1:21];
    % X{cnt}{4}(3, :) = randi(100, 1, 20);
    X{cnt}{5}(1, :) = [40:-1:21];
    X{cnt}{5}(2, :) = [50:-1:31];
    % X{cnt}{5}(3, :) = randi(100, 1, 20);
    gt_class{cnt} = [1 1 2 2 2];

    cnt = cnt + 1;
    test{cnt} = 'shift, dist, mat';
    sync{cnt} = 'shift';
    metric{cnt} = 'dist'; %% coeff
    aff_type{cnt} = 'mat';
    num(cnt) = 2;
    X{cnt}{1}(1, :) = ones(1,20)*5;
    X{cnt}{1}(2, :) = ones(1,20)*99;
    % X{cnt}{1}(3, :) = randi(100, 1, 20);
    X{cnt}{2}(1, :) = ones(1,20)*6;
    X{cnt}{2}(2, :) = ones(1,20)*100;
    % X{cnt}{2}(3, :) = randi(100, 1, 20);
    X{cnt}{3}(1, :) = ones(1,20)*100;
    X{cnt}{3}(2, :) = ones(1,20)*1;
    % X{cnt}{3}(3, :) = randi(100, 1, 20);
    X{cnt}{4}(1, :) = ones(1,20)*99;
    X{cnt}{4}(2, :) = ones(1,20)*2;
    % X{cnt}{4}(3, :) = randi(100, 1, 20);
    X{cnt}{5}(1, :) = ones(1,20)*98;
    X{cnt}{5}(2, :) = ones(1,20)*3;
    % X{cnt}{5}(3, :) = randi(100, 1, 20);
    gt_class{cnt} = [1 1 2 2 2];



    %% --------------------
    %% Main starts
    %% --------------------
    for ti = 1:length(test)
        fprintf('=====================================\n');
        fprintf('TEST %d: %s\n', ti, char(test{ti}));
        [X{ti}{1};
        X{ti}{2};
        X{ti}{3};
        X{ti}{4};
        X{ti}{5}]
        
        opt = ['sync=''' char(sync{ti}) ''',metric=''' char(metric{ti}) ''''];
        obj = cal_cluster_obj(X{ti}, gt_class{ti}, opt);
        obj
        input('========================================\n');
    end
end