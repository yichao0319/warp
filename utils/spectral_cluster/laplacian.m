function [L] = laplacian(A,lap_opt)
%
% [L] = laplacian(A,lap_opt) construct the Laplacian for an input graph
% specified by affinity matrix A.
%
% When A is asymmetric (i.e. the graph is directed), the graph Laplacian
% for directed graph is used (cf. Chung 2005, Zhou 2005)
%
% Input:
%
%      A:         Affinity matrix
%      lap_opt:   which laplacian to generate ('rw', 'sym', 'unnormalized')
%                 default: 'rw' (as suggested by Luxburg 2006).
%
% Output:
%
%      L:         the graph Laplacian
%
% Reference: 
%
%   F. Chung.
%   Laplacians and the Cheeger inequality for directed graphs.
%   Annals of Combinatorics 9 (2005), pp. 1--19
%   http://www.math.ucsd.edu/~fan/wp/dichee.pdf
%
%   Dengyong Zhou, Jiayuan Huang, and Bernhard Scholkopf
%   Learning from labeled and unlabeled data on a directed graph
%   Proc. 22nd International Conference on Machine Learning (ICML'05)
%   Bonn, Germany, 2005.
%   http://research.microsoft.com/~denzho/papers/LLUD.pdf
%
% file:        laplacian.m
% directory:   /u/yzhang/MRA/Matlab/
% created:     Wed Oct  8 2008 
% author:      Yin Zhang 
% email:       yzhang@cs.utexas.edu
%

  if nargin < 2, lap_opt = 'rw'; end  
  
  m = size(A,1);

  % check whether A is symmetric
  EPS = 1e-10;
  if (max(max(abs(A - A'))) > EPS)
    directed = true;
  else
    directed = false;
  end

  % construct the graph Laplacian
  I = speye(m,m);
  if (~directed) % undirected graph
        
    % deal with empty rows by setting A's diagonal elements to EPS
    d      = full(sum(A,2));
    idx    = find(d == 0);
    d(idx) = EPS;
    A      = A + sparse(idx,idx,EPS,m,m);
    D      = sparse(1:m,1:m,d);
    invD   = sparse(1:m,1:m,1./d);
    
    switch(lower(lap_opt))
     case {'rw'}   % L_rw
      L = I - invD*A;
     case {'sym'}  % L_sym
      L = I - (invD.^0.5)*A*(invD.^0.5);
     otherwise     % L_unnormalized
      L = D - A;
    end
    
  else % directed graph
    
    % reset empty rows of A to EPS
    d        = full(sum(A,2));
    idx      = find(d == 0);
    d(idx)   = EPS*m;
    A(idx,:) = EPS;
    D        = sparse(1:m,1:m,d);
    invD     = sparse(1:m,1:m,1./d);

    % obtain transition probability matrix P
    % (add teleporting probability eta = 0.01; see Zhou 2005)
    eta      = 0.01;
    P        = (1-eta)*invD*A + eta/m;
    
    % compute stationary probability pi
    [p,skip] = eigs(P',1,'LR');
    p        = p./sum(p);
    Pi       = sparse(1:m,1:m,p);
    invPi    = sparse(1:m,1:m,1./p);
    
    switch(lower(lap_opt))
     case {'rw'}   % L_rw
      L = I - 0.5*(P + invPi*P'*Pi);
     case {'sym'}  % L_sym
      Q = (Pi.^0.5)*P*(invPi.^0.5);
      L = I - 0.5*(Q + Q');
     otherwise     % L_unnormalized
      L = Pi - 0.5*(Pi*P + P'*Pi);
    end
  end
