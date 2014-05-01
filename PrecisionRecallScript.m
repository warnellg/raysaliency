%PrecisionRecallScript.m
%
%Garrett Warnell
%February 2014
%
%DESCRIPTION:
%    *generates the precision/recall curves for a database of single images
%    with ground truth masks and saliency maps

%**************************************************************************
%clean up
clear; close all; clc;
drawnow;
%**************************************************************************


%**************************************************************************
%malleable parameters

%dataset identifier
data_id = 'MSRA';

%algorithm set
alg_ids = {'FI','SF','AC','GB','IG','IT','MZ','RS','SR'};

%number of thresholds to look at for precision/recall
n_thresh = 256;

%display options
VIZ_PR = false;
%**************************************************************************


%**************************************************************************
%rigid parameters

%get computer name and define top-level directory, etc. accordingly
[~, hostname] = system('hostname');
hostname = hostname(1:(end-1));
switch hostname
  case 'warnellwks'
    top_dir = '~/Projects/RaySaliency';
    save_dir = 'out';
  case 'ramawks18'
    top_dir = '/gleuclid/warnellg/RaySaliency';
    save_dir = 'out'; %relative to top_dir
  case 'warnellg-u410'
    error('Paths not yet defined for this machine!');
  case 'warnellg-i7-virtualubuntu'
    error('Paths not yet defined for this machine!');
  otherwise
    if(strncmp(hostname,'euclid',6)||strncmp(hostname(2:end),'euclid',6))
      top_dir = '/gleuclid/warnellg/RaySaliency';
      save_dir = 'out'; %relative to top_dir
    else
      error('Unknown hostname!  Please specify a new case for finding files.');
    end
end

%dataset things
switch data_id
  case 'MSRA'
    sal_dir = 'out/MSRA'; %relative to top_dir
    mask_dir = 'data/single/MSRA/mask'; %relative to top_dir
    mask_ext = 'bmp';
  otherwise
    error('Unknown dataset id!');
end

%build (partial) paths
sal_loc = fullfile(top_dir,sal_dir);
mask_loc = fullfile(top_dir,mask_dir);
save_path = fullfile(top_dir,save_dir,[data_id '_PR.mat']);

%get list of image names to process
mask_names = dir(fullfile(mask_loc,['*.' mask_ext]));
n_masks = length(mask_names);
n_algs = length(alg_ids);
%**************************************************************************


%**************************************************************************
%parallel warning
product_info = ver;
has_parallel_toolbox = false;
for i=1:length(product_info)
    if(strcmp(product_info(i).Name,'Parallel Computing Toolbox'))
        has_parallel_toolbox = true;
        break;
    end
end
if(has_parallel_toolbox && matlabpool('size')==0)
    fprintf('WARNING: No parallel workers found! Press any key to continue...\n');
    pause;
end
%**************************************************************************


%**************************************************************************
%compute precision/recall for each algorithm

%loop over algorithm specifiers
precision = cell(1,n_algs);
recall = cell(1,n_algs);
n_masks_used = zeros(n_algs,1);
sal_loc_alg = cell(n_algs,1);
sal_ext = cell(n_algs,1);
sal_name_format = cell(n_algs,1);
parfor a=1:n_algs
  %build location to saliency maps
  switch alg_ids{a}
    case 'AC'
      sal_loc_alg{a} = fullfile(sal_loc,'AC');
      sal_ext{a} = 'jpg';
      sal_name_format{a} = '%s';
    case 'GB'
      sal_loc_alg{a} = fullfile(sal_loc,'GB');
      sal_ext{a} = 'jpg';
      sal_name_format{a} = '%s';
    case 'IG'
      sal_loc_alg{a} = fullfile(sal_loc,'IG');
      sal_ext{a} = 'jpg';
      sal_name_format{a} = '%s';
    case 'IT'
      sal_loc_alg{a} = fullfile(sal_loc,'IT');
      sal_ext{a} = 'jpg';
      sal_name_format{a} = '%s';
    case 'MZ'
      sal_loc_alg{a} = fullfile(sal_loc,'MZ');
      sal_ext{a} = 'jpg';
      sal_name_format{a} = '%s';
    case 'RS'
      sal_loc_alg{a} = fullfile(sal_loc,'RS');
      sal_ext{a} = 'jpg';
      sal_name_format{a} = '%s';
    case 'SR'
      sal_loc_alg{a} = fullfile(sal_loc,'SR');
      sal_ext{a} = 'jpg';
      sal_name_format{a} = '%s';
    case 'SF'
      sal_loc_alg{a} = fullfile(sal_loc,'SF');
      sal_ext{a} = 'jpg';
      sal_name_format{a} = '%s';
    case 'FI'
      sal_loc_alg{a} = fullfile(sal_loc,'FI');
      sal_ext{a} = 'png';
      sal_name_format{a} = '%s_smap';
    otherwise
      sal_loc_alg{a} = '';
      warning('Algorithm ID %s not found.',alg_ids{a});
  end
  %loop over all mask names to find corresponding files
  if(~strcmp(sal_loc_alg{a},''))
    precision{a} = zeros(n_thresh,1);
    recall{a} = zeros(n_thresh,1);
    for j=1:n_masks
      if(mod(j,25)==1)
        fprintf('\tProcessing for mask %i of %i for algorithm %s...\n',j,n_masks,alg_ids{a});
      end
      %get the name of this mask and make sure we have a corresponding
      %saliency map
      [pathstr,name,ext] = fileparts(mask_names(j).name);
      smask_path = fullfile(sal_loc_alg{a},[sprintf(sal_name_format{a},name) '.' sal_ext{a}]);
      if(exist(smask_path,'file'))
        %load gt mask and saliency mask and compute precision/recall
        mask = rgb2gray(imread(fullfile(mask_loc,[name '.' mask_ext])))>0;
        S = im2double(imread(smask_path));
        if(size(S,3)~=1)
          S = rgb2gray(S);
        end
        [p, r] = precisionRecall(S,mask,n_thresh);
        %add contribution to overall precision/recall values
        precision{a} = precision{a}(:) + p(:);
        recall{a} = recall{a}(:) + r(:);
        n_masks_used(a) = n_masks_used(a) + 1;
      end
    end
    %average
    precision{a} = precision{a}/n_masks_used(a);
    recall{a} = recall{a}/n_masks_used(a);
  end
end
%**************************************************************************


%**************************************************************************
%display precision/recall curve
if VIZ_PR
  figure; hold all;
  for a=1:n_algs
    plot(recall{a},precision{a});
  end
  xlabel('Recall');
  ylabel('Precision');
  drawnow;
end
%**************************************************************************


%**************************************************************************
%save results
pr.data_id = data_id;
pr.alg_ids = alg_ids;
pr.precision = precision;
pr.recall = recall;
save(save_path,'-struct','pr');
%**************************************************************************
