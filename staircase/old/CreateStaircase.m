function [staircase] = CreateStaircase(pctarget, stepinfo, xstart, pfdir)
% s = CreateStaircase(pctarget, stepinfo, xstart, pfdir)
%
% pctarget:
if nargin < 4, pfdir = +1; end
if nargin < 3, error('Not enough input arguments.'); end

staircase = struct;

staircase.pctarget = pctarget;
staircase.stepinfo = stepinfo;
staircase.pfdir = sign(pfdir);

staircase.i = 1;
staircase.x = nan.*ones(1, 1000);
staircase.r = nan.*ones(1, 1000);

staircase.scur = staircase.stepinfo(1,1);
staircase.dcur = staircase.stepinfo(2,1);
staircase.ncur = staircase.stepinfo(3,1);

staircase.j = 0;
staircase.w = [];

staircase.wcur = 0;
staircase.wold = 0;

staircase.nstp = 0;
staircase.istp = nan.*ones(1, 1000);

staircase.nrev = 0;
staircase.irev = nan.*ones(1, 1000);

staircase.ndec = 0;
staircase.idec = nan.*ones(1, size(staircase.stepinfo, 2)-1);

staircase.x(1) = xstart;

end
