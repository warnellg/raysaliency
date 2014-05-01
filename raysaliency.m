%raysaliency.m
%
%Garrett Warnell
%February 2014
%
%DESCRIPTION:
%    computes ray saliency graph function for supplied spatial and function
%    values over nodes in a graph
%
%INPUTS:
%    *X: p-by-N matrix, where each column (x_i) specifies the p-dimensional
%    spatial coordinate of the corresponding node
%
%    *F: d-by-N matrix, where each column (f_i) specifies the d-dimensional
%    function value at the corresponding node
%
%    *sig_x: the standard deviation of the Gaussian function that encodes
%    spatial similarity, i.e.,
%        sim_x(x_i,x_j) = exp{ -0.5 * (d_x(x_i,x_j)/sig_x)^2 }
%
%    *c_sig: (optional, default=3) the number of standard deviations in the
%    spatial domain that define the Euclidean neighborhood of a given node,
%    i.e.,
%        nbhd_x(i) = { j | d_x(x_i,x_j) <= 2*sin(c_sig*sig_x/2) }
%
%OUTPUTS:
%    *mu: the 1-by-N array of saliency values corresponding to each node
%
%REFERENCES:
%    [1] Warnell et al. "Ray Saliency: Bottom-up Saliency for a Rotating
%    and Zooming Camera." 2014.

function mu = raysaliency(X,F,sig_x,c_sig)

%find number of data points
N = size(X,2);

%set up default inputs
if(nargin<4)
  c_sig = 3;
end

%create kd tree based on euclidean spatial distance
kdt = createns(X.','NSMethod','kdtree','Distance','euclidean');

%compute saliency node-by-node (parallel?)
mu = zeros(N,1);
for i=1:N
  %find neighbors and calculate saliency
  nbhds = rangesearch(kdt,X(:,i).',2*sin(c_sig*sig_x/2));
  nbhd = setdiff(nbhds{1},i);
  if(~isempty(nbhd))
    n_nbhd = length(nbhd);   
    spatialweights = exp(-0.5*(acos(X(:,i).'*X(:,nbhd))/sig_x).^2);
    featureweights = sqrt(sum((repmat(F(:,i),1,n_nbhd)-F(:,nbhd)).^2,1));
    mu(i) = sum(spatialweights.*featureweights)/sum(spatialweights);    
  else
    mu(i) = 0;
  end
end