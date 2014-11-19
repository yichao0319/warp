function [pid,idx] = spectral_bisect(A,split_opt,lap_opt)
%
% [pid,idx] = SPECTRAL_BISECT(A,split_opt,lap_opt) partitions nodes of a graph
% (with affinity matrix A) into 2 parts using spectral methods
%
% When A is asymmetric (i.e. the graph is directed), the graph Laplacian
% for directed graph is used (see comments in laplacian.m)
%
% Input:
%
%      A:         Affinity matrix
%
%      split_opt: where to split ('mean', 'median', 'zero', 'opt')
%
%      lap_opt:   which laplacian to generate ('rw', 'sym', 'unnormalized')
%                 default: 'rw' (as suggested by Luxburg 2006).
%
% Output:
%
%      pid:       part id (pid = 1 => in part 1, pid = 2 => in part 2)
%
%      idx:       linear order obtained through spectral reordering
%                 (should be identical to spectral_reorder(A,lap_opt)
%
% file:        spectral_bisect.m
% directory:   /u/yzhang/MRA/Matlab/
% created:     Wed Oct  8 2008 
% author:      Yin Zhang 
% email:       yzhang@cs.utexas.edu
%

  if nargin < 2, split_opt = 'median'; end  
  if nargin < 3, lap_opt = 'rw';    end  
  
  % for laplacian(A,'sym'), we need to use the normalized Fiedler vector
  % which is the same as the (unnormalized) Fiedler vector of laplacian(A,'rw')
  if (strcmpi(lap_opt, 'sym'))
    lap_opt = 'rw';
  end
  
  m = size(A,1);
  if (m <= 1)
    pid = ones(1,m);
    idx = ones(m,1);
    return
  end

  % make A s
  if ((~issparse(A)) & (nnz(A) < 0.2*m*m))
    A = sparse(A);
  end
  
  L = laplacian(A,lap_opt);
  
  % find eigenvectors corresponding to 2 smallest eigenvalues
  v2 = fiedler(L);
  [v2_sorted,idx] = sort(v2,'descend');

  % find the split location
  switch(lower(split_opt))
   case {'zero'}
    % split at 0
    s_loc = max(find(v2_sorted >= 0));
    
   case {'mean'}
    % split at the mean
    v2avg = mean(v2_sorted);
    s_loc = max(find(v2_sorted >= v2avg));
   
   case {'median'}
    % split at the median
    if (mod(m,2) == 0)
      s_loc = m/2;
    else
      s_loc = min_ncut_1d(A,idx,(m-1)/2,(m+1)/2);
    end
   
   case {'opt'}
    % try to minimize the normalized cut in 1-dimension
    s_loc = min_ncut_1d(A,idx,1,m-1);
  end  

  pid = ones(m,1);
  pid(idx((s_loc+1):end)) = 2;
   
%
% find k \in kmin:kmax that minimzes Ncut(A,idx(1:k),idx(k+1:end))
% where Ncut(A,I,J) = cut_IJ/vol_I + cut_JI/vol_J
%
% the implementation uses incremental update to keep 
% the quadratic complexity
%
function [kopt] = min_ncut_1d(A,idx,kmin,kmax)

  Asum = sum(A,2);
  
  I = idx(1:kmin);
  J = idx(kmin+1:end);
  
  cut_IJ = sum(sum(A(I,J)));
  vol_I  = sum(Asum(I));
  cut_JI = sum(sum(A(J,I)));
  vol_J  = sum(Asum(J));
  ncut   = cut_IJ/(eps+vol_I) + cut_JI/(eps+vol_J);
  kopt   = kmin;
  
  for k = (kmin+1):kmax
    j = idx(k);
    
    % incrementally update cut_IJ, cut_JI, vol_I, vol_J, I, J
    cut_IJ = cut_IJ - sum(A(I,j)) + sum(A(j,J)) - A(j,j);
    cut_JI = cut_JI - sum(A(j,I)) + sum(A(J,j)) - A(j,j);
    vol_I  = vol_I + Asum(j);
    vol_J  = vol_J - Asum(j);
    I      = [I; j];
    J      = J(2:end);
    
    % compute the new normalized cut metric
    ncut_k = cut_IJ/(eps+vol_I) + cut_JI/(eps+vol_J);
    if (ncut_k < ncut)
      ncut = ncut_k;
      kopt = k;
    end
  end
