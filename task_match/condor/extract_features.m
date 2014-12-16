%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Yi-Chao Chen @ UT Austin
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

function [X_feature] = extract_features(X, gt_class, opt)
    
    %% --------------------
    %% DEBUG
    %% --------------------
    DEBUG0 = 0;
    DEBUG1 = 1;
    DEBUG2 = 1;
    DEBUG3 = 1;  %% verbose
    DEBUG4 = 0;  %% more details

    thresh = 0;
    max_iter = 1000;


    %% --------------------
    %% Check input
    %% --------------------
    if nargin < 2, opt = 'num=0'; end


    %% --------------------
    %% Main starts
    %% --------------------

    num_classes  = max(gt_class);
    num_features = size(X{1}, 1);

    [num, sync, metric] = get_extract_feature_opt(opt);
    require_num = max(1, floor(num_features * num));
    cal_obj_opt = ['sync=''' sync ''',metric=''' metric ''''];

    if num < 0 | require_num >= num_features
        X_feature = X;
        return;
    end

    

    iter = 0;
    pre_obj = Inf;
    best_obj = 1;
    flists = [];
    remaining_features = [1:num_features];
    while(iter < max_iter)
        iter = iter + 1;
        if DEBUG3
            fprintf('    iter %d flists: ', iter);
            fprintf('%d,', flists);
            fprintf('\n');
        end

        %% add one more feature to the list
        best_obj = Inf;
        best_f = -1;
        for fi = remaining_features
            if DEBUG4, fprintf('    > add %d\n', fi); end

            tmp_flists = [flists, fi];

            for tsi = 1:length(X)
                tmp_X{tsi} = X{tsi}(tmp_flists, :);
            end

            obj = cal_cluster_obj(tmp_X, gt_class, cal_obj_opt);
            if obj < best_obj | best_f == -1
                best_obj = obj;
                best_f = fi;
            end

            if DEBUG4, fprintf('      obj=%f (best f=%d)\n', obj, best_f); end
        end

        if best_obj < pre_obj
            flists = [flists, best_f];
            pre_obj = best_obj;
            remaining_features = setxor(remaining_features, best_f);

            if DEBUG4, 
                fprintf('    >> add new feature=%d (obj=%f)\n', best_f, best_obj); 
                fprintf('       remaining features = ');
                fprintf('%d,', remaining_features);
                fprintf('\n');
            end

        elseif num > 0 & length(flists) < require_num
            %% keep adding the best feature till have enough features
            flists = [flists, best_f];
            pre_obj = best_obj;
            remaining_features = setxor(remaining_features, best_f);

            if DEBUG4, 
                fprintf('    >> #features=%d (<=%d)\n', length(flists)+1, require_num); 
                fprintf('       add new feature=%d (obj=%f)\n', best_f, best_obj); 
                fprintf('       remaining features = ');
                fprintf('%d,', remaining_features);
                fprintf('\n');
            end

        else
            %% no further improvement by adding more features
            if DEBUG4, fprintf('    >> no improvement\n'); end
            break;
        end

        
        if length(flists) >= require_num & num > 0
            if DEBUG4, fprintf('    >> have enough features: %d\n', length(flists)); end
            break;
        end
    end


    for tsi = 1:length(X)
        X_feature{tsi} = X{tsi}(flists, :);
    end
end


function [num, sync, metric] = get_extract_feature_opt(opt)
    num = 1;
    sync = 'shift';
    metric = 'dist';
    if nargin < 1, return; end

    opts = regexp(opt, ',', 'split');
    for this_opt = opts
        eval([char(this_opt) ';']);
    end
end
