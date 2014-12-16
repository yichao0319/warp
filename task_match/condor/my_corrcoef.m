%% my_corrcoef: 
%%   ts1 and ts2: time x features
function [coeff] = my_corrcoef(ts1, ts2)
    for fi = 1:size(ts1,2)
        idx = find(~isnan(ts1(:,fi)) & ~isnan(ts2(:,fi)));
        if length(idx) < 3
            coeff = [-1 -1; -1 -1];
            return;
        end
        tmp = corrcoef(ts1(idx,fi), ts2(idx,fi));
        this_coeff(fi) = tmp(1,2);
    end
    avg_coeff = mean(this_coeff);
    coeff = [1 avg_coeff; avg_coeff 1];
end
