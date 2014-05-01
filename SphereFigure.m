%SphereFigure.m
%
%Garrett Warnell
%March 2014
%
%DESCRIPTION:
%   script to generate the sphere figure to help explain ray saliency

%**************************************************************************
%clean up
clear; close all; clc;
drawnow;
%**************************************************************************


%**************************************************************************
%malleable parameters
f_touse = [10 20];
m = 16;
n = 16;
%**************************************************************************


%**************************************************************************
%rigid parameters
[X_ip, Y_ip] = meshgrid(1:n,1:m);
X_ip = X_ip - n/2;
Y_ip = Y_ip - m/2;
n_f = length(f_touse);
C = cell(n_f,1);
Vray = cell(n_f,1);
for i=1:n_f
  C{i} = [ f_touse(i) 0 0;
           0 f_touse(i) 0;
           0 0 1;];
  Vray{i} = C{i}\[X_ip(:).';Y_ip(:).';ones(1,m*n);];
  Vray{i} = bsxfun(@rdivide,Vray{i},sqrt(sum(Vray{i}.^2,1)));    
end
%**************************************************************************


%**************************************************************************
%generate the figure
figure;
[X_sph, Y_sph, Z_sph] = sphere(100);
sph_surf = surf(X_sph,Y_sph,Z_sph);
set(sph_surf,'facecolor','b','facealpha',0.05,'edgealpha',0.05);
hold all; axis equal; axis off; 
plot3(X_ip(:)/f_touse(1),Y_ip(:)/f_touse(1),1/f_touse(1)*ones(1,m*n),...
  'k.','MarkerSize',5)
plot3(Vray{1}(1,:),Vray{1}(2,:),Vray{1}(3,:),'b.','MarkerSize',5);
% plot3(Vray{2}(1,:),Vray{2}(2,:),Vray{2}(3,:),'g.','MarkerSize',5);
%**************************************************************************