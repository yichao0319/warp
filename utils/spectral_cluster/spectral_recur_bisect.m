function [idx,clist] = spectral_recur_bisect(A,max_level,split_opt,lap_opt) 
%
% [idx,clist] = SPECTRAL_RECUR_BISECT(A,max_level,split_opt,lap_opt) partitions nodes of a graph
% (with affinity matrix A) into 2 parts using spectral methods
%
% When A is asymmetric (i.e. the graph is directed), the graph Laplacian
% for directed graph is used (see comments in laplacian.m)
%
% Input:
%
%      A:         Affinity matrix
%
%      max_level: max-level to perform bisection
%
%      split_opt: where to split ('mean', 'median', 'zero', 'opt')
%
%      lap_opt:   which laplacian to generate ('rw', 'sym', 'unnormalized')
%                 default: 'rw' (as suggested by Luxburg 2006).
%
% Output:
%
%      idx:       a global linear order of elements 
%
%      clist:     clist{i} contains the size of each cluster at level i
%
% file:        spectral_recur_bisect.m
% directory:   /u/yzhang/MRA/Matlab/
% created:     Wed Oct  8 2008 
% author:      Yin Zhang 
% email:       yzhang@cs.utexas.edu
%

  if nargin < 2, max_level = inf;      end
  if nargin < 3, split_opt = 'median'; end  
  if nargin < 4, lap_opt = 'rw';       end  
  
  % for laplacian(A,'sym'), we need to use the normalized Fiedler vector
  % which is the same as the (unnormalized) Fiedler vector of laplacian(A,'rw')
  if (strcmpi(lap_opt, 'sym'))
    lap_opt = 'rw';
  end
  
  m         = size(A,1);

  [pid,idx] = spectral_bisect(A,split_opt,lap_opt);
  cl(1)     = sum(pid == 1);
  cl(2)     = sum(pid == 2);
  clist{1}  = cl;

  done  = false;
  level = 1;
  while(~done)
    level  = level + 1;
    cl_old = clist{level-1}; 
    cl_new = zeros(1,2^level);
    
    ibeg = 0;
    iend = 0;
    for c = 1:length(cl_old)
      clen = cl_old(c);
      ibeg = iend + 1;
      iend = iend + clen;
      I    = idx(ibeg:iend);
      
      [pid_c,idx_c] = spectral_bisect(A(I,I),split_opt,lap_opt);
      
      % reverse the order if it helps reduce the number of
      % order reversals (compared with 1:clen)
      rev_idx_c = (clen+1) - idx_c;
      if (get_num_reversal(rev_idx_c) < get_num_reversal(idx_c))
        idx_c = rev_idx_c;
        pid_c = (max(pid_c)+1) - pid_c;
      end
      
      cl_new(2*c-1)  = sum(pid_c == 1);
      cl_new(2*c)    = sum(pid_c == 2);
      idx(ibeg:iend) = I(idx_c);
    end
    
    clist{level} = cl_new;
    if ((max(cl_new) <= 1) | (level >= max_level))
      done = true;
    end
  end

  
% 
% compare idx with 1:m to get the number of order reversals
%
function [nrev] = get_num_reversal(idx)

  m    = length(idx);
  nrev = 0;
  for i = 1:(m-1)
    nrev = nrev + sum(idx((i+1):m) < idx(i));
  end
