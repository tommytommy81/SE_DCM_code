%% MERGE conditions and create

% LFP_seg: spm object with all LFPs
% ICMsummary: dcm object with all conditions



 


%% collect all vLFP in the object: LFP_seg

% create reccond - recordings conditions

se_vLFP_conditions(F); 

load([F.today filesep 'reccond'],'reccond')
%     {'2ndLine NonResp post'}
%     {'2ndLine NonResp pre' }
%     {'2ndLine Resp post'   }
%     {'2ndLine Resp pre'    }
%     {'Benz NonResp post'   }
%     {'Benz NonResp pre'    }
%     {'Benz Resp post'      }
%     {'Benz Resp pre'       }

% 
meegfiles       = dir([F.DCMbackup filesep 'MM*.mat'])

ftdata = []
pos    = 1

quantisono = []
chie       = []

for ii = 1:52

    % check category


    DCM.xY.Dfile    = [meegfiles(ii).folder filesep meegfiles(ii).name];

    LFP             = spm_eeg_load(DCM.xY.Dfile);
    Fs              = fsample(LFP);
    smpls           = size(LFP,2);
    timax           = linspace(9, smpls/Fs, smpls); % time vector
    clist           = condlist(LFP); % cell array of SLIDE_<begin sample>

    for s = 1:size(LFP,3)
        ftdata.trial{pos} = LFP(1,:,s);
        ftdata.time{pos}  = timax;
        ftdata_clist{pos} = [reccond(ii).cond ' ' clist{1}];
        chie = [chie ceil(ii/2)];

        pos = pos+1;
    end

    quantisono = [quantisono s];  

end


ftdata.label = 'LFP';
D = spm_eeg_ft2spm(ftdata, [F.today filesep 'LFP_seg']);

for c = 1:length(ftdata_clist)

    D = conditions(D, c, ftdata_clist{c});
end


save(D)

%% DCM prepare

F.spm_file = [F.today filesep 'LFP_seg'];

LFP             = spm_eeg_load(F.spm_file);
Fs              = fsample(LFP);
smpls           = size(LFP,2);
timax           = linspace(9, smpls/Fs, smpls); % time vector
clist           = condlist(LFP); % cell array of SLIDE_<begin sample>



% Set up DCM details
%--------------------------------------------------------------------------
clear P
for c = 1:length(clist)
    disp(['Window ' num2str(c) ' of ' num2str(length(clist))])
    DCM.xY.Dfile         = F.spm_file;

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
    DCM.name = [F.today filesep 'DCM_temp.mat'];

    DCM  = spm_dcm_erp_data(DCM); % prepares structures for forward model
    DCM  = spm_dcm_erp_dipfit(DCM, 1); % Prepare structures for ECD forward model
    DCM  = spm_dcm_csd_data(DCM); % gets cross-spectral density data-features using a VAR model
    DCM.options.DATA = 0;

    % DCM.onset    = onsets(c);
    % DCM.rel2drug = c - drugwindow;
    DCM.xY.R(DCM.xY.R < 0.01) = 0;
    DCM.xY.R     = sparse(DCM.xY.R);
    save([F.folderDCM filesep 'DCM_' clist{c}], 'DCM');
    % P(c)         = DCM;

end

%% invert DCMs

load([F.today filesep 'FCM']) % for reference on L

% Load DCM files
%--------------------------------------------------------------------------
fs      = filesep;
D       = spm_eeg_load(F.spm_file);
conds   = condlist(D);
clear DCM
for c = 1:length(conds)
    T           = load([F.folderDCM filesep 'DCM_' conds{c}]);
    DCM(c)      = T.DCM;
    DCM(c).name = [F.folderDCM fs 'ICM_' conds{c}];
end

% Invert individual DCMs without altered priors
%--------------------------------------------------------------------------
P = DCM(1);
[pE,pC]  = nae_spm_dcm_neural_priors(P.A,P.B,P.C,P.options.model);
[pE,pC]  = spm_L_priors(P.M.dipfit,pE,pC);
[pE,pC]  = spm_ssr_priors(pE,pC);

 

clear ICM
for c = 1:length(conds)
%     Lprior      = FCM{1, 1}.Ep.L;
    scaleprior  = FCM{1, 1}.xY.datascale;
    DCM(c).xY.datascale = scaleprior;
    DCM(c).M.pE   = pE  ;
    DCM(c).M.pC   = pC  ;
    DCM(c).M.pE.L = 10;
    DCM(c).M.pC.L = 0;
    ICM(c) = nae_spm_dcm_csd(DCM(c));
end


figure,

rows = length(conds);
nsplot = 1
for c = [6 5 2 1 4 3  8 7]

    cols = 1
    Nparams = 14;

    Glabels = {'T_s_s', 'T_s_p', 'T_i_i', 'T_d_p',...
        'G_s_p', 'G_s_p_-_s_s', 'G_i_i_-_s_s', 'G_i_i', 'G_s_s_-_i_i', ...
        'G_d_p_-_i_i', 'G_s_s_-_d_p', 'G_i_i_-_d_p', 'G_d_p', 'G_s_s', }

    Tcon  = 1:4;
    Gmod  = [1 4 9 10]+4;
    Gexc  = [5 6 7 ]+4;
    Gihn  = [2 3 8]+4;

    Ep_idx = [Tcon Gmod Gexc  Gihn ];


    idx1 = 1:length(Tcon);
    idx2 = length(Tcon)+1:length([Tcon Gmod]);
    idx3 = length([Tcon Gmod])+1:length([Tcon Gmod Gexc]);
    idx4 = length([Tcon Gmod Gexc])+1:length(Ep_idx);


    Ep_all = [ICM(c).Ep.T ICM(c).Ep.G]';
    subplot(rows/2,2,nsplot),
    bar(idx1,Ep_all(idx1,1),'facecolor','b');
    hold on, bar(idx2,Ep_all( idx2,1),'facecolor','g');
    hold on, bar(idx3,Ep_all( idx3,1),'facecolor','c');
    hold on, bar(idx4,Ep_all( idx4,1),'facecolor','m');
    set(gca,'XTick',1:Nparams,'XTickLabel',[Glabels(Tcon) Glabels(Gmod) Glabels(Gexc) Glabels(Gihn)],'XTickLabelRotation',90)
    ylim([-1 1])%*max(max(abs(Ep_all))))
    title( conds{c} )

    nsplot  = nsplot+1;
end

%

ICMfiles       = dir([F.today filesep 'ICM*.mat'])



save([F.today filesep 'ICMsummary'], 'ICM')

%% plot PSD

close all


load([F.today filesep 'ICMsummary'], 'ICM')

for c = 1:8
conds2plot{c} = ICM(c).xY.code{1, 1};end

figure,

for c = [1 2 3 4 ]
subplot(221)
plot(ICM(c).xY.Hz,   abs( ICM(c).xY.y{1})  )
hold on
subplot(222)
plot(ICM(c).xY.Hz,   abs( ICM(c).Hc{1})  )
hold on
end
legend(conds2plot([1 2 3 4  ]))

for c = [5:8 ]
subplot(223)
semilogy(ICM(c).xY.Hz,   abs( ICM(c).xY.y{1})  )
hold on
subplot(224)
semilogy(ICM(c).xY.Hz,   abs( ICM(c).Hc{1})  )
hold on
end
legend(conds2plot(5:8))



figure,

for c = 1:8
subplot(121)
semilogy(ICM(c).xY.Hz,   abs( ICM(c).xY.y{1})  )
hold on
subplot(122)
semilogy(ICM(c).xY.Hz,   abs( ICM(c).Hc{1})  )
hold on
end
legend(conds2plot)

%


figure(1)

save([F.today filesep 'ICMsummary'], 'ICM')
for c = 1:8
conds2plot{c} = ICM(c).xY.code{1, 1};end
figure,
colors = 'rmbc'
for c = 1:4
    subplot(211)
    plot(ICM(c).xY.Hz,   abs( ICM(c).xY.y{1}), 'color', colors(c)  )
    hold on
    subplot(212)
    semilogy(ICM(c).xY.Hz,   abs( ICM(c).xY.y{1}), 'color', colors(c)   )
    hold on

    legend(conds2plot(1:4))
end