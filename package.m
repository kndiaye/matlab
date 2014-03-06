% This function makes a zip file archive from an m-file and its
% dependencies.  The zip-file is stored in the same path as the 
% m-file with a *.zip extension.  The keyword is used to identify and
% package ONLY m-files that are on paths containing the keyword.  This
% prevents the archiving of Mathwork functions which the end user is likely
% to have or need a license for.  The function is recursive and therefore
% packages functions of functions of functions etc.
%
%  SYNTAX: package(mfile,keyword);
%
% DBE 10/26/04
% DBE 06/24/05 Modified to use username if no keyword is passed IFF Unix platform
%              Included DEPFUN2 as a sub-function.
% DBE 04/11/06 Updated to include functions of sub-functions etc.
%
% See also DEPFUN, DEPFUN2

function package(mfile,keyword);

if nargin==1
  list=depfun2(mfile,[]);
elseif nargin==2
  list=depfun2(mfile,keyword);
else
  error('PACAKGE.M requires 1-2 inputs on Unix machines and 2 inputs on PC machines.');
end

% Display the relevant files
fprintf('The following m-files were packaged together:\n');  
for k=1:size(list,1)
  fprintf(['  ',list{k},'\n']);
end

zipname=which(mfile);
zipname=[zipname(1:end-1),'zip'];   % Create an *.zip filename based on the root m-file name
zip(zipname,list);                  % Zip them together

return

% DEPFUN2 finds the M-file dependencies of an m-file whos
% path also contains a KEYWORD.  It relies upon the use of the 
% DEPFUN function.  DEPFUN2 accepts a keyword to 'grep' for allowing 
% the return of m-files that are only found on a specific path (a users 
% path for example).  The keyword (or part of a word) is used to find 
% matches in the full pathname of all files that the m-file depends upon.
%
% SYNTAX: G=depfun2(fname);
%         G=depfun2(fname,[]);
%         G=depfun2(fname,keyword);
%         G=depfun2(fname,keyword,varargin);
%
% fname    - The name of the m-file for which to determine dependencies
% keyword  - The keyword used to retain m-files whose pathname contains 'keyword'
%            DEFAULT keyword is unix('whoami') on UNIX platforms.
% varargin - Any of the various arguments that DEPFUN usually accepts.
%
% Example: G=depfun2('bench','graphics','-quiet','-toponly'); % Returns FEWER results than...
%          G=depfun2('bench','graphics','-quiet');            % Because this includes indirectly called m-files
% 
%
%          On Unix Platforms the DEFAULT of:
%            G=depfun2('test');
%          Is equivalent to:
%            [STATUS,USERNAME]=unix('whoami');
%            G=depfun2('test',deblank(USERNAME),'-quiet');
%
% DBE 2003/02/07
% DBE 2004/10/26 Modified to support full range of DEPFUN inputs.
% DBE 2005/07/29 Modified to use unix('whoami') as DEFAULT keyword.
% DBE 2005/09/29 Fixed bug when using 2 input arguments
% DBE 2006/04/11 Fixed bug noted by TMW user regarding the inputs.  Cleaned up the code and commented more.

function G=depfun2(fname,keyword,varargin);
if (nargin <2 | isempty(keyword)) & isunix
  [status,keyword]=unix('whoami');
  keyword=deblank(keyword);
  if status
    error('UNIX WHOAMI call failed.');
  end
elseif nargin<2
  error('depfun2.M requires at least two user inputs on non-UNIX platforms');
end

if nargin>2  % VARARGIN can be used to pass standard arguments to DEPFUN
  % Concatentate the VARARGIN into a string that can be used with DEPFUN
  input=[];
  for n=1:length(varargin)
    input=[input,'''',varargin{n},''''];
    if n~=length(varargin), input=[input,',']; end
  end
else  % Default input argument to DEPFUN
%   input=['''','-quiet','''',',','''','-toponly',''''];  % This restricts tracing to first level
  input=['''','-quiet',''''];
end

try
T=eval(['depfun(fname,',input,');']);
catch
    T=depfun(fname);
end

G=[]; m=1;
for k=1:length(T)
  f=strfind(T{k},keyword);
  if ~isempty(f), 
    G{m}=T{k};
    m=m+1; 
  end
end

G=G';

return


% % DEPFUN2 finds the M-file dependencies of an m-file whos
% % path also contains a keyword.  It relies upon the use of the 
% % DEPFUN function.  DEPFUN2 accepts a keyword to 'grep' for allowing 
% % the return of m-files that are only found on a specific path (a users 
% % path for example).  The keyword (or part of a word) is used to find 
% % matches in the full pathname of all files that the m-file depends on.
% %
% % SYNTAX: G=depfun2(fname,keyword,varargin);
% %
% % fname    - The name of the m-file for which to determine dependencies
% % keyword  - The keyword used to retain m-files whose pathname contains 'keyword'
% %            DEFAULT keyword is unix('whoami')
% % varargin - Any of the various arguments that DEPFUN usually accepts.
% %
% % Example: G=depfun2('bench','graphics','-quiet','-toponly'); % Returns FEWER results than...
% %          G=depfun2('bench','graphics','-quiet');            % Because this includes indirectly called m-files
% % 
% % DBE 02/07/03
% % DBE 04/10/26 Modified to support full range of DEPFUN inputs.
% %
% % To Do: Figure out a good way to include functions that sub-functions
% % depend upon etc.
% 
% function G=depfun2(fname,keyword,varargin);
% if nargin <2 & isunix
%   [status,keyword]=unix('whoami');
%   keyword=deblank(keyword);
%   if status
%     error('UNIX WHOAMI call failed.');
%   end
% elseif nargin<2 & ~isunix
%   error('PACKAGE.M requires two user inputs on the PC platform');
% elseif nargin==2
% else
%   error('depfun2.M requires two user inputs');
% end
% 
% if nargin>2 % Concatentate the VARARGIN into a string that can be used with DEPFUN
%   input=[];
%   for n=1:length(varargin)
%     input=[input,'''',varargin{n},''''];
%     if n~=length(varargin), input=[input,',']; end
%   end
% else        % Default input string to DEPFUN
%   input=['''','-quiet','''',',','''','-toponly',''''];
% %   input=['''','-quiet','''']
% end
% 
% T=eval(['depfun(fname,',input,');']);
% 
% G=[]; m=1;
% for k=1:length(T)
%   f=strfind(T{k},keyword);
%   if ~isempty(f), 
%     G{m}=T{k};
%     m=m+1; 
%   end
% end
% 
% G=G';
% 
% return

