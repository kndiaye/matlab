function ht = setAll(p,v,h)
%SETALLTEXT - Set properties of all text objects (in a given figure/plot/...)
%   ht = setAllText(Property,Value,[Handles])
%   ht are the handles to text object found

% Author: KND
% Created: Sep 2005
if nargin<3
    h=gca;
end


ht=findobj(h, 'type', 'text');
set(ht, p, v)
ha=findobj(h,'type', 'axes')
if ~isempty(ha)
    for i=1:length(ha)        
        if isfield(get(ha(i)), p)
            set(ha(i),p,v)
        else
            warning(sprintf('No property %s for object Axes', p))
        end
        for hah=get(ha(i),'Children')'
            if isfield(get(hah), p)
                %set(hah
            end
        end
    end
end
