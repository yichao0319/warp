%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Yi-Chao Chen @ UT Austin
%%
%% Activities:
%% - 1: Working at Computer
%% - 2: Standing Up, Walking and Going up\down stairs
%% - 3: Standing
%% - 4: Walking
%% - 5: Going Up\Down Stairs
%% - 6: Walking and Talking with Someone
%% - 7: Talking while Standing
%%
%% - Input:
%%
%%
%% - Output:
%%
%%
%% e.g.
%%
%%     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [X, gt_class] = get_trace_match_acc_chest(opt)
    
    %% --------------------
    %% DEBUG
    %% --------------------
    DEBUG0 = 0;
    DEBUG1 = 1;
    DEBUG2 = 1;
    DEBUG3 = 0;

    %% --------------------
    %% Variable
    %% --------------------
    input_dir  = '/u/yichao/warp/data/acc_chest/';
    % output_dir = '';
    subjects = 1:15;
    activities = 1:7;

    max_num = 1000; %% get maximal n samples
    step = 0.1;
    r0 = 10;


    %% --------------------
    %% Check input
    %% --------------------
    if nargin < 1, arg = 1; end
    if nargin < 1, arg = 1; end


    %% --------------------
    %% Main starts
    %% --------------------
    [feature] = get_trace_match_acc_chest_opt(opt);

    tsc = 0;
    for si = subjects
        for ai = activities
            if DEBUG2, fprintf('    acitvity %d subject %d:\n', ai, si); end

            filename = [input_dir num2str(si) '.csv'];
            tmp = load(filename);
            idx = find(tmp(:, 5) == ai);

            tsc = tsc + 1;
            raw_X{tsc} = tmp(idx, 2:4)';
            gt_class(tsc) = ai;
            
            if DEBUG3, fprintf('      raw size = %dx%d\n', size(tmp)); end
            if DEBUG3, fprintf('      this act size = %dx%d\n', size(raw_X{tsc})); end


            %% get maximal n samples
            len = size(raw_X{tsc}, 2);
            start_idx = max(1,ceil(len/2-max_num/2))+1;
            raw_X{tsc} = raw_X{tsc}(:, start_idx:min(end,start_idx+max_num-1));

            if DEBUG3, fprintf('      final act size = %dx%d\n', size(raw_X{tsc})); end
        end
    end


    %% sort by activity
    tsc = 0;
    for ai = activities
        idx = find(gt_class == ai);
        for iidx = 1:length(idx)
            tsc = tsc + 1;
            raw_X2{tsc} = raw_X{idx(iidx)};
            gt_class2(tsc) = gt_class(idx(iidx));
        end
    end
    raw_X = raw_X2;
    gt_class = gt_class2;


    %% prepare for output
    if strcmp(feature, 'raw')
        X = raw_X;
        for tsi = 1:length(raw_X)
            for ri = 1:size(raw_X{tsi}, 1)
                X{tsi}(ri, :) = X{tsi}(ri, :) - min(X{tsi}(ri, :));
                X{tsi}(ri, :) = X{tsi}(ri, :) / max(X{tsi}(ri, :));
            end
        end
    elseif strcmp(feature, 'mag')
        for tsi = 1:length(raw_X)
            % X{tsi} = mean(raw_X{tsi}, 1);
            X{tsi} = sqrt(raw_X{tsi}(1,:).^2 + raw_X{tsi}(2,:).^2 + raw_X{tsi}(3,:).^2);
            X{tsi} = X{tsi} - min(X{tsi});
            X{tsi} = X{tsi} / max(X{tsi});
        end
    elseif strcmp(feature, 'percentile')
        X = raw_X;
        for tsi = 1:length(raw_X)
            for ri = 1:size(raw_X{tsi}, 1)
                X{tsi}(ri, :) = X{tsi}(ri, :) - min(X{tsi}(ri, :));
                X{tsi}(ri, :) = X{tsi}(ri, :) / max(X{tsi}(ri, :));
                X{tsi}(ri, :) = floor(X{tsi}(ri, :) / step);
            end
        end
    elseif strcmp(feature, 'mag_percentile')
        for tsi = 1:length(raw_X)
            % X{tsi} = mean(raw_X{tsi}, 1);
            X{tsi} = sqrt(raw_X{tsi}(1,:).^2 + raw_X{tsi}(2,:).^2 + raw_X{tsi}(3,:).^2);
            X{tsi} = X{tsi} - min(X{tsi});
            X{tsi} = X{tsi} / max(X{tsi});
            X{tsi} = floor(X{tsi} / step);
        end
    elseif strcmp(feature, 'lowrank')
        X = raw_X;
        for tsi = 1:length(raw_X)
            for ri = 1:size(raw_X{tsi}, 1)
                X{tsi}(ri, :) = X{tsi}(ri, :) - min(X{tsi}(ri, :));
                X{tsi}(ri, :) = X{tsi}(ri, :) / max(X{tsi}(ri, :));
            end

            [U, S, V] = svd(X{tsi});
            
            U_lr = U(:, 1:min(r0,end));
            S_lr = S(1:min(r0,end), 1:min(r0,end));
            V_lr = V(:, 1:min(r0,end));

            X{tsi} = U_lr * S_lr * V_lr';
        end

    elseif strcmp(feature, 'lowrank_percentile')
        X = raw_X;
        for tsi = 1:length(raw_X)
            for ri = 1:size(raw_X{tsi}, 1)
                X{tsi}(ri, :) = X{tsi}(ri, :) - min(X{tsi}(ri, :));
                X{tsi}(ri, :) = X{tsi}(ri, :) / max(X{tsi}(ri, :));
            end

            [U, S, V] = svd(X{tsi});
            
            U_lr = U(:, 1:min(r0,end));
            S_lr = S(1:min(r0,end), 1:min(r0,end));
            V_lr = V(:, 1:min(r0,end));

            X{tsi} = U_lr * S_lr * V_lr';

            for ri = 1:size(X{tsi}, 1)
                X{tsi}(ri, :) = floor(X{tsi}(ri, :) / step);
            end
        end

    else
        error(['wrong trace opt: ' opt]);
        
    end

    % input('.........')

end


function [feature] = get_trace_match_acc_chest_opt(opt)
    feature = 'raw';
    if nargin < 1, return; end

    opts = regexp(opt, ',', 'split');
    for this_opt = opts
        eval([char(this_opt) ';']);
    end
end
