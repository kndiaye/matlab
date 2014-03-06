function [capt]=decours(chnames, data, imod, allcond, PlotLat, Filtering, Ncond)
% decours(chnames, data[, imod,allcond,PlotLat, Filtre])
% Affiche les décours du signal sur une liste de capteurs
% en fonction de la durée de stimulation
% data est au format data.G, data.Channel
% ex. decours({'mrt14'} , data)
% Si chnames est une 'cell' sur plusieurs lignes, 'decours' affiche les MOYENNES 
% des capteurs sur chaque ligne
% 
% > allcond = 1 pour avoir les plots sur la meme figure
% > imod = 1 pour l'auditif seul, 2 pour visuel, 3:les deux [bugge !], 0:demande
% > PlotLat = 1 pour qu'il place un ppoint sur la latence sur max
% > Filtre = 1 : slidingwindows, 2: lpass, 0:none

COLORS={[0 0 0], [ .2 .7 .2], [0 0 1], [1 0 1] , [1 0 0]};
COL2={[1 0 0], [0 1 0], [0 0 1]};
global CONDS
CONDS={'TC', 'C','S','L','TL'} ;
CONDS={'C', 'IC','S','IL','L'} ;
MODAL={'Auditory' 'Visual'};

if nargin < 2
    return
end
if nargin < 4
    % Graphs on the same figure
    allcond=1;
end

if nargin < 5 
    PlotLat=0;
end
if nargin < 6 
    Filtering=0;
end

if nargin < 7 
    Ncond=5;
end
disp(fprintf('%d conditions', Ncond));

if isfield(data,'Time')    
    Time=data.Time;
else
    global Time
end

if ~iscell(chnames) & ischar(chnames)
    chnames=cellstr(chnames);
    if size(chnames,1)>1    
        chnames=chnames';
    end
end

if isfield(data,'G') & iscell(data.G)
    if nargin<3 
        ButtonName=questdlg('Which modality?', 'Question', 'Auditory','Visual', 'Both', 'cancel');   
        switch ButtonName,
        case 'Auditory', 
            F=data.G{1};
            imod=1;
        case 'Visual',
            F=data.G{2};
            imod=2;
        case 'Both',
            imod=3;
        otherwise
            return
        end % switch
    else
        F=data.G{imod};
    end
elseif isfield(data,'F')
    F=data.F;
    data.G=F;
end

if isfield(data,'F')
    data=rmfield(data,'F');
end

if ischar(chnames)
    chnames=cellstr(chnames);
end
if isnumeric(chnames)
    chnames={data.Channel(chnames).Name};
end
if size(chnames,1)>1
    % Dans le cas où l'on veut avoir des groupes d'électrodes on les
    % indique en colonnes

    num=1:size(chnames,1);    
    for j=num
        id=whichChannel(chnames(j,:), data.Channel, 'exact');
        disp(sprintf('Averaging %d electrodes', length(id)))

        if ~allcond & chnames{j,1}(1)=='M'
            rev=1-2*(chnames{j,:}(2)=='L')
            % reverse signal for meg !            
            switch ndims(F)
            case 3
                data.F(j,:,:)=rev*mean(F(id,:,:),1);
            case 2
                data.F(j,:)=rev*mean(F(id,:),1);
            end
        else
            switch ndims(F)
            case 3
                data.F(j,:,:)=mean(F(id,:,:),1);
            case 2
                data.F(j,:)=mean(F(id,:),1);
            end
        end
        
        chnames2{j}=sprintf('Group.%d',j);
    end
    
    chnames2{1}='Right electrodes';
    chnames2{2}='Left electrodes';
    if size(chnames,2)>1
        chnames=chnames2;                   
    end
else
    num=1:length(chnames);
    for j=num
        id=whichChannel(chnames(j), data.Channel, 'exact');
        
        disp(sprintf('Averaging %d electrodes', length(id)))
        switch ndims(F)
            case 3
                data.F(j,:,:)=mean(F(id,:,:),1);
            case 2
                data.F(j,:)=mean(F(id,:),1);
            end
        end
    
end

if Filtering
    disp('Filtering data')
    switch Filtering
        case 1,
            disp('Sliding windows')
            data.F=slidingwindows(data.F);
        case 2,
            disp('Low Pass')
            data.F=lpass(data.F);
        case 3
            filter=20;
            disp(sprintf('Low Pass %fHz', filter));
            data.F=lpass(data.F, filter);            
        otherwise
            filter=Filtering;
            disp(sprintf('Low Pass %fHz', filter));
            data.F=lpass(data.F, filter);            
    end
end


if ~allcond
    for j=1:size(data.F,3)
        f(j)=figure(j);
        clf
        hold on
    end
else
    for j=num
        f(j)=figure;
        clf
        hold on
    end
end

set(f,'Color', [1 1 1])

for j=num
    p=[];
    if allcond            
        % Une figure par channel, plusieurs cond sur la meme
        figure(f(j));
        set(f(j), 'Name', chnames{j});
        ax(j)=gca;
        set(gca, 'Fontsize', 15)
        if Ncond==3
            p=plot3cond(squeeze(data.F(j,:,:)));
        else    
            p=plot5cond(squeeze(data.F(j,:,:)));
        end
        if PlotLat
            addPlotLat(data.F(j,:,:));
        end
        
        hold off
        if ~isfield(data, 'Title')
            titletxt{j}=[MODAL{imod} ' - '  chnames{j}];
        else
            titletxt{j}=[data.Title chnames{c}];
            
        end
        legtxt=CONDS;
        
    else
        % Same figure for different channels, one figure by condition
        for d=1:size(data.F,3)                  
            figure(f(d));            
            set(f(d), 'Name', ['Condition: ' CONDS{d}]);
            F=data.F(j,:,d); %ipermute(lpass(permute(data.F(j,:,d),[1 3 2]),4),[1 3 2]);
            p=[p plot(Time, F)];
            ax(d)=gca;
            if ~isfield(data, 'Title')
                titletxt{d}=[MODAL{imod} ' - ' CONDS{d}];
            else
                titletxt{d}=[data.Title CONDS{d}]
            end
            
        end
        legtxt=chnames;
        set(p,'Color', COL2{j}) 
        set(p,'LineWidth', 2)
            
    end
end
if size(data.F,2)==938
    set(ax, 'XLim', [-0.1 1.4])
end
for a=1:length(ax)
    if max(abs(get(ax(a), 'YLim')))<1e-10
        axes(ax(a))
        ylabel('Magnetic Field (T)')
    elseif max(abs(get(ax(1), 'YLim')))<1e-4
        axes(ax(a))        
        ylabel('Electric Potential (V)')
        set(ax(a),'YDir', 'reverse')
    end
    
    settitle(ax(a), titletxt{a});
    h=legend(legtxt);
    set(h,'Position',  [0.83    0.70    0.1643    0.2869])
end



function []=settitle(h,t)
global CONDS
axes(h)
ttl=title([t],'FontSize', 14);
posttl=get(ttl, 'Position');
set(ttl, 'Position', [0.7 posttl(2) posttl(3)])
xlabel('Time')
xlim=[-0.1 1.4];
set(gca, 'xlim', xlim)
set(gca, 'xgrid', 'on')
set(gca, 'Box', 'on')
hold on
plot(xlim, xlim*0,':','Color', [.5 .5 .5])        
hold off