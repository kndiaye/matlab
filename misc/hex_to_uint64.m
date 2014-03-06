function m = hex_to_uint64(h)
%HEX_TO_UINT64 Convert hexadecimal string to uint64 number.
%
%   HEX_TO_UINT64(H) converts the hexadecimal string H and returns the
%   corresponding uint64 numbers.  Each row in H, representing one output
%   value, must only contain characters in the set '0123456789abcdefABCDEF'.
%
%   For example
%
%      hex_to_uint64(['0000000000000000'
%                     '0000000000000001'
%                     '0000000000000002'
%                     '7ffffffffffffffd'
%                     '7ffffffffffffffe'
%                     '7fffffffffffffff'])
%
%   returns
%
%      [                  0
%                         1
%                         2
%       9223372036854775805
%       9223372036854775806
%       9223372036854775807]

%   Author:      Peter John Acklam
%   Time-stamp:  2004-09-22 18:43:25 +0200
%   E-mail:      pjacklam@online.no
%   URL:         http://home.online.no/~pjacklam

   % Check number of input arguments.
   error(nargchk(1, 1, nargin));

   % Check type and size of input argument.
   if ~ischar(h)
      error('Argument must be a character array.');
   end

   hs = size(h);
   hd = ndims(h);
   if (hd > 2) || (hs(2) ~= 16)
      error('Input must be a 2D matrix with 16 columns.');
   end

   if any(   ( (h(:) < '0') | ('9' < h(:)) ) ...
           & ( (h(:) < 'A') | ('F' < h(:)) ) ...
           & ( (h(:) < 'a') | ('f' < h(:)) ) );
      error('Invalid hexadecimal string.');
   end

   % Convert to the output data type.
   n = uint64(reshape(sscanf(h, '%1x'), hs))
   m = uint64(n(:,1));
   for i = 2:16
      m = bitor(bitshift(m, 4), n(:,i));
   end
