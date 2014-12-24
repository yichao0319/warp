%% do_estimate: function description
function [X_est] = do_estimate(X, M, esti_method, est_opt)
    [r, alpha, lambda] = get_est_opt(est_opt);

    if strcmp(esti_method, 'lens')
        [X_est, x, y, z] = wrap_lens(X, M, r);

    elseif strcmp(esti_method, 'svd_base')
        epsilon = 0.01;

        X_est = wrap_svd_base(X, M, r, epsilon);

    elseif strcmp(esti_method, 'svd_base_knn')
        epsilon = 0.01;
        maxDist = 3;
        EPS = 1e-3;

        X_est = wrap_svd_base(X, M, r, epsilon);
        X_est = wrap_knn(X_est, X, M, maxDist, EPS);

    elseif strcmp(esti_method, 'srmf')
        epsilon = 0.01;
        period = 1;

        X_est = wrap_srmf(X, M, r, alpha, lambda, epsilon, period);

    elseif strcmp(esti_method, 'srmf_knn')
        epsilon = 0.01;
        period = 1;
        maxDist = 3;
        EPS = 1e-3;

        X_est = wrap_srmf(X, M, r, alpha, lambda, epsilon, period);        
        X_est = wrap_knn(X_est, X, M, maxDist, EPS);

    elseif strcmp(esti_method, 'knn')
        maxDist = 3;
        EPS = 1e-3;
        
        X_est = X;
        X_est(~M) = 0;
        
        X_est = wrap_knn(X_est, X, M, maxDist, EPS);

    elseif strcmp(esti_method, 'na')
        X_est = X;
    else
        error(['wrong estimate method: ' esti_method]);
    end

end


%% get_dtw_opt: function description
function [r, alpha, lambda] = get_est_opt(opt)
    r = 1;
    alpha = 0;
    lambda = 0;
    if nargin < 1, return; end

    opts = regexp(opt, ',', 'split');
    for this_opt = opts
        values = regexp(this_opt, '=', 'split');
        values = values{1};
        [ret, status] = str2num(values{2});

        if status > 0
            eval([char(this_opt) ';']);
        else
            assignin('base', values{1}, values{2});
        end
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
    % this_r = r0;
    this_r = r0*4;
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


%% wrap_srmf: function description
function [X_est] = wrap_srmf(X, M, r, alpha, lambda, epsilon, period)
    r = min([r, size(X)]);
    [A, b] = XM2Ab(X, M);
    config = ConfigSRTF(A, b, X, M, size(X), r, r, epsilon, true, period);
    [u4, v4, w4] = SRTF(X, r, M, config, alpha, lambda, 50);

    X_est = tensorprod(u4, v4, w4);
end


%% wrap_knn: function description
function [X_est] = wrap_knn(X_est, X, M, maxDist, EPS)
    Z = X_est;
    Z(~M) = 0;

    for i = 1:size(Z,1)
        for j = find(M(i,:) == 0);
            ind = find((M(i,:)==1) & (abs((1:size(Z,2)) - j) <= maxDist));
            if (~isempty(ind))
                Y  = X_est(:,ind);
                C  = Y'*Y;
                nc = size(C,1);
                C  = C + max(eps,EPS*trace(C)/nc)*speye(nc);
                w  = C\(Y'*X_est(:,j));
                w  = reshape(w,1,nc);
                Z(i,j) = sum(X(i,ind).*w);
            end
        end
    end

    X_est = Z;
end


%% functionname: function description
function [X_est] = wrap_svd_base(X, M, r, epsilon)
    r = min([r, size(X)]);
    [A, b] = XM2Ab(X, M);
    BaseX = EstimateBaseline(A, b, size(X));
    [u,v,w] = FactTensorACLS(X-BaseX, r, M, false, epsilon, 50, 1e-8, 0);

    X_est = tensorprod(u,v,w) + BaseX;
end
