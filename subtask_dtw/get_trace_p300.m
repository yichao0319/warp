%% get_trace_p300: function description
%% opt:
%%   - subject
%%   - session
%%   - img_idx
%%     > 1~6
%%     > 0: target
%%     > 7: random
function [X, r, bin] = get_trace_p300(opt)
    [subject, session, img_idx, mat_type] = get_p300_opt(opt);

    inputdir = '/scratch/cluster/yichao/warp/processed_data/subtask_parse_p300/';
    num_chennels = 32;
    % subjects = [1 2 3 4 6 7 8 9];
    % sessions = [1:4];

    %% --------------------
    %% load data
    %% --------------------
    filename = [inputdir 's' int2str(subject) int2str(session)];
    load(filename); %% data in "runs"
    
    tmp1 = [];
    for ri = 1:length(runs)
        stimuli = runs{ri}.stimuli;

        if img_idx == 0
            target = runs{ri}.target;
            target_idx = (target == stimuli);

        elseif (img_idx >= 1) && (img_idx <= 6)
            target = img_idx;
            target_idx = (target == stimuli);

        elseif img_idx == 7
            target_idx = 1:nnz(runs{ri}.target == stimuli);
        end

        tmp2 = [];
        for chi = 1:num_chennels
            tmp2 = cat(2, tmp2, squeeze(runs{ri}.x(chi, :, target_idx))' );
        end
        tmp1 = cat(1, tmp1, tmp2);
    end

    X = num2cell(tmp1, 2);
    r = 10;
    bin = 1;
end


function [subject, session, img_idx, mat_type] = get_p300_opt(opt)
    subject = 1;
    session = 1;
    img_idx = 1;
    mat_type = 1;

    opts = regexp(opt, ',', 'split');
    for this_opt = opts
        eval([char(this_opt) ';']);
    end
end
