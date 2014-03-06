function [s1]=mergestructs(s1,s2,ignore)
% mergestructs - merge two structures into one
%   [S3]=MERGESTRUCTS(S1,S2) creates a structure s3 whose fields are those
%   of structures S1 and S2. 
%   
%   Structures are recursively processed. If some fields (and/or subfields)
%   are common to both S1 and S2, values from S1 are replaced by those
%   found in S2.
%   Common fields/subfields in S1 and S2 MUST be of the same size (or one
%   must be of size 1 and will be expanded to match the size of the other).

% KND 

if isempty(s1)
    s1=s2;
    return
end
if isempty(s2)    
    return
end
if nargin<3
    ignore=0;
end

if  ( ~isstruct(s1) ||  ~isstruct(s2) )
    if ignore && ( ~isstruct(s1) &&  ~isstruct(s2) )
        % 'ignore == 1'  accepts input that aren't structures.
        s1=s2;
        return;
    else
        error('KND:MERGESTRUCTS:NotStructures', 'Inputs must be struct arrays!');
        return
    end
end

if ~isequal(size(s1),size(s2))
    if all(size(s1)==1)
        s1=repmat(s1, size(s2));
    elseif all(size(s2)==1)
        s2=repmat(s2, size(s1));
    else
        error('KND:MERGESTRUCTS:NonmatchingSizes', ...
            'Input structures have incompatibles size.');
    end
end
f=fieldnames(s2);
for i=1:length(f)
    do_merge = isfield(s1, f{i});
    for j=1:length(s1(:))
        if do_merge
            x=mergestructs(getfield(s1(j),f{i}), getfield(s2(j),f{i}),1);
        else
            x=getfield(s2(j),f{i});
            s1(j).(f{i})=[];
        end
        s1(j)=setfield(s1(j), f{i}, x);
    end
end
s1=reshape(s1, size(s2));
