%% my_corrcoef: 
%%   ts1 and ts2 should be column vector
function [coeff] = my_corrcoef(ts1, ts2)
    idx = find(~isnan(ts1) & ~isnan(ts2));
    if length(idx) < 3
        coeff = [0 0; 0 0];
        return;
    end
    coeff = corrcoef(ts1(idx), ts2(idx));
end
