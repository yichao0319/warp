%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% do_drop
%%
%% - Input:
%%   - X: 
%%      2D matrix [flows x time]
%%   - drop_opt:
%%      > frac: element fraction
%%      > lr: loss rate
%%      > elem_mode
%%      > loss_mode
%%      > burst: burst size
%%
%% - Output
%%   - X_drop:
%%       2D matrix, missing elements = NaN
%%   - M:
%%       2D matrix, missing elements are labeled with 0, and 1 otherwise
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [X_drop, M] = do_drop(X, opt)
    addpath('/u/yichao/lens/utils/compressive_sensing');
    
    [frac, lr, elem_mode, loss_mode, burst] = get_drop_opt(opt);

    nr = size(X, 1);
    nc = 1;
    nt = size(X, 2);

    M = DropValues(nr, nc, nt, frac, lr, elem_mode, loss_mode, burst);
    M = squeeze(M);
    X_drop = X;
    X_drop(~M) = NaN;
end


function [frac, lr, elem_mode, loss_mode, burst] = get_drop_opt(opt)
    frac = 1;
    lr = 0.1; 
    elem_mode = 'elem';
    loss_mode = 'ind';
    burst = 1;

    opts = regexp(opt, ',', 'split');
    for this_opt = opts
        eval([char(this_opt) ';']);
    end
end
