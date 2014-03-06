function val = get(dh, propName, options)
% GET - Get property from datahandler object

% default output data
if nargin<2
    propName = 'data';
end
switch lower(propName)
    case {'data', 'f'}
        val = dh.F;
    otherwise
        error([propName,' is not a datahandler property'])
end