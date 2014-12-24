%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Yi-Chao Chen @ UT Austin
%%
%% - Input:
%%   - X: 3D data
%%        1st dim (cell): subjects / words / ...
%%        2nd dim (matrix): features
%%        3rd dim (matrix): samples over time
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ret] = my_cell2mat(X)
    num_cols = 0;
    num_rows = 0;
    for ri = 1:length(X)
        num_rows = num_rows + size(X{ri}, 1);
        if size(X{ri}, 2) > num_cols
            num_cols = size(X{ri}, 2);
        end
    end

    ret = zeros(num_rows, num_cols);
    ri = 1;
    for mi = 1:length(X)
        nr = size(X{mi}, 1);
        nc = size(X{mi}, 2);
        % fprintf('  mi=%d, nr=%d, nc=%d\n', mi, nr, nc);
        ret(ri:ri+nr-1, 1:nc) = X{mi};
        ri = ri+nr;
    end
end

