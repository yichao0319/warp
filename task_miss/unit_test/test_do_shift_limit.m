%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Yi-Chao Chen @ UT Austin
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function test_do_shift_limit()
    addpath('../');
    
    %% --------------------
    %% Variable
    %% --------------------
    cnt = 0;

    cnt = cnt + 1;
    test{cnt} = 'coeff';
    metric{cnt} = 'coeff';
    X{cnt}{1}{1} = [1:20];
    X{cnt}{1}{2} = [1:2:20];
    X{cnt}{2}{1} = [20:-2:10 10:2:20];
    X{cnt}{2}{2} = [15:-1:10 10:15];
    X{cnt}{2}{3} = [15:-1:10 10:2:22];
    other_mat{cnt}{1} = X{cnt};
    

    cnt = cnt + 1;
    test{cnt} = 'dist';
    metric{cnt} = 'dist';
    X{cnt}{1}{1} = [ones(1,5)*10 ones(1,5)*99 ones(1,10)*9];
    X{cnt}{1}{2} = [ones(1,10)*9 ones(1,4)*99 ones(1,3)*10];
    X{cnt}{2}{1} = [ones(1,10)*30 ones(1,10)*40];
    X{cnt}{2}{2} = [ones(1,5)*29 ones(1,10)*50];
    X{cnt}{2}{3} = [ones(1,5)*29 ones(1,5)*39 ones(1,10)*29];
    other_mat{cnt}{1} = X{cnt};
    

    %% --------------------
    %% Main starts
    %% --------------------
    for ti = 1:length(test)
        fprintf('=====================================\n');
        fprintf('TEST %d: %s\n', ti, char(test{ti}));
        X{ti}{1}{1}
        X{ti}{1}{2}
        X{ti}{2}{1}
        X{ti}{2}{2}
        X{ti}{2}{3}

        opt = ['metric=''' char(metric{ti}) ''''];
        [X_sync, other_sync] = do_shift_limit(X{ti}, opt, '', other_mat{ti});

        for ci = 1:length(X{ti})
            fprintf('> cluster %d\n', ci);
            for ri = 1:length(X{ti}{ci})
                [X_sync{ci}{ri};
                other_sync{1}{ci}{ri}]
            end
        end

        input('========================================\n');
    end
end