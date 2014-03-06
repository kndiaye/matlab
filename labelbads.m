function [Bads]=labelbads(ctfdata)
% labelbads - label as BAD channels / trials / channel&trial

% Bads.Trials : Bad trials
% Bads.Channels : 
% Bads.TrialChannel : Isolated events


Bads=cell(1,3);

if size(ctfdata.data, 1) == ctfdata.setup.number_samples
    ctfdata.data=permute(ctfdata.data, [2 1 3]);    
end

x=ctfdata.data(ctfdata.sensor.index.eeg_sens,:,:);
sx=size(x);
figure
[h,t]=hist(abs(x(:)),10);
[i,j,k]=ind2sub(sx, find(abs(x)>t(5)));

b=zeros(sx([1 3]));
b(i,k)=1;
% b(i,1)=NaN;
pcolor(b)
ylabel('Channels')
xlabel('Trials')

x(i,j,k)=NaN;
figure
hist(abs(x(:)),100);
[h,t]=hist(abs(x(:)),10)
[i,j,k]=ind2sub(sx, find(abs(x)>t(5)));

