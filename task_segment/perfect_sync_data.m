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

function [sync_X, sync_sample_class] = perfect_sync_data(X, sample_class, opt)
    
    %% --------------------
    %% DEBUG
    %% --------------------
    DEBUG0 = 0;
    DEBUG1 = 1;
    DEBUG2 = 1;  %% progress
    DEBUG3 = 1;  %% verbose
    DEBUG4 = 1;  %% results


    %% --------------------
    %% Constant
    %% --------------------


    %% --------------------
    %% Check input
    %% --------------------


    %% --------------------
    %% Main starts
    %% --------------------
    sync_X = {};
    sync_sample_class = {};
    for ci = 1:max(sample_class{1})
        this_X = {};
        this_sync_sample_class = {};
        for ti = 1:length(X)
            idx = find(sample_class{ti} == ci);
            this_X{ti} = X{ti}(:, idx);
            this_sync_sample_class{ti} = sample_class{ti}(:, idx);
        end

        other_mat{1} = this_sync_sample_class;
        [tmp_X, tmp_other] = sync_data(this_X, opt, other_mat);
        
        if length(sync_X) == 0
            sync_X = tmp_X;
            sync_sample_class = tmp_other{1};
        else
            if length(sync_X) ~= length(tmp_X)
                error('wrong number of subjects');
            end

            for ti = 1:length(sync_X)
                sync_X{ti} = [sync_X{ti} tmp_X{ti}];
                sync_sample_class{ti} = [sync_sample_class{ti} tmp_other{1}{ti}];
            end
        end
    end

end