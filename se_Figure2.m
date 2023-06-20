% addpath('L:\EEG-Archimedes\Projects\Status_Epilepticus\code\ColorBrewer')
% addpath('L:\EEG-Archimedes\Projects\Status_Epilepticus\code\FreezeColors')
% F.figuresfolder = 'L:\EEG-Archimedes\Projects\Status_Epilepticus\Results\Paper Figures'
% 
% F = se_housekeeping('TF');
% folderDCM   = 'DCMinverted';

%% Panel A - SE example in SE - still necessary?

% look into Figure2_EEGexample.m


%%  Panel C  - LPF trace

clear DCM
DCM.xY.Dfile = [F.figuresdata filesep 'Figure2' filesep 'MMEEG-full_SE010_001_1_39.mat'];
load( [F.figuresdata filesep 'Figure2' filesep 'SE010_001_1_39_inverted.mat'])     

LFP  = spm_eeg_load(DCM.xY.Dfile); 
dt   = 1/256;
time = [dt:dt:dt*length(LFP(:))]/60+P(1).rel2drug/2;
plot(time, LFP(:))

hold on
quiver( 15, -4000,  1, 0,'k')
hold on
quiver( 15, -4000, 0, 1000 ,'k','ShowArrowHead','off')
text(15 , -4500, '1 s')
text(13, -3500, '1 mV')
xlim([P(1).rel2drug P(end).rel2drug ]/2)
ylim([-1 1]*10000)
set(gca,'XTick',[])

xline(0, 'color', 'magenta', 'linewidth', 3)

set(gca,'XTick',[],'YTick',[],'box','off')
color = get(gca,'Color');
set(gca,'XColor',color,'YColor',color,'TickDir','out')

saveas(gcf,[ F.figuresfolder      filesep 'Figure2B.eps'])
saveas(gcf,[ F.figuresfolder      filesep 'Figure2B.svg'])

%%  Panel D  - TF real and dcm
% load('/Volumes/Krasniy/KISPI/Output/221230 T4 G10 PEB scale Figure2/SE010_001_1_39_inverted.mat')     
Pinv = P

obs = [];
fit = []; 
Ep  = []; 

for p = 1:length(Pinv)
    obs = [obs, log(abs(Pinv(p).xY.y{1}))];
    fit = [fit, log(abs(Pinv(p).Hc{1} ))]; 
    Ep  = [Ep, full(spm_vec(Pinv(p).Ep))]; 
end
clear a b 

 
% plotting routines: observed
%--------------------------------------------------------------------------
a(1) = subplot(211);
imagesc([Pinv.rel2drug]/2, Pinv(1).xY.Hz, obs)
title('Cross spectral densitis as estimated at the source')
b(1) = colorbar(); b(1).Label.String = 'Log amplitude';
set(a(1), 'Ydir', 'normal'), ylabel('Frequency [Hz]') 
colormap(a(1), flip(cbrewer('div', 'RdGy', 500, 'linear')))

% plotting routines: fitted
%--------------------------------------------------------------------------
a(2) = subplot(212);
imagesc([Pinv.rel2drug]/2, Pinv(1).xY.Hz,fit)
title('Cross spectral densities mode fits')
b(2) = colorbar(); b(2).Label.String = 'Log amplitude';
set(a(2), 'Ydir', 'normal'), ylabel('Frequency [Hz]'), xlabel('Time window relative to drug administration [minutes]')
colormap(a(2), flip(cbrewer('div', 'RdGy', 500, 'linear')))

saveas(gcf,[ F.figuresfolder      filesep 'Figure2C1.eps'])
saveas(gcf,[ F.figuresfolder      filesep 'Figure2C1.svg'])


%% Panel E - DCM params over time in 30 s steps
subname = 'SE010'


Gs = [];
Ts = []; 

% ss = spiny stellate (e)
% sp = superficial pyramidal (i)
% dp = deep pyramidal (e)
% ii = inhibitory interneurons (i)

% G(:,1)  ss -> ss (-ve self)  4
% G(:,2)  sp -> ss (-ve rec )  4
% G(:,3)  ii -> ss (-ve rec )  4
% G(:,4)  ii -> ii (-ve self)  4
% G(:,5)  ss -> ii (+ve rec )  4
% G(:,6)  dp -> ii (+ve rec )  2
% G(:,7)  sp -> sp (-ve self)  4
% G(:,8)  ss -> sp (+ve rec )  4
% G(:,9)  ii -> dp (-ve rec )  2
% G(:,10) dp -> dp (-ve self)  1
[7 2 3 4 5 6 8 9 10 1]

Tlabels = {'T_s_s', 'T_s_p', 'T_i_i', 'T_d_p'}
Glabels = {'G_s_p', 'G_s_p_-_s_s', 'G_i_i_-_s_s', 'G_i_i', 'G_s_s_-_i_i', ...
           'G_d_p_-_i_i', 'G_s_s_-_d_p', 'G_i_i_-_d_p', 'G_d_p', 'G_s_s', }

Gmod  = [1 4 9 10];
Gexc  = [5 6 7 ];
Gihn  = [2 3 8];

for p = 1:length(P)
    Gs = [Gs, P(p).Ep.G(:)];
    Ts = [Ts, P(p).Ep.T(:)];
end

baseline = 1:abs(P(1).rel2drug);
if isempty(baseline) | length(baseline) > size(Gs,2)
    baseline = 1;
end

Gs = Gs - mean(Gs(:,baseline),2);
Ts = Ts - mean(Ts(:,baseline),2);

figure('Units','normalized','Position',[0 0.5 .5 .2],'visible','on')
 
 
axes('ColorOrder',flipud(brewermap(6,'Blues')),'NextPlot','replacechildren')
      win_time_min = max(P(1).xY.Time)/1000/60;
    plot([P.rel2drug]*win_time_min, Ts(:,:)', 'linewidth', 1.5); hold on
    xline(0),set(gca,'XTickLabel',''),set(gca,'YTick',[-1 1]),
    title(subname)
    ylim([-1.5,1])
    ylabel('T Parameter change [a.u.]')
    legend(Tlabels, 'location', 'southeast');
    ylim([-1.5,1.5])
    saveas(gcf,[ F.figuresfolder filesep 'Figure2E1.eps'])
    saveas(gcf,[ F.figuresfolder filesep 'Figure2E1.svg'])
% freezeColors

figure('Units','normalized','Position',[0 0.5 .5 .2],'visible','on')
axes('ColorOrder',flipud(brewermap(8,'Greens')),'NextPlot','replacechildren')
% colormap(gca,flipud(brewermap(6,'Blues')))

    plot([P.rel2drug]*win_time_min, Gs(Gmod,:)', 'linewidth', 1.5); hold on
    xline(0),set(gca,'XTickLabel',''),set(gca,'YTick',[-1 1]),
    ylim([-1.5,1])
    ylabel('G Modulation change [a.u.]')
    legend(Glabels(Gmod), 'location', 'southeast');
    ylim([-1.5,1.5])
    saveas(gcf,[ F.figuresfolder filesep 'Figure2E2.eps'])
    saveas(gcf,[ F.figuresfolder filesep 'Figure2E2.svg'])

figure('Units','normalized','Position',[0 0.5 .5 .2],'visible','on')
     axes('ColorOrder',flipud(brewermap(3,'Blues')),'NextPlot','replacechildren')

    plot([P.rel2drug]*win_time_min, Gs(Gexc,:)', 'linewidth', 1.5); hold on
    xline(0),set(gca,'XTickLabel',''),set(gca,'YTick',[-1 1]),
     ylim([-1.5,1.5])
    ylabel('G Excitation change [a.u.]')
     legend(Glabels(Gexc), 'location', 'southeast');
   saveas(gcf,[ F.figuresfolder filesep 'Figure2E3.eps'])
    saveas(gcf,[ F.figuresfolder filesep 'Figure2E3.svg'])

figure('Units','normalized','Position',[0 0.5 .5 .2],'visible','on')
     axes('ColorOrder',flipud(brewermap(6,'RdPu')),'NextPlot','replacechildren')

    plot([P.rel2drug]*win_time_min, Gs(Gihn,:)', 'linewidth', 1.5); hold on
    xline(0) ,set(gca,'YTick',[-1 1]),
     ylim([-1.5,1.5])
    ylabel('G Ihnibition change [a.u.]')
    xlabel(['Time relative to drug administration [min]'])
    legend(Glabels(Gihn), 'location', 'southeast');
    ylim([-1.5,1.5])
     saveas(gcf,[ F.figuresfolder filesep 'Figure2E4.eps'])
    saveas(gcf,[ F.figuresfolder filesep 'Figure2E4.svg'])

%% Panel F - PSD  on 5 minutes

DCM_pre  = load([ F.folderDCM filesep 'SE010_pre_inverted.mat'])
DCM_post = load([ F.folderDCM filesep 'SE010_pos_inverted.mat'])

obs1 =  abs(DCM_pre.DCM.xY.y{1});
fit1 =  abs(DCM_pre.DCM.Hc{1});

obs2 =  abs(DCM_post.DCM.xY.y{1});
fit2 =  abs(DCM_post.DCM.Hc{1});

freq = DCM_post.DCM.M.Hz;

figure('Units','normalized','Position',[0 0.2 .7 .7],'visible','on')

semilogy(freq,obs2 ,'linewidth',3)
hold on
semilogy(freq,obs1 ,'linewidth',3)
hold on
semilogy(freq,fit2 ,'--c','linewidth',2)
hold on
semilogy(freq,fit1 ,'--k','linewidth',2)
axis([1 45 1e-4 1e1])
hold on
legend('post medication data','pre medication data','post medication fit','pre medication fit','fontsize',16)
legend boxoff
xlabel('Frequency [Hz]')
ylabel('Power spectrum [ \muV^2/Hz ]')
set(gca,'box','off')
saveas(gcf,[ F.figuresfolder filesep 'Figure2F.eps'])
saveas(gcf,[ F.figuresfolder filesep 'Figure2F.svg'])

%% Panel G - DCM params on 5 minutes



Tlabels = {'T_s_s', 'T_s_p', 'T_i_i', 'T_d_p'}
Glabels = {'G_s_p', 'G_s_p_-_s_s', 'G_i_i_-_s_s', 'G_i_i', 'G_s_s_-_i_i', ...
           'G_d_p_-_i_i', 'G_s_s_-_d_p', 'G_i_i_-_d_p', 'G_d_p', 'G_s_s', }

ha = figure('Units','normalized','Position',[0 0.2 .7 .5],'visible','on')


Ep_pre  =   [full(DCM_pre.DCM.Ep.T)  full(DCM_pre.DCM.Ep.G)]'  ; 
Ep_post  =   [full(DCM_post.DCM.Ep.T)  full(DCM_post.DCM.Ep.G)]   ;   
Cp_pre   =  diag(full(DCM_pre.DCM.Cp)); % skip first 5 and take 14 values 
Cp_pre   =  Cp_pre([1:14]+5);
Cp_post   =  diag(full(DCM_post.DCM.Cp)); % skip first 5 and take 14 values 
Cp_post   =  Cp_post([1:14]+5);

% index of G types
Gmod  = [1 4 9 10];
Gexc  = [5 6 7 ];
Gihn  = [2 3 8];

% reorder for plotting
coef(:,1)  = Ep_pre([1:4 [Gmod Gexc  Gihn ]+4] )
coef(:,2)  = Ep_post([1:4 [Gmod Gexc  Gihn ]+4]  )
coef(:,3)  = coef(:,2) - coef(:,1);
CI(:,1)    = Cp_pre([1:4 [Gmod Gexc  Gihn ]+4] );
CI(:,2)    = Cp_post([1:4 [Gmod Gexc  Gihn ]+4] );
CI(:,3)    = (CI(:,1)+CI(:,2))/2; % average?

 ha(1) = subplot(311), 
 spm_plot_ci(coef(:,1), CI(:,1) )
 
    set(gca,'XTick',1:14,'XTickLabel',[Tlabels Glabels(Gmod) Glabels(Gexc) Glabels(Gihn)],'XTickLabelRotation',0)
     ylabel('before medication')
    set(gca,'box','off')

 ha(2) = subplot(312), 
    spm_plot_ci(coef(:,2), CI(:,2) )
    set(gca,'XTick',1:14,'XTickLabel',[Tlabels Glabels(Gmod) Glabels(Gexc) Glabels(Gihn)],'XTickLabelRotation',0)
    ylim([-1.5 1.5])
    ylabel('after medication')
    set(gca,'box','off')

 ha(3) = subplot(313), 
     spm_plot_ci(coef(:,3), CI(:,3) )
 
    set(gca,'XTick',1:14,'XTickLabel',[Tlabels Glabels(Gmod) Glabels(Gexc) Glabels(Gihn)],'XTickLabelRotation',0)
    ylim([-1.5 1.5])
        ylabel('difference')
    set(gca,'box','off')

    saveas(gcf,[ F.figuresfolder filesep 'Figure2G.eps'])
    saveas(gcf,[ F.figuresfolder filesep 'Figure2G.svg'])   
 