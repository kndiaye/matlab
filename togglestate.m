function [varargout] = togglestate(handles,property,togglelist,exactflag)
%togglestate - toggle a handle between states 
%   [newstate] = togglestate(handles,Property,[ListOfStates], [exactflag])
% Toggle the Property of each Handle individually 
%   ListOfState is optional. Default is to toggle between 'on' and 'off'
%   If exactflag == 'exact', string matching will be exact
% ex:
%   togglestate

if nargin<4
    exactflag=0;
else
    exactflag=isequal(exactflag, 'exact');
end

if nargin<3
    togglelist={'on' ; 'off'};    
end
if nargin<2
    error('Handles and Property to set are mandatory')
end

cellofchar=0;
try
    char(togglelist);
    cellofchar=1;
end

% togglelist2=unique(togglelist);
% if length(togglelist2) ~= length(togglelist)
%     warning('List of States has redundant elements, they will be removed!')
%     [i,j]=ismember(togglelist2,togglelist)
%     togglelist=togglelist(sort(j))
% end
% togglelist(end+1)=togglelist(1);
ns=length(togglelist);

for i=1:length(handles)
    %    get(handles(i), property),
    newstate{i}=togglelist{1};
    for j=1:ns-1
        if (cellofchar & strmatch(togglelist{j},get(handles(i), property))) |  (~cellofchar & isequal(togglelist{j},get(handles(i), property)))
            newstate{i}=togglelist{j+1};
        end
    end
    set(handles(i), property, newstate{i});
end
if nargout>1
    varargout=newstate;
end
return
