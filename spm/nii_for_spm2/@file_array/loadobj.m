function b = loadobj(a)
% loadobj for file_array class
% _______________________________________________________________________
% Copyright (C) 2008 Wellcome Trust Centre for Neuroimaging

%
% $Id: loadobj.m 1746 2008-05-28 17:43:42Z guillaume $

if isa(a,'file_array')
    b = a;
else
    a = rmfield(a, 'permission');
    b = file_array(a);
end
