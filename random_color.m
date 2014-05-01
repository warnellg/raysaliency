%random_color.m
%
%Ming-Yu Liu
%2011 (copyright)
%
%Garrett Warnell
%January 2014 (modified)
%
%DESCRIPTION:
%    from a superpixel segmentation, color each pixel randomly.
%
%INPUTS:
%    *img: the input image
%
%    *labels: the labeled image
%
%    *labelnums: the label numbers that appear in the labelled image
%
% OUTPUTS
%    *out: the colored image.

function [out] = random_color(img,labels,labelnums)

[height, width, dim] = size(img);
rimg = zeros(height,width);
gimg = zeros(height,width);
bimg = zeros(height,width);
for i=1:numel(labelnums)
    idx = find(labels==labelnums(i));
    rimg(idx) = rand(1);
    gimg(idx) = rand(1);
    bimg(idx) = rand(1);
end
out = img;
out(:,:,1) = rimg;
out(:,:,2) = gimg;
out(:,:,3) = bimg;