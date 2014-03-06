cd('D:\ndiayek\data\rings')
x=load('random02-Tr18_data_trial_1');
c=load('random02-Tr18_channel.mat');
[y,ic]=getMEGChannels(c.Channel);
f=x.F(i,:);

fid = fopen('random02-Tr18_data_trial_1.ep','wt');
for t=1:2125
    for i=1:151
    fprintf(fid,'%g ',f(i,t));
    end
    fprintf(fid,'\n');
end

fclose(fid);
        