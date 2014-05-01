%achanta_sf.m
%
%Garrett Warnell
%February, 2014
%
%DESCRIPTION:
%    implementation of [1]. written in my style but using [2] as a
%    template.
%
%DEPENDANCIES:
%    *VLFeat (run vl_setup)
%
%INPUTS:
%    *I: m-by-n-by-3 RGB image
%
%OUTPUTS:
%    *S: m-by-n saliency map
%
%NOTES:
%    *the input image is assumed to be rgb
%
%REFERENCES
%    [1] Achanta et al. "Frequency-tuned Salient Region Detection." CVPR
%    2009.
%
%    [2] http://ivrgwww.epfl.ch/supplementary_material/RK_CVPR09/SourceCode/Saliency_CVPR2009.m.
%    Accessed 2/24/2013.

function S = achanta_sf(I)

%conver to Lab space and blur
I = im2single(vl_xyz2lab(vl_rgb2xyz(I)));
Ig = imfilter(I,fspecial('gaussian', 3, 3),'symmetric','conv');

%extract channels and compare each to the mean
l = double(Ig(:,:,1)); lm = mean(mean(l));
a = double(Ig(:,:,2)); am = mean(mean(a));
b = double(Ig(:,:,3)); bm = mean(mean(b));

%compute the saliency map and normalize
S = (l-lm).^2 + (a-am).^2 + (b-bm).^2;
S = S-min(S(:));
S = S/max(S(:));