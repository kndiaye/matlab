function varargout = setAll(p,v,h)
%SETALL - Set a given property for all objects that have it
%   ht = setall(Property,Value,[ParentHandles])
%   ht are the modified handles

% Author: KND
% Created: Sep 2005
if nargin<3
    h=gca;
end
if ~ishandle(h)
    return
end
h=findall(h);
ht=[];
for i=1:length(h)
    try%if isfield(get(h(i)), p)
        set(h(i),p,v);
        ht=[ht h(i)];
    end
end
if nargout
    varargout={ht};
end
return

