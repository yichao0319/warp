%% my_cell2mat: function description
function [ret] = my_cell2mat(mat)
    num_cols = 0;
    num_rows = 0;
    for ri = 1:length(mat)
        num_rows = num_rows + size(mat{ri}, 1);
        if size(mat{ri}, 2) > num_cols
            num_cols = size(mat{ri}, 2);
        end
    end

    ret = zeros(num_rows, num_cols);
    ri = 1;
    for mi = 1:length(mat)
        nr = size(mat{mi}, 1);
        nc = size(mat{mi}, 2);
        % fprintf('  mi=%d, nr=%d, nc=%d\n', mi, nr, nc);
        ret(ri:ri+nr-1, 1:nc) = mat{mi};
        ri = ri+nr;
    end
end

