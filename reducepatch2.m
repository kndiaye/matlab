function [varargout]=reducepatch2(varargin)
% reducepatch2 - reduce patch and give the indices of the kept vertices 
% [nfv,kept]=reducepatch2(...)
% [nf,nv,kept]=reducepatch2(...)
% Same options as reducepatch()
[f2,v2]=reducepatch(varargin{:});
if isstruct(varargin{1}) % FV struct
    v1 = getfield(varargin{1}, 'vertices');
elseif ishandle(varargin{1}) % patch
    v1 = get(varargin{1}, 'vertices');
else
    v1 = varargin{2};
end
[ignore,kept]=ismember(v2,v1, 'rows');
if nargout<=2
    varargout{1}=struct('faces', f2, 'vertices', v2);        
else
    varargout{1}=f2;
    varargout{2}=v2;
end
varargout{end+1}=kept;
