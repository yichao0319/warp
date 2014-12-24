%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Yi-Chao Chen @ UT Austin
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function test_do_dtw()
    addpath('../');
    
    %% --------------------
    %% Variable
    %% --------------------
    cnt = 0;

    cnt = cnt + 1;
    test{cnt} = 'seg=1';
    num_seg{cnt} = 1;
    X{cnt}{1}{1} = [1:20];
    X{cnt}{1}{2} = [1:2:20];
    X{cnt}{2}{1} = [20:-2:10 10:2:20];
    X{cnt}{2}{2} = [15:-1:10 10:15];
    X{cnt}{2}{3} = [15:-1:10 10:2:22];
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

        opt = ['num_seg=' num2str(num_seg{ti})];
        [X_sync, other_sync] = do_dtw(X{ti}, opt, other_mat{ti});

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