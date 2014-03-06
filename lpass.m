function [z] = lpass(x, f, FS,tdim)
% lpass - easy to use lw pass filter (zero phase)
%   [xf]=lpass(x,[f, FS, tdim])
% Low-passes data in x ...
%    with a cutting frequency f [default=5Hz]
%    assuming x in sampled at FS Hz [def=625];
%    on the tdim dimension. If not given:
%           - x should be a [ 6 conditions x Nchannels x Tsamples ]
%           - or: tdim is ssumed to be the longest dimension... don't laugh
%
% Based on Mario Chavez's LowPassFilter 
if not(exist('lowpassFilter'))
    global HOMEDIR
    addpath(fullfile(HOMEDIR, 'matlab', 'mario'))
     addpath(fullfile(HOMEDIR, 'matlab', 'mario'))
end

if nargin<2 % 6Hz par défaut ~=~ 100ms sliding window
    f=6;
end

if nargin < 3
    FS=625;
end

if nargin > 3 
    s1=size(x);
    n1=ndims(x);    
    t=tdim;
    s2=[prod(s1(1:t-1)) s1(t) prod(s1(t+1:end))];
    z=reshape(x,s2);
        for i=1:size(z,1)        
            for j=1:size(z,3)        
                z(i,:,j)=lowpassFilter(squeeze(z(i,:,j)),FS,f);    
            end
        end
    
    z=reshape(z, s1);
    return
end
if ndims(x)==3 & size(x,3)<6
    for i=1:size(x,3);  
        z(:,:,i)=lowpassFilter(shiftdim(permute(x(:,:,i), [3 2 1])),FS,f)';
    end
    if size(z, 2)==1
        z=permute(z, [2 1 3]);
    end
else
    s1=size(x);
    n1=ndims(x);    
    [ignore,t]=max(s1);
        s2=[prod(s1(1:t-1)) s1(t) prod(s1(t+1:end))];
        z=reshape(x,s2);
        for i=1:size(z,1)        
            for j=1:size(z,3)        
                z(i,:,j)=lowpassFilter(squeeze(z(i,:,j)),FS,f);    
            end
        end
    
    z=reshape(z, s1);
end