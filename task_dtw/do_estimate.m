%% do_estimate: function description
function [X_est] = do_estimate(X, M, esti_method, est_opt)
    [r] = get_est_opt(est_opt);

    if strcmp(esti_method, 'lens')
        [X_est, x, y, z] = wrap_lens(X, M, r);

    elseif strcmp(esti_method, 'SRMF')
        epsilon = 0.01;
        period  = 1;
        alpha   = 10;
        lambda  = 0.01;

        [A, b] = XM2Ab(X, M);
        config = ConfigSRTF(A, b, X, M, size(X), r, r, epsilon, true, period);
        [u4, v4, w4] = SRTF(X, r, M, config, alpha, lambda, 50);

        X_est = tensorprod(u4, v4, w4);
        X_est = max(0, X_est);
    elseif strcmp(esti_method, 'KNN')
        Z = X;
        Z(~M) = 0;

        maxDist = 3;
        EPS = 1e-3;

        for i = 1:size(Z,1)
            for j = find(M(i,:) == 0);
                ind = find((M(i,:)==1) & (abs((1:size(Z,2)) - j) <= maxDist));
                if (~isempty(ind))
                    Y  = X(:,ind);
                    C  = Y'*Y;
                    nc = size(C,1);
                    C  = C + max(eps,EPS*trace(C)/nc)*speye(nc);
                    w  = C\(Y'*X(:,j));
                    w  = reshape(w,1,nc);
                    Z(i,j) = sum(X(i,ind).*w);
                end
            end
        end
        
        X_est = Z;

    elseif strcmp(esti_method, 'na')
        X_est = X;
    else
        error(['wrong estimate method: ' esti_method]);
    end

end


%% get_dtw_opt: function description
function [r] = get_est_opt(opt)
    r = 1;
    if nargin < 1, return; end

    opts = regexp(opt, ',', 'split');
    for this_opt = opts
        eval([char(this_opt) ';']);
    end

end


function [X_est,x,y,z] = wrap_lens(X, M, r0)
    addpath('/u/yichao/lens/utils/lens');


    % tmpX = cluster2mat(X);
    % tmpM = cluster2mat(M);
    % tmpX(~tmpM) = 0;
    % find(isnan(tmpX))
    % input('.............')


    %% --------------------
    %% Missing values
    %% --------------------
    [m,n] = size(X);
    E = ~M;
    
    %% ====================================
    %% LENS_ST
    A = speye(m);
    B = speye(m);
    C = speye(m);
    F = ones(m,n);
    
    soft = 1;
    sigma0 = [];
    this_r = r0 * 4;
    rho = 1.03;

    CC = zeros(1, n-1); CC(1,1) = 1;
    RR = zeros(1, n); RR(1,1) = 1; RR(1,2) = -1; % P: mxm, x: mxn, Q: nxn
    P = speye(m,m);
    Q = toeplitz(CC,RR);
    K = P*zeros(m,n)*Q';

    X(E) = 0;

    [x,y,z,w,enable_B,sig,gamma] = lens3(X,this_r,A,B,C,E,P,Q,K,[],soft,rho);
    if (enable_B)
        X_est = x+y;
    else
        X_est = x;
    end
end


