%% source reconstruction script
 
EEGfiles =  dir([F.DCMbackup filesep 'MEEG*.mat']) % scalp EEG
 
for n = 1:length(EEGfiles)

    fname    = [EEGfiles(n).folder filesep EEGfiles(n).name];
    SEname   = fname(strfind(fname,'SE0'): strfind(fname,'SE0')+4);
    D        =  spm_eeg_load(fname)
    % for c = 1:length(D.trials), D = conditions(D, c, num2str(c)); end


    %% leadfiled

    clear J job
    J.D       = {[fname]};           % MEEG file i.e. MEEG-full_SE004_001
    J.val     = 1;
    J.comment = 'template';
    J.meshings.meshes.template      = 1;    % type of model (mesh)
    J.meshing.meshres               = 2;    % normal granularity mesh
    J.coregistration.coregdefault   = 1;    % register to default
    J.forward.eeg                   = 'EEG BEM';
    job{1}.spm.meeg.source.headmodel = J;
    spm_jobman('run', job);
    close all

    %% complete source IID

    clear J job
    J.D         = {[fname ]}; %i.e. MEEG-full_SE004_001
    J.val       = 1;
    % J.whatconditions.condlabel  = conditions(D);    % conditions to include
    J.custom.invtype            = 'IID';            % Inversion algorithm
    J.custom.foi                = [0 40];           % frequencies of interest
    J.custom.hanning            = 1;
    J.custom.priors.priorsmask  = {''};
    J.custom.restrict.locs      = zeros(0,3);
    J.customrestrict.radius     = 32;
    J.custom.restrict.mask      = {''};
    J.modality                  = {'EEG'};
    job{1}.spm.meeg.source.invert = J;
    spm_jobman('run', job);
    % saveas(gcf, s.source_fig)
    close all

    %% select source
    % location previoulsy defined on a clear SE window

%     if  exist([F.sources_backup filesep SEname '_L.mat'])

        load([F.sources_backup filesep SEname '_L.mat'])

%     else
% 
%         clear L
%         load(fname) % reload the D struct updated after source reconstr
%         clear mMAP xMAP
%         for d = 1:length(D.other.inv{1}.inverse.J)
%             mMAP{d} = mean(D.other.inv{1}.inverse.J{d},2); % mean value across time
%             xMAP(d) = max(mMAP{d}); % max value across space
%         end
%         [v i] = max(xMAP);
%         [v l] = max(mMAP{i});
%         L.xyz = fix(D.other.inv{1}.forward.mesh.vert(l,:) * 1000)
%         save([F.today filesep s.folder '_L.mat'],'L')
% 
%     end


    %% Extract and save source waveforms

    clear S
    % MEEG = spm_eeg_load(fname); % sensor data
    xyz  = L.xyz;
    % scalefactor = sqrt(xyz(1)^2+xyz(2)^2+xyz(3)^2);
    scalefactor = norm(xyz);

    S.D = [fname  ]; %i.e. MEEG-full_SE004_001
    S.dipoles.pnt = L.xyz;
    S.dipoles.ori = L.xyz / scalefactor;
    S.dipoles.label = {'LFP'};
    sD = spm_eeg_dipole_waveforms(S); % saves to %i.e. MMEEG-full_SE004_001
    close all

end
