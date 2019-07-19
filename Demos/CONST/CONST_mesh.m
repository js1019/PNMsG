% build up an constant solid model
clear all; clc;
addpath('../../modelbuilder/'); 

fmesh  = './output/CONST3k/CONST_1L_3k';
%fmesh = '/pylon5/ac4s8pp/js116/trueG/CONST128M/CONST_1L_128M';
%tetgen = '/home/js116/Documents/tetgen1.5.0/tetgen';
tetgen = '../../packages/tetgen1.5.0/tetgen';

% finite element order (choose 1 or 2)
pOrder  = 1;

% set the value to contral the degrees of freedom
a = 5e8; %392 3k
%a = 3e8; %392 5k 
%a = 1.5e8; % 956 10k
%a = 9e7; % 956 20k 
%a = 5e7; % 3k6 40k 
%a = 2.5e7; % 6k 80k 
%a = 1.4e7; % 15k 160k 
%a = 6e6; % 15k 320k 
%a = 3.3e6; % 42k 640k 
%a = 2e6; % 42k 1M
%a = 1e6; % 94k 2M
%a = 5e5; % 167k 4M 
%a = 2.5e5; % 167k 8M 
%a = 2.6e5; % 377k 8M
%a = 1.3e5; % 589k 16M


% load radial information
load ../../radialmodels/PREM/prem3L_noocean.mat


% radius 
R1 = RD(1,1); 

% load unit spheres
load ../../Discontinuities/data/Sph392.mat

p1 = R1*p;
np1 = size(p1,1); t1 = t; nt1 = size(t1,1);

istart = 1; iend = np1; 
pin(istart:iend,:) = p1;

istart = 1; iend = nt1; 
tin(istart:iend,:) = t1;

tic
% generate internal surfaces 
trisurf2poly(fmesh,pin,tin);
toc 

fhed = [fmesh,'.1_mesh.header'];
fele = [fmesh,'.1_ele.dat'];
fngh = [fmesh,'.1_neigh.dat'];
fnde = [fmesh,'.1_node.dat'];

% generate the mesh
unix([tetgen,' -pq1.5nYVFAa',num2str(a,'%f'),' ',fmesh,'.poly']);
toc
[pout,tout,~,~,neigh] = read_mesh3d([fmesh,'.1']);

dh =[size(tout,1) size(pout,1)];
fid = fopen(fhed,'w');
fprintf(fid,'%d %d',dh);

fid=fopen(fele,'w');
fwrite(fid,tout','int');
fid=fopen(fngh,'w');
fwrite(fid,neigh','int');
fid=fopen(fnde,'w');
fwrite(fid,pout','float64');

%vtk_write_general([fmesh,'_face.vtk'],'test',pin,tin);
toc
fprintf('check number of elements %d \n', size(tout,1));


run CONST_models
