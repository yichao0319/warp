%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Yi-Chao Chen @ UT Austin
%%
%% cal_cluster_obj
%%   calculate the objective function with given features.
%%   obj = mean(inter-cluster-similarity) / intra-cluster-similarity
%%      the smaller value means the better seperation of clusters so is the better
%%
%% - Input:
%%   - X: the 3D data
%%        1st dim (cell): subjects / words / ...
%%        2nd dim (matrix): features
%%        3rd dim (matrix): samples over time
%%   - gt_class: vector of ground-truth class 
%%        the class the word/subject belongs to.
%%        always labeled as 1, 2, 3, ...
%%   - opt:
%%     > sync: shift, stretch
%%     > metric: coeff, dist
%%
%% - Output:
%%   - obj
%%
%%     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [obj] = cal_cluster_obj(X, gt_class, opt)
    
    %% --------------------
    %% DEBUG
    %% --------------------
    DEBUG0 = 0;
    DEBUG1 = 1;
    DEBUG2 = 1;
    DEBUG3 = 0;  %% verbose


    %% --------------------
    %% Check input
    %% --------------------
    if nargin < 3, opt = ''; end
    

    %% --------------------
    %% Main starts
    %% --------------------

    %% get opt
    [sync, metric] = get_cal_custer_obj_opt(opt);


    %% get affinity matrix
    aff_type = 'mat';
    affinity = get_affinity(X, sync, metric, aff_type);
    
    if strcmp(metric, 'dist')
        affinity = 1 ./ affinity;
        idx = isinf(affinity);
        affinity(idx) = max(affinity(~idx));
    end

    if DEBUG3, affinity, end


    %% find cluster heads
    for ai = 1:max(gt_class)
        idx = find(gt_class == ai);
        this_aff = affinity(idx, idx);
        [val, ii] = max(sum(this_aff, 2));
        head(ai) = idx(ii);
        
        if DEBUG3,
            fprintf('    cluster %d head = %d\n', ai, head(ai));
        end
    end


    %% for each class, calculate the objective: intra / inter 
    for ai1 = 1:max(gt_class)
        this_head = head(ai1);
        inter_sim = 0;

        for ai2 = 1:max(gt_class)
            idx = find(gt_class == ai2);

            if ai1 == ai2
                %% intra class similarity
                if nnz(ismember(idx, this_head)) < 1
                    error('cannot find the cluster head');
                end

                idx = setxor(idx, this_head);
                intra_sim = mean(affinity(this_head, idx)); 


                if DEBUG3, 
                    fprintf('    cluster %d(head=%d) intra: ', ai1, this_head);
                    fprintf('%d,', idx);
                    fprintf('\n');
                    fprintf('      similarity = %f\n', intra_sim);
                end

            else
                %% inter class similarity
                inter_sim = inter_sim + mean(affinity(this_head, idx)); 

                if DEBUG3, 
                    fprintf('    cluster %d(head=%d) to %d: ', ai1, this_head, ai2);
                    fprintf('%d,', idx);
                    fprintf('\n');
                    fprintf('      similarity = %f\n', mean(affinity(this_head, idx)));
                end
            end
        end

        
        if strcmp(metric, 'coeff')
            %% make them positive values
            intra_sim = intra_sim + 1;
            inter_sim = inter_sim + 1;
        end
        inter_sim = inter_sim / (max(gt_class)-1);
        obj(ai1) = inter_sim / intra_sim;


        if DEBUG3, 
            fprintf('    > cluster %d: obj = %f\n', ai1, obj(ai1));
        end
    end

    obj = mean(obj);
end


function [sync, metric] = get_cal_custer_obj_opt(opt)
    sync = 'shift';
    metric = 'dist';
    if nargin < 1, return; end

    opts = regexp(opt, ',', 'split');
    for this_opt = opts
        eval([char(this_opt) ';']);
    end
end
