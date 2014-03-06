function [C] = coincidence_matrix(X)
levx = (unique(X(~isnan(X))));
nval = numel(x);
cm = zeros(nval);
mu = no - sum(isnan(R));

P = nchoosek(r,2);
P = [ P  ; fliplr(P) ];
P = sortrows([ [r(:) r(:)] ; P ]);
np = size(P,1);
%Coincidence values
C = repmat(R, [ 1 1 np]) == permute(repmat(P',[1 1 nm ]), [1 3 2]);
C = squeeze(sum(all(C),2))
% ... into matrix
C = reshape(C,[nr nr]);
C = C' + C;
n = 2*nm;
nc = sum(C);
dimx = size(X);

% http://pbil.univ-lyon1.fr/library/concord/R/concord
% # calculates the coincidence matrix for the kripp.alpha() function
%
% coincidence.matrix<-function(x) {
%  levx<-(levels(as.factor(x)))
%  nval<-length(levx)
%  # set up a coincidence matrix to hold the match/mismatch data
%  cm<-matrix(rep(0,nval*nval),nrow=nval)
%  dimx<-dim(x)
%  # calculate correction factor (?) for data with missing values
%  vn<-function(datavec) sum(!is.na(datavec))
%  if(any(is.na(x))) mc<-apply(x,2,vn)-1
%  else mc<-rep(1,dimx[2])
%  for(col in 1:dimx[2]) {
%   for(i1 in 1:(dimx[1]-1)) {
%    for(i2 in (i1+1):dimx[1]) {
%     if(!is.na(x[i1,col]) && !is.na(x[i2,col])) {
%      index1<-which(levx==x[i1,col])
%      index2<-which(levx==x[i2,col])
%      cm[index1,index2]<-cm[index1,index2]+(1+(index1==index2))/mc[col]
%      if(index1 != index2) cm[index2,index1]<-cm[index1,index2]
%     }
%    }
%   }
%  }
%  nmv<-sum(apply(cm,2,sum))
%  return(list(statistic=NA,coincidence.matrix=cm,data.values=levx,nmatchval=nmv))
% }
%
% # calculates Krippendorff's alpha
%
% kripp.alpha<-function(x,method="nominal") {
%  if(!missing(x)) {
%   cm<-coincidence.matrix(x)
%   dimcm<-dim(cm$coincidence.matrix)
%   # upper triangle of the coincidence matrix as a vector
%   utcm<-as.vector(cm$coincidence.matrix[upper.tri(cm$coincidence.matrix)])
%   # diagonal of the coincidence matrix
%   diagcm<-diag(cm$coincidence.matrix)
%   # sum of diagonal elements of coincidence matrix
%   occ<-sum(diagcm)
%   # the marginal sums for the coincidence matrix
%   nc<-apply(cm$coincidence.matrix,1,sum)
%   # calculate this term to simplify
%   ncnc<-sum(nc*(nc-1))
%   # need the data values for interval and ratio methods
%   dv<-as.numeric(cm$data.values)
%   diff2<-rep(0,length(utcm))
%   ncnk<-rep(0,length(utcm))
%   ck<-1
%   for(k in 2:dimcm[2]) {
%    for(c in 1:(k-1)) {
%     ncnk[ck]<-nc[c]*nc[k]
%     if(method == "nominal") diff2[ck]<-1
%     if(method == "ordinal") {
%      diff2[ck]<-nc[c]/2
%      if(k > (c+1)) {
%       for(g in (c+1):(k-1)) {
%        diff2[ck]<-diff2[ck]+nc[g]
%       }
%      }
%      diff2[ck]<-diff2[ck]+nc[k]/2
%      diff2[ck]<-diff2[ck]^2
%     }
%     if(method == "interval") diff2[ck]<-(dv[c]-dv[k])^2
%     if(method == "ratio") {
%      diff2[ck]<-(dv[c]-dv[k])^2/(dv[c]+dv[k])^2
%     }
%     ck<-ck+1
%    }
%   }
%   cm$statistic<-1-(cm$nmatchval-1)*sum(utcm*diff2)/sum(ncnk*diff2)
%   return(cm)
%  }
%  else {
%   cat("Usage: kripp.alpha(x,method=c(\"nominal\",\"ordinal\",\"interval\",\"ratio\"))\n")
%   cat("\twhere x is a classifier by object matrix of classifications\n\n")
%  }
% }
