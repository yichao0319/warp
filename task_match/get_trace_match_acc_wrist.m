%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Yi-Chao Chen @ UT Austin
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [X, gt_class] = get_trace_match_acc_wrist(opt)
    addpath('../utils');
    
    %% --------------------
    %% DEBUG
    %% --------------------
    DEBUG0 = 0;
    DEBUG1 = 1;
    DEBUG2 = 1;


    %% --------------------
    %% Constant
    %% --------------------


    %% --------------------
    %% Variable
    %% --------------------
    input_dir  = '/u/yichao/warp/data/acc-wrist/';
    % output_dir = '';
    activities1 = {'Climb_stairs_MODEL', 'Drink_glass_MODEL', 'Getup_bed_MODEL', 'Pour_water_MODEL', 'Sitdown_chair_MODEL', 'Standup_chair_MODEL', 'Walk_MODEL'};
    activities2 = {'Brush_teeth', 'Comb_hair', 'Descend_stairs', 'Eat_meat', 'Eat_soup', 'Liedown_bed', 'Use_telephone'};

    step = 0.1;
    r0 = 20;
    

    %% --------------------
    %% Check input
    %% --------------------
    if nargin < 1, opt = ''; end
    

    %% --------------------
    %% Main starts
    %% --------------------
    [feature, set] = get_trace_match_acc_wrist_opt(opt);

    if set == 1
        activities = activities1;
    elseif set == 2
        activities = activities2;
    elseif set == 3
        activities = {activities1{:}, activities2{:}};
    end

    tsc = 0;
    for ai = 1:length(activities)
        activity = char(activities{ai});

        dirname = [input_dir activity '/'];
        filenames = dir([dirname, '*.txt']);
        for i = 1:length(filenames)
            fh = fopen([dirname filenames(i).name], 'r');
            data = fscanf(fh, '%d\t%d\t%d\n', [3,inf]);
            fclose(fh);

            % CONVERT THE ACCELEROMETER DATA INTO REAL ACCELERATION VALUES
            % mapping from [0..63] to [-14.709..+14.709]
            noisy_x = -14.709 + (data(1,:)/63)*(2*14.709);
            noisy_y = -14.709 + (data(2,:)/63)*(2*14.709);
            noisy_z = -14.709 + (data(3,:)/63)*(2*14.709);

            % REDUCE THE NOISE ON THE SIGNALS BY MEDIAN FILTERING
            n = 3;      % order of the median filter
            x_set = medfilt1(noisy_x,n);
            y_set = medfilt1(noisy_y,n);
            z_set = medfilt1(noisy_z,n);

            tsc = tsc + 1;
            raw_X{tsc} = [x_set; y_set; z_set];
            gt_class(tsc) = ai;
        end
    end


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
    elseif strcmp(feature, 'quantization')
        X = raw_X;
        for tsi = 1:length(raw_X)
            for ri = 1:size(raw_X{tsi}, 1)
                X{tsi}(ri, :) = X{tsi}(ri, :) - min(X{tsi}(ri, :));
                X{tsi}(ri, :) = X{tsi}(ri, :) / max(X{tsi}(ri, :));
                X{tsi}(ri, :) = floor(X{tsi}(ri, :) / step);
            end
        end
    elseif strcmp(feature, 'mag_quantization')
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

    elseif strcmp(feature, 'lowrank_quantization')
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
     
end


function [feature, set] = get_trace_match_acc_wrist_opt(opt)
    feature = 'raw';
    set = 1;
    if nargin < 1, return; end

    opts = regexp(opt, ',', 'split');
    for this_opt = opts
        eval([char(this_opt) ';']);
    end
end
