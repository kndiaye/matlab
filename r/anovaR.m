function []=anovaR(X,G)
mypath;
addpath(fullfile(HOMEDIR, 'mtoolbox', 'matlab-R'))

status=closeR;
[status,msg] = openR;
if status ~= 1
    disp(['Problem connecting to R: ' msg]);
end

b = evalR('a^2')
evalR('b <- a^2');
evalR('c <- b + 1');
c = getRdata('c')

closeR