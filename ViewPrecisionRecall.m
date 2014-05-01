%ViewPrecisionRecall.m
%
%Garrett Warnell
%February 2014

%**************************************************************************
%clean up
clear all; close all; clc;
drawnow;
%**************************************************************************


%**************************************************************************
%malleable parameters

%specify data file
data_name = 'MSRA_PR.mat';

%specify figure file
figfile_name = 'MSRA_PR.png';

%specify which algorithms to plot (comment out to plot all)
alg_ids_plot = {'IT','GB','SF','IG','RS'};

%plotting parameters
aspectRatio = [1.25 1 1];
pixelUnits = 625;
axesNormXStart = 0.07;
axesNormXWidth = 0.905;
axesNormYStart = 0.12;
axesNormYWidth = 0.855;
labelFontSize = 18;
tickFontSize = 12;
legendFontSize = 18;
%**************************************************************************


%**************************************************************************
%rigid parameters

%get computer name and define top-level directory, etc. accordingly
[~, hostname] = system('hostname');
hostname = hostname(1:(end-1));
switch hostname
  case 'warnellwks'
    top_dir = '~/Projects';
    data_dir = 'RaySaliency/out'; %relative to top_dir
  case 'ramawks18'
    top_dir = '/gleuclid/warnellg';
    data_dir = 'RaySaliency/out'; %relative to top_dir
  case 'warnellg-u410'
    top_dir = '~/Dropbox/ARL_Projects';
    data_dir = 'RaySaliency/out'; %relative to top_dir
  case 'warnellg-i7'
    top_dir = 'C:\Users\warnellg\Dropbox\ARL_Projects';
    data_dir = 'RaySaliency\out'; %relative to top_dir
  case 'warnellg-i7-virtualubuntu'
    top_dir = '/media/sf_warnellg/Dropbox/ARL_Projects';
    data_dir = 'RaySaliency/out'; %relative to top_dir
  otherwise
    if(strncmp(hostname,'euclid',6)||strncmp(hostname(2:end),'euclid',6))
      top_dir = '/gleuclid/warnellg';
      data_dir = 'RaySaliency/out'; %relative to top_dir
    else
      error('Unknown hostname!  Please specify a new case for finding files.');
    end
end

%build paths
data_path = fullfile(top_dir,data_dir,data_name);
figfile_path = fullfile(top_dir,data_dir,figfile_name);
%**************************************************************************


%**************************************************************************
%load data
load(data_path);
n_algs = length(alg_ids);
%**************************************************************************


%**************************************************************************
%draw figures
hFig = figure;hold all;
set(hFig,'Color','w');
%plot lines (determine subset if necessary)
lineHandles = cell(1,n_algs);
for a=1:n_algs
  if(exist('alg_ids_plot')&&ismember(alg_ids{a},alg_ids_plot))
    lineHandles{a} = plot(recall{a},precision{a});
    set(lineHandles{a},'linewidth',2.5);
    set(lineHandles{a},'Displayname',alg_ids{a});
  end
end
%set axes limits/ticks
axis([0 1 0 1]);
set(gca,'XTick',0:0.2:1);
set(gca,'YTick',0:0.2:1);
%adjust figure size in pixels
set(hFig,'Units','pixels','OuterPosition',[0 0 pixelUnits*aspectRatio(1:2)]);
set(hFig,'Position',[0 0 pixelUnits*aspectRatio(1:2)]);
%adjust axes size in normalized units relative to figure size
set(gca,'Units','normalized','OuterPosition',[0 0 1 1]);
set(gca,'Units','normalized','Position',[axesNormXStart axesNormYStart axesNormXWidth axesNormYWidth]);
%draw box
a = gca;
set(a,'box','off','color','none')
b = axes('Position',get(a,'Position'),'box','on','xtick',[],'ytick',[],'linewidth',3);
axes(a);
%axes names
xlabel('Recall','Interpreter','latex','FontSize',labelFontSize,'FontWeight','bold');
ylabel('Precision','Interpreter','latex','FontSize',labelFontSize,'FontWeight','bold');
%adjust font
set(gca,'FontSize',tickFontSize,'FontWeight','bold');
%add the legend
hLegend = legend(cell2mat(lineHandles),'Location','NorthEast');
set(hLegend,'FontSize',legendFontSize,'FontWeight','bold','Interpreter','latex');
%export figure
export_fig(figfile_path,'-m2','-nocrop','-painters');
%alert where it was written
fprintf('Figure written to: %s\n',figfile_path);
%**************************************************************************