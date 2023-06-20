close all

 
if precomput
    se_Figure4_precompute % it precomputes Figure4.mat
else
    load([F.today filesep 'Figure4'], 'simulations', 'options');
end

colormap hot
cols   = 'rmbc'
sqtype = 'YlOrRd';%YlGnBu

gris   = (uint8(255*cbrewer('seq', sqtype, size(simulations(1).sim20,2))));

options.label1      = 'benzodiazepine effect';
options.label2      = 'response x benzodiazepine effect';


legendrealdata = {  'Responder before drug'
    'Responder after drug'
    'Non Responder before drug'
    'Non Responder after drug'}'



figure('Units','normalized','Position',[0 0 1 .75],'visible','on')

subplot(231)
imagesc(flipud(simulations(2).sim20))
ylabel(options.label1)
xlabel(options.label2)
set(gca,'XTick',[],'YTick',[],'box','off')
colormap hot
clim([ -8 -2])
colorbar

subplot(234)
imagesc(flipud(simulations(1).sim20))
ylabel(options.label1)
xlabel(options.label2)
set(gca,'XTick',[],'YTick',[],'box','off')
colormap hot
clim([ -8 -2])
colorbar


subplot(232)
plot(simulations(2).ICMPsd(:,3) ,'color',[.95 .63 .1],'LineWidth',3)
hold on
plot(simulations(2).ICMPsd(:,4) ,'color',[.0 .45 .74],'LineWidth',3)
hold on


for e = 1:10:length(simulations(1).sim20)
    if options.diagonal == 1
        plot(simulations(2).sims{e,e}  ,'color',gris(e,:))
    else
        plot(simulations(2).sims{e,length(ax1)-e+1}  ,'color',gris(e,:))
    end
    hold on
end
plot(simulations(2).ICMPsd(:,3) ,'color',[.95 .63 .1],'LineWidth',5)
hold on
plot(simulations(2).ICMPsd(:,4) ,'color',[.0 .45 .74],'LineWidth',5)
hold on
ylabel('log Power [dB]')
xlabel('Frequency [Hz]')
legend(legendrealdata(3:4))
legend boxoff
set(gca,'XTick',[10 20 30 40],'YTick',[-8 -4 0] ,'box','off')

axis([1 45 -10 2])


subplot(235)



plot(simulations(1).ICMPsd(:,1) ,'color',[.95 .63 .1],'LineWidth',5)
hold on
plot(simulations(1).ICMPsd(:,2) ,'color',[.0 .45 .74],'LineWidth',5)
hold on
for e = 1:10:length(simulations(1).sim20)
    if options.diagonal == 1
        plot(simulations(1).sims{e,e}  ,'color',gris(e,:))
    else
        plot(simulations(1).sims{e,length(ax1)-e+1}  ,'color',gris(e,:))
    end
    hold on
end
plot(simulations(1).ICMPsd(:,1) ,'color',[.95 .63 .1],'LineWidth',5)
hold on
plot(simulations(1).ICMPsd(:,2) ,'color',[.0 .45 .74],'LineWidth',5)
hold on
ylabel('log Power [dB]')
xlabel('Frequency [Hz]')
set(gca,'XTick',[10 20 30 40],'YTick',[-8 -4 0] ,'box','off')
legend(legendrealdata(1:2))
legend boxoff
axis([1 45 -10 2])



%% LFP traces

% load all first level DCM
load([F.today  filesep 'FCM.mat'])
% load([ 'FCM_230309_scale1_L1_adaptedprior.mat'])

% select representative examples
vLFP = [7 8 43 44] % visually inspected - SE004 and SE037 - pt 1 an 17 in Table 1


for p = 1:length(vLFP)

    patname         = FCM{vLFP(p), 1}.name(strfind(FCM{vLFP(p), 1}.name,'SE0') :  strfind(FCM{vLFP(p), 1}.name,'_inverted')-1)
    if strcmp(patname(end-2:end),'pos'), patname = [patname 't']; end
    DCM.xY.Dfile    = [F.DCMbackup filesep 'MMEEG-full_' patname '.mat']
    LFP             = spm_eeg_load(DCM.xY.Dfile);
    vLFPexample(p,:) = LFP(:);
end

Fs       = 256;
interval = 15*Fs:30*Fs;
xshift   = 1*Fs;

time1    = 1:length(interval);
time2    = xshift+(length(interval):2*length(interval)-1);

subplot(2,3,3)
cla
plot(time1,  vLFPexample(3,interval) , 'color',[.95 .63 .1] )
hold on
plot(time2,  vLFPexample(4,interval) ,'color',[.0 .45 .74])
ylim([-3000 4000])
box off
set(gca,'XTick',[],'YTick',[],'box','off')

axes('Position',[.85 .87 .05 .05])
cla

plot(log(abs(FCM{vLFP(3),1}.xY.y{1, 1}  )) , 'color',[.95 .63 .1])
hold on
plot(log(abs(FCM{vLFP(4),1}.xY.y{1, 1}  )),'color',[.0 .45 .74])
ylabel('log Power [dB]')
xlabel('Frequency [Hz]')
ylim([-12 2])
box off

subplot(2,3,6)
interval = 92*Fs:107*Fs;
time1    = 1:length(interval);
time2    = xshift+(length(interval):2*length(interval)-1);
cla
plot(time1,  vLFPexample(1,interval) , 'color',[.95 .63 .1] )
hold on
plot(time2,  vLFPexample(2,interval) ,'color',[.0 .45 .74])
box off
ylim([-3000 3000])

quiver( 7000, -2000, 2*256, 0,'k','ShowArrowHead','off')
hold on
quiver( 7000, -2000, 0, 500 ,'k','ShowArrowHead','off')
text( 7100, -2200, '2 s')
text( 6000, -1700,   '500 \muV' )
set(gca,'XTick',[],'YTick',[],'box','off')

axes('Position',[.85 .4 .05 .05])
cla

plot(log(abs(FCM{vLFP(1),1}.xY.y{1, 1}  )), 'color',[.95 .63 .1])
hold on
plot(log(abs(FCM{vLFP(2),1}.xY.y{1, 1}  )),'color',[.0 .45 .74])
ylabel('log Power [dB]')
xlabel('Frequency [Hz]')
ylim([-12 2])
box off




%% save



saveas(gcf,[ F.figuresfolder filesep 'Figure 4.eps'])
saveas(gcf,[ F.figuresfolder filesep 'Figure 4.svg'])



 

%% Explore initial conditions
% close all

I = load([F.today  filesep 'ICMsummary.mat'])

figure
for iter = 1:2 % iter = 1, responders; iter = 2, non responders

    switch iter
        case 1 , target_case = {'Benz Resp pre'};
        case 2 , target_case = {'Benz NonResp pre'};
    end

    % search in the average model of each condition to extract the starting
    % point
    for i = 1:length(I.ICM)
        ecco(i) = ismember(target_case,I.ICM(i).xY.code{1, 1}  );
    end
    base_id = find(ecco)

    base      = I.ICM(base_id);
    subplot(2,1,iter)
    barplot_paramsCI(base )
    title(target_case)
    hold on

end