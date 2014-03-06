function [fv]=struct2fv(s)
% struct2fv - Keep only the faces and vertices fields from a structure
%   fv=struct2fv(s)
% will remove extra fields of s to keep only the "Vertices" and "Faces" ones
% Note: Upper case/lower case discrepancies are ignored.

fv=[];
for f={'faces', 'vertices'}
    if isfield(s, f{1})    
        fv=setfield(fv, f{1}, getfield(s, f{1}));
    elseif isfield(s, lower(f{1}))    
        fv=setfield(fv, f{1}, getfield(s, lower(f{1})));
    elseif isfield(s,  [upper(f{1}(1)) upper(f{1}(2:end))])
        fv=setfield(fv, f{1}, getfield(s, [upper(f{1}(1)) upper(f{1}(2:end))]));
    else
        warning(sprintf('No field %f in the structure', f{1}))
    end
end