function [idx] = spectral_cluster(A,k,lap_opt,kmax)
%
% [idx] = SPECTRAL_CLUSTER(A,k,lap_opt) clusters a graph
% (with affinity matrix A) into k clusters using spectral clustering 
%
% When A is asymmetric (i.e. the graph is directed), the graph Laplacian
% for directed graph is used (see comments in laplacian.m)
%
% When k <= 0, the eigengap heuristic is used to automatically determine
% the number of clusters (cf. Luxburg 2006)
%
% Input:
%
%      A:         Affinity matrix
%
%      k:         desired number of clusters (k <= 0 ==> automatically
%                 determine k using the eigengap heuristic)
%
%      lap_opt:   which laplacian to generate ('rw', 'sym', 'unnormalized')
%                 default: 'rw' (as suggested by Luxburg 2006).
%
%                 'rw':           the Meila-Shi algorithm is used
%                 'sym':          the Ng, Jordan, Weiss algorithm is used
%                 'unnormalized': unnormalized spectral clustering
%
%      kmax:      kmax parameter for get_num_clusters().  Needed only if k <= 0
%                 (default: kmax = []; see get_num_clusters.m for default kmax there). 
%
% Output:
%
%      idx:       idx(i) gives the cluster that row i belongs to
%
% Reference: 
%
%   Ulrike von Luxburg
%   A Tutorial on Spectral Clustering
%   Statistics and Computing, vol. 17, no. 4, pp. 395--416, December 2007.
%   http://springerlink.metapress.com/content/jq1g17785n783661/fulltext.pdf
%
%   Meila and Jianbo Shi
%   A random walk view of image segmentation.
%   AI and STATISTICS (AISTATS) 2001 
%
%   Andrew Y. Ng, Michael I. Jordan, and Yair Weiss.
%   On spectral clustering: Analysis and an algorithm
%   Advances in Neural Information Processing Systems 14 (2001)
%   http://www-2.cs.cmu.edu/Groups/NIPS/NIPS2001/papers/psgz/AA35.ps.gz 
%
% file:        spectral_cluster.m
% directory:   /u/yzhang/MRA/Matlab/
% created:     Wed Oct  8 2008 
% author:      Yin Zhang 
% email:       yzhang@cs.utexas.edu
%

  if nargin < 2, k = 0;        end
  if nargin < 3, lap_opt = 'rw'; end  
  if nargin < 4, kmax = [];     end
  
  m = size(A,1);

  % make A s
  if ((~issparse(A)) & (nnz(A) < 0.2*m*m))
    A = sparse(A);
  end
  
  L = laplacian(A,lap_opt);
  
  if (k <= 0)
    % automatically select k based on the eigengap heuristic
    k = get_num_clusters(L,kmax);
  end
  
  % find eigenvectors corresponding to k smallest eigenvalues
  [V,ev] = eigs(L,k,'SR');
  
  % normalization for L_sym
  if (strcmpi(lap_opt,'sym'))
    Vnorm = sqrt(sum(V.^2,2));
    V     = V./repmat(Vnorm,1,k);
  end
  
  % do k-means clustering
  idx = kmeans(V,k,'EmptyAction','singleton','Replicates',10);
