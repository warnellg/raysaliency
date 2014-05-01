%SingleScript.m
%
%Garrett Warnell
%February 2014
%
%DESCRIPTION:
%    runs the ray saliency algorithm on a database of single images

%**************************************************************************
%clean up
clear; close all; clc;
drawnow;
%**************************************************************************


%**************************************************************************
%malleable parameters

%dataset identifier
data_id = 'MSRA';

%display options
VIZ_PROCESSING = false;
%**************************************************************************


%**************************************************************************
%rigid parameters

%get computer name and define top-level directory, etc. accordingly
[~, hostname] = system('hostname');
hostname = hostname(1:(end-1));
switch hostname
  case 'warnellwks'
    top_dir = '~/Projects/RaySaliency';
    data_dir = 'data/single';
    save_dir = 'out';
  case 'ramawks18'
    top_dir = '/gleuclid/warnellg/RaySaliency';
    data_dir = 'data/single'; %relative to top_dir
    save_dir = 'out'; %relative to top_dir
  case 'warnellg-u410'
    error('Paths not yet defined for this machine!');
  case 'warnellg-i7-virtualubuntu'
    error('Paths not yet defined for this machine!');
  otherwise
    if(strncmp(hostname,'euclid',6))
      top_dir = '/gleuclid/warnellg/RaySaliency';
      data_dir = 'data/single'; %relative to top_dir
      save_dir = 'out'; %relative to top_dir
    else
      error('Unknown hostname!  Please specify a new case for finding files.');
    end
end

%dataset things
switch data_id
  case 'MSRA'
    img_dir = 'MSRA/img'; %relative to data_dir
    img_ext = 'jpg';
    mask_dir = 'MSRA/mask'; %relative to data_dir
    mask_ext = 'bmp';
    img_save_dir = 'MSRA/RS';
    sig_x_pix_frac = 0.35; %percent image dimension that defines sig_x_pix
    n_thresh = 256;
  otherwise
    error('Unknown dataset id!');
end

%build (partial) paths
img_loc = fullfile(top_dir,data_dir,img_dir);
mask_loc = fullfile(top_dir,data_dir,mask_dir);
save_loc = fullfile(top_dir,save_dir,img_save_dir);

%get list of image names to process
mask_names = dir(fullfile(mask_loc,['*.' mask_ext]));
n_masks = length(mask_names);
%**************************************************************************


%**************************************************************************
%process data
fprintf('Beginning data processing...\n');

%loop over all images with masks
precision = zeros(n_thresh,1);
recall = zeros(n_thresh,1);
for j=1:n_masks
  if(mod(j,25)==1)
    fprintf('\tProcessing image %i of %i...\n',j,n_masks);
  end
  %load the mask and the image
  [pathstr,name,ext] = fileparts(mask_names(j).name);
  mask = rgb2gray(imread(fullfile(mask_loc,[name '.' mask_ext])))>0;
  I = im2single(imread(fullfile(img_loc,[name '.' img_ext])));
  Ilab = im2single(vl_xyz2lab(vl_rgb2xyz(I)));
  
  %back-calculate sig_x_pix
  m = size(Ilab,1);
  n = size(Ilab,2);
  sig_x_pix = min(m,n)*sig_x_pix_frac;
  
  %run ray saliency
  S = raysaliency_single(Ilab,sig_x_pix);
  
  %save saliency map
  imwrite(S,fullfile(save_loc,[name '.' img_ext]));
  
  %display
  if VIZ_PROCESSING
    subplot(1,3,1);imshow(I);
    subplot(1,3,2);imshow(S);
    subplot(1,3,3);imshow(mask);
    drawnow;
  end
end
%**************************************************************************