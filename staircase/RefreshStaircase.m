function [staircase] = RefreshStaircase(staircase)

if nargin < 1
    error('missing input argument.');
end

if ~isnan(staircase.r(staircase.i))
    if ~mod(staircase.i-staircase.j,staircase.dcur)
        staircase.nstp = staircase.nstp+1;
        staircase.istp(staircase.nstp) = staircase.i;
        rcur = staircase.r(staircase.i-staircase.dcur+1:staircase.i);
        if all(ismember(rcur,[0,1]))
            p = mean(rcur);
        else
            error('unable to refresh staircase.');
        end
        if staircase.chancefloor
            pcur = max(p,0.5);
        else
            pcur = p;
        end
        staircase.wcur = staircase.ptarget-pcur;
        staircase.p(staircase.i) = p;
        staircase.x(staircase.i+1) = staircase.x(staircase.i)*10^(staircase.wcur*staircase.scur);
    else
        staircase.p(staircase.i) = 0;
        staircase.x(staircase.i+1) = staircase.x(staircase.i);
    end
    staircase.i = staircase.i+1;
    if staircase.i == length(staircase.x)
        staircase.x = [staircase.x,nan(1,staircase.i)];
        staircase.r = [staircase.r,nan(1,staircase.i)];
        staircase.p = [staircase.p,nan(1,staircase.i)];
    end
end

end