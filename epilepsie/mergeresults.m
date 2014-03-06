function mergeresults()
% Fusionne les donnees epilepsie du sujet bern en 1 seul gros fichier  
  for istud=1:3
    ImageGridAmp=single(zeros(12501,10569));	
    studyname=sprintf('debcrise%d-long',istud)
    local=sprintf('/tmp/epil/debcrise%d-long.ds/',istud)
    switch(istud)
     case 1
      distal='/epilepsie/data/EPILEPSIE/03Mar18/PART1/debcrise1-long.ds/'
      ImageGridTime=84+(cumsum(ones(1,12500))-1)*8e-4;
     case 2
      distal='/epilepsie/data/EPILEPSIE/03Mar18/PART2/debcrise2-long.ds/'
      ImageGridTime=33+(cumsum(ones(1,12500))-1)*8e-4;
     case 3
      distal='/epilepsie/data/EPILEPSIE/03Mar18/PART2/debcrise3-long.ds/'
      ImageGridTime=106+(cumsum(ones(1,12500))-1)*8e-4;	
    end 
    %f=dir(sprintf('*_data_trial_1.mat'));
    %studyname=f(1).name(1:findstr('_data_trial_',f(1).name)-1);
    %data=load(f(1).name, 'Time');
    if 1
      for i=1:10      
	clear d
	pack;
	T=((i-1)*1250+1):i*1250;
	f=dir(sprintf('%s*_data_trial_%d_MNE_*.mat',distal,i));
	disp(sprintf('Loading... %s',f(1).name));
	    d=load([distal f(1).name], 'ImageGridAmp');
	ImageGridAmp(:,T)=single(d.ImageGridAmp(:,1:end-1));
	disp(sprintf('Saving... %s',studyname));
	% save(sprintf('%s%s_data_trial_0_MNE_MEGresults.mat', local,studyname),'ImageGridAmp')   		
      end
      ImageGridAmp(:,12501)=single(d.ImageGridAmp(:,end));
      %ImageGridTime=getfield(load(sprintf('%s%s_data_trial_0.mat',local, studyname), 'Time'),'Time');
      save(sprintf('%s%s_data_trial_0_MNE_MEGresults.mat', local,studyname),'ImageGridAmp','ImageGridTime')    
      
    end

    SourceLoc=[];
    Comment=studyname;
    save(sprintf('%s%s_data_trial_0_MNE_MEGresults.mat', local, ...
		 studyname),'-APPEND','SourceLoc', 'Comment', 'ImageGridTime')    
        
  end
  
  return
  