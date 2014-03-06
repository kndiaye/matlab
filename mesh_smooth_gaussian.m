%   Simple Gaussian Smoothing does NOT work on surface manifolds. As
%   distance needs to be geodesic not Euclidian
function y=mesh_smooth_gaussian(x,v,vc,sigma,radius)
% mesh_smooth_gaussian - smooth data on a mesh with a Gaussian kernel
%   y=mesh_smooth_gaussian(x,v,vc,sigma,radius)
%   
%   x: data, if empty, the smoothing matrix is returned.
%   y: smoothed data / smooting matrix (if x empty)
%   v: vertices positions ([X Y Z])
%   vc: vertices connectivity
%   sigma: standard deviation of the gaussian kernel
%   radius: radius of swelling (in sigma units), default: 4
%           The contribution of any given vertex is set to zero, when it
%           lies further than the radius
%
% Note: Full Width at Half Maximum (FWHM) is related to sigma by:
%	FWHM = sqrt(8*log(2)) * sigma ~ 2.35*sigma
if (nargin<5)
    radius=4;
end
nv=size(v,1);
radius=radius*sigma;
sigma=sigma^2; % 
W=sparse(1:nv,1:nv,1./sqrt(2*pi*sigma).*ones(1,nv),nv,nv,ceil(nv*radius/sqrt(sum(median(diff(v)).^2))));
K=inline('1/sqrt(2*pi*sigma)*exp(-(x.^2/(2*sigma)))','sigma','x');
for i=1:nv
    waitbar(i/nv)
    done=[i];
    nb=[vc{i}];
    while ~isempty(nb)
        dist=sqrt(sum((v(nb,:)-repmat(v(i,:),length(nb),1)).^2,2));
        j=logical(dist<radius);
        if  ~isempty(nb(j))
            W(i,nb(j))=1/sqrt(2*pi*sigma)*exp(-(dist(j).^2/(2*sigma)));
        end
        done=[done nb];
        nb=setdiff([vc{nb}], done);
    end
end
if isempty(x)
    y=W;
    return
end
y=W*x;
