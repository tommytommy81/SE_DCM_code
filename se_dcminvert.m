function se_dcminvert (F)

    dcmfile        = [F.DCMbackup filesep char(F.T.Filename(F.nfile))]; % point to vLFP
    
    % to name the DCM out
    ptr2pat_id      = strfind(dcmfile,'SE0');
    pat_id          = dcmfile(ptr2pat_id:ptr2pat_id+8);
    
    load([F.folderDCM filesep 'DCM_' pat_id], 'P');
        
    % pre-condition: run it once to give a better starting point
    P.M.nograph = 1;
    pinv   = nae_spm_dcm_csd(P );
    P.M.pE = pinv.Ep;
    
    % fix scaling within patient (across pre and post)
    if ~mod(F.nfile,2) % % if it is a post: ~(mod,2) == 1
        load([F.folderDCM filesep 'PostPriors' ])
        P.xY.datascale = datascale;
        P.M.pE.L       = Lprior;
        P.M.pC.L       = 0;
    end
    
    
    %% Run actual inversion across all time windows
    %--------------------------------------------------------------------------
    clear Pinv
    P.M.nograph = 1;
    for p = 1:length(P)
        disp(['DCM number ' num2str(p)]);
        Pinv(p) = nae_spm_dcm_csd(P(p));
    end
    
    % Save actual DCM output
    %==========================================================================
    DCM = Pinv;
    
    % save scaling and forward model prior info if necessary
    if mod(F.nfile,2) % if it is a pre: (mod,2) == 1
        datascale = DCM.xY.datascale;
        Lprior    = DCM.Ep.L;
        save([F.folderDCM filesep 'PostPriors' ], 'datascale','Lprior')
    end
    
    % DCM.name = [subfiles(indx(i)).folder filesep subfiles(indx(i)).name];
    DCM.name = [F.today filesep F.folderDCM filesep pat_id '_inverted.mat']
    save([F.folderDCM filesep pat_id '_inverted.mat'], 'DCM')
 
end