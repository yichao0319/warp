%% do_stretch: function description
function [X_sync, other_sync] = do_stretch(X_cluster, other_mat)
    DEBUG_TIME = 0;

    other_sync = {};

    for ci = 1:length(X_cluster)
        if length(X_cluster{ci}) == 1
            X_sync{ci} = X_cluster{ci};
            % M_sync{ci} = M_cluster{ci};
            if nargin >= 2
                for oi = 1:length(other_mat)
                    other_sync{oi}{ci} = other_mat{oi}{ci};
                end
            end
            continue;
        end

        for tsi = 2:length(X_cluster{ci})
            % fprintf('tsi %d\n', tsi);
            [stretch_idx1, stretch_idx2] = find_best_stretch(X_cluster{ci}{1}, X_cluster{ci}{tsi});
            % fprintf(' end find best stretch\n', tsi);
            ws{tsi} = [];
            ws{tsi}(:, 1) = stretch_idx1';
            ws{tsi}(:, 2) = stretch_idx2';

            % fprintf('-- ws ----------------\n')
            % length(X_cluster{ci}{1})
            % length(X_cluster{ci}{tsi})
            % ws{tsi}(:, 1)'
            % ws{tsi}(:, 2)'
            % fprintf('-- end ws ----------------\n')
            % input('..........')
        end
        
        t1 = tic;
        % [X_sync{ci}, M_sync{ci}] = align_cluster(X_cluster{ci}, ws, M_cluster{ci});
        tmp_other_mat = {};
        if nargin >= 2
            for oi = 1:length(other_mat)
                tmp_other_mat{oi} = other_mat{oi}{ci};
            end
        end
        [X_sync{ci}, tmp_other_sync] = align_cluster(X_cluster{ci}, ws, tmp_other_mat);
        if nargin >= 2
            for oi = 1:length(tmp_other_sync)
                other_sync{oi}{ci} = tmp_other_sync{oi};
            end
        end
        
        if DEBUG_TIME, fprintf('[TIME] len:%d, time=%f\n', size(ws{2},1), toc(t1)); end
    end
end
