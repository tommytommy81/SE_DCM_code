clear all
close all
clc

%% ==========================================================================
F = se_housekeeping('Krasniy');        % Initial housekeeping
N = size(F.T,1);

%% from EEG to vLFP
source_flag = 0;
if source_flag == 1,
se_EEG2vLFP; end

%% prepare DCM struct

for nfile = 1:N,     F.nfile = nfile;     se_dcmspec(F ); end

%% DCM inversion and inference

for nfile = 1:N,     F.nfile = nfile;        se_dcminvert(F);    end % this takes ~1h

%% build stacked FCM

se_build_FCM(F)
load([F.today filesep  F.FCMfilename '.mat'],'FCM')

%% some sanity checks

se_sanitychecks_PSDfit_scaling

%% PEB model 

se_PEB_3models(F)


%% Paper Figures
 
% prepare files objects
se_merge_MMEEG

% Figure1
se_Figure1 
se_Figure1C

% Figure2 
se_Figure2 % recreate script for DCM computation!


% Figure3
se_Figure3 

% Figure4
precomput = 0; % to recompute the simulated paramater space
se_Figure4 

