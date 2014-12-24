%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Yi-Chao Chen @ UT Austin
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function test_get_affinity()
    addpath('../');

    %% --------------------
    %% Variable
    %% --------------------
    % get_affinity(X, sync, metric)
    cnt = 0;


    cnt = cnt + 1;
    test{cnt} = 'na, coeff';
    sync{cnt} = 'na';
    metric{cnt} = 'coeff';
    X{cnt}{1}(1, :) = [1:20];
    X{cnt}{2}(1, :) = [11:30];
    X{cnt}{3}(1, :) = [20:-1:1];
    X{cnt}{4}(1, :) = [30:-1:11];
    X{cnt}{5}(1, :) = randi(100, 1, 20);

    cnt = cnt + 1;
    test{cnt} = 'na, dist';
    sync{cnt} = 'na';
    metric{cnt} = 'dist'; %% coeff
    X{cnt}{1}(1, :) = ones(1,20)*5;
    X{cnt}{2}(1, :) = ones(1,20)*6;
    X{cnt}{3}(1, :) = ones(1,20)*100;
    X{cnt}{4}(1, :) = ones(1,20)*99;
    X{cnt}{5}(1, :) = randi(100, 1, 20);

    cnt = cnt + 1;
    test{cnt} = 'na, dist';
    sync{cnt} = 'na';
    metric{cnt} = 'dist'; %% coeff
    X{cnt}{1}(1, :) = ones(1,20)*5;
    X{cnt}{2}(1, :) = ones(1,20)*6;
    X{cnt}{3}(1, :) = ones(1,20)*100;
    X{cnt}{4}(1, :) = ones(1,20)*99;
    X{cnt}{5}(1, :) = [ones(1,5) ones(1,5)*99 ones(1,10)*5];
    X{cnt}{6}(1, :) = randi(100, 1, 20);


    cnt = cnt + 1;
    test{cnt} = 'shift, coeff';
    sync{cnt} = 'shift';
    metric{cnt} = 'coeff';
    X{cnt}{1}(1, :) = [1:20];
    X{cnt}{2}(1, :) = [11:30];
    X{cnt}{3}(1, :) = [20:-1:1];
    X{cnt}{4}(1, :) = [30:-1:11];
    X{cnt}{5}(1, :) = randi(100, 1, 20);

    cnt = cnt + 1;
    test{cnt} = 'shift, dist';
    sync{cnt} = 'shift';
    metric{cnt} = 'dist'; %% coeff
    X{cnt}{1}(1, :) = ones(1,20)*5;
    X{cnt}{2}(1, :) = ones(1,20)*6;
    X{cnt}{3}(1, :) = ones(1,20)*100;
    X{cnt}{4}(1, :) = ones(1,20)*99;
    X{cnt}{5}(1, :) = randi(100, 1, 20);

    cnt = cnt + 1;
    test{cnt} = 'shift, dist';
    sync{cnt} = 'shift';
    metric{cnt} = 'dist'; %% coeff
    X{cnt}{1}(1, :) = ones(1,20)*5;
    X{cnt}{2}(1, :) = ones(1,20)*6;
    X{cnt}{3}(1, :) = ones(1,20)*100;
    X{cnt}{4}(1, :) = ones(1,20)*99;
    X{cnt}{5}(1, :) = [ones(1,5) ones(1,5)*99 ones(1,10)*5];


    cnt = cnt + 1;
    test{cnt} = 'stretch, coeff';
    sync{cnt} = 'stretch';
    metric{cnt} = 'coeff';
    X{cnt}{1}(1, :) = reshape([1:10; 1:10], 1, []);
    X{cnt}{2}(1, :) = [1:10];
    X{cnt}{3}(1, :) = reshape([20:-1:11; 20:-1:11], 1, []);
    X{cnt}{4}(1, :) = [20:-1:11];
    X{cnt}{5}(1, :) = randi(100, 1, 20);
    

    cnt = cnt + 1;
    test{cnt} = 'dtw';
    sync{cnt} = 'dtw';
    metric{cnt} = 'coeff';
    X{cnt}{1}(1, :) = ones(1,20)*5;
    X{cnt}{2}(1, :) = ones(1,20)*6;
    X{cnt}{3}(1, :) = ones(1,20)*100;
    X{cnt}{4}(1, :) = ones(1,20)*99;
    X{cnt}{5}(1, :) = [ones(1,5) ones(1,5)*99 ones(1,10)*5];


    %% --------------------
    %% Main starts
    %% --------------------
    for ti = 1:length(test)
        fprintf('=====================================\n');
        fprintf('TEST %d: %s\n', ti, char(test{ti}));
        X{ti}{1}
        X{ti}{2}
        X{ti}{3}
        X{ti}{4}
        X{ti}{5}
        affinity = get_affinity(X{ti}, char(sync{ti}), char(metric{ti}));
        affinity
        input('========================================\n');
    end
end