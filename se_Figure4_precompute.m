
clear all
close all
clc


F = se_housekeeping('TF');        % Initial housekeeping
N = size(F.T,1);

% data

load ([F.today filesep F.FCMfilename],'FCM');

model_name = '2306';
m          = 3;
model_name_scenario = [model_name '_scenario' num2str(m)]; 
load([F.today  filesep  'Full Empirical Bayes ' model_name_scenario ])


I = load([F.today  filesep 'ICMsummary.mat'])
% computed in merge_MMEEG2.m

% % LFP spectra for reference
% %             'Benz Resp pre'                'Benz Resp post'             'Benz NoResp pre'             'Benz NoResp post'
% ICMPsd   = [log(abs(I.ICM(8).xY.y{1, 1})) log(abs(I.ICM(7).xY.y{1, 1})) log(abs(I.ICM(6).xY.y{1, 1})) log(abs(I.ICM(5).xY.y{1, 1}))];

clear ICMPsd legendrealdata
j = 1
for c = 6:-1:3
ICMPsd(:,j) = log(abs(I.ICM(c).xY.y{1, 1})); 
legendrealdata{j} = I.ICM(c).xY.code{1, 1}
j = j+1;
end
 

%% setting for simulations
ax_start = 0
ax_step  = .01
ax_end   = 2.5

var_resp     = FEB.PMA.Ep(4:6);    % resp
var_benz     = FEB.PMA.Ep(7:9);    % benz
var_respbenz = FEB.PMA.Ep(10:12); % resp x benz

ax_resp      = ax_start:ax_step:ax_end;
ax_benz      = ax_start:ax_step:ax_end;
ax_respbenz  = ax_start:ax_step:ax_end ;%[0 1.5:.05:2];


%%
close all


for iter = 1:2 % iter = 1, responders; iter = 2, non responders

    switch iter 
        case 1 , target_case = {'Benz Resp pre'};
        case 2 , target_case = {'Benz NonResp pre'};
        %case 3 , target_case = {'Benz Resp post'};
    end

    % search in the average model of each condition to extract the starting
    % point
    for i = 1:length(I.ICM)
        ecco(i) = ismember(target_case,I.ICM(i).xY.code{1, 1}  );
    end
    base_id = find(ecco)

    Base      = I.ICM(base_id);
    % generate a spectra for the starting point
    Base.xY.y = spm_csd_mtf(Base.Ep, Base.M, Base.xU);

    % figure, plot(log(abs(Base.xY.y{1})))

    % Base Ep values
    flag_ICM = 1 % to substract the LFP spectra from simulated spectra
    basepars = (Base.Ep); % resp pre/ non resp pre
    ref_psd  = log(abs(Base.xY.y{1, 1}));


    %% benz and respbenz

    flag_ICM = 0
    basepars = I.ICM(base_id).Ep; % DCM params -  resp pre/ non resp pre

    % simulate PSD
    clear sims sim20
    for i = 1:length(ax_resp)
        for e = 1:length(ax_respbenz)
            [i e]
            simpars  = basepars; % initial condition
            % spanning over paramaters space
            simpars.G([2 3 8]) = simpars.G([2 3 8]) + ax_benz(e) * var_benz' + ax_respbenz(i) * var_respbenz';
            % generate a simulated PSD
            y                  = spm_csd_mtf(simpars, Base.M, Base.xU);
            % save the psd for plot
            sims{e,i}          = log(abs(y{1}));
            % keep one value for sensitivity maps - 20 Hz is representative
            sim20(e,i)         = log(abs(y{1}(20)));
        end
    end

    %% plotting cosmetics
    options.axislabels  = {'benz','respbenz'}
    options.label1      = 'benz';
    options.label2      = 'respbenz';
    options.ref_psd     = ref_psd % not used 
    options.ref_psd     = 0;
    options.ICMPsd      = ICMPsd; % LFP spectra
    options.diagonal    = 1; % take the spectra along the diagonal of sims
    options.flag_ICM    = 1; % not used 
    options.legendrealdata = legendrealdata;
    options.figurename  = ['simulation start' target_case{1} ' ']; % figurename
    options.F           = F; % directiories info
    plot_sims2final(sim20, sims, options)

    simulations(iter).sims = sims;
    simulations(iter).sim20 = sim20;
    simulations(iter).ICMPsd = ICMPsd;
    simulations(iter).basepars = basepars;




end
save([F.today filesep 'Figure4'], 'simulations', 'options');

%%

