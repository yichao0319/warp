
%% find_srmf_param: function description
%% find_srmf_param('test_sine_shift', 'na')
%% find_srmf_param('test_sine_scale', 'na')
%% find_srmf_param('abilene', 'na')
function find_srmf_param(trace_name, trace_opt)
    addpath('/u/yichao/lens/utils/compressive_sensing');

    %% --------------------
    %% DEBUG
    %% --------------------
    DEBUG0 = 0;
    DEBUG1 = 1;
    DEBUG2 = 1;
    DEBUG3 = 1;
    DEBUG4 = 1;  %% results


    %% --------------------
    %% Variables
    %% --------------------
    rand('seed', 1);
    randn('seed', 1);

    output_dir = '../../processed_data/task_dtw/do_missing_exp/';
    % output_dir = '/u/yichao/warp/condor_data/task_dtw/condor/do_missing_exp/';

    %% SRMF
    epsilon = 0.01;
    period  = 1;
    alphas  = [0, 10 .^ [-5:5]];
    lambdas = [0, 10 .^ [-5:5]];


    %% --------------------
    %% load data
    %% --------------------
    if DEBUG2, fprintf('load data\n'); end

    [X, r, bin] = get_trace(trace_name, trace_opt);
    X = my_cell2mat(X);
    r = min([r, size(X)]);
    fprintf('X size: %dx%d\n', size(X));


    %% --------------------
    %% drop values
    %% --------------------
    if DEBUG2, fprintf('drop values\n'); end

    [X_drop, M] = do_drop(X, 1, 0.1, 'elem', 'ind', 1);


    %% --------------------
    %% Best alphas
    %% --------------------
    if DEBUG2, fprintf('best alphas\n'); end

    best_alpha = alphas(1);
    best_mae   = 1000;
    lambda     = 1000;

    for alpha = alphas
        mae = warp_srmf(X, M, r, alpha, lambda, epsilon, period);
        if mae < best_mae
            best_mae = mae;
            best_alpha = alpha;
        end

        fprintf('  alpha=%f: mae=%f (best mae=%f)\n', alpha, mae, best_mae);
    end

    fprintf('> best alpha = %f (mae = %f)\n', best_alpha, best_mae);


    %% --------------------
    %% Best lambda
    %% --------------------
    if DEBUG2, fprintf('best lambda\n'); end

    best_lambda = lambdas(1);
    alpha       = best_alpha;

    for lambda = lambdas
        mae = warp_srmf(X, M, r, alpha, lambda, epsilon, period);
        if mae < best_mae
            best_mae = mae;
            best_lambda = lambda;
        end

        fprintf('  lambda=%f: mae=%f (best mae=%f)\n', lambda, mae, best_mae);
    end

    fprintf('> best alpha = %f (mae = %f)\n', best_alpha, best_mae);
    fprintf('> best lambda = %f (mae = %f)\n', best_lambda, best_mae);

end


%% warp_srmf: function description
function [mae] = warp_srmf(X, M, r, alpha, lambda, epsilon, period)
    [A, b] = XM2Ab(X, M);
    config = ConfigSRTF(A, b, X, M, size(X), r, r, epsilon, true, period);
    [u4, v4, w4] = SRTF(X, r, M, config, alpha, lambda, 50);

    X_est = tensorprod(u4, v4, w4);

    mae = calculate_mae(X, X_est, M);
end


%% calculate_mae: function description
function [mae] = calculate_mae(X, X_est, M)
    meanX = mean(abs(X(~M)));
    mae = mean(abs((X(~M) - X_est(~M)))) / meanX;
end

