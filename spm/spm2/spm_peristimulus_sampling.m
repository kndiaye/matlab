function [x,h]=spm_pst_smp(RT,onsets,NV,ST,nslices)
% check sampling of the HRF 
try
    addpath('D:\mtoolbox\spm2\')
end
if nargin < 1
    RT=2.5;
end
if nargin < 2
    onsets=cumsum(2.5+rand(1,10)/10)
end
if nargin < 3
    NV=(onsets(end)+32)/2.5;
end
if nargin < 4
    ST=1;
end
if ST >= RT
    error('acquisition time can''t be longer than RT!!')
end
if isvector(onsets)
    onsets=onsets(:)';
end
figure
ha=axes;
line([0 32], [0 0], 'color','k');
hold on
t=[0:32/.15]*.15;
y=normalize(spm_hrf(.15),inf);
plot(t,y)
set(ha,'Xlim', [0 32])
% set(ha,'Xlim', [-RT*.1 RT*1.25], 'Ylim', [-.2 1.2], 'box', 'on')
% rectangle('position',[ ST 0 RT-ST .25], 'FaceColor', .85*[1 1 1]);
% line([-RT 2*RT], [0 0], 'color','k');
% x=mod(onsets,RT);
x=RT*[0:NV-1]'*ones(1,length(onsets)) - ones(NV,1)*(onsets) + ST;
% x=x(:);
% x(x>32)=[];
% x(x<0)=[];
x(x>32)=NaN;
x(x<0)=NaN;
for j=1:length(onsets)
    h(j)=plot(x(:,j),interp1(t,y,x(:,j)),'.', 'color', rand(1,3));    
end
str = sprintf('TR = %0.2f secs ',RT);
if ST>0
    str=[str sprintf('(including silent time = %0.2f secs)',ST)];
end
xlabel('time (secs)')
title(str)
return
