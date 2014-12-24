%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Yi-Chao Chen @ UT Austin
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function test_do_stretch()
    addpath('../');
    
    %% --------------------
    %% Variable
    %% --------------------
    cnt = 0;

    cnt = cnt + 1;
    test{cnt} = 'coeff';
    
    X{cnt}{1}{1} = reshape([1:10; 1:10], 1, []);
    X{cnt}{1}{2} = [1:10];
    X{cnt}{2}{1} = reshape([20:-1:11; 20:-1:11], 1, []);
    X{cnt}{2}{2} = [20:-1:11];
    X{cnt}{2}{3} = reshape([20:-1:11; 20:-1:11; 20:-1:11], 1, []);
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

        [X_sync, other_sync] = do_stretch(X{ti}, other_mat{ti});

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