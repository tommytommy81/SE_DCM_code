function se_build_FCM(F)


subfiles = dir([F.folderDCM filesep '*inverted.mat'])

% reorder to match the design matrix
N        = length(subfiles);
indx     = reshape([2:2:N; 1:2:N],[],1);

% extract filenames 
for i = 1:length(indx)
    dcmfiles{i,1} = [subfiles(indx(i)).folder filesep subfiles(indx(i)).name];
end

% stack files together
FCM      = spm_dcm_load(dcmfiles);

save([F.today filesep F.FCMfilename '.mat'],'FCM')