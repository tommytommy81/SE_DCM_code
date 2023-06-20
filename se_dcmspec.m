function P = se_dcmspec(F)


clear DCM

% Load MEEG object and extract sampling rate and info
%--------------------------------------------------------------------------
meegfile        = [F.DCMbackup filesep char(F.T.Filename(F.nfile))]; % point to vLFP 
DCM.xY.Dfile    = meegfile;
LFP             = spm_eeg_load(meegfile); 

Fs              = fsample(LFP); 
smpls           = size(LFP,2); 
timax           = linspace(9, smpls/Fs, smpls); % time vector
clist           = condlist(LFP); % cell array of SLIDE_<begin sample>

% to name the DCM out
ptr2pat_id      = strfind(meegfile,'SE0');
pat_id          = meegfile(ptr2pat_id:ptr2pat_id+8);


%% Set up DCM details
%--------------------------------------------------------------------------
clear P
for c = 1:length(clist)
disp(['Window ' num2str(c) ' of ' num2str(length(clist))])
DCM.options.analysis    = 'CSD';   	% cross-spectral density 
DCM.options.model       = 'CMC';    % structure cannonical microcircuit
DCM.options.spatial    	= 'LFP';    % virtual electrode input   
DCM.options.Tdcm        = [timax(1) timax(end)] * 1000;     % time in ms

DCM.options.Fdcm    = [1 45];     	% frequency range  
DCM.options.D       = 1;         	% frequency bin, 1 = no downsampling
DCM.options.Nmodes  = 8;          	% number of eigenmodes
DCM.options.han     = 0;         	% no hanning 
DCM.options.trials  = c;            % index of ERPs within file

DCM.Sname           = chanlabels(LFP);
DCM.M.Hz            = DCM.options.Fdcm(1):DCM.options.D:DCM.options.Fdcm(2);
DCM.xY.Hz           = DCM.M.Hz;

% Create DCM Struct and specify DCM.options 
%--------------------------------------------------------------------------
DCM.A     	= {1 1 1};
DCM.B    	= {};
DCM.C   	= sparse(length(DCM.A{1}),0);

% Reorganise model parameters in specific structure
%==========================================================================
DCM.M.dipfit.Nm     = DCM.options.Nmodes;
DCM.M.dipfit.model 	= DCM.options.model;
DCM.M.dipfit.type   = DCM.options.spatial;
DCM.M.dipfit.Nc     = size(LFP,1);
DCM.M.dipfit.Ns     = length(DCM.A{1});

% Define empirical priors here
%--------------------------------------------------------------------------
[pE,pC]  = nae_spm_dcm_neural_priors(DCM.A,DCM.B,DCM.C,DCM.options.model);
% [pE,pC]  = spm_dcm_neural_priors(DCM.A,DCM.B,DCM.C,DCM.options.model);
[pE,pC]  = spm_L_priors(DCM.M.dipfit,pE,pC);
[pE,pC]  = spm_ssr_priors(pE,pC); %for CSD analyses

pE.L = 10;  % accounting for virtual electrode gain matrix

DCM.M.pE    = pE;
DCM.M.pC    = pC;

% Estimate CSD and save
%--------------------------------------------------------------------------
DCM.name = [F.folderDCM filesep 'DCM_temp.mat'];
% DCM.name = [F.today filesep 'DCM_' pat_id '.mat'];

DCM  = spm_dcm_erp_data(DCM); % prepares structures for forward model
DCM  = spm_dcm_erp_dipfit(DCM, 1); % Prepare structures for ECD forward model
DCM  = spm_dcm_csd_data(DCM); % gets cross-spectral density data-features using a VAR model
DCM.options.DATA = 0; 

DCM.xY.R(DCM.xY.R < 0.01) = 0; 
DCM.xY.R     = sparse(DCM.xY.R); 
P(c)         = DCM; 

end

%%
delete([F.folderDCM filesep 'DCM_temp.mat'])
save([F.folderDCM filesep 'DCM_' pat_id], 'P');

 