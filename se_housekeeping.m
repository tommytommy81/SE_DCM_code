function F = se_housekeeping(initials)


if strcmp(initials, 'TF')

    % project organization
    F.project         = '/Users/administrator/KISPI/SE';  % main directory

end

if strcmp(initials, 'Krasniy')

    % project organization
    F.project         = ['D:' filesep 'KISPI' filesep 'SE'];  % main directory

end

if strcmp(initials, 'KISPI')

    % project organization
    F.project         = 'L:\EEG-Archimedes\Projects\Status_Epilepticus';  % main directory

end


    F.data            = [F.project filesep 'EEG' ];       % annotated EEG
    F.spm             = [F.project filesep 'spm12'];      % SPM library  
    F.ica             = [F.project filesep 'ICA'];        % ICA outcome
    F.code            = [F.project filesep 'code'];       % matlab scripts
    F.outp            = [F.project filesep 'Output'];     % results
    F.DCMbackup       = [F.outp filesep 'DATA back up'];  % files .mat 
    F.sources_backup  = [F.outp filesep 'sources_backup'];% vLFP coordinates .mat
    F.figuresfolder   = [F.outp filesep 'Figures'];
    F.figuresdata     = [F.DCMbackup filesep 'Figures']; 

    mkdir(F.figuresfolder)

    % data info
    F.SE_info          = [F.project filesep 'SE_info.xlsx']; % general data info .xlsx
    F.sheetDCM         = 'DCM segments';                     % for DCM
    F.sheetEEGpreproc  = 'EEG preprocessing';                % for extracting intervals and vLFP from annotated EEG
    F.sheetDesign      = 'DesignMatrix'                      % PEB Design Matrix
    
    % patients table
    F.T                = readtable(F.SE_info,'Sheet',F.sheetEEGpreproc);
    F.Xfull            = readtable(F.SE_info,'Sheet',F.sheetDesign,'Range','C6:N58');
    F.long1            = readtable(F.SE_info,'Sheet','EEG layout');
    F.Xnames_full      = F.Xfull.Properties.VariableNames; 

    % manage results
    F.today            = [F.outp filesep 'matfiles'];
    folderDCM          = 'DCM';
    F.FCMfilename      = 'FCM';
    F.folderDCM        = [F.today filesep folderDCM  ];
    mkdir(F.today )
    mkdir(F.folderDCM )
    F.model_name       = '2306'; % model date, just to keep track
 
 

% addpath(genpath(F.RRlibrary)) %nae_xxx
addpath(F.spm)
spm('defaults', 'eeg')

addpath(genpath([F.project filesep 'code' filesep 'Tools']))

cd([F.project filesep 'code'])

% to solve issue with spm on mac
% system('sudo xattr -r -d com.apple.quarantine ''/Users/administrator/Matlab Toolbox/spm12''')
% system('sudo find ''/Users/administrator/Matlab Toolbox/spm12'' -name \*.mexmaci64 -exec spctl --add {} \;')


F.montage.RoL = {'Fp2', 'F8', 'T4', 'T6', ...
                 'F4', 'C4', 'P4', 'O2', ...
                 'Fz', 'Cz', 'Pz', ...
                 'Fp1', 'F7', 'T3', 'T5', ...
                 'F3', 'C3', 'P3', 'O1'}; 


F.montage.LoR = {'Fp1', 'F7', 'T3', 'T5', ...
                 'F3', 'C3', 'P3', 'O1', ...
                 'Fz', 'Cz', 'Pz', ...
                 'Fp2', 'F8', 'T4', 'T6', ...
                 'F4', 'C4', 'P4', 'O2'}; 


 
 



 
