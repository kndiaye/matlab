function [varargout]=affinetransform(x,varargin)
% affinetransform - Apply affine transformation to 3D points
% [y,m,m2]=affinetransform(x,m)
% [y,m,m2]=affinetransform(x,r,t)
% [x,m,m2]=affinetransform(y,-1,m) or affinetransform(y,-1,r,t) 
% [m,m2]=affinetransform([],r,t)
%   x and y are the Nx3 coordinates
%   r is the TRANSPOSED rotation matrix (see infra) or the rotation vector: [ux uy uz angle]
%   t is the transposed (i.e. horizontal) translation vector
%   m is the rotation/translation matrix: m = [r ; t] = [R' ; T']
%   m2 is the inverse transformation:    m2 = [r'; -t*r']
%   the [-1] flag will apply the inverse transfo m2 (see infra)
%   
% The classical formula for vertical vectors: 
%   Y = R * X + T 
% is simplified into the following: 
%   y = [x 1]*m = [x*r]+t =     [X'*R]+T'
% with: 
%   y and x are N-by-3 matrices (i.e. horizontal vectors)
%   r = R'
%   t = T'
%   m = [r ; t] = [R T]'
%
% The [-1] flag apply the inverse transformation so that: 
%   X = R^-1 * ( Y - T) 
% i.e:
%   x = r' * [y' - t']

ninput=nargin-1;
if isequal(varargin{1}, -1)
    InverseTransfo = 1;
    varargin(1)=[];
    ninput=ninput-1;
else
    InverseTransfo = 0;
end  

switch ninput
    case 1
        m=varargin{1};
        r=m(1:3,:);
        t=m(4,:);
    case 2
            if isequal(size(varargin{1}), [1 4])
            u=varargin{1};
            cosa = cos(u(4));
            sina = sin(u(4));
            vera = 1 - cosa;
            x = u(1); y = u(2); z = u(3);
            r = [cosa+x^2*vera , x*y*vera-z*sina , x*z*vera+y*sina; ...
                    x*y*vera+z*sina , cosa+y^2*vera , y*z*vera-x*sina; ...
                    x*z*vera-y*sina , y*z*vera+x*sina , cosa+z^2*vera]';
        else            
            r=varargin{1};
        end        
        t = varargin{2};
        
    otherwise
        error('Invalid number of inputs')
end
m=[r ; t];
m2 = [r'; -t*r'];
if isempty(x)
    varargout={m,m2};
    return
end
if InverseTransfo
    y=[x ones(size(x,1),1)]*m2;
else  
    y=[x ones(size(x,1),1)]*m;
end
varargout={y,m,m2};