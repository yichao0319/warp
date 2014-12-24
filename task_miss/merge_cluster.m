%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Yi-Chao Chen @ UT Austin
%%
%% - Input:
%%   - opt
%%     > merge: merge cluster if necessary
%%       - num: #members of a cluster < thresh
%%       - sim: similarity of a cluster < thresh 
%%       - top: top "thresh" clusters with highest similarity
%%       - na: don't merge
%%     > thresh
%%     > head
%%       - rand
%%       - best
%%       - worst
%%
%% - Output:
%%   - cluster_members: 2D data
%%       1st dim (cell): clusters
%%       2nd dim (vector): cluster member idx
%%
%% example:
%%
%%     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [cluster_members, cluster_head, cluster_affinity] = merge_cluster(cluster_idx, cluster_head, cluster_affinity, affinity, opt)
    
    %% --------------------
    %% DEBUG
    %% --------------------
    DEBUG0 = 0;
    DEBUG1 = 1;
    DEBUG2 = 1;  %% progress
    DEBUG3 = 1;  %% verbose
    DEBUG4 = 1;  %% results

    if nargin < 5, opt = ''; end


    %% get option
    [merge, thresh, head_type] = get_merge_opt(opt);

    if strcmp(merge, 'na')
        for ci = 1:length(cluster_head)
            cluster_members{ci} = find(cluster_idx == ci);
        end
    elseif strcmp(merge, 'num')
        [val, cluster_order] = sort(cluster_affinity, 'descend');

        cnt = 0;
        skip_members = [];
        for ii = 1:length(cluster_order)
            ci = cluster_order(ii);

            mem_idx = find(cluster_idx == ci);
            if length(mem_idx) < thresh
                skip_members = [skip_members, mem_idx];
                continue;
            end

            cnt = cnt + 1;
            
            cluster_members{cnt} = mem_idx;
            new_cluster_head(cnt) = cluster_head(ci);
            new_cluster_affinity(cnt) = cluster_affinity(ci);
        end

        if length(skip_members) > 0
            cnt = cnt + 1;

            if 0
                %% only merge skipped flows
                cluster_members{cnt} = skip_members;
            else
                %% have a cluster include all flows
                cluster_members{cnt} = 1:length(cluster_idx);
            end

            tmp_affinity = affinity(cluster_members{cnt}, cluster_members{cnt});
            [new_cluster_head(cnt), new_cluster_affinity(cnt)] = select_head(head_type, tmp_affinity);
        end

        cluster_head = new_cluster_head;
        cluster_affinity = new_cluster_affinity;

    elseif strcmp(merge, 'sim')
        [val, cluster_order] = sort(cluster_affinity, 'descend');

        cnt = 0;
        skip_members = [];
        for ii = 1:length(cluster_order)
            ci = cluster_order(ii);

            mem_idx = find(cluster_idx == ci);
            if cluster_affinity(ci) < thresh
                skip_members = [skip_members, mem_idx];
                continue;
            end

            cnt = cnt + 1;
            
            cluster_members{cnt} = mem_idx;
            new_cluster_head(cnt) = cluster_head(ci);
            new_cluster_affinity(cnt) = cluster_affinity(ci);
        end

        if length(skip_members) > 0
            cnt = cnt + 1;

            if 0
                %% only merge skipped flows
                cluster_members{cnt} = skip_members;
            else
                %% have a cluster include all flows
                cluster_members{cnt} = 1:length(cluster_idx);
            end

            tmp_affinity = affinity(cluster_members{cnt}, cluster_members{cnt});
            [new_cluster_head(cnt), new_cluster_affinity(cnt)] = select_head(head_type, tmp_affinity);
        end

        cluster_head = new_cluster_head;
        cluster_affinity = new_cluster_affinity;


    elseif strcmp(merge, 'top')
        [val, cluster_order] = sort(cluster_affinity, 'descend');

        for ii = 1:min(thresh, length(cluster_order))
            ci = cluster_order(ii);
            
            cluster_members{ii} = find(cluster_idx == ci);
            new_cluster_head(ii) = cluster_head(ci);
            new_cluster_affinity(ii) = cluster_affinity(ci);
        end

        cluster_head = new_cluster_head;
        cluster_affinity = new_cluster_affinity;

    else
        error(['wrong merge type=' merge ' (opt=' opt ')']);
    end

end


function [merge, thresh, head] = get_merge_opt(opt)
    merge  = 'na';
    thresh = 0;
    head   = 'best';

    opts = regexp(opt, ',', 'split');
    for this_opt = opts
        eval([char(this_opt) ';']);
    end
end
