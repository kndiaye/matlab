function [results] = GetStaircaseResults(staircase)

if nargin < 1
    error('Missing input argument.');
end

results = struct;

results.ptarget = staircase.ptarget;

results.n = staircase.i-1;

results.x = staircase.x(1:results.n);
results.r = staircase.r(1:results.n);
results.p = staircase.p(1:results.n);

results.nstp = length(find(staircase.istp <= results.n));
results.istp = staircase.istp(1:results.nstp);

results.nrev = staircase.nrev;
results.irev = staircase.irev(1:results.nrev);

results.ndec = staircase.ndec;
results.idec = staircase.idec;
if isempty(icvg)
    if isempty(results.idec)
        icvg = [];
    else
        icvg = results.idec(end);
    end
elseif icvg > results.n
    icvg = nan;
end
results.icvg = icvg;
if ~isnan(icvg)
    results.pc = mean(results.r(icvg:end));
    try
        results.x0 = quantile(results.x(icvg:end), [0.25,0.5,0.75]);
    catch
        results.x0 =[NaN,median(results.x(icvg:end)),NaN];
    end
else
    results.pc = nan;
    results.x0 = [nan,nan,nan];
end
