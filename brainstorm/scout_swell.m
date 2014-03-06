function newverts = scout_swell(iverts,vconn,depth);
%scout_swell - find neighboring vertices of a scout/patch
%   [newverts]=scout_swell(iverts,vconn)
%   [newverts]=scout_swell(iverts,vconn,depth)

if nargin<3
    depth=1;
end
iverts=unique(iverts);
newverts=swell(iverts,vconn,depth);
return


function [nv]=swell(iv,vc,d)
if d==0
    nv=iv;
    return
end
if iscell(vc)
    nv=[vc{iv}];
    vc(iv)={[]};
else
    nv=[find(any(vc(iv,:),1))];
    vc(iv,nv)=0;
    vc(nv,iv)=0;
end
nv = [nv(:) ; iv(:)];
nv=unique(nv(:)');
nv=unique([nv swell(nv,vc,d-1)]);
return
