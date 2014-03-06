function val = compute(dh, op, options)
% compute(datahandler) - Performs computation on data

switch lower(op)
    case {'mean'}
        
    otherwise
        error([op,' is not a valid operation.'])
end