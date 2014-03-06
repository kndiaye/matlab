function printmatrix(X,dec);

% PRINTMATRIX prints to the screen a nice easy to read printout of the matrix X
% that can be copied and pasted into other applications (e.g. Excel).
%
% PRINTMATRIX(X); prints out the contents of X with 3 decimal places
%
% PRINTMATRIX(X,DEC); prints out the contents of X with DEC decimal places
%
%
% Written by Stephan W. Wegerich, SmartSignal Corp. August, 2001.
%
if(nargin==1),dec=3;end

if(any(~isreal(X)))
    error('Input Must be Real');
end

[N,M]=size(X);

ff = ceil(log10(max(max(abs(X)))))+dec+3;

fprintf('\n');
for i=1:N,
    fprintf(['%#',num2str(ff),'.',num2str(dec),'f\t'],X(i,:));
    fprintf('\n');
end
