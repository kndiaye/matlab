function  [clu,clu2,tex2]=tex_clusters(tex, vc, sx, tx,VERBOSE)
% tex_clusters - find clusters of a given extant on a texture
% 
% [clu]=tex_clusters(tex, vc)
% [clu,clu2,tex2]=tex_clusters(tex, vc, sx, tx)
%  
% Lists clusters of a texture, given a minimal size in space and time
% (i.e. at least [sx] connected vertices must be active during at
% least [tx] time sample for the cluster to be kept
%  
%INPUTS:
% tex: [M-by-T] texture of logical values (0=not active) on a N-vertices mesh during T time samples
% vc: vertex connectivity of the mesh or adjacency matrix
%OPTIONAL INPUTS:
% sx: minimum  spatial extant (default: 1) 
% tx: minimum temporal extant (default: 1)
%OUTPUT: 
% clu: cluster list, a cell array of vertex indices matchin the criteria
% clu2: time dependent new texture with 1's
%


% See also: dmperm

% http://delivery.acm.org/10.1145/100000/98287/p303-pothen.pdf?key1=98287&key2=1613996311&coll=GUIDE&dl=GUIDE&CFID=65251534&CFTOKEN=21051873

DEBUG=0;
if nargin<5
    VERBOSE=1;
end
if nargin<4
    tx=1;
elseif tx>0
    warning('No temporal filtering yet!');
end
if nargin<3
    sx=1;
end
if nargin<2
    error('Not enoug arguments');
end

nv=size(tex,1);
nt=size(tex,2);

if length(vc) ~= nv
    error('Connectivity and number of vertices in the texture don''t match')
end

if iscell(vc)
    A=vertconn2adjacency(vc);
else
    A=vc;
end

A=(A|speye(size(A)));
if VERBOSE
    h = timebar('Spatial extent','Progress');
end
C={};
for it=1:nt
    f=double(tex(1:nv,it));  
    B=A;
    % NaN values
    f(isnan(f))=0;
    
    % Remove OFF vertices
    B(~f,:)=0;
    B(:,~f)=0;  
    
    % Compute clusters
    [p,q,r,s] = dmperm(B);    
    nc=0; % number of cluster at this time sample
    sr=diff(r); % compute size of clusters
    [ignore,rr]=sort(-sr); % sort clusters by decreasing size 
    for i=1:length(r)-1
        if r(rr(i))<nv 
            % some clusters are empty and said to contain the 
            % (nv+1)-th vertex!      
            if f(p(r(rr(i)))) ... % == it is an ON cluster
                    & sr(rr(i))>=sx % == it passes the spatial threshold 
                nc=nc+1;
                C{it}{nc}=p(r(rr(i)):r(rr(i)+1)-1);
            end
        end
        if VERBOSE
             try;timebar(h,(i+(it-1)*length(r))/(nt*length(r)));end;
         end
    end
    
        
end
if VERBOSE
    try;close(h);end
end
% Post process for time continuity
% 

clu=C;

if nargout>1
    clu2=sparse(nv,nt);
    for it=1:nt
        for i=1:length(clu{it})
            clu2(C{it}{i},it)=i;
        end
    end
end

return
