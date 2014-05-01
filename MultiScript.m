%MultiScript.m
%
%Garrett Warnell
%March 2014
%
%DESCRIPTION:
%    script to perform ray saliency processing on multi-image datasets
%
%DEPENDANCIES:
%    *VLFeat (run vl_setup)

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

%file name for saving
save_name = 'rs_sp_out.mat';
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
      save_dir = '/gleuclid/warnellg/rs_out';
    else
      error('Unknown hostname!  Please specify a new case for finding files.');
    end
end

%dataset things (directories relative to top_dir above)
switch data_id
  case 'office'
    calinfo_dir = 'Common/data/cal';
    calinfo_name = 'cal_arl2.mat';
    data_name = 'arl2_office/arl2_office.mat';    
    j_touse = [1 4 7 10 19 84 93 94];    
    sig_x = 0.11;
  case 'orangecones'
    calinfo_dir = 'Common/data/cal';
    calinfo_name = 'cal_avw143.mat';
    data_name = 'avw143_orangecones/avw143_orangecones.mat';
    j_touse = [1 3 27 30];    
    sig_x = 0.05;
  case 'watertruck'
    calinfo_dir = 'Common/data/cal';
    calinfo_name = 'cal_avw143.mat';
    data_name = 'avw143_watertruck/avw143_watertruck.mat';
    j_touse = [1 5 6 12 15];    
    sig_x = 0.01;
  otherwise
    error('Unknown dataset id!');
end

%build paths
data_path = fullfile(top_dir,data_dir,data_name);
calinfo_path = fullfile(top_dir,calinfo_dir,calinfo_name);
save_path = fullfile(save_dir,save_name);
%**************************************************************************


%**************************************************************************
%load data
fprintf('Loading data...');
tic;
%load/format data
D = load(data_path);
cal = load(calinfo_path);
n_images = length(j_touse);
I = cell(n_images,1);
Ilab = cell(n_images,1);
ptz = cell(n_images,1);
K = cell(n_images,1);
R = cell(n_images,1);
C = cell(n_images,1);
f_avg = zeros(n_images,1);
for j=1:n_images
  %load the image and generate the corresponding camera matrix
  I{j} = im2single(D.J{j_touse(j)}.img);
  Ilab{j} = im2single(vl_xyz2lab(vl_rgb2xyz(I{j})));
  ptz{j} = D.J{j_touse(j)}.c;
  [K{j}, R{j}] = generateCameraMatrix(cal,ptz{j});
  C{j} = K{j}*R{j};
  f_avg(j) = mean([K{j}(1,1) K{j}(2,2)]);
end
t_l = toc;
fprintf('complete (%f sec.)!\n',t_l);
%**************************************************************************


%**************************************************************************
%calculate ray saliency
fprintf('Calculating saliency...');
tic;
S = raysaliency_multi(Ilab,C,f_avg,sig_x);
t_rs = toc;
fprintf('complete (%d sec.)!\n',t_rs);
%**************************************************************************


%**************************************************************************
%save data
fprintf('Saving...');

%organize relevant info into struct and save
rs.data_id = data_id;
rs.j_touse = j_touse;
rs.I = I;
rs.ptz = ptz;
rs.C = C;
rs.f_avg = f_avg;
rs.n_images = n_images;
rs.S = S;
rs.t_rs = t_rs;
if(exist('reg_slic','var'))
  rs.reg_slic = reg_slic;
end
save(save_path,'-struct','rs');
fprintf('complete!\n');
%**************************************************************************