%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Yi-Chao Chen @ UT Austin
%%
%% - Input:
%%
%%
%% - Output:
%%
%%
%% example:
%%
%%     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function check_rhythm(trace_name, trace_opt)
    
    %% --------------------
    %% DEBUG
    %% --------------------
    DEBUG0 = 0;
    DEBUG1 = 1;
    DEBUG2 = 1;  %% progress
    DEBUG3 = 1;  %% verbose
    DEBUG4 = 1;  %% results


    %% --------------------
    %% check input
    %% --------------------
    if nargin < 2, 
        if strcmp(trace_name, 'p300')
            trace_opt = 'subject=1,session=1,img_idx=0';
        elseif strcmp(trace_name, '4sq')
            trace_opt = 'num_loc=100,num_rep=1,loc_type=1';
        elseif strcmp(trace_name, 'deap')
            trace_opt = 'video=1';
        elseif strcmp(trace_name, 'muse')
            trace_opt = 'muse=''4ch''';
        else
            trace_opt = 'na'; 
        end
    end


    %% --------------------
    %% Variable
    %% --------------------
    output_dir = './tmp/';


    %% --------------------
    %% Main starts
    %% --------------------
    
    %% --------------------
    %% load data
    %% --------------------
    if DEBUG2, fprintf('load data\n'); end

    [X, r, bin, alpha, lambda] = get_trace(trace_name, trace_opt);
    if DEBUG3, 
        fprintf('  X size: %dx%d\n', size(my_cell2mat(X)));
    end

    ts{1} = X;
    plot_ts(ts, [output_dir trace_name '.ts']);


    %% --------------------
    %% desync data
    %% --------------------
    if DEBUG2, fprintf('desync data\n'); end
    
    other_mat = {};
    desync_opt = 'desync=0.15';
    [X_desync, other_desync] = desync_data(X, other_mat, desync_opt);

    if DEBUG3, 
        fprintf('  X size: %dx%d\n', size(my_cell2mat(X_desync)));
    end
    
    desync_ts{1} = X_desync;
    plot_ts(desync_ts, [output_dir trace_name '.desync_ts']);


    %% --------------------
    %% synchronization
    %% --------------------
    if DEBUG2, fprintf('synchronization\n'); end

    X_cluster{1} = X_desync;
    other_mat = {};
    other_cluster = {};

    sync_opt = 'sync=''shift'',metric=''coeff''';
    [X_sync, other_cluster] = do_sync(X_cluster, sync_opt, other_mat, '');

    sync_ts{1} = X_sync{1};
    plot_ts(sync_ts, [output_dir trace_name '.sync_ts']);

end