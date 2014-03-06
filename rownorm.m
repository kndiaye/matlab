function nrm = rownorm(A);
% function nrm = rownorm(A);
% calculate the Euclidean norm of each ROW in A, return as
% a column vector with same number of rows as A.

% Copyright (c) 1994 by John C. Mosher
% Los Alamos National Laboratory
% Group ESA-MT, MS J580
% Los Alamos, NM 87545
% email: mosher@LANL.Gov
%
% Permission is granted to modify and re-distribute this code in any manner
%  as long as this notice is preserved.  All standard disclaimers apply.

% May 6, 1994 JCM author 

[m,n] = size(A);

if(n>1),			% multiple columns
  nrm = sqrt(sum([A.*conj(A)],2));
else				% A is col vector
  nrm = abs(A);
end

return
