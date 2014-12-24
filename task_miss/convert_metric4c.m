%% convert_metric4c
function [metric4c] = convert_metric4c(metric)
    if strcmp(metric, 'coeff')
        metric4c = 1;
    elseif strcmp(metric, 'dist')
        metric4c = 2;
    elseif strcmp(metric, 'graph')
        metric4c = 2;
    else
        error(['wrong metric: ' metric]);
    end
end

