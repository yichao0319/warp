%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Yi-Chao Chen @ UT Austin
%%
%% - Input:
%%   - X: 2D data
%%       1st dim (cell): subjects / flows / ...
%%       2nd dim (vector): time series
%%   - other_mat: 3D data -- other matrices to be clustered as X
%%       1st dim (cell): 
%%       2nd dim (cell): subjects / flows / ...
%%       3rd dim (vector): time series
%%   - desync_opt
%%       > desync: ratio of maximal shift
%%   
%%
%% - Output:
%%
%%
%% example:
%%
%%     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [desync_X, desync_other] = desync_data(X, other_mat, desync_opt)
    
    %% --------------------
    %% DEBUG
    %% --------------------
    DEBUG0 = 0;
    DEBUG1 = 1;
    DEBUG2 = 1;  %% progress
    DEBUG3 = 1;  %% verbose
    DEBUG4 = 1;  %% results


    %% --------------------
    %% Variable
    %% --------------------
    

    %% --------------------
    %% Check input
    %% --------------------
    if nargin < 2, other_mat = {}; end
    if nargin < 3, desync_opt = ''; end


    %% --------------------
    %% Main starts
    %% --------------------
    desync_ratio = get_desync_opt(desync_opt);
    desync_len   = floor(desync_ratio * size(X{1},2));

    desync_X = {};
    desync_other = {};
    if desync_len == 0
        desync_X = X;
        desync_other = other_mat;
        return;
    end


    min_len = 0;
    for tsi = 1:length(X)
        shift_len = randi(desync_len);
        w{tsi} = shift_len:size(X{tsi},2);

        if length(w{tsi}) < min_len | tsi == 1
            min_len = length(w{tsi});
        end
    end


    for tsi = 1:length(w)
        desync_X{tsi} = X{tsi}(:, w{tsi}(1:min_len));

        for oi = 1:length(other_mat)
            desync_other{oi}{tsi} = other_mat{oi}{tsi}(:, w{tsi}(1:min_len));
        end
    end
end


function [desync] = get_desync_opt(opt)
    desync = 0.1;

    opts = regexp(opt, ',', 'split');
    for this_opt = opts
        eval([char(this_opt) ';']);
    end
end
