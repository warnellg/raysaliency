%raysaliency_multi.m
%
%Garrett Warnell
%February 2014
%
%DESCRIPTION:
%    computes ray saliency for multi-image data
%
%INPUTS:
%    *I: cell structure of J images
%
%    *C: cell structure of the J camera matrices used to form images in I
%
%    *f: J-by-1 array of the (average) focal lengths used to form images in
%    I
%
%    *sig_x: std of Gaussian neighborhood (rad.)
%
%    *reg_slic: (optional, default=1) spatial regularizaion parameter for
%    the SLIC superpixel algorithm
%
%    *sig_x_sp_factor: (optional, default=15) factor by which to divide
%    sig_x to determine sig_x_sp
%
%    *c_sig: (optional, default=3) number of sig_x's to use in the locality
%    approximation
%
%OUTPUTS:
%    *S: cell structure of saliency maps corresponding to the images in I

function S = raysaliency_multi(I,C,f,sig_x,reg_slic,sig_x_sp_factor,c_sig)

%optional parameters
if(nargin<5)
  reg_slic = 1;
end
if(nargin<6)
  sig_x_sp_factor = 15;
end
if(nargin<7)
  c_sig = 3;
end

%inferred parameters
J = length(I);
m = size(I{1},1);
n = size(I{1},2);

%set up pixel coordinates
[x_ip, y_ip] = meshgrid(1:n,1:m);
N = m*n;

%get the superpixels
labels = cell(J,1);
labelnums = cell(J,1);
nlabels = zeros(J,1);
sig_x_sp = sig_x/sig_x_sp_factor;
for j=1:J
  [labels{j}, labelnums{j}] = slic_ray(I{j},f(j),sig_x_sp,reg_slic);
  nlabels(j) = numel(labelnums{j});
end

%find mean position/color for each superpixel (ray)
n_rays = sum(nlabels);
V_ray = zeros(3,n_rays);
V_f = zeros(3,n_rays);
ray_idx = 1;
for j=1:J
  %loop superpixels
  for i=1:nlabels(j)
    %find linear indicies of this label (labels start with zero)
    labelidx = find(labels{j}==labelnums{j}(i));    
    %compute ray coordinate that corresponds to centroid
    V_ray(:,ray_idx) = C{j}\[mean(x_ip(labelidx));mean(y_ip(labelidx));1];
    V_ray(:,ray_idx) = V_ray(:,ray_idx)/norm(V_ray(:,ray_idx));    
    %compute mean color    
    V_f(:,ray_idx) = mean([I{j}(labelidx).';I{j}(N+labelidx).';I{j}(2*N+labelidx).'],2);    
    %update position in list
    ray_idx = ray_idx+1;
  end
end

%calculate saliency and normalize
s = raysaliency(V_ray,V_f,sig_x,c_sig);
s_norm = s(:)-min(s(:));
s_norm = s_norm/max(s_norm(:));

%re-organize into maps
S = cell(J,1);
for j=1:J
  %initialize the saliency map
  S{j} = zeros(m,n);
  %find the offset for indexing into s
  if(j==1)
    offset_idx = 0;
  else
    offset_idx = sum(nlabels(1:(j-1)));
  end
  %map each superpixel's saliency value into the image
  for i=1:nlabels(j)
    S{j}(labels{j}==labelnums{j}(i)) = s_norm(offset_idx+i);
  end
end