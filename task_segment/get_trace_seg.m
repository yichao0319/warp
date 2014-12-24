%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Yi-Chao Chen @ UT Austin
%%
%% get_trace_seg
%%
%% - Input
%%   - trace_name
%%     > word
%%     > deap
%%     > acc-chest
%%     > acc-wrist
%%   - trace_opt
%%     > feature:
%%       The preprocessing of the data
%%       - raw, mfcc, spectrogram, lowrank, quantization, mag, and etc
%%     > set:
%%       The class set to use (for acc-wrist)
%%       set = 1, 2, or 3
%%     > num:
%%       Number of classes to be concategated
%%       - num == 0: use all classes
%%
%% - Output
%%   - X: the 3D data
%%        1st dim (cell): subjects / words / ...
%%        2nd dim (matrix): features
%%        3rd dim (matrix): samples over time
%%   - sample_class: 2D data
%%        the class that each sample belongs to
%%        the classes are always labeled from 1, 2, 3, ...
%%        1st dim (cell): subjects / words /...
%%        2nd dim (vector): class of samples
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [X, sample_class] = get_trace_seg(trace_name, trace_opt)
    DEBUG2 = 1;

    if DEBUG2, fprintf('  trace: %s (opt: %s)\n', trace_name, trace_opt); end

    if strcmp(trace_name, 'word')
        [X, sample_class] = get_trace_seg_word(trace_opt);
    elseif strcmp(trace_name, 'deap')
        % [X, sample_class] = get_trace_seg_deap(trace_opt);
        error('XXX: not implemented yet');
    elseif strcmp(trace_name, 'acc-chest')
        % [X, sample_class] = get_trace_seg_acc_chest(trace_opt);
        error('XXX: not implemented yet');
    elseif strcmp(trace_name, 'acc-wrist')
        [X, sample_class] = get_trace_seg_acc_wrist(trace_opt);
    else
        error(['wrong trace name: ' trace_name]);
    end
end

