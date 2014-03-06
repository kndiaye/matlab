function [A]=vertconn2adjacency(vc,VERBOSE)
% vertconn2adjacency - compute the adjacency patrix
%  [A]=vertconn2adjacency(vc,VERBOSE)
% 
% vc: vertex connectivity, cell array of indices OR patch structure
% A: (sparse) adjacency matrix

if nargin<2
  VERBOSE=0;
end

if isfield(vc, 'faces')
  VertConn=0;
  nv=size(vc.vertices,1);
elseif iscell(vc)    
  VertConn=1;
  nv=length(vc);
else
    error('Wrong type of inputs')
end
% Could think of preallocating I and J
% with an a priori ratio of the number of vertices...
% but (sigh)...
I=[];
J=[];

if VERBOSE
  h=timebar('Building adjacency matrix','Adjacency');
end

if VertConn
    l=[0; cellfun('length', vc)];
    cl=cumsum(l);
    I=zeros(cl(end),1);
    J=[vc{:}]';
    for i=1:nv
        I(cl(i)+[1:l(i+1)])=i;
        if VERBOSE
            timebar(h,i/nv)
        end
    end
else
    % I J should be preallocated 
    for i=1:nv;
        adj=setdiff(unique(vc.faces(find(any(vc.faces==i,2)))),i);
        adj=adj(:)';
        adj=double(adj);
        n=length(adj);
        I=[I i*ones(1,n)];
        J=[J adj];
        if VERBOSE
            timebar(h,i/nv)
        end
    end
end
A=sparse(I,J,ones(length(I),1),nv,nv);
A=A|A';

if VERBOSE
  close(h);
end
