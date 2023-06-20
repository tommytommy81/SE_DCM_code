
 

load ([F.today filesep F.FCMfilename],'FCM');

for m = 1:3

    
    model_name_scenario = [F.model_name '_scenario' num2str(m)];
    
    load([F.today filesep  'Full Empirical Bayes ' model_name_scenario ])
    
    FE(m) = FEB.PEB.F;

end




     

%% figure FEB

 PEB = FEB.PEB;
PMA = FEB.PMA;
cols = 4
Figwidth = 3
% makefigure_PEBparams_Fig5
makefigure_PEBparams_Fig3_CI   
saveas(gcf,[ F.figuresfolder filesep 'Figure3_scenario3.eps'])
saveas(gcf,[ F.figuresfolder filesep 'Figure3_scenario3.svg'])

%% FE
 
close all
vector  = FE( [1 2 3])-min(FE( [1 2 3]))+.1

% vector = reshape([vector; zeros(2,3)],[],1);

figure('Units','normalized','Position',[0 0.2 1 .5],'visible','on')
bar( vector)
set(gca,'XTick',[1 2 3],'XTickLabel',{'Hypothesis 1', 'Hypothesis 2',...
                                 'Hypothesis 3'},'fontsize',16)
line([2.4 2.73],[1 1]*vector(2),'linestyle','--')
line([2.4 2.73],[1 1]*vector(3),'linestyle','--')

axis([.5 3.5 0 20])

% [nx1, ny1] = normalize_coordinate(2.5, vector(2), get(gca, 'Position'), get(gca, 'xlim'), get(gca, 'ylim'), 0, 0)
% [nx2, ny2] = normalize_coordinate(2.5, vector(3), get(gca, 'Position'), get(gca, 'xlim'), get(gca, 'ylim'), 0, 0)
% 
% annotation('doublearrow', [nx1 nx2],[ny1 ny2])
ylabel ('Relative Free Energy','fontsize',16)  
 set(gca,'box','off', 'YTick',[])
saveas(gcf,[ F.figuresfolder filesep 'Figure3_FE.eps'])
saveas(gcf,[ F.figuresfolder filesep 'Figure3_FE.svg'])

 
%% PEB FE for scenario 3

 load([F.today  filesep 'PEB_' model_name_scenario]);  

 clear fields  labels
fields{1}   = {'T(1)', 'T(2)', 'T(3)', 'T(4)'};     % time constants
fields{2}   = {'G(2)', 'G(3)', 'G(8)'};             % inh connections
fields{3}   = {'G(5)', 'G(6)', 'G(7)'};             % exc connections
fields{4}   = {'G(1)', 'G(4)', 'G(9)', 'G(10)'};    % mod connections

labels  = { 't ', 'g_i ', 'g_e ', 'g_m '  };

% all possible combinations of parameters - just for the labels
     combs3 = nchoosek( 1:4 , 3 );
    combs2 = nchoosek( 1:4 , 2 );

    fieldscounter = length(fields);
    for c = 1:size(combs2,1),
        fields{fieldscounter+c} = [fields{combs2(c,:)}];
        labels{fieldscounter+c} = [labels{combs2(c,:)}]
    end
    fieldscounter = length(fields);
    for c = 1:size(combs3,1),
        fields{fieldscounter+c} = [fields{combs3(c,:)}];
        labels{fieldscounter+c} = [labels{combs3(c,:)}]
    end
    fieldscounter = length(fields);
    fields{fieldscounter+1}   = {'T(1)', 'T(2)', 'T(3)', 'T(4)',...
        'G(2)', 'G(3)', 'G(8)', 'G(1)', 'G(5)', 'G(6)', 'G(7)',...
        'G(4)', 'G(9)', 'G(10)'};
    labels{fieldscounter+1} = 'all';
 

    clear Fs Fall
    for p = 1:size(P,1)
        for q = 1:size(P,2)
            Fs(p,q) = P(p,q).F;
        end
    end
    Fall    =  (Fs);

 figure,
    subplot(2,1,1), bar(Fall - min(Fall));
    ylabel({'Relative Free Energy'})
    set(gca, 'XTick', 1:length(Fall), 'XTickLabel', labels,'FontSize',16);

    % subplot(3,1,2), plot(Fs' - min(Fs'));
    subplot(2,1,2),
    [alpha, exp_r, xp] = spm_BMS(Fs, 1e6, 1, 0, 1);
    bar(xp); title('RFX Analysis');
    ylabel({'exceedance probability'})
    set(gca, 'XTick', 1:length(Fall), 'XTickLabel', labels,'FontSize',16);
