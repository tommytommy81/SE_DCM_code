% spectral analysis

 

bandslabels    = {'\delta', '\theta' , '\alpha', '\beta', '\gamma'}
freq_intervals = [1 4; 4 8; 8 13; 13 25; 25  40];

%% load the raw data

filename = [F.today filesep 'LFP_seg'];
LFP      = spm_eeg_load(filename)


Fs         = 256
fft_freq   = [0.5 45]
fft_points = fft_freq *30; % Hz in fft samples

%
i = 1; % index of the dataset

% keeping track of the condition
psd.pre  = zeros(length(LFP.conditions),1);
psd.post = zeros(length(LFP.conditions),1);
psd.resp = zeros(length(LFP.conditions),1);
psd.nresp= zeros(length(LFP.conditions),1);
psd.benzo= zeros(length(LFP.conditions),1);

for elem = 1:length(LFP.conditions) % 512

    sp = find(LFP.conditions{elem}==' ');
    benzo_yn = LFP.conditions{elem}(1:sp(1)-1);
    preppost = LFP.conditions{elem}(sp(end)+1:end);
    resp_yn  = LFP.conditions{elem}(sp(1)+1:sp(2)-1);

    if strncmp(benzo_yn,'Benz',4)
        psd.benzo(i) = 1;
    else
        psd.benzo(i) = 0;
    end
    if strncmp(preppost,'pre',3)
        psd.an_prepost{i} = 'pre';
        psd.pre(i) = 1;
    else
        psd.an_prepost{i} = 'post';
        psd.post(i) = 1;
    end
    if strncmp(resp_yn ,'Resp',4)
        psd.an_resp{i} = 'resp';
        psd.resp(i) = 1;

    else
        psd.an_resp{i} = 'notresp';
        psd.nresp(i) = 1;
    end
    data = squeeze(LFP(1,:,elem));
    spectrum_loc = abs(fft(data));
    psd.spectrum(i,:) = spectrum_loc(fft_points(1):fft_points(2));
    i = i+1;

end


 

psd.frq_axis = linspace(fft_freq(1), fft_freq(2), size(psd.spectrum(1,:),2));

figure,
plot(psd.frq_axis, log(psd.spectrum))


%% RM  ANOVA 

load([F.today filesep 'LFPinfo'])  %quantisono chie
chie = chie(find(psd.benzo)); %restrict the analysis to the benzo patients
clear y_table ranovatbl

% vector of response in benzo patients
cumquantsono = cumsum(quantisono);
rm_resp      = psd.resp(cumquantsono(1:2:end));
rm_resp      = rm_resp(unique(chie)); %restrict the analysis to the benzo patients

for f = 1:length(freq_intervals)

    freq_int = freq_intervals(f,:);
    freq_int_samples = find(psd.frq_axis>freq_int(1) & psd.frq_axis<freq_int(2));

    y = mean(psd.spectrum(:,freq_int_samples),2);
    
    pos = 1;
    for i = unique(chie)
        quali = find(chie == i);
        if length(quali) == 20
            y_table (pos, :) = y(quali);
        else
            tofill = [ y(quali(1:end/2))' repmat(mean(y(quali(1:end/2))),1,2) y(quali(end/2+1:end))' repmat(mean(y(quali(end/2+1:end))),1,2)];

            y_table (pos, :) = tofill;
        end
        pos = pos+1
    end



%     
    t = table(rm_resp,...
        y_table(:,1),y_table(:,2),y_table(:,3),y_table(:,4),y_table(:,5),y_table(:,6),y_table(:,7),y_table(:,8),y_table(:,9),y_table(:,10),...
        y_table(:,11),y_table(:,12),y_table(:,13),y_table(:,14),y_table(:,15),y_table(:,16),y_table(:,17),y_table(:,18),y_table(:,19),y_table(:,20),...
    'VariableNames',{'Resp','t1','t2','t3','t4','t5','t6','t7','t8','t9','t10',...
                           't11','t12','t13','t14','t15','t16','t17','t18','t19','t20'});
    within = [zeros(1,10) ones(1,10) ]; % 0 pre, 1 post
 
    rm = fitrm(t,'t1-t20  ~ Resp','WithinDesign',within);
    
    disp(['Frequency: ' num2str(freq_int(1)) ' - ' num2str(freq_int(2)) ' [Hz]' ] )
    ranovatbl(f).tbl = ranova(rm)

    writetable(ranovatbl(f).tbl,'myData.xls','Sheet',f,'Range','A1')

end
 
%% Post hoc statistics over different frequency bands


STATsum = []

for f = 1:length(freq_intervals)

    freq_int = freq_intervals(f,:);
    freq_int_samples = find(psd.frq_axis>freq_int(1) & psd.frq_axis<freq_int(2));

    y = (mean(psd.spectrum(:,freq_int_samples),2));

     
    dat{1} = y(psd.pre & psd.resp & psd.benzo);
    dat{2} = y(psd.post & psd.resp & psd.benzo);
    dat{3} = y(psd.pre & psd.nresp & psd.benzo);
    dat{4} = y(psd.post & psd.nresp & psd.benzo);
    lab = {'resp pre', 'resp post', 'noresp pre', 'noresp post'};


    [STATS(f).posthoc(1).h,STATS(f).posthoc(1).p] = ranksum(dat{1},dat{3})
    [STATS(f).posthoc(2).h,STATS(f).posthoc(2).p] = ranksum(dat{1},dat{2})
    [STATS(f).posthoc(3).h,STATS(f).posthoc(3).p] = ranksum(dat{3},dat{4})
    STATS(f).posthoc(1).label = 'resp pre vs nresp pre';   
    STATS(f).posthoc(2).label = 'resp pre vs resp post';   
    STATS(f).posthoc(3).label = 'nresp pre vs nresp post';   

% STATsum = [STATsum  [STATS(f).posthoc(1).p, STATS(f).posthoc(2).p, STATS(f).posthoc(3).p,...
%                      STATS(f).posthoc(1).h, STATS(f).posthoc(2).h, STATS(f).posthoc(3).h]' ];
end

%% PSD spectra - average of all 30 s dataset

figure,
clear C
conds = {'resp pre', 'resp post', 'noresp pre', 'noresp post'};
C(1).all = psd.spectrum(psd.pre & psd.resp & psd.benzo,:);
C(2).all = psd.spectrum(psd.post & psd.resp & psd.benzo,:);
C(3).all = psd.spectrum(psd.pre & psd.nresp & psd.benzo,:);
C(4).all = psd.spectrum(psd.post & psd.nresp & psd.benzo,:);
C(5).all = psd.spectrum(psd.pre & psd.resp & ~psd.benzo,:);
C(6).all = psd.spectrum(psd.post & psd.resp & ~psd.benzo,:);
C(7).all = psd.spectrum(psd.pre & psd.nresp & ~psd.benzo,:);
C(8).all = psd.spectrum(psd.post & psd.nresp & ~psd.benzo,:);

% prepare data  m +- se

for c = 1:8

    C(c).mean_psd = mean(C(c).all);
    for f = 1:size(C(c).all,2)
        matr = C(c).all(:,f);
        dots = matr(:);
        sem  = std(dots) / sqrt(length(dots));
        C(c).up(f) = mean(matr,1) + 2 * sem;
        C(c).lo(f) = mean(matr,1) - 2 * sem;
    end
end

set(gcf, 'Color', 'w');
set(gcf, 'Position', [100 100, 1500 1000]);
frq_axis = psd.frq_axis;

c = [1 2 3 4];

plot(frq_axis(1),C(c(1)).mean_psd(1),'r'); hold on    % Bug req initial plot
[mc1] = plotshaded(frq_axis, [C(c(1)).up; C(c(1)).mean_psd; C(c(1)).lo], 'r');
[mp1] = plotshaded(frq_axis, [C(c(2)).up; C(c(2)).mean_psd; C(c(2)).lo], 'm');
[mc2] = plotshaded(frq_axis, [C(c(3)).up; C(c(3)).mean_psd; C(c(3)).lo], 'b');
[mp2] = plotshaded(frq_axis, [C(c(4)).up; C(c(4)).mean_psd; C(c(4)).lo], 'c');


hold on
freq_intervals = [1 4; 4 8; 8 13; 13 25; 25  40];
for f =1:5,fx  = freq_intervals(f,2), line([fx fx],[1e3 1e6],'color','black','linestyle','--'),hold on, end
% Set plotting parameters
ylim([0 max([C.mean_psd])]);
xlim([1 40]);
box off

text(2,2e3, '\delta','fontsize',18) 
text(6,2e3, '\theta','fontsize',18)
text(10,2e3, '\alpha','fontsize',18)
text(17,2e3, '\beta','fontsize',18)
text(30,2e3, '\gamma','fontsize',18)

set(gca, 'XTick', unique(freq_intervals(:)));

xlabel('Frequency [ Hz ]')
ylabel('Power spectrum [ \muV^2/Hz ]')

legend([mc1, mp1 mc2, mp2],conds,'fontsize',14)
legend boxoff 
set(gca,'YScale','log')

% line([0 45],[1.2e3 1.2e3],'color','g')
% hold on
% line([0 4],[1.3e3 1.3e3],'color','k')

text(1.5, 1.2e3,'***','color','k','fontsize',18) 
hold on
text(5, 1.2e3,'***','color','k','fontsize',18) 
hold on
text(9.5, 1.2e3,'***','color','k','fontsize',18) 
hold on
% text(16.5, 1.2e3,'***','color','k','fontsize',18) 
hold on
text(29.5, 1.2e3,'***','color','k','fontsize',18) 
hold on
text(1.5, 1.4e3,'***','color',[120 120 120]/256,'fontsize',18) 


saveas(gcf,[ F.figuresfolder filesep 'Figure1C.eps'])
saveas(gcf,[ F.figuresfolder filesep 'Figure1C.svg'])
%





