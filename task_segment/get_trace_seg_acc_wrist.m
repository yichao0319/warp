%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Yi-Chao Chen @ UT Austin
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [X, sample_class] = get_trace_seg_acc_wrist(opt)
    
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


    %% --------------------
    %% Check input
    %% --------------------
    if nargin < 1, opt = ''; end
    

    %% --------------------
    %% Main starts
    %% --------------------

    %% --------------------
    %% get option
    [feature, set, num] = get_trace_seg_acc_wrist_opt(opt);


    %% -----------------------
    %% select activity set
    if set == 1
        activities = activities1;
    elseif set == 2
        activities = activities2;
    elseif set == 3
        activities = {activities1{:}, activities2{:}};
    end


    %% -----------------------
    %% select activities to concatenate
    if num <= 0, num = length(activities); end
    select_idx = 1:num;
    

    %% -----------------------
    %% read raw data
    min_num_subjects = -1;
    for ai = select_idx
        activity = char(activities{ai});

        dirname = [input_dir activity '/'];
        filenames = dir([dirname, '*.txt']);
        for si = 1:length(filenames)
            fh = fopen([dirname filenames(si).name], 'r');
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

            raw_X{ai}{si} = [x_set; y_set; z_set];
        end

        if length(raw_X{ai}) < min_num_subjects | min_num_subjects < 0
            min_num_subjects = length(raw_X{ai});
        end
    end

    if DEBUG2,
        fprintf('    #activities=%d: ', length(raw_X));
        fprintf('%d,', select_idx);
        fprintf('\n');
        fprintf('    min num subjects=%d\n', min_num_subjects);
    end


    for si = 1:min_num_subjects
        X{si} = [];
        sample_class{si} = [];

        for ai = select_idx
            %% -----------------------
            %% preprocessing
            prep_data = preporcess_data(raw_X{ai}{si}, feature);
            this_class = ones(1, size(prep_data,2)) * ai;

            X{si} = [X{si} prep_data];
            sample_class{si} = [sample_class{si} this_class];
        end
    end

end


function [feature, set, num] = get_trace_seg_acc_wrist_opt(opt)
    feature = 'raw';
    set = 1;
    num = 0;
    if nargin < 1, return; end

    opts = regexp(opt, ',', 'split');
    for this_opt = opts
        eval([char(this_opt) ';']);
    end
end


%% preporcess_wav
function [prep_data] = preporcess_data(data, feature)
    
    r0 = 20;
    step = 0.1;

    if strcmp(feature, 'raw')
        prep_data = data;

    elseif strcmp(feature, 'mag')
        prep_data = sqrt(data(1,:).^2 + data(2,:).^2 + data(3,:).^2);

    elseif strcmp(feature, 'quantization')
        prep_data = floor(data / step);
        
    elseif strcmp(feature, 'mag_quantization')
        prep_data = floor(sqrt(data(1,:).^2 + data(2,:).^2 + data(3,:).^2) / step);

    elseif strcmp(feature, 'lowrank')
        [U, S, V] = svd(data);
        
        U_lr = U(:, 1:min(r0,end));
        S_lr = S(1:min(r0,end), 1:min(r0,end));
        V_lr = V(:, 1:min(r0,end));

        prep_data = U_lr * S_lr * V_lr';

    elseif strcmp(feature, 'lowrank_quantization')
        [U, S, V] = svd(data);
        
        U_lr = U(:, 1:min(r0,end));
        S_lr = S(1:min(r0,end), 1:min(r0,end));
        V_lr = V(:, 1:min(r0,end));

        prep_data = floor(U_lr * S_lr * V_lr' / step );

    else
        error(['wrong feautre: ' feature]);
        
    end
end
