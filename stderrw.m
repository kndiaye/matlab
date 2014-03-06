function Y = stderrw(X,dimF,dimS)
%stderrw - Standard error for repated measure
%
%   Y=stderrw(X,dimF)
%   Y=stderrw(X,dimF,dimS)
%
%   Computes standard error (of the sample mean) in fully repeated design.
%       dimF indicates the dimension(s) of repeated factors/treatment
%       dimS indicates the observations/subjects dimension
%            (default: the first non-singleton dimension beside factors)
%
%   Example:
%   5 different measures in 2 tasks by 3 condition for 10 subjects in a
%   within subject design giving the data matrix X such as:
%       size(X)==[ 2 3 5 10 ] 
%       >> Y=stderrw(X,1:2,4);
%          Y is thus of size [2 3 5 1]

sX=size(X);
ndX=ndims(X);
if nargin<3
    sY=sX;
    sY(dimF)=0;
    dimS = min(find(sY>1));
    if isempty(dimS), error('Not enough '); end
end
sY=sX;
sY(dimS)=1;
Y=zeros(sY);
sF=sX(dimF);
NL=prod(sX(dimF));
NS=sX(dimS);
NX=[sX(setdiff(1:ndX,[dimS dimF])) 1];

% for each subject center X and compute stderr
pX=[dimF dimS setdiff(1:ndX,[dimS dimF])];
X=permute(X,pX);
X=reshape(X,[NL,NS,NX]);
X=X-repmat(mean(X,1),[NL 1]);
Y=stderr(X,2);
Y=reshape(Y,[sX(dimF),1,NX]); 
Y=ipermute(Y,pX);
return


