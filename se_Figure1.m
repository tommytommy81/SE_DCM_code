
 close all

% general info

% BS_Path =  'L:\EEG-Archimedes\Data\status_epilepticus\BrainstormDB\SE\data\'
% Path    =  ['L:\EEG-Archimedes\Data\status_epilepticus\BrainstormDB\SE\data\',...
%     'SE017\SE017_130306F-B_GR-GS_edited_SE_cont_drug\']
% F.figuresfolder = 'L:\EEG-Archimedes\Projects\Status_Epilepticus\Results\Paper Figures\Figure1\' 
% channelfile = ['L:\EEG-Archimedes\Data\status_epilepticus\BrainstormDB\SE\data\',...
%     'SE017\SE017_130306F-B_GR-GS_edited_SE_cont_drug\channel.mat']

BS_Path = [F.DCMbackup filesep 'Figures' filesep 'Figure1']

data_chs = load( [BS_Path filesep 'channel.mat'] )


% filter 
[b,a ] = butter(2,[1 40]/256/2);

%% bipolar spatial filter
 
long1 = F.long1;

for bch = 1:size(long1,1)

    try
    long1_num(bch,1) = find(ismember({data_chs.Channel.Name}',long1.First(bch)));
    long1_num(bch,2) = find(ismember({data_chs.Channel.Name}',long1.Second(bch)));
    catch
        long1_num(bch,1) = NaN;
    end
end

long1(isnan(long1_num(:,1)),:) = [];
long1_num(isnan(long1_num(:,1)),:) = [];

%% Panel A -  SE types
 

% Example of focal, generalized, intermittent Status epilepticus

% Data: SE015_180719U-A_GS_edited_SE_cont_cl_drug, 1200 - 1230 s
filename_focal = 'SE015/data_block001.mat'

% Data: SE003_111207U-B_GR-GS_edited_SE_sub_cont_drug, 6405 - 6435 s
% filename_general = 'SE003/SE003_111207U-B_GR-GS_edited_SE_sub_cont_drug/data_block001.mat'
% Data:  SE021_150902U-B_GR-GS_edited_SE_sub_cont_seiz_drug, 1820 -  s
filename_general = 'SE021/data_block001_02.mat'

% Data: SE041_181006U-A_GR-GS_edited_SE_cl_int_drug, 878 - 908 s
filename_intermittent = 'SE041/data_block001.mat'

% Data: SE036/SE036_170922Q-A_GS_edited_SE_cl_int_drug/data_block001.mat, 10945 - 10975 s
filename_intermittent2 = 'SE036/data_block001.mat'

% load
data = load([BS_Path filesep filename_focal])
[data_bip,data_bip_lab] = createbipolar(data, long1_num, long1, b,a);
shift = 1000e-6
reftime = data.Time(end);
xlimits = [data.Time(1) data.Time(end)];
generate_EEG_1A(data, data_bip, data_bip_lab, shift, reftime, xlimits)

saveas(gcf,[ F.figuresfolder filesep 'Figure1 BR A1.eps'])
saveas(gcf,[ F.figuresfolder filesep 'Figure1 BR A1.svg'])

% load
data = load([BS_Path filesep filename_general])
[data_bip,data_bip_lab] = createbipolar(data, long1_num, long1, b,a);
shift = 300e-6
reftime = data.Time(end);
xlimits = [data.Time(1) data.Time(end)-5];
generate_EEG_1A(data, data_bip, data_bip_lab, shift, reftime, xlimits)
 
saveas(gcf,[ F.figuresfolder filesep 'Figure1 BR A2.eps'])
saveas(gcf,[ F.figuresfolder filesep 'Figure1 BR A2.svg'])


% load
data = load([BS_Path filesep filename_intermittent])
[data_bip,data_bip_lab] = createbipolar(data, long1_num, long1, b,a);
shift = 300e-6
reftime = data.Time(end)-10;
xlimits = [878 908];
generate_EEG_1A(data, data_bip, data_bip_lab, shift, reftime, xlimits)
 

saveas(gcf,[ F.figuresfolder filesep 'Figure1 BR A3.eps'])
saveas(gcf,[ F.figuresfolder filesep 'Figure1 BR A3.svg'])


% load
data = load([BS_Path filesep filename_intermittent2])
[data_bip,data_bip_lab] = createbipolar(data, long1_num, long1, b,a);
shift = 1000e-6
reftime = data.Time(end);
xlimits = [data.Time(1) data.Time(end)];
generate_EEG_1A(data, data_bip, data_bip_lab, shift, reftime, xlimits)

saveas(gcf,[ F.figuresfolder filesep 'Figure1 BR A4.eps'])
saveas(gcf,[ F.figuresfolder filesep 'Figure1 BR A4.svg'])

%% Panel B

close all

% Responders
filename_resp1    = [BS_Path filesep   'SE004/data_block001.mat'   ]; %Fp1F7
filename_resp2    = [BS_Path filesep   'SE010/data_block001.mat' ]; %Fp1F7
filename_resp3    = [BS_Path filesep   'SE032/data_block001.mat'    ]; %F7-T3
filename_resp4    = [BS_Path filesep   'SE031/data_block001.mat'    ]; %F7T3
filename_resp5    = [BS_Path filesep   'SE011/data_block001.mat']; %F7T3



% pat 4 - responder
data_resp1                = load( filename_resp1 );
[data_bip1, data_bip_lab] = createbipolar(data_resp1, long1_num, long1, b,a);
choi                      = find(ismember(data_bip_lab, 'F8-T4')); % channel selection
% close all,for choi= 1:14
data2plot                 = data_bip1(choi,:);
info.shift                     = 150e-6;
info.reftime                   = data_resp1.Time(end)-10;
info.xlimits                   = [data_resp1.Time(1) data_resp1.Time(end)];
info.ylimits                   = [-1 1]*2*shift;
info.druginfo                  = 'Temesta 3mg i.v.'
info.patientID                 = '1'
generate_EEG_1B(data_resp1, data2plot, data_bip_lab(choi), info) 
saveas(gcf,[ F.figuresfolder filesep 'Figure1 BR B1.eps'])
saveas(gcf,[ F.figuresfolder filesep 'Figure1 BR B1.svg'])
 
% pat 10 - responder
data_resp1                = load( filename_resp2 );
[data_bip1, data_bip_lab] = createbipolar(data_resp1, long1_num, long1, b,a);
choi                      = find(ismember(data_bip_lab, 'F3-C3')); % channel selection
data2plot                 = data_bip1(choi,:);
info.shift                     = 200e-6;
info.reftime                   = data_resp1.Time(end)-10;
info.xlimits                   = [data_resp1.Time(1) data_resp1.Time(end)];
info.ylimits                   = [-1 1]*2*shift;
info.druginfo                  = 'Diazepam rectal 10 mg'
info.patientID                 = '2'
generate_EEG_1B(data_resp1, data2plot, data_bip_lab(choi), info) 
saveas(gcf,[ F.figuresfolder filesep 'Figure1 BR B2.eps'])
saveas(gcf,[ F.figuresfolder filesep 'Figure1 BR B2.svg'])

% pat 32 - responder
data_resp1                = load( filename_resp3 );
[data_bip1, data_bip_lab] = createbipolar(data_resp1, long1_num, long1, b,a);
choi                      = find(ismember(data_bip_lab, 'F7-T3')); % channel selection
data2plot                 = data_bip1(choi,:);
info.shift                     = 200e-6;
info.reftime                   = data_resp1.Time(end)-10;
info.xlimits                   = [data_resp1.Time(1) data_resp1.Time(end)];
info.ylimits                   = [-1 1]*2*shift;
info.druginfo                  = 'Midazolam 0.1 mg/kg/h'
info.patientID                 = '7'
generate_EEG_1B(data_resp1, data2plot, data_bip_lab(choi), info) 
saveas(gcf,[ F.figuresfolder filesep 'Figure1 BR B3.eps'])
saveas(gcf,[ F.figuresfolder filesep 'Figure1 BR B3.svg'])
  
% pat 31 - responder
data_resp1                = load( filename_resp4 );
[data_bip1, data_bip_lab] = createbipolar(data_resp1, long1_num, long1, b,a);
choi                      = find(ismember(data_bip_lab, 'F7-T3')); % channel selection
data2plot                 = data_bip1(choi,:);
info.shift                     = 300e-6;
info.reftime                   = data_resp1.Time(end)-10;
info.xlimits                   = [data_resp1.Time(1) data_resp1.Time(end)];
info.ylimits                   = [-1 1]*3*shift;
info.druginfo                  = 'Keppra 500 mg';
info.patientID                 = '23'
generate_EEG_1B(data_resp1, data2plot, data_bip_lab(choi), info) 
saveas(gcf,[ F.figuresfolder filesep 'Figure1 BR B4.eps'])
saveas(gcf,[ F.figuresfolder filesep 'Figure1 BR B4.svg'])

% pat 11 - responder
data_resp1                = load( filename_resp5 );
[data_bip1, data_bip_lab] = createbipolar(data_resp1, long1_num, long1, b,a);
choi                      = find(ismember(data_bip_lab, 'C3-P3')); % channel selection
% close all
% for choi= 1:14
data2plot                 = data_bip1(choi,:);
info.shift                     = 100e-6;
info.reftime                   = data_resp1.Time(end)-10;
info.xlimits                   = [data_resp1.Time(1) data_resp1.Time(end)];
info.ylimits                   = [-1 1]*1*shift;
info.druginfo                  = 'Diazepam 5mg';
info.patientID                 = '6'
generate_EEG_1B(data_resp1, data2plot, data_bip_lab(choi), info) 
saveas(gcf,[ F.figuresfolder filesep 'Figure1 BR B5.eps'])
saveas(gcf,[ F.figuresfolder filesep 'Figure1 BR B5.svg'])
 
 
%% Panel B - examples of responders and non responders to benzodiazepines

% Non responders
filename_nonresp1 = [BS_Path filesep   'SE002/data_block001.mat']; %Fp2F8
filename_nonresp2 = [BS_Path filesep   'SE013/data_block001.mat'     ]; %C4P4
filename_nonresp3 = [BS_Path filesep   'SE022/data_block001.mat'   ]; %C3P3
filename_nonresp4 = [BS_Path filesep   'SE007/data_block001.mat'   ]; % FzCz
filename_nonresp5 = [BS_Path filesep   'SE021/data_block001.mat'   ]; % F4C4


% pat 2 - nresponder
data_resp1                = load( filename_nonresp1 );
[data_bip1, data_bip_lab] = createbipolar(data_resp1, long1_num, long1, b,a);
choi                      = find(ismember(data_bip_lab, 'Fp2-F8')); % channel selection
% close all,for choi= 1:14
data2plot                 = data_bip1(choi,:);
info.shift                     = 150e-6;
info.reftime                   = data_resp1.Time(end)-10;
info.xlimits                   = [data_resp1.Time(1) data_resp1.Time(end)];
info.ylimits                   = [-1 1]*1.5*shift;
info.druginfo                  = 'Temesta 2.5mg'
info.patientID                 = '9'
generate_EEG_1B(data_resp1, data2plot, data_bip_lab(choi), info) 
% end
saveas(gcf,[ F.figuresfolder filesep 'Figure1 BR B6.eps'])
saveas(gcf,[ F.figuresfolder filesep 'Figure1 BR B6.svg'])
 
% pat 13 - nresponder
data_resp1                = load( filename_nonresp2 );
[data_bip1, data_bip_lab] = createbipolar(data_resp1, long1_num, long1, b,a);
choi                      = find(ismember(data_bip_lab, 'C3-P3')); % channel selection
% close all,for choi= 1:14
data2plot                 = data_bip1(choi,:);
info.shift                     = 400e-6;
info.reftime                   = data_resp1.Time(end)-10;
info.xlimits                   = [data_resp1.Time(1) data_resp1.Time(end)];
info.ylimits                   = [-1 1]*4*shift;
info.druginfo                  = 'Dormicum'
info.patientID                 = '11'
generate_EEG_1B(data_resp1, data2plot, data_bip_lab(choi), info) 
% end
saveas(gcf,[ F.figuresfolder filesep 'Figure1 BR B7.eps'])
saveas(gcf,[ F.figuresfolder filesep 'Figure1 BR B7.svg'])

% pat 22 - nresponder
data_resp1                = load( filename_nonresp3 );
[data_bip1, data_bip_lab] = createbipolar(data_resp1, long1_num, long1, b,a);
choi                      = find(ismember(data_bip_lab, 'C3-P3')); % channel selection
data2plot                 = data_bip1(choi,:);
info.shift                     = 300e-6;
info.reftime                   = data_resp1.Time(end)-10;
info.xlimits                   = [data_resp1.Time(1) data_resp1.Time(end)];
info.ylimits                   = [-1 1]*3*shift;
info.druginfo                  = 'Midazolam 0.1 mg/kg/h'
info.patientID                 = '14'
generate_EEG_1B(data_resp1, data2plot, data_bip_lab(choi), info) 
saveas(gcf,[ F.figuresfolder filesep 'Figure1 BR B8.eps'])
saveas(gcf,[ F.figuresfolder filesep 'Figure1 BR B8.svg'])
  
% pat 7 - nresponder
data_resp1                = load( filename_nonresp4 );
[data_bip1, data_bip_lab] = createbipolar(data_resp1, long1_num, long1, b,a);
choi                      = find(ismember(data_bip_lab, 'Fz-Cz')); % channel selection
data2plot                 = data_bip1(choi,:);
info.shift                     = 150e-6;
info.reftime                   = data_resp1.Time(end)-10;
info.xlimits                   = [data_resp1.Time(1) data_resp1.Time(end)];
info.ylimits                   = [-1 1]*1.5*shift;
info.druginfo                  = 'Diazepam 5mg ';
info.patientID                 = '26'
generate_EEG_1B(data_resp1, data2plot, data_bip_lab(choi), info) 
saveas(gcf,[ F.figuresfolder filesep 'Figure1 BR B9.eps'])
saveas(gcf,[ F.figuresfolder filesep 'Figure1 BR B9.svg'])

% pat 21 - nresponder
data_resp1                = load( filename_nonresp5 );
[data_bip1, data_bip_lab] = createbipolar(data_resp1, long1_num, long1, b,a);
choi                      = find(ismember(data_bip_lab, 'Fp2-F4')); % channel selection
% close all
% for choi= 1:14
data2plot                 = data_bip1(choi,:);
info.shift                     = 100e-6;
info.reftime                   = data_resp1.Time(end)-10;
info.xlimits                   = [data_resp1.Time(1) data_resp1.Time(end)];
info.ylimits                   = [-1 1]*1*shift;
info.druginfo                  = 'Temesta 0.1 mg/kg';
info.patientID                 = '13'
generate_EEG_1B(data_resp1, data2plot, data_bip_lab(choi), info) 
% end
saveas(gcf,[ F.figuresfolder filesep 'Figure1 BR B10.eps'])
saveas(gcf,[ F.figuresfolder filesep 'Figure1 BR B10.svg'])

%% plot

close all

figure('Units','normalized','Position',[0 0 .8 1],'visible','on')
shift = 500e-6;
for ch = 1:size(data_bip,1)
    plot(data.Time, data_bip(ch,:)-shift*ch,'k')
    hold on
end

set(gca,'YTick',[-ch:-1 ]*shift, 'YTickLabel',flipud(data_bip_lab))

% axis
quiver( data.Time(end)-2, 0,  1, 0,'k','ShowArrowHead','off')
hold on
quiver( data.Time(end)-2, 0, 0, shift ,'k','ShowArrowHead','off')
text( data.Time(end)-1.8, -shift/6, '1 s')
text( data.Time(end)-3.1, shift/2, '500 \muV')

 set(gca,'XTick',[],'box','off')

 %%
 saveas(gcf,[ F.figuresfolder filesep 'Figure2 panel A0.eps'])
 saveas(gcf,[ F.figuresfolder filesep 'Figure2 panel A0.svg'])

 %% Panel C - PSD of benzodiazepine patients

 se_Figure1C