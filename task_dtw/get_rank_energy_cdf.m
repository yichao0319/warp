%% get_energy_cdf: function description
function [cdf_x, cdf_y, r] = get_rank_energy_cdf(X, percentile)
    if nargin < 2, percentile = 0.85; end

    X = X - mean(X(:));
    sigma = svd(X);

    total_sum = sum(sigma);
    total_sum_sofar = cumsum(sigma);
    cdf = total_sum_sofar ./ total_sum;

    k = [1:length(cdf)]' / length(cdf);

    % cdf_x = k;
    % cdf_y = cdf;
    %% interpolation
    try
        cdf_x = [0:0.01:1]';
        cdf_y = interp1(k, cdf, cdf_x, 'linear');
    catch e
        cdf_x = k;
        cdf_y = cdf;
    end

    idx = find(cdf_y >= percentile);
    r = cdf_x(idx(1)) * size(sigma,1);
end

