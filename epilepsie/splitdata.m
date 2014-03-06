function []=splitdata()
load('debcrise1-f_data_trial_0.mat')
G=F;
T=Time;

for i=1:10
    if i<10
        t=1250*(i-1)+1:1250*(i);
    else
        t=1250*(i-1)+1:1250*(i)+1;
    end

    Time=T(t)';
    F=G(:,t);
    size(Time)
    size(F)
    save(sprintf('debcrise1-f_data_trial_%d.mat', i), 'ChannelFlag', 'Comment', 'Device', 'F', 'NoiseCov', 'Projector','SourceCov', 'System', 'Time')
end


