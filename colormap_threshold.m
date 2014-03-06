function c = colormap_threshold(x,cmap,beta)
%COLORMAP_THRESHOLD - Cut colormap at a given threshold
%
%   [cmap] = colormap_threshold(x)
%       Replace colormap in current axes (gca) with a thresholded one at
%       the value x (or [-x x] if both positive and negatice values are
%       used in the current graphics
%
%   [cmap] = colormap_threshold(x,rgb) if RGB has only one line, the new
%       colormap will be based on the colormap of the current axes
%
%   [cmap] = colormap_threshold(x,handle) uses the colormap of the
%       specified axes. If empty, uses the current axes.
%
%   [cmap] = colormap_threshold(x,cmap,beta) 
%       beta specifies where the colormap should be cut and replace by the
%       given RGB color (col). In percent (if beta<1) or actual number of colors (if >=1). 
%       Default: beta=0 (the whole previous colormap will be
%       used to display values beyond the threshold x) 
%
%   [cmap] = colormap_threshold(x,beta,cmap,clim,col)

%
%   Example
%       To cut p-value map displayed in log10 at a p<0.05 threshold
%       >> colormap_threshold(-log10(0.05))
%
%   See also: 

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2005 
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% ----------------------------- Script History ---------------------------------
% KND  2005-12-18 Creation
%                   
% ----------------------------- Script History ---------------------------------
h=gca;
beta=0;
if nargin>1    
    h=varargin{1};
end
if nargin>2
    beta=varargin{2};
end
if nargin>3
    col=varargin{3};
    if length(col)==3
        cmap=colormap(h);
        clim=get(h, 'CLim');
    else
        beta=varargin{1};
        cmap=varargin{2};
        clim=varargin{3};
        col=[];
        if nargin>4
            col=varargin{4};
        end
        
    end
else
    cmap=colormap(h);
    clim=get(h, 'CLim');
    col=[];
end

if prod(clim)>=0
   % all values have same sign
   d=clim(2)-clim(1);
   
   if (clim(2)>0)
       % All positive
       
   elseif clim(1)<0
       % All negative
   else
       % All zeros!
       error('Wrong CLim')
   end
else

end
