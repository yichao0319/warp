%% cluster2mat: function description
function [X_mat] = cluster2mat(X_cluster)
    tsc = 0;
    for ci = 1:length(X_cluster)
        for tsi = 1:length(X_cluster{ci})
            tsc = tsc + 1;
            X_final{tsc} = X_cluster{ci}{tsi};
        end
    end
    X_mat = my_cell2mat(X_final);
end
