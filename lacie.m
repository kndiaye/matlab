function [LACIE] = lacie()
%LACIE  Finds LACIE (my ext. harddrive)'s letter
%   output = lacie(input)
%
%   See also: mypath
LACIE='';
DRIVES='GHFEKX';
if ispc
    for i=1:length(DRIVES)        
        if exist(fullfile([DRIVES(i) ':'],'lacie.txt'),'file')
            LACIE=[DRIVES(i) ':'];
            break
        end
    end
else
    error('adapt your script man!')
end

if nargout==0
    assignin('caller', 'LACIE', LACIE)
end


% Author: 
% Created: Mar 2007
% Copyright 2007