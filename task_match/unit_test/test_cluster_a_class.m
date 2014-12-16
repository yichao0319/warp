%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Yi-Chao Chen @ UT Austin
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function test_cluster_a_class()
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
    aff_type{cnt} = 'mat';
    num(cnt) = 2;
    X{cnt}{1}(1, :) = [1:20];
    X{cnt}{2}(1, :) = [11:30];
    X{cnt}{3}(1, :) = [20:-1:1];
    X{cnt}{4}(1, :) = [30:-1:11];
    X{cnt}{5}(1, :) = [40:-1:21];


    cnt = cnt + 1;
    test{cnt} = 'shift, dist, mat';
    sync{cnt} = 'shift';
    metric{cnt} = 'dist'; %% coeff
    aff_type{cnt} = 'mat';
    num(cnt) = 2;
    X{cnt}{1}(1, :) = ones(1,20)*5;
    X{cnt}{2}(1, :) = ones(1,20)*6;
    X{cnt}{3}(1, :) = ones(1,20)*100;
    X{cnt}{4}(1, :) = ones(1,20)*99;
    X{cnt}{5}(1, :) = ones(1,20)*98;



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
        affinity = get_affinity(X{ti}, char(sync{ti}), char(metric{ti}), char(aff_type{ti}));
        affinity

        opt = ['method=''kmeans'',sync=''' char(sync{ti}) ''',metric=''' char(metric{ti}) ''',num=' num2str(num(ti))];
        opt
        [X_cluster] = cluster_a_class(X{ti}, opt);
        for ci = 1:length(X_cluster)
            fprintf('cluster %d: #members=%d\n', ci, length(X_cluster{ci}));
            for ui = 1:length(X_cluster{ci})
                fprintf('  user %d: size=%dx%d\n', ui, size(X_cluster{ci}{ui}));
            end
        end
        input('========================================\n');
    end
end