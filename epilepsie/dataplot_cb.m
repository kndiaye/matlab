function varargout = dataplot_cb(action,varargin)
%DATAPLOT_CB : Callback switchyard for the DATAPLOT Tool
% function dataplot_cb(action)
% Callback function for the DATAVIEWER tool
%
% /---Script Author--------------------------------------\
% |                                                      |
% | *** Sylvain Baillet, Ph.D.                           |
% | Cognitive Neuroscience & Brain Imaging Laboratory    |
% | CNRS UPR640 - LENA                                   | 
% | Hopital de la Salpetriere, Paris, France             |
% | sylvain.baillet@chups.jussieu.fr                     |
% \------------------------------------------------------/
%  
% Date of creation: January 1999
% Date of modification: November 2001                  
%---------------------------------------------------------------------------------------------------------------------------
% SB, 2001-09 / revamping for compliancy with DataManager + major plastic surgery
% SB, October 2001 - Added Cortical Probes, Mapping of Curvature, Colormap Scaling of Activations
% SB - DS, November 2001 - Multiple fixings; added 0ms adjustment  to data maximum peak (useful for epileptic data analysis about the maximum of the spike)
% KND, Nov. 2003 : Changed lines 610-621 to allow MEG and EEG data plot...
% KND, Nov. 2003 : Changed line 290 to put F{1} in Data.F

frontcolor = [.4 .4 .4];
backcolor = [.8 .8 .8];
linecolor = [.4 .4 .4];
textcolor =  linecolor;
verbose = 0;% Verbose mode for Mosher's tools: 0 - off ; 1 - on

%----------------------------------------------------------------------------

DATAPLOT = openfig('dataplot.fig','reuse');

TASKBAR = findobj(0,'Tag','TASKBAR');
Users = guidata(TASKBAR);

MEG = get(findobj(DATAPLOT,'Tag','MEG'),'value');
EEG = get(findobj(DATAPLOT,'Tag','EEG'),'value');
OTHER = get(findobj(DATAPLOT,'Tag','OTHER'),'value');
current = find([MEG,EEG,OTHER] == 1);
modality = {'MEG','EEG','OTHER'};

switch action
    
case 'create'
    DATAPLOT = openfig('dataplot.fig','reuse');
    % Check for data loaded from DataManager, if exists
    if ~isfield(Users,'CurrentData') % No data was loaded using DataManager - do nothing (old way)
        set(findobj(DATAPLOT,'style','pushbutton'),'enable','off');
        set(findobj(DATAPLOT,'string','Load'),'enable','on')
        set(findobj(DATAPLOT,'string','Quit'),'enable','on')
        set(findobj(DATAPLOT,'Tag','SurfaceViewer'),'enable','on')
        return
    end
    
    % Look for datafiles in current study folder
    cd(Users.STUDIES);
    [studypath,file,ext] = fileparts(Users.CurrentData.StudyFile);
    cd(studypath)
    
    TestFiles = dir('*data*.mat');
    i = 0;
    for k = 1:length(TestFiles)
        if isempty(findstr(TestFiles(k).name,'results'))
            i = i+1;
            DataFiles{i} = TestFiles(k).name;
        end
    end
    if isempty(DataFiles)
        DataFiles = 'No data files in current study';
    end
        
    hDataplot = guihandles(DATAPLOT);
    set(hDataplot.DataFileList,'String',DataFiles,'Value',1,'Max',1)
    
    
    %Visu = get(DATAPLOT,'Userdata');
    if 1%isempty(Visu)
        dataplot_cb('loaddata',Users.CurrentData.StudyFile,Users.CurrentData.DataFile);
    end
    
    %----------------------------------------------------------------------------
    
    
case 'mutincomp_cmapping' % Mutually icompatible checkboxes
    mapping_win = findobj(0,'Tag','mapping'); 
    MEG = findobj(mapping_win ,'Tag','ABSOLUTE');
    EEG = findobj(mapping_win ,'Tag','RELATIVE');
    mutincomp([MEG,EEG])
    h = findobj([MEG,EEG],'Value',1); 
    if length(h)>1
        set(h(2),'Value',0) 
    end   
    %----------------------------------------------------------------------------
    
case 'mutincomp_colormap' % Mutually icompatible checkboxes
    mapping_win = findobj(0,'Tag','tesselation_select'); 
    MEG = findobj(mapping_win ,'Tag','Normalize');
    EEG = findobj(mapping_win ,'Tag','FreezeColormap');
    mutincomp([MEG,EEG])
    h = findobj([MEG,EEG],'Value',1); 
    if length(h)>1
        set(h(2),'Value',0) 
    end   
   
    %----------------------------------------------------------------------------
case 'mutincomp_meanmax' % Mutually icompatible checkboxes
    mapping_win = findobj(0,'Tag','tesselation_select'); 
    MEG = findobj(mapping_win ,'Tag','MeanCorticalArea');
    EEG = findobj(mapping_win ,'Tag','MaxCorticalArea');
    OTHER = findobj(mapping_win ,'Tag','AllCorticalArea');
    
    mutincomp([MEG,EEG,OTHER])
    h = findobj([MEG,EEG,OTHER],'Value',1); 
    if length(h)>1
        set(h(2:end),'Value',0) 
    end   
    %----------------------------------------------------------------------------
case 'mutincomp_opaque' % Mutually icompatible checkboxes
    MEG = findobj(gcbf,'Tag','Opaque');
    EEG = findobj(gcbf,'Tag','transparent');
    mutincomp([MEG,EEG])
    h = findobj([MEG,EEG],'Value',1); 
    if length(h)>1
        set(h(2),'Value',0) 
    end   
    dataplot_cb mesh_vals 
    %----------------------------------------------------------------------------
    
case 'mapping_type' % Mutually icompatible checkboxes
    mapping_win = findobj(0,'Tag','mapping'); 
    MEG = findobj(mapping_win ,'Tag','raw');
    EEG = findobj(mapping_win ,'Tag','gradient');
    OTHER = findobj(mapping_win,'Tag','magnetic');
    mutincomp([MEG,EEG,OTHER])
    h = findobj([MEG,EEG,OTHER],'Value',1); 
    if length(h)>1
        set(h(2),'Value',0) 
    end   
    %----------------------------------------------------------------------------
    
case 'mapping_head_shape' % Mutually icompatible checkboxes
    mapping_win = findobj(0,'Tag','mapping'); 
    handles = guihandles(mapping_win);
    %     figure(mapping_win)
    mutincomp([handles.sphere,handles.fit,handles.scalp])
    h = findobj([handles.sphere,handles.fit,handles.scalp],'Value',1); 
    if length(h)>1
        set(h(2),'Value',0) 
    end   
    %----------------------------------------------------------------------------
    
case 'selectmodality' % Select the current signals to visualize
    MEG = findobj(DATAPLOT,'Tag','MEG');
    EEG = findobj(DATAPLOT,'Tag','EEG');
    OTHER = findobj(DATAPLOT,'Tag','OTHER');
    mutincomp([MEG,EEG,OTHER])
    h = findobj([MEG,EEG,OTHER],'Value',1); 
    if length(h)>1
        set(h(2),'Value',0) % Just one modality at a time please !
    end
    QUICKLOOK_GUI = findobj(0,'Tag','QUICKLOOK_GUI');
    if ~isempty(QUICKLOOK_GUI)
        vMEG = get(MEG,'value');
        vEEG = get(EEG,'value');
        vOTHER = get(OTHER,'value');
        current = find([vMEG,vEEG,vOTHER] == 1);
        set(QUICKLOOK_GUI,'Name',['QuickLook ',modality{current}])
    end
    
    previous  = findobj(0,'Tag','channel_select'); % Update Channel Selection Window with Current Modality
    if ~isempty(previous)
        dataplot_cb selectchannels   
    end
    
    mapping_win = findobj(0,'Tag','mapping'); 
    MEG = get(MEG,'value');
    EEG = get(EEG,'value');
    OTHER = get(OTHER,'value');
    current = find([MEG,EEG,OTHER] == 1);
    if ~isempty(mapping_win)
        set(mapping_win,'Name',[modality{current},' Mapping'])
        RAW = findobj(mapping_win ,'Tag','raw');
        GRADIENT = findobj(mapping_win ,'Tag','gradient');
        MAGNETIC = findobj(mapping_win,'Tag','magnetic');
        
        if current == 1 % If MEG
            set([RAW,GRADIENT,MAGNETIC],'enable','on')
            set(RAW,'Value',1)
        else
            set([RAW,GRADIENT,MAGNETIC],'enable','off')
        end
    end
    
    Visu = get(DATAPLOT,'Userdata');
    channel_select_win = findobj(0,'Tag','channel_select');
    goodchannels = setdiff([Visu.ChannelID{current}],find(Visu.Data.ChannelFlag == -1));% - min(Visu.ChannelID{current})+1; % Discard bad channels
    badchannels = intersect([Visu.ChannelID{current}],find(Visu.Data.ChannelFlag == -1));% - min(Visu.ChannelID{current})+1;
    
    removed = findobj(channel_select_win,'Tag','removed');
    available = findobj(channel_select_win,'Tag','available');
    
    
    set(available,'String', cellstr(num2str(goodchannels')));
    set(removed,'String', cellstr(num2str(badchannels')));
    
    set(available,'Value',1,'Max',length(get(available,'String')))
    set(removed,'Value',1,'Max',max([1,length(get(removed,'String'))]))
    
    %----------------------------------------------------------------------------
case 'LoadFromDataFileList' % Load from popup menu list in the DataViewer
    hDataplot = guihandles(DATAPLOT);
    iFile = get(hDataplot.DataFileList,'Value');
    FileNames = get(hDataplot.DataFileList,'String');
    
    dataplot_cb('loaddata',Users.CurrentData.StudyFile,FileNames{iFile});
 %   dataplot_cb quicklook
    
    %----------------------------------------------------------------------------
case 'LoadPrevFile' % Load previous file in the popup menu list in the DataViewer
    hDataplot = guihandles(DATAPLOT);
    iFile = get(hDataplot.DataFileList,'Value');
    FileNames = get(hDataplot.DataFileList,'String');
    
    iFile = iFile - 1;
    if iFile < 1
        iFile = 1;
        return
    end
    
    set(hDataplot.DataFileList,'Value',iFile)
    dataplot_cb('loaddata',Users.CurrentData.StudyFile,FileNames{iFile});
        
%    dataplot_cb quicklook
    
    %----------------------------------------------------------------------------
case 'LoadNextFile' % Load previous file in the popup menu list in the DataViewer
    hDataplot = guihandles(DATAPLOT);
    iFile = get(hDataplot.DataFileList,'Value');
    FileNames = get(hDataplot.DataFileList,'String');
    
    iFile = iFile + 1;
    if iFile > length(FileNames)
        iFile = length(FileNames);
        return
    end
    
    set(hDataplot.DataFileList,'Value',iFile)
    dataplot_cb('loaddata',Users.CurrentData.StudyFile,FileNames{iFile});
        
  %  dataplot_cb quicklook
    
    %----------------------------------------------------------------------------
case 'loaddata' % Only MAT BrainStorm file format is available - User has to import original data into BrainStorm otherwise
    
    TIME_MIN = findobj(DATAPLOT,'Tag','time_min');
    TIME_MAX = findobj(DATAPLOT,'Tag','time_max');
    
    datatype = 'mat';
    % Read Study File
    
    cd(Users.STUDIES);
    if nargin == 1 % Load the old-way
        [studyfile,studypath] = uigetfile(['*brainstormstudy.',datatype], 'Enter file name for the study file');
        if (studyfile)==0, return, end
        cd(studypath)
        
        [datafile,datapath] = uigetfile(['*data*.',datatype], 'Enter file name for data set');
        if (datafile)==0, return, end
        disp('Loading data...')
        cd(datapath)
    elseif nargin  == 3
        studyfile = varargin{1};
        datafile = varargin{2};
    end
    [path,file,ext] = fileparts(studyfile);
    
    load(studyfile);
    if ~isempty(path)
        cd(path)
    end
    
    try
        Data= load(datafile);
    catch
        cd(Users.STUDIES)
        Data= load(datafile);
    end
    
    %KND   
    if iscell(Data.F)
      Data.F=Data.F{1};
    end

    
    Visu.Data = Data; clear Data
    
    set(findobj(DATAPLOT,'style','pushbutton'),'enable','on');
    
    channelfile = strrep([file,ext],'brainstormstudy','channel');
    load(channelfile) 
    
    % - Loading Subject Information
    cd(Users.SUBJECTS)
    if isempty(BrainStormSubject)
        %         errordlg('Please make sure you have assigned a Subject file to this study')
        %         study_editor_cb create
        %   
        set(findobj(DATAPLOT,'Tag', 'SurfaceViewer'),'enable','off')
    else
        load(BrainStormSubject)
        
        Visu.Tesselation = Tesselation;
        if isempty(Visu.Tesselation)
            set(findobj(DATAPLOT,'Tag', 'SurfaceViewer'),'enable','off')
        else
            set(findobj(DATAPLOT,'Tag', 'SurfaceViewer'),'enable','on')
        end
    end
    
    % Check the nature of the channels
    MEG_chk = [];
    EEG_chk = [];
    OTHER_chk = [];
    
    % Channel Identification
    imeg = 0; % Index of MEG channels 
    ieeg = 0;  
    iother = 0;
    megID = [];
    eegID = [];
    otherID = [];
    
    for chan = 1:max(size(Channel))
        if ~isempty(Channel(chan).Type)
            switch Channel(chan).Type
                % case {'MEG','MEG Sensor','Ref Magnetometer','Ref Gradiometer'}
                % case {'MEG','Ref Magnetometer','Ref Gradiometer'}
            case {'MEG','MEG Sensor'}
                MEG_chk = 1;
                imeg = imeg +1;
                megID(imeg) = chan; 
            case {'EEG','EEG Sensor'}
                EEG_chk = 1; 
                ieeg = ieeg +1;
                eegID(ieeg) = chan;   
            otherwise
                OTHER_chk = 1; 
                iother = iother +1;
                otherID(iother) = chan;
            end
        end
    end
    
    Visu.ChannelID = {megID,eegID,otherID};
    Visu.Channel = Channel;
    
    % Number of time samples - for GUI display purposes
    nSamples = findobj(DATAPLOT,'tag','Samples');
    set(nSamples,'String',{int2str(size(Visu.Data.F,2)),'samples'})
    
    set(TIME_MIN,'String',num2str(1000*min(Visu.Data.Time),5))
    set(TIME_MAX,'String',num2str(1000*max(Visu.Data.Time),5))
    
    hDATAPLOT = guihandles(DATAPLOT);
    
    set([hDATAPLOT.MEG,hDATAPLOT.EEG,hDATAPLOT.OTHER,hDATAPLOT.RemoveEEGAverage],'enable','on')
    
    if isempty(MEG_chk)
        set(hDATAPLOT.MEG,'enable','off','Value',0)
    end
    if isempty(EEG_chk)
        set(hDATAPLOT.EEG,'enable','off','Value',0)
        set(hDATAPLOT.RemoveEEGAverage,'enable','off')
    end
    if isempty(OTHER_chk )
        set(hDATAPLOT.OTHER,'enable','off')
    end
    
    if ~isempty(MEG_chk)
        set(hDATAPLOT.MEG,'value',~isempty(MEG_chk),'enable','on')
    end
    if ~isempty(EEG_chk)
        set(hDATAPLOT.EEG,'enable','on','Value',1)
        set(hDATAPLOT.RemoveEEGAverage,'value',0)
    end
    
    if ~isempty(OTHER_chk)
        set(hDATAPLOT.OTHER,'enable','on')
    end
    
    set(DATAPLOT,'Userdata',Visu)
    
    htaskbar = guihandles(TASKBAR);
    set(htaskbar.CurrentData,'String',...
        { ['Study: ',''],...
            ['Subject: ', Users.CurrentData.SubjectName],...
            ['Data File: ',datafile],...
            ['Database: ',Users.CurrentData.Database]...
        });
    

    FileList = get(hDATAPLOT.DataFileList,'String');
    iFile = find(strcmp(FileList,datafile));
    if ~isempty(iFile)
        set(hDATAPLOT.DataFileList,'Value',iFile)
    end
    
    disp('Loading data... -> Done')   
    drawnow
    
    %----------------------------------------------------------------------------
    
case 'RemoveEEGAverage' % When box is checked, systematically displays the EEG as averaged-reference
    
    Visu = get(DATAPLOT,'Userdata');
    switch get(gcbo,'Value')
    case 1 % Remove Average
        % Get goodchannels
        goodchannels = find(Visu.Data.ChannelFlag(Visu.ChannelID{2})==1);
        goodchannels = Visu.ChannelID{2}(goodchannels);
        if ~isfield(Visu,'DataOrig') % First time average reference is requested
            Visu.DataOrig.F = Visu.Data.F;
        end
        Visu.Data.F(goodchannels,:) = Visu.Data.F(goodchannels,:) - repmat(mean(Visu.Data.F(goodchannels,:)),length(goodchannels),1);
        ButtonName=questdlg('Would you like to overwrite the orignal EEG segment in the current data file with the averaged-reference EEG (ie current referenced EEG will be lost) or save it under another name ?',...
            '','Overwrite','Save as a new file','Don''t save; just try it','Overwrite');
        switch ButtonName
        case 'Overwrite'
            % Save it back to the original data set file
            cd(Users.STUDIES)
            [path,file,ext] = fileparts(Users.CurrentData.StudyFile);
            cd(path)
            [path,file,ext] = fileparts(Users.CurrentData.DataFile);
            if file == 0, return, end
            
            save_fieldnames(Visu.Data,file)
            
            Users.CurrentData.DataFile = file;
            guidata(TASKBAR,Users)
            
        case 'Save as a new file'
        
            % Save it back to the original data set file
            cd(Users.STUDIES)
            [path,file,ext] = fileparts(Users.CurrentData.StudyFile);
            cd(path)
            [path,file,ext] = fileparts(Users.CurrentData.DataFile);
            if file == 0, return, end
            
            file = [file,'_EEGAvrRef'];
            
            save_fieldnames(Visu.Data,file)
            
            msgbox(['Data saved in ',file]);
          
            Users.CurrentData.DataFile = file;
            guidata(TASKBAR,Users)
            
        case 'Don''t save; just try it'
            % Do nothing
        case 'Cancel'
            return
        end
        
    otherwise % Back to original reference system
        Visu.Data.F = Visu.DataOrig.F;
    end
    
    Visu.Alter = 1;
    
    set(DATAPLOT,'Userdata',Visu)
    dataplot_cb quicklook
    
    %----------------------------------------------------------------------------
case {'set_time_min','set_time_max'}
    dataplot_cb quicklook
    IMAGING = findobj(0,'Tag','CorticalImaging');
    
    if ~isempty(IMAGING)
        dhandles = guihandles(DATAPLOT);
        handles = guihandles(IMAGING); 
        set(handles.FromTo,'String',...
            sprintf('From: %s\t To: %s (ms)', get(dhandles.time_min,'String'),get(dhandles.time_max,'String')),...
            'Userdata',[str2num(get(dhandles.time_min,'String')),str2num(get(dhandles.time_max,'String'))] );
    end

    %----------------------------------------------------------------------------
    
case 'SetPeakLatency' %0ms adjustment to data maximum peak (useful for epileptic data analysis about the maximum of the spike)
    % ... prior to source localization about the spike
    Visu = get(DATAPLOT,'Userdata');
    hDataPlot = guihandles(DATAPLOT);
    
    if get(hDataPlot.SetPeakLatency,'Value')
        if length(current) > 1
            errordlg('Please select either MEG, EEG or OTHER data subset')
            return
        end
        
        % Extract channels from selected data
        goodchannel = intersect(find(Visu.Data.ChannelFlag==1),[Visu.ChannelID{current}]);
        F = Visu.Data.F(goodchannel,:);
        
        % Get value for time window of analysis
        winPeak = str2num(get(hDataPlot.PeakDetectionWindow,'String'));
        
        % Corresponding number of samples
        srate = abs(Visu.Data.Time(1)-Visu.Data.Time(2));
        winPeak = ceil(winPeak/1000/srate/2);
        
        % Find sample corresponding to time 0ms
        zeroLat = round(abs(Visu.Data.Time(1))/srate)+1;
        
        % Extract data on the window of analysis:
        F = F(:,zeroLat-winPeak:zeroLat+winPeak);
        
        % Find maximum at each time sample 
        [mF ,mFindx] = max((F));
        % Find absolute maximum
        [mmF, mFindx] = max(mF);
        
        % Compute new time vector
        Visu.Data.TimeOrig = Visu.Data.Time;
        
        % New sample number for 0ms latency 
        zeroLat = zeroLat-winPeak+mFindx-1; 
        % New time vector
        Time(1) = sign(Visu.Data.Time(1))*(zeroLat-1)*srate;
        Time = Time(1):srate:(Time(1)+(length(Visu.Data.Time)-1)*srate);
        Visu.Data.Time = Time; 
        set(hDataPlot.time_min,'String',num2str(Time(1)*1000,'%3.2f'));
        set(hDataPlot.time_max,'String',num2str(Time(end)*1000,'%3.2f'));
    else
        Visu.Data.Time = Visu.Data.TimeOrig;
    end
    
    % Save it back to the original data set file
    cd(Users.STUDIES)
    [path,file,ext] = fileparts(Users.CurrentData.StudyFile);
    cd(path)
    [path,file,ext] = fileparts(Users.CurrentData.DataFile);
    if file == 0, return, end
    
    save_fieldnames(Visu.Data,file)
    file
    
    set(DATAPLOT,'Userdata',Visu)
    dataplot_cb quicklook
    
    %----------------------------------------------------------------------------
    
case 'quicklook'
    if isempty(current)
        return
    end
    
    Visu = get(DATAPLOT,'Userdata');
    
    for k = 1:length(current) % For each of selected modality 
        previous{k} = findobj(0,'Tag',['waves_single',int2str(current(k))]);
        if isempty(previous{k})
            previous{k} = open('wave_single.fig');
            set(previous{k},'color',backcolor)
            set(previous{k},'Tag',['waves_single',int2str(current(k))])
            movegui(previous{k},'north');
        else
            figure(previous{k})
        end
        
        zoom(previous{k},'on')
        
        if ~isempty(find(Visu.Data.ChannelFlag == -1))
            goodchannels{k} = setdiff(Visu.ChannelID{current(k)},find(Visu.Data.ChannelFlag == -1));%Discard bad channels
            badchannels{k} = intersect(Visu.ChannelID{current(k)},find(Visu.Data.ChannelFlag == -1));
        else
            goodchannels{k} = Visu.ChannelID{current(k)};
            badchannels{k} = [];
        end
        
    end
    
    TIME_MIN = str2num(get(findobj(DATAPLOT,'Tag','time_min'),'String'));
    TIME_MAX = str2num(get(findobj(DATAPLOT,'Tag','time_max'),'String'));
    
    if TIME_MAX > Visu.Data.Time(end) * 1000
        TIME_MAX = Visu.Data.Time(end) * 1000;
        set(findobj(DATAPLOT,'Tag','time_max'),'String',num2str(TIME_MAX,5))
    end
    
    if TIME_MIN < Visu.Data.Time(1) * 1000
        TIME_MIN = Visu.Data.Time(1) * 1000;
        set(findobj(DATAPLOT,'Tag','time_min'),'String',num2str(TIME_MIN,5))
    end
    
    mapping_win = findobj(0,'Tag','mapping'); 
    if ~isempty(mapping_win)
        slider_time = findobj(mapping_win,'Tag','slider_time');
        set(slider_time,'Min',TIME_MIN,'Max',TIME_MAX)
        set(slider_time,'Value',TIME_MIN)
    end
    
    if length(Visu.Data.Time) >1
        delta_t = 1000*(Visu.Data.Time(2)-Visu.Data.Time(1));
        samples = round(([TIME_MIN:delta_t:TIME_MAX]-Visu.Data.Time(1)*1000)/delta_t)+1;
    else
        samples = 1;
    end
    % Number of time samples - for GUI display purposes
    nSamples = findobj(DATAPLOT,'tag','Samples');
    set(nSamples,'String',{int2str(length(samples)),'samples'})
    
    for k = 1:length(current)
        figure(previous{k})
        switch current(k)
        case 1 % MEG channels
            try
                plotwaves = plot([TIME_MIN:delta_t:TIME_MAX],Visu.Data.F(goodchannels{k},samples));
            catch   
                plotwaves = plot([TIME_MIN:delta_t:TIME_MAX],Visu.Data.F{1}(goodchannels{k},samples));
            end            
            set(plotwaves,'Tag','plotMEGwaves')
        case 2 % EEG channels
            try
                plotwaves = plot([TIME_MIN:delta_t:TIME_MAX],Visu.Data.F(goodchannels{k},samples));
            catch   
                plotwaves = plot([TIME_MIN:delta_t:TIME_MAX],Visu.Data.F{1}(goodchannels{k},samples));
            end
            set(plotwaves,'Tag','plotEEGwaves')     
        otherwise
            plotwaves = plot([TIME_MIN:delta_t:TIME_MAX],Visu.Data.F(goodchannels{k},samples));
            set(plotwaves,'Tag','plotOTHERwaves')     
        end
        
        set(plotwaves,'ButtonDownFcn','dataplot_cb line_select')
        set(gca,'xcolor', textcolor,'ycolor', textcolor,'fontweight','bold','Xlim',[TIME_MIN,TIME_MAX]);
        grid on   
        set(gcf,'Userdata',plotwaves,'NumberTitle','off',...
            'Name',[modality{current(k)},' Waveforms'])   
        zoom(gcf,'on')
    end
    
    %----------------------------------------------------------------------------
    
case 'line_select' % Mouse selection of a channel in the current waves_single window
    Visu = get(DATAPLOT,'Userdata');
    MEG = get(findobj(DATAPLOT,'Tag','MEG'),'value');
    EEG = get(findobj(DATAPLOT,'Tag','EEG'),'value');
    OTHER = get(findobj(DATAPLOT,'Tag','OTHER'),'value');
    current = find([MEG,EEG,OTHER] == 1);
    
    figsingle = findobj(0,'Tag',['waves_single',int2str(current)]); % Figure of overlaping plots for the current modality
    layout = findobj(0,'Tag',['layout_',modality{current}]);
    
    if ~isempty(find(Visu.Data.ChannelFlag == -1))
        goodchannels = setdiff([Visu.ChannelID{current}],find(Visu.Data.ChannelFlag == -1));%- min(Visu.ChannelID{current})+1 ; % Discard bad channels
        badchannels = intersect([Visu.ChannelID{current}],find(Visu.Data.ChannelFlag == -1));% - min(Visu.ChannelID{current})+1;
    else
        goodchannels = [Visu.ChannelID{current}];
        badchannels = [];
    end
    
    switch gcbf
    case figsingle
        line_qcklk = get(figsingle,'Userdata');
        set(line_qcklk,'linewidth',1)
        axes_qcklk = get(line_qcklk(1),'Parent');
        
        gco = get(figsingle,'CurrentObject');
        if ~strcmp(get(gco,'Type'),'line')
            return % No channel has been cliked
        end
        ichan = (find(line_qcklk == gco)); % Number of the line plot that has been selected
        current_chan = (ichan);%-min(Visu.ChannelID{current})+1 ; % Number of the Channel that has been selected
        set(line_qcklk(ichan),'linewidth',2);
    case layout
        gco = get(layout,'CurrentAxes');
        ichan = str2num(get(gca,'Tag')); % Number of the channel that has been selected
        line_qcklk(ichan) = findobj(get(gca,'Children'),'Type','line','color',frontcolor);
        axes_qcklk = get(line_qcklk(ichan),'Parent');
    otherwise
        return
    end
    
    previous = findobj(0,'Tag',['single_wave_',[modality{current}],'  ',Visu.Channel(goodchannels(current_chan)).Name]); % Plot exists already ?
    if ~isempty(previous)
        figure(previous)
        return
    end
    
    singlefig = figure; % Creation of a new window
    set(singlefig','color',backcolor,'CreateFcn','movegui south','Position',get(singlefig,'Position')/1.5,'Name','')
    switch gcbf
    case figsingle
        set(singlefig,'Tag',['single_wave_',[modality{current}],'  ',Visu.Channel(goodchannels(current_chan)).Name])
        set(singlefig,'Name',['Selected Channel: ',[modality{current}],'  ',Visu.Channel(goodchannels(current_chan)).Name])
    otherwise
        set(singlefig,'Tag',['single_wave_',[modality{current}],'  ',Visu.Channel(goodchannels(current_chan)).Name])
        set(singlefig,'Name',['Selected Channel: ',[modality{current}],'  ',Visu.Channel(goodchannels(current_chan)).Name])
    end
    
    ax_single = copyobj(axes_qcklk,singlefig);
    set(ax_single,'Visible','on','Xcolor',textcolor,'Ycolor',textcolor,'color',[1 1 1],...
        'Fontweight','bold','Position',get(0,'DefaultAxesPosition'),'Units','Normal')
    grid on
    
    delete(get(ax_single,'children'))
    wave = copyobj(line_qcklk(ichan),ax_single);
    set(wave,'Linewidth',2,'color',linecolor)
    
    %----------------------------------------------------------------------------
    
case 'quicklook_plots' % Single axis or Multiple axis plots for waveforms
    Visu = get(DATAPLOT,'USerdata');
    % Current Modality
    MEG = get(findobj(DATAPLOT,'Tag','MEG'),'value');
    EEG = get(findobj(DATAPLOT,'Tag','EEG'),'value');
    OTHER = get(findobj(DATAPLOT,'Tag','OTHER'),'value');
    current = find([MEG,EEG,OTHER] == 1);
    
    QUICKLOOK_GUI = findobj(0,'Tag',['QUICKLOOK_GUI']);
    figsingle = findobj(0,'Tag',['waves_single',int2str(current)]); % Figure of overlaping plots for the current modality
    
    if isempty(figsingle)
        errordlg('Please load a data set first')
        return
    end
    
    % Get handles on the QUICKLOOK graphic objects
    line_qcklk = get(figsingle,'Userdata');%findobj(figsingle,'Type','line');
    axes_qcklk = get(line_qcklk(1),'Parent');
    tag = get(gcbo,'TAG');
    
    if ~isempty(find(Visu.Data.ChannelFlag == -1))
        goodchannels = setdiff([Visu.ChannelID{current}],find(Visu.Data.ChannelFlag == -1))- min([Visu.ChannelID{current}])+1 ; % Discard bad channels
    else
        goodchannels = [Visu.ChannelID{current}]- min([Visu.ChannelID{current}])+1 ;
    end
    
    switch tag
        
    case 'SINGLE'
        switch get(gcbo,'value')
        case 0
            set(findobj(DATAPLOT,'Tag','MULTIPLE'),'Value',1)
            
            multi = findobj(0,'Tag',['waves_multi',int2str(current)]);
            if ~isempty(multi)
                set(multi,'Visible','on')
                return
            end
            
            k = length(line_qcklk); % Number of channels
            c = ceil(sqrt(k));
            r = ceil(sqrt(k));  
            wave_fig = get(axes_qcklk,'Parent');
            
            waves_multi       
            multi = findobj(0,'Tag','waves_multi');
            set(multi,'Tag',[get(multi,'Tag'),int2str(current)])
            switch current
            case 1
                set(gcf,'Name','MEG wave forms')
            case 2
                set(gcf,'Name','EEG wave forms')
            otherwise
                set(gcf,'Name','Miscellaneous wave forms')
            end
            
            Mx = get(axes_qcklk,'Xlim');
            My = get(axes_qcklk,'Ylim');
            
            for kk = 1:k
                ax(kk) = subplot(r,c,kk);
                line_qcklk(kk)= copyobj(line_qcklk(kk),ax(kk));
                set(line_qcklk(kk),'color',frontcolor)
                set(ax(kk),'xcolor', frontcolor,'ycolor', frontcolor,'fontweight','bold',...
                    'XTicklabel',[],'YTicklabel',[],'Xlim',Mx,'Ylim',My,'color',backcolor,'Box','on');
                xlabel(int2str(goodchannels(kk)),'color',frontcolor,'Fontsize',8)
            end
            
        otherwise
            set(findobj(DATAPLOT,'Tag','MULTIPLE'),'Value',0)
            switch current
            case 1
                figure(findobj(0,'Tag',['waves_single',int2str(current)]))         
            case 2
                figure(findobj(0,'Tag',['waves_single',int2str(current)]))       
            otherwise
                figure(findobj(0,'Tag',['waves_single',int2str(current)]))
            end
            
            multi = findobj(0,'Tag',['waves_multi',int2str(current)]);
            if ~isempty(multi)
                set(multi,'Visible','off')
            end
            
        end
    case 'MULTIPLE'
        switch get(gcbo,'value')
        case 0
            set(findobj(DATAPLOT,'Tag','SINGLE'),'Value',1)
            switch current
            case 1
                figure(findobj(0,'Tag',['waves_single',int2str(current)]))         
            case 2
                figure(findobj(0,'Tag',['waves_single',int2str(current)]))
            otherwise
                figure(findobj(0,'Tag',['waves_single',int2str(current)]))
            end
            multi = findobj(0,'Tag',['waves_multi',int2str(current)]);
            if ~isempty(multi)
                set(multi,'Visible','off')
            end
            
        otherwise
            set(findobj(DATAPLOT,'Tag','SINGLE'),'Value',0)
            
            multi = findobj(0,'Tag',['waves_multi',int2str(current)]);
            if ~isempty(multi)
                set(multi,'Visible','on')
                return
            end
            
            k = length(line_qcklk); % Number of channels
            c = ceil(sqrt(k));
            r = round(sqrt(k));  
            wave_fig = get(axes_qcklk,'Parent');
            
            waves_multi       
            multi = findobj(0,'Tag','waves_multi');
            set(multi,'Tag',[get(multi,'Tag'),int2str(current)])
            switch current
            case 1
                set(gcf,'Name','MEG wave forms')
            case 2
                set(gcf,'Name','EEG wave forms')
            otherwise
                set(gcf,'Name','Miscellaneous wave forms')
            end
            
            Mx = get(axes_qcklk,'Xlim');
            My = get(axes_qcklk,'Ylim');
            
            for kk = 1:k
                ax(kk) = subplot(r,c,kk);
                line_qcklk(kk)= copyobj(line_qcklk(kk),ax(kk));
                set(line_qcklk(kk),'color',frontcolor)
                set(ax(kk),'xcolor', frontcolor,'ycolor', frontcolor,'fontweight','bold',...
                    'XTicklabel',[],'YTicklabel',[],'Xlim',Mx,'Ylim',My,'color',backcolor,'Box','on');
                xlabel(Visu.Channel(Visu.ChannelID{current}(goodchannels(kk))).Name,'color',textcolor,'Fontsize',8)
            end
        end
    end
    %----------------------------------------------------------------------------
    
case 'Residuals'
    Visu = get(DATAPLOT,'Userdata');
    
    tesselation_select_win = findobj(0,'Tag','tesselation_select');
    if isempty(tesselation_select_win)
        tesselation_select_win = open('tessellation_select.fig');
    end
    handles = guihandles(tesselation_select_win);
    
    ResFiles = get(handles.ResultFiles,'String');
    ResFile = ResFiles{get(handles.ResultFiles,'Value')};
    [path,file,ext] = fileparts(Users.CurrentData.StudyFile);
    ResFile = fullfile(Users.STUDIES,path,ResFile);
    load(ResFile,'Fsynth','GUI','ImageGridTime');
    
    if ~isempty(find(Visu.Data.ChannelFlag == -1))%~isempty(find(Visu.Data.ChannelFlag == 0))
        goodchannels = setdiff(Visu.ChannelID{current},find(Visu.Data.ChannelFlag == -1)); % - min(Visu.ChannelID{current})+1; % Discard bad channels
        badchannels = intersect(Visu.ChannelID{current},find(Visu.Data.ChannelFlag == -1));% - min(Visu.ChannelID{current})+1;
    else
        goodchannels = Visu.ChannelID{current};% - min(Visu.ChannelID{current})+1;
        badchannels = [];
    end
    
    %F = Visu.Data.F(goodchannels,[GUI.Segment(1):GUI.Segment(end)]); % Try next line instead
    F = Visu.Data.F(goodchannels,:);
    
    res = 100*norcol(F-Fsynth)./(norcol(F));
    clear Results;
    mean_res = mean(res);
    std_res = std(res);
    min_res = min(res);
    max_res = max(res);
    
    figres = figure;
    powF = norm(norcol(F));
    [haxes, hline1,hline2] = plotyy(1000*ImageGridTime,res,1000*ImageGridTime,100*(norcol(F))/powF);
    hold on
    axes(haxes(1))
    set(haxes(1),'Ycolor','r')
    set(hline1,'linewidth',2)
    xlabel('Time (ms)');
    ylabel('Residuals (%)');
    
    axes(haxes(2))
    set(haxes(2),'Ycolor','b')
    xlabel('Time (ms)');
    ylabel('GFP (%)');
    grid on
    set(hline1,'Color','r')
    set(hline2,'Color','b')
    grid on
    
    fprintf(...
            'Residuals\nAverage: %4.2f%%\nStd.:%4.2f%%\nMin.: %4.2f%%\nMax.: %4.2f%%\n',mean_res,std_res,min_res,max_res);
    
    set(figres,'Name','Residuals / GFP')
    set(get(figres,'CurrentAxes'),'XGrid','on','YGrid','on')
    
    %----------------------------------------------------------------------------
    
case 'mesh_rendering'
    
    tesselation_select_win = findobj(0,'Tag','tesselation_select');
    if isempty(tesselation_select_win)
        tesselation_select_win = open('tessellation_select.fig');
    end
    
    handles = guihandles(tesselation_select_win);
    
    set(handles.removed,'String','')
    set(handles.available,'String','')
    
    Visu = get(DATAPLOT,'Userdata');
    if isempty(Visu) % Just Mesh rendering without any study
        cd(Users.SUBJECTS);
        [tessfile,tesspath] = uigetfile('*.mat','Please choose a tessellation file');
        load(fullfile(tesspath,tessfile))
        Visu.Tesselation = fullfile(tesspath,tessfile);
        set(DATAPLOT,'Userdata',Visu)
        set(handles.removed,'Userdata',[])   
        set(handles.current_surface,'visible','off') % can't get rid of this object using GUIDE
        set(handles.CurrentSurface,'String',tessfile)
    else
        try
            load(Visu.Tesselation)
        catch % Not in proper directory - try something else
            cd(Users.SUBJECTS)
            load(Visu.Tesselation)
        end
        set(handles.CurrentSurface,'String',Visu.Tesselation)
    end
    set(handles.light_props,'value',1)
    
    % How many meshes available ?
    nmesh = max(size(Vertices));
    Vals = [ones(nmesh,1),zeros(nmesh,7)];
    set(handles.removed,'Userdata',Vals)
    
    set(handles.available,'String',Comment)
    set(handles.available,'Max',length(Comment))
    
    % Look for Results file in the current study folder
    % Get the path
    [path,file,ext] = fileparts(Users.CurrentData.StudyFile);
    % Dir list and look for result files
    cd(fullfile(Users.STUDIES,path))
    ResFiles = dir('*result*.mat');
    for k = 1:length(ResFiles)
        ResFiles(k).name = strrep(ResFiles(k).name,'.mat','');
    end
    set(handles.ResultFiles,'String',{ResFiles(:).name},'Value',1)   
   
    
    %dataplot_cb LoadResultFile
    
    %----------------------------------------------------------------------------
case 'LoadResultFile' % Load selected Result File parameters for source visualization
    tesselation_select_win = findobj(0,'Tag','tesselation_select');
    
    if isempty(tesselation_select_win)
        tesselation_select_win = open('tessellation_select.fig');
    end
    handles = guihandles(tesselation_select_win);

    set(tesselation_select_win,'Pointer','watch'),drawnow

    set(handles.ZScore,'Value',0)
    dataplot_cb('ToggleButtonColor',handles.ZScore)
    
    if nargin == 1
        ResFiles = get(handles.ResultFiles,'String');
        ResFile = ResFiles{get(handles.ResultFiles,'Value')};
    else % A result file is specified
        ResFile = varargin{1};
    end
    
    [path,file,ext] = fileparts(Users.CurrentData.StudyFile);
    ResFile = fullfile(Users.STUDIES,path,ResFile);
    Results = load(ResFile);
    set(handles.Refresh,'Userdata',ResFile)
    
    if isfield(Results,'ZScore')
        if (get(handles.Baseline,'Userdata')) == 0
            try 
                set(handles.Baseline,'String',num2str(1000*(Results.ZScore.BaselineTime),'%4.2f '));
                if isfield(Results.ZScore,'BaselineFile')
                    disp(['ZScore available - baseline taken from file: ',Results.ZScore.BaselineFile])
                else
                    disp(['ZScore available - baseline was set to: ', num2str(1000*Results.ZScore.BaselineTime,'%4,2f '),' ms'])
                end
                
            catch
                set(handles.Baseline,'String','File');
            end
                        
        elseif (get(handles.Baseline,'Userdata')) == 1
            set(handles.Baseline,'String','File');
            if isfield(Results.ZScore,'BaselineFile')
                disp(['ZScore available - baseline taken from file: ',Results.ZScore.BaselineFile])
            else
                disp(['ZScore available - baseline was set to: ', num2str(1000*Results.ZScore.BaselineTime,'%4,2f '),' ms'])
            end
            
        end
        
    end
    
    %Load Associated Data File
    cd(fullfile(Users.STUDIES,path))
    ResFiletmp = strrep(ResFile,Users.STUDIES,'');
    ResFiletmp = strrep(ResFiletmp,'.mat','');
    Iunder = findstr(ResFiletmp,'_');
    DataFile= [ResFiletmp(1:Iunder(end-1)-1),'.mat'];
    
    if exist(DataFile,'file')
        dataplot_cb('loaddata',Users.CurrentData.StudyFile,[DataFile]);
    end
    
    
    set(handles.ResultFiles,'Userdata',Results); % Save in GUI for future use
    nSources = length(Results.SourceLoc);
    if nSources == 0 % Probably an ImageGrid file
        nSources  = size(Results.ImageGridAmp,1);
        BeginTime = Results.ImageGridTime(1)*1000;
        EndTime = Results.ImageGridTime(end)*1000;
        set(handles.CorticalMap,'enable','on') % Allo20w visualization of cortical current density maps
    else
        BeginTime = [];
        EndTime = [];
        set(handles.CorticalMap,'enable','off')
    end
        
    DATA = {'MEG','EEG','FUSION'};
    
    if ~isfield(Results,'ZScore')
        ResultFileParamString= sprintf('%s\nNumber of Sources: %d\nTime window: %3.1f %3.1f msec',...
            Results.Comment,nSources,BeginTime,EndTime);
    else
        if ~isempty(Results.ZScore.BaselineFile)
            [tmp,tmpfile,ext] = fileparts(Results.ZScore.BaselineFile);
            ResultFileParamString= sprintf(...
                '%s-%s\nNumber of Sources: %d\nTime window: %3.1f %3.1f msec\nZScore done: baseline from file:\n%s\n%4.1f to %4.1f ms',...
                Results.Comment,DATA{Results.GUI.DataType},nSources,BeginTime,EndTime,tmpfile,1000*(Results.ZScore.BaselineTime));
        else
            ResultFileParamString= sprintf(...
                '%s-%s\nNumber of Sources: %d\nTime window: %3.1f %3.1f msec\nZScore done: baseline set to\n%4.1f to %4.1f  ms',...
                Results.Comment,DATA{Results.GUI.DataType},nSources,BeginTime,EndTime,1000*(Results.ZScore.BaselineTime));
        end
    end
    

    
    set(handles.ResultFileParam,'String',ResultFileParamString)
        
    % Find the corresponding tessellated envelope in the list
    nsrc = size(Results.ImageGridAmp,1); % Number of cortical sources 
    % Is there a cortical surface available qith the same number of sources ?
    Visu = get(DATAPLOT,'Userdata');
    try
        load(Visu.Tesselation,'Vertices','Comment')
    catch
        cd(Users.SUBJECTS)
        load(Visu.Tesselation,'Vertices','Comment')
    end
    
    for k = 1:length(Vertices)
        nverts(k) = size(Vertices{k},2);
    end
    clear Vertices
    iCortex = find(nverts == nsrc);
    if isempty(iCortex)
        errordlg('No corresponding cortical surface was found among the available tessellated surfaces')
        return
    elseif length(iCortex)>1
        msgbox('Several tessellated surfaces may be corresponding to this result file. Please select the proper one manually')
        return
    end
    
    % Find the cortical surface is the list and mark it as selected
    
    set(handles.removed,'String',Comment{iCortex})
    set(handles.available,'String',Comment(setdiff(1:length(Comment),iCortex)))
    
    set(handles.CorticalMap,'Value',1);
    Green = [.66 1 .43];
    Dark = [.4 .4 .4];
    set(handles.CorticalMap,'Backgroundcolor',Green,'Foregroundcolor',Dark)
    
    set(tesselation_select_win,'Pointer','arrow')
    %----------------------------------------------------------------------------
case 'mesh_props' % Indicate Mesh Surface Properties with Radiobuttons 
    Visu = get(DATAPLOT,'Userdata');
    %   eval(['load ',Visu.Tesselation,' Comment'])
    cd(Users.SUBJECTS)
    load(Visu.Tesselation)
    
    nmesh = max(size(Comment));
    
    tesselation_select_win = findobj(0,'Tag','tesselation_select');
    available = findobj(tesselation_select_win,'Tag','available');
    removed =  findobj(tesselation_select_win,'Tag','removed');
    removeID = get(gcbo,'Value');
    IDs = get(gcbo,'String');
    mesh_names = IDs(removeID);
    %     current_surface = findobj(tesselation_select_win,'Tag','current_surface');
    %  set(current_surface,'String',mesh_names{1});
    
    OPAQUE = findobj(gcbf,'Tag','Opaque');
    TRANSPARENT = findobj(gcbf,'Tag','transparent');
    RIGHT = findobj(tesselation_select_win,'Tag','right');
    LEFT = findobj(tesselation_select_win,'Tag','left');
    FRONT = findobj(tesselation_select_win,'Tag','front');
    BACK = findobj(tesselation_select_win,'Tag','back');
    TOP = findobj(tesselation_select_win,'Tag','top');
    BOTTOM = findobj(tesselation_select_win,'Tag','bottom');
    
    if length(removeID)>1
        return
    end
    
    % Identification of the active mesh surfaces
    for i = 1:length(removeID)
        imesh(i) = find(strcmp(mesh_names{i},Comment));
    end
    
    if length(imesh)== 1
        set(findobj(gcbf,'Tag','faces'),'string',[int2str(size(Faces{imesh},1)),' Faces'])
        set(findobj(gcbf,'Tag','vertices'),'string',[int2str(size(Vertices{imesh},2)), ' Vertices'])
        if ~strcmp(get(gcbo,'Tag'),'removed'); return, end
    end
    
    Vals = get(removed,'Userdata');
    if isempty(Vals)
        Vals = [ones(nmesh,1),zeros(nmesh,7)];
    else
        HANDLES = [OPAQUE TRANSPARENT RIGHT LEFT FRONT BACK TOP BOTTOM];
        for k = 1:length(HANDLES)
            set(HANDLES(k),'Value',Vals(imesh,k));
        end
    end
    
    %----------------------------------------------------------------------------
    
case 'camlight' % Add light in the tesselation window
    previous  = findobj(0,'Tag','tessellation_window');
    if isempty(previous)
        return
    end
    figure(previous)
    h = camlight('headlight');
    set(h,'color','w'); % mute the intensity of the lights
    rotate3d on
    %----------------------------------------------------------------------------
    
case 'remove_camlight' % Remove last camlight 
    previous  = findobj(0,'Tag','tessellation_window');
    if isempty(previous)
        return
    end
    figure(previous)
    h = findobj(previous,'type','light');
    if isempty(h), return, end
    delete(h(end))
    rotate3d on
    %----------------------------------------------------------------------------
    
case 'mesh_vals' % Indicate Mesh Surface Properties with Radiobuttons 
    Visu = get(DATAPLOT,'Userdata');
    try
        eval(['load ',Visu.Tesselation,' Comment'])
    catch
        cd(Users.SUBJECTS)
        eval(['load ',Visu.Tesselation,' Comment'])
    end
    
    nmesh = max(size(Comment));
    
    tesselation_select_win = findobj(0,'Tag','tesselation_select');
    available = findobj(tesselation_select_win,'Tag','available');
    removed =  findobj(tesselation_select_win,'Tag','removed');
    removeID = get(removed,'Value');
    IDs = get(removed,'String');
    if iscell(IDs)
        mesh_names = IDs(removeID);
    else
        mesh_names  = IDs;
    end
    
    
    current_surface = findobj(tesselation_select_win,'Tag','current_surface');
    %     set(current_surface,'String',mesh_names{1});
    
    OPAQUE = findobj(gcbf,'Tag','Opaque');
    TRANSPARENT = findobj(gcbf,'Tag','transparent');
    RIGHT = findobj(tesselation_select_win,'Tag','right');
    LEFT = findobj(tesselation_select_win,'Tag','left');
    FRONT = findobj(tesselation_select_win,'Tag','front');
    BACK = findobj(tesselation_select_win,'Tag','back');
    TOP = findobj(tesselation_select_win,'Tag','top');
    BOTTOM = findobj(tesselation_select_win,'Tag','bottom');
    
    % Identification of the active mesh surfaces
    if ~iscell(mesh_names)
        imesh = find(strcmp(mesh_names,Comment));
    else
        for i = 1:length(removeID)
            imesh(i) = find(strcmp(mesh_names{i},Comment));
        end
    end
    
    
    Vals = get(removed,'Userdata');
    if 0%isempty(Vals)
        Vals = [ones(nmesh,1),zeros(nmesh,7)];
    else
        HANDLES = [OPAQUE TRANSPARENT RIGHT LEFT FRONT BACK TOP BOTTOM];
        tmp = get(HANDLES,'Value');
        Vals(imesh,:) = [tmp{:}];   
    end
    
    set(removed,'Userdata',Vals)
    
    %----------------------------------------------------------------------------
case 'ConcatenateTess' % Concatenate 2 selected envelopes into 1
    tesselation_select_win = findobj(0,'Tag','tesselation_select');
    Visu = get(DATAPLOT,'Userdata');
    removed =  findobj(tesselation_select_win,'Tag','removed');
    removeID = get(removed,'Value');
    
    IDs = get(removed,'String');
    if isempty(IDs)
        return
    end
    
    mesh_names = IDs(removeID);
    eval(['load ',Visu.Tesselation,' Comment'])
    
    nmesh = max(size(Comment));
    
    % Identification of the active mesh surfaces
    for i = 1:length(removeID)
        imesh{i} = find(strcmp(mesh_names{i},Comment));
    end
    
    if length(imesh) >2
        errordlg('Cannot concatenate more than 2 envelopes yet') % CHEAT - need to generalize this
        return
    end
    
    load(Visu.Tesselation,'Faces','Vertices')
    Vertices{end+1} = [Vertices{imesh{1}},Vertices{imesh{2}}]  ;
    Faces{end+1} = [Faces{imesh{1}}; Faces{imesh{2}}+size(Vertices{imesh{1}},2)];
    Comment{end+1} = [Comment{imesh{1}},Comment{imesh{2}}]  ;
    
    save(Visu.Tesselation,'Faces','Vertices','Comment','-append')
    
    dataplot_cb mesh_rendering
    
    %----------------------------------------------------------------------------
    
case 'SwapFaces' % Swap vertex ordering for face definition as some pacthes normal may happen to be oriented inwards and therefore look dark in 3d
    
    tesselation_select_win = findobj(0,'Tag','tesselation_select');
    Visu = get(DATAPLOT,'Userdata');
    removed =  findobj(tesselation_select_win,'Tag','removed');
    removeID = get(removed,'Value');
    
    IDs = get(removed,'String');
    if isempty(IDs)
        return
    end
    
    mesh_names = IDs(removeID);
    eval(['load ',Visu.Tesselation,' Comment'])
    
    nmesh = max(size(Comment));
    
    % Identification of the active mesh surfaces
    for i = 1:length(removeID)
        imesh{i} = find(strcmp(mesh_names{i},Comment));
    end
    
    if length(imesh) > 1
        errordlg('Cannot swap vertices of more than 1 envelope yet') % CHEAT - need to generalize this
        return
    end
    
    load(Visu.Tesselation,'Faces')
    
    Faces{imesh{1}} = Faces{imesh{1}}(:,[2 1 3]);
    
    save(Visu.Tesselation,'Faces','-append')
    
    dataplot_cb mesh_rendering
    
    
    %----------------------------------------------------------------------------
    
case 'RenameTess' % Edit the Comment (ie label) of selected envelope
    
    tesselation_select_win = findobj(0,'Tag','tesselation_select');
    Visu = get(DATAPLOT,'Userdata');
    removed =  findobj(tesselation_select_win,'Tag','removed');
    removeID = get(removed,'Value');
    
    IDs = get(removed,'String');
    if isempty(IDs)
        return
    end
    
    mesh_names = IDs(removeID);
    eval(['load ',Visu.Tesselation,' Comment'])
    
    nmesh = max(size(Comment));
    
    % Identification of the active mesh surfaces
    for i = 1:length(removeID)
        imesh{i} = find(strcmp(mesh_names{i},Comment));
    end
    
    if length(imesh) > 1
        errordlg('Cannot rename more than 1 envelope yet') % CHEAT - need to generalize this
        return
    end
    
    newComment = inputdlg('Please enter a new label for the selected envelope');
    if isempty(newComment)
        return
    end
    
    Comment{imesh{1}} = newComment{:};
    
    save(Visu.Tesselation,'Comment','-append')
    
    dataplot_cb mesh_rendering
    
    
    
    %----------------------------------------------------------------------------
case 'DownsizeTess'
    tesselation_select_win = findobj(0,'Tag','tesselation_select');
    Visu = get(DATAPLOT,'Userdata');
    removed =  findobj(tesselation_select_win,'Tag','removed');
    removeID = get(removed,'Value');
    
    IDs = get(removed,'String');
    if isempty(IDs)
        return
    end
    
    mesh_names = IDs(removeID);
    eval(['load ',Visu.Tesselation,' Comment'])
    
    nmesh = max(size(Comment));
    
    % Identification of the active mesh surfaces
    for i = 1:length(removeID)
        imesh{i} = find(strcmp(mesh_names{i},Comment));
    end
    
    if length(imesh) > 1
        errordlg('Cannot swap vertices of more than 1 envelope yet') % CHEAT - need to generalize this
        return
    end
    
    load(Visu.Tesselation,'Faces','Vertices')
    
    handles = guihandles(tesselation_select_win);
    nfv.faces = Faces{imesh{1}};
    nfv.vertices = Vertices{imesh{1}}';
    
    set(tesselation_select_win,'Pointer','watch')
    NFV = reducepatch(nfv, str2num(get(handles.DownsizeFactor,'String')));
    
    clear nfv
    Faces{end+1} = NFV.faces;
    Vertices{end+1} = NFV.vertices';
    clear NFV
    Comment{end+1} = [Comment{imesh{1}},'_',get(handles.DownsizeFactor,'String')];
    
    save(Visu.Tesselation,'Faces','Comment','Vertices', '-append')
    
    dataplot_cb mesh_rendering
    
    set(tesselation_select_win,'Pointer','arrow')
    %----------------------------------------------------------------------------
case 'mesh_add' % Add a meshed surface to visualization
    Visu = get(DATAPLOT,'Userdata');
    load(Visu.Tesselation)
    nmesh = max(size(Vertices));
    
    tesselation_select_win = findobj(0,'Tag','tesselation_select');
    available = findobj(tesselation_select_win,'Tag','available');
    removed =  findobj(tesselation_select_win,'Tag','removed');
    removeID = get(available,'Value');
    
    %Check if it's a double-click
    old_available = get(available,'Userdata');
    if isempty(old_available) | old_available ~= removeID % Single Click
        set(available,'Userdata',removeID)
        return
    else
        set(available,'Userdata',[])
    end
    
    IDs = get(available,'String');
    if isempty(IDs), return, end
    chan = 1:length(get(available,'String'));
    
    set(available,'String', IDs(setdiff(chan,removeID)));
    if isempty(get(removed,'String'))
        set(removed,'String', IDs(removeID));
    else
        strtmp = (get(removed,'String'));
        strtmp(end+1:end+length(IDs)) = IDs(removeID) ;
        set(removed,'String', sort(unique(strtmp)));
    end
    set(available,'String', IDs(setdiff(chan,removeID)));
    set(available,'Value',1,'Max',length(get(available,'String')))
    set(removed,'Value',1,'Max',max([1,length(get(removed,'String'))]))
    
    %----------------------------------------------------------------------------
    
case 'delete_tess'
    % Update the tessellation file (SubjectTess) by deleting the selected surface tessellation
    tesselation_select_win = findobj(0,'Tag','tesselation_select');
    available = findobj(tesselation_select_win,'Tag','available');
    removed =  findobj(tesselation_select_win,'Tag','removed');
    removeID = get(available,'Value');
    availableID = get(removed,'Value');
    IDs = get(removed,'String');
    if isempty(IDs)
        errordlg('Please select a Tessellation in the ''Active'' listbox')
        return
    end
    
    mesh_names = IDs(availableID);
    Visu = get(DATAPLOT,'Userdata');
    eval(['load ',Visu.Tesselation,' Comment'])
    nmesh = max(size(Comment));
    % Identification of the active mesh surfaces
    for i = 1:length(availableID)
        imesh{i} = find(strcmp(mesh_names{i},Comment));
    end
    ButtonName=questdlg(['Are you sure you want to delete permanently ',[Comment{[imesh{:}]}],' from the subject tessellation file ?'], ...
        'Warning', ...
        'Yes','No','No');
    switch ButtonName,
    case 'No', 
        return   
    end
    
    set(removed,'Value',1)
    set(removed,'String',setdiff(get(removed,'String'),char(Comment{[imesh{:}]})))
    
    load(Visu.Tesselation)
    tmp = 1:length(Comment);
    Comment = Comment(setdiff(tmp,[imesh{:}]));
    Vertices = Vertices(setdiff(tmp,[imesh{:}]));
    Faces= Faces(setdiff(tmp,[imesh{:}]));
    
    save(Visu.Tesselation,'Faces','Vertices','Comment','-append')
    
    %----------------------------------------------------------------------------
    
case 'mesh_lighting_props' % Set lighting to Flat/Gouraud/Phong
    
    TessWin  = findobj(0,'Tag','tessellation_window'); % Handle to the 3D display
    SlidesWin = findobj(0,'Tag','subplot_tess_window'); % Handle to the Slides or Movie Window
    if ~isempty(SlidesWin)
        TessWin = SlidesWin;
    end
    
    if isempty(TessWin), return, end
    TessSelect = findobj(0,'Tag','tesselation_select');
    light_props = findobj(TessSelect,'Tag','light_props'); % Handle to the lighting properties pull-down menu 
    tmp = get(light_props,'String');
    
    
    try 
        set(findobj(TessWin,'type','patch'),'edgelighting',tmp{get(light_props,'Value')},...
        'facelighting',tmp{get(light_props,'Value')})
    
    catch
        if ~isempty(findstr(tmp{get(light_props,'Value')},'Flat'))
            set(findobj(TessWin,'type','patch'),...
                'facecolor','flat')
        else
            set(findobj(TessWin,'type','patch'),...
                'facecolor','interp')
        end
        
    end
    
    
    %----------------------------------------------------------------------------
    
case 'mesh_remove' % Remove a mesh surface from visualization
    tesselation_select_win = findobj(0,'Tag','tesselation_select');
    available = findobj(tesselation_select_win,'Tag','available');
    removed =  findobj(tesselation_select_win,'Tag','removed');
    availableID = get(removed,'Value');
    Faces = findobj(tesselation_select_win,'Tag','faces');
    
    %Check if it's a double-click
    old_removed = get(Faces,'Userdata');
    if isempty(old_removed) | old_removed ~= availableID % Single Click
        set(Faces ,'Userdata',availableID)
        return
    else
        set(Faces ,'Userdata',[])
    end
    
    IDs = get(removed,'String');
    if isempty(IDs), return, end
    chan = [1:length(IDs)];
    
    set(removed,'Max',max([1,length(setdiff(chan,availableID))]))
    set(removed,'Value',1,'String',IDs(setdiff(chan,availableID)));
    
    if isempty(get(available,'String'))
        set(available,'String', [IDs(availableID)]);
    else
        strtmp = (get(available,'String'));
        strtmp(end+1:end+length(IDs)) = IDs(availableID) ;
        set(available,'String', sort(unique(strtmp)));
    end
    set(available,'Value',1,'Max',length(get(available,'String')))
    
    %----------------------------------------------------------------------------
    
case 'change_color' % Changes the color of the current mesh surface
    Visu = get(DATAPLOT,'Userdata');
    eval(['load ',Visu.Tesselation,' Comment'])
    tesselation_select_win = findobj(0,'Tag','tesselation_select');
    available = findobj(tesselation_select_win,'Tag','available');
    removed =  findobj(tesselation_select_win,'Tag','removed');
    removeID = get(removed,'Value');
    IDs = get(removed,'String');
    mesh_names = IDs(removeID);
    
    for i = 1:length(removeID)
        imesh(i) = find(strcmp(mesh_names{i},Comment));
    end
    previous  = findobj(0,'Tag','tessellation_window');
    
    if isempty(previous), return, end
    
    for k = imesh
        h = findobj(previous,'Tag',Comment{k});
        corig = get(h,'Edgecolor');
        if ischar(corig) % Edgecolor 'none'
            corig = get(h,'FaceVertexCdata');
            iok = find(isfinite(corig(:,1)));
            corig = corig(iok,:);
            corig = corig(1,:);
        else
            iok = [];
        end
        c = uisetcolor(corig, [Comment{k}, ' Color Change']);
        if c == corig, return, end
        
        ctet = get(h,'vertices');
        vertexcolorh = get(h,'FaceVertexCData');
        siz = size(vertexcolorh,2);
        if size(vertexcolorh ,1) == 1
            vertexcolorh = ones(size(ctet,1),1)*vertexcolorh;
        end
        if 0%size(ctet,1)~=length(iok)
            vertexcolorh(tmp,:) = NaN * ones(length(tmp),siz);	   	
        end
        
        vertexcolorh(iok,:) = ones(length(iok),1)*c ;	   	
        set(h,'FaceVertexCData',vertexcolorh,'Userdata',c)
        if isempty(iok)
            set(h,'edgecolor',c)
        end
        
    end
    
    %--------------------------------------------------------------------------------------------------------------------
    
case 'saveas' % Save the new data set as...
    MEG = get(findobj(DATAPLOT,'Tag','MEG'),'value');
    EEG = get(findobj(DATAPLOT,'Tag','EEG'),'value');
    OTHER = get(findobj(DATAPLOT,'Tag','OTHER'),'value');
    current = find([MEG,EEG,OTHER] == 1);
    
    Visu = get(DATAPLOT,'Userdata');
    
    Data = Visu.Data;
    
    TASKBAR = findobj(0,'Tag','TASKBAR');
    Current = get_user_directory;
    cd(Current.STUDIES)
    [FILENAME, PATHNAME] = uiputfile('*data*mat', 'New File Name');
    if FILENAME == 0, return, end
    cd(PATHNAME)
    
    [F,Device,ChannelFlag,Time,NoiseCov,SourceCov,Projector,Comment] = ...
        deal(Data.F,Data.Device,Data.ChannelFlag,Data.Time,Data.NoiseCov,Data.SourceCov,Data.Projector,Data.Comment);
    clear Data
    save(FILENAME,'Device','ChannelFlag','F','Time','NoiseCov','SourceCov','Projector','Comment');
    
    I = findstr(FILENAME,['_data']);
    if isempty(I)
        error('File name should contain ''_data'' string ')
        return
    end
    
    channelfile = FILENAME(1:I-1);
    channelfile = [channelfile,'_channel']; 
    Channel = Visu.Channel;
    save (channelfile,'Channel')
    
    %----------------------------------------------------------------------------
case 'create_filter_window'
    filter_wind = findobj(0,'Tag','filter_win');
    if isempty(filter_wind)
        filter_win
    end
    filter_wind = findobj(0,'Tag','filter_win');
    set(0,'CurrentFigure',filter_wind)
    
    %----------------------------------------------------------------------------
case 'data_filter' % Filter the data and update visualization
    filter_win = findobj(0,'Tag','filter_win');
    lpf = findobj(filter_win,'Tag','LPF'); % Low Cut-off
    hpf = findobj(filter_win,'Tag','HPF'); % High Cut-off
    AVG = findobj(filter_win,'Tag','average'); % Remove average
    lpf = str2num(get(lpf,'string'));
    hpf = str2num(get(hpf,'string'));
    AVG = get(AVG,'Value');
    
    Visu = get(DATAPLOT,'Userdata');
    MEG = get(findobj(DATAPLOT,'Tag','MEG'),'value');
    EEG = get(findobj(DATAPLOT,'Tag','EEG'),'value');
    OTHER = get(findobj(DATAPLOT,'Tag','OTHER'),'value');
    current = find([MEG,EEG,OTHER] == 1);
    
    if ~isempty(find(Visu.Data.ChannelFlag == -1))%~isempty(find(Visu.Data.ChannelFlag == 0))
        goodchannels = setdiff(Visu.ChannelID{current},find(Visu.Data.ChannelFlag == -1)); % - min(Visu.ChannelID{current})+1; % Discard bad channels
        badchannels = intersect(Visu.ChannelID{current},find(Visu.Data.ChannelFlag == -1));% - min(Visu.ChannelID{current})+1;
    else
        %KND
        goodchannels = [Visu.ChannelID{current}];% - min(Visu.ChannelID{current})+1;
        badchannels = [];
    end
    
    srate = abs(1/(Visu.Data.Time(2)-Visu.Data.Time(1))); 
    new_waves  = zeros(size(Visu.Data.F));%Visu.ChannelID{current},:)));
    %tmp = brainstorm_filt(Visu.Data.F(goodchannels+min(Visu.ChannelID{current})-1,:),srate,0,lpf);
    tmp = brainstorm_filt(Visu.Data.F(goodchannels,:),srate,0,lpf);
    new_waves(goodchannels,:) = tmp; clear tmp
    % SB 11/10/00 back to space average which is the so-called <average> reference in EEG
    %JCM 10/27/00 changed the average to be the average in time, not space
    if(1)
        if 0%AVG == 1 % Remove average
            new_waves(goodchannels,:) =  new_waves(goodchannels,:) - repmat(mean(new_waves(goodchannels,:)),length(goodchannels),1);
        end
    else
        if AVG == 1 % Remove average in time from each channel
            AVG_MAX = Visu.Data.Time(end)*1000; % milliseconds
            AVG_MIN = Visu.Data.Time(1)*1000;
            prompt={'Enter the starting time (ms)','Enter the ending time (ms)'};
            def={sprintf('%g',AVG_MIN),sprintf('%g',AVG_MAX)};
            dlgTitle='Input the times to use for average removal';
            answer = inputdlg(prompt,dlgTitle,1,def);
            if(isempty(answer)),
                disp('Cancelled')
                return
            else
                AVG_MIN = sscanf(answer{1},'%g');
                AVG_MAX = sscanf(answer{2},'%g');
            end
            AVG_MIN = min(find(Visu.Data.Time >= AVG_MIN/1000)); % convert to index
            AVG_MAX = max(find(Visu.Data.Time <= AVG_MAX/1000));
            if(isempty(AVG_MIN) | isempty(AVG_MAX)), % nothing
                disp('Invalid time values')
                return;
            end
            if(AVG_MAX < AVG_MIN), % bogus
                disp('Inconsistent time values')
                return;
            end
            
            tmp = mean(new_waves(goodchannels,AVG_MIN:AVG_MAX)')'; % mean in time for each channel
            new_waves(goodchannels,:) =  new_waves(goodchannels,:) - tmp(:,ones(1,size(new_waves,2)),:);
        end
    end   
    %   Visu.Data.F(goodchannels+min(Visu.ChannelID{current})-1 ,:) = new_waves(goodchannels,:);
    Visu.Data.F(goodchannels,:) = new_waves(goodchannels,:);
    Visu.Alter = 1;
    
    set(DATAPLOT,'Userdata',Visu);
    dataplot_cb quicklook
    
    %----------------------------------------------------------------------------
case 'show_fragment'
    Visu = get(DATAPLOT,'Userdata');
    tesselation_select_win = findobj(0,'Tag','tesselation_select');
    available = findobj(tesselation_select_win,'Tag','available');
    removed =  findobj(tesselation_select_win,'Tag','removed');
    availableID = get(removed,'Value');
    IDs = get(removed,'String');
    if isempty(IDs), return, end
    chan = [1:length(IDs)];
    
    load(Visu.Tesselation,'Clusters','Comment')
    
    if ~exist('Clusters','var') % No fragmentation available for this tessellation file
        return
    end
    
    % Identification of the active mesh surfaces
    for i = 1:length(IDs)
        imesh(i) = find(strcmp(IDs(i),Comment));
    end
    
    Vals = get(removed,'Userdata');
    if isempty(Vals)
        Vals = [ones(nmesh,1),zeros(nmesh,8)];
    end
    
    % Check for clusters for the current surface (highlighted surface name in the "selected text listbox")
    FragmentMenu = findobj(gcbf,'Tag','FragmentMenu');
    nsurf = imesh(availableID); % Selected surface
    
    dataplot_cb mesh_props
    
    if ~exist('Clusters','var') % Classes were not defined beforehand 
        set(FragmentMenu,'String','No Fragmentation','Value',1);
        return
    end
    
    if isempty(Clusters{nsurf}) % No cluster available for surface 'nsurf'
        set(FragmentMenu,'String','No Fragmentation','Value',1);
        return
    else
        if isempty(Clusters{nsurf}.Seed)% No fragmentation availlable for this surface
            set(FragmentMenu,'String','No Fragmentation');
        else
            sstring = {'No Fragmentation'};
            for k = 1:length(Clusters{nsurf}.Seed)
                sstring{k+1} = int2str(Clusters{nsurf}.Seed(k));
            end
            set(FragmentMenu,'String',sstring,'Value',2)
        end
    end
    
    %----------------------------------------------------------------------------
    
case 'SelectCorticalSpot'
    
    TessWin  = findobj(0,'tag','tessellation_window'); 
    if isempty(TessWin)
        TessWin = open('tessellation_window.fig');
        set(TessWin,'CurrentAxes',findobj(TessWin,'Tag','MainAxis'));
    end
    
    figure(TessWin)
    hold on
    
    if nargin == 1
        ginput(1);
    else
        TessWin = (varargin{2});
        figure(TessWin)
        hold on
    end
    
    MainAxes = findobj(TessWin,'Tag','MainAxes');
    
    scurrent = plot3(0,0,0,'o','parent',MainAxes,'Markersize',5,'Markerfacecolor','r');
    set(scurrent,'visible','off')
    
    vertices = get(findobj(MainAxes,'type','patch'),'vertices');
    % Search for intersection with cortical nodes which 
    % are considered as visible only, ie FVCData ~- NaN
    vert_isnan = get(findobj(MainAxes,'type','patch'),'FaceVertexCdata');
    if size(vert_isnan,2) == 1
        vert_isnan = find(~isnan(vert_isnan));
    else
        vert_isnan = sum(vert_isnan ,2);
        vert_isnan = find(~isnan(vert_isnan));
    end
    
    vertices = vertices(vert_isnan,:);
    
    x = vertices(:,1)';
    y = vertices(:,2)';
    z = vertices(:,3)';		
    clear vertices
    
    if nargin == 1 % Vertex selection from a manual probe
        
        % Calcul de la distance minimale du cortex a la droite C
        C = get(MainAxes,'Currentpoint');		
        
        % Vecteur directeur du rayon d'observation
        u = (C(1,:)-C(2,:))'/norm(C(1,:)-C(2,:));
        
        algo = 'new';
        if algo == 'old'
            %% --------- Ancien algo
            
            normals = get(cortex,'Userdata');
            scalaire = normals*u';
            %%clear normals
            %inorm = find(scalaire > mean(scalaire)+std(scalaire)/2);							
            %inorm = find(scalaire >= 0);							
            inorm = 1:length(scalaire);							
            
            tempo = [C(1,1)-x(inorm);C(1,2)-y(inorm);C(1,3)-z(inorm)];
            distboite = norcol(tempo);
            [minn,im] = min(distboite);				
            %% ------------------------		
        else
            %% ----------- Nouvel algo
            inorm=  1:length(x);
            tempo1 = [C(1,1)-x(inorm);C(1,2)-y(inorm);C(1,3)-z(inorm)];
            DIR = u * ones(1,length(inorm));
            tempo = cross(tempo1,DIR);
            clear DIR
            distdroite = norcol(tempo);
            distboite = norcol(tempo1);
            distdroite = distdroite/max(distdroite);
            distboite = distboite/max(distboite);
            [minn,im] = min(.04*distboite+0.96*distdroite);				
            clear tempo tempo1
            %% -----------
        end % algo
        
        clear tempo
        
        % Affiche source courante		
        
    else % Point location is passed as an argument 
        inorm=  1:length(x);
        im = varargin{1};
    end
    
    set(scurrent,'Xdata',x(inorm(im)),'Ydata',y(inorm(im)),'Zdata',z(inorm(im))) 
    drawnow
    
    set(scurrent,'visible','on')
    if isempty(im)
        warndlg('Please reselect your location','Location error')	
    end
    
    hTessWin = guihandles(TessWin);
    TessWinUserData = get(TessWin,'Userdata');
    if isempty(TessWinUserData)
        TessWinUserData = struct('CorticalSpots',[],'CorticalMarkers',[],'CorticalMarkersLabels',[]);
    elseif ~isfield(TessWinUserData, 'CorticalSpots')
        TessWinUserData.CorticalSpots = [];
        TessWinUserData.CorticalMarkers = [];
        TessWinUserData.CorticalMarkersLabels = [];
    end
    
    %    TessWinUserData.CorticalSpots = [TessWinUserData.CorticalSpots,inorm(im)];
    TessWinUserData.CorticalSpots = [TessWinUserData.CorticalSpots,vert_isnan(inorm(im))];
    if size(TessWinUserData.CorticalMarkers,1) > 1
        TessWinUserData.CorticalMarkers = TessWinUserData.CorticalMarkers';
    end
    
    TessWinUserData.CorticalMarkers = [TessWinUserData.CorticalMarkers,scurrent];
    
    htext = text(1.05*x(inorm(im)),1.05*y(inorm(im)),1.05*z(inorm(im)),int2str(length(TessWinUserData.CorticalSpots)));
    set(htext,'FontWeight','normal','color','g','Fontname','helvetica','Fontsize',10,'FontUnits','Point')
    
    TessWinUserData.CorticalMarkersLabels = [TessWinUserData.CorticalMarkersLabels,htext];
    
    set(TessWin,'Userdata',TessWinUserData);
    
    CorticalSpotList = cell(length(TessWinUserData.CorticalSpots),1);
    for k = 1:length(TessWinUserData.CorticalSpots)
        CorticalSpotList{k} = k;
    end
    tesselation_select_win = findobj(0,'Tag','tesselation_select');
    hTessSelect = guihandles(tesselation_select_win);
    if length(CorticalSpotList) == 1
        set(hTessSelect.CorticalSpotList,'String',{get(TessWinUserData.CorticalMarkersLabels,'string')}...
            ,'Max',length(CorticalSpotList),'Value',1)    
    else
        set(hTessSelect.CorticalSpotList,'String',get(TessWinUserData.CorticalMarkersLabels,'string')...
            ,'Max',length(CorticalSpotList),'Value',1)    
    end
    
    rotate3d on
    
    
    %----------------------------------------------------------------------------
case 'DeleteCorticalSpot'
    tesselation_select_win = findobj(0,'Tag','tesselation_select');
    hTessSelect = guihandles(tesselation_select_win);
    SelectedArea = get(hTessSelect.CorticalSpotList,'Value');
    
    AreaLabels = get(hTessSelect.CorticalSpotList,'String');
    
    % Update label information
    ResidualAreas = setdiff([1:length(AreaLabels)],SelectedArea);
    
    set(hTessSelect.CorticalSpotList,'String',AreaLabels(ResidualAreas),'Value',1,'Max',length(AreaLabels));
    
    TessWin  = findobj(0,'tag','tessellation_window'); 
    hTessWin = guihandles(TessWin);
    TessWinUserData = get(TessWin,'Userdata');
    
    TessWinUserData.CorticalSpots =  TessWinUserData.CorticalSpots(ResidualAreas);
    delete(TessWinUserData.CorticalMarkers(SelectedArea))
    delete(TessWinUserData.CorticalMarkersLabels(SelectedArea))
    TessWinUserData.CorticalMarkers = TessWinUserData.CorticalMarkers(ResidualAreas);
    TessWinUserData.CorticalMarkersLabels = TessWinUserData.CorticalMarkersLabels(ResidualAreas);
    
    set(TessWin,'Userdata',TessWinUserData);

    %----------------------------------------------------------------------------
    
case 'ImportScoutsFromMRI' % Create a scout file from points selected in the MR

    TessWin  = findobj(0,'tag','tessellation_window'); 
    tesselation_select_win = findobj(0,'Tag','tesselation_select');
    hTessSelect = guihandles(tesselation_select_win);

    cd(Users.STUDIES);
    [filename, pathname] = uigetfile('*.txt', 'Select an MRI Point File');
    if filename == 0, return, end
    CorticalScouts = struct('MarkersLabels','','CorticalSpots',[],'CorticalMarkers',[]);
    
    [Number,CorticalScouts.CorticalMarkersLabels,X,Y,Z,Xmri,Ymri,Zmri] = ...
        textread(fullfile(pathname,filename),'%d %s %f %f %f %f %f %f',-1);
    clear Number Xmri Ymri Zmri
    
    % What's the name of the current cortical envelope ?
    ActiveTess = get(hTessSelect.removed,'String'); % Find the active Cortical surface
    iCortex = get(hTessSelect.removed,'Value'); 
    if iscell(ActiveTess)
        ActiveTess= ActiveTess{iCortex};
    end
    
    % What's the name of the current data set ?
    ResultFiles = get(hTessSelect.ResultFiles,'String');
    ResultFile = ResultFiles{get(hTessSelect.ResultFiles,'Value')};
    
    % XYZ Coordinates of the scouts
    Visu = get(DATAPLOT,'Userdata');
    cd(Users.SUBJECTS)
    load(Visu.Tesselation,'Comment','Vertices')
    % What's the current surface ?
    imesh = find(strcmp(Comment,ActiveTess));
    Vertices = Vertices{imesh};
    X = X/1000;
    Y = Y/1000;
    Z = Z/1000;
    
    for k = 1:length(X) % Find closest vertex in the tessellation
        [mm CorticalScouts.CorticalSpots(k)] = min(norcol(...
            [Vertices(1,:)-X(k); ...
                Vertices(2,:)-Y(k); ...
                Vertices(3,:)- Z(k)])); 
        CorticalScouts.CorticalMarkers(k,:) = Vertices(:,CorticalScouts.CorticalSpots(k))';
    end
    CorticalScouts.CorticalMarkers = Vertices(:,CorticalScouts.CorticalSpots)';
    clear Vertices
  
    CorticalScouts
    
    % Create Cortical Scout File
    cd(Users.STUDIES);
    [filename, pathname] = uiputfile(['CorticalScoutFromMRI.mat'], 'Save Cortical Scout in...');
    save(fullfile(pathname,filename), 'ResultFile','ActiveTess','CorticalScouts','-mat');

    % Visualization
    dataplot_cb('LoadCorticalSpot',fullfile(pathname,filename))
    
    
    %----------------------------------------------------------------------------
    
case 'CorticalScoutFromThres' % Create a cortical scout file with areas above a given %-threshold
    TessWin  = findobj(0,'tag','tessellation_window'); 
    CorticalScouts = get(TessWin,'Userdata');
    tesselation_select_win = findobj(0,'Tag','tesselation_select');
    hTessSelect = guihandles(tesselation_select_win);

    % Let's do it simple first
    Results = get(hTessSelect.ResultFiles,'Userdata');
    M = max(abs(Results.ImageGridAmp),[],2); % Take maximum over time
    MAX = max(M);
    cThres = str2num(get(hTessSelect.TruncateFactor,'string'))/100;
    
    % Indices of the sources above threshold
    CorticalScouts.CorticalSpots = find(M >= cThres*MAX);
    

    % What's the name of the current cortical envelope ?
    ActiveTess = get(hTessSelect.removed,'String'); % Find the active Cortical surface
    iCortex = get(hTessSelect.removed,'Value'); 
    if iscell(ActiveTess)
        ActiveTess= ActiveTess{iCortex};
    end
    
    % XYZ Coordinates of the scouts
    Visu = get(DATAPLOT,'Userdata');
    cd(Users.SUBJECTS)
    load(Visu.Tesselation,'Comment','Vertices')
    % What's the current surface ?
    imesh = find(strcmp(Comment,ActiveTess));
    Vertices = Vertices{imesh};
    CorticalScouts.CorticalMarkers = Vertices(:,CorticalScouts.CorticalSpots)';
    clear Vertices
    for k =1 : length(CorticalScouts.CorticalSpots)
        CorticalScouts.CorticalMarkersLabels{k} = int2str(k);
    end
    
    
    % What's the name of the current data set ?
    ResultFiles = get(hTessSelect.ResultFiles,'String');
    ResultFile = ResultFiles{get(hTessSelect.ResultFiles,'Value')};
    
    cd(Users.STUDIES)
    dirr = fileparts(Users.CurrentData.StudyFile);
    cd(dirr);
    
    % Create Cortical Scout File
    [filename, pathname] = uiputfile(['CorticalScoutFromThresh_',get(hTessSelect.TruncateFactor,'string'),'.mat'], 'Save Cortical Scout in...');
    save(fullfile(pathname,filename), 'ResultFile','ActiveTess','CorticalScouts','-mat');

    % Visualization
    dataplot_cb('LoadCorticalSpot',fullfile(pathname,filename))
    
    
    %----------------------------------------------------------------------------
    
case 'LoadCorticalSpot' % Load cortical scout locations 
    TessWin  = findobj(0,'tag','tessellation_window'); 

    if nargin == 1
    
        CorticalScouts = get(TessWin,'Userdata');
        if ~isempty(CorticalScouts) % some exist - remove
            if isfield(CorticalScouts,'CorticalMarkers')
                delete(CorticalScouts.CorticalMarkers)
                delete(CorticalScouts.CorticalMarkersLabels)
                clear CorticalScouts
            end
        end
    
        cd(Users.STUDIES)
        dirr = fileparts(Users.CurrentData.StudyFile);
        cd(dirr);
        
        [filename, pathname] = uigetfile('CorticalScout.mat', 'Save Cortical Scout in...');
        if filename == 0
            return
        end
        load(fullfile(pathname,filename), 'ResultFile','ActiveTess','CorticalScouts','-mat');
    else
        load(varargin{1}, 'ResultFile','ActiveTess','CorticalScouts','-mat');
    end
    
    figure(TessWin), hold on
    MainAxes = findobj(TessWin,'Tag','MainAxes');
    vertices = get(findobj(MainAxes,'type','patch'),'vertices');
    x = vertices(:,1)';
    y = vertices(:,2)';
    z = vertices(:,3)';		
    clear vertices
    
    CorticalScouts.CorticalMarkers = zeros(length(CorticalScouts.CorticalSpots),1);
    for k = 1:length(CorticalScouts.CorticalSpots)
        scurrent = plot3(0,0,0,'o','parent',MainAxes,'Markersize',5,'Markerfacecolor','r');
        set(scurrent,'visible','off')
        set(scurrent,'Xdata',x(CorticalScouts.CorticalSpots(k)),...
            'Ydata',y(CorticalScouts.CorticalSpots(k)),...
            'Zdata', z(CorticalScouts.CorticalSpots(k)))
        set(scurrent,'visible','on')
        CorticalScouts.CorticalMarkers(k) = scurrent;
        
        r_text =1.1;
        
        if iscell(CorticalScouts.CorticalMarkersLabels)
            htext = text(r_text*x(CorticalScouts.CorticalSpots(k)),...
                r_text*y(CorticalScouts.CorticalSpots(k)),...
                r_text*z(CorticalScouts.CorticalSpots(k)),...
                CorticalScouts.CorticalMarkersLabels{k});
        else
            htext = text(r_text*x(CorticalScouts.CorticalSpots(k)),...
                r_text*y(CorticalScouts.CorticalSpots(k)),...
                r_text*z(CorticalScouts.CorticalSpots(k)),...
                CorticalScouts.CorticalMarkersLabels);
            
        end
        
        
        set(htext,'FontWeight','normal','color','g','Fontname','helvetica',...
            'Fontsize',10,'FontUnits','Point')
        
        Label_tmp(k) = htext;
    end
    
    tesselation_select_win = findobj(0,'Tag','tesselation_select');
    hTessSelect = guihandles(tesselation_select_win);
    set(hTessSelect.CorticalSpotList,'String',CorticalScouts.CorticalMarkersLabels,...
        'Value',1,'Max', length(CorticalScouts.CorticalMarkersLabels))
    
    CorticalScouts.CorticalMarkersLabels = Label_tmp; clear Label_tmp;
    
    set(TessWin,'Userdata',CorticalScouts);
    
    figure(TessWin)
    rotate3d on
    
    %----------------------------------------------------------------------------
case 'SaveCorticalSpot' % Save cortical scout locations 
    % Cortical scouts need to be indexed with both the corresponding cortical surface name 
    % and the current data set name 
    
    TessWin  = findobj(0,'tag','tessellation_window'); 
    CorticalScouts = get(TessWin,'Userdata');
    
    CorticalScouts.CorticalMarkersLabels = get(CorticalScouts.CorticalMarkersLabels,'String');
    CorticalScouts.CorticalMarkers = [get(CorticalScouts.CorticalMarkers,'Xdata');...
            get(CorticalScouts.CorticalMarkers,'Ydata');...
            get(CorticalScouts.CorticalMarkers,'Zdata')];
    if iscell( CorticalScouts.CorticalMarkers)
        CorticalScouts.CorticalMarkers = [CorticalScouts.CorticalMarkers{:}];
    end
    
    CorticalScouts.CorticalMarkers = reshape(CorticalScouts.CorticalMarkers,length(CorticalScouts.CorticalMarkersLabels),3);
    % CorticalScouts.CorticalMarkers is now Number of Scouts x 3
    
    tesselation_select_win = findobj(0,'Tag','tesselation_select');
    hSelect = guihandles(tesselation_select_win);
    
    % What's the name of the current cortical envelope ?
    ActiveTess = get(hSelect.removed,'String'); % Find the active Cortical surface
    iCortex = get(hSelect.removed,'Value'); 
    if iscell(ActiveTess)
        ActiveTess= ActiveTess{iCortex};
    end
    
    if isfield(CorticalScouts,'CorticalProbePatches') % Process members of cortical patches to get their x,y,z's
        Visu = get(DATAPLOT,'Userdata');
        try
            load(Visu.Tesselation,'Comment','Vertices')
        catch
            cd(Users.SUBJECTS)
            load(Visu.Tesselation,'Comment','Vertices')
        end
        % What's the current surface ?
        imesh = find(strcmp(Comment,ActiveTess));
        Vertices = Vertices{imesh};
        CorticalScouts.CorticalProbePatchesXYZ = cell(size(CorticalScouts.CorticalProbePatches));
        for k=1:length(CorticalScouts.CorticalProbePatches)   % for each area
            CorticalScouts.CorticalProbePatchesXYZ{k} = ...
                Vertices(:,CorticalScouts.CorticalProbePatches{k});
        end
        
    end
    
    % What's the name of the current data set ?
    ResultFiles = get(hSelect.ResultFiles,'String');
    ResultFile = ResultFiles{get(hSelect.ResultFiles,'Value')};
    
    cd(Users.STUDIES)
    dirr = fileparts(Users.CurrentData.StudyFile);
    cd(dirr);
    
    [filename, pathname] = uiputfile('CorticalScout.mat', 'Save Cortical Scout in...');
    save(fullfile(pathname,filename), 'ResultFile','ActiveTess','CorticalScouts','-mat');
    
    %----------------------------------------------------------------------------
case 'RenameCorticalSpot'
    tesselation_select_win = findobj(0,'Tag','tesselation_select');
    hTessSelect = guihandles(tesselation_select_win);
    SelectedArea = get(hTessSelect.CorticalSpotList,'Value');
    SelectedArea = SelectedArea(1); % only one at a time please
    
    AreaLabels = get(hTessSelect.CorticalSpotList,'String');
    
    Title = '';
    Prompt = sprintf('Please enter a new label for %s',AreaLabels{SelectedArea});
    newLabel = inputdlg(Prompt,Title);
    if isempty(newLabel), return, end
    
    AreaLabels{SelectedArea} = newLabel{:} ;
    
    set(hTessSelect.CorticalSpotList,'String',AreaLabels)
    
    TessWin  = findobj(0,'tag','tessellation_window'); 
    TessWinUserData = get(TessWin,'Userdata');
    set(TessWinUserData.CorticalMarkersLabels(SelectedArea),'String',newLabel{:})
    set(TessWin,'Userdata',TessWinUserData);

    %----------------------------------------------------------------------------
case 'ZScoreThreshold'
    %Thresholded ZScore map in terms of multiples of sigmas in the baseline
    
    tesselation_select_win = findobj(0,'Tag','tesselation_select');
    hTSelect = guihandles(tesselation_select_win);
    TessWin  = findobj(0,'tag','tessellation_window'); 
    %if isempty(TessWin), return, end
    %hTessWin = guihandles(TessWin);
      
    %TessWinUserData = get(TessWin,'Userdata');
    
    % Are we switching from ZScore to Absolute mapping or vice-versa ?
    Results = get(hTSelect.ResultFiles,'Userdata');
    set(hTSelect.AbsoluteCurrent,'Value',1)
    
    switch get(hTSelect.ZScoreThresholdApply,'Value')
    case 1 % Switch to ZScore map and threshold it
        if isempty(Results), return, end % No results were loaded
        
        if ~isfield(Results,'ZScore') % No ZScore was defined beforehand
            dataplot_cb ZScore % Compute the ZScore map
            Results = get(hTSelect.ResultFiles,'Userdata');
        end

        set(hTSelect.ZScore,'Value',1);
        dataplot_cb('ToggleButtonColor',hTSelect.ZScore)
        
        ZThres = str2num(get(hTSelect.ZScoreThreshold,'String'));
        if isempty(ZThres)
            set(hTSelect.ZScoreThreshold,'String',2); % Apply Default
            ZThres = str2num(get(hTSelect.ZScoreThreshold,'String'));
        end
        
        Results.ZScore.ImageGridZ.ZThres = ZThres;
        
        set(hTSelect.ZScoreThreshold,'Userdata',ZThres / max(Results.ImageGridAmp(:)))
        
    case 0
        % Don't apply thresholded map
        set(hTSelect.ZScoreThreshold,'Userdata',0)
        
    end
        
    
    %Results.ImageGridAmp(iZeroed) = eps ; %Thresholded Map
        
    % Update display
    set(hTSelect.ResultFiles,'Userdata',Results);
    
    dataplot_cb ScaleColormap
    %dataplot_cb tesselation_select_done
    %----------------------------------------------------------------------------
case 'IntegSTHistogram' % Integrate Saptio-temporal histogram overtime
    tesselation_select_win = findobj(0,'Tag','tesselation_select');
    hTSelect = guihandles(tesselation_select_win);
    
    avResults = get(hTSelect.ResultFiles,'Userdata');
    if ~isfield(avResults,'HistoSrc'), return, end % This is not an histogram result set
    
    % Integrate over time
    figure, imagesc(avResults.ImageGridTime, 1:size(avResults.ImageGridAmp,1),avResults.ImageGridAmp)
    colorbar
    avResults.ImageGridAmp = max(avResults.ImageGridAmp,[],2) *ones(1,size(avResults.ImageGridAmp,2));
   
    
    set(hTSelect.ResultFiles,'Userdata',avResults);
    
    
    %----------------------------------------------------------------------------
         
case 'STHistogram' % Spatio-temporal histogram of activations (in terms of ZScore) on a series of result files
    
    tesselation_select_win = findobj(0,'Tag','tesselation_select');
    hTSelect = guihandles(tesselation_select_win);
    
    % Look for Results file in the current study folder
    % Get the path
    [path,file,ext] = fileparts(Users.CurrentData.StudyFile);
    % Dir list and look for result files
    cd(fullfile(Users.STUDIES,path))
    ResFiles = dir('*result*.mat');
    for k = 1:length(ResFiles)
        ResFiles(k).name = strrep(ResFiles(k).name,'.mat','');
    end
    [ResSelect,ok] = listdlg('Liststring',{ResFiles.name},'Selectionmode','multiple','Name','Please select one or sevral result files',...
        'listsize',[400 400]);
    
    if ok == 0 
        return
    end
    
    hw = waitbar(0,['Computing the spatio-temporal histogram of activation maps through a set of ',int2str(length(ResSelect)),' result files...']);
    nDataFiles = 0;
    
    % Get Value for Z threshold
    ZThres = str2num(get(hTSelect.ZScoreThreshold,'String'));
    if isempty(ZThres)
        set(hTSelect.ZScoreThreshold,'String',2); % Apply Default
        ZThres = str2num(get(hTSelect.ZScoreThreshold,'String'));
    end
    
       
    for k = 1:length(ResSelect)
        dataplot_cb('LoadResultFile',ResFiles(ResSelect(k)).name)
        ResFiles(ResSelect(k)).name
        Results = get(hTSelect.ResultFiles,'Userdata');
        
        if k == 1
            avResults = Results;
            avResults.ImageGridAmp = 0* avResults.ImageGridAmp; % ImageGridAmp becomes a hit-count table - 
            % cell (i,j) will indicate how many times source i had a ZScore > ZThres at time j
            
            avResults.HistoSrc = cell(length(ResSelect));
        end
        
        if isfield(Results,'ZScore')
            
%             % Adapt length to the length of shortest result file
%             cropMin = 0;
%             cropMax = 0;
%             if Results.Time(1) > avResults.Time(1)       
%                 cropMin = Results.Time(1)-avResults.Time(1);
%                 avResults.ImageGridAmp = avResults.ImageGridAmp(:,cropMin+1:end);
%                 avResults.ImageGridTime = avResults.ImageGridTime(:,cropMin+1:end);
%                 avResults.Fsynth = avResults.Fsynth(:,cropMin+1:end);
%                 avResults.ZScore.ImageGridZ.Amp = avResults.ZScore.ImageGridZ.Amp(:,cropMin+1:end);
%                 
%             end
%             if Results.Time(1) < avResults.Time(1)       
%                 cropMin = -Results.Time(1)+avResults.Time(1);
%                 %                 Results.ImageGridAmp = Results.ImageGridAmp(:,cropMin+1:end);
%                 Results.ZScore.ImageGridZ.Amp = Results.ZScore.ImageGridZ.Amp(:,cropMin+1:end);
%                 Results.Time = Results.Time(cropMin+1:end);    
%             end
%             if Results.Time(end) > avResults.Time(end)       
%                 cropMax = Results.Time(end)-avResults.Time(end);
%                 %                 Results.ImageGridAmp = Results.ImageGridAmp(:,1:end-cropMax);
%                 Results.ZScore.ImageGridZ.Amp = Results.ZScore.ImageGridZ.Amp(:,1:end-cropMax);
%                 Results.Time = Results.Time(1:end-cropMax);    
%             end
%             if Results.Time(end) < avResults.Time(end)       
%                 cropMax = -Results.Time(end)+avResults.Time(end);
%                 avResults.ImageGridAmp = avResults.ImageGridAmp(:,1:end-cropMax);
%                 avResults.ImageGridTime = avResults.ImageGridTime(:,1:end-cropMax);
%                 avResults.Fsynth = avResults.Fsynth(:,1:end-cropMax);
%                 avResults.ZScore.ImageGridZ.Amp = avResults.ZScore.ImageGridZ.Amp(:,1:end-cropMax);
%             end
%             
            avResults.Time = Results.Time;
        
            Results.ZScore.ImageGridZ.Amp = (Results.ImageGridAmp)-repmat(Results.ZScore.ImageGridZ.mean,1,size(Results.ImageGridAmp,2));
            iStd = spdiags(1./Results.ZScore.ImageGridZ.std, 0, length(Results.ZScore.ImageGridZ.std), length(Results.ZScore.ImageGridZ.std)) ;
            Results.ZScore.ImageGridZ.Amp = abs(iStd*Results.ZScore.ImageGridZ.Amp);
            
            avResults.HistoSrc{k} = sparse(Results.ZScore.ImageGridZ.Amp > ZThres);
            % avResults.HistoSrc{k} stores the source indices and time where sources had greater ZScore that ZThres
            avResults.ImageGridAmp = avResults.ImageGridAmp + avResults.HistoSrc{k} ;
            
            if k == 1
                prev = figure;
            end
            
            nDataFiles = nDataFiles + 1;    
            k
            figure(prev)
            plot(avResults.ImageGridTime, sum(avResults.HistoSrc{k},1))
            
            
        else % No ZScore available - skip file
            
            disp([ResFiles(ResSelect(k)).name,' does not contain any ZScore map - skip file'])
            
        end
    
        waitbar(k/length(ResSelect))
        
    end
    
    avResults.ImageGridAmp = 100*avResults.ImageGridAmp/nDataFiles; % Scale to 100% hits
    
    cd(Users.STUDIES);
    [path,file,ext] = fileparts(Users.CurrentData.StudyFile);
    cd(path)
    c = clock;
    ResFiletmp = strrep(ResFiles(ResSelect(end)).name,Users.STUDIES,'');
    ResFiletmp = strrep(ResFiletmp,'.mat','');
    Iunder = findstr(ResFiletmp,'_');
    DataFile= [ResFiletmp(1:Iunder(end)-1)];
    
    newname = ([DataFile sprintf('_HISTO_%02.0f%02.0f',c(4:5)) ext]);
    i = 0;
    while(exist(newname,'file')),
        i = i+1; % subtract another minute
        c(5) = mod(c(5) - 1,60);
        newname = ([DataFile sprintf('_HISTO_%02.0f%02.0f',MethodeCode,c(4),c(5)) ext]);
    end
    
    save_fieldnames(avResults,newname)

    delete(hw)
    
    msgbox(['Average activation maps saved in ', newname])
    set(hTSelect.ResultFiles,'Userdata',avResults)

    % Refresh results list
    dataplot_cb mesh_rendering
    ResFiles = get(hTSelect.ResultFiles,'String');
    iFile = find(strcmp(ResFiles,strrep(newname,'.mat','')));
    set(hTSelect.ResultFiles,'Value',iFile)
    
    

    %----------------------------------------------------------------------------
     
case 'AverageMaps' % Average activations across multiple result files

    tesselation_select_win = findobj(0,'Tag','tesselation_select');
    hTSelect = guihandles(tesselation_select_win);
    
    % Look for Results file in the current study folder
    % Get the path
    [path,file,ext] = fileparts(Users.CurrentData.StudyFile);
    % Dir list and look for result files
    cd(fullfile(Users.STUDIES,path))
    ResFiles = dir('*result*.mat');
    for k = 1:length(ResFiles)
        ResFiles(k).name = strrep(ResFiles(k).name,'.mat','');
    end
    [ResSelect,ok] = listdlg('Liststring',{ResFiles.name},'Selectionmode','multiple','Name','Please select one or sevral result files',...
        'listsize',[400 400]);
    
    if ok == 0 
        return
    end
    
    % Now compute ZScore for each of the selected files
    hw = waitbar(0,['Averaging activation maps through a set of ',int2str(length(ResSelect)),' result files...']);
    for k = 1:length(ResSelect)
        dataplot_cb('LoadResultFile',ResFiles(ResSelect(k)).name)
        ResFiles(ResSelect(k)).name
        Results = get(hTSelect.ResultFiles,'Userdata');
        
        if k == 1
            avResults = Results;
            avResults.ImageGridAmp = avResults.ImageGridAmp/length(ResSelect);    
        end

        % !!!!!!Suppose all result files were computed on the same time window - discard what's commented below
        
%         % Adapt length to the length of shortes result file
%         cropMin = 0;
%         cropMax = 0;
%         if Results.Time(1) > avResults.Time(1)       
%             cropMin = Results.Time(1)-avResults.Time(1);
%             avResults.ImageGridAmp = avResults.ImageGridAmp(:,cropMin+1:end);
%             avResults.ImageGridTime = avResults.ImageGridTime(:,cropMin+1:end);
%             avResults.Time = avResults.Time(:,cropMin+1:end);
%             avResults.Fsynth = avResults.Fsynth(:,cropMin+1:end);
%     
%             if isfield(Results,'ZScore')
%                 avResults.ZScore.ImageGridZ.Amp = avResults.ZScore.ImageGridZ.Amp(:,cropMin+1:end);
%             end 
%         end
%         if Results.Time(1) < avResults.Time(1)       
%             cropMin = -Results.Time(1)+avResults.Time(1);
%             Results.ImageGridAmp = Results.ImageGridAmp(:,cropMin+1:end);
%             Results.ImageGridTime = Results.ImageGridTime(:,cropMin+1:end);
%             Results.Time = Results.Time(:,cropMin+1:end);
%             if isfield(Results,'ZScore')
%                 Results.ZScore.ImageGridZ.Amp = Results.ZScore.ImageGridZ.Amp(:,cropMin+1:end);
%             end
%         end
%         if Results.Time(end) > avResults.Time(end)       
%             cropMax = Results.Time(end)-avResults.Time(end);
%             Results.ImageGridAmp = Results.ImageGridAmp(:,1:end-cropMax);
%             Results.ImageGridTime = Results.ImageGridTime(:,1:end-cropMax);
%             Results.Time = Results.Time(:,1:end-cropMax);
%             if isfield(Results,'ZScore')
%                 Results.ZScore.ImageGridZ.Amp = Results.ZScore.ImageGridZ.Amp(:,1:end-cropMax);
%             end
%         end
%         if Results.Time(end) < avResults.Time(end)       
%             cropMax = -Results.Time(end)+avResults.Time(end);
%             avResults.ImageGridAmp = avResults.ImageGridAmp(:,1:end-cropMax);
%             avResults.ImageGridTime = avResults.ImageGridTime(:,1:end-cropMax);
%             avResults.Fsynth = avResults.Fsynth(:,1:end-cropMax);
%             avResults.Time = avResults.Time(:,1:end-cropMax);
%             if isfield(Results,'ZScore')
%                 avResults.ZScore.ImageGridZ.Amp = avResults.ZScore.ImageGridZ.Amp(:,1:end-cropMax);
%             end
%         end 

        if k == 1
            prev = figure;
            if isfield(Results,'ZScore')
                Results.ZScore.ImageGridZ.Amp = (Results.ImageGridAmp)-repmat(Results.ZScore.ImageGridZ.mean,1,size(Results.ImageGridAmp,2));
                iStd = spdiags(1./Results.ZScore.ImageGridZ.std, 0, length(Results.ZScore.ImageGridZ.std), length(Results.ZScore.ImageGridZ.std)) ;
                Results.ZScore.ImageGridZ.Amp = abs(iStd*Results.ZScore.ImageGridZ.Amp);
            end
        end
        
        if k >1
            avResults.ImageGridAmp = avResults.ImageGridAmp + (Results.ImageGridAmp)/length(ResSelect);
            if isfield(Results,'ZScore')
                avResults.ZScore.ImageGridZ.Amp = avResults.ZScore.ImageGridZ.Amp + (Results.ZScore.ImageGridZ.Amp)/length(ResSelect);
            end
        end
        figure(prev)
        plot(Results.ImageGridTime,mean(abs(Results.ImageGridAmp),1),'b'), hold on
        plot(avResults.ImageGridTime,mean(abs(avResults.ImageGridAmp),1),'r'), hold off
               
        waitbar(k/length(ResSelect))
        
    end
    
    %avResults.ImageGridAmp = avResults.ImageGridAmp/length(ResSelect);
%     if isfield(avResults,'ZScore')
%         avResults.ZScore.ImageGridZ.Amp = avResults.ZScore.ImageGridZ.Amp/length(ResSelect);
%     end
    
    cd(Users.STUDIES);
    [path,file,ext] = fileparts(Users.CurrentData.StudyFile);
    cd(path)
    c = clock;
    ResFiletmp = strrep(ResFiles(ResSelect(end)).name,Users.STUDIES,'');
    ResFiletmp = strrep(ResFiletmp,'.mat','');
    Iunder = findstr(ResFiletmp,'_');
    DataFile= [ResFiletmp(1:Iunder(end-1)-1)];
    
    newname = ([DataFile sprintf('_AVRresults_%02.0f%02.0f',c(4:5)) ext]);
    i = 0;
    while(exist(newname,'file')),
        i = i+1; % subtract another minute
        c(5) = mod(c(5) - 1,60);
        newname = ([DataFile sprintf('_AVRresults_%02.0f%02.0f',MethodeCode,c(4),c(5)) ext]);
    end
    
    save_fieldnames(avResults,newname)

    delete(hw)
    
    msgbox(['Average activation maps saved in ', newname])
    set(hTSelect.ResultFiles,'Userdata',avResults)

    % Refresh results list
    dataplot_cb mesh_rendering
    ResFiles = get(hTSelect.ResultFiles,'String');
    iFile = find(strcmp(ResFiles,strrep(newname,'.mat','')));
    set(hTSelect.ResultFiles,'Value',iFile)
    
    %----------------------------------------------------------------------------
    
case 'DefineBaseline'
    tesselation_select_win = findobj(0,'Tag','tesselation_select');
    hTSelect = guihandles(tesselation_select_win);
    set(hTSelect.ZScore,'Value',1)
    dataplot_cb('ToggleButtonColor',hTSelect.ZScore)
    
    if ~strcmp(get(hTSelect.Baseline,'String'),'File')
        set(hTSelect.Baseline,'Userdata',0) % FLAG: Baseline defined on current file
    end
    
    dataplot_cb('ZScore',1) % Force ZScore computation
    
    %----------------------------------------------------------------------------
    
case 'LoadBaseline' % Define Baseline from a different result file
    cd(Users.STUDIES)
    [resfile, respath] = uigetfile('*result*.mat','Please Select a Result File Containing the Activation Baseline');
    if resfile == 0, return, end
    tesselation_select_win = findobj(0,'Tag','tesselation_select');
    hTSelect = guihandles(tesselation_select_win);
    set(hTSelect.LoadBaseline,'userdata',fullfile(respath, resfile));
    set(hTSelect.Baseline,'String','File');
    set(hTSelect.Baseline,'Userdata',1) % FLAG: Baseline defined on a pre-loaded file
    
    dataplot_cb DefineBaseline
    
    %----------------------------------------------------------------------------
case 'ZScoreBatch' % Compute ZScore on a set of Result files
    
    % Look for Results file in the current study folder
    % Get the path
    [path,file,ext] = fileparts(Users.CurrentData.StudyFile);
    % Dir list and look for result files
    cd(fullfile(Users.STUDIES,path))
    ResFiles = dir('*result*.mat');
    for k = 1:length(ResFiles)
        ResFiles(k).name = strrep(ResFiles(k).name,'.mat','');
    end
    [ResSelect,ok] = listdlg('Liststring',{ResFiles.name},'Selectionmode','multiple','Name','Please select one or sevral result files',...
        'listsize',[400 400]);
    
    if ok == 0 
        return
    end
    
    % Now compute ZScore for each of the selected files
    hw = waitbar(0,['Computing ZScore for the selected set of ',int2str(length(ResSelect)),' result files...']);
    for k = 1:length(ResSelect)
        dataplot_cb('LoadResultFile',ResFiles(ResSelect(k)).name)
        ResFiles(ResSelect(k)).name
        tesselation_select_win = findobj(0,'Tag','tesselation_select');
        hTSelect = guihandles(tesselation_select_win);
        set(hTSelect.ZScore,'Value',1)
        dataplot_cb('ToggleButtonColor',hTSelect.ZScore)
        dataplot_cb('ZScore',1) % Force the computation of the ZScore for each of the file (ie force test to 1 in dataplot_cb ZScore)
        waitbar(k/length(ResSelect))
    end
    set(hTSelect.Baseline,'Userdata',0) 
    
    delete(hw)
    
    %----------------------------------------------------------------------------
case 'ZScore' % Switches from Z-Score to Absolute current density mapping 

    tesselation_select_win = findobj(0,'Tag','tesselation_select');
    hTSelect = guihandles(tesselation_select_win);
    TessWin  = findobj(0,'tag','tessellation_window'); 
    
    switch get(hTSelect.ZScore,'Value')
    case 1 % Switch to ZScore map 
    
        % Are we switching from ZScore to Absolute mapping or vice-versa ?
        set(hTSelect.AbsoluteCurrent,'Value',1)
        
        if get(hTSelect.Baseline,'Userdata') == 1  % Baseline is defined from an existing result file, load it
            Results = load(get(hTSelect.LoadBaseline,'Userdata'));
            FlagBaselineFile = 1;
        else % else use current loaded results
            Results = get(hTSelect.ResultFiles,'Userdata');
            FlagBaselineFile = 0;
        end
        
        if isempty(Results), return, end % No results were loaded
        
        test = 0; % By default, consider not computing a new ZScore - check if a previously computation is available - 
        % if test is set to 1 anytime below, this will conduct to a new ZScore computation either because the baseline has changed 
        % or the computation is conducted on a new set of data.
        if nargin == 1
            varargin{1} = 0;
        end
        
        if (~isfield(Results,'ZScore') | varargin{1} == 1) % No ZScore was defined beforehand or computation is forced
            Results.ZScore.Baseline = [-Inf Inf]; % Dummy Score
            test = 1; % Force ZScore computation
        end

        %Get baseline time limits
        if FlagBaselineFile == 1
            set(hTSelect.Baseline,'String',...
                [num2str(Results.ImageGridTime(1)*1000,'%3.1f'),' ',num2str(Results.ImageGridTime(end)*1000,'%3.1f')]);
            
            baseline = [Results.ImageGridTime(1) Results.ImageGridTime(end)];
        else
            baseline = str2num(get(hTSelect.Baseline,'String'))/1000;
        end
        
        if length(baseline) < 2
            errordlg('Please enter 2 time values to define the baseline interval')
            return
        end
        
        if isfield(Results.ZScore,'FlagBaselineFile') % Was this ZScore computed from a stored baseline ?
            if Results.ZScore.FlagBaselineFile == 0 % No - check new baseline limits 
                % Get exact time samples closest to these values
                if round(1000*baseline(1)) < round(1000*Results.ImageGridTime(1)) | round(1000*baseline(2)) > round(1000*Results.ImageGridTime(end)) % Accuracy set to the ms
                    errordlg('Please set baseline time extremas within the available time window for this result file')
                    return    
                end
                
                [tmp, tmin] = min(abs(Results.ImageGridTime-baseline(1)));
                [tmp, tmax] = min(abs(Results.ImageGridTime-baseline(2)));
                
                baseline_new = [tmin tmax];
                
                test =  (sum(baseline_new == ...
                    Results.ZScore.Baseline) ~= 2); % New baseline requested - recompute Z-Score
                
            elseif test ~= 1 % Yes - Baseline was stored in a file - do not recompute the ZScore
                
                [tmp, tmin] = min(abs(Results.ImageGridTime-baseline(1)));
                [tmp, tmax] = min(abs(Results.ImageGridTime-baseline(2)));
                
                test = 0;
            
            elseif varargin{1} == 1 % Force computation
                [tmp, tmin] = min(abs(Results.ImageGridTime-baseline(1)));
                [tmp, tmax] = min(abs(Results.ImageGridTime-baseline(2)));
                
                test = 1;
                
            end
            
        else
            [tmp, tmin] = min(abs(Results.ImageGridTime-baseline(1)));
            [tmp, tmax] = min(abs(Results.ImageGridTime-baseline(2)));
            
            test = 1;
        end
        
        if 1%test
            
            set(tesselation_select_win,'Pointer','watch')
            
            disp('Computing a new Z-Score map from this baseline...'), drawnow
            
            disp(sprintf('Baseline is %d time samples large (out of %d samples available)',...
            tmax-tmin+1, length(Results.ImageGridTime)))
        
            % Store original results patter in memory
            if 1%(~isfield(Results,'ImageGridAmpOrig') & FlagBaselineFile == 0) | varargin{1} == 1
                 Results.ImageGridAmpOrig = Results.ImageGridAmp;
            end
            
            if FlagBaselineFile == 0 % remove the zero here !!!
                Results.ImageGridAmp = Results.ImageGridAmpOrig;
            end
                
            %Results.ImageGridAmp = abs(Results.ImageGridAmp);
            
            
            % Compute ZScores on that baseline
            Results.ZScore.Baseline = [tmin tmax];
            Results.ZScore.BaselineTime = [baseline(1) baseline(2)];
            
            % Average activity and its standard deviation over the baseline, for each source
            Results.ZScore.ImageGridZ.mean = ...
                mean((Results.ImageGridAmp(:,tmin:tmax)),2);
            Results.ZScore.ImageGridZ.std = ...
                std((Results.ImageGridAmp(:,tmin:tmax)),0,2);
            Results.ZScore.ImageGridZ.std = ...
                Results.ZScore.ImageGridZ.std + max(Results.ZScore.ImageGridZ.std)*eps; % Avoid devide-by-zero issues

            if ~isempty(get(hTSelect.CorrectionFactor,'String'))
                Results.ZScore.ImageGridZ.std = str2num(get(hTSelect.CorrectionFactor,'String'))*Results.ZScore.ImageGridZ.std;
            end
            
            % Compute Z-Scores
            if FlagBaselineFile == 1 % Now load current results
                ZScore = Results.ZScore; 
                Results = get(hTSelect.ResultFiles,'Userdata');
                Results.ZScore = ZScore; clear ZScore
                if ~isfield(Results,'ImageGridAmpOrig') 
                    Results.ImageGridAmpOrig = [];
                end
                if isempty(Results.ImageGridAmpOrig)
                    Results.ImageGridAmpOrig = Results.ImageGridAmp; % Store original current density map 
                end
                Results.ImageGridAmp = Results.ImageGridAmpOrig;
                Results.ZScore.BaselineFile = get(hTSelect.LoadBaseline,'Userdata');
                Results.ZScore.FlagBaselineFile = 1;
            else
                Results.ZScore.FlagBaselineFile = 0;
                Results.ZScore.BaselineFile = '';
            end
            
            disp('Updating Result File...'), drawnow
            Results.ImageGridAmp = Results.ImageGridAmpOrig;
            tmp = Results.ImageGridAmpOrig;
            Results.ImageGridAmpOrig = [];
            save_fieldnames(Results,get(hTSelect.Refresh,'Userdata'));
            %Results.ImageGridAmp = Results.ZScore.ImageGridZ.Amp;
            Results.ImageGridAmpOrig = tmp; clear tmp
                        
            Results.ImageGridAmp = (Results.ImageGridAmp)-repmat(Results.ZScore.ImageGridZ.mean,1,size(Results.ImageGridAmp,2));
            iStd = spdiags(1./Results.ZScore.ImageGridZ.std, 0, length(Results.ZScore.ImageGridZ.std), length(Results.ZScore.ImageGridZ.std)) ;
                       
            %Results.ZScore.ImageGridZ.Amp = Results.ImageGridAmp;

            disp('Computing a new Z-Score map from this baseline...-> DONE'), drawnow
            
        else % Compute ZScore from saved mean and std maps
            
            Results.ImageGridAmpOrig = Results.ImageGridAmp;
            %Results.ImageGridAmp= Results.ZScore.ImageGridZ.Amp ;
            
            Results.ImageGridAmp = (Results.ImageGridAmp)-repmat(Results.ZScore.ImageGridZ.mean,1,size(Results.ImageGridAmp,2));
            iStd = spdiags(1./Results.ZScore.ImageGridZ.std, 0, length(Results.ZScore.ImageGridZ.std), length(Results.ZScore.ImageGridZ.std)) ;

        end
        
        %Results.ImageGridAmp = rand(size(iStd*Results.ImageGridAmp));
        Results.ImageGridAmp = abs(iStd*Results.ImageGridAmp);
        
        set(tesselation_select_win,'Pointer','arrow')
            
    case 0 % Switch to absolute current density mapping
        
        Results = get(hTSelect.ResultFiles,'Userdata');
        
        disp('Previous Z-Score map on same baseline is used'), drawnow
        Results.ImageGridAmp = Results.ImageGridAmpOrig;
        set(hTSelect.ZScoreThresholdApply,'Value',0)
        dataplot_cb('ToggleButtonColor',hTSelect.ZScoreThresholdApply)
    end
    
    % Update display
    set(hTSelect.ResultFiles,'Userdata',Results);
    
    dataplot_cb tesselation_select_done
        
    %----------------------------------------------------------------------------
    
    
case 'AnalyzeCorticalMap' % Spatio-temporal segmentation of the cortical current density maps
    
    tesselation_select_win = findobj(0,'Tag','tesselation_select');
    hTessSelect = guihandles(tesselation_select_win);
    available = findobj(tesselation_select_win,'Tag','available');
    removed =  findobj(tesselation_select_win,'Tag','removed');
    availableID = get(removed,'Value');
    IDs = get(removed,'String');
    if isempty(IDs), return, end
    
    % Identification of the active mesh surfaces
    Visu = get(DATAPLOT,'Userdata');
    
    try
        load(Visu.Tesselation,'Comment')
    catch
        cd(Users.SUBJECTS)
        load(Visu.Tesselation,'Comment')
    end
    
    if ~iscell(IDs)
        imesh = find(strcmp(IDs,Comment));
    end
    
    nsurf = imesh(availableID); % Selected surface
    
    TessWin  = findobj(0,'tag','tessellation_window'); 
    hTessWin = guihandles(TessWin);
    TessWinUserData = get(TessWin,'Userdata');
    
    if ~isfield(TessWinUserData,'VertConn') % Vertex connectivity not available here - load or compute
        nsurfaces = length(Comment);
        
        % ----------------- Load current surface parameters - 
        load(Visu.Tesselation,'Faces','Vertices')
        FV.faces = Faces{nsurf}; clear Faces
        FV.vertices = Vertices{nsurf}'; clear Vertices
        % ----------------- Load current surface parameters - DONE
        
        load(Users.CurrentData.SubjectFile,'VertConn'); % Is the vertex connectivity available ?
        
        if isempty(VertConn) % Vertex connectivity was not defined before
            VertConn = cell(nsurfaces,1);
        else
            if exist(VertConn,'file')
                load(VertConn)
            else
                VertConn = cell(nsurfaces,1);
            end
        end
        
        if isempty(VertConn{nsurf}) % Compute the vertex connectivity
            [pathname, filename] = fileparts(Visu.Tesselation);    
            VertConn{nsurf} = vertices_connectivity(FV);
            clear FV
            VertConnFile = [filename,'_vertconn.mat'];

            % Save this file in the current subject folder
            [path,name,ext] = fileparts(Users.CurrentData.SubjectFile);
            if ~isempty(path)
                cd(path)
            else
                cd(Users.SUBJECTS)
            end
            
            save(VertConnFile,'VertConn'); 
            
            VertConn = VertConnFile;
            save(Users.CurrentData.SubjectFile,'VertConn','-append') 
        else % Load VC from the file
            load(Users.CurrentData.SubjectFile,'VertConn');
        end
        load(VertConn);
        VertConn = VertConn{nsurf};
        TessWinUserData.VertConn = VertConn; clear VertConn;    
    end
    
    
    % Get Z threshold
    ZThres = str2num(get(hTessSelect.ZScoreThreshold,'String'))  ;
    
    % Vertices which maximum Z score is above ZThres
    Results = get(hTessSelect.ResultFiles,'Userdata');
    ImageGridAmp =  Results.ImageGridAmp; clear Results
    
    % Get baseline info
    Results = get(hTessSelect.ResultFiles,'userdata');
    AnalyzeWin = [0 370]/1000; % in sec
    [tmp, tmin] = min(abs(Results.ImageGridTime-AnalyzeWin(1)));
    [tmp, tmax] = min(abs(Results.ImageGridTime-AnalyzeWin(2)));
    clear Results
    
    %Baseline = Results.ZScore.Baseline; clear Results
    %Time = Baseline(end)+1:size(ImageGridAmp,2); %setdiff([1:size(ImageGridAmp,2)],[Baseline(1):Baseline(end)]);
    
    Time = [tmin:tmax];
    
    MaxVerts = max(ImageGridAmp(:,Time)');
    iThres = find(MaxVerts > ZThres);
    % Threshold in terms of correlation
    CorrThres = .9; 
    
    Scout{1} = [];
    iScout = 1;
    imax = 1;
    
    % Sort MaxVerts
    [s, iMaxVertsSort] = sort(MaxVerts); clear s
    
    CONNEX = 0; % if 1; enforce connexity of each clusters 
    
   
  while ~isempty(imax)
      %%%% Segmentation process
      if iScout == 1 % We are starting from scratch
          % Initialization
          % Start region growing from the vertex with maximum ZScore
          imax = iMaxVertsSort(end);
      else
          tmp = setdiff(iMaxVertsSort,[Scout{:}]); 
          [mm, imax] = max(MaxVerts(tmp)); clear mm
          imax = tmp(imax);
      end
      
      % Does imax checks iThres
      if isempty(find(iThres == imax))
          break
      end
      
      
      if CONNEX == 1
          % Look for his neighbors
          voiz = patch_swell(imax,TessWinUserData.VertConn);
          % Select those that check the Zthres condition
          voiz = intersect(iThres,voiz);
    
      else % Just look for all the points above ZThres
          voiz = setdiff(iThres,imax);
      end
      
      % Remove those previously selected
      voiz = setdiff(voiz,[Scout{:}]);
      
      % Compute correlation coefficients of their time series
      %CorrCoeff = abs(corrcoef(ImageGridAmp([imax,voiz],Time)'));
      if ~isempty(voiz)
          CorrCoeff = abs(ImageGridAmp(imax,Time)/norm(ImageGridAmp(imax,Time)))...
          *abs(ImageGridAmp(voiz,Time)'*inorcol(ImageGridAmp(voiz,Time)'));
      else
          CorrCoeff = CorrThres/10;
      end
          
      % Apply Correlation Threshold
      %icorr = find(CorrCoeff(1,2:end)>CorrThres);
      icorr = find(CorrCoeff>CorrThres);
      
      Scout{iScout} = [imax,voiz(icorr)];
      
      while ~isempty(icorr)
          
          if CONNEX == 1
              voiz = patch_swell(voiz(icorr),TessWinUserData.VertConn);
              % Select those that check the Zthres condition
              voiz = intersect(iThres,voiz);
          else
              voiz = setdiff(iThres,imax);
          end
              
          % Remove those previously selected
          voiz = setdiff(voiz,[Scout{:}]);
          
          % Compute correlation coefficients of their time series
          %CorrCoeff = abs(corrcoef(ImageGridAmp([imax,voiz],Time)'));
          if ~isempty(voiz)
              CorrCoeff = abs(ImageGridAmp(imax,Time)/norm(ImageGridAmp(imax,Time)))...
              *abs(ImageGridAmp(voiz,Time)'*inorcol(ImageGridAmp(voiz,Time)'));

               CorrCoeffBaseLine = abs(ImageGridAmp(imax,125:500)/norm(ImageGridAmp(imax,125:500)))...
              *abs(ImageGridAmp(voiz,125:500)'*inorcol(ImageGridAmp(voiz,125:500)'));      
        else
            
              CorrCoeff = CorrThres/10;
          end
      
          % Apply Correlation Threshold
          %icorr = find(CorrCoeff(1,2:end)>CorrThres);
          icorr = find(CorrCoeff>CorrThres);
          
          Scout{iScout} = [Scout{iScout},voiz(icorr)];

      end
      
      if length([Scout{:}]) ~= length(unique([Scout{:}]))
          keyboard
      end
      
      length(iThres) - length([Scout{:}])
      
      CorticalScouts.CorticalProbePatches(iScout) = Scout(iScout); 
      CorticalScouts.CorticalMarkersLabels{iScout} = int2str(iScout);
      CorticalScouts.CorticalSpots(iScout) = imax;
      if iScout == 1
          load(Visu.Tesselation,'Vertices')
      end
      CorticalScouts.CorticalMarkers(iScout,:) = Vertices{nsurf}(:,Scout{iScout}(1));
      
      iScout = iScout+1;
      disp('')    
      
      
  end
  
  newScout = 1;
  
  for iScout = 1:length(Scout)
      if length(Scout{iScout}) == 1 % Single point scout: do we keep it ?
          % Check if its neighbors with activation < ZThres have time series that correlate with his with corrcoeff > CorrThres
          voiz = patch_swell(Scout{iScout},TessWinUserData.VertConn);
          
          if ~isempty(voiz)
              CorrCoeff = abs(ImageGridAmp(imax,Time)/norm(ImageGridAmp(imax,Time)))...
                  *abs(ImageGridAmp(voiz,Time)'*inorcol(ImageGridAmp(voiz,Time)'));
          else
              CorrCoeff = CorrThres/10;
          end
          
          icorr = find(CorrCoeff>CorrThres);
          
          if isempty(icorr)
              disp('Remove spurious Scout')
              %               Scout{iScout} = [];
              %               iScout = iScout - 1;
          else
              newCorticalScouts.CorticalProbePatches(newScout) = Scout(iScout); 
              newCorticalScouts.CorticalMarkersLabels{newScout} = int2str(newScout);
              newCorticalScouts.CorticalSpots(newScout) = Scout{iScout}(1);
              if newScout == 1
                  load(Visu.Tesselation,'Vertices')
              end
              newCorticalScouts.CorticalMarkers(newScout,:) = Vertices{nsurf}(:,Scout{iScout}(1));
              newScout = newScout + 1;
          end
          
      else
          newCorticalScouts.CorticalProbePatches(newScout) = Scout(iScout); 
          newCorticalScouts.CorticalMarkersLabels{newScout} = int2str(newScout);
          newCorticalScouts.CorticalSpots(newScout) = Scout{iScout}(1);
          if newScout == 1
              load(Visu.Tesselation,'Vertices')
          end
          newCorticalScouts.CorticalMarkers(newScout,:) = Vertices{nsurf}(:,Scout{iScout}(1));
          newScout = newScout + 1;
      end
  
      clear CorticalScouts
      CorticalScouts = newCorticalScouts;
      
  end
  
 
  CorticalScouts.VertConn = TessWinUserData.VertConn;
  CorticalScouts.CorticalProbeDepth = ones(1,length(Scout));
  
  cd(Users.STUDIES)
  
  length(CorticalScouts.CorticalProbePatches)
  
  save test CorticalScouts
  
  %----------------------------------------------------------------------------
case 'ShowClusters' % Show all cortical scouts/clusters at once
    tesselation_select_win = findobj(0,'Tag','tesselation_select');
    hTessSelect = guihandles(tesselation_select_win);
    available = findobj(tesselation_select_win,'Tag','available');
    removed =  findobj(tesselation_select_win,'Tag','removed');
    availableID = get(removed,'Value');
    IDs = get(removed,'String');
    if isempty(IDs), return, end
    
    % Identification of the active mesh surfaces
    Visu = get(DATAPLOT,'Userdata');
    
    try
        load(Visu.Tesselation,'Comment')
    catch
        cd(Users.SUBJECTS)
        load(Visu.Tesselation,'Comment')
    end
    
    if ~iscell(IDs)
        imesh = find(strcmp(IDs,Comment));
    end
    
    nsurf = imesh(availableID); % Selected surface
    
    TessWin  = findobj(0,'tag','tessellation_window'); 
    hTessWin = guihandles(TessWin);
    TessWinUserData = get(TessWin,'Userdata');
    
    if ~isfield(TessWinUserData,'VertConn') % Vertex connectivity not available here - load or compute
        nsurfaces = length(Comment);
        
        % ----------------- Load current surface parameters - 
        load(Visu.Tesselation,'Faces','Vertices')
        FV.faces = Faces{nsurf}; clear Faces
        FV.vertices = Vertices{nsurf}'; clear Vertices
        % ----------------- Load current surface parameters - DONE
        
        load(Users.CurrentData.SubjectFile,'VertConn'); % Is the vertex connectivity available ?
        
        if isempty(VertConn) % Vertex connectivity was not defined before
            VertConn = cell(nsurfaces,1);
        else
            if exist(VertConn,'file')
                load(VertConn)
            else
                VertConn = cell(nsurfaces,1);
            end
        end
        
        if isempty(VertConn{nsurf}) % Compute the vertex connectivity
            [pathname, filename] = fileparts(Visu.Tesselation);    
            VertConn{nsurf} = vertices_connectivity(FV);
            VertConnFile = [filename,'_vertconn.mat'];

            % Save this file in the current subject folder
            [path,name,ext] = fileparts(Users.CurrentData.SubjectFile);
            if ~isempty(path)
                cd(path)
            else
                cd(Users.SUBJECTS)
            end
            
            save(VertConnFile,'VertConn'); 
            
            VertConn = VertConnFile;
            save(Users.CurrentData.SubjectFile,'VertConn','-append') 
        else % Load VC from the file
            load(Users.CurrentData.SubjectFile,'VertConn');
        end
        load(VertConn);
        VertConn = VertConn{nsurf};
        TessWinUserData.VertConn = VertConn; clear VertConn;    
    end
    
    % Now grow a patch around the selected probe and selected neighbors
    
     SelectedArea = get(hTessSelect.CorticalSpotList,'Value');
%     if ~isfield(TessWinUserData,'CorticalProbePatches')
%         TessWinUserData.CorticalProbePatches = cell(get(hTessSelect.CorticalSpotList,'Max'),1);
%         TessWinUserData.CorticalProbeDepth = zeros(get(hTessSelect.CorticalSpotList,'Max'),1); % Number of patch_swells necessary to achieve the patch growth;
%     end
%     if length(TessWinUserData.CorticalProbePatches) < SelectedArea % User just added a new probe 
%         nareas = length(TessWinUserData.CorticalProbePatches);
%         TessWinUserData.CorticalProbePatches(nareas+1:SelectedArea) = cell(SelectedArea-nareas,1);   
%         TessWinUserData.CorticalProbeDepth(nareas+1:SelectedArea) = 0;
%     end
    
%     if isempty(TessWinUserData.CorticalProbePatches{SelectedArea}) % No areas around patches were defined
%         TessWinUserData.CorticalProbeDepth(SelectedArea) = 1;
%         TessWinUserData.CorticalProbePatches{SelectedArea} = ...
%             [TessWinUserData.CorticalSpots(SelectedArea),patch_swell(TessWinUserData.CorticalSpots(SelectedArea),TessWinUserData.VertConn)];
%     else
%         TessWinUserData.CorticalProbeDepth(SelectedArea) = TessWinUserData.CorticalProbeDepth(SelectedArea) +1;
%         TessWinUserData.CorticalProbePatches{SelectedArea} = [TessWinUserData.CorticalProbePatches{SelectedArea},...
%                 patch_swell([TessWinUserData.CorticalProbePatches{SelectedArea}],TessWinUserData.VertConn)];
%     end
    
    ActiveTess = get(hTessSelect.removed,'String'); % Find the active scalp surface
    iCortex = get(hTessSelect.removed,'Value'); % Find the active scalp surface    
    if isempty(iCortex)
        h = msgbox('Please select a cortex surface from the tessellations available.');
        return
    end
    if iscell(ActiveTess)
        Cortex = findobj(get(TessWin,'CurrentAxes'),'Type','patch','Tag',ActiveTess{iCortex}); %CHEAT - need to be improved ?
    else
        Cortex = findobj(get(TessWin,'CurrentAxes'),'Type','patch','Tag',ActiveTess); %CHEAT - need to be improved ?    
    end

    FVCData = get(Cortex,'FaceVertexCData');
    MM = max(abs(FVCData));
    if size(FVCData,2) == 1 % No curvature mapping
        FVCData = .1*MM*ones(size(FVCData));
    else
       FVCData = repmat(MM,size(FVCData,1),1);
    end 
    
    if ~isfield(TessWinUserData,'FVCData')
        TessWinUserData.FVCData = FVCData; % Keep track of the original activation vertex colordata
    end
    
    if size(FVCData,2) == 1 % No curvature mapping
        FVCData([ TessWinUserData.CorticalProbePatches{SelectedArea} ]) = MM;
    else
        FVCData([ TessWinUserData.CorticalProbePatches{SelectedArea} ],:) = repmat(MM,length(TessWinUserData.CorticalProbePatches{SelectedArea} ),1);
    end
    
    set(Cortex,'FaceVertexCData',FVCData);

    set(Cortex,'FaceVertexCData',FVCData);
    set(TessWin,'Userdata',TessWinUserData)    
    
    
    %----------------------------------------------------------------------------

    %----------------------------------------------------------------------------
case 'GrowCorticalArea' % Grow a survey cortical area around a probe to include connected vertices
    tesselation_select_win = findobj(0,'Tag','tesselation_select');
    hTessSelect = guihandles(tesselation_select_win);
    available = findobj(tesselation_select_win,'Tag','available');
    removed =  findobj(tesselation_select_win,'Tag','removed');
    availableID = get(removed,'Value');
    IDs = get(removed,'String');
    if isempty(IDs), return, end
    
    % Identification of the active mesh surfaces
    Visu = get(DATAPLOT,'Userdata');
    
    try
        load(Visu.Tesselation,'Comment')
    catch
        cd(Users.SUBJECTS)
        load(Visu.Tesselation,'Comment')
    end
    
    if ~iscell(IDs)
        imesh = find(strcmp(IDs,Comment));
    end
    
    nsurf = imesh(availableID); % Selected surface
    
    TessWin  = findobj(0,'tag','tessellation_window'); 
    hTessWin = guihandles(TessWin);
    TessWinUserData = get(TessWin,'Userdata');
    
    if ~isfield(TessWinUserData,'VertConn') % Vertex connectivity not available here - load or compute
        nsurfaces = length(Comment);
        
        % ----------------- Load current surface parameters - 
        load(Visu.Tesselation,'Faces','Vertices')
        FV.faces = Faces{nsurf}; clear Faces
        FV.vertices = Vertices{nsurf}'; clear Vertices
        % ----------------- Load current surface parameters - DONE
        
        load(Users.CurrentData.SubjectFile,'VertConn'); % Is the vertex connectivity available ?
        
        if isempty(VertConn) % Vertex connectivity was not defined before
            VertConn = cell(nsurfaces,1);
        else
            if exist(VertConn,'file')
                load(VertConn)
            else
                VertConn = cell(nsurfaces,1);
            end
        end
        
        if isempty(VertConn{nsurf}) % Compute the vertex connectivity
            [pathname, filename] = fileparts(Visu.Tesselation);    
            VertConn{nsurf} = vertices_connectivity(FV);
            VertConnFile = [filename,'_vertconn.mat'];

            % Save this file in the current subject folder
            [path,name,ext] = fileparts(Users.CurrentData.SubjectFile);
            if ~isempty(path)
                cd(path)
            else
                cd(Users.SUBJECTS)
            end
            
            save(VertConnFile,'VertConn'); 
            
            VertConn = VertConnFile;
            save(Users.CurrentData.SubjectFile,'VertConn','-append') 
        else % Load VC from the file
            load(Users.CurrentData.SubjectFile,'VertConn');
        end
        load(VertConn);
        VertConn = VertConn{nsurf};
        TessWinUserData.VertConn = VertConn; clear VertConn;    
    end
    
    % Now grow a patch around the selected probe and selected neighbors
    
    SelectedArea = get(hTessSelect.CorticalSpotList,'Value');
    if ~isfield(TessWinUserData,'CorticalProbePatches')
        TessWinUserData.CorticalProbePatches = cell(get(hTessSelect.CorticalSpotList,'Max'),1);
        TessWinUserData.CorticalProbeDepth = zeros(get(hTessSelect.CorticalSpotList,'Max'),1); % Number of patch_swells necessary to achieve the patch growth;
    end
    if length(TessWinUserData.CorticalProbePatches) < SelectedArea % User just added a new probe 
        nareas = length(TessWinUserData.CorticalProbePatches);
        TessWinUserData.CorticalProbePatches(nareas+1:SelectedArea) = cell(SelectedArea-nareas,1);   
        TessWinUserData.CorticalProbeDepth(nareas+1:SelectedArea) = 0;
    end
    
    if isempty(TessWinUserData.CorticalProbePatches{SelectedArea}) % No areas around patches were defined
        TessWinUserData.CorticalProbeDepth(SelectedArea) = 1;
        TessWinUserData.CorticalProbePatches{SelectedArea} = ...
            [TessWinUserData.CorticalSpots(SelectedArea),patch_swell(TessWinUserData.CorticalSpots(SelectedArea),TessWinUserData.VertConn)];
    else
        TessWinUserData.CorticalProbeDepth(SelectedArea) = TessWinUserData.CorticalProbeDepth(SelectedArea) +1;
        TessWinUserData.CorticalProbePatches{SelectedArea} = [TessWinUserData.CorticalProbePatches{SelectedArea},...
                patch_swell([TessWinUserData.CorticalProbePatches{SelectedArea}],TessWinUserData.VertConn)];
    end
    
    ActiveTess = get(hTessSelect.removed,'String'); % Find the active scalp surface
    iCortex = get(hTessSelect.removed,'Value'); % Find the active scalp surface    
    if isempty(iCortex)
        h = msgbox('Please select a cortex surface from the tessellations available.');
        return
    end
    if iscell(ActiveTess)
        Cortex = findobj(get(TessWin,'CurrentAxes'),'Type','patch','Tag',ActiveTess{iCortex}); %CHEAT - need to be improved ?
    else
        Cortex = findobj(get(TessWin,'CurrentAxes'),'Type','patch','Tag',ActiveTess); %CHEAT - need to be improved ?    
    end
    
    FVCData = get(Cortex,'FaceVertexCData');
    
    if ~isfield(TessWinUserData,'FVCData')
        TessWinUserData.FVCData = FVCData; % Keep track of the original activation vertex colordata
    end
    
    if size(FVCData,2) == 1 % No curvature mapping
        FVCData([ TessWinUserData.CorticalProbePatches{SelectedArea} ]) = max(abs(FVCData));
    else
        FVCData([ TessWinUserData.CorticalProbePatches{SelectedArea} ],:) = repmat(max(abs(FVCData)),length(TessWinUserData.CorticalProbePatches{SelectedArea} ),1);
    end
    
    set(Cortex,'FaceVertexCData',FVCData);
    set(TessWin,'Userdata',TessWinUserData)    
    
    
    %----------------------------------------------------------------------------
case 'ReduceCorticalArea' % See above 'GrowCorticalArea' -  except we are here reducing the size of the survey cortical zone to monitor
    tesselation_select_win = findobj(0,'Tag','tesselation_select');
    hTessSelect = guihandles(tesselation_select_win);
    available = findobj(tesselation_select_win,'Tag','available');
    removed =  findobj(tesselation_select_win,'Tag','removed');
    availableID = get(removed,'Value');
    IDs = get(removed,'String');
    if isempty(IDs), return, end
    
    % Identification of the active mesh surfaces
    Visu = get(DATAPLOT,'Userdata');
    
    try
        load(Visu.Tesselation,'Comment')
    catch
        cd(Users.SUBJECTS)
        load(Visu.Tesselation,'Comment')
    end
    
    if ~iscell(IDs)
        imesh = find(strcmp(IDs,Comment));
    end
    
    nsurf = imesh(availableID); % Selected surface
    
    TessWin  = findobj(0,'tag','tessellation_window'); 
    hTessWin = guihandles(TessWin);
    TessWinUserData = get(TessWin,'Userdata');
    
    if ~isfield(TessWinUserData,'VertConn') % Vertex connectivity not available here - load or compute
        nsurfaces = length(Comment);
        
        % ----------------- Load current surface parameters - 
        load(Visu.Tesselation,'Faces','Vertices')
        FV.faces = Faces{nsurf}; clear Faces
        FV.vertices = Vertices{nsurf}'; clear Vertices
        % ----------------- Load current surface parameters - DONE
        
        load(Users.CurrentData.SubjectFile,'VertConn'); % Is the vertex connectivity available ?
        
        if isempty(VertConn) % Vertex connectivity was not defined before
            VertConn = cell(nsurfaces,1);
        else
            if exist(VertConn,'file')
                load(VertConn)
            else
                VertConn = cell(nsurfaces,1);
            end
        end
        
        if isempty(VertConn{nsurf}) % Compute the vertex connectivity
            [pathname, filename] = fileparts(Visu.Tesselation);    
            VertConn{nsurf} = vertices_connectivity(FV);
            VertConnFile = [filename,'_vertconn.mat'];
            
            save(VertConnFile,'VertConn'); 
            
            VertConn = VertConnFile;
            save(Users.CurrentData.SubjectFile,'VertConn','-append') 
        else % Load VC from the file
            load(Users.CurrentData.SubjectFile,'VertConn');
        end
        load(VertConn);
        VertConn = VertConn{nsurf};
        TessWinUserData.VertConn = VertConn; clear VertConn;    
    end
    
    
    % Now grow a patch around the selected probe and selected neighbors
    SelectedArea = get(hTessSelect.CorticalSpotList,'Value');
    
    tmp = [];
    
    for k = 1:TessWinUserData.CorticalProbeDepth(SelectedArea)-1
        if k == 1
            tmp = ...
                patch_swell(TessWinUserData.CorticalSpots(SelectedArea),TessWinUserData.VertConn);
        else
            tmp = ...
                [tmp,patch_swell(tmp,TessWinUserData.VertConn)];
        end
    end
    
    TessWinUserData.CorticalProbeDepth(SelectedArea) = max([TessWinUserData.CorticalProbeDepth(SelectedArea)-1,0]);
    
    ActiveTess = get(hTessSelect.removed,'String'); % Find the active scalp surface
    iCortex = get(hTessSelect.removed,'Value'); % Find the active scalp surface    
    
    if isempty(iCortex)
        h = msgbox('Please select a cortex surface from the tessellations available.');
        return
    end
    if iscell(ActiveTess)
        Cortex = findobj(get(TessWin,'CurrentAxes'),'Type','patch','Tag',ActiveTess{iCortex}); %CHEAT - need to be improved ?
    else
        Cortex = findobj(get(TessWin,'CurrentAxes'),'Type','patch','Tag',ActiveTess); %CHEAT - need to be improved ?    
    end
    FVCData = get(Cortex,'FaceVertexCData');
    old_members = intersect(TessWinUserData.CorticalProbePatches{SelectedArea},tmp); % Older members of the cortical survey zone (keep them)
    if isempty(old_members)
        old_members = TessWinUserData.CorticalSpots(SelectedArea);
    end
    new_members = setdiff(TessWinUserData.CorticalProbePatches{SelectedArea},tmp); % Last members of the cortical survey zone (remove them)
    
    if size(FVCData,2) == 1 % No curvature mapping
        FVCData(new_members) =  TessWinUserData.FVCData(new_members); % Reset their color to original
    else
        FVCData(new_members,:) =  TessWinUserData.FVCData(new_members,:); % Reset their color to original
    end
    
    TessWinUserData.CorticalProbePatches{SelectedArea} = old_members;
    
    if size(FVCData,2) == 1 % No curvature mapping
        FVCData([ TessWinUserData.CorticalProbePatches{SelectedArea} ]) = max(abs(FVCData));
    else
        FVCData([ TessWinUserData.CorticalProbePatches{SelectedArea} ],:) = repmat(max(abs(FVCData)),length(TessWinUserData.CorticalProbePatches{SelectedArea} ),1);
    end
        
    set(Cortex,'FaceVertexCData', TessWinUserData.FVCData)
    set(Cortex,'FaceVertexCData',FVCData);
    
    set(TessWin,'Userdata',TessWinUserData)    
    
    
    %----------------------------------------------------------------------------
case 'CorticalSpotActivity'
    tesselation_select_win = findobj(0,'Tag','tesselation_select');
    hTessSelect = guihandles(tesselation_select_win);
    
    % What kind of display is wanted here ?
    MEAN = get( hTessSelect.MeanCorticalArea,'Value');
    MAX = get(hTessSelect.MaxCorticalArea,'Value');
    ALL = get(hTessSelect.AllCorticalArea,'Value');
    
    SelectedArea = get(hTessSelect.CorticalSpotList,'Value');
    
    TessWin  = findobj(0,'tag','tessellation_window'); 
    hTessWin = guihandles(TessWin);
    TessWinUserData = get(TessWin,'Userdata');
    
    Results = get(hTessSelect.ResultFiles,'Userdata');

    if get(hTessSelect.ZScoreThresholdApply,'Value') % Threshold is applied on ZScore map: indicate significant Z Scores time samples
        flagZScoreT = 1;
        flagHisto = 0;    
    else
        flagZScoreT = 0;
        if get(hTessSelect.ZScore,'Value')
            flagZScore = 1;
            flagHisto = 0;    
        else
            flagZScore = 0;
            % !!! CorticalActivity is scaled to nA.m
            if max(abs(Results.ImageGridAmp(:))) < 1e-5 % Probably dipole moment values - scale to nA.m
                flagHisto = 0;
                Results.ImageGridAmp = 1e9*Results.ImageGridAmp;    
            else
                % This is a plot of histogram of activations
                flagHisto = 1;
            end
            
        end
        
    end
    

    if ~isfield(TessWinUserData,'CorticalProbePatches')
        if get(hTessSelect.AbsoluteCurrent,'Value')
            CorticalActivity = abs(Results.ImageGridAmp(TessWinUserData.CorticalSpots(SelectedArea),:));
        else
            CorticalActivity = Results.ImageGridAmp(TessWinUserData.CorticalSpots(SelectedArea),:);
        end
    else
        for k = 1:length(SelectedArea) % For each cortical survey area
            if length(TessWinUserData.CorticalProbePatches{SelectedArea(k)})>1
                if MEAN == 1% Average of the patch activity at each time instant
                    if get(hTessSelect.AbsoluteCurrent,'Value')
                        CorticalActivity(k,:) = mean(abs(Results.ImageGridAmp(TessWinUserData.CorticalProbePatches{SelectedArea(k)},:)));
                    else
                        CorticalActivity(k,:) = sign(mean(Results.ImageGridAmp(TessWinUserData.CorticalProbePatches{SelectedArea(k)},:)))...
                            .* mean((Results.ImageGridAmp(TessWinUserData.CorticalProbePatches{SelectedArea(k)},:))) ;
                    end
                elseif MAX==1 % Strongest
                    nor = 1e9*norlig(Results.ImageGridAmp(TessWinUserData.CorticalProbePatches{SelectedArea(k)},:));
                    [m,iMax] = max(nor);
                    if get(hTessSelect.AbsoluteCurrent,'Value')
                        CorticalActivity(k,:) = max(abs(Results.ImageGridAmp(TessWinUserData.CorticalProbePatches{SelectedArea(k)},:)));
                    else
                        CorticalActivity(k,:) = max(Results.ImageGridAmp(TessWinUserData.CorticalProbePatches{SelectedArea(k)},:));
                    end
                    
                else % Display every source activity in the patch
                    % All sources need to be displayed
                    if get(hTessSelect.AbsoluteCurrent,'Value')
                        CorticalActivity{k} = abs(Results.ImageGridAmp(TessWinUserData.CorticalProbePatches{SelectedArea(k)},:));
                    else
                        CorticalActivity{k} = Results.ImageGridAmp(TessWinUserData.CorticalProbePatches{SelectedArea(k)},:);
                    end
                    % Detect Maxima in amplitudes (needed for proper display in the offset plot)
                    maxCorticalActivity(k,:) = sign(min(CorticalActivity{k})).*max(abs(CorticalActivity{k}));
                  end
            else
                if get(hTessSelect.AbsoluteCurrent,'Value')
                    tmp = abs(Results.ImageGridAmp(TessWinUserData.CorticalSpots(SelectedArea(k)),:));
                else
                    tmp = Results.ImageGridAmp(TessWinUserData.CorticalSpots(SelectedArea(k)),:);
                end
                if (MEAN | MAX)
                    CorticalActivity(k,:) = tmp; clear tmp
                else
                    CorticalActivity{k} = tmp; clear tmp
                    maxCorticalActivity(k,:) = CorticalActivity{k};
                end
            end
        end
    end
    
    t = 1000*Results.ImageGridTime;
    fActivation = figure;
    % Display set-up
    switch(find([MEAN,MAX,ALL]))
    case 1
        tail = 'MEAN';
    case 2
        tail = 'MAX';
    case 3
        tail = 'ALL';
    end
    
    set(gcf,'Tag','source_time_series','Name',['Activation time series: ', tail],'color','w' )
    Color = get(gca,'ColorOrder'); % Default Colormapping for line plots

    if ~iscell(CorticalActivity)
        S = CorticalActivity';
        
        %         %Sn = colnorm(S);
        %         %Sn = S./Sn(ones(1,size(S,1)),:);
        %         % each waveform is now unity in norm. Weight
        %         %  by its total contribution to the field
        %         %Snw = Sn .* (ones(size(S,1),1)*(colnorm(A).*colnorm(S)));
        %         [outmatnw, col_offsetnw] = offset(S);
        %         plot(t,outmatnw,'linewidth',1),
        %         hold on
        %         plot(t,col_offsetnw,'linewidth',2) % want same color order as data
        
        % Get Max amplitude and apply to all axes
        M = max(abs(S(:)));
        for k = 1:size(CorticalActivity,1)
            subplot(size(CorticalActivity,1)+1,1,k) % One-column display
            plot(t,CorticalActivity(k,:),'color',Color(modulo(k,size(Color,1)),:),'Tag','AllSamples')
            hold on 
            set(gca,'XlimMode','manual')
            if get(hTessSelect.AbsoluteCurrent,'Value')
                axis([t(1) t(end) 0 M+.05*M])
            else
                axis([t(1) t(end) -M-.05*M M+.05*M])
            end

            
            if flagZScoreT == 1 % Add markers for significant amplitudes along time 
                iZeroed = find(...
                    abs(CorticalActivity(k,:)) ...
                    -  Results.ZScore.ImageGridZ.ZThres...
                    <=0);
                CorticalActivity(k,iZeroed) = NaN;
                hold on
                if length(iZeroed) ~= length(CorticalActivity(k,:))
                    plot(t,CorticalActivity(k,:),'color',Color(modulo(k,size(Color,1)),:),'linewidth',2,'Tag','SignificantSamples')
                end
                
            end
            
            if 0 < t(end) & 0 > t(1)
                if get(hTessSelect.AbsoluteCurrent,'Value')
                    line([0 0], [0 M+.05*M],'color','k','linestyle','--')
                else
                    line([0 0] ,[-M-.05*M M+.05*M],'color','k','linestyle','--')
                end
            end

            % Plastic Surgery to Axes Display
            set(gca,'box','off','XGrid','off','FontUnits','Points','fontsize',9,'LineWidth',2)
           
            Label = get(TessWinUserData.CorticalMarkersLabels(SelectedArea(k)),'String');

            if flagZScoreT == 1
                if length(iZeroed) ~= length(CorticalActivity(k,:))
                    hLeg = legend(sprintf(...
                        '%s',Label),...
                        sprintf('p<%4.2f', 1/Results.ZScore.ImageGridZ.ZThres^2)...
                        ,0);  
                else
                    hLeg = legend(sprintf(...
                        '%s (n.s.)',Label),0);
                    
                end
                
            else
                hLeg = legend(sprintf(...
                    '%s',Label)...
                    );    
            end
            
            %set(hLeg,'color',Color(modulo(k,size(Color,1)),:),'fontsize',9)
            %legend('boxoff')
            
            if flagZScoreT == 1
                line([t(1) t(end)], [Results.ZScore.ImageGridZ.ZThres Results.ZScore.ImageGridZ.ZThres],...
                    'Color',Color(modulo(k,size(Color,1)),:),'linestyle','--')
                if k==1 
                    if flagHisto == 0
                        ylabel(['Z-Score (\bf\sigma)'],'fontunits','point')
                    else
                        ylabel(['% Spikes'],'fontunits','point')    
                    end
                    
                    xlabel('time (ms)','fontunits','point','fontsize',9)
                end
                
                hold off
            else
                if k == 1
                    if flagZScore == 0
                        if flagHisto == 0
                            ylabel(['nA\cdotm'],'fontunits','point')    
                        else
                            ylabel(['% Spikes'],'fontunits','point')
                        end

                    else
                        if flagHisto == 0
                            ylabel(['Z-Score (\bf\sigma)'],'fontunits','point')
                        else
                            ylabel(['% Spikes'],'fontunits','point')
                        end
                        
                    end
                    xlabel('time (ms)','fontunits','point','fontsize',9)
                end
            end
            
            % Summary plot
            subplot(size(CorticalActivity,1)+1,1,size(CorticalActivity,1)+1) 
            plot(t,CorticalActivity(k,:),'color',Color(modulo(k,size(Color,1)),:),'Tag','AllSamples')
            hold on
            set(gca,'XlimMode','manual')
            set(gca,'box','off','XGrid','off','FontUnits','point','fontsize',10,'LineWidth',2)
            if get(hTessSelect.AbsoluteCurrent,'Value')
                axis([t(1) t(end) 0 M+.05*M])
            else
                axis([t(1) t(end) -M-.05*M M+.05*M])
            end
            
            if 0 < t(end) & 0 > t(1)
                if get(hTessSelect.AbsoluteCurrent,'Value')
                    line([0 0], [0 M+.05*M],'color','k','linestyle','--')
                else
                    line([0 0] ,[-M-.05*M M+.05*M],'color','k','linestyle','--')
                end
            end

            if flagZScoreT == 1
                line([t(1) t(end)], [Results.ZScore.ImageGridZ.ZThres Results.ZScore.ImageGridZ.ZThres],...
                    'Color',Color(modulo(k,size(Color,1)),:),'linestyle','--')
                if k==1 
                    ylabel(['Z-Score (\bf\sigma)'],'fontunits','point')
                    xlabel('time (ms)','fontunits','point','fontsize',9)
                end
            else
                if k == 1
                    if flagZScore == 0
                        if flagHisto == 0
                            ylabel(['nA\cdotm'],'fontunits','point')    
                        else
                            ylabel(['% Spikes'],'fontunits','point')
                        end

                    else
                        if flagHisto == 0
                            ylabel(['Z-Score (\bf\sigma)'],'fontunits','point')
                        else
                            ylabel(['% Spikes'],'fontunits','point')
                        end
                    end 
                    xlabel('time (ms)','fontunits','point','fontsize',9)
                end
            end

            
            
            %----------------
            
            
        end
        
    else
    
        % Find MAX
        for k = 1:length(CorticalActivity)
            M(k) = max(abs([CorticalActivity{k}(:)]));
        end
        M = max(M);
        for k = 1:length(CorticalActivity)
            subplot(length(CorticalActivity)+1,1,k) % One-column display
            plot(t,CorticalActivity{k},'color',Color(modulo(k,size(Color,1)),:))
            hold on

            set(gca,'XlimMode','manual')
            if get(hTessSelect.AbsoluteCurrent,'Value')
                axis([t(1) t(end) 0 M+.05*M])
            else
                axis([t(1) t(end) -M-.05*M M+.05*M])
            end
            
            
            if flagZScoreT == 1 % Add markers for significant amplitudes along time 
                iZeroed = find(...
                    abs(CorticalActivity{k}) ...
                    -  Results.ZScore.ImageGridZ.ZThres...
                    <=0);
                CorticalActivity{k}(iZeroed) = NaN;
                hold on
                if length(iZeroed) ~= length(CorticalActivity{k}(:))
                    plot(t,CorticalActivity{k},'color',Color(modulo(k,size(Color,1)),:),'linewidth',2,'Tag','SignificantSamples')
                end
                if k== 1
                    if flagHisto == 0
                        ylabel(['Z-Score (\bf\sigma)'],'fontunits','point')
                    else
                        ylabel(['% Spikes'],'fontunits','point')
                    end
                    
                    xlabel('time (ms)','fontunits','point')
                end
                
            else
                if k==1
                    if flagZScore == 0
                        if flagHisto == 0
                            ylabel(['nA\cdotm'],'fontunits','point')    
                        else
                            ylabel(['% Spikes'],'fontunits','point')
                        end

                    else
                        if flagHisto == 0
                            ylabel(['Z-Score (\bf\sigma)'],'fontunits','point')
                        else
                            ylabel(['% Spikes'],'fontunits','point')
                        end
                        
                    end
                    xlabel('time (ms)','fontunits','point')
                end
                
            end
            
            if 0 < t(end) & 0 > t(1)
                if get(hTessSelect.AbsoluteCurrent,'Value')
                    line([0 0], [0 M+.05*M],'color','k','linestyle','--')
                else
                    line([0 0] ,[-M-.05*M M+.05*M],'color','k','linestyle','--')
                end
            end
            
            % Plastic Surgery to Axes Display
            set(gca,'box','off','XGrid','off','FontUnits','point','fontsize',10,'LineWidth',2)
            Label = get(TessWinUserData.CorticalMarkersLabels(SelectedArea(k)),'String');
            %             title(sprintf(...
            %             '   Area: %s',Label)...
            %                 );    
            if flagZScoreT == 1
                if length(iZeroed) ~= length(CorticalActivity{k})
                    hLeg = legend(sprintf(...
                        '%s',Label),...
                        sprintf('p<%4.2f', 1/Results.ZScore.ImageGridZ.ZThres^2)...
                        ,0);    
                else
                    hLeg = legend(sprintf(...
                        '%s (n.s.)',Label),0);
                end
                
            else
                hLeg = legend(sprintf(...
                    '   Area: %s',Label)...
                    ,0);    
            end
            
            %set(hLeg,'color',Color(modulo(k,size(Color,1)),:),'fontunits','points','fontsize',9)
            %set(findobj(get(hLeg,'children'),'type','text'),'color',Color(modulo(k,size(Color,1)),:))
            %%legend('boxoff')
                     
            %         S = maxCorticalActivity';
            %         [outmatnw, col_offsetnw] = offset(S);
            %         off = plot(t,col_offsetnw,'linewidth',2); % want same color order as data
            %         hold on
            %         for k = 1:length(CorticalActivity)
            %         Src = CorticalActivity{k} + repmat(col_offsetnw(:,k)',size(CorticalActivity{k},1),1);
            %         plot(t,Src,'linewidth',1,'color',get(off(k),'color')),
            %         set(off(k),'color',[.4 .4 .4])    
            

            % Summary plot
            subplot(length(CorticalActivity)+1,1,length(CorticalActivity)+1) 
            plot(t,CorticalActivity{k},'color',Color(modulo(k,size(Color,1)),:),'Tag','AllSamples')
            hold on
            set(gca,'XlimMode','manual')
            set(gca,'box','off','XGrid','off','FontUnits','point','fontsize',10,'LineWidth',2)
            if get(hTessSelect.AbsoluteCurrent,'Value')
                axis([t(1) t(end) 0 M+.05*M])
            else
                axis([t(1) t(end) -M-.05*M M+.05*M])
            end
            
            if 0 < t(end) & 0 > t(1)
                if get(hTessSelect.AbsoluteCurrent,'Value')
                    line([0 0], [0 M+.05*M],'color','k','linestyle','--')
                else
                    line([0 0] ,[-M-.05*M M+.05*M],'color','k','linestyle','--')
                end
            end

            
            if flagZScoreT == 1
                line([t(1) t(end)], [Results.ZScore.ImageGridZ.ZThres Results.ZScore.ImageGridZ.ZThres],...
                    'Color',Color(modulo(k,size(Color,1)),:),'linestyle','--')
                hold off
            end

            if flagZScoreT == 1
                line([t(1) t(end)], [Results.ZScore.ImageGridZ.ZThres Results.ZScore.ImageGridZ.ZThres],...
                    'Color',Color(modulo(k,size(Color,1)),:),'linestyle','--')
                if k==1 
                    if flagHisto == 0
                        ylabel(['Z-Score (\bf\sigma)'],'fontunits','point')
                    else
                        ylabel(['% Spikes'],'fontunits','point')
                    end
                    
                    xlabel('time (ms)','fontunits','point','fontsize',9)
                end
                
                hold off
            else
                if k == 1
                    if flagZScore == 0
                        if flagHisto == 0
                            ylabel(['nA\cdotm'],'fontunits','point')    
                        else
                            ylabel(['% Spikes'],'fontunits','point')
                        end
                    else
                        if flagHisto == 0
                            ylabel(['Z-Score (\bf\sigma)'],'fontunits','point')
                        else
                            ylabel(['% Spikes'],'fontunits','point')
                        end
                    
                    end
                    xlabel('time (ms)','fontunits','point','fontsize',9)
                end
            end

            
            %----------------

    
            
        end
    end
    
    hold off
    
    %     for i = 1:size(S,2)
    %         Label = get(TessWinUserData.CorticalMarkersLabels(SelectedArea(i)),'String');
    %         htext = text(t(end),col_offsetnw(end,i),sprintf(...
    %             '   Area: %s',Label)...
    %             ,'color','k');
    %         set(htext, 'FontUnits','Normal','FontName','Helvetica')
    %     end
    
    %     zoom on
    %     set(gca,'xgrid','on','xcolor','k','ycolor','k','box','on')
    %     set(gca,'yticklabel',[])
    %     set(gca,'Position',[.05 .10 .75 .9])
    %     drawnow
    
    % Draw Source Time Cursor
    if 0
        figsingle = findobj(0,'Tag','source_time_series'); 
        src_slider_time = findobj(SRC_MAPPING,'Tag','src_slider_time');
        ctime = get(src_slider_time,'Value');
        cursor = line([ctime ctime],get(gca,'Ylim'));
        set(cursor,'color','r','linewidth',3,'Tag','cursor','erasemode','Xor')
    end

    %----------------------------------------------------------------------------
case 'tesselation_select_done' % Launch/Refresh Mesh Surface Visulization
    Visu = get(DATAPLOT,'Userdata');
    TessSelect = findobj(0,'Tag','tesselation_select');
    hSelect = guihandles(TessSelect);
    
    available = findobj(TessSelect,'Tag','available');
    removed =  findobj(TessSelect,'Tag','removed');
        
    previous  = findobj(0,'tag','tessellation_window');
    tmp  = findobj(0,'tag','subplot_tess_window');
    if ~isempty(tmp)
        previous = tmp; % Consider the slides or movie window
    end
    
    if isempty(previous)
        previous = open('tessellation_window.fig');
        set(previous,'CurrentAxes',findobj(previous,'Tag','MainAxis'),...
            'Renderer','OpenGL',...
            'Color','w', 'Colormap',gray);
        rotate3d on
        set(hSelect.TruncateFactor,'String',0)
        set(hSelect.ColorMAP,'Userdata',[])
        set(hSelect.ScaleColormap,'Userdata',[])
        
        availableID = get(removed,'Value');
        IDs = get(removed,'String');
        if isempty(IDs), return, end
        chan = [1:length(IDs)];
        
        try
            load(Visu.Tesselation)
        catch
            cd(Users.SUBJECTS)
            load(Visu.Tesselation)
        end
        
        % How many meshes available ?
        nmesh = max(size(Vertices));
        
        % Identification of the active mesh surfaces
        if ischar(IDs) % only one envelope was selected
            imesh =  find(strcmp(IDs,Comment));
        else
            for i = 1:length(IDs)
                imesh(i) = find(strcmp(IDs(i),Comment));
            end
        end
        
        Vals = get(removed,'Userdata');
        if isempty(Vals)
            Vals = [ones(nmesh,1),zeros(nmesh,8)];
        end
        Vals = set(removed,'Userdata');
        nsurf = imesh(availableID); % Selected surface
        set(hSelect.Apply,'Userdata',{imesh,nsurf,Comment,Vertices,Faces})
    else
        tmp = get(hSelect.Apply,'Userdata');
        imesh = tmp{1};
        nsurf = tmp{2};
        Comment = tmp{3};
        Vertices = tmp{4};
        Faces = tmp{5};    
    end
    figure(previous)
    
    Vals = get(removed,'Userdata');
    
    FragmentMenu = findobj(gcbf,'Tag','FragmentMenu');
    nclust = get(FragmentMenu,'Value')-1; % Get label of clustering to visualize 
    
    TAG = get(hSelect.OrthoViews,'Value');
    
    if TAG == 1
        OrthoViews = 1;
    else
        OrthoViews = 0;
    end
    hpatch = [];
    if OrthoViews == 0
        hpatch = findobj(findobj(previous,'Tag','MainAxes'),'Type','patch','Visible','on');
    else
        if ~isempty(findobj(findobj(previous,'Tag','axsub1'),'Type','patch'))
            hpatch(1) = findobj(findobj(previous,'Tag','axsub1'),'type','patch');
            hpatch(2) =  findobj(findobj(previous,'Tag','axsub2'),'type','patch');
            hpatch(3) =  findobj(findobj(previous,'Tag','axsub3'),'type','patch');
            hpatch(4) =  findobj(findobj(previous,'Tag','axsub4'),'type','patch');
        else
            if isempty(hpatch)
                hpatch = [];
            end
        end
    end
    
    % What kind of visualization type is needed here ? -------------------------------
    ScalpMaps = get(hSelect.ScalpMaps,'Value');
    ColorSensors = get(hSelect.ColorSensors,'Value');
    CorticalMap =  get(hSelect.CorticalMap,'Value');
    
    nmesh = 0; % Number of meshes to display
    
    for k = imesh
        h = findobj(hpatch,'Tag',Comment{k});
        set(h,'Visible','on')
        
        if isempty(h)
            h{1}= 'new_patch';
        elseif iscell(h)
            if get(h{1},'Parent') ~= get(previous,'CurrentAxes')
                h{1}= 'new_patch';
            end
        else
            hh = cell(length(h),1);  
            for kh = 1:length(hh)
                hh{kh} = h(kh);
            end
            h = hh; clear hh
        end
        
        switch h{1}
        case 'new_patch'
            
            h = patch('vertices',Vertices{k}','Faces',Faces{k},...
                'Facecolor',[.8 .8 .8],'Edgecolor','none',...
                'Visible','off','Tag',Comment{k});  
            
            % Surface orientation
            if ~isfield(Visu.Data,'System')
                Visu.Data.System = 'ctf';
            end
    
            switch(Visu.Data.System)
            case 'ctf'
                view(-90,90)
            end
            
                %-------------------------
            
                if length(imesh)>1
                nmesh = nmesh+1;    
                hpatch(nmesh) = h;
            else
                hpatch = h;
            end
            % Lightning properties -------------------------------------------------------
            set(h,'facelighting','none','edgelighting','none',...
                'ambientstrength',.5,...
                'DiffuseStrength',.3,...
                'specularcolorreflectance',.0,... 
                'specularexponent',1,'specularstrength',.2,...
                'backfacelighting','unlit');
            
            lightangle(0,0)
            lightangle(0,90)
            lightangle(180,0)
            axis normal , axis equal, axis vis3d, axis off
         
        end
    end

    if get(hSelect.MapCurvature,'Value') % ColorCoding of surface curvature is requested
        TessWin  = findobj(0,'tag','tessellation_window'); 
        hTessWin = guihandles(TessWin);
        TessWinUserData = get(TessWin,'Userdata');
        
        if ~isfield(get(hpatch, 'Userdata'),'CDepth') % No curvature mapping is available - compute it
            % Try to load the depth map from the tessellation file
            nsurfaces = length(Comment);
            
            try 
                load(Visu.Tesselation,'Curvature')
            catch
                cd(Users.SUBJECTS)
                load(Visu.Tesselation,'Curvature')
            end
            
            if ~exist('Curvature','var')
                Curvature = cell(nsurfaces,1);
            end
            
            if length(Curvature) < nsurf
                tmp = cell(nsurf,1);
                tmp(1:length(Curvature)) = Curvature;
                Curvature = tmp; clear tmp
            end
            
            if isempty(Curvature{nsurf})  %| ~isfield(TessWinUserData,'VertConn') % Vertex connectivity not available here - load or compute
               
                load(Users.CurrentData.SubjectFile,'VertConn'); % Is the vertex connectivity available ?
                
                if isempty(VertConn) % Vertex connectivity was not defined before
                    VertConn = cell(nsurfaces,1);
                else
                    if exist(VertConn,'file')
                        load(VertConn)
                    else
                        VertConn = cell(nsurfaces,1);
                    end
                end
                
                if length(VertConn) < nsurf
                    tmp = cell(nsurf,1);
                    tmp(1:length(VertConn)) = VertConn;
                    VertConn = tmp; clear tmp
                end
            
                if isempty(VertConn{nsurf}) % Compute the vertex connectivity
                    
                    % ----------------- Load current surface parameters
                    load(Visu.Tesselation,'Faces','Vertices')
                    FV.faces = Faces{nsurf}; clear Faces
                    FV.vertices = Vertices{nsurf}'; clear Vertices
                    % ----------------- Load current surface parameters - DONE
                    
                    [pathname, filename] = fileparts(Visu.Tesselation);    
                    VertConn{nsurf} = vertices_connectivity(FV);
                    VertConnFile = [filename,'_vertconn.mat'];
                    
                    % Save this file in the current subject folder
                    [path,name,ext] = fileparts(Users.CurrentData.SubjectFile);
                    if isempty(path)
                        cd(Users.SUBJECTS)
                    else 
                        cd(path)
                    end
                    save(VertConnFile,'VertConn'); 
                    
                    cd(Users.SUBJECTS)
                    VertConn = fullfile(path,VertConnFile);
                    save(Users.CurrentData.SubjectFile,'VertConn','-append') 
                    load(VertConn)
                end
                VertConn = VertConn{nsurf};
                TessWinUserData.VertConn = VertConn; clear VertConn;    
                set(TessWin,'Userdata',TessWinUserData)
                % Compute colormap for this surface
                FV.vertices = get(hpatch,'Vertices');
                FV.faces = get(hpatch,'Faces');
                [vertexcolorh,map]=c_activ(FV,TessWinUserData.VertConn); clear FV
                Curvature{nsurf} = vertexcolorh;
                save(Visu.Tesselation,'Curvature','-append')
            else
                vertexcolorh = Curvature{nsurf};
                clear Curvature
            end
            
            if strcmp(get(hpatch(1),'Visible'),'off')
                set(hpatch,'FaceVertexCData',vertexcolorh)
            end
            % Now save it back to the Tesselation file
                        
        else
        
            vertexcolorh =  get(hpatch,'Userdata');
            vertexcolorh = vertexcolorh.CDepth;
            
        end
       
        cortex = get(hpatch,'Userdata');
        cortex.CDepth = vertexcolorh;
        set(hpatch,'Userdata',cortex);
        
    else
    
        vertexcolorh =  get(hpatch,'FaceVertexCdata');
        
    end
        
    if ColorSensors
        dataplot_cb DataOnSensors
    end
    
    if ScalpMaps
        dataplot_cb DataOnScalp
    end
    
    if CorticalMap
        dataplot_cb('CorticalMap',hpatch)
    else
        if get(hSelect.MapCurvature,'Value')
            set(hpatch,'FaceVertexCData',vertexcolorh)
        end
    end
    
    set(hpatch,'Visible','on')

    vertexcolorh =  get(hpatch,'FaceVertexCdata');
    
    nmesh = 0;
    for k = imesh
        nmesh = nmesh + 1;
        h = findobj(get(previous,'CurrentAxes'),'Tag',Comment{k},'Visible','on');
        if isempty(h)
            
            if k == nsurf & nclust > 0 % Some clustering has been selected - display clusters on the surface
                set(h,'FacevertexCdata',Clusters{nsurf}.Cluster{nclust},'Userdata',Clusters{nsurf}.Cluster{nclust}')
                colormap(rand(Clusters{nsurf}.NClusters(nclust),3))
            end
            
            hold on
            
            if Vals(k,1) == 1
                set(h,'edgecolor','none','facecolor','interp')
            else
                set(h,'edgecolor',[.7 .7 .7],'facecolor','none')
            end
            
        else
            
            if isempty(vertexcolorh)
                vertexcolorh = get(h,'FaceVertexCData');
            elseif iscell(vertexcolorh)
                vertexcolorh = vertexcolorh{nmesh};
            end
            
            if Vals(k,1) == 1

                if isempty(vertexcolorh)
                    set(h,'edgecolor','none','facecolor',[.5 .5 .5])
                else
                    set(h,'edgecolor','none','facecolor','interp')
                end
                
            else
                set(h,'edgecolor','interp','facecolor','none')
            end
        end
        % Update envelope properties ------------------------------------------------------
        
        ctet = get(h,'vertices');
        siz = size(vertexcolorh,2);
        if size(vertexcolorh,1) == 1
            vertexcolorh = ones(size(ctet,1),1)*vertexcolorh;
        end
        
        
        if Vals(k,3) == 1
            vertexcolorh(find(ctet(:,2) < 0),:) = NaN * ones(length(find(ctet(:,2) < 0)),siz);	   	
        end
        if Vals(k,4) == 1
            vertexcolorh(find(ctet(:,2) > 0),:) = NaN * ones(length(find(ctet(:,2) > 0)),siz);	   	
        end
        if Vals(k,5) == 1
            vertexcolorh(find(ctet(:,1) > 0),:) = NaN * ones(length(find(ctet(:,1) > 0)),siz);	   	
        end
        if Vals(k,6) == 1
            vertexcolorh(find(ctet(:,1) < 0),:) = NaN * ones(length(find(ctet(:,1) < 0)),siz);	   	
        end
        if Vals(k,7) == 1
            vertexcolorh(find(ctet(:,3) > 0),:) = NaN * ones(length(find(ctet(:,3) > 0)),siz);	   	
        end
        if Vals(k,8) == 1
            vertexcolorh(find(ctet(:,3) < 0),:) = NaN * ones(length(find(ctet(:,3) < 0)),siz);	   	
        end
        
        clear ctet
        if iscell(vertexcolorh)
            set(h,'FaceVertexCData',vertexcolorh{1},'Visible','on')
            if length(hpatch)>1 % OrthoViews
                for kk = 1:length(hpatch)
                    h = hpatch(kk);
                    set(h,'FaceVertexCData',vertexcolorh{1},'Visible','on') 
                end
                
            end
            
        else
            if OrthoViews == 1
                set(hpatch,'FaceVertexCData',vertexcolorh,'Visible','on')
            else
                set(h,'FaceVertexCData',vertexcolorh,'Visible','on')
            end
        end
        vertexcolorh = []; % Move to next surface       
    end
    
    figure(previous)
    hold off
    rotate3d on
    if ~isempty(findobj(gcf,'Tag','MainAxes')) 
       if length(hpatch)>1 & length(imesh) == 1% suplots with only one surface to display (need to generalize this)
           if ~strcmp(get(hpatch(4),'Visible'),'on')
               set(gca,'View',get(findobj(gcf,'Tag','MainAxes'),'view'))
           end
       end
       
    end
    
    dataplot_cb mesh_lighting_props

    %----------------------------------------------------------------------------
case 'listchan_create' % Selection of channel names for n-plot visualization
    Visu = get(DATAPLOT,'Userdata');
    if isempty(Visu)
        errordlg('Please load a data set first')
        return
    end
    0
    str = {'MEG','EEG','OTHER'};
    
    LISTCHAN = findobj(0,'Tag','listchan');
    if isempty(LISTCHAN)
        LISTCHAN = open('listchan.fig');
    end
    
    goodchannels = setdiff(Visu.ChannelID{current},find(Visu.Data.ChannelFlag == -1))  - min(Visu.ChannelID{current})+1; % Discard bad channels
    badchannels = intersect(Visu.ChannelID{current},find(Visu.Data.ChannelFlag == -1)) - min(Visu.ChannelID{current})+1;
    
    available = findobj(LISTCHAN,'Tag','available');
    removed =  findobj(LISTCHAN,'Tag','removed');
    
    set(available,'String', {Visu.Channel(Visu.ChannelID{current}(goodchannels)).Name});
    
    if ~isempty(badchannels)
        set(removed,'String', {Visu.Channel(Visu.ChannelID{current}(badchannels)).Name});
    else
        set(removed,'String', '');
    end
    
    set(available,'Value',1,'Max',length(get(available,'String')))
    set(removed,'Value',1,'Max',max([1,length(get(removed,'String'))]))
    
    %----------------------------------------------------------------------------
    
case 'channel_plot_remove' % Remove Channels
    channel_select_win = findobj(0,'Tag','listchan');
    available = findobj(channel_select_win,'Tag','available');
    removed =  findobj(channel_select_win,'Tag','removed');
    removeID = get(available,'Value');
    IDs = get(available,'String');
    chan = [1:length(IDs)];
    
    set(available,'String', IDs(setdiff(chan,removeID)));
    if isempty(get(removed,'String'))
        set(removed,'String', [IDs(removeID)] );
    else
        strtmp = ([cellstr(get(removed,'String'));IDs(removeID)]);
        strtmp = sort(strtmp);
        set(removed,'String', cellstr(strtmp));
    end
    set(available,'Value',1,'Max',length(get(available,'String')))
    set(removed,'Value',1,'Max',max([1,length(get(removed,'String'))]))
    
    
    %----------------------------------------------------------------------------
    
case 'channel_plot_restore' % Restore Channels - Make them become available again
    channel_select_win = findobj(0,'Tag','listchan');
    available = findobj(channel_select_win,'Tag','available');
    removed =  findobj(channel_select_win,'Tag','removed');
    availableID = get(removed,'Value');
    IDs = get(removed,'String');
    chan = [1:length(IDs)];
    
    set(removed,'Max',max([1,length(setdiff(chan,availableID))]))
    set(removed,'Value',1,'String',IDs(setdiff(chan,availableID)));
    
    if isempty(get(available,'String'))
        set(available,'String', [IDs(availableID)]);
    else
        strtmp = ([cellstr(get(available,'String'));IDs(availableID)]);
        strtmp = sort(strtmp);
        set(available,'String', cellstr(strtmp));
    end
    set(available,'Value',1,'Max',length(get(available,'String')))
    
    %----------------------------------------------------------------------------
    
case 'listchan_SelectAll'
    
    channel_select_win = findobj(0,'Tag','listchan');
    available = findobj(channel_select_win,'Tag','available');
    set(available,'Value',[1:get(available,'Max')])
    dataplot_cb channel_plot_remove
    
    %----------------------------------------------------------------------------
case 'listchan_RemoveAll'
    
    channel_select_win = findobj(0,'Tag','listchan');
    available = findobj(channel_select_win,'Tag','removed');
    set(available,'Value',[1:get(available,'Max')])
    dataplot_cb channel_plot_restore
    
    %----------------------------------------------------------------------------
case 'listchan_refresh' % Update the channel information / plots
    
    Visu = get(DATAPLOT,'Userdata');
    str = {'MEG','EEG','OTHER'};
    
    channel_select_win = findobj(0,'Tag','listchan');
    removed =  findobj(channel_select_win,'Tag','removed');
    available =  findobj(channel_select_win,'Tag','available');
    handles = guihandles(channel_select_win);
    ncol = str2num(get(handles.NumberOfColumns,'String')); % Number of columns in the layout
    
    if isempty(get(removed,'String'))
        errordlg('Please Select Channels for the Plot first')
        return
    end
    
    [tmp,IDs] = intersect({Visu.Channel(Visu.ChannelID{current}).Name},get(removed,'String'));  
    
    % Get time window
    TIME_MIN = str2num(get(findobj(DATAPLOT,'Tag','time_min'),'String'));
    TIME_MAX = str2num(get(findobj(DATAPLOT,'Tag','time_max'),'String')); 
    
    if TIME_MAX > Visu.Data.Time(end) * 1000
        TIME_MAX = Visu.Data.Time(end) * 1000;
        set(findobj(DATAPLOT,'Tag','time_max'),'String',num2str(TIME_MAX,5))
    end
    
    if TIME_MIN < Visu.Data.Time(1) * 1000
        TIME_MIN = Visu.Data.Time(1) * 1000;
        set(findobj(DATAPLOT,'Tag','time_min'),'String',num2str(TIME_MIN,5))
    end
    
    delta_t = 1000*(Visu.Data.Time(2)-Visu.Data.Time(1));
    samples = round(([TIME_MIN:delta_t:TIME_MAX]-Visu.Data.Time(1)*1000)/delta_t)+1;
    
    M = max(max(abs(Visu.Data.F(Visu.ChannelID{current}(IDs),samples))));
    
    fignplot = findobj(0,'Tag','nplot_win'); % Figure of overlaping plots for the current modality
    if isempty(fignplot)
        fig = figure;
        delete(findobj(fig,'type','axes'))
        movegui(fig,'center')
        set(fig,'Tag','nplot_win')
    else
        figure(fignplot)
        clf
    end
    
    % Visualization
    N = ceil(length(IDs)/ncol); % Maximum number of channels to visualize per column
    
    delta = .95/(N+1); % Space between plots (in normalized units)  
    hold on
    for col = 1:ncol % For each column of the layout
        
        if col<ncol
            try
                IDscol = IDs((col-1)*N+1 : N*col); % Labels of channels to plot in each column 
            catch
                errordlg('Please try another number of columns')
                return
            end
            
        else
            IDscol = IDs((col-1)*N+1 : end); % Labels of channels to plot in each column 
        end
        if col>1
            axes
        end
        
        i = 0;
        
        for k = IDscol
            i = i+1;
            plotwaves = plot([TIME_MIN:delta_t:TIME_MAX],Visu.Data.F(Visu.ChannelID{current}(k),samples)+(2*M*i));
            hold on
        end
        
        set(gca,'units','normalized','ygrid','on','xgrid','on','Box','on',...
            'Position',[(col-1)*0.96/ncol + 0.039, 0.035, 0.80/ncol, 0.96],...
            'Yticklabel',{Visu.Channel(Visu.ChannelID{current}(IDscol)).Name},'Ytick',2*M*[1:length(IDscol)],...
            'FontName','Helvetica','FontSize',7,'FontUnits','Points','Fontweight','light',...
            'xColor',[.4 .4 .4], 'ycolor', [.05 .45 .80],'XMinorGrid','on',...
            'Xlim',[TIME_MIN,TIME_MAX],'Ylim',[0 2*M*(N+1)])
        %         set(gca,'Fontunits','normal')
        liine = line([0 0],get(gca,'Ylim'),'linewidth',1);
        set(liine,'color','r','Tag','cursor')
    end
    
    hold off
    %--------------------------------------------------------------'--------------
case 'selectchannels' % Selection of Good/Bad Channels
    Visu = get(DATAPLOT,'Userdata');
    previous  = findobj(0,'Tag','channel_select');
    
    if length(current) > 1
        errordlg('Please select either MEG, EEG or OTHER data subset')
        return
    end
    
    for kur = 1:length(current)
        
        goodchannels = setdiff(Visu.ChannelID{current(kur)},find(Visu.Data.ChannelFlag == -1))  - min(Visu.ChannelID{current(kur)})+1; % Discard bad channels
        
        if ~isempty(previous)
            figure(previous)
            channel_select_win = previous;
            available = findobj(channel_select_win,'Tag','available');
            removed =  findobj(channel_select_win,'Tag','removed');
            channel_removed = get(channel_select_win,'Userdata');
            if isfield(channel_removed,str{current})
                eval(['removedIDs = channel_removed.',str{current},';']);
                set(removed,'String',{Visu.ChannelID{current(kur)}(goodchannels(removedIDs)).Name})
                
                set(removed,'Value',1,'Max',length(get(removed,'String')))
                chan = [1:length(Visu.ChannelID{current(kur)})];
                
                set(available,'String',{Visu.Channel(Visu.ChannelID{current(kur)}(goodchannels(setdiff(chan,removedIDs)))).Name});
                set(available,'Value',1,'Max',length(get(available,'String')))
            else
                set(removed,'String','')
                set(available,'String', {Visu.Channel(Visu.ChannelID{current(kur)}(goodchannels)).Name});
                
                set(available,'Max',length(Visu.ChannelID{current(kur)}))
                set(removed,'Max',length(get(removed,'String')))        
            end
        else
            channel_select_win = openfig('channel_select.fig');
            available = findobj(channel_select_win,'Tag','available');
            removed =  findobj(channel_select_win,'Tag','removed');
            goodchannels = setdiff(Visu.ChannelID{current},find(Visu.Data.ChannelFlag == -1)) - min(Visu.ChannelID{current(kur)})+1; % Discard bad channels
            badchannels = intersect(Visu.ChannelID{current},find(Visu.Data.ChannelFlag == -1)) - min(Visu.ChannelID{current(kur)})+1;
            
            removed = findobj(channel_select_win,'Tag','removed');
            available = findobj(channel_select_win,'Tag','available');
            
            set(available,'String', {Visu.Channel(Visu.ChannelID{current(kur)}(goodchannels)).Name});
            
            if ~isempty(badchannels)
                set(removed,'String', {Visu.Channel(Visu.ChannelID{current(kur)}(badchannels)).Name});
            else
                set(removed,'String', '');
            end
            
            set(available,'Value',1,'Max',length(get(available,'String')))
            set(removed,'Value',1,'Max',max([1,length(get(removed,'String'))]))
            
        end
    end
    
    
    set(channel_select_win,'Name',[modality{current(kur)},' Channels'])

    %----------------------------------------------------------------------------
    
case 'channel_remove' % Remove Channels
    if length(current) > 1
        errordlg('Please select either MEG, EEG or OTHER data subset')
        return
    end
    
    channel_select_win = findobj(0,'Tag','channel_select');
    available = findobj(channel_select_win,'Tag','available');
    removed =  findobj(channel_select_win,'Tag','removed');
    removeID = get(available,'Value');
    IDs = get(available,'String');
    if isempty(IDs)
        return
    end
    chan = [1:length(IDs)];
    
    set(available,'String', IDs(setdiff(chan,removeID)));
    if isempty(get(removed,'String'))
        set(removed,'String', [IDs(removeID)] );
    else
        strtmp = ([cellstr(get(removed,'String'));IDs(removeID)]);
        strtmp = sort(strtmp);
        set(removed,'String', cellstr(strtmp));
    end
    set(available,'Value',1,'Max',length(get(available,'String')))
    set(removed,'Value',1,'Max',max([1,length(get(removed,'String'))]))
    
    
    %----------------------------------------------------------------------------
    
case 'channel_restore' % Restore Channels - Make them become available again
    if length(current) > 1
        errordlg('Please select either MEG, EEG or OTHER data subset')
        return
    end
    channel_select_win = findobj(0,'Tag','channel_select');
    available = findobj(channel_select_win,'Tag','available');
    removed =  findobj(channel_select_win,'Tag','removed');
    availableID = get(removed,'Value');
    IDs = get(removed,'String');
    if isempty(IDs)
        return
    end
    chan = [1:length(IDs)];
    
    set(removed,'Max',max([1,length(setdiff(chan,availableID))]))
    set(removed,'Value',1,'String',IDs(setdiff(chan,availableID)));
    
    if isempty(get(available,'String'))
        set(available,'String', [IDs(availableID)]);
    else
        strtmp = ([cellstr(get(available,'String'));IDs(availableID)]);
        strtmp = sort(strtmp);
        set(available,'String', cellstr(strtmp));
    end
    set(available,'Value',1,'Max',length(get(available,'String')))
    
    
    %----------------------------------------------------------------------------
case 'GenerateAverage' % Generate Time-Locked Average of all Data Files in Current Study
    
    hDATAPLOT = guihandles(DATAPLOT);
    
    disp('Time-locked averaging of all data files from current study...')
    cd(Users.STUDIES)
    [path,file,ext] = fileparts(Users.CurrentData.StudyFile);
    
    [DataDir,DataPopup,Leader] = find_brainstorm_files('data',fullfile(Users.STUDIES,path));
    ndatafiles = 0;
    
    for file = DataDir
        
        cd(fullfile(Users.STUDIES,path))
        if isempty(findstr(file{:},'results')) & isempty(findstr(file{:},'avr.mat'))
            ndatafiles = ndatafiles+1
            load(file{:},'F','Time')
            Users.CurrentData.DataFile = file{:};
            guidata(TASKBAR,Users)
            
            if get(hDATAPLOT.SetPeakLatency,'Value') % Adjust peak latency
                Visu = get(DATAPLOT,'Userdata');
                Visu.Data.F = F;
                Visu.Data.Time = Time;
                set(DATAPLOT,'Userdata',Visu)
                dataplot_cb SetPeakLatency
                
                %Adjust time window
                Visu = get(DATAPLOT,'Userdata');
                if ndatafiles == 1
                    srate = abs(Visu.Data.Time(1)-Visu.Data.Time(2));
                    zeroLat = round(abs(Visu.Data.Time(1))/srate)+1;
                    zeroLatOld = zeroLat;
                end
                
            end
            
            if ndatafiles == 1
                Fav = F;
                iunder = findstr(file{:},'_'); % Generate average data file name
                avFileName = file{:}(1:iunder(end));
                Mod = {'MEG','EEG','OTHER'};
                avFileName = [avFileName,Mod{current},'avr.mat'];
                Data = load(file{:});
                
            else
                
                if get(hDATAPLOT.SetPeakLatency,'Value') % Adjust peak latency
                    % Find sample corresponding to time 0ms
                    zeroLat = round(abs(Visu.Data.Time(1))/srate)+1;
                    if zeroLat < zeroLatOld
                        Fav = Fav(:,zeroLatOld-zeroLat+1:end);
                        %     F = F(:,1:end-zeroLatOld+zeroLat);
                        Fav = Fav(:,1:min([size(F,2),size(Fav,2)]));
                        F = F(:,1:min([size(F,2),size(Fav,2)]));
                        zeroLatOld = zeroLat;
                    else
                        F = F(:,zeroLat-zeroLatOld+1:end);
                        %   Fav = Fav(:,1:end-zeroLat+zeroLatOld);
                        Fav = Fav(:,1:min([size(F,2),size(Fav,2)]));
                        F = F(:,1:min([size(F,2),size(Fav,2)]));
                        zeroLat = zeroLatOld;    
                    end
                end
                
                Fav = Fav+F;
                % Find maximum latency of this running average
                Time(1) = sign(Visu.Data.Time(1))*(zeroLat-1)*srate;
                Time = Time(1):srate:(Time(1)+(size(Fav,2)-1)*srate);
                Visu.Data.Time = Time; 
                Visu.Data.F = Fav;
                set(DATAPLOT,'Userdata',Visu)
                Users.CurrentData.DataFile = avFileName;
                guidata(TASKBAR,Users)
            
                dataplot_cb SetPeakLatency
                
                Visu = get(DATAPLOT,'Userdata');
                zeroLat = round(abs(Visu.Data.Time(1))/srate)+1;
                zeroLatOld = zeroLat
            end
        end
    end
    
    srate = abs(Visu.Data.Time(1)-Visu.Data.Time(2));
    % Find sample corresponding to time 0ms
    
    % New time vector
    Time(1) = sign(Visu.Data.Time(1))*(zeroLat-1)*srate;
    Time = Time(1):srate:(Time(1)+(size(Fav,2)-1)*srate);
    Visu.Data.Time = Time; 
    set(hDATAPLOT.time_min,'String',num2str(Time(1)*1000,'%3.2f'));
    set(hDATAPLOT.time_max,'String',num2str(Time(end)*1000,'%3.2f'));
    
    Data.F = Fav/ndatafiles;
    Data.Time = Time;
    
    save_fieldnames(Data,avFileName);
    disp('Time-locked averaging all data files from current study...->DONE')
    disp([num2str(ndatafiles),' files averaged'])
    
    
%----------------------------------------------------------------------------

case 'channel_select_done' % Update the channel information / plots
    
    Visu = get(DATAPLOT,'Userdata');
    
    if length(current) > 1
        errordlg('Please select either MEG, EEG or OTHER data subset')
        return
    end
    
    str = {'MEG','EEG','OTHER'};
    
    channel_select_win = gcbf;
    removed =  findobj(channel_select_win,'Tag','removed');
    
    [tmp,IDs] = intersect({Visu.Channel(Visu.ChannelID{current}).Name},get(removed,'String'));
    
    % Keep Removed Channels in Memory
    channel_removed = get(channel_select_win,'Userdata');
    if ~isempty(channel_removed)
        eval(['channel_removed.',str{current},' = IDs;'])
        set(channel_select_win,'Userdata',channel_removed);
    end
    
    if isempty(IDs)
        Visu.Data.ChannelFlag(Visu.ChannelID{current}) = ones(size(Visu.ChannelID{current})); %Restore to Good Channel
    else
        Visu.Data.ChannelFlag(IDs + min(Visu.ChannelID{current}) - 1) = -ones(size(IDs)); % Mark as bad, i.e. -1
    end
    
    Visu.Alter = 1; % Data set is altered from original version (channels were removed - keep that in mind when calling SourceImaging tools)
    
    set(DATAPLOT,'Userdata',Visu)
    
    figsingle = findobj(0,'Tag',['waves_single',int2str(current)]); % Figure of overlaping plots for the current modality
    if isempty(figsingle)
        return
    end
    
%     if current==2 % In case of EEG data - remove average reference when requested
%         dataplot_cb RemoveEEGAverage
%     end
    
    ChannelSelectAllDataSets = findobj(channel_select_win,'Tag','ChannelSelectAllDataSets');;
    if get(ChannelSelectAllDataSets,'Value') % Apply this selection to all the data setsfrom this study
        disp('Updating all data files from current study...')
        cd(Users.STUDIES)
        [path,file,ext] = fileparts(Users.CurrentData.StudyFile);
       
        [DataDir,DataPopup,Leader] = find_brainstorm_files('data',fullfile(Users.STUDIES,path));
        ndatafiles = 0;
        clear ChannelFlag
        for file = DataDir
            cd(fullfile(Users.STUDIES,path))
            if isempty(findstr(file{:},'results'))
                load(file{:},'ChannelFlag')
            end
            if exist('ChannelFlag','var') % Skip this file
                ndatafiles = ndatafiles+1
                ChannelFlag =  Visu.Data.ChannelFlag;
                save(file{:},'ChannelFlag','-append')    
                clear ChannelFlag
            end
        end
        disp('Updating all data files from current study...-> DONE')
        disp([num2str(ndatafiles),' file updated'])
    else
        disp('Updating current data file...')
        cd(Users.STUDIES)
        [path,file,ext] = fileparts(Users.CurrentData.StudyFile);
        cd(path)
        clear ChannelFlag
        load(Users.CurrentData.DataFile,'ChannelFlag')
        if exist('ChannelFlag','var') % Skip this file
            ChannelFlag =  Visu.Data.ChannelFlag;
            save(Users.CurrentData.DataFile,'ChannelFlag','-append')    
            clear ChannelFlag
        end
        disp('Updating current data file... -> DONE')
    end
    
    dataplot_cb quicklook
    
    %----------------------------------------------------------------------------
    
case '2dlayout'
    Visu = get(DATAPLOT,'Userdata');
    MEG = get(findobj(DATAPLOT,'Tag','MEG'),'value');
    EEG = get(findobj(DATAPLOT,'Tag','EEG'),'value');
    OTHER = get(findobj(DATAPLOT,'Tag','OTHER'),'value');
    current = find([MEG,EEG,OTHER] == 1);
    channel_select_win = findobj(0,'Tag','channel_select');
    layout = findobj(0,'Tag',['layout_',modality{current}]);
    
    timescale = 10;
    
    if ~isempty(find(Visu.Data.ChannelFlag == -1))
        goodchannels = setdiff(Visu.ChannelID{current},find(Visu.Data.ChannelFlag == -1));%- min(Visu.ChannelID{current})+1 ; % Discard bad channels
        badchannels = intersect(Visu.ChannelID{current},find(Visu.Data.ChannelFlag == -1));%- min(Visu.ChannelID{current})+1;
    else
        goodchannels = setdiff(Visu.ChannelID{current},find(Visu.Data.ChannelFlag == -1));%- min(Visu.ChannelID{current})+1 ;;%Visu.ChannelID{current};
        badchannels = [];
    end
    
    TIME_MIN = str2num(get(findobj(DATAPLOT,'Tag','time_min'),'String'));
    TIME_MAX = str2num(get(findobj(DATAPLOT,'Tag','time_max'),'String'));
    delta_t = 1000*(Visu.Data.Time(2)-Visu.Data.Time(1));
    samples = round(([TIME_MIN:delta_t:TIME_MAX]-Visu.Data.Time(1)*1000)/delta_t)+1;
    
    
    j = 0;
    for chan = goodchannels%Visu.ChannelID{current}
        j = j+1;
        chanloc(:,j) = Visu.Channel(chan).Loc(:,1);
    end
    
    figure
    set(gcf,'Color','k')
    
    minn = min(chanloc')';
    maxx = max(chanloc')';
    chanloc(3,:) =  chanloc(3,:) - maxx(3);
    
    [TH,PHI,R] = cart2sph(chanloc(1,:),chanloc(2,:),chanloc(3,:));
    PHI2 = zeros(size(PHI));
    R2 = R./cos(PHI).^.2;
    
    [Y,X] = pol2cart(TH,R2);
    dat = Visu.Data.F(goodchannels,samples);
    M = max(abs(dat(:)));
    
    My = max(abs(Y));
    Mx = max(abs(X));
    Mt = TIME_MAX-TIME_MIN;
    
    
    for i = 1:length(goodchannels)
        dat = Visu.Data.F(goodchannels(i),samples);
        h = plot(Mx*[TIME_MIN:delta_t:TIME_MAX]/(timescale*Mt)-X(i),(My*dat/(10*M)+Y(i)),'color',[.9 .9 .9]);
        set(h,'ButtondownFcn','dataplot_cb line_select')
        hold on
        ttl = text(Mx*TIME_MIN/(timescale*Mt)-X(i),.5*My*M/(10*M)+Y(i),Visu.Channel((goodchannels(i))).Name);
        set(ttl,'fontsize',8,'color',.8*[1 1 1])
    end
    axis equal
    axis off
    
    %----------------------------------------------------------------------------
case 'mapping_create' % Generates SLIDES and/or MOVIES
    
    Visu = get(DATAPLOT,'Userdata');
    MEG = get(findobj(DATAPLOT,'Tag','MEG'),'value');
    EEG = get(findobj(DATAPLOT,'Tag','EEG'),'value');
    OTHER = get(findobj(DATAPLOT,'Tag','OTHER'),'value');
    current = find([MEG,EEG,OTHER] == 1);
    
    mapping_win = findobj(0,'Tag','mapping');
    if isempty(mapping_win)
        open mapping.fig; 
        mapping_win = findobj(0,'Tag','mapping');
    else
        return
    end
    
    RAW = findobj(mapping_win ,'Tag','raw');
    GRADIENT = findobj(mapping_win ,'Tag','gradient');
    MAGNETIC = findobj(mapping_win,'Tag','magnetic');
    
    if current == 1 % If MEG
        set([RAW,GRADIENT,MAGNETIC],'enable','on')
        set(RAW,'Value',1)
    else
        set([RAW,GRADIENT,MAGNETIC],'enable','off')
    end
    
    start = findobj(mapping_win,'Tag','start');
    step = findobj(mapping_win,'Tag','step');
    stop = findobj(mapping_win,'Tag','stop');
    current_time = findobj(mapping_win,'Tag','current_time');
    slider_time = findobj(mapping_win,'Tag','slider_time');
    go = findobj(mapping_win,'Tag','go');
    SPHERE = findobj(mapping_win,'Tag','sphere');
    fit = findobj(mapping_win,'Tag','fit');
    ROTATE = findobj(mapping_win,'Tag','rotate');
    fit = findobj(mapping_win,'Tag','fit');
    slides = findobj(mapping_win,'Tag','slides');
    single = findobj(mapping_win,'Tag','single');
    MOVIE = findobj(mapping_win,'Tag','movie');
    
    handles = guihandles(mapping_win);
    
    set(mapping_win,'Name',[get(mapping_win,'Name'), ' - ', modality{current}])
    
    set(start,'String', num2str(1000*Visu.Data.Time(1)))
    set(stop,'String', num2str(1000*Visu.Data.Time(end)))
    if length(Visu.Data.Time) > 1
        set(step,'String', num2str(1000*(Visu.Data.Time(2)-Visu.Data.Time(1)),2))
    else
        set(step,'String', 0)
    end
    
    
    TIME_MIN = str2num(get(findobj(DATAPLOT,'Tag','time_min'),'String'));
    TIME_MAX = str2num(get(findobj(DATAPLOT,'Tag','time_max'),'String'));
    
    if TIME_MAX > Visu.Data.Time(end) * 1000
        TIME_MAX = Visu.Data.Time(end) * 1000;
        set(findobj(DATAPLOT,'Tag','time_max'),'String',num2str(TIME_MAX,5))
    end
    
    if TIME_MIN < Visu.Data.Time(1) * 1000
        TIME_MIN = Visu.Data.Time(1) * 1000;
        set(findobj(DATAPLOT,'Tag','time_min'),'String',num2str(TIME_MIN,5))
    end
    
    if ~isempty(mapping_win)
        slider_time = findobj(mapping_win,'Tag','slider_time');
        if length(Visu.Data.Time) > 1
            set(slider_time,'enable','on')
            set(slider_time,'Min',TIME_MIN,'Max',TIME_MAX)
        else
            set(slider_time,'Min',TIME_MIN,'Max',2*TIME_MAX)
            set(slider_time,'enable','off')
        end
        
    end
    set(slider_time,'Value',TIME_MIN,'enable','on')
    
    set(current_time,'String',num2str(get(slider_time,'Value'),4))
    set(single,'Value',1)
    mutincomp([single,slides,MOVIE])
    set(SPHERE,'Value',1)
    mutincomp([SPHERE,fit,handles.scalp])
    
    % Draw time cursor
    figsingle = findobj(0,'Tag',['waves_single',int2str(current)]); % Figure of overlaping plots for the current modality
    if ~isempty(figsingle) 
        figure(figsingle)
        ctime = get(slider_time,'Value');
        cursor = line([ctime ctime],get(gca,'Ylim'));
        set(cursor,'color','r','linewidth',3,'Tag','cursor','erasemode','Xor')
    end
    
    fignplot = findobj(0,'Tag','nplot_win'); % superimposed n-plots
    if ~isempty(fignplot) 
        figure(fignplot)
        ctime = get(slider_time,'Value');
        cursor = line([ctime ctime],get(gca,'Ylim'));
        set(cursor,'color','r','linewidth',3,'Tag','cursor','erasemode','Xor')
    end
    %----------------------------------------------------------------------------
    
case 'mapping_slider' % Update of the current time sample using the slider
    
    Visu = get(DATAPLOT,'Userdata');
    
    mapping_win = openfig('mapping.fig','reuse'); 
    current_time = findobj(mapping_win,'Tag','current_time');
    slider_time = findobj(mapping_win,'Tag','slider_time');
    step = findobj(mapping_win,'Tag','step');
    
    set(current_time,'String',num2str(get(slider_time,'Value'),5))
    
    ctime = get(slider_time,'Value')/1000;
    
    % Draw time cursor
    for k=1:length(current)
        % Figure of overlaping plots for the current modality
        figsingle{k} = findobj(0,'Tag',['waves_single',int2str(current(k))]); 
        if ~isempty(figsingle{k})
            figure(figsingle{k})
            cursor = findobj(figsingle{k},'Tag','cursor');
            if isempty(cursor)
                cursor = line(1000*[ctime ctime],get(gca,'Ylim'));
                set(cursor,'color','r','linewidth',1,'Tag','cursor','erasemode','Xor')
            else
                set(cursor,'Xdata',1000*[ctime ctime])
            end
            
            text_cursor = findobj(figsingle{k},'Tag','text_cursor');
            if isempty(text_cursor)
                text_cursor = text(1000*[ctime],max(get(gca,'Ylim'))/1.1,num2str(1000*ctime,4));
                set(text_cursor ,'Horizontalalignment','right','Fontweight','bold','color','k','fontsize',12,...
                    'Tag','text_cursor','erasemode','xor')
            else
                set(text_cursor,'Position',[1000*[ctime],max(get(gca,'Ylim'))/1.1],'String',num2str(1000*ctime,4))
            end
        end
    end
    
    fignplot = findobj(0,'Tag','nplot_win'); % Figure of overlaping plots for the current modality
    if ~isempty(fignplot)
        figure(fignplot)
        cursor = findobj(fignplot,'Tag','cursor');
        if isempty(cursor)
            cursor = line(1000*[ctime ctime],get(gca,'Ylim'));
            set(cursor,'color','r','linewidth',3,'Tag','cursor','erasemode','Xor')
        else
            set(cursor,'Xdata',1000*[ctime ctime])
        end
        
        text_cursor = findobj(fignplot,'Tag','text_cursor');
        if isempty(text_cursor)
            text_cursor = text(1000*[ctime],.98*max(get(gca,'Ylim')),num2str(1000*ctime,4));
            set(text_cursor ,'Horizontalalignment','right','Fontweight','demi','color','k',...
                'fontsize',10,'fontunits','points',...
                'Tag','text_cursor','erasemode','xor')
        else
            set(text_cursor,'Position',[1000*[ctime],.98*max(get(gca,'Ylim'))],'String',num2str(1000*ctime,4))
        end
    end
    
    % SurfaceViewer update
    TessSelectWin = findobj(0,'Tag','tesselation_select');
    if ~isempty(TessSelectWin) % Check if Surface Viewer is open
        handles = guihandles(TessSelectWin );
        ScalpMaps = get(handles.ScalpMaps,'Value');
        ColorSensors = get(handles.ColorSensors,'Value');
        CorticalMap = get(handles.CorticalMap,'Value');
        dataplot_cb tesselation_select_done
    end
    
    %Update data mapping if exists
    for k = 1:length(current)
        map_single_win = findobj(0,'Tag',['map_single',int2str(current(k))]);
        if isempty(map_single_win), return, end
        map_sph = get(map_single_win,'Userdata');
        srate = abs(Visu.Data.Time(1)-Visu.Data.Time(2) );   
        ctime = round(( get(slider_time,'Value')/1000-Visu.Data.Time(1))/srate)+1;
        mapping_win = findobj(0,'Tag','mapping'); 
        RAW = findobj(mapping_win ,'Tag','raw');
        GRADIENT = findobj(mapping_win ,'Tag','gradient');
        MAGNETIC = findobj(mapping_win,'Tag','magnetic');
        if strcmp(get(RAW,'enable'),'on') % MEG Case
            RAW = get(RAW,'Value');
            GRADIENT = get(GRADIENT,'Value');
            MAGNETIC = get(MAGNETIC,'Value');
            current_visu = find([RAW,GRADIENT,MAGNETIC] == 1);
        else
            current_visu = NaN;
        end
        ABSOLUTE = get(findobj(mapping_win,'Tag','ABSOLUTE'),'value');
        RELATIVE = get(findobj(mapping_win,'Tag','RELATIVE'),'value');
        
        % Channels Locations:
        if ~isempty(find(Visu.Data.ChannelFlag == -1))
            goodchannels = setdiff(Visu.ChannelID{current(k)},find(Visu.Data.ChannelFlag == -1));%- min(Visu.ChannelID{current})+1 ; % Discard bad channels
            badchannels = intersect(Visu.ChannelID{current(k)},find(Visu.Data.ChannelFlag == -1));%- min(Visu.ChannelID{current})+1;
        else
            goodchannels = setdiff(Visu.ChannelID{current(k)},find(Visu.Data.ChannelFlag == -1));%- min(Visu.ChannelID{current})+1 ;   
            badchannels = [];
        end
        data = Visu.Data.F(goodchannels,ctime) ;
        
        if (current_visu == 2) & (current(k) == 1)% & ~isempty(badchannels) % MEG with bad channels and visualization of the gradient amplitude
            channels = [1:length(Visu.ChannelID{current(k)})];
            odd_channels = channels(find(rem(channels,2) == 1));
            if ~isempty(badchannels)
                odd = badchannels(find(rem(badchannels,2) == 1));
                even = setdiff(badchannels,odd);
                odd = unique([odd',intersect(odd_channels ,(even - 1))]);
            else
                odd = [];
                even = [];
            end
            
            good_odd_channels = setdiff(odd_channels,odd);
            grad_meg = [];
            j = 0;
            for i = (good_odd_channels)
                j = j+1;
                grad_meg(j) = norm([Visu.Data.F(i,ctime),Visu.Data.F(i+1,ctime)]);
            end
            data = grad_meg;
        elseif current_visu == 3 & current(k) == 1
            data = Visu.MNEdata(:,ctime);
        end
        
        try 
            cdata_map = griddata(map_sph.x,map_sph.y,data,map_sph.xs,map_sph.ys,'invdist');
        catch
            errordlg('First Hit the Refresh Button of the Mapping Window when Channels are Removed')
            return
        end
        
        set(map_sph.handle,'CData',cdata_map)
        
        if RELATIVE == 1
            if current_visu == 3
                datacomplete = Visu.MNEdata;
            else
                datacomplete = Visu.Data.F(goodchannels,:);
            end
            
            Max = max(abs(datacomplete(:)));
            figure(map_single_win)
            if (current_visu == 2) & (current(k) == 1)% & ~isempty(badchannels) % MEG with bad channels and visualization of the gradient amplitude
                caxis([0,Max])
            else
                caxis([-Max,Max])
            end
        else
            figure(map_single_win)
            if (current_visu == 2) & (current(k) == 1)% & ~isempty(badchannels) % MEG with bad channels and visualization of the gradient amplitude
                caxis([0,max(abs(data))])
            else
                caxis([-max(abs(data)),max(abs(data))])
            end
            
        end
    end
    
    %----------------------------------------------------------------------------
    
case 'set_current_time'
    Visu = get(DATAPLOT,'Userdata');
    
    mapping_win = findobj(0,'Tag','mapping'); 
    current_time = findobj(mapping_win,'Tag','current_time');
    slider_time = findobj(mapping_win,'Tag','slider_time');
    step = findobj(mapping_win,'Tag','step');
    
    ctime = str2num(get(current_time,'String'))/1000;
    
    set(slider_time,'Value',1000*ctime);
    dataplot_cb mapping_slider
    
    % Draw time cursor
    figsingle = findobj(0,'Tag',['waves_single',int2str(current)]); % Figure of overlaping plots for the current modality
    if ~isempty(figsingle)
        figure(figsingle)
        cursor = findobj(figsingle,'Tag','cursor');
        if isempty(cursor)
            cursor = line(1000*[ctime ctime],get(gca,'Ylim'));
            set(cursor,'color','r','linewidth',3,'Tag','cursor','erasemode','Xor')
        else
            set(cursor,'Xdata',1000*[ctime ctime])
        end
        
        text_cursor = findobj(figsingle,'Tag','text_cursor');
        if isempty(text_cursor)
            text_cursor = text([1000*ctime],max(get(gca,'Ylim'))/1.1,num2str(1000*ctime,4));
            set(text_cursor ,'Horizontalalignment','right','Fontweight','bold','color','k','fontsize',12,...
                'Tag','text_cursor','erasemode','xor')
        else
            set(text_cursor,'Position',[1000*[ctime],max(get(gca,'Ylim'))/1.1],'String',num2str(1000*ctime,4))
        end
    end
    
    
    % Draw time cursor
    fignplot = findobj(0,'Tag','nplot_win'); 
    if ~isempty(fignplot)
        figure(fignplot)
        cursor = findobj(fignplot,'Tag','cursor');
        if isempty(cursor)
            cursor = line(1000*[ctime ctime],get(gca,'Ylim'));
            set(cursor,'color','r','linewidth',3,'Tag','cursor','erasemode','Xor')
        else
            set(cursor,'Xdata',1000*[ctime ctime])
        end
        
        text_cursor = findobj(fignplot,'Tag','text_cursor');
        if isempty(text_cursor)
            text_cursor = text(1000*[ctime],max(get(gca,'Ylim')),num2str(1000*ctime,4));
            set(text_cursor ,'Horizontalalignment','right','Fontweight','bold','color','k','fontsize',12,...
                'Tag','text_cursor','erasemode','xor')
        else
            set(text_cursor,'Position',[1000*[ctime],max(get(gca,'Ylim'))],'String',num2str(1000*ctime,4))
        end
    end
    
    %Update data mapping if exists
    map_single_win = findobj(0,'Tag',['map_single',int2str(current)]);
    if isempty(map_single_win), return, end
    map_sph = get(map_single_win,'Userdata');
    srate = abs(Visu.Data.Time(1)-Visu.Data.Time(2) );   
    ctime = round((ctime-Visu.Data.Time(1))/srate)+1;
    mapping_win = findobj(0,'Tag','mapping'); 
    RAW = findobj(mapping_win ,'Tag','raw');
    GRADIENT = findobj(mapping_win ,'Tag','gradient');
    MAGNETIC = findobj(mapping_win,'Tag','magnetic');
    if strcmp(get(RAW,'enable'),'on') % MEG Case
        RAW = get(RAW,'Value');
        GRADIENT = get(GRADIENT,'Value');
        MAGNETIC = get(MAGNETIC,'Value');
        current_visu = find([RAW,GRADIENT,MAGNETIC] == 1);
    else
        current_visu = NaN;
    end
    ABSOLUTE = get(findobj(mapping_win,'Tag','ABSOLUTE'),'value');
    RELATIVE = get(findobj(mapping_win,'Tag','RELATIVE'),'value');
    
    % Channels Locations:
    if ~isempty(find(Visu.Data.ChannelFlag == -1))
        goodchannels = setdiff(Visu.ChannelID{current},find(Visu.Data.ChannelFlag == -1));%- min(Visu.ChannelID{current})+1 ; % Discard bad channels
        badchannels = intersect(Visu.ChannelID{current},find(Visu.Data.ChannelFlag == -1));%- min(Visu.ChannelID{current})+1;
    else
        goodchannels = setdiff(Visu.ChannelID{current},find(Visu.Data.ChannelFlag == -1));%- min(Visu.ChannelID{current})+1 ;   
        badchannels = [];
    end
    data = Visu.Data.F(goodchannels,ctime) ;
    
    if (current_visu == 2) & (current == 1)% & ~isempty(badchannels) % MEG with bad channels and visualization of the gradient amplitude
        channels = [1:length(Visu.ChannelID{current})];
        odd_channels = channels(find(rem(channels,2) == 1));
        if ~isempty(badchannels)
            odd = badchannels(find(rem(badchannels,2) == 1));
            even = setdiff(badchannels,odd);
            odd = unique([odd',intersect(odd_channels ,(even - 1))]);
        else
            odd = [];
            even = [];
        end
        
        good_odd_channels = setdiff(odd_channels,odd);
        grad_meg = [];
        j = 0;
        for i = (good_odd_channels)
            j = j+1;
            grad_meg(j) = norm([Visu.Data.F(i,ctime),Visu.Data.F(i+1,ctime)]);
        end
        data = grad_meg;
    end
    
    try 
        cdata_map = griddata(map_sph.x,map_sph.y,data,map_sph.xs,map_sph.ys,'invdist');
    catch
        errordlg('First Hit the Refresh Button of the Mapping Window when Channels are Removed')
        return
    end
    
    set(map_sph.handle,'CData',cdata_map)
    if RELATIVE == 1
        
        if current_visu == 3
            datacomplete = Visu.MNEdata;
        else
            datacomplete = Visu.Data.F(goodchannels,:);
        end
        Max = max(abs(datacomplete(:)));
        figure(map_single_win)
        if (current_visu == 2) & (current == 1)% & ~isempty(badchannels) % MEG with bad channels and visualization of the gradient amplitude
            caxis([0,Max])
        else
            caxis([-Max,Max])
        end
        
    else
        figure(map_single_win)
        if (current_visu == 2) & (current == 1)% & ~isempty(badchannels) % MEG with bad channels and visualization of the gradient amplitude
            caxis([0,max(abs(data))])
        else
            caxis([-max(abs(data)),max(abs(data))])
        end
        
    end
    
    
    %-----------------------------------------------------------------------------------------------   
    
case 'gomapping' % Display the map according to featured parameters
    
    set(findobj(0,'Tag','rotate'),'Value',0)
    
    Visu = get(DATAPLOT,'Userdata');
    
    str = {'MEG','EEG','OTHER'};
    mapping_win = findobj(0,'Tag','mapping'); 
    
    ABSOLUTE = get(findobj(mapping_win,'Tag','ABSOLUTE'),'value');
    RELATIVE = get(findobj(mapping_win,'Tag','RELATIVE'),'value');
    
    RAW = findobj(mapping_win ,'Tag','raw');
    GRADIENT = findobj(mapping_win ,'Tag','gradient');
    MAGNETIC = findobj(mapping_win,'Tag','magnetic');
    if strcmp(get(RAW,'enable'),'on') % MEG Case
        RAW = get(RAW,'Value');
        GRADIENT = get(GRADIENT,'Value');
        MAGNETIC = get(MAGNETIC,'Value');
        current_visu = find([RAW,GRADIENT,MAGNETIC] == 1);
    else
        current_visu = NaN;
    end
    
    handles = guihandles(mapping_win);
    
    % Detect Display/Type
    display_type = get([handles.single,handles.slides,handles.movie],'Value');
    head_shape =(get([handles.sphere,handles.fit,handles.scalp],'Value')); % Sphere, Adujst to sensors or map to scalp.
    head_shape =find([head_shape{:}]);
    
    for k = 1:length(current)
        % Channels Locations:
        if ~isempty(find(Visu.Data.ChannelFlag == -1))
            goodchannels{k} = setdiff(Visu.ChannelID{current(k)},find(Visu.Data.ChannelFlag == -1));
            badchannels{k} = intersect(Visu.ChannelID{current(k)},find(Visu.Data.ChannelFlag == -1));
        else
            goodchannels{k} = setdiff(Visu.ChannelID{current(k)},find(Visu.Data.ChannelFlag == -1));
            badchannels{k} = [];
        end
        
        j = 0;
        for chan = goodchannels{k}
            j = j+1;
            chanloc{k}(:,j) = Visu.Channel(chan).Loc(:,1);
        end
    end
    
    %-------------------------------------------------------------
    
    % Check if we have access to the projection of the magnetic field
    
    % Load MNE matrix in the headmodel.mat file 
    if ~isfield(Visu.Data,'System')
        Visu.Data.System = 'ctf';
    end
    if ~isfield(Visu,'MNEdata') & ~strcmp(Visu.Data.System,'ctf') % non ctf systems only
        
        rooot = findstr(Users.CurrentData.StudyFile,'brainstormstudy.mat');
        if isempty(rooot)
            errordlg('Study file name should be of the form ''*brainstormstudy.mat''')
            return
        end
        rooot = Users.CurrentData.StudyFile(1:rooot-2);
        HeadModelFile = fullfile(Users.STUDIES,[rooot ,'_headmodel.mat']);
        MEG = (find(current == 1));
        if ~isempty(MEG) % MEG was selected as a modality
            if verbose
                disp('Computing gain matrix for Min. Norm estimate of the magnetic field from sensors...')
                drawnow
            end
            
            sensMEGMNE = goodchannels{MEG};
            global ChannelFlag
            ChannelFlag = ones(length(Visu.Channel),1);
            ChannelFlag(badchannels{MEG}) = -1;
            nsrc = length(sensMEGMNE);
            mne_src = [ones(size(chanloc{MEG})).*chanloc{MEG}/3]; % Choose sources this way -> hence they are inside the sensor helmet
            % Sources should be quite deep to smooth out their contribution to the sensors
            Chan = Visu.Channel(sensMEGMNE);
            [Chan.Weight] = deal([1 0]); % Null weight associated to second coil of the gradiometer
            
            mass = mean(chanloc{MEG}'); % center of mass of the scalp vertex locations   
            R0 = mean(norlig(chanloc{MEG}' - ones(size(chanloc{MEG}',1),1)*mass)); % Average distance betw
            vec0 = [mass,R0];
            [minn,brp] = fminsearch('dist_sph',vec0,[],chanloc{MEG}');
            center = minn(1:end-1)'; % 3x1
            R = minn(end);
            
            [Param(1:length(sensMEGMNE))] = deal(struct('Center',center,'Radii',R));
            Par = Param;
            
            Gmne2mag = os_meg(mne_src, Chan, Par, -1);
            Gmne2mag = Gmne2mag(:,1:3:end);
            Gmne2grad = os_meg(mne_src, Visu.Channel(sensMEGMNE), Par, -1);
            Gmne2grad = Gmne2grad(:,1:3:end);
            
            matt = Gmne2grad'*Gmne2grad;
            MNEMag = Gmne2mag * inv(matt+1e-6*norm(matt,'fro')*eye(size(matt)))*Gmne2grad';
            
            clear Par Chan
            
            if verbose
                disp('Computing gain matrix for Min. Norm estimate of the magnetic field from sensors...-> DONE')
                drawnow
            end
            
            if ~exist(HeadModelFile,'file')
                save(HeadModelFile,'MNEMag')
            else
                save(HeadModelFile,'MNEMag','-append')
            end
            
            Visu.MNEdata = MNEMag*Visu.Data.F(goodchannels{MEG},:);
        else
            load(HeadModelFile,'MNEMag');            
        end
        
        set(DATAPLOT,'Userdata',Visu)
    end
    
    %-------------------------------------------------------------
    
    % Sampling rate
    srate = abs(Visu.Data.Time(1)-Visu.Data.Time(2) );   % Assuming time is in sec.
    
    for kur = 1:length(current)
        
        switch find([display_type{:}])
            
        case 1 % Single Window
            % Detect 'Single-Map' window; creates if does not exist
            map_single_win = findobj(0,'Tag',['map_single',int2str(current(kur))]);
            if isempty(map_single_win)
                map_single_win = open('map_single.fig');
                set(map_single_win,'Tag',['map_single',int2str(current(kur))],'Name',...
                    [str{current(kur)},' Mapping'],...
                    'color',backcolor);
            else 
                figure(map_single_win)
            end
            
            ctime = round((get(handles.slider_time,'Value')/1000-Visu.Data.Time(1))/srate)+1;
            data = Visu.Data.F(goodchannels{kur},ctime) ;
            
            if (current_visu == 2) & (current(kur) == 1)% & ~isempty(badchannels) % MEG with bad channels and visualization of the gradient amplitude
                channels = [1:length(goodchannels{kur})];
                odd_channels = goodchannels{kur}(find(rem(goodchannels{kur},2) == 1));
                
                if ~isempty(badchannels{kur})
                    odd = badchannels{kur}(find(rem(badchannels{kur},2) == 1));
                    even = setdiff(badchannels{kur},odd);
                    odd = unique([odd',intersect(odd_channels,(even - 1))]);
                else
                    odd = [];
                    even = [];
                end
                
                good_odd_channels = setdiff(odd_channels,odd);
                [c,ia,ib] = intersect(goodchannels{kur},good_odd_channels);%-goodchannels(1)+1);
                chanloc = chanloc(:,ia);
                grad_meg = [];
                j = 0;
                for i = good_odd_channels
                    j = j+1;
                    grad_meg(j) = norm([Visu.Data.F(i,ctime),Visu.Data.F(i+1,ctime)]);
                end
                data = grad_meg;
                
            elseif current_visu == 3 & current(kur) == 1 % MEG and MN estimation of the magnetic field at the planar gradiometers
                data = Visu.MNEdata(:,ctime);
            end
            
            switch head_shape
            case 1 % Sphere
                [x,y,z,xs,ys,sensor,map_sph] = carto_sph((chanloc{kur})',data,[0 0 0]);
                if get(handles.ShowSensorLocs,'Value')
                    set(sensor,'Visible','on');
                else
                    set(sensor,'Visible','off');
                end
                
                if current(kur) == 1
                    if exist('good_odd_channels','var')
                        n_chan = length(good_odd_channels);
                        name = good_odd_channels;
                    else
                        n_chan = length(goodchannels{kur}); 
                        name = goodchannels{kur} - min(Visu.ChannelID{current(kur)})+1 ;
                    end
                    
                    if get(handles.ShowSensorLabels,'Value')
                        for i = 1:n_chan
                            h = text(1.05*x(i),1.05*y(i),1.05*z(i),Visu.Channel(goodchannels{kur}(i)).Name);
                            set(h,'horizontalalignment','center','fontsize',8,'color',...
                                textcolor,'fontweight','normal')
                        end
                    end
                else
                    if get(handles.ShowSensorLabels,'Value')
                        for i = 1:length(goodchannels{kur})
                            h = text(1.05*x(i),1.05*y(i),1.05*z(i),Visu.Channel(goodchannels{kur}(i)).Name);
                            set(h,'horizontalalignment','center','fontsize',10,'color',...
                                textcolor,'fontweight','bold')
                        end
                    end
                end
                axis vis3d, %axis equal
                if ~isfield(Visu.Data,'Device');
                    Visu.Data.Device = 'jpol'; % Default setting
                end
                
                if findstr(lower(Visu.Data.Device),'ctf')
                    view(-90,90) % Noise pointing upwards
                end
                
            case 2 % Sensors shape
                [x,y,xs,ys,sensors,map_sph] = carto_sensors(chanloc{kur}',data);
                
            case 3 % Scalp Surface
                close(map_single_win)
                
                dataplot_cb mesh_rendering
                TessWin = findobj(0,'Tag','tesselation_select');
                figure(TessWin)
                set(findobj(TessWin,'Tag','DataVisualization'),'Value',2)
                dataplot_cb AddData
                return
            end 
            
            if RELATIVE == 1
                
                if current_visu == 3
                    datacomplete = Visu.MNEdata;
                else
                    datacomplete = Visu.Data.F(goodchannels{kur},:);
                end
                M = max(abs(datacomplete(:)));
                % MEG with bad channels and visualization of the gradient amplitude
                if (current_visu == 2) & (current(kur) == 1)
                    caxis([0,M])
                    colormap hot
                    clrbr = colorbar('horiz');
                    set(clrbr,'xcolor',frontcolor,'ycolor',frontcolor)
                else
                    caxis([-M,M])
                end
                
            else
                if (current_visu == 2) & (current(kur) == 1)% MEG with bad channels and visualization of the gradient amplitude
                    caxis([0,max(abs(data))])
                else
                    caxis([-max(abs(data)),max(abs(data))])
                end
                
            end
            
            dataplot_cb Colorbar_mapping
            
            map_sph.handle = map_sph;
            map_sph.x = x;
            map_sph.y = y;
            map_sph.xs = xs;
            map_sph.ys = ys;
            set(map_single_win,'Userdata',map_sph)
            
            
        case 2 % Slides
            sstart = str2num(get(handles.start,'String'))/1000;
            if sstart < Visu.Data.Time(1)
                sstart = Visu.Data.Time(1);
            end
            
            sstep = str2num(get(handles.step,'String'))/1000;
            
            sstop = str2num(get(handles.stop,'String'))/1000;
            if sstop > Visu.Data.Time(end)
                sstop = Visu.Data.Time(end);
            end
            
            samples = round(([sstart,sstop]-Visu.Data.Time(1))/srate)+1;
            sstep = round(sstep/srate);
            samples = samples(1):sstep:samples(2);
            nsamples = length(samples);
            if nsamples > 40 % Warning, too many slides may take a while to create.
                button = questdlg({'You have requested ',int2str(nsamples),' slide(s)','Do you still want to proceed ?'},'','Yes','No','Yes');
                if strcmp(button,'No')
                    return
                end
            end
            
            map_slides_win = findobj(0,'Tag',['map_slides',int2str(current(kur)),'_',get(handles.start,'String'),'_',get(handles.step,'String'),'_',get(handles.stop,'String')]);
            
            if isempty(map_slides_win )
                map_slides_win = open('map_single.fig');
                set(map_slides_win ,'Tag',['map_slides',int2str(current(kur)),'_',get(handles.start,'String'),'_',get(handles.step,'String'),'_',get(handles.stop,'String')],...
                    'color',backcolor);
                
                drawnow
                
            else 
                figure(map_slides_win)
            end
            
            % Figure Layout
            k = size(samples,2);
            c = ceil(sqrt(k));
            r = ceil(sqrt(k));  
            switch head_shape
            case 1 % Sphere
                iplot = 0;
                for ctime = samples
                    iplot = iplot+1;
                    figure(map_slides_win)
                    subplot(c,r,iplot)
                    axis off
                    data = Visu.Data.F(goodchannels{kur},ctime)+eps;
                    
                    if (current_visu == 2) & (current == 1) % & ~isempty(badchannels) % MEG with bad channels and visualization of the gradient amplitude
                        if ctime == samples(1)
                            channels = [1:length(Visu.ChannelID{current(kur)})];
                            odd_channels = channels(find(rem(channels,2) == 1));
                            if ~isempty(badchannels{kur})
                                odd = badchannels{kur}(find(rem(badchannels{kur},2) == 1));
                                even = setdiff(badchannels{kur},odd);
                                odd = unique([odd',intersect(odd_channels,(even - 1))]);
                                
                            else
                                odd = [];
                                even = [];
                            end
                            good_odd_channels = setdiff(odd_channels,odd);
                            [cc,ia,ib] = intersect(goodchannels{kur},good_odd_channels-goodchannels{kur}(1)+1);
                            chanloc{kur} = chanloc{kur}(:,ia);
                        end
                        grad_meg = [];
                        j = 0;
                        for i = (good_odd_channels)
                            j = j+1;
                            grad_meg(j) = norm([Visu.Data.F(i,ctime),Visu.Data.F(i+1,ctime)]);
                        end
                        data = grad_meg;
                    elseif current_visu == 3 & current(kur) == 1
                        data = Visu.MNEdata(:,ctime);    
                    end
                    
                    if iplot == 1
                        [x,y,z,xs,ys,sensor,map_sph] = carto_sph(chanloc{kur}',data,[0 0 0]);
                        set(findobj(get(gca,'Children'),'Type','line'),'Visible','off')
                        axorig  = get(map_sph,'Parent');
                        set(gcf,'CurrentAxes',axorig)
                        cmap = get(gcf,'Colormap');
                        map_sph2 = copyobj(map_sph,gca); % Trick to enforce proper scaling of the axis
                        delete(map_sph)
                        map_sph = map_sph2; 
                    else
                        map_sph2 = copyobj(map_sph,gca);
                        cdata_map = griddata(x,y,data,xs,ys,'invdist');
                        set(map_sph2,'CData',cdata_map)
                    end
                    
                    if RELATIVE == 1
                        if iplot == 1
                            if current_visu == 3
                                datacomplete = Visu.MNEdata;
                            else
                                datacomplete = Visu.Data.F(goodchannels{kur},:);
                            end
                            M = max(abs(datacomplete(:)));
                        end
                        caxis([-M,M])
                    else
                        caxis([-max(abs(data)),max(abs(data))])
                    end
                    axis equal
                    if findstr(lower(Visu.Data.Device),'ctf')
                        view(-90,90) % Noise pointing upwards
                    end
                    axis tight
                    
                    h = title(num2str(((ctime-1)*srate + Visu.Data.Time(1))*1000,4));
                    set(h,'fontweight','normal','color',frontcolor,'Fontname','helvetica','Fontsize',8,'FontUnits','Point')
                    %set(h,'fontunits','normal')
                    % SurfaceViewer update
                    TessSelectWin = findobj(0,'Tag','tesselation_select');
                    if ~isempty(TessSelectWin) % Check if Surface Viewer is open
                        cortx_handles = guihandles(TessSelectWin );
                        ScalpMaps = get(cortx_handles.ScalpMaps,'Value');
                        ColorSensors = get(cortx_handles.ColorSensors,'Value');
                        CorticalMap = get(cortx_handles.CorticalMap,'Value');
                        previous  = findobj(0,'tag','tessellation_window'); 
                        if ctime == samples(1);
                            pprevious  = findobj(0,'tag','tesselation_select'); 
                            hpprevious = guihandles(pprevious);
                            OrthoViews = get(hpprevious.OrthoViews,'Value');
%                            clear hprevious
                        end
                        
                        SlidesWin = findobj(0,'tag','subplot_tess_window'); 
                        if OrthoViews == 0
                            if isempty(SlidesWin)
                                SlidesWin = open('tessellation_window.fig');
                                set(SlidesWin,'tag','subplot_tess_window'); 
                            end
                        else % Open a new window for each time sample when OrthoViews are requested
                            SlidesWin = open('tessellation_window.fig');
                            set(SlidesWin,'tag','subplot_tess_window'); 
                        end
                            
                        mapping_win = findobj(0,'Tag','mapping'); 
                        
                        if ctime == samples(1) | OrthoViews == 1
                            phandles = guihandles(previous);
                            VIEW = get(phandles.MainAxes,'view');
                            Lights = findobj(phandles.MainAxes,'type','light');
                            Colormap = get(previous,'Colormap');
                            set(SlidesWin,'Colormap',Colormap)
                        end
                        
                        if ~isempty(mapping_win)
                            slider_time = findobj(mapping_win,'Tag','slider_time');
                            current_time= findobj(mapping_win,'Tag','current_time');
                        end
                        
                        set(slider_time,'Value',1000*Visu.Data.Time(ctime))
                        set(current_time,'String',1000*Visu.Data.Time(ctime))
                        figure(SlidesWin)
                        if OrthoViews == 0
                            hold on
                            ax = subplot(c,r,iplot);
                            axis off, axis tight
                           % copyobj(Lights,ax);
                        else
                            set(previous,'Tag','')
                            set(SlidesWin,'Tag','tessellation_window');
                            
                        end
                        dataplot_cb tesselation_select_done                        
                        axis equal, axis tight
                        if OrthoViews == 1
                            dataplot_cb OrthoViews
                            set(SlidesWin,'Name',[num2str(((ctime-1)*srate + Visu.Data.Time(1))*1000,4), ' ms'])
                        else
                            set(ax,'view',VIEW)
                        end
                        
                        figure(SlidesWin)
                        h = title(num2str(((ctime-1)*srate + Visu.Data.Time(1))*1000,4));
                        set(h,'fontweight','normal','color',frontcolor,'Fontname','helvetica','Fontsize',8,'FontUnits','Point')
                        %set(h,'Fontunits','normal')
                        
                        if OrthoViews == 1 & get(findobj(mapping_win,'Tag','SaveFigures'),'Value') % OrthoVoews are requested : Save each slide in a separate window
                            if ctime == samples(1)
                                ResFiles = get(hpprevious.ResultFiles,'String');
                                ResFile = ResFiles{get(hpprevious.ResultFiles,'Value')};
                                [path,file,ext] = fileparts(Users.CurrentData.StudyFile);
                                ResFile = fullfile(Users.STUDIES,path,ResFile);
                                [path,ResFile,ext] = fileparts(ResFile);
                            end
                            
                            time = num2str(((ctime-1)*srate + Visu.Data.Time(1))*1000,4);
                            
                            ImageFile = fullfile(path,[ResFile,'_OrthoViews_',time,'.jpg']);
                            saveas(SlidesWin,ImageFile,'t')
                            
                        end
                        
                    end
                    
                end
            end
            map_sph.handle = map_sph;
            map_sph.x = x;
            map_sph.y = y;
            map_sph.xs = xs;
            map_sph.ys = ys;
            set(map_slides_win,'Userdata',map_sph)
            
            if OrthoViews == 0 & get(findobj(mapping_win,'Tag','SaveFigures'),'Value') % Regular single slide window - no orthoview
                ResFiles = get(hpprevious.ResultFiles,'String');
                ResFile = ResFiles{get(hpprevious.ResultFiles,'Value')};
                [path,file,ext] = fileparts(Users.CurrentData.StudyFile);
                ResFile = fullfile(Users.STUDIES,path,ResFile);
                [path,ResFile,ext] = fileparts(ResFile);
                
                time = [num2str(((samples(1)-1)*srate + Visu.Data.Time(1))*1000,4),'_', num2str(((samples(end)-1)*srate + Visu.Data.Time(1))*1000,4)];
                
                ImageFile = fullfile(path,[ResFile,'_Slides_',time,'.jpg']);
                saveas(SlidesWin,ImageFile,'jpg')
                
            end
            
            if get(findobj(mapping_win,'Tag','SaveFigures'),'Value')
                ImageFile = fullfile(path,[ResFile,'_Data_Slides_',time,'.jpg']);
                saveas(map_slides_win,ImageFile,'jpg')
            end
            
        case 3 % Movie
            sstart = str2num(get(handles.start,'String'))/1000;
            if sstart < Visu.Data.Time(1)
                sstart = Visu.Data.Time(1);
            end
            
            sstep = str2num(get(handles.step,'String'))/1000;
            
            sstop = str2num(get(handles.stop,'String'))/1000;
            if sstop > Visu.Data.Time(end)
                sstop = Visu.Data.Time(end);
            end
            
            samples = round(([sstart,sstop]-Visu.Data.Time(1))/srate)+1;
            sstep = round(sstep/srate);
            samples = samples(1):sstep:samples(2);
            nsamples = length(samples);
            if nsamples > 40 % Warning, too many slides may take a while to create.
                button = questdlg({'You have requested ',int2str(nsamples),' slide(s)','Do you still want to proceed ?'},'','Yes','No','Yes');
                if strcmp(button,'No')
                    return
                end
            end
            
            map_movie_win = findobj(0,'Tag',['map_movie',int2str(current(kur)),'_',get(handles.start,'String'),'_',get(handles.step,'String'),'_',get(handles.stop,'String')]);
            if isempty(map_movie_win)
                map_single = open('map_single.fig'); % Create a new window
                set(map_single,'Tag',['map_movie',int2str(current(kur)),'_',get(handles.start,'String'),'_',get(handles.step,'String'),'_',get(handles.stop,'String')],...
                    'color','w')
                map_movie_win = findobj(0,'Tag',['map_movie',int2str(current(kur)),'_',get(handles.start,'String'),'_',get(handles.step,'String'),'_',get(handles.stop,'String')]);
            else 
                figure(map_movie_win)
            end
            
            switch head_shape
            case 1 % Sphere
                iplot = 0;
              
                [moviefile, moviepath] = uiputfile('*.avi', 'Save Movie File as...');
                if moviefile == 0, return, end
                cd(moviepath)
                
                mov = avifile(moviefile,'FPS',2,'QUALITY',50);   
                moviefiletopo = moviefile;
                [path,file,ext] = fileparts(moviefiletopo);
                moviefiletopo = [file,'_topo.avi'];
               
                movtopo = avifile(moviefiletopo,'FPS',2,'QUALITY',50);   
                
                for ctime = samples
                    iplot = iplot+1;
                    
                    data = Visu.Data.F(goodchannels{kur},ctime)+eps ;
                    if (current_visu == 2) & (current(kur) == 1) %MEG with bad channels and visualization of the gradient amplitude
                        if ctime == samples(1)
                            channels = [1:length(Visu.ChannelID{current(kur)})];
                            odd_channels = channels(find(rem(channels,2) == 1));
                            if ~isempty(badchannels{kur})
                                odd = badchannels{kur}(find(rem(badchannels{kur},2) == 1));
                                even = setdiff(badchannels{kur},odd);
                                odd = unique([odd',intersect(odd_channels ,(even - 1))]);
                            else
                                odd = [];
                                even = [];
                            end
                            good_odd_channels = setdiff(odd_channels,odd);
                            [c,ia,ib] = intersect(goodchannels{kur},good_odd_channels-goodchannels{kur}(1)+1);
                            chanloc{kur} = chanloc{kur}(:,ia);
                        end
                        grad_meg = [];
                        j = 0;
                        for i = (good_odd_channels)
                            j = j+1;
                            grad_meg(j) = norm([data(i),data(i+1)]);
                        end
                        data = grad_meg;
                    elseif current_visu == 3 & current(kur) == 1
                        data = Visu.MNEdata(:,ctime);    
                    end
                    
                    
                    if ctime == samples(1)
                        [x,y,z,xs,ys,sensor,map_sph] = carto_sph(chanloc{kur}',data,[0 0 0]);
                        set(findobj(get(gca,'Children'),'Type','line'),'Visible','off') % Erase the sensor positions
                        axorig = get(map_sph,'Parent');
                        set(gcf,'CurrentAxes',axorig)
                        %M = moviein(nsamples,map_movie_win);
                        %h = title(num2str(((ctime-1)*srate+Visu.Data.Time(1))*1000,4));
                          h = text(0.05,0.05,0,num2str(((ctime-1)*srate + Visu.Data.Time(1))*1000,4),'units','normalized');
                        set(h,'fontweight','normal','color',frontcolor,'Fontname','helvetica','Fontsize',8,'FontUnits','Point')

                        set(h,'fontweight','normal','color',frontcolor,'Fontname','helvetica','Fontsize',8,'FontUnits','Point')
                        axis manual                 % Freeze Axes limits
                        set(gca,'nextplot','replacechildren');
                        if RELATIVE == 1
                            if current_visu == 3
                                datacomplete = Visu.MNEdata;
                            else
                                datacomplete = Visu.Data.F(goodchannels{kur},:);
                            end
                            Max = max(abs(datacomplete(:)));
                            caxis([-Max,Max])
                        else
                            caxis([-max(abs(data)),max(abs(data))])
                        end
                        if findstr(lower(Visu.Data.Device),'ctf')
                            view(-90,90) % Noise pointing upwards
                        end
                        axis tight
                                                    
                    else
                        cdata_map = griddata(x,y,data,xs,ys,'invdist');
                        set(h,'String',num2str(((ctime-1)*srate+Visu.Data.Time(1))*1000,4));
                        set(map_sph,'CData',cdata_map)
                    end
                    %                     axis equal, axis vis3d
                    Ftopo = getframe(get(map_sph,'Parent'));
                    movtopo = addframe(movtopo,Ftopo);    
                     
                    %[M(:,iplot)] = getframe(map_movie_win);
                    
                    % SurfaceViewer update
                    TessSelectWin = findobj(0,'Tag','tesselation_select');
                    if ~isempty(TessSelectWin) % Check if Surface Viewer is open
                        handles = guihandles(TessSelectWin );
                        ScalpMaps = get(handles.ScalpMaps,'Value');
                        ColorSensors = get(handles.ColorSensors,'Value');
                        CorticalMap = get(handles.CorticalMap,'Value');
                        previous  = findobj(0,'tag','tessellation_window'); 
                        
                        if isempty(previous)
                            previous = open('tessellation_window.fig');
                        end
                        figure(previous)
                        mapping_win = findobj(0,'Tag','mapping'); 
                        if ~isempty(mapping_win)
                            slider_time = findobj(mapping_win,'Tag','slider_time');
                            current_time= findobj(mapping_win,'Tag','current_time');
                        end
                        
                        set(slider_time,'Value',1000*Visu.Data.Time(ctime))
                        set(current_time,'String',1000*Visu.Data.Time(ctime))
                        
                        dataplot_cb tesselation_select_done

                        figure(previous)
                        if ctime == samples(1)
                            hxt = text(0.05,0.05,0,num2str(((ctime-1)*srate + Visu.Data.Time(1))*1000,4),'units','normalized');
                            set(hxt,'fontweight','normal','color',frontcolor,'Fontname','helvetica','Fontsize',8,'FontUnits','Point')
                            
                            set(gca,'nextplot','replacechildren');
                            
                        else
%                             set(hxt,'String',' '), drawnow
                            set(hxt,'String',num2str(((ctime-1)*srate + Visu.Data.Time(1))*1000,4))
                        end
                        
                        drawnow
                        
                        F = getframe(gca);
                       	mov = addframe(mov,F);    
                        
                    end
                    
                end
                cmap = colormap; % Retrieves Current Colormap
                
            end
            
            mov = close(mov);
            movtopo = close(movtopo);
            
            % Save Movie file 
%             [moviefile, moviepath] = uiputfile('*.mpg', 'Save Movie File as...');
%             if moviefile == 0, return, end
%             cd(moviepath)
%             %save(moviefile,'cmap','M') Matlab format
%             disp('Saving Movie File...')
%             mpgwrite(M,cmap,moviefile)
            msgbox('Movie Save Completed')
            disp('Saving Movie File... -> Done')
            
            map_sph.handle = map_sph;
            map_sph.x = x;
            map_sph.y = y;
            map_sph.xs = xs;
            map_sph.ys = ys;
            set(map_movie_win,'Userdata',map_sph)
        end
    end
    
    set(findobj(0,'Tag','rotate'),'Userdata',get(map_sph.handle,'Parent')) % Axes handle for possible future rotattion using 'rotate'
    
   
    %----------------------------------------------------------------------------
    
case 'mapping_rotate' % Make the last 3D view rotate 
    ax = get(gcbo,'Userdata');
    if isempty(ax), return, end
    axes(ax)
    switch get(gcbo,'Value')
    case 1
        rotate3d on
    otherwise
        rotate3d off
    end
    
    %----------------------------------------------------------------------------
    
case 'mapping_display_type' % Checkboxes Mutually incompatible
    DATAPLOT = findobj(0,'Tag','mapping'); 
    MEG = findobj(DATAPLOT,'Tag','single');
    EEG = findobj(DATAPLOT,'Tag','slides');
    OTHER = findobj(DATAPLOT,'Tag','movie');
    mutincomp([MEG,EEG,OTHER])
    h = findobj([MEG,EEG,OTHER],'Value',1); 
    if length(h)>1
        set(h(2),'Value',0) % Just one modality at a time please !
    end
    
    %----------------------------------------------------------------------------
    
case 'quit'
    close gcbf
    
    %----------------------------------------------------------------------------
case 'see_sensors' % Visualize sensor locations using 3D spheres
    
    TessWin = findobj(0,'Tag','tesselation_select');
    hTessWin = guihandles(TessWin);
    
    %     mutincomp([hTessWin.Sensors3D,hTessWin.SensorsMarkers]);
    previous  = openfig('tessellation_window.fig','reuse');
    
    if get(hTessWin.Sensors3D,'Value') == 0
        if get(hTessWin.SensorsMarkers,'Value') == 1
            sph= findobj(previous,'Tag','SENSORS');
            delete(sph); set(previous,'Userdata',[])      % Redraw all sensors - to avoid mess with handles when resizing and coloring the sphere
            dataplot_cb see_sensors_markers
            return
        else
            sph= findobj(previous,'Tag','SENSORS');
            delete(sph); set(previous,'Userdata',[])      % Redraw all sensors - to avoid mess with handles when resizing and coloring the sphere
            return
        end
    end
    
    Visu = get(DATAPLOT,'Userdata');
    previous  = openfig('tessellation_window.fig','reuse');
    
    
    SIZE = sqrt(str2num(get(hTessWin.SensorSize,'String'))/10); % get sensor size
    if isempty(SIZE), SIZE = 1; end
    
    sph= findobj(previous,'Tag','SENSORS');
    delete(sph); set(previous,'Userdata',[])      % Redraw all sensors - to avoid mess with handles when resizing and coloring the sphere
    
    % Channels Locations:
    if ~isempty(find(Visu.Data.ChannelFlag == -1))
        goodchannels = setdiff(Visu.ChannelID{current},find(Visu.Data.ChannelFlag == -1));% - min(Visu.ChannelID{current})+1; % Discard bad channels
        badchannels = intersect(Visu.ChannelID{current},find(Visu.Data.ChannelFlag == -1));% - min(Visu.ChannelID{current})+1;
    else
        goodchannels = Visu.ChannelID{current};
        badchannels = [];
    end
    j = 0;
    chanloc = [Visu.Channel(goodchannels).Loc];
    chanloc = chanloc(:,1:2:end);
    for chan = goodchannels %Visu.ChannelID{current}
        j = j+1;
        figure(previous)
        hold on
        if j == 1
            maxx = max(abs(get(gca,'Xlim')/50))*SIZE;
            [X,Y,Z] = sphere;
        end
        sph(j) = surf(maxx*X+chanloc(1,j),maxx*Y+chanloc(2,j),maxx*Z+chanloc(3,j),'Visible','off');
    end
    
    set(sph,'Userdata',SIZE,'Visible','on','facelighting','Gouraud','edgelighting','Gouraud','Tag','SENSORS','facecolor',[.1 .1 .9],'Edgecolor','none')
    axis equal, axis vis3d
    varargout{1} = sph;
    
    %--------------------------------------------------------------------------------------------------------------------
case 'see_sensors_markers' % Visualize sensor locations using regular markers
    
    TessWin = findobj(0,'Tag','tesselation_select');
    hTessWin = guihandles(TessWin);
    
    %     mutincomp([hTessWin.Sensors3D,hTessWin.SensorsMarkers]);
    previous  = openfig('tessellation_window.fig','reuse');
    
    if get(hTessWin.SensorsMarkers,'Value') == 0
        if get(hTessWin.Sensors3D,'Value') == 1
            sph= findobj(previous,'Tag','SENSORS');
            delete(sph); set(previous,'Userdata',[])      % Redraw all sensors - to avoid mess with handles when resizing and coloring the sphere
            dataplot_cb see_sensors
            return
        else
            sph= findobj(previous,'Tag','SENSORS');
            delete(sph); set(previous,'Userdata',[])      % Redraw all sensors - to avoid mess with handles when resizing and coloring the sphere
            return
        end
    end
    
    Visu = get(DATAPLOT,'Userdata');
    
    SIZE = sqrt(str2num(get(hTessWin.SensorSize,'String'))); % get sensor size
    if isempty(SIZE), SIZE = 1; end
    
    sph= findobj(previous,'Tag','SENSORS');
    delete(sph); set(previous,'Userdata',[])      % Redraw all sensors - to avoid mess with handles when resizing and coloring the sphere
    
    % Channels Locations:
    if ~isempty(find(Visu.Data.ChannelFlag == -1))
        goodchannels = setdiff(Visu.ChannelID{current},find(Visu.Data.ChannelFlag == -1));% - min(Visu.ChannelID{current})+1; % Discard bad channels
        badchannels = intersect(Visu.ChannelID{current},find(Visu.Data.ChannelFlag == -1));% - min(Visu.ChannelID{current})+1;
    else
        goodchannels = Visu.ChannelID{current};
        badchannels = [];
    end
    j = 0;
    chanloc = [Visu.Channel(goodchannels).Loc];
    chanloc = chanloc(:,1:2:end);
    hold on
    sph = scatter3(chanloc(1,:),chanloc(2,:),chanloc(3,:),'filled');
    
    set(sph,'Userdata',SIZE,'Visible','on','Tag','SENSORS',...
        'Markerfacecolor',[.1 .1 .9],'Markeredgecolor','k', 'MarkerSize',SIZE);
    axis equal, axis vis3d
    varargout{1} = sph;
    
    %--------------------------------------------------------------------------------------------------------------------
    
    
case 'DataOnSensors' % Sensors are color-coded according to the data at each location
    
    dataplot_cb mapping_create
    Visu = get(DATAPLOT,'Userdata');
    previous  = openfig('tessellation_window.fig','reuse');
    
    
    % Handles to the spherical representation of the sensors 
    sph = findobj(previous,'Tag','SENSORS');
    if isempty(sph) | isempty(get(previous,'userdata'))
        
        if ~isempty(sph)
            if strcmp(get(sph(1),'type'),'surface')
                sph = dataplot_cb('see_sensors');
            else
                sph = dataplot_cb('see_sensors_markers');
            end
        else
            TessWin = findobj(0,'Tag','tesselation_select');
            hTessWin = guihandles(TessWin);
            if get(hTessWin.Sensors3D,'Value')
                sph = dataplot_cb('see_sensors');
            else
                sph = dataplot_cb('see_sensors_markers');    
            end
        end
        set(previous,'UserData',sph);
    else
        sph = get(previous,'Userdata'); % Need this and line above to keep sensor ordering correct - sph = findobj creates an arbitrary ordering otherwise
    end
    
    % Bring the time slider - call the mapping window if available
    MAPPING = openfig('mapping.fig','reuse');
    hMAPPING = guihandles(MAPPING);
    
    % Good/Bad Channels
    if ~isempty(find(Visu.Data.ChannelFlag == -1))
        goodchannels = setdiff(Visu.ChannelID{current},find(Visu.Data.ChannelFlag == -1));
        badchannels = intersect(Visu.ChannelID{current},find(Visu.Data.ChannelFlag == -1));
    else
        goodchannels = setdiff(Visu.ChannelID{current},find(Visu.Data.ChannelFlag == -1));
        badchannels = [];
    end
    
    % Sampling rate
    srate = abs(Visu.Data.Time(1)-Visu.Data.Time(2) );   % Assuming time is in sec.
    ctime = round((get(hMAPPING.slider_time,'Value')/1000-Visu.Data.Time(1))/srate)+1;
    axx = get(sph(1),'Parent');
    
    data = Visu.Data.F(goodchannels,:); clear Visu
    %set(axx,'Clim',[-max(abs(data(:))) max(abs(data(:)))]);
    caxis(axx,[-max(abs(data(:))) max(abs(data(:)))]);
    data = data(:,ctime);
    
    C = [flipud(fliplr(hot(128)));hot(128)];
    colormap(axx,C);
    
    % Manipulation to get the color properly for each sensor sphere
    
    set(sph,'visible','off')
    TessWin = findobj(0,'Tag','tesselation_select');
    hTessWin = guihandles(TessWin);
    
    if get(hTessWin.Sensors3D,'Value')
        zdata = get(sph(1),'Zdata');                
        for k=1:length(sph)
            cdata = data(k)*ones(size(get(sph(k),'zdata')));
            set(sph(k),'CData',cdata,'facecolor','flat','CDataMapping','scaled');
        end
    else
        for k=1:length(sph)
            set(sph(k),'Markerfacecolor',C( max([round(size(C,1)*(data(k)-min(caxis(axx)))/(max(caxis(axx))-min(caxis(axx)))),1]),:));
        end
        
    end
    
    set(sph,'visible','on')
    
    %--------------------------------------------------------------------------------------------------------------------
case 'DataOnScalp' % Scalp topography
    
    dataplot_cb mapping_create
    
    TessSelect = findobj(0,'Tag','tesselation_select');
    hSelect = guihandles(TessSelect);
    ActiveTess = get(hSelect.removed,'String'); % Find the active scalp surface
    % Check if the CORTEX keyword is present
    for k = 1:length(ActiveTess)
        flag(k) = ~isempty(findstr(lower(ActiveTess{k}),'head')); %KND:scalp->head
    end
    iScalp = find(flag);
    iScalp = iScalp(1);
    if isempty(iScalp)
        h = msgbox('Please select a scalp envelope from the tessellated surfaces available.');
        return
    end
    TessWin = openfig('tessellation_window.fig','reuse');
    
    Visu = get(DATAPLOT,'Userdata');
    if ~isempty(find(Visu.Data.ChannelFlag == -1))
        goodchannels = setdiff(Visu.ChannelID{current},find(Visu.Data.ChannelFlag == -1));% - min(Visu.ChannelID{current})+1; % Discard bad channels
        badchannels = intersect(Visu.ChannelID{current},find(Visu.Data.ChannelFlag == -1));% - min(Visu.ChannelID{current})+1;
    else
        goodchannels = Visu.ChannelID{current};
        badchannels = [];
    end
    
    Scalp = findobj(TessWin,'Type','patch','Tag',ActiveTess{iScalp}); % Need to find a better way to identify scalp when multiple surfaces are present in tessellation_win
    if isempty(Scalp), tesselation_select_done, return, end
    
    if isempty(get(Scalp,'Userdata'))
        figure(TessWin)
        C = [flipud(fliplr(grayish(hot(128),.3)));grayish(hot(128),.3)];
        colormap(C)
        
        scalp.vertices = get(Scalp,'vertices');
        % Channels Locations
        j = 0;
        for chan = goodchannels 
            j = j+1;
            %Projection of sensors on surface
            celec = ones(size(scalp.vertices,1),1)*Visu.Channel(chan).Loc(:,1)';
            dist = norlig(scalp.vertices-celec);
            [minn(j) imin(j)] = min(dist);
        end
        scalp.chanloc = [scalp.vertices(imin,1),scalp.vertices(imin,2),scalp.vertices(imin,3)];
        
        % Sampling rate
        scalp.srate = abs((Visu.Data.Time(2)-Visu.Data.Time(1))); 
        data = Visu.Data.F(goodchannels,:);
        axx= get(Scalp,'Parent');
        set(axx,'Clim',[-max(abs(data(:))) max(abs(data(:)))]);    
        set(Scalp,'Userdata',scalp)
    else
        scalp = get(Scalp,'Userdata');
    end
    
    
    % Get the data from the mapping window
    MAPPING = openfig('mapping.fig','reuse');
    hMAPPING = guihandles(MAPPING);
    ctime = round((get(hMAPPING.slider_time,'Value')/1000-Visu.Data.Time(1))/scalp.srate)+1;
    vertxcolor = interp_mail(scalp.vertices,scalp.chanloc,Visu.Data.F(goodchannels,ctime));
    set(Scalp,'FaceVertexCData',vertxcolor,'facecolor','interp');
    
    %--------------------------------------------------------------------------------------------------------------------
    
case 'CorticalMap' % See cortical current maps interpolated on the proper cortical surface
    
    TessSelect = findobj(0,'Tag','tesselation_select');
    hSelect = guihandles(TessSelect);
    ActiveTess = get(hSelect.removed,'String'); % Find the active scalp surface
    iCortex = get(hSelect.removed,'Value'); % Find the active scalp surface    
    
    if isempty(iCortex)
        h = msgbox('Please select a cortex surface from the tessellations available.');
        return
    end
    TessWin = findobj(0,'Tag','tessellation_window');
    SlidesWin = findobj(0,'Tag','subplot_tess_window');
    if ~isempty(SlidesWin)
        TessWin = SlidesWin; % Subplot or movie window
    end
    
    if isempty(TessWin)
        TessWin = openfig('tessellation_window.fig');
        dataplot_cb('loaddata',Users.CurrentData.StudyFile,Users.CurrentData.DataFile); % Refresh by reloading data 
    end
    
    % Check if loaded Results match this surface (ie number of sources = number of vertices of selected cortical surface)
    Results = get(hSelect.ResultFiles,'Userdata');
    nSources = size(Results.ImageGridAmp,1);
    
    if nargin == 1 & get(hSelect.OrthoViews,'Value') == 0
        if iscell(ActiveTess)
            Cortex = findobj(get(TessWin,'CurrentAxes'),'Type','patch','Tag',ActiveTess{iCortex}); %CHEAT - need to be improved ?
        else
            Cortex = findobj(get(TessWin,'CurrentAxes'),'Type','patch','Tag',ActiveTess); %CHEAT - need to be improved ?    
        end
    elseif nargin == 1 & get(hSelect.OrthoViews,'Value') == 1 % Orthogonal views are requested
        Cortex = findobj(get(TessWin,'CurrentAxes'),'Type','patch','Tag',ActiveTess,'Visible','on'); %CHEAT - need to be improved ?    
        Cortex = Cortex(1);
    else
        Cortex = varargin{1}(1);
    end
    
    %set(Cortex,'Visible','off')
    if ~isfield(get(Cortex,'Userdata'),'srate')
        Visu = get(DATAPLOT,'Userdata');
        figure(TessWin)

        cortex = get(Cortex,'Userdata');
        
        cortex.vertices = get(Cortex,'vertices');
        % Sampling rate
        cortex.srate = abs(Visu.Data.Time(2)-Visu.Data.Time(1)); 
        data = Results.ImageGridAmp;
        axx= get(Cortex,'Parent');
        set(axx,'Clim',[-max(abs(data(:))) max(abs(data(:)))]);    
        set(Cortex,'Userdata',cortex)
        
        % Result time window has priority over the original time window for the data - replace
        Visu.Data.Time = Results.ImageGridTime; % Need to do better than that - CHEAT
        try
            Visu.Data.F = Visu.Data.F(:,Results.Time(1):Results.Time(end)); % Should work only the first time the result time series are called - otherwise do nothing
        catch
            Visu.Data.F = Visu.Data.F; % Do nothing
        end
        
        set(DATAPLOT,'Userdata',Visu);
        
        M = max(abs(Results.ImageGridAmp(:)));
        set(hSelect.Colorbar,'Userdata',M);
        
    else
        cortex = get(Cortex,'Userdata');
    end
    
    dataplot_cb mapping_create
    
    % Get the data from the mapping window
    MAPPING = findobj(0,'Tag','mapping');
    hMAPPING = guihandles(MAPPING);
    
    if iscell(cortex)
        ctime = round((get(hMAPPING.slider_time,'Value')/1000- Results.ImageGridTime(1))/cortex{1}.srate)+1;
    else
        ctime = round((get(hMAPPING.slider_time,'Value')/1000- Results.ImageGridTime(1))/cortex.srate)+1;
    end
    if ctime < 0, ctime =1; end
    
    if get(hSelect.AbsoluteCurrent,'Value')
        set(Cortex,'FaceVertexCData',abs(Results.ImageGridAmp(:,ctime)));
    else
        set(Cortex,'FaceVertexCData',Results.ImageGridAmp(:,ctime));
    end
    
    figure(TessWin)
    hTessWin = guihandles(TessSelect);
    if get(hTessWin.Normalize,'Value')
        TessWin = findobj(0,'Tag','tessellation_window');
        axx = findobj(TessWin,'tag','MainAxes');
        set(axx,'ClimMode','auto')  
        M = max(abs(Results.ImageGridAmp(:,ctime)));
        set(hSelect.Normalize,'Userdata',M)
        
        SlidesWin = findobj(0,'Tag','subplot_tess_window');
        if ~isempty(SlidesWin)
            TessWin = SlidesWin; % Subplot or movie window
            axx = findobj(TessWin,'type','axes');
            set(axx,'ClimMode','auto')    
        end
        
    else
        if get(hTessWin.FreezeColormap,'Value')
            data = get(Cortex,'FaceVertexCData');
            FreezeTime = get(hTessWin.FreezeColormap,'Userdata');
            M = max(abs(Results.ImageGridAmp(:,FreezeTime)));
        else
            M = max(abs(Results.ImageGridAmp(:)));
        end
        
        if get(hSelect.AbsoluteCurrent,'Value')
            set(findobj(TessWin,'type','axes'),'ClimMode','manual','Clim',[0 M])
        else
            set(findobj(TessWin,'type','axes'),'ClimMode','manual','Clim',[-M M]) 
        end
    end
       
    if isempty(get(hSelect.ColorMAP,'Userdata'))
        %if ~isfield(cortex,'CDepth') & ~get(hSelect.MapCurvature,'Value')% No curvature mapping
        if ~get(hSelect.MapCurvature,'Value')% No curvature mapping
            if ~get(hSelect.AbsoluteCurrent,'Value')
                C = [flipud(fliplr(grayish(hot(128),.3)));grayish(hot(128),.3)];
            else
                %C = [(grayish(hot(128),.3))];
                load bst_cactivCmap
                C = map;
            end
        else
            [FVC,C]=catci(get(Cortex,'FaceVertexCData'),cortex.CDepth,M);
            set(Cortex,'FaceVertexCData',FVC);
        end
        
    else % Truncated Colormap
        if ~isfield(cortex,'CDepth') % No curvature mapping
            C = get(hSelect.ColorMAP,'Userdata'); % Truncated Colormap
            if get(hSelect.ZScoreThresholdApply,'Value') & get(hSelect.ZScore,'Value') 
                cThres = str2num(get(hSelect.ZScoreThreshold,'String'));
            else
                cThres = str2num(get(hTessWin.TruncateFactor,'String'));
            end
            FVC = get(Cortex,'FaceVertexCData');
            if get(hSelect.OrthoViews,'Value') == 0
                set(Cortex,'FaceVertexCData',FVC);
                Cortex = findobj(TessWin,'Type','patch','Tag',ActiveTess,'Visible','on'); %CHEAT - need to be improved ?    
                FVC(FVC<cThres) =0;
                set(Cortex,'FaceVertexCData',FVC);
            else
                Cortex = findobj(TessWin,'Type','patch','Tag',ActiveTess,'Visible','on'); %CHEAT - need to be improved ?    
                FVC(FVC<cThres) =0;
                set(Cortex,'FaceVertexCData',FVC);
            end
            
        else
            if get(hSelect.ZScoreThresholdApply,'Value') & get(hSelect.ZScore,'Value') 
                cThres = 100*get(hSelect.ZScoreThreshold,'Userdata');
            else
                cThres = str2num(get(hTessWin.TruncateFactor,'String'));
            end

            [FVC,C]=catci(get(Cortex,'FaceVertexCData'),cortex.CDepth,M,cThres);
            if get(hSelect.OrthoViews,'Value') == 0
                set(Cortex,'FaceVertexCData',FVC);
            else
                Cortex = findobj(TessWin,'Type','patch','Tag',ActiveTess,'Visible','on'); %CHEAT - need to be improved ?    
                set(Cortex,'FaceVertexCData',FVC);
            end
            
        end
    end
    
    colormap(C)
    
    %--------------------------------------------------------------------------------------------------------------------
case 'ToggleButtonColor'
    
    Green = [.66 1 .43];
    Dark = [.4 .4 .4];
    if nargin == 1
        handle = get(gcbf,'CurrentObject');
    else
        handle = varargin{1};
    end
    
    if get(handle,'Value')
        set(handle,'Backgroundcolor',Green,'Foregroundcolor',Dark)
    else
        set(handle,'Backgroundcolor',Dark,'Foregroundcolor','w')
    end

    %--------------------------------------------------------------------------------------------------------------------
case 'OrthoViews' % Toggle between visualization of selected envelopes along 4 orthogonal views and single-view mode 
    
    TessSelect = findobj(0,'Tag','tesselation_select');
    hSelect = guihandles(TessSelect);
    TAG = get(hSelect.OrthoViews,'Value');
    
    TessWin = findobj(0,'Tag','tessellation_window');
    if isempty(TessWin), set(gcbo,'Value',0), return, end
    
    ha = findobj(TessWin,'Tag','MainAxes');
    hp = findobj(get(ha,'Children'),'Type','patch');
    haa(1) =  findobj(TessWin,'Tag','axsub1');
    haa(2) =  findobj(TessWin,'Tag','axsub2');
    haa(3) =  findobj(TessWin,'Tag','axsub3');
    haa(4) =  findobj(TessWin,'Tag','axsub4');
    
    haa_child = get(haa,'Children');
    if ~isempty(haa_child{1})
        hps{1} = findobj([haa_child{:}],'Type','patch');
    else
        hps{1} = [];
    end
        
    if isempty(TAG)|TAG == 1
        if isempty(hps{1})
            for k = 1:4
                hps{k} =  copyobj([hp(:)]',[haa(k)]);
            end
            axes(haa(1)), view(-180, 90), axis vis3d, axis equal, axis off, 
            copyobj(findobj(ha,'Type','light'),haa(1))
            axes(haa(2)), view(-180, 0), axis vis3d, axis equal, axis off, 
            copyobj(findobj(ha,'Type','light'),haa(2))
            axes(haa(3)), view(-90, 0), axis vis3d, axis equal, axis off, 
            copyobj(findobj(ha,'Type','light'),haa(3))
            axes(haa(4)), view(0, 0), axis vis3d, axis equal, axis off, 
            copyobj(findobj(ha,'Type','light'),haa(4))
                     
            set(haa, 'Clim',get(ha,'Clim'))
            
        else
            set([hps{:}],'visible','on')
        end
        set(hp,'visible','off')
    else
        set([hps{:}],'visible','off')
        set(hp,'visible','on')
        set(TessWin,'CurrentAxes',get(hp(1),'Parent'))
    end
    dataplot_cb mapping_slider % Refersh time sample
    %--------------------------------------------------------------------------------------------------------------------
case 'FreezeColormap' %...so that Colormap is adjusted to     

    TessWin = findobj(0,'Tag','tessellation_window');
    TessSelect = findobj(0,'Tag','tesselation_select');
    hSelect = guihandles(TessSelect);
    figure(TessWin);

    dataplot_cb('ToggleButtonColor',gcbo)

    % Check if loaded Results match this surface (ie number of sources = number of vertices of selected cortical surface)
    Results = get(hSelect.ResultFiles,'Userdata');
    if isempty(Results), return, end
    MAPPING = findobj(0,'Tag','mapping');
    hMAPPING = guihandles(MAPPING);
    srate = abs(Results.ImageGridTime(2)-Results.ImageGridTime(1));
  
    ctime = round((get(hMAPPING.slider_time,'Value')/1000- Results.ImageGridTime(1))/srate)+1;
    
    set(hSelect.FreezeColormap,'Userdata',ctime)
    if get(hSelect.FreezeColormap,'Value')
        set(hSelect.FreezeTime,'String',sprintf('Time: %4.1f ms',1000*Results.ImageGridTime(ctime)))
    else
        set(hSelect.FreezeTime,'String','')
    end
    
    if get(hSelect.FreezeColormap,'Value')
        set(hSelect.Normalize,'Value',0); 
        set(TessSelect,'currentobject',hSelect.Normalize)        
        dataplot_cb NormalizeColormap
    else
        dataplot_cb mapping_slider
    end
         
    %dataplot_cb mapping_slider
    %--------------------------------------------------------------------------------------------------------------------
    
case 'NormalizeColormap' % ...so that Colormapping is automatic (data maxima reach the maximum of the colormap)
    
    TessWin = findobj(0,'Tag','tessellation_window');
    TessSelect = findobj(0,'Tag','tesselation_select');
    hSelect = guihandles(TessSelect);
    figure(TessWin);
    
    dataplot_cb('ToggleButtonColor',gcbo)
    
    if get(hSelect.Normalize,'Value')
        set(hSelect.FreezeColormap,'Value',0); 
        set(TessSelect,'currentobject',hSelect.FreezeColormap)        
        dataplot_cb FreezeColormap
        
    end
    dataplot_cb mapping_slider

    %--------------------------------------------------------------------------------------------------------------------
    
case 'ScaleColormap' % let the user adjust the color scaling for greater saturation
    
    hTessSelect = guihandles(gcbf);
 
    %ScaleFactor = inputdlg('Enter Caxis Scaling Factor','BrainStorm Movie Maker',[1 50],{'1'});
    %if isempty(ScaleFactor), return, end
    
    if get(hTessSelect.ZScoreThresholdApply,'Value') & get(hTessSelect.ZScore,'Value') 
        ZScoreFlag = 1;
        ScaleFactor = 100*get(hTessSelect.ZScoreThreshold,'Userdata');
    else
        ScaleFactor = str2num(get(hTessSelect.TruncateFactor,'String'));
        ZScoreFlag = 0;
    end
    
    
    TessWin = findobj(0,'Tag','tessellation_window');
    if isempty(TessWin), return, end
    figure(TessWin)
    ColorMap = get(TessWin,'Colormap');
    
    ColorMapOld = get(hTessSelect.ScaleColormap,'Userdata');
    if isempty(ColorMapOld), 
        ColorMapOld = ColorMap; 
        set(hTessSelect.ScaleColormap,'Userdata',ColorMapOld);
     end    
    ColorMap = ColorMapOld;
    

    if ScaleFactor > 0
        ColorMap(1:round(ScaleFactor*end/100),:) = ...
            repmat(min([.3,sum(ColorMap(round(ScaleFactor*end/100),:))])*[1 1 1],length(1:round(ScaleFactor*size(ColorMapOld,1)/100)),1);
    else
        ColorMap = ColorMapOld;
    end
    
    set(TessWin,'Colormap',ColorMap);
    set(hTessSelect.ColorMAP,'Userdata',ColorMap)
    
    dataplot_cb CorticalMap
    %--------------------------------------------------------------------------------------------------------------------
    
    
case 'Colorbar' % Add colorbar to the Surface Viewer window
    handles = guihandles(gcbf);
    ViewColorbar = get(handles.Colorbar,'Value'); % Add or remove colorbar
    TessWin = findobj(0,'Tag','tessellation_window');

    if isempty(TessWin), return, end
    if isempty(get(handles.Colorbar,'Userdata')) | (ViewColorbar == 1)
        figure(TessWin);
        Colorbar = colorbar('horiz');
        set(handles.Colorbar,'Userdata',Colorbar);
        set(Colorbar,'Xcolor',textcolor,'Ycolor',textcolor)
    elseif ~isempty(get(handles.Colorbar,'Userdata'))
        delete(get(handles.Colorbar,'Userdata'));
        set(handles.Colorbar,'Userdata',[])
    end
    figure(TessWin)
    rotate3d on
    hTessSelect = guihandles(findobj(0,'Tag','tesselation_select'));
    if get(hTessSelect.Normalize,'Value') & ViewColorbar == 1% Normalized colorbar
        M=get(hTessSelect.Normalize,'Userdata');
        set(get(handles.Colorbar,'Userdata'),'XTickLabel',num2str(linspace(0,M,6)',1))
    end
    %--------------------------------------------------------------------------------------------------------------------
case 'Colorbar_mapping' % Add colorbar to the Surface Viewer window
    handles = guihandles(gcbf);
    ViewColorbar = get(handles.Colorbar,'Value'); % Add or remove colorbar
    for k = 1:length(current)
        TessWin = findobj(0,'Tag',['map_single',int2str(current(k))]);
        
        if isempty(TessWin), return, end
        if (ViewColorbar == 1)
            figure(TessWin);
            axes(get(TessWin,'CurrentAxes'));
            Colorbar{k} = colorbar('horiz');
            set(handles.Colorbar,'Userdata',Colorbar);
            set(Colorbar{k},'Xcolor',textcolor,'Ycolor',textcolor)
        elseif ~isempty(get(handles.Colorbar,'Userdata'))
            Colorbar = get(handles.Colorbar,'Userdata');
            if isempty(Colorbar)
                return
            end
            delete([Colorbar{:}]);
            set(handles.Colorbar,'Userdata',[])
        end
    end
    
    %--------------------------------------------------------------------------------------------------------------------
case 'QuitTessSelect' % Bye
    delete(findobj(0,'tag','tesselation_select')); 
    delete(findobj(0,'tag','tessellation_window')); 

    
end  % Switch action 

