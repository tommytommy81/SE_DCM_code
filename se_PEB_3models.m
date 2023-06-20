function se_PEB_3models(F)

% creates the PEB model once are assigned

% FCM: first level DCM
% M.X: Design Matrix

%%
close all

%% load the first level inverted DCMs
load ([F.today filesep F.FCMfilename],'FCM');
model_name = F.model_name;

allparamcomb = 1 % set to 1 to verify the Free Energy associated
                 % with combinations of T, Gmod, Gexc, Ginh 
saveit       = 1;% flag to save PEB results

% Design matrix and labels
% we consider the design including the 2nd Line treatment as random noise
% and includes also interactin terms Treatment x Response
col_m{1}   = [1 2];            % Response
col_m{2}   = [1 2 3   11   ];  % Treatment 
col_m{3}   = [1 2 3 7 11 12 ]; % Treatment x Response

%% CMC 
% 
% coupling parameters
%--------------------------------------------------------------------------
% G(:,1)  ss -> ss (-ve self)  4    MOD
% G(:,2)  sp -> ss (-ve rec )  4    INH
% G(:,3)  ii -> ss (-ve rec )  4    INH
% G(:,4)  ii -> ii (-ve self)  4    MOD
% G(:,5)  ss -> ii (+ve rec )  4    EXC
% G(:,6)  dp -> ii (+ve rec )  2    EXC
% G(:,7)  sp -> sp (-ve self)  4    MOD
% G(:,8)  ss -> sp (+ve rec )  4    EXC
% G(:,9)  ii -> dp (-ve rec )  2    INH
% G(:,10) dp -> dp (-ve self)  1    MOD
%
% G Parameters: The order in the DCM structure is as follows
% j     = [7 2 3 4 5 6 8 9 10 1];
% i.e.     M I I M E E E I M  M
% new   =  1 2 3 4 5 6 7 8 9 10
%
% T Parameters: The order is as follows
% ss sp ii dp
%  1  2  3  4
%  E  I  E  I

% Model space by parameter type nae_spm_fx_cmc
%--------------------------------------------------------------------------
clear fields  labels
fields{1}   = {'T(1)', 'T(2)', 'T(3)', 'T(4)'};     % time constants
fields{2}   = {'G(2)', 'G(3)', 'G(8)'};             % inh connections
fields{3}   = {'G(5)', 'G(6)', 'G(7)'};             % exc connections
fields{4}   = {'G(1)', 'G(4)', 'G(9)', 'G(10)'};    % mod connections

labels  = { 't ', 'g_i ', 'g_e ', 'g_m '  };

% all possible combinations of parameters
if allparamcomb
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
end
 
%% PEB computation
%-------------------------------------------------------------------------

for m = 1:3 % three hypothesized scenarios 
    
    % name for saving .mat and figures
    model_name_scenario = [model_name '_scenario' num2str(m)];
    
    % design matrix
    X           = table2array(F.Xfull(:,col_m{m}  ));
    Xnames      = F.Xnames_full(col_m{m}  );
    M.X         = X;
    M.Xnames    = Xnames;
    M.Q         = 'all';
    M.noplot    = 1;

    clear PEB RCM P

    for f = 1:length(fields)
        f
        [PEB, RCM]   = spm_dcm_peb(FCM, M, fields{f});
        FE(f,m)       = PEB.F;
        P(1,f).PEB    = PEB;
        P(1,f).fields = fields{f};
        P(1,f).F      = PEB.F;
        P(1,f).RCM    = RCM;
    end

    if saveit, save([F.today filesep 'PEB_' model_name_scenario ], 'P'); end

    %% Identify overall winning PEB model
    %==========================================================================
    if saveit, load([F.today  filesep 'PEB_' model_name_scenario]); end

    clear Fs Fall
    for p = 1:size(P,1)
        for q = 1:size(P,2)
            Fs(p,q) = P(p,q).F;
        end
    end
    Fall    =  (Fs);


    % Plot free energies and model posteriors spm_dcm_bmc
    %--------------------------------------------------------------------------
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

    set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
    saveas(gcf,[F.today  filesep  'PEB models report ' model_name_scenario '.png'])

    %% the winner is...

    [v l] = max(Fall);


    %% Bayesian model reduction over winning PEB  
    %--------------------------------------------------------------------------
    load([F.today  filesep 'PEB_' model_name_scenario])

    PMA        = spm_dcm_peb_bmc(P(1,l).PEB); 
    FEB.PMA    = PMA;
    FEB.RCM    = P(1,l).RCM;
    FEB.PEB    = P(1,l).PEB; 

    save([F.today  filesep  'Full Empirical Bayes ' model_name_scenario], 'FEB');

     

    %% figure FEB

    PEB = FEB.PEB;
    PMA = FEB.PMA;
    
    makefigure_PEBparams(PEB, PMA)

    set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);

    saveas(gcf,[F.today  filesep  'Full Empirical Bayes ' model_name_scenario '.png'])

end

