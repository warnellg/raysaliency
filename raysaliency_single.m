%raysaliency_single.m
%
%Garrett Warnell
%February 2014
%
%DESCRIPTION:
%    function to compute the saliency map for a single image using the ray
%    saliency technique
%
%INPUTS:
%    *I: the image for which to compute the saliency map
%
%    *sig_x_pix: the number of pixels sig_x should be
%
%    *reg_slic: (optional, default=1) the spatial regularization parameter
%    for the SLIC algorithm
%
%    *sig_x_sp_factor: (optional, default=15) factor by which to divide
%    sig_x to determine sig_x_sp
%
%    *c_sig: (optional, default=3) number of sig_x's to use in the locality
%    approximation
%
%    *f: (optional, default=1e3) the focal length to use
%
%OUTPUT:
%    *S: the saliency map (normalized such that all values lie between 0
%    and 1).

function S = raysaliency_single(I,sig_x_pix,reg_slic,sig_x_sp_factor,c_sig,f)

%infer parameters
m = size(I,1);
n = size(I,2);

%optional parameters
if(nargin<3)
  reg_slic = 1;
end
if(nargin<4)
  sig_x_sp_factor = 15;
end
if(nargin<5)
  c_sig = 3;
end
if(nargin<6)
  f = 1e3;
end

%back-calculate the camera matrix
C = [f 0 n/2;0 f m/2;0 0 1];

%set up pixel coordinates
[x_ip, y_ip] = meshgrid(1:n,1:m);
N = m*n;

%back-calculate the sig_x (rad) that induces the requested sig_x_pix
sig_x = atan(sig_x_pix/f);

%get the superpixels
sig_x_sp = sig_x/sig_x_sp_factor;
[labels, labelnums] = slic_ray(I,f,sig_x_sp,reg_slic);
nlabels = numel(labelnums);

%find mean position/color for each superpixel
n_rays = nlabels;
V_ray = zeros(3,n_rays);
V_f = zeros(3,n_rays);
ray_idx = 1;
for i=1:nlabels
  %find linear indicies of this label (labels start with zero)
  labelidx = find(labels==labelnums(i));
  %compute ray coordinate that corresponds to centroid
  V_ray(:,ray_idx) = C\[mean(x_ip(labelidx));mean(y_ip(labelidx));1];
  V_ray(:,ray_idx) = V_ray(:,ray_idx)/norm(V_ray(:,ray_idx));
  %compute mean color
  V_f(:,ray_idx) = mean([I(labelidx).';I(N+labelidx).';I(2*N+labelidx).'],2);
  %update position in list
  ray_idx = ray_idx+1;
end

%calculate saliency and normalize
s = raysaliency(V_ray,V_f,sig_x,c_sig);
s_norm = s(:)-min(s(:));
s_norm = s_norm/max(s_norm(:));

%translate superpixel saliency values back to saliency maps
S = zeros(m,n);
for i=1:nlabels
  S(labels==labelnums(i)) = s_norm(i);
end