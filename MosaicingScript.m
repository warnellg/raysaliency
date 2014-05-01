%MosaicingScript.m
%
%Garrett Warnell
%March 2014
%
%DESCRIPTION:
%    script to perform mosaic saliency processing

%**************************************************************************
%clean up
clear; close all; clc;
drawnow;
%**************************************************************************


%**************************************************************************
%malleable parameters

% data_id = 'office';
% data_id = 'orangecones';
data_id = 'watertruck';

%which saliency algorithm to use
sal_id = 'achanta_sf';

%file name for saving
save_name = 'ms_out.mat';

%whether or not to display the various generated images
VIZ_MOSAIC = true;
VIZ_MOSAICMAP = true;
VIZ_MAPS = true;

%whether or not to save the data
SAVE_DATA = true;
%**************************************************************************


%**************************************************************************
%rigid parameters

%get computer name and define top-level directory, etc. accordingly
[~, hostname] = system('hostname');
hostname = hostname(1:(end-1));
switch hostname
  case 'warnellwks'
    top_dir = '~/Projects';
    data_dir = 'RaySaliency/data/multi'; %relative to top_dir
    save_dir = '~/scratch';
  case 'ramawks18'
    top_dir = '~/Dropbox/ARL_Projects';
    data_dir = 'RaySaliency/data/multi'; %relative to top_dir
    save_dir = '~/scratch';
  case 'warnellg-u410'
    top_dir = '~/Dropbox/ARL_Projects';
    data_dir = 'RaySaliency/data/multi'; %relative to top_dir
    save_dir = '~/scratch';
  case 'warnellg-i7-virtualubuntu'
    top_dir = '/media/sf_warnellg/Dropbox/ARL_Projects';
    data_dir = 'RaySaliency/data/multi'; %relative to top_dir
    save_dir = '~/scratch';
  otherwise
    if(strncmp(hostname,'euclid',6))
      top_dir = '~/Dropbox/ARL_Projects';
      data_dir = 'RaySaliency/data'; %relative to top_dir
      save_dir = '/gleuclid/warnellg/ms_out';
    else
      error('Unknown hostname!  Please specify a new case for finding files.');
    end
end

%dataset things (directories relative to top_dir above)
switch data_id
  case 'office'
    data_name = 'arl2_office/arl2_office.mat';
    j_touse = [1 4 19 93 94];
    ref_idx = 3; %index into j_touse
    calinfo_dir = 'Common/data/cal';
    calinfo_name = 'cal_arl2.mat';
  case 'orangecones'
    data_name = 'avw143_orangecones/avw143_orangecones.mat';
    j_touse = [1 3 27 30];
    ref_idx = 4; %index into j_touse
    calinfo_dir = 'Common/data/cal';
    calinfo_name = 'cal_avw143.mat';
  case 'watertruck'
    data_name = 'avw143_watertruck/avw143_watertruck.mat';
    j_touse = [1 5 6 12 15];
    ref_idx = 4; %index into j_touse
    calinfo_dir = 'Common/data/cal';
    calinfo_name = 'cal_avw143.mat';
  otherwise
    error('Unknown dataset id!');
end

%build paths
data_path = fullfile(top_dir,data_dir,data_name);
calinfo_path = fullfile(top_dir,calinfo_dir,calinfo_name);
save_path = fullfile(save_dir,save_name);

%build saliency function handle
switch sal_id
  case 'achanta_sf'
    salfun = @(I)achanta_sf(I);
  otherwise
    error('Unknown saliency algorithm id!');
end
%**************************************************************************


%**************************************************************************
%load data
fprintf('Loading data...');

%load/compute the data
D = load(data_path);
cal = load(calinfo_path);
n_images = length(j_touse);
Irgb = cell(n_images,1);
I = cell(n_images,1);
ptz = cell(n_images,1);
zooms = zeros(n_images,1);
K = cell(n_images,1);
R = cell(n_images,1);
C = cell(n_images,1);
for j=1:n_images
  %load the image and generate the corresponding camera matrix
  I{j} = im2single(D.J{j_touse(j)}.img);
  ptz{j} = D.J{j_touse(j)}.c;
  zooms(j) = ptz{j}.zoom;
  [K{j}, R{j}] = generateCameraMatrix(cal,ptz{j});
  C{j} = K{j}*R{j};
end
P = cell(n_images,1);
for j=1:n_images
  %determine the projective transform that maps coordinates into the
  %reference view
  P{j} = C{ref_idx}/C{j};
end

fprintf('complete!\n');
%**************************************************************************


%**************************************************************************
%compute mosaicing saliency
fprintf('Computing mosaicing saliency...');
tic;
[M, SM, S] = mosaicingsaliency(I,zooms,P,salfun);
t_ms = toc;
fprintf('complete! (%f sec.)\n',t_ms);
%**************************************************************************


%**************************************************************************
%optional visualizations
if VIZ_MOSAIC
  %display mosaic
  warning off images:initSize:adjustingMag
  figure;imshow(M);
  drawnow;
  warning on images:initSize:adjustingMag
end
if VIZ_MOSAICMAP
  warning off images:initSize:adjustingMag
  figure;imshow(SM);
  drawnow;
  warning on images:initSize:adjustingMag
end
if VIZ_MAPS
  for j=1:n_images
    hFig = figure;
    subplot(1,2,1); imshow(I{j});
    subplot(1,2,2); imshow(S{j});
  end
  drawnow;
end
%**************************************************************************


%**************************************************************************
%save data
if SAVE_DATA
  fprintf('Saving...');  
  %organize relevant info into struct and save
  ms.data_id = data_id;
  ms.sal_id = sal_id;
  ms.j_touse = j_touse;
  ms.I = I;
  ms.ptz = ptz;
  ms.zooms = zooms;
  ms.C = C;
  ms.n_images = n_images;
  ms.M = M;
  ms.SM = SM;
  ms.S = S;
  ms.t_ms = t_ms;
  save(save_path,'-struct','ms');
  fprintf('complete!\n');
end
%**************************************************************************