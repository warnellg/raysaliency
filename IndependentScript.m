%IndependentScript.m
%
%Garrett Warnell
%March 2014
%
%DESCRIPTION:
%    script to perform independent saliency processing

%**************************************************************************
%clean up
clear; close all; clc;
drawnow;
%**************************************************************************


%**************************************************************************
%malleable parameters

data_id = 'office';
% data_id = 'orangecones';
% data_id = 'watertruck';

%which saliency algorithm to use
sal_id = 'achanta_sf';

%file name for saving
save_name = 'ip_out.mat';

%whether or not to display the various generated images
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
    j_touse = [1 4 7 10 19 84 93 94];
  case 'orangecones'
    data_name = 'avw143_orangecones/avw143_orangecones.mat';
    j_touse = [1 3 27 30];
  case 'watertruck'
    data_name = 'avw143_watertruck/avw143_watertruck.mat';
    j_touse = [1 5 6 12 15];
  otherwise
    error('Unknown dataset id!');
end

%build paths
data_path = fullfile(top_dir,data_dir,data_name);
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
n_images = length(j_touse);
I = cell(n_images,1);
for j=1:n_images
  %load the image and generate the corresponding camera matrix
  I{j} = im2single(D.J{j_touse(j)}.img);
end

fprintf('complete!\n');
%**************************************************************************


%**************************************************************************
%compute saliency maps through independent processing
fprintf('Computing independently-processed saliency...');
tic;
S = cell(n_images,1);
for j=1:n_images
  S{j} = salfun(I{j});
end
t_ip = toc;
fprintf('complete! (%f sec.)\n',t_ip);
%**************************************************************************


%**************************************************************************
%optional visualizations
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
  ip.data_id = data_id;
  ip.sal_id = sal_id;
  ip.j_touse = j_touse;
  ip.I = I;
  ip.n_images = n_images;
  ip.S = S;
  ip.t_ip = t_ip;
  save(save_path,'-struct','ip');
  fprintf('complete!\n');
end
%**************************************************************************