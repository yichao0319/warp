%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Yi-Chao Chen @ UT Austin
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function test_do_drop()
    addpath('../');
    
    %% --------------------
    %% Variable
    %% --------------------
    % [X_drop, M] = do_drop(X, opt);
    % [frac, lr, elem_mode, loss_mode, burst] = get_drop_opt(opt);
    cnt = 0;

    cnt = cnt + 1;
    test{cnt}      = 'frac=1, lr=0.2, elem_mode=elem, loss_mode=ind, burst=1';
    frac(cnt)      = 1;
    lr(cnt)        = 0.2;
    elem_mode{cnt} = 'elem';
    loss_mode{cnt} = 'ind';
    burst(cnt)     = 1;
    X{cnt} = reshape(1:50, 10, 5)';


    %% --------------------
    %% Main starts
    %% --------------------
    for ti = 1:length(test)
        fprintf('=====================================\n');
        fprintf('TEST %d: %s\n', ti, char(test{ti}));
        
        X{ti}
        
        opt = ['frac=' num2str(frac(cnt)) ',lr=' num2str(lr(cnt)) ',elem_mode=''' char(elem_mode{cnt}) ''',loss_mode=''' char(loss_mode{cnt}) ''',burst=' num2str(burst(cnt))];
        [X_drop, M] = do_drop(X{ti}, opt);

        X_drop
        M

        %% --------------------
        %% revM: label all missing elements with 1,2,3,...,#drop
        %% --------------------
        drop_idx = find(M == 0);
        revM = zeros(size(M));
        revM(drop_idx) = 1:length(drop_idx);
        revM
        input('========================================\n');
    end
    
end