function [y] = nae_spm_fs_csd(y,M)
% spectral feature selection for a CSD DCM
% FORMAT [y] = spm_fs_csd(y,M)
% y      - CSD
% M      - model structure
%__________________________________________________________________________
%
% David O, Friston KJ (2003) A neural mass model for MEG/EEG: coupling and
% neuronal dynamics. NeuroImage 20: 1743-1755
%__________________________________________________________________________
% Copyright (C) 2008 Wellcome Trust Centre for Neuroimaging
 
% Karl Friston
% $Id: spm_fs_csd.m 7002 2017-02-02 18:22:04Z karl $

% control the relative precision of (second-order) data features
%--------------------------------------------------------------------------
beta = [1 1/8 8];

% return (scaled) cross-spectra, covariance functions MAR coefficients
%--------------------------------------------------------------------------
for i = 1:length(y);
    csd  = y{i};
    ccf  = spm_csd2ccf(csd,M.Hz);
    mar  = spm_ccf2mar(ccf,32);
    for p = 1:mar.p
        arc(p,:,:) = mar.lag(p).a;
    end
    y{i} = [log(csd)*beta(1); ccf(1:8:end,:,:)*beta(2); arc*beta(3)];
%     y{i} = [csd*beta(1); ccf(1:8:end,:,:)*beta(2); arc*beta(3)];
end
