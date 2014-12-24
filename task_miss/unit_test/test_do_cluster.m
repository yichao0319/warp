%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Yi-Chao Chen @ UT Austin
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function test_cluster_a_class()
    addpath('../');
    
    %% --------------------
    %% Variable
    %% --------------------
    % [X_cluster, other_cluster, cluster_affinity] = do_cluster(X, cluster_opt, figbase, other_mat)
    % [method, num_cluster, head_type, num_seg, sync, metric, sigma] = get_cluster_opt(cluster_opt);
    cnt = 0;

    cnt = cnt + 1;
    test{cnt} = 'kmeans, #cluster=2, best head, no merge, shift, coeff';
    method{cnt} = 'kmeans';
    num(cnt) = 2;
    head{cnt} = 'best';
    merge{cnt} = 'na';
    thresh(cnt) = 0;
    sync{cnt} = 'shift';
    metric{cnt} = 'coeff';
    X{cnt}{1}(1, :) = [1:20];
    X{cnt}{2}(1, :) = [11:30];
    X{cnt}{3}(1, :) = [20:-1:1];
    X{cnt}{4}(1, :) = [30:-1:11];
    X{cnt}{5}(1, :) = [40:-1:21];
    other_mat{cnt}{1} = X{cnt};


    cnt = cnt + 1;
    test{cnt} = 'kmeans, #cluster=2, best head, no merge, shift, dist';
    method{cnt} = 'kmeans';
    num(cnt) = 2;
    head{cnt} = 'best';
    merge{cnt} = 'na';
    thresh(cnt) = 0;
    sync{cnt} = 'shift';
    metric{cnt} = 'dist';
    X{cnt}{1}(1, :) = ones(1,20)*5;
    X{cnt}{2}(1, :) = ones(1,20)*6;
    X{cnt}{3}(1, :) = ones(1,20)*100;
    X{cnt}{4}(1, :) = ones(1,20)*99;
    X{cnt}{5}(1, :) = ones(1,20)*98;
    other_mat{cnt}{1} = X{cnt};


    cnt = cnt + 1;
    test{cnt} = 'kmeans, #cluster=2, worst head, no merge, shift, dist';
    method{cnt} = 'kmeans';
    num(cnt) = 2;
    head{cnt} = 'worst';
    merge{cnt} = 'na';
    thresh(cnt) = 0;
    sync{cnt} = 'shift';
    metric{cnt} = 'dist';
    X{cnt}{1}(1, :) = ones(1,20)*5;
    X{cnt}{2}(1, :) = ones(1,20)*6;
    X{cnt}{3}(1, :) = ones(1,20)*100;
    X{cnt}{4}(1, :) = ones(1,20)*99;
    X{cnt}{5}(1, :) = ones(1,20)*98;
    other_mat{cnt}{1} = X{cnt};


    cnt = cnt + 1;
    test{cnt} = 'kmeans, #cluster=2, rand head, no merge, shift, dist';
    method{cnt} = 'kmeans';
    num(cnt) = 2;
    head{cnt} = 'rand';
    merge{cnt} = 'na';
    thresh(cnt) = 0;
    sync{cnt} = 'shift';
    metric{cnt} = 'dist';
    X{cnt}{1}(1, :) = ones(1,20)*5;
    X{cnt}{2}(1, :) = ones(1,20)*6;
    X{cnt}{3}(1, :) = ones(1,20)*100;
    X{cnt}{4}(1, :) = ones(1,20)*99;
    X{cnt}{5}(1, :) = ones(1,20)*98;
    other_mat{cnt}{1} = X{cnt};


    cnt = cnt + 1;
    test{cnt} = 'spectral, #cluster=0, best head, no merge, shift, dist';
    method{cnt} = 'spectral';
    num(cnt) = 0;
    head{cnt} = 'best';
    merge{cnt} = 'na';
    thresh(cnt) = 0;
    sync{cnt} = 'shift';
    metric{cnt} = 'dist';
    X{cnt}{1}(1, :) = ones(1,20)*5;
    X{cnt}{2}(1, :) = ones(1,20)*6;
    X{cnt}{3}(1, :) = ones(1,20)*100;
    X{cnt}{4}(1, :) = ones(1,20)*99;
    X{cnt}{5}(1, :) = ones(1,20)*98;
    other_mat{cnt}{1} = X{cnt};


    cnt = cnt + 1;
    test{cnt} = 'spectral, #cluster=-1, best head, no merge, na, dist';
    method{cnt} = 'spectral';
    num(cnt) = -1;
    head{cnt} = 'best';
    merge{cnt} = 'na';
    thresh(cnt) = 0;
    sync{cnt} = 'na';
    metric{cnt} = 'dist';
    X{cnt}{1}(1, :) = ones(1,20)*5;
    X{cnt}{2}(1, :) = ones(1,20)*6;
    X{cnt}{3}(1, :) = ones(1,20)*100;
    X{cnt}{4}(1, :) = ones(1,20)*99;
    X{cnt}{5}(1, :) = ones(1,20)*98;
    other_mat{cnt}{1} = X{cnt};


    cnt = cnt + 1;
    test{cnt} = 'spectral, #cluster=3, best head, no merge, na, dist';
    method{cnt} = 'spectral';
    num(cnt) = 3;
    head{cnt} = 'best';
    merge{cnt} = 'na';
    thresh(cnt) = 0;
    sync{cnt} = 'na';
    metric{cnt} = 'dist';
    X{cnt}{1}(1, :) = ones(1,20)*5;
    X{cnt}{2}(1, :) = ones(1,20)*6;
    X{cnt}{3}(1, :) = ones(1,20)*103;
    X{cnt}{4}(1, :) = ones(1,20)*100;
    X{cnt}{5}(1, :) = ones(1,20)*98;
    other_mat{cnt}{1} = X{cnt};


    cnt = cnt + 1;
    test{cnt} = 'spectral, #cluster=3, best head, merge num<2, na, dist';
    method{cnt} = 'spectral';
    num(cnt) = 3;
    head{cnt} = 'best';
    merge{cnt} = 'num';
    thresh(cnt) = 2;
    sync{cnt} = 'na';
    metric{cnt} = 'dist';
    X{cnt}{1}(1, :) = ones(1,20)*5;
    X{cnt}{2}(1, :) = ones(1,20)*6;
    X{cnt}{3}(1, :) = ones(1,20)*103;
    X{cnt}{4}(1, :) = ones(1,20)*100;
    X{cnt}{5}(1, :) = ones(1,20)*98;
    other_mat{cnt}{1} = X{cnt};


    cnt = cnt + 1;
    test{cnt} = 'spectral, #cluster=3, best head, merge to have only top 2, na, dist';
    method{cnt} = 'spectral';
    num(cnt) = 3;
    head{cnt} = 'best';
    merge{cnt} = 'top';
    thresh(cnt) = 2;
    sync{cnt} = 'na';
    metric{cnt} = 'dist';
    X{cnt}{1}(1, :) = ones(1,20)*5;
    X{cnt}{2}(1, :) = ones(1,20)*6;
    X{cnt}{3}(1, :) = ones(1,20)*103;
    X{cnt}{4}(1, :) = ones(1,20)*100;
    X{cnt}{5}(1, :) = ones(1,20)*98;
    other_mat{cnt}{1} = X{cnt};


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
        affinity = get_affinity(X{ti}, char(sync{ti}), char(metric{ti}));
        affinity

        opt = ['method=''' char(method{ti}) ''',num=' num2str(num(ti)) ',head=''' char(head{ti}) ''',merge=''' char(merge{ti}) ''',thresh=' num2str(thresh(ti)) ',sync=''' char(sync{ti}) ''',metric=''' char(metric{ti}) ''''];
        opt
        [X_cluster, other_cluster, cluster_affinity] = do_cluster(X{ti}, opt, '', other_mat{ti});
        for ci = 1:length(X_cluster)
            fprintf('cluster %d: #members=%d, affinity=%f\n', ci, length(X_cluster{ci}), cluster_affinity(ci));
            for ui = 1:length(X_cluster{ci})
                [X_cluster{ci}{ui};
                other_cluster{1}{ci}{ui}]
            end
        end
        input('========================================\n');
    end
end