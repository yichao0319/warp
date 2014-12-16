%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Yi-Chao Chen @ UT Austin
%%
%% get_trace_match
%%
%% Output
%%   - X: the 3D data
%%        1st dim (cell): words / subjects / ...
%%        2nd dim (matrix): features
%%        3rd dim (matrix): samples over time
%%   - gt_class: vector of ground-truth class 
%%        the class the word/subject belongs to.
%%        always labeled as 1, 2, 3, ...
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [X, gt_class] = get_trace_match(trace_name, trace_opt)
    DEBUG2 = 1;

    if DEBUG2, fprintf('  trace: %s (opt: %s)\n', trace_name, trace_opt); end

    if strcmp(trace_name, 'word')
        [X, gt_class] = get_trace_match_word(trace_opt);
    elseif strcmp(trace_name, 'deap')
        [X, gt_class] = get_trace_match_deap(trace_opt);
    elseif strcmp(trace_name, 'acc-chest')
        [X, gt_class] = get_trace_match_acc_chest(trace_opt);
    elseif strcmp(trace_name, 'acc-wrist')
        [X, gt_class] = get_trace_match_acc_wrist(trace_opt);
    else
        error(['wrong trace name: ' trace_name]);
    end
end

