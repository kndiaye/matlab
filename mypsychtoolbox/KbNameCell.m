function [kbNameResult] = KbName(arg);
% KbNameCell - Forec KbName output into cell (for strings)
kbNameResult = KbName(arg);
if isnumeric(arg) && ~iscell(kbNameResult)
        kbNameResult = {kbNameResult};
end
    
