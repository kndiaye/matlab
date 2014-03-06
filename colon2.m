function [varargout] = colon2(varargin)
%:  Colon2. (Adapted fomr COLON for 2-element input by KND)
%
%   COLON2([J K]) is equivalent to COLON(J,K)
%
%   See also: COLON

%   J:K  is the same as [J, J+1, ..., K].
%   J:K  is empty if J > K.
%   J:D:K  is the same as [J, J+D, ..., J+m*D] where m = fix((K-J)/D).
%   J:D:K  is empty if D == 0, if D > 0 and J > K, or if D < 0 and J < K.
%
%   COLON(J,K) is the same as J:K and COLON(J,D,K) is the same as J:D:K.
%
%   The colon notation can be used to pick out selected rows, columns
%   and elements of vectors, matrices, and arrays.  A(:) is all the
%   elements of A, regarded as a single column. On the left side of an
%   assignment statement, A(:) fills A, preserving its shape from before.
%   A(:,J) is the J-th column of A.  A(J:K) is [A(J),A(J+1),...,A(K)].
%   A(:,J:K) is [A(:,J),A(:,J+1),...,A(:,K)] and so on.
%
%   The colon notation can be used with a cell array to produce a comma-
%   separated list.  C{:} is the same as C{1},C{2},...,C{end}.  The comma
%   separated list syntax is valid inside () for function calls, [] for
%   concatenation and function return arguments, and inside {} to produce
%   a cell array.  Expressions such as S(:).name produce the comma separated
%   list S(1).name,S(2).name,...,S(end).name for the structure S.
%
%   For the use of the colon in the FOR statement, See FOR.
%   For the use of the colon in a comma separated list, See VARARGIN.

if nargout == 0
    if nargin==1 && length(varargin{1})==2
        builtin('colon',varargin{1}(1),varargin{1}(2));
    else
        builtin('colon', varargin{:});
    end
else
    if nargin==1 && length(varargin{1})==2
        [varargout{1:nargout}] = builtin('colon', varargin{1}(1),varargin{1}(2));
    else
        [varargout{1:nargout}] = builtin('colon', varargin{:});
    end
end