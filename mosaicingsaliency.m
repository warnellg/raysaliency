%mosaicingsaliency.m
%
%Garrett Warnell
%March 2014
%
%DESCRIPTION:
%    computes saliency maps for a set of multiple images through the use of
%    a mosaic of these images
%
%INPUTS:
%    *I: cell structure of J images. the order should reflect the order in
%    which it is desired that the images are added to the mosaic
%
%    *zooms: array of J zoom values used to collect the corresponding
%    images in I
%
%    *P: cell structure of J projective transforms that map pixel
%    coordinates in each image of I to pixel coordinates in some
%    predetermined reference image plane (on which we will generate the
%    mosaic)
%
%    *salfun: handle for a function that takes in a single image as input
%    and returns a single saliency map as the output
%
%OUTPUTS:
%    *M: the image mosaic
%
%    *SM: the saliency map generated from M
%
%    *S: cell structure containing individual saliency maps corresponding
%    to each input image
%
%REFERENCES:
%    [1] Warnell et al. "Ray Saliency: Bottom-up Saliency for a Rotating
%    and Zooming Camera." 2014.

function [M, SM, S] = mosaicingsaliency(I,zooms,P,salfun)

%sort by zoom so we draw in order of increasing zoom
[~, sortIdx] = sort(zooms);
I = I(sortIdx);
P = P(sortIdx);

%create the mosaic, apply the saliency algorithm, and backproject to the
%original image coordinates
M = images_to_mosaic(I,P);
SM = salfun(M);
S = mosaic_to_images(SM,P,[size(I{1},1) size(I{1},2)]);

%undo zoom sorting for the output set of maps
unsorted = 1:numel(I);
newIdx(sortIdx) = unsorted;
S = S(newIdx);