function [v,e] = fiedler(L,tol)
%
% [v,e] = FIEDLER(L,tol) returns the (unnormalized) Fiedler vector
% from Laplacian matrix L
%
% Input:
%
%      L:      the graph laplacian
%
%      tol:    tolerance level for eigs()
%
% Output:
%
%      v:      the Fiedler vector (i.e. 2nd smallest eigenvector of L)
%
%      e:      the 2nd smallest eigenvalue of L
%
% file:        fiedler.m
% directory:   /u/yzhang/MRA/Spectral/
% created:     Mon Nov  3 2008 
% author:      Yin Zhang 
% email:       yzhang@cs.utexas.edu
%

  if nargin < 2, tol = 1e-6; end
  
  m          = size(L,1);
  
  % set options for eigs()
  opts.disp  = 0;
  opts.tol   = tol;
  opts.v0    = ones(m,1)/sqrt(m);
  opts.maxit = 1000;
  
  % find eigenvectors corresponding to 2 smallest eigenvalues
  [V,ev]     = eigs(L,2,'SR',opts);
  
  % return the result
  v          = V(:,2);
  e          = ev(2,2);
