%% do_stretch: function description
function X_warp = do_stretch(X_cluster)
    DEBUG_TIME = 0;

    for ci = 1:length(X_cluster)
        if length(X_cluster{ci}) == 1
            X_warp{ci} = X_cluster{ci};
            continue
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
        X_warp{ci} = align_cluster(X_cluster{ci}, ws);
        if DEBUG_TIME, fprintf('[TIME] len:%d, time=%f\n', size(ws{2},1), toc(t1)); end
    end
end
