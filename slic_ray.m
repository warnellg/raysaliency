%slic_ray.m
%
%Garrett Warnell
%February 2014
%
%DESCRIPTION:
%    computes SLIC superpixels for a given image with approximate size
%    determined by supplied parameters (focal length, desired size on the
%    sphere, etc.)
%
%DEPENDENCIES:
%    *VLFeat (run vl_setup)
%
%INPUTS:
%    *I: the m-by-n-by-c input image (c=1 for grayscale, c=3 for color)
%
%    *f: the focal length at which I was captured
%
%    *sig_x_sp: desired angular width (rad) of each superpixel
%
%    *reg_slic: (optional, default=1) the spatial regularizer for the SLIC
%    algorithm
%
%    *nlabels_min: (optional, default=36) the minimum number of superpixels
%    to start with
%
%    *nlabels_max: (optional, default=4096) the maximum number of
%    superpixels to start with
%
%OUTPUTS:
%    *labels: m-by-n array of superpixel labels for each pixel
%
%    *labelnums: list of all labels that appear in labels
%
%REFERENCES:
%    [1] Achanta et al. "SLIC Superpixels." EPFL Tech. Rep. 149300. 2010.
%
%    [2] Vedaldi and Fulkerson. "VLFeat: An Open and Portable Library of
%    Computer Vision Algorithms." http://www.vlfeat.org/. 2008.
%
%    [3] Warnell et al. "Ray Saliency: Bottom-up Saliency for a Rotating
%    and Zooming Camera." 2014.

function [labels, labelnums] = slic_ray(I,f,sig_x_sp,reg_slic,nlabels_min,nlabels_max)

%inferred parameters
m = size(I,1);
n = size(I,2);

%default parameters
if(nargin<6)
  nlabels_max = 4096;
end
if(nargin<5)
  nlabels_min = 36;
end
if(nargin<4)
  reg_slic = 1;
end

%determine minimum and maximum initalization for superpixel width
w_slic_max = floor(max(m,n)/sqrt(nlabels_min));
w_slic_min = ceil(min(m,n)/sqrt(nlabels_max));  

%determine superpixel width based on sig_x_sp and clip appropriately
if(sig_x_sp>pi)
  w_slic_sig = max(m,n);
else
  w_slic_sig = 2*f*tan(sig_x_sp);
end
w_slic = max(min(w_slic_sig,w_slic_max),w_slic_min);

%use SLIC to extract superpixels
labels = vl_slic(im2single(I),w_slic,reg_slic);
labelnums = unique(labels);