function [k] = get_num_clusters(L,kmax)
%
% [k] = GET_NUM_CLUSTERS(L) automatically select the number of clusters
% from the graph Laplacian L using the eigengap heuristic
%
% Input:
%
%      L:      the graph Laplacian
%
%      kmax:   max number of clusters (default: ceil(2*sqrt(m/2)))
%
%              According to http://en.wikipedia.org/wiki/Data_clustering,
%              a rule of thumb is to set k = k0 = sqrt(m/2).  We therefore
%              set kmax to kmax = 2*k0.
%
% Output:
%
%      k:      the number of clusters
%
% file:        get_num_clusters.m
% directory:   /u/yzhang/MRA/Matlab/
% created:     Sun Oct 12 2008 
% author:      Yin Zhang 
% email:       yzhang@cs.utexas.edu
%

  m = size(L,1);
  if ((nargin < 2) | isempty(kmax))
    kmax = min(m,ceil(2*sqrt(m/2)));
  end

  ev     = eigs(L,kmax,'SR');
  egap   = diff(sort(ev));
  [eg,k] = max(egap);
