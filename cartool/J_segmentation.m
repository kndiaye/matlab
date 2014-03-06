function [GFP,DE,indm,indM,DEm]=J_segmentation(flowc,graphe,Time,tstim,tend,GFP)

if nargin<3
    Time=flowc.t;
    [m,tstim]=min(abs(Time));

    DE=sqrt(flowc.de);
    nF=size(flowc.F,1);
    GFP=sqrt(sum((flowc.F-repmat(mean(flowc.F),nF,1)).^2,1));
    % DE modifié par la moyenne des champs de vitesse

    nV=size(flowc.V,1);
    for tt=1:size(flowc.V,3)
        V=flowc.V(:,:,tt);

        mV=mean(V);
        DEm(tt)=sqrt(sum((V(:,1)-mV(1)).^2) + sum((V(:,2)-mV(2)).^2) + sum((V(:,3)-mV(3)).^2));
    end

else
    DEm=sqrt(flowc);
end



%%%%%%%%%%%%%%%%%
% Vizualisation %
%%%%%%%%%%%%%%%%%

[mval,indm]=lmin(DEm,3);
[Mval,indM]=lmax(DEm,3);

if graphe
    figure
    plot(Time,DEm,'Color',[0 0 0])
    hold on
    if nargin==6
    figure(2)
    plot(Time,GFP,'Color',[0 0 0])
    hold on
    end
end

goodm=find(indm>tstim & indm<tend);
indm=indm([goodm(1)-1 goodm]);
goodM=find(indM>tstim & indM <tend);
indM=indM([goodM(1)-1 goodM]);

indices=[indm indM tend;zeros(1,length(indm)) ones(1,length(indM)) -1];

indices=sortrows(indices')';

sep_indices=zeros(length(indices),1);
sep_indices(1)=tstim;
stable_state=[];
trans_state=[];

for tt=2:length(indices)-1
    ind_tt=indices(1,tt);
    ind_ttp=indices(1,tt+1);
    [t1,t2]=intermediate_values(DEm,ind_tt,(DEm(ind_tt)+DEm(ind_ttp))/2);

    sep_indices(tt)=t2;

    if tt==2
        [t1,t2]=intermediate_values(DEm,ind_tt,(DEm(ind_tt)+DEm(indices(1,tt-1)))/2);
    else
        t1=sep_indices(tt-1);
    end
    if indices(2,tt)==1
        type='r';
        trans_state=[trans_state;sep_indices(tt-1) sep_indices(tt)];
    else
        type='b';
        stable_state=[stable_state;sep_indices(tt-1) sep_indices(tt)];
    end
    if graphe

        area(Time(t1:t2),DEm(t1:t2),'FaceColor',type)
        if nargin==6
            figure(2)
            area(Time(t1:t2),GFP(t1:t2),'FaceColor',type)
        end
    end
end

if graphe

    xlim([Time(tstim) Time(end)])

    if nargin==6
        figure(2)
        xlim([Time(tstim) Time(end)])
    end
end

% Boundaries of temporal interval

if stable_state(1,1)<=tstim
    if stable_state(1,2)<=tstim
        stable_state=stable_state(2:end,:);
    else
        stable_state(1,1)=tstim;
    end
end

if trans_state(1,1)<=tstim
    if trans_state(1,2)<=tstim
        trans_state=trans_state(2:end,:);
    else
        trans_state(1,1)=tstim;
    end
end

indm=indm(2:end);
indM=indM(2:end); % only indices > tstim

% OUTPUTS
if nargin<3


else
    GFP=stable_state;
    DE=trans_state;
    DEm=0;
end
%%%%%%%%%%%%%%%%
% Subfunctions %
%%%%%%%%%%%%%%%%

function [tm,tM]=intermediate_values(curve,ind,thres)
% Find the nearest indices before and after ind such that curve==thres
tm=ind;
tM=ind;

if curve(ind)<thres

    while curve(tm)<thres & tm>1
        tm=tm-1;
    end

    while curve(tM)<thres & tM<length(curve)
        tM=tM+1;
    end

else
    
    while curve(tm)>thres & tm>1
        tm=tm-1;
    end

    while curve(tM)>thres & tM<length(curve)
        tM=tM+1;
    end
    
end

function [lmval,indd]=lmax(xx,filt)
%LMAX 	[lmval, indd]=lmax(xx,filt). Find local maxima in vector XX,where
%	LMVAL is the output vector with maxima values, INDD  is the 
%	corresponding indexes, FILT is the number of passes of the small
%	running average filter in order to get rid of small peaks.  Default
%	value FILT =0 (no filtering). FILT in the range from 1 to 3 is 
%	usially sufficient to remove most of a small peaks
%	For example:
%	xx=0:0.01:35; y=sin(xx) + cos(xx ./3); 
%	plot(xx,y); grid; hold on;
%	[b,a]=lmax(y,2)
%	 plot(xx(a),y(a),'r+')
%	see also LMIN, MAX, MIN
	
%**************************************************|
% 	Serge Koptenko, Guigne International Ltd., |
%	phone (709)895-3819, fax (709)895-3822     |
%--------------06/03/97----------------------------|

x=xx;
len_x = length(x);
fltr=[1 1 1]/3;
if nargin <2, filt=0;
else
    x1=x(1); x2=x(len_x);
    for jj=1:filt,
        c=conv(fltr,x);
        x=c(2:len_x+1);
        x(1)=x1;
        x(len_x)=x2;
    end
end
lmval=[]; indd=[];
i=2;		% start at second data point in time series
while i < len_x-1,
    if x(i) > x(i-1)
        if x(i) > x(i+1)	% definite max
            lmval =[lmval x(i)];
            indd = [ indd i];
        elseif x(i)==x(i+1)&x(i)==x(i+2)	% 'long' flat spot
            %lmval =[lmval x(i)];  	%1   comment these two lines for strict case
            %indd = [ indd i];	%2 when only  definite max included
            i = i + 2;  		% skip 2 points
        elseif x(i)==x(i+1)	% 'short' flat spot
            %lmval =[lmval x(i)];	%1   comment these two lines for strict case
            %indd = [ indd i];	%2 when only  definite max included
            i = i + 1;		% skip one point
        end
    end
    i = i + 1;
end
if filt>0 & ~isempty(indd),
    if (indd(1)<= 3)|(indd(length(indd))+2>length(xx)),
        rng=1;	%check if index too close to the edge
    else rng=2;
    end
    for ii=1:length(indd), 	% Find the real maximum value
        [val(ii) iind(ii)] = max(xx(indd(ii) -rng:indd(ii) +rng));
        iind(ii)=indd(ii) + iind(ii)  -rng-1;
    end
    indd=iind; lmval=val;
else
end




function [lmval,indd]=lmin(xx,filt)
%LMIN 	function [lmval,indd]=lmin(x,filt)
%	Find local minima in vector X, where LMVAL is the output
%	vector with minima values, INDD is the corresponding indeces 
%	FILT is the number of passes of the small running average filter
%	in order to get rid of small peaks.  Default value FILT =0 (no
%	filtering). FILT in the range from 1 to 3 is usially sufficient to 
%	remove most of a small peaks
%	Examples:
%	xx=0:0.01:35; y=sin(xx) + cos(xx ./3); 
%	plot(xx,y); grid; hold on;
%	[a b]=lmin(y,2)
%	 plot(xx(a),y(a),'r+')
%	see also LMAX, MAX, MIN
	
%
%**************************************************|
% 	Serge Koptenko, Guigne International Ltd., |
%	phone (709)895-3819, fax (709)895-3822     |
%--------------06/03/97----------------------------|

x=xx;
len_x = length(x);
fltr=[1 1 1]/3;
if nargin <2, filt=0;
else
    x1=x(1); x2=x(len_x);

    for jj=1:filt,
        c=conv(fltr,x);
        x=c(2:len_x+1);
        x(1)=x1;
        x(len_x)=x2;
    end
end

lmval=[];
indd=[];
i=2;		% start at second data point in time series

while i < len_x-1,
    if x(i) < x(i-1)
        if x(i) < x(i+1)	% definite min
            lmval =[lmval x(i)];
            indd = [ indd i];

        elseif x(i)==x(i+1)&x(i)==x(i+2)	% 'long' flat spot
            %lmval =[lmval x(i)];	%1   comment these two lines for strict case
            %indd = [ indd i];	%2 when only  definite min included
            i = i + 2;  		% skip 2 points

        elseif x(i)==x(i+1)	% 'short' flat spot
            %lmval =[lmval x(i)];	%1   comment these two lines for strict case
            %indd = [ indd i];	%2 when only  definite min included
            i = i + 1;		% skip one point
        end
    end
    i = i + 1;
end

if filt>0 & ~isempty(indd),
    if (indd(1)<= 3)|(indd(length(indd))+2>length(xx)),
        rng=1;	%check if index too close to the edge
    else rng=2;
    end

    for ii=1:length(indd),
        [val(ii) iind(ii)] = min(xx(indd(ii) -rng:indd(ii) +rng));
        iind(ii)=indd(ii) + iind(ii)  -rng-1;
    end
    indd=iind; lmval=val;
else
end