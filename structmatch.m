function [V,I,MK] = structmatch(D,H,K,W)
%STRUCTMATCH - Generic lookup function for structure arrays
%
%   [VALUES] = structmatch(DATA,HASHKEY,KEY) will retrieve all elements
%   from the structure DATA whose field HASHKEY match the value(s) in KEY
%   (according to regexp). HASKEY can also be the index in the fieldname list.
%
%   [VALUES] = structmatch(DATA,HASHKEY) will retrieve all elements from
%   the structure DATA whose field HASHKEY is true (will be converted to
%   logical if needed)
%
%   [VALUES,INDICES] = structmatch(...) also outputs the logical indices of
%   the matching elements from the structure
%
%   [...] = structmatch(DATA,HASHKEY,KEY,WHAT) will only retrieve from
%   the matching elements, the field indexed by WHAT
%   If WHAT == NaN (default), retrieves all data
%   If WHAT == 0, retrieves logical indices, see just below.
%   If WHAT == N, retrieves indices of N>0 first matches.
%   If WHAT == Inf, retrieves indices of all matches.
%
%   [TF] = structmatch(DATA,HASHKEY,KEY,0) will only retrieve logicals
%   of the same size as DATA with 1's where elements match the KEY
%
%   [...] = structmatch(DATA,HASKEY,FUN) uses function handle FUN to make
%   the match (the result FUN is converted into a logical).
%
%   [VALUES,INDICES,MATCHINGKEYS] = structmatch(...) will also output the
%   names of the fields used as hashkeys (e.g., if HASHKEY was input as the
%   numerical index of the field in the structure)
%
%   Examples
%       >> structmatch(dir(pwd),'bytes',@(X)X>10000,'name')
%       will list the name of the files from the current directory whose
%       size is > 100 bytes (See help on dir and function_handle)
%
%       >> structmatch(dir,'date',@(D)datenum(D)>now-7,'name')'
%       will list the name of the files from the current directory which
%       are earlier than 7 days
%
%       >> findobj('type','fig')
%       >> close(ans(structmatch(get(findobj('type','fig')),'Name',@isempty,0)))
%       will close all open figures whose Names are empty.
%
%   See also: strmatch, structcmp, function_handle

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2008
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2008-10-28 Creation
% KND  2008-11-05 Bug with nargin=3;
% KND  2009-07-24 Bug: structmatch(dir(pwd),4,1)
% KND  2009-11-05 Logical indices & Error checking 
%
% ----------------------------- Script History ---------------------------------

%warning('bug with: structmatch(dir(pwd),4,1)')
if ~ isstruct(D)
    error('Input must be a structure array')
end
if nargin<4
    %retrieve all fields of the matching elements from the structure
    W=NaN;
end
if nargin<3
    %retrieve all fields of the matching elements from the structure
    K=[];
end
if ischar(H)
    if isfield(D,H)
        HK={D.(deblank(H))};
    else
        error('Unknown hashkey: %s is not a field of the structure', H);
    end
elseif isnumeric(H)
    FN=fieldnames(D);
    if H<1 || H > numel(FN)
        error('Requiring field #%d in structure that contains only %d fields!', H, numel(FN));
    end
    H=FN{H};
    HK={D.(deblank(H))};
end
% Find indices of the elements matching the key
if isempty(K)
    I=cell2mat(HK);
elseif isa(K, 'function_handle')
    [I]=cell2mat(cellfun2(K,HK));
    % elseif isnumeric(K)
    % [I]=ismember(cell2mat(HK),K);
    % this doesn't work...
    % indeed if any empty value, result is shifted...
    % eg: a=dir;b=a;b(3).bytes=[];structmatch(a,3,a(4).bytes)
    %
elseif ischar(K) % reg exp
    %[I]=ismember(HK,K);
    [I]=not(cellfun('isempty',regexp(HK,K)));
else
    I=logical(zeros(size(HK))); %#ok<LOGL>
    for i=1:numel(HK)
        if isequal(K,HK{i})
            I(i)=1;
        end
    end
    %error('STRUCTMATCH:WrongKey','Wrong input: KEY');
end
% Output matching keys, if user wants them
if nargout>2
    MK=HK(I);
end
if isequal(W,0)
    V = I;
    return
end
if ~isnan(W) & isnumeric(W)
    V = find(I,W);
    return
end

% Filter matching elements
V=D(I);
if ~isnan(W)
    V ={V.(deblank(W))};
else
    % output the whole struct as V
end


function [y] = cellfun2(fun, x)
% cellfun() - Cap funtion for cellfun which accepts any function call
%
% Y = CELLFUN(FUN, C) applies function FUN to the cells of C
%
%See also: cellfun
y = cell(size(x));
for i=1:numel(x)
    y{i} = feval(fun, x{i});
end
return;
