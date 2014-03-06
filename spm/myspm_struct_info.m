% Short Explanation of the Fields of SPM struct
% =============================================
% SPM.xY Data
% ---------------------------------------------------------------------
% xY.P filenames of images (with path)
% xY.VY handle to images (from spm_vol)
% VY.fname filename
% VY.dim image dimensions
% VY.mat transformation matrix
% VY.pinfo plane info (scale factor for every image)
% VY.descrip description string
% VY.n ?
% VY.private.hdr analyze header
% VY.userdata user data (usually not used)
% SPM.xX Design Matrix
% ---------------------------------------------------------------------
% xX.X Design Matrix (raw values)
% xX.iH column indices for condition effects partition
% xX.iC column indices for covariates of interest partition
% xX.iB column indices for constants
% xX.iG colunn indices for nuisances covariates partition
% xX.name regressor names (cell array)
% xX.I indicator for factor levels
% xX.sF factor names
% xX.K filter for design matrix
% xX.W pre-whitening matrix (WY = WX*b + We)
% xX.xKXs struct for filtered and pre-whitened design matrix (K*W*X)
% xKXs.X the filtered and whitened design matrix
% xKXs.tol tolerance [max(size(xKXs.X))*max(abs(xKXs.ds))*eps]
% xKXs.ds vector of singular values [diag(s) from [u,s,v]=svd(xKXs.X,0)]
% xKXs.u u as in X = u*diag(ds)*v' [taken from [u,s,v]=svd(xKXs.X,0)]
% xKXs.v v as in X = u*diag(ds)*v' [taken from [u,s,v]=svd(xKXs.X,0)]
% xKXS.rk rank = sum(xKXs.ds > xKXs.tol)
% xKXs.oP orthogonal projector on X
% xKXs.oPp orthogonal projector on X'
% xKXs.ups space in which this one is embedded
% xKXs.sus subspace
% xX.pKX pseudo-inverse of filtered and pre-whitened design
% matrix
% xX.Bcov covariance matrix of parameter estimates
% [diag(Bcov) = variance of parameter estimates]
% xX.V filtered and pre-whitened error covariance matrix
% (K*W*xVi.Vi*W'*K')
% xX.trRV trace of R*V (necessary for effective df)
% xX.trRVRV trace of RVRV (necessary of effective df)
% xX.erdf effective residual df (trRV^2/trRVRV)
% xX.nKX filtered design matrix scaled for display
% SPM.xC Covariate details
% ---------------------------------------------------------------------
% xC.rc raw (as entered) i-th covariate
% xC.rcname name of this covariate
% xC.c covariate as appears in design matrix
% xC.cname cellstr containing names corresponding to xC(i).c
% xC.iCC covariate contering option
% xC.iCFT covariate by factor interaction option
% xC.type covariate type (1=interest,2=nuisance,3=global)
% xC.cols columns of design matrix corresponding to xC(i).c
% xC.descrip description of covariate
% SPM.xGX Global options and values
% ---------------------------------------------------------------------
% xGX.iGXcalc global calculation option used
% xGX.sGCcalc string describing global calculations used
% xGX.rg raw globals (before scaling)
% [mean image intensity, not session-specific]
% xGX.gSF global scaling factor (applied to xGX.rg)
% [global mean, session-specific]
% xGX.GM global mean (gSF*rg = GM)
% xGX.iGMsca grand mean scaling option
% xGX.sGMsca string describing grand mean (/proportional)
% scaling option
% xGX.iGC global covariate centering option
% xGX.sGC string describing global covariate centering option
% xGX.gc center for global covariate
% xGX.iGloNorm global normalization option
% xGX.sGloNorm string describing global normalization option
% SPM.xVi Non-spericity options
% ---------------------------------------------------------------------
% xVi.iid independent and identical errors (0/1)
% xVi.I see SPM.xX.I
% xVi.sF see SPM.xX.sF
% xVi.var factor to correct for inhomogenous variance (?)
% xVi.dep factor to correct of non-identical errors (?)
% xVi.Vi cell array with model components for error GLM
% (design matrices for error)
% xVi.h hyperparameter estimates for xVi.Vi
% (usually called lambda's)
% xVi.Cy spatially whitened covariance matrix of data (Y*Y')
% [used by ReML to estimate h)]
% xVi.CY fitted covariance matrix of data (Y-<Y>)*(Y-<Y>')
% [used by spm_Bayes]
% SPM.xM Masking options
% ---------------------------------------------------------------------
% xM.T threshold masking values (-Inf = 'none')
% xM.TH nScan x 1 vector of analysis thresholds
% xM.I implicit masking (0 = 'none'; 1 = zero/NaN)
% xM.VM handle to explicit masking image (see SPM.xY.VY)
% xM.xs struture describing masking options
% SPM.xVol information about image dimensions etc.
% ---------------------------------------------------------------------
% xVol.M transformation matrix vox2mm
% xVol.iM transformation matrix mm2vox
% xVol.DIM images dimensions
% xVol.FWHM smoothing filter width (in voxels)
% xVol.R vector of resel counts (in resels)
% xVol.S Lebelgue measure of volume (in voxels)
% xVol.VRpv handle to Resels/voxel images (RPV.img)
% (see SPM.xY.VY)
% SPM.Vbeta parameter estimates
% ---------------------------------------------------------------------
% handle to beta images (see SPM.xY.VY)
% SPM.VResMS residual sum of squares
% ---------------------------------------------------------------------
% handle to images of residuals (ResMS.img)
% SPM.VM mask image
% ---------------------------------------------------------------------
% handle to mask images of analysis voxels
% (mask.img)
% SPM.xCon structure holding contrast information
% ---------------------------------------------------------------------
% xCon.name contrast name
% xCon.STAT type of statistic (T/F)
% xCon.c contrast vector/matrix
% xCon.X0 reduced design matrix (spans design space under Ho)
% xCon.iX0 indicates how contrast was specified
% if by "columns for reduces design" then column
% indices, otherwise either 'c', 'c+', or 'X0'
% see spm_FcUtil
% xCon.X1o remaining design space (orthogonal to X0)
% xCon.eidf effective interest df (numerator df)
% xCon.Vcon handle to contrast image
% (con_xxxx.img,ess_xxxx.img)
% xCon.Vspm handle to statistical image
% (spmT_xxxx.img/spmF_xxxx.img)
% SPM.Sess regressors in design matrix (session-specific)
% ---------------------------------------------------------------------
% Sess.U experimental regressors
% U.name name of regressors
% U.ons onset vector
% U.dur duration (0 = events)
% U.P parametric modulations
% P.name name of parametric modulator
% P.h order of expansion
% P.i
% U.dt internal temporal resolution RT/T
% U.pst peri-stimulus time (specifies occurence of
% scans in relation to events)
% C covariates
% C.C nScan x number of covariates matrix
% C.name cell array with names of covariates
% row indices of rows of design matrix belonging to
% the session
% col indices of columns of design matrix belongin to
% the session
% Fc structrue holding information on F-contrasts
% Fc.i index of F-contrast (?)
% FC.name name of F-contrast
% SPM.xBF structure with information if basis functions
% ---------------------------------------------------------------------
% xBF.name name of basis function of set of bassi functions
% xBF.T time bins
% xBF.T0 reference bin
% xBF.UNITS onsets in scans or seconds
% xBF.Volterra (1 = linear, normal HRF, 2 = trial interactions)
% xBF.dt internal temporal resolution (RT/T)
% xBF.length length of basis functions (in sec)
% xBF.order ? (1 = HRD no order)
% xBF.bf vector with basis functions
% SPM.xsDes structure describing design
% SPM.SPMid version information of SPM
% SPM.swd analysis directory (holding SPM.mat)
% SPM.nscan number of images
help(mfilename)