%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Yi-Chao Chen @ UT Austin
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function test_test_evaluation()
    addpath('../');
    
    %% --------------------
    %% Variable
    %% --------------------
    cnt = 0;

    cnt = cnt + 1;
    test{cnt} = 'best cluster';
    X{cnt} = reshape(1:50, 10, 5)';
    r{cnt} = 3;
    drop_opt{cnt} = 'frac=1,lr=0.1,elem_mode=''elem'',loss_mode=''ind'',burst=1';
    dup{cnt} = 'best';


    cnt = cnt + 1;
    test{cnt} = 'no duplicate';
    X{cnt} = reshape(1:50, 10, 5)';
    r{cnt} = 3;
    drop_opt{cnt} = 'frac=1,lr=0.1,elem_mode=''elem'',loss_mode=''ind'',burst=1';
    dup{cnt} = 'no';


    cnt = cnt + 1;
    test{cnt} = 'avg';
    X{cnt} = reshape(1:50, 10, 5)';
    r{cnt} = 3;
    drop_opt{cnt} = 'frac=1,lr=0.1,elem_mode=''elem'',loss_mode=''ind'',burst=1';
    dup{cnt} = 'avg';


    cnt = cnt + 1;
    test{cnt} = 'equal';
    X{cnt} = reshape(1:50, 10, 5)';
    r{cnt} = 3;
    drop_opt{cnt} = 'frac=1,lr=0.1,elem_mode=''elem'',loss_mode=''ind'',burst=1';
    dup{cnt} = 'equal';
    


    %% --------------------
    %% Main starts
    %% --------------------
    for ti = 1:length(test)
        fprintf('=====================================\n');
        fprintf('TEST %d: %s\n', ti, char(test{ti}));
        
        X{ti}
        
        %% drop
        fprintf('  drop\n');
        [X_drop, M] = do_drop(X{ti}, char(drop_opt{ti}));
        X_drop
        M
        input('===');

        %% index missing elements
        drop_idx = find(M == 0);
        revM = zeros(size(M));
        revM(drop_idx) = 1:length(drop_idx);
        revM
        input('===');

        %% interpolate
        fprintf('  interpolate\n');
        est_opt = ['r=' num2str(r{ti})];
        X_est = do_estimate(X_drop, M, 'lens', est_opt);
        X_est
        input('===');

        %% collect interpolated values
        fprintf('  collect interpolation 1\n');
        est_collection = [];
        ci = 1;
        cluster_affinity = 10;
        est_collection = collect_estimation(X{ti}, X_est, M, revM, ci, cluster_affinity, est_collection);
        est_collection
        input('===');

        %% collect interpolated values
        fprintf('  collect interpolation 2\n');
        ci = 2;
        cluster_affinity = 8;
        X_est2 = X_est + 2;
        len = floor(size(X{ti},2)/2);
        est_collection = collect_estimation(X{ti}(:,1:len), X_est2(:,1:len), M(:,1:len), revM(:,1:len), ci, cluster_affinity, est_collection);
        est_collection
        input('===');

        %% evaluate
        eval_opt = ['dup=''' char(dup{ti}) ''''];
        [mae, select_miss_elem] = evaluate_est_collection(est_collection, eval_opt);
        mae
        select_miss_elem

        input('========================================\n');
    end
end