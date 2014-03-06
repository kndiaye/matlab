function [staircase] = CreateStaircase(ptarget,xstart,sstart,dstart,chancefloor)

if nargin < 5
    chancefloor = false;
end
if nargin < 4
    error('Missing input argument(s).');
end

staircase = struct;

staircase.ptarget = ptarget;

staircase.i = 1;
staircase.x = nan.*ones(1, 1000);
staircase.r = nan.*ones(1, 1000);

staircase.scur = staircase.stepinfo(1,1);
staircase.dcur = staircase.stepinfo(2,1);
staircase.ncur = staircase.stepinfo(3,1);

staircase.j = 0;

staircase.x = nan(1,1000); staircase.x(1) = xstart;
staircase.r = nan(1,1000);
staircase.p = nan(1,1000);

staircase.scur = sstart;
staircase.dcur = dstart;
staircase.wcur = 0;

staircase.nstp = 0;
staircase.istp = nan(1,1000);

staircase.chancefloor = chancefloor;

end
