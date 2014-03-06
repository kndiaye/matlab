function view_minnorm_cb(action);
% VIEW_MINNORM_CB Callback for viewing minimum norm solutions
% function view_minnorm_cb(action);
% Call with no arguments to build gui.

% John C. Mosher, Ph.D., See Copyright.m file for information.
% $Date: 4/19/01 6:15a $ $Revision: 4 $
% Additions:
% 
%
% 04-03-01
% Sylvain Baillet - CNRS-UPR640 
% Added orthogonal views button and callbacks
%

if(~exist('action','var')),
    action = 'build';
end

hf = gcbf; % who called me

switch deblank(lower(action))
case 'build'
    open('view_minnorm_cb.fig');
    
case 'reset'
    % Reset all of the buttons to initial values, refresh the studies list
    % Objects:  AxisStudy, AxisSignal, AxisNoise, AxisSVD
    %  EditMinTime, EditMaxTime, EditRank, EditCorr, EditReg
    %  SliderRank, SliderCorr,
    %  PopupSVD, PopupReg, PopupOrder, ExecuteRAP
    
    % Set the menu action
    
    hur = findobj(hf,'Tag','UimenuReset'); % handle of uimenu for reseting
    hud = findobj(hf,'Tag','UimenuDataSets');
    hub = findobj(hf,'Tag','UimenuBSTStudy'); % the studies
    delete(hur);
    delete(hud);
    delete(hub);
    
    find_brainstorm_files('studies',[],hf); % restablish the menu
    hub = findobj(hf,'Tag','UimenuBSTStudy'); % the studies created by that call
    % now create a menu to find the datasets for those studies
    hud = uimenu('Label','DataSets','Tag','UimenuDataSets');
    % and the call to reset this gui
    hur = uimenu('Label','Reset GUI','Tag','UimenuReset',...
        'Callback','view_minnorm_cb(''reset'')');  
    
    % So the studies menu has a list of StudySubjects to write to UserData
    % now append to each study menu callback a datasets menu action
    hub1 = get(hub,'children'); % what are all of the studies
    %  hub1r = findobj(hub1,'Label','Refresh Studies');
    %  hub1(find(hub1==hub1r)) = []; % don't update the refresher child
    
    for i = 1:length(hub1), % each submenu of the study menu
        cb = get(hub1(i),'Callback');
        % datamenu will make a menu of data sets for min norm
        set(hub1(i),'Callback',[cb 'viewminnormdatamenu;']);
    end
    
    %So the menus are rebuilt.  Now for the other objects. Activate all of them
    TAGS = {'AxisStudy', 'AxisSeries', 'AxisView'};
    
    for i = 1:length(TAGS),
        
        axes(findobj(hf,'Tag',TAGS{i}));
        cla reset
        set(gca,'Tag',TAGS{i},'Units','Normalized');    % set tag back in
        box on
        
        if i==3 
            set(gca,'color',[.35 .35 .35])       
            set(gca,'Xtick',[],'Ytick',[])
        end
        
        set(gca,'xcolor',[.7 .7 0],'ycolor',[.7 .7 0]);
        axis on
        grid off
        
    end
    
    hm = findobj(gcf,'Label','Toggle Face');
    delete(hm)
    hm = findobj(gcf,'Label','Toggle Lighting');
    delete(hm)
    
    uimenu(gcf,'Label','Toggle Face','callback','toggleface(get(gcbo,''UserData''))','UserData',[]);
    uimenu(gcf,'Label','Toggle Lighting','callback','togglelight(get(gcbo,''UserData''))','UserData',[]);
    
    
    % end of reset
    
case 'view data'
    % user has clicked on some data in the data menu.
    ht = findobj(0,'Tag','TASKBAR');
    UD = get(ht,'UserData'); % get the userdata
    % interested in StudySubject information and DataName string
    Results = load_brainstorm_file(UD.DataName);
    
    if(~isempty(findstr('_results',deblank(lower(Results.GUI.DataName))))), 
        % CHEAT
        % The DataName has the string '_results' in it
        % We are trying to view independent topographies as min norm data. Eventually this
        %  capability will be moved to a new routine.
        OrgData= load(Results.GUI.DataName); % the original data 
        % now synthesize a Data structure from this
        [ignorm,Anrm] = colnorm(OrgData.IndepTopo);
        Data = struct('F',Anrm,'Channel',OrgData.Channel,...
            'Time',[1:size(OrgData.IndepTopo,2)],... % time is now simply an indexer
            'NoiseCov',OrgData.NoiseCov,'SourceCov',OrgData.SourceCov,'Projector',OrgData.Projector,...
            'Comment',sprintf('Synthesized Data Set from Results: %s',OrgData.Comment));
        GoodChannel = [1:size(Anrm,2)]; % all channels good in the IndepTopo
    else
        % CHEAT
        % the GUI.DataName does not have the word "results" in it, so we are viewing legitimate
        %  minimum norm results. In the future, we might key in on the letters "mn" , for instance
        % assume it is a data file
        User = get_user_directory;
        cd(User.STUDIES)
        Data = load(Results.GUI.DataName,'F','Channel','Time','Projector','Comment');
        Channel = load(Results.StudySubject.Channel);
        Channel = Channel.Channel; 
        GoodChannel = good_channel(Channel,Results.ChannelFlag,'MEG');

        % CHEAT SILVIN
        %GoodChannel = good_channel(Channel,Results.ChannelFlag,'EEG');
        %% CHEAT, show data and residual in a separate window for now
        figure(windfind(sprintf('MinNorm Data and Residuals: %s',Results.GUI.DataName)))
        windclf
        plot([Data.F(GoodChannel,Results.Time) Results.Fsynth Data.F(GoodChannel,Results.Time)-Results.Fsynth]');
        title(sprintf('%s: Data, Synth, Resid',Results.GUI.DataName),'interpreter','none')
        drawnow  
        
    end
    
    ha = findobj(hf,'Tag','AxisStudy');
    axes(ha)
    cla
    line(1000*Data.Time(Results.Time),Data.F(GoodChannel,Results.Time)')
    title(Data.Comment)
    axis tight
    grid on
    
    % now we can only handle a couple hundred lines
    MAXLINE = 500;
    MAXLINE = min(MAXLINE,size(Results.ImageGridAmp)); % in case there are fewer sources
    AmpNrm = rownorm(Results.ImageGridAmp);
    [ignore,iAmpNrm] = sort(AmpNrm);
    iAmpNrm = iAmpNrm(end:-1:1); % biggest to smallest
    
    ha = findobj(hf,'Tag','AxisSeries');
    axes(ha)
    cla
    line(1000*Data.Time(Results.Time),Results.ImageGridAmp(iAmpNrm(1:MAXLINE),:)')
    axis tight
    grid on
    
    [ignore,GUI.iTime] = max(max(abs(Results.ImageGridAmp(iAmpNrm(1:MAXLINE),:)))); 
    % gives us the max time index
    
    V = axis; % what's the settings
    UD = struct('iTime',GUI.iTime,'Time',Data.Time(Results.Time));
    % iTime is the integer time index in the array of data. Time is the time in engineering units
    hline = line(1000*[UD.Time(UD.iTime);UD.Time(UD.iTime)],[V(3);V(4)],'Color','b','linewidth',2);
    set(ha,'UserData',setfield(UD,'hline',hline));
    
    drawnow
    
    view_minnorm_gui(Results,GUI)
    
    hpatch = findobj(gca,'Type','patch'); % find the patch
    set(hpatch,'FaceLighting','flat'); % much faster rendering
    hm = findobj(gcf,'Label','Toggle Face');
    set(hm,'UserData',hpatch);
    hm = findobj(gcf,'Label','Toggle Lighting');
    set(hm,'UserData',hpatch);
    
    
    hud = findobj(hf,'Tag','UimenuDataSets');
    set(hud,'UserData',Results); % set results into ram
    
    rotate3d on
    axis vis3d % freeze the size for three d rotation
    
case 'set time'
    ha = findobj(hf,'Tag','AxisSeries');
    UD = get(ha,'UserData');
    % UD.Time tells us where we are in true unit
    set(UD.hline,'Xdata',[1000 1000]*UD.Time(floor(UD.time_scale *(UD.iTime-1)+1))); % move it
    axes(ha);
    xlabel(sprintf('Time: %7.1f',1000*UD.Time(floor(UD.time_scale *(UD.iTime-1)+1))));
    
case 'scale_colormap'
    % let the user adjust the color scaling for greater saturation
    hv = findobj(hf,'Tag','AxisView');
    axes(hv); % set to the current figure
    org_caxis = caxis; % what is the color axis
    ScaleFactor = inputdlg('Enter Caxis Scaling Factor','BrainStorm Movie Maker',[1 50],{'1'});
    ScaleFactor = str2num(ScaleFactor{:});
    %caxis(str2num(ScaleFactor{:})*org_caxis);
    cmap_orig = grayish(hot(128),.33);
    %cmap_orig(1:round(size(cmap_orig,1)/5),:) = brighten(round(size(cmap_orig,1)/5));
    
    ind_trim = min([128,floor(128*( 1 - exp(-(ScaleFactor-1)/6 )))+1]);
    cmap = (cmap_orig);
    cmap(1:ind_trim,:) = (repmat(cmap(1,:),length(1:ind_trim),1));
    cmap(ind_trim+1:end,:) =  (grayish(hot(size(cmap(ind_trim+1:end,:),1)),.33));
    
    hud = findobj(hf,'Tag','UimenuDataSets');
    Results = get(hud,'UserData'); % the results data
    M = max(abs(Results.ImageGridAmp(:)));
    colormap((cmap))
    caxis([0,M])
    
case 'create movie'
    hud = findobj(hf,'Tag','UimenuDataSets');
    hv = findobj(hf,'Tag','AxisView');
    hp = findobj(hv,'Type','Patch'); % get the patch
    Results = get(hud,'UserData'); % the results data
    if(isempty(Results)),
        msgbox('Load data first','Notice','modal');
        return
    end
    
    NF = getframe(hf); % the whole figure
    
    mpg_limits = size(NF.cdata); %the size of the figure
    if ((mpg_limits(1) > 480) | (mpg_limits(2) > 640)),
        ButtonName = questdlg(sprintf('Resize your window to 480 x 640?'));
        switch ButtonName
        case 'Yes'
            set(hf,'units','pixels')
            Vposition = get(hf,'Position');
            set(hf,'Position',[Vposition(1:2) 640 480]); % don't know why this translates to 480 x 640
            %NF = getframe(hf); % the whole figure again
        case 'No'
            % do nothing
        case 'Cancel'
            % user punted, so will we
            return
        end
    end
    
    
    % let the user adjust the color scaling for greater saturation
    axes(hv); % set to the current figure
    org_caxis = caxis; % what is the color axis
    if 0  
        ScaleFactor = inputdlg('Enter Caxis Scaling Factor','BrainStorm Movie Maker',[1 50],{'1'});
        caxis(str2num(ScaleFactor{:})*org_caxis);
    end
    
    
    % Check if we have enough memory 
    MovieSiz = length(Results.Time)*prod(size(NF.cdata));
    if MovieSiz > 128e6
        disp(['The memory requirement might be too large for your system : ', round(num2str(MovieSiz/1e6,'%4.0f')),' MBytes'])
        ans = input('Would you like to decimate the time series ? (Y/N) ','s');
        switch(lower(ans))
        case 'y'
            disp(['Current number of time samples: ', int2str(length(Results.Time))])
            num = input('How many time samples would you like to achieve ? : ');
            oldtime = Results.Time;
            Results.Time = linspace(Results.Time(1),Results.Time(end),num);
            time_scale = abs(Results.Time(2)-Results.Time(1))/abs(oldtime(2)-oldtime(1));
        otherwise
            % nothing
            time_scale = 1;
        end
    else
        time_scale = 1;
    end
    
    ha = findobj(hf,'Tag','AxisSeries');
    UD = get(ha,'UserData'); % get the userdata
    UD.time_scale = time_scale;
    set(ha,'UserData',UD);
    
    %[NF(1:length(Results.Time))] = (deal(NF)); % allocate memory
    
    ha = findobj(hf,'Tag','AxisSeries');
    disp(sprintf('Making movie of %.0f slices',length(Results.Time)));
    Results.ImageGridAmp = abs(Results.ImageGridAmp);
    for i = 1:length(Results.Time),
        set(ha,'UserData',setfield(get(ha,'UserData'),'iTime',i));
        view_minnorm_cb('set time') % set the time bar
        set(hp,'FaceVertexCdata',(Results.ImageGridAmp(:,floor((i-1)*time_scale+1))));
        drawnow
        disp(' ')
        % NF(i) = getframe(hf);
    end
    caxis(org_caxis); % reset the color axis back to original
    
    
    set(hv,'UserData',struct('Movie',NF));  
    msgbox('Done. You may save and/or play the movie','Make Movie','modal');
    
case 'save movie'
    ht = findobj(0,'Tag','TASKBAR');
    UD = get(ht,'UserData'); % get the userdata
    % want UD.DataName
    
    ha = findobj(hf,'Tag','AxisView');
    UD1 = get(ha,'UserData');
    % want the movie
    if(~isfield(UD1,'Movie')),
        msgbox('No movie to save','Notice','modal');
        return
    end
    
    [PATH,NAME,EXT,VER] = fileparts(UD.DataName);
    
    ButtonName = questdlg('Save as Matlab Movie or MPEG','Movie Save','Matlab','MPEG','Tiff','MPEG');
    switch ButtonName
    case 'Matlab'
        EXT = '.mat';
    case 'MPEG'
        EXT = '.mpg';
    case 'Tiff'
        EXT = '.tif';
    end
    
    cd(PATH);
    switch  ButtonName
    case {'Matlab' 'MPEG'}
        [NAME,PATH] = uiputfile([NAME '_movie' EXT],'Save the Movie information');
    case 'Tiff'
        [NAME,PATH] = uiputfile([NAME '_movie' EXT],'Establish a Tif Root Name');
    end
    
    if(~NAME), % user punted
        return
    end
    
    Movie = UD1.Movie;
    switch ButtonName
    case 'Matlab'
        save(fullfile(PATH,NAME),'Movie');
    case 'MPEG'
        % note that in Matlab 5.3, the colormap is bogus in mpgwrite
        mpgwrite(Movie,hot(64),fullfile(PATH,NAME));
    case 'Tiff'
        [PATH,NAME,EXT,VER] = fileparts(NAME); % knock the extension back off
        for i = 1:length(Movie)
            imwrite(frame2im(Movie(i)),fullfile(PATH,sprintf('%s_%03.0f.tif',NAME,i)),'tif');
        end
    end
    
    msgbox('Done Saving','BrainStorm Movie Maker','modal');
    
case 'load movie'
    [NAME,PATH] = uigetfile('*movie.mat','Load the Matlab Movie File');
    if(NAME==0),
        return
    end
    
    UD = load(fullfile(PATH,NAME));
    if(~isfield(UD,'Movie')),
        msgbox('No movie to load','Notice','modal');
        return
    end
    ha = findobj(hf,'Tag','AxisView');
    set(ha,'UserData',setfield(get(ha,'UserData'),'Movie',UD.Movie));
    
    
case 'play movie'
    ha = findobj(hf,'Tag','AxisView');
    UD1 = get(ha,'UserData');
    % want the movie
    if(~isfield(UD1,'Movie')),
        msgbox('No movie to play','Notice','modal');
        return
    end
    movie_player(UD1.Movie);
    
    
case 'orthoviews'
    %delete(findobj(gcf,'Type','Light'));
    ha = findobj(gcf','Tag','AxisView');
    hp = findobj(ha,'Type','Patch');
    ha1=  findobj(gcf','Tag','axsub1');
    ha2=  findobj(gcf','Tag','axsub2');
    ha3=  findobj(gcf','Tag','axsub3');
    ha4=  findobj(gcf','Tag','axsub4');
    hps= findobj([ha1,ha2,ha3,ha4],'Type','Patch');
    
    TAG = get(gcbo,'Userdata');
    
    if isempty(TAG)|TAG == 1
        TAG = 0;
        %set(ha,'Visible','off')
        if isempty(hps)
            hps=  copyobj([hp,hp,hp,hp],[ha1,ha2,ha3,ha4]);
            axes(ha1), view(-180, 90), axis equal, axis off, camlight
            axes(ha2), view(-180, 0), axis equal, axis off, camlight
            axes(ha3), view(-90, 0), axis equal, axis off, camlight
            axes(ha4), view(0, 0), axis equal, axis off, camlight
        else
            set(hps,'visible','on')
        end
        set(hp,'visible','off')
    else
        TAG = 1;
        set(hps,'visible','off')
        set(hp,'visible','on')
    end
    set(gcbo,'Userdata',TAG);

case 'normalize_colormap' % Normalize colormap to maximum
    ha(1) = findobj(gcf','Tag','AxisView');
    ha(2)=  findobj(gcf','Tag','axsub1');
    ha(3)=  findobj(gcf','Tag','axsub2');
    ha(4)=  findobj(gcf','Tag','axsub3');
    ha(5)=  findobj(gcf','Tag','axsub4');
    
    hps= findobj(gcbf,'Type','Patch');
    hps = hps(1);
    crtx_amp = get(hps,'FaceVertexCData');
    set(ha,'clim',[0 max(crtx_amp)]);
    
    
case 'gotime' % Map the current map at a specified time instant
    gotime = findobj(gcf','Tag','gotime');
    time = str2num(get(gotime,'String'))/1000;
    
    ht = findobj(0,'Tag','TASKBAR');
    h = findobj(gcf,'Type','Patch');    
    Results = get(h(1),'Userdata');
    if isempty(Results)
        UD = get(ht,'UserData'); % get the userdata
        cd(UD.Users.STUDIES)
        Results = load(UD.DataName,'ImageGridTime','ImageGridAmp');
        set(h(1),'Userdata',Results)
    end
    
    [mm, itime] = min(abs(Results.ImageGridTime - time));
    Results.ImageGridAmp = Results.ImageGridAmp(:,itime);
    set(h,'FaceVertexCData',abs(Results.ImageGridAmp))
        
    ha = findobj(gcf,'Tag','AxisSeries');
    axes(ha)
    UD = get(ha,'UserData');
    set(UD.hline,'Xdata',[Results.ImageGridTime(itime)...
            Results.ImageGridTime(itime)]*1000)
    
end



return
