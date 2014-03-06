function [html] = WhatsThisImage(filename,keywords,varargin)
%WHATSTHISIMAGE - Try to find a amtching image on the web
%   [] = WhatsThisImage(filename)
%
%   Example
%       >> WhatsThisImage
%
%   See also: 

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2009 
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2009-03-02 Creation
%                   
% ----------------------------- Script History ---------------------------------

filename = 'http://tbn2.google.com/images?q=tbn:PkiyfXuSo4dVIM:http://www.simpsonstrivia.com.ar/simpsons-photos/wallpapers/homer-simpson-wallpaper-brain-1024.jpg';
keywords = 'brain'

query = 'http://images.google.com/images?';
params.q=keywords;
params.language = [];
params.tab = 'wi';

for f=fieldnames(params)'
    if isfield(params, f{1}) && ~isempty(params.(f{1}))
        query = [ query '&' f{1} '=' params.(f{1}) ];
    end
end
query
start=0
for ipage = 1:2
   html = urlread(query); 
end

javaaddpath(fullfile(pwd,'googleapi','googleapi.jar'))

%key = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx';
setpref('google','key',key);


% Setup.
googleSearch = com.google.soap.search.GoogleSearch;
key = getpref('google','key','');
if isempty(key)
    error(sprintf('%s\n%s', ...
'No key set.  You need to get an access key from Google and set it like this:', ...
'setpref(''google'',''key'',''xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'');'));    
end
googleSearch.setKey(key);
googleSearch.setQueryString(q);
googleSearch.setFilter(filter);



function score = matching(im1,im2)
% Brutye foprce approach : pixel-based correlation in greyscale... 
score = 0;
im1=normimage(im1);
im2=normimage(im2);
if ~isequal(size(im1),size(im2))
    return
end
    

sc = corrcoef(im1,im2)

function x = normimage(im) 
x = normalize(mean(double(im),3), 'unity', [1:2]);
