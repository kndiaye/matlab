function [r,cc,M,YY] = simsort(X,simfun,M)
% simsort() - Sort data based on their similarity with a model

% try 
% D=evalin('base', 'D');
% catch
% evalin('base', 'load mri');
% end
% j=[1 20 30 31  60 61 62 63 64 65 66 70 75 80 85 110 120]
% X=double(D(j,40:80,1,13));
% dbstop in simsort

if nargin<3
M=meannan(X);
end
if nargin<2
simfun = 'corrcoef2';
end
Y=M;
if nargout>4
	YY=repmat(M,size(X,1)-1,1);
end
ii=1:size(X,1);
r=NaN.*ii;
for i=1:size(X,1);
	if nargout>4
		YY(i,:)=Y;	
	end	
	Z=X(ii,:);		
	[cc(i) tmp]=max(abs(feval(simfun,Y,Z')));
	r(i) = ii(tmp)	
	ii(tmp)=[];
	se(i)=0;
	Y=meannan(X(r(1:i),:),1);
	subplot(2,1,1); cla	
	hold on; 
	plot(X(r(1:i),:)')
	plot(Y(:),'linewidth',3);
	subplot(2,1,2)
	plot(Z(:,:)');
	pause(.1)
end
%r(end)=ii;
size(Z)
abs(feval(simfun,Y,Z'))
cc(end+1)=abs(feval(simfun,Y,Z'));


%if exist('j','var');disp(j(r));end
