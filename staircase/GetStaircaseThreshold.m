function [results] = GetStaircaseThreshold(results,iout)

if nargin < 2
    error('Missing input argument(s).');
end

iout = min(iout,length(results.istp)-1);
i1st = results.istp(iout)+1;

xthres = 10^mean(log10(results.x(results.istp(iout+1:end))));
pthres = [];

rthres = results.r(i1st:end);
if all(ismember(rthres,[0 1]))
    pthres = mean(rthres);
elseif all(ismember(rthres,[-2 -1 +1 +2]))
    pthres = 0.5*(nnz(rthres == +1)/nnz(abs(rthres) == 1)+nnz(rthres == +2)/nnz(abs(rthres) == 2));
end

results.xthres = xthres;
results.pthres = pthres;

end