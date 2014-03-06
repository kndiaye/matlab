function view_topography_cb(action);
% VIEW_TOPOGRAPHY_CB Callback for viewing topographies as min norm solutions
% function view_topography_cb(action);
% Call with no arguments to build gui.
% Calls view_minnorm_gui to actually create the first minimum norm solution
% Sequence is to call rap music first, then this routine applied to the results file

% John C. Mosher, Ph.D., See Copyright.m file for information.
% $Date: 1/24/01 5:50p $ $Revision: 1 $

if(~exist('action','var')),
  action = 'build';
end

hf = gcbf; % who called me

switch deblank(lower(action))
case 'build'
  open('view_topography_cb.fig');
  
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
    'Callback','view_topography_cb(''reset'')');  
  
  % So the studies menu has a list of StudySubjects to write to UserData
  % now append to each study menu callback a datasets menu action
  
  hub1 = get(hub,'children'); % what are all of the studies
  % These line unnecessary now that JCM dropped the refresh
  % hub1r = findobj(hub1,'Label','Refresh Studies');
  % hub1(find(hub1==hub1r)) = []; % don't update the refresher child
  
  for i = 1:length(hub1), % each submenu of the study menu
    cb = get(hub1(i),'Callback');
    % datamenu will make a menu of data sets for min norm
    set(hub1(i),'Callback',[cb 'viewtopographydatamenu;']);
  end
  
  % so the menus are rebuilt.  Now for the other objects. Activate all of them
  % Study has the original data, Series has the time series, View has the patch rendering
  
  TAGS = {'AxisStudy', 'AxisSeries', 'AxisView'};
  
  for i = 1:length(TAGS),
    axes(findobj(hf,'Tag',TAGS{i}));
    cla reset
    set(gca,'Tag',TAGS{i},'Units','Normalized'); % set tag back in
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
  
  SourceResults = load_brainstorm_file(UD.DataName);
  
  % we expect this file to be the results file of Rap music (or least squares).
  %  so the DataName should have the name "results" in it.
  if(~isempty(findstr('_results',deblank(lower(UD.DataName))))), 
    % name has the string '_results' in it, see if it is has indep topographies
    if(isempty(SourceResults.IndepTopo)),
      msgbox('Data has no IndepTopo to view','Wrong Data Set','modal');
      return
    end    
    % Get the original Data structure
    Data = load_brainstorm_file(SourceResults.GUI.DataName);
  else
    % assume it is a data file
    msgbox('DataName does not have the name ''results''','Wrong Data Set','modal')
    return
  end
  
  Channel = load_brainstorm_file(SourceResults.StudySubject.Channel);
  Channel = Channel.Channel; 
  GoodChannel = good_channel(Channel,Data.ChannelFlag,'MEG');
  
  %% CHEAT, show data and residual in a separate window for now
  figure(windfind(sprintf('Synthesized Data and Residuals: %s',UD.DataName)))
  windclf
  plot([Data.F(GoodChannel,SourceResults.Time) ...
      SourceResults.Fsynth Data.F(GoodChannel,SourceResults.Time)-SourceResults.Fsynth]');
  title(sprintf('%s: Data, Synth, Resid',UD.DataName),'interpreter','none')
  drawnow  
  
  ha = findobj(hf,'Tag','AxisStudy');
  axes(ha)
  cla
  line(Data.Time(SourceResults.Time),Data.F(GoodChannel,SourceResults.Time)')
  title(Data.Comment)
  axis tight
  grid on
    
  ha = findobj(hf,'Tag','AxisSeries');
  axes(ha)
  cla
  line(Data.Time(SourceResults.Time),SourceResults.TimeSeries)
  axis tight
  grid on
  
  drawnow
  
  hud = findobj(hf,'Tag','UimenuDataSets');
  set(hud,'UserData',SourceResults); % set results into ram of UimenuDataSets
  
  view_topography_cb('make topographies')
  
  rotate3d on
  
case 'make topographies'
  
  hud = findobj(hf,'Tag','UimenuDataSets');
  SourceResults = get(hud,'UserData');
  ha = findobj(hf,'Tag','AxisView');
  axes(ha)
  cla
  User = get_user_directory; % default directory
  % want to understand how many vertices there are, partial load
  HeadModel = load(fullfile(User.STUDIES,SourceResults.StudySubject.HeadModel),'ImageGridLoc');
  
  % just how many grid points are there?
  % CHEAT, always looks at grid 1
  if ~isfield(HeadModel,'ImageGridLoc')
     errordlg('Please Compute the Gain Matrix (ie an Image Grid) over the Cortical Surface First ')
     return
  end
  
  GUI.iGrid = [HeadModel.ImageGridLoc{:}];
  % CHEAT: expects only one ImageGridLOc
  GUI.iGrid = GUI.iGrid(1); 

  User = get_user_directory;
  load(fullfile(User.SUBJECTS,SourceResults.StudySubject.SubjectTess),'Vertices');
  Vertices = Vertices{HeadModel.ImageGridLoc{GUI.iGrid}};
  NumVerts = size(Vertices,2); % number of grid points Cheat ImageGridLoc
  
  % CHEAT, hidden string to trigger a simulated patch
  DataStored = whos('-file',SourceResults.GUI.DataName);
  if(~isempty(strmatch('pndx',{DataStored.name}))), 
    % Yes! We stored a pndx matrix in the original data file.
    %  synthesize the ImageGridAmp from this information
    Answer = questdlg('Min Norm or Use the Patch','Patch Index Detected',...
      'Min Norm','Patch','Patch');
    switch Answer
    case 'Patch'      
      % which patch, the true or the estimated
      if(~isempty(strmatch('pndxs',{DataStored.name}))), 
        TrueOrFound = questdlg('True or Estimated Patch','Patch Solution Detected',...
          'True','Estimated','True');
        switch TrueOrFound
        case 'True'
          temp = load_brainstorm_file(SourceResults.GUI.DataName,'pndx');
          pndx = temp.pndx; % the patch indices
        case 'Estimated'
          temp = load_brainstorm_file(SourceResults.GUI.DataName,'pndxs');
          pndx = temp.pndxs; % the patch indices
          %CHEAT: For IPMI, the first dipolar source can't be seen. Replace it with the
          % the bigger true patch
          msgbox('Overwriting the first estimated source with the true patch',...
            'IPMI Viewchart Cheat for Presentation','modal');
          temp = load_brainstorm_file(SourceResults.GUI.DataName,'pndx');
          pndx{1} = temp.pndx{1};
        end
      else
        % Estimated patch not detected
        temp = load_brainstorm_file(SourceResults.GUI.DataName,'pndx');
        pndx = temp.pndx; % the patch indices
      end
      % clear the min norm answer
      SourceResults.ImageGridAmp = zeros(NumVerts,length(pndx));
      for i = 1:length(pndx),
        SourceResults.ImageGridAmp(pndx{i},i) = 1; % unity patch
      end  
      [ignore,SourceResults.ImageGridAmp] = colnorm(SourceResults.ImageGridAmp);
      set(hud,'UserData',SourceResults); % save back in
    otherwise
      % do nothing, we calculated the min norm below
    end
  end    
  
  % if it is still empty, then we minimum norm the data
  if(isempty(SourceResults.ImageGridAmp)), % topo's have not been converted
    % Cheat, I always want Tikhonov Condition on the min norm data
    SourceResults.GUI.REG = 'Tikhonov';
    SourceResults.GUI.Tikhonov = inputdlg('Enter the Tikhonov Condition Number: ',...
      'Topography Mininum Norm',[1 50],{'1000'});
    if(isempty(SourceResults.GUI.Tikhonov)), % user bailed so will we
      return
    end
    SourceResults.GUI.Tikhonov = str2num(SourceResults.GUI.Tikhonov{1});
    
    MinResults = minnorm(SourceResults); % local call below
    [ignore,SourceResults.ImageGridAmp] = colnorm(MinResults.ImageGridAmp);
    % CHEAT notice, would love to save these results, but as of 6/17 have become
    %  worried about overwriting the original filename in taskbar.
    % Stored results would also not allow different regularization parameters.
    set(hud,'UserData',SourceResults); % save back in
  end
  
  SimulateMinNorm = questdlg('Synthesize a "mininmum norm" sequence for viewing?');
  SourceResults.SimulateMinNorm = SimulateMinNorm; % save into ram version
  switch SimulateMinNorm
  case 'Yes'
    % Lets Synthesize the ImageGridAmp information as though it were a minimum norm
    % Each column of ImageGridAmp is the new min norm solution to the topography.
    % Let's column normalize each, then multiply it by it's time series, which already
    %  anticipates a unity column norm signal
    [ignore,TempIndepTopo] = colnorm(SourceResults.ImageGridAmp); % make these the topographies
    SourceResults.ImageGridAmp = zeros(size(SourceResults.ImageGridAmp,1),size(SourceResults.TimeSeries,1));
    for i = 1:size(TempIndepTopo,2), % for each topography
      SourceResults.ImageGridAmp = SourceResults.ImageGridAmp + ...
        TempIndepTopo(:,i)*SourceResults.TimeSeries(:,i)';
    end
  end
  
  set(hud,'UserData',SourceResults); % save back in, including min norm answer
  

  cdata = SourceResults.ImageGridAmp(:,1);
  SubjectTess = load_brainstorm_file(SourceResults.StudySubject.SubjectTess);

  view_minnorm(SubjectTess.Faces{GUI.iGrid},SubjectTess.Vertices{GUI.iGrid}',cdata,grayish(bluehot(128),.33),ha); % local call below
  % creates a patch in the axisview
  
  mx_val = max(SourceResults.ImageGridAmp(:));
  mn_val = min(SourceResults.ImageGridAmp(:));
  
  if(0)
    if(mn_val < 0), % we have negative values
      % balance the colors
      caxis(max(abs([mx_val mn_val]))*[-1 1]);
    else
      caxis([0 mx_val])
    end
  else
    % always balance the colors
    caxis(max(abs([mx_val mn_val]))*[-1 1]);
  end

  rotate3d on
  axis vis3d
  
  hpatch = findobj(gca,'Type','patch'); % find the patch
  set(hpatch,'FaceLighting','flat'); % much faster rendering
  hm = findobj(gcf,'Label','Toggle Face');
  set(hm,'UserData',hpatch);
  hm = findobj(gcf,'Label','Toggle Lighting');
  set(hm,'UserData',hpatch);
    
  switch SimulateMinNorm
  case 'Yes'
    % set time marker 
    ha = findobj(hf,'Tag','AxisSeries');
    axes(ha)
    V = axis; % what's the settings
    hline = findobj(ha,'Type','line'); % get the lines
    Xdata = get(hline(1),'Xdata'); % get the time line
    UD = struct('iTime',1,'Time',Xdata);
    % iTime is the integer time index in the array of xdata. Time is the time in engineering units
    hline = line([UD.Time(UD.iTime);UD.Time(UD.iTime)],[V(3);V(4)],'Color','b','linewidth',2);
    set(ha,'UserData',setfield(UD,'hline',hline));

case 'No' % making topographies
   depth_point = SourceResults.SourceLoc{1}; %first solution
   depth_point = depth_point(:,1); % first source points
   [ignore,ignore,ignore,ignore,hlinedepth,hstringdepth] = ...
      depthgauge(depth_point,depth_point/norm(depth_point),100/1000,5/1000,1000,gca);
   hseries = findobj(gcbf,'Tag','AxisSeries'); % the time series
   tempcolor = get(hseries,'ColorOrder'); % colororder
   % set the color of the depthgauge to that of the default line colors in the axes
   set(hlinedepth,'Color',tempcolor(1,:),'MarkerFaceColor',tempcolor(1,:))
end

case 'create movie'
  hud = findobj(hf,'Tag','UimenuDataSets');
  hv = findobj(hf,'Tag','AxisView');
  hp = findobj(hv,'Type','Patch'); % get the patch
  SourceResults = get(hud,'UserData'); % the results data
  if(isempty(SourceResults)),
    msgbox('Load data first','Notice','modal');
    return
  end
  
  axes(hv);
  org_caxis = caxis; % the original axis
  
  ScaleFactor = inputdlg('Enter Caxis Scaling Factor','BrainStorm Movie Maker',[1 50],{'1'});  
  caxis(str2num(ScaleFactor{:})*org_caxis);
  
  NF = getframe(hf); % the whole figure
  mpg_limits = size(NF.cdata); %the size of the figure
  if ((mpg_limits(1) > 480) | (mpg_limits(2) > 640)),
    ButtonName = questdlg(sprintf('Resize your window to 480 x 640?'));
    switch ButtonName
    case 'Yes'
      Vposition = get(hf,'Position');
      set(hf,'Position',[Vposition(1:2) 480 360]); % don't know why this translates to 480 x 640
      NF = getframe(hf); % the whole figure again
    case 'No'
      % do nothing
    case 'Cancel'
      % user punted, so will we
      return
    end
  end
  
  [NF(1:size(SourceResults.ImageGridAmp,2))] = deal(NF); % allocate memory
  
  hobjs = get(hv,'chil'); % the children of the view axis
  for i = 1:length(hobjs),
    switch deblank(lower(get(hobjs(i),'type')))
    case {'text','line'} % get rid of the old depthgauges
      delete(hobjs(i))
    end
  end
    
  hlinedepth = []; % the depthgauge information
  hstringdepth = [];
  disp(sprintf('Making movie for %.0f topographies',size(SourceResults.ImageGridAmp,2)));
  for i = 1:size(SourceResults.ImageGridAmp,2), % for each source
    delete(hlinedepth)
    delete(hstringdepth)
    set(hp,'FaceVertexCdata',SourceResults.ImageGridAmp(:,i));
    
    switch SourceResults.SimulateMinNorm
    case 'Yes'
      % we are simulating the time series, update the time index in the time series      
      ha = findobj(hf,'Tag','AxisSeries');
      UD = get(ha,'UserData');
      % UD.Time tells us where we are in true unit
      set(UD.hline,'Xdata',[1 1]*UD.Time(i)); % move it
      axes(ha);
      xlabel(sprintf('Time: %7.1f',UD.Time(i)));
            
    case 'No'
      % we are viewing topographies, drop in a depthgauge
      depth_point = SourceResults.SourceLoc{i}; % next source points
      hlinedepth = zeros(size(depth_point,2),1); % each location
      hstringdepth = hlinedepth; % numbers, initial
      for i =1:length(hlinedepth),
         [ignore,ignore,ignore,ignore,hlinedepth(i),hstringdepth(i)] = ...
            depthgauge(depth_point(:,i),...
            depth_point(:,i)/norm(depth_point(:,i)),100/1000,5/1000,1000,gca);
      end
      hseries = findobj(gcbf,'Tag','AxisSeries'); % the time series
      tempcolor = get(hseries,'ColorOrder'); % colororder
      % set the color of the depthgauge to that of the default line colors in the axes
      mod_i = mod(i-1,size(tempcolor,1))+1; % modulo the length
      set(hlinedepth,'Color',tempcolor(mod_i,:),'MarkerFaceColor',tempcolor(mod_i,:))
    end
    
    drawnow
    NF(i) = getframe(hf); % get the entire frame
  end
  
  axes(hv);
  caxis(org_caxis); % reset the scale axes

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
  % overwrite the extension with the desired form
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
  
end

return

%-----------------------------------------------------%

function  view_minnorm(faces,vertices,cdata,cmap,ha);
% VIEW_MINNORM view neural activity on the cortex with emphasis on speed for min norm solutions
% function [hf,hs,hl,tconn] = view_minnorm(faces,vertices,cdata,tconn,cmap,fname);
% faces, vertices, cdata is the standard patch or trisurf information.
% tconn is the triangle connectivity, if not given then will be computed and
%  returned in the outputs.
% cmap is the colormap to apply to cdata, defaults to bluehot with a gray minimum
% fname is the window to write, defaults to current

% Ambient, Diffusion, Specular, spec exp, spec reflect (see material
MaterialBack =   [0.5 0.7 0.3 10 1]; % qualities of the background image
MaterialSource = [0.8 0.7 0.8 20 1]; % qualities for the data

% handle user inputs
if(~exist('cmap')),
  cmap= []; % activate default
end

%% keep the text on how to create the triangle connectivity
%% TriConn
if(0)
  if(isempty(tconn)), % create it for the user
    tconn=cell(size(vertices,1),1); % one empty cell per vertex
    disp(sprintf('Processing %.0f faces into triangle connectivity',nf))
    for iface = 1:size(faces,1), %for each triangle, what are the vertices    
      if(~rem(iface,25000)),
        fprintf(' %.0f',iface);
      end
      for iside = 1:size(faces,2), %each vertex of the face
        tconn{faces(iface,iside)}(end+1) = iface; % map face number to vertex cell
      end
    end
    fprintf('\n');
  end
end

% check out the vertex data

mn = min(cdata(:)); % minimum non-zero, could be negative
mx = max(cdata(:)); % maximum non-zero

cmap = grayish(hot(128),.33); % CHEAT
if (1)%isempty(cmap)), % need to generate a good colormap CHEAt
  if(mn >= 0), % all positive information 
    cmap = grayish(hot(128),.33);
  else
    % we have negative values as well
    cmap = grayish(bluehot(128),.33);
  end
end

% now lets plot
hs = zeros(2,1); % 1 is data, 2 is background

axes(ha);
cla

% form the data
hs(1) = patch('faces',faces,'vertices',vertices,...
  'facevertexcdata',cdata,'facecolor','interp','edgecolor','none',...
  'facelighting','phong');
set_material(hs(1),MaterialSource); % local function 

colormap(cmap)

if(mn < 0), %balance for negative values
  cx = caxis;
  caxis(max(abs(cx))*[-1 1]);
end

view(2)
axis image
axis off

hl(1) = camlight(-20,30);
hl(2) = camlight(20,30);
hl(3) = camlight(-20,-30);
for i = 1:length(hl),
  set(hl(i),'color',[.8 1 1]/length(hl)/1.2); % mute the intensity of the lights
end

return

function set_material(isurf,data);
% set material, set only for specified handle
ka = data(1);
kd = data(2);
ks= data(3);
n= data(4);
sc= data(5);
set(isurf,'AmbientStrength', ka, 'DiffuseStrength', kd, 'SpecularStrength', ks, ...
  'SpecularExponent', n, 'SpecularColorReflectance', sc)
return

function Results = minnorm(SourceResults);
% MINNORM Mininum norm solution as called from above, dedicated to topographies only
% As kluged up from the original minnorm_gui call:
% Parameters in GUI are:
% .DataName, string of actual data file used
%   we want to minnorm the indeptopo, so let GUI.DataName = IndepTopo matrix
% .Results, optional file to write results
%   don't write anywhere
% .Segment, two element vector giving the start and stop index numbers to use in 
%  the spatiotemporal data matrix.
%   all
% .iGrid, which imaging grid to use in the subject information
%   CHEAT, always set to 1 for now
% .Rank, rank to use, e.g. 10
%   no svd of topographies
% .ChannelFlag, an index of channels in the data file to process
%   the full indeptopo, since it's already good
% 
% The following three structure fields are optional for regularization purposes.
%  They may be null or missing to represent unused. If multiple fields are given, 
%  then precedence is given in the order given below.
%  .Condition, condition number to use in truncation, e.g. 100
%  .Energy, fractional energy to use in truncation, e.g. .95
%  .Column_norm, string of 'y' or 'n' to use in regularization
% Whatever was originally used in the call
%  
%  If all are null, no regularization is performed in the RAP-MUSIC loops.
% If GUI.Results is non-null,then writes results to that file.


BLOCK = 10000; % process by blocks


User = get_user_directory;
% load up the information needed for the gain matrix, partial load
HeadModel = load(fullfile(User.STUDIES,SourceResults.StudySubject.HeadModel),'Function','Param',...
  'ImageGridLoc','ImageGain','ImageGainCovar'); % expensive load

GUI.iGrid = [HeadModel.ImageGridLoc{:}];
% CHEAT: expects only one ImageGridLOc
GUI.iGrid = GUI.iGrid(1); 

if(isempty(HeadModel.ImageGain{GUI.iGrid})),
  msgbox('Your Grid Gain Matrix is empty, please run Head Modeler to build','Error','modal');
  return
end
if 0%(isempty(HeadModel.ImageGainCovar{GUI.iGrid})),
  disp(' ')
  disp('Your Grid Gain Correlation matrix is empty, consider running Head Modeler to build');
  disp(' ')
end

% ImageGains are assumed stored in the local directory to the subject head model
[path,name,ext,ver] = fileparts(fullfile(User.STUDIES,SourceResults.StudySubject.HeadModel));
cd(path)
fid = fopen(...
  fullfile(path,char(HeadModel.ImageGain{GUI.iGrid})),...
  'rb','ieee-be');
if(fid == -1),
  msgbox(sprintf('Failed to open %s',HeadModel.ImageGain{GUI.iGrid}),'Error','modal')
  error(sprintf('Failed to open %s',HeadModel.ImageGain{GUI.iGrid}));
  return
end

% synthesize data
Channel = load_brainstorm_file(SourceResults.StudySubject.Channel);
Channel = Channel.Channel; 
Data = struct('F',SourceResults.IndepTopo,...
  'ChannelFlag',SourceResults.ChannelFlag,...
  'Projector',SourceResults.Projector,'Comment',SourceResults.Comment);

% now alter the data according to the bad channels
GoodChannel = good_channel(Channel,SourceResults.ChannelFlag,'MEG'); %good channels

if(isempty(HeadModel.ImageGainCovar{GUI.iGrid})),
  hwaitbar = waitbar(0,'Creating Gain matrix Covariance');
  
  % just how many grid points are there?
  User = get_user_directory;
  load(fullfile(User.SUBJECTS,SourceResults.StudySubject.SubjectTess),'Vertices');
  Vertices = Vertices{HeadModel.ImageGridLoc{GUI.iGrid}};
  nv = size(Vertices,2); % number of grid points
  
  disp(sprintf('Processing for %.0f grid points . . .',nv));
  
  frewind(fid);
  rows = fread(fid,1,'uint32');
  
  AAt = zeros(rows);
  
  for i = 1:BLOCK:nv,
    
    waitbar(i/nv,hwaitbar);
    
    ndx = [0:(BLOCK-1)]+i;
    if(ndx(end) > nv),  % last block too long
      ndx = [ndx(1):nv];
    end
    
    cols = length(ndx); % how many columns to retrieve this time
    
    % 8 bytes per element, find starting point
    offset = 4 + (ndx(1)-1)*rows*4;
    status = fseek(fid,offset,'bof');
    if(status == -1),
      error(sprintf('Error reading file at column %.0f',i));
    end
    
    temp = fread(fid,[rows,cols],'float32');
    
    AAt = AAt + temp*temp';  % next chunk of correlations
    
  end
  
  close(hwaitbar);
  
  disp('Saving the gain covar back into your head model');
  % CHEAT, only works on first imaging matrix
  ImageGainCovar{1} = AAt;
  save(SourceResults.StudySubject.HeadModel,'ImageGainCovar','-append');
  
  
else
  
  % already exists, load it
  AAt = HeadModel.ImageGainCovar{GUI.iGrid}{1};
  
end  % creating gain covariance matrix

% knock out the rows and columns of the correlation matrix

AAt = AAt(GoodChannel,:);
AAt = AAt(:,GoodChannel);

% the ImageGain matrix is handled separately, due to it's size

% did the user provide an existing control. Decompose it
if(isfield(Data,'Projector')),
  if(isempty(Data.Projector)),
    A = [];
    Ua = [];
  else
    A = Data.Projector; % initialize
    Ua = orth(A);
  end
else % user did not give a projector
  A = [];
  Ua = [];
end

% use all of the "data" (all of the indeptopographies)
F = Data.F;

% handle this in the call
% [ignore,F] = colnorm(F); % column norm the topographies

% use all time (all of the topographies), time is indexer to topography
Time = [1:size(F,2)];

% Begin the minimum norm estimate

% recall the y = Ax, let x = A'c -> y = AA'c, solve for c, the 'coefs' of x.
% c = pinv(AA')*y, and we will regularize the inverse of AA' based on user selection
% Then form x = A'c.

[U,S,V] = svd(AAt);
% NOTE: we regularize the indep topographies the same way as the data

U = regsubspace(SourceResults.GUI,U,sqrt(S)); % condition based on svd of gain matrix
reg_rank = size(U,2); % reduced rank based on regularization
S = diag(S);
switch deblank(lower(SourceResults.GUI.REG))
case 'tikhonov'
  % pinv(A)*b is inv(A'*A)*A'*b. Let A = [A;lamb I]. inv(A'*A + lamb^2 I)*A'*b
  Lambda = sqrt(S(1))/SourceResults.GUI.Tikhonov; % sing values already squared
  Si = 1../(S(1:reg_rank)+Lambda^2); % filtered inverse
otherwise
  % do nothing, truncation only
  Si = 1../S(1:reg_rank);
end

% the min norm coefs
coefs = V(:,1:reg_rank)*...
  ((spdiags(Si,0,reg_rank,reg_rank)*U(:,1:reg_rank)') * F);

% let rAAt = regularized(AAt), as found by the above
%  So F = AAt *c, c = inv(rAAt), so Fsynth = AAt*c, let's calculate and stick into results
Fsynth = AAt * coefs;
% Store conveniently in the Results, Fsynth here is the regularized topography

% now calculate the final solution


% just how many grid points are there?
User = get_user_directory;
load(fullfile(User.SUBJECTS,SourceResults.StudySubject.SubjectTess),'Vertices');
Vertices = Vertices{HeadModel.ImageGridLoc{GUI.iGrid}};
nv = size(Vertices,2); % number of grid points
  
ImageGridAmp = zeros(nv,size(F,2)); % one column per topography

hwaitbar = waitbar(0,sprintf('Processing %.0f point final inverse transform',nv));

disp(sprintf('Processing for %.0f grid points . . .',nv));

frewind(fid);
rows = fread(fid,1,'uint32');

for i = 1:BLOCK:nv,
  
  waitbar(i/nv,hwaitbar);
  
  ndx = [0:(BLOCK-1)]+i;
  if(ndx(end) > nv),  % last block too long
    ndx = [ndx(1):nv];
  end
    
  cols = length(ndx); % how many columns to retrieve this time
  
  % 8 bytes per element, find starting point
  offset = 4 + (ndx(1)-1)*rows*4;
  status = fseek(fid,offset,'bof');
  if(status == -1),
    error(sprintf('Error reading file at column %.0f',i));
  end
  
  temp = fread(fid,[rows,cols],'float32');
  temp = temp(GoodChannel,:);
  
  ImageGridAmp(ndx,:) = temp'*coefs;  % next chunk of solutions
  
end

close(hwaitbar);

fclose(fid);


% now map to results
if(0) % only care about a few things
  
  Comment = sprintf('MIN NORM, rank %.0f',GUI.Rank);
  Date = datestr(datenum(now),0);
  Subject = SourceResults.Subject;
  Study = Study;
  Time = [GUI.Segment(1):GUI.Segment(2)];
  ChannelFlag = GUI.ChannelFlag;
  NoiseCov = [];
  SourceCov = [];
  Projector = Data.Projector;
  SourceLoc = [];
  SourceOrder = [];
  SourceOrientation = cell(1);
  ModelGain = [];
  IndepTopo = [];
  TimeSeries = [];
  PatchNdx = [];
  PatchAmp = [];
  % ImageGridAmp = ImageGridAmp;
  ImageGridTime = Data.Time(Time);
  Function = mfilename; % name of this calling routine
  
  Results = struct('Comment',Comment,'Function',mfilename,'StudySubject',StudySubject,...
    'GUI',GUI,'Date',Data,'Subject',Subject,'Study',Study,'Time',Time,...
    'ChannelFlag',ChannelFlag,'NoiseCov',NoiseCov,'SourceCov',SourceCov,...
    'Projector',Projector,'SourceLoc',SourceLoc,'SourceOrder',SourceOrder,...
    'SourceOrientation',[],'ModelGain',ModelGain,...
    'IndepTopo',IndepTopo,'TimeSeries',TimeSeries,'PatchNdx',PatchNdx,...
    'PatchAmp',PatchAmp,'ImageGridAmp',ImageGridAmp,'ImageGridTime',ImageGridTime,'Fsynth',Fsynth);
  Results.SourceOrientation = SourceOrientation; % struct command could kron out
end

% we only care about imagegrid amp and Fsynth

Results = struct('ImageGridAmp',ImageGridAmp,'Fsynth',Fsynth);


return % to the calling routine above
