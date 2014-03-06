function [staircase] = UpdateStaircase(staircase, r, x)
% sc2 = UpdateStaircase(sc1, accuracy)
%   sc1: Staircase struct previously initialized   
%   accuracy = 0 (incorrect) or 1 (correct)
% Ouput: 
%   sc2: Updated staircase struct

if nargin < 2, error('Not enough input arguments.'); end

staircase.r(staircase.i) = r;
if nargin>2
    staircase.x(staircase.i) = x;
end

if ~mod(staircase.i-staircase.j, staircase.dcur)
    staircase.nstp = staircase.nstp+1;
    staircase.istp(staircase.nstp) = staircase.i;
    % Number of correct responses on the last 'dcur' trials (see stepinfo)
    nc = sum(staircase.r(staircase.i-staircase.dcur+1:staircase.i));
    if isempty(staircase.w)
        staircase.w = GetStaircaseWeights(staircase.pctarget, staircase.dcur);
    end
    % Get the weights for 'nc' correct responses
    staircase.wcur = staircase.w(nc+1);
    if abs(sign(staircase.wcur)-sign(staircase.wold)) > 1
        % We have a reversal at this trial... 
        staircase.nrev = staircase.nrev+1;
        staircase.irev(staircase.nrev) = staircase.i;
        % If # of reversals for this size of steps has been reached go to
        % the next
        if staircase.nrev == staircase.ncur
            staircase.ndec = staircase.ndec+1;
            staircase.idec(staircase.ndec) = staircase.i;
            staircase.scur = staircase.stepinfo(1,staircase.ndec+1);
            staircase.dcur = staircase.stepinfo(2,staircase.ndec+1);
            staircase.ncur = staircase.ncur+staircase.stepinfo(3,staircase.ndec+1);
            staircase.w = GetStaircaseWeights(staircase.pctarget, staircase.dcur);
            staircase.j = staircase.i;
        end
    end
    staircase.wold = staircase.wcur;
    staircase.x(staircase.i+1) = staircase.x(staircase.i)*10^(staircase.pfdir*staircase.wcur*staircase.scur);
else
    staircase.x(staircase.i+1) = staircase.x(staircase.i);
end

staircase.i = staircase.i+1;

if staircase.i == length(staircase.x)
    staircase.x = [staircase.x,nan(1, staircase.i)];
    staircase.r = [staircase.r,nan(1, staircase.i)];
end
if staircase.nrev == length(staircase.irev)
    staircase.irev = [staircase.irev,nan(1, staircase.nrev)];
end

end

function [w] = GetStaircaseWeights(pc, d)
b = factorial(d)./(factorial(0:+1:d).*factorial(d:-1:0)).*pc.^(0:+1:d).*(1-pc).^(d:-1:0);
w = pc-linspace(0, 1, d+1);
w = w./sum(b.*abs(w));
end
