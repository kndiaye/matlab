function mergedata()

for istud=1:3
  studyname=sprintf('debcrise%d-long',istud) 
  local=sprintf('/tmp/epil/debcrise%d-long.ds/',istud)
    switch(istud)
     case 1
      distal='/epilepsie/data/EPILEPSIE/03Mar18/PART1/debcrise1-long.ds/'
      Time=84+(cumsum(ones(1,12500))-1)*8e-4;
     case 2
      distal='/epilepsie/data/EPILEPSIE/03Mar18/PART2/debcrise2-long.ds/'
      Time=33+(cumsum(ones(1,12500))-1)*8e-4;	
     case 3
      distal='/epilepsie/data/EPILEPSIE/03Mar18/PART2/debcrise3-long.ds/'
      Time=106+(cumsum(ones(1,12500))-1)*8e-4;	
    end
  F=[];
  ChannelFlag=[];
  
  if 0
    for i=1:10
      clear d
      f=fullfile(distal, sprintf('%s_data_trial_%d.mat',studyname, i));
      disp(sprintf('Loading... %s',f));
	  d=load(f);
      F=[F d.F(:,1:end-1)];    
      ChannelFlag=d.ChannelFlag;
      Time=[Time, d.Time(1:end-1)];
      disp(sprintf('Saving... %s',studyname));
	  save(sprintf('%s%s_data_trial_0.mat', local,studyname),'F', 'ChannelFlag', 'Time' )
    end
    F=[F d.F(:,end)];
    % Time=[Time, d.Time(end)];
    save(sprintf('%s%s_data_trial_0.mat', local,studyname),'F', 'ChannelFlag', 'Time' )
    copyfile(sprintf('%ssensor_result.mat', distal),sprintf('%s', local)) 
    copyfile(sprintf('%s%s_brainstormstudy.mat', distal,studyname),sprintf('%s', local)) 
    copyfile(sprintf('%s%s_channel.mat', distal,studyname),sprintf('%s', local))  
  end
  save(sprintf('%s%s_data_trial_0.mat', local,studyname),'-APPEND', 'Time' )
  end
return
