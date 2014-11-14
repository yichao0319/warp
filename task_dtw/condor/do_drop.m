%% do_drop
%% - elem_frac: 1
%% - loss_rate: 0.1
%% - elem_mode: 'elem'
%% - loss_mode: 'ind'

function [X_drop, M] = do_drop(X, ElemFrac, LossRate, ElemMode, LossMode, BurstSize);
    nr = size(X, 1);
    nc = 1;
    nt = size(X, 2);

    M = DropValues(nr, nc, nt, ElemFrac, LossRate, ElemMode, LossMode, BurstSize);
    M = squeeze(M);
    X_drop = X;
    X_drop(~M) = NaN;
end