function a=cronbach(X)
%cronbach - Calculates the Cronbach's alpha of a data set X.
%
%   a=cronbach(X)
%       a is the Cronbach's alpha.
%       X is the data set (Observations by Items).
%

% Reference:
% Cronbach L J (1951): Coefficient alpha and the internal structure of
% tests. Psychometrika 16:297-333

a=1/(1-1/size(X,2))*(1-sum(var(X))./var(sum(X,2)));

% 
% % Alexandros Leontitsis
% % Department of Education
% % University of Ioannina
% % Ioannina
% % Greece
% %
% % e-mail: leoaleq@yahoo.com
% % Homepage: http://www.geocities.com/CapeCanaveral/Lab/1421
% %
% % June 10, 2005.
% 
% if nargin<1 | isempty(X)==1
%    error('You shoud provide a data set.');
% else
%    % X must be a 2 dimensional matrix
%    if ndims(X)~=2
%       error('Invalid data set.');
%    end
% end
% 
% 
% % Calculate the number of items
% k=size(X,2);
% 
% % Calculate the variance of the items' sum
% VarTotal=;
% 
% % Calculate the item variance
% SumVarX=;
% 
% % Calculate the Cronbach's alpha
