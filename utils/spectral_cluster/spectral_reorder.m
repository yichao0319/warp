function [idx] = spectral_reorder(A,lap_opt)
%
% [idx] = SPECTRAL_REORDER(A,lap_opt) reorders nodes of a graph (with
% affinity matrix A) using spectral methods
%
% When A is asymmetric (i.e. the graph is directed), the graph Laplacian
% for directed graph is used (see comments in laplacian.m)
%
% Input:
%
%      A:         Affinity matrix
%
%      lap_opt:   which laplacian to generate ('rw', 'unnormalized')
%                 default: 'rw' (as suggested by Luxburg 2006).
%
% Output:
%
%      idx:       new order of rows in A
%
% file:        spectral_reorder.m
% directory:   /u/yzhang/MRA/Matlab/
% created:     Wed Oct  8 2008 
% author:      Yin Zhang 
% email:       yzhang@cs.utexas.edu
%

  if nargin < 2, lap_opt = 'rw'; end  

  % for laplacian(A,'sym'), we need to use the normalized Fiedler vector
  % which is the same as the (unnormalized) Fiedler vector of laplacian(A,'rw')
  if (strcmpi(lap_opt, 'sym'))
    lap_opt = 'rw';
  end
  
  m = size(A,1);

  % make A s
  if ((~issparse(A)) & (nnz(A) < 0.2*m*m))
    A = sparse(A);
  end
  
  L = laplacian(A,lap_opt);
  
  % find eigenvectors corresponding to 2 smallest eigenvalues
  v2 = fiedler(L);

  % obtain the linear order by sorting v2
  [v2_sorted,idx] = sort(v2,'descend');
