function [r]=labelbrainstorm(varargin)
% labelbrainstorm - display (and compute) labels on a brainstorm cortical surface
%
% [] = labelviewer([inputs])
% 
% Inputs should be given according to the following way:
% 'Option', OptionValue
% - BrainstormSubject='FileName': optional Brainstorm Subject file
% - BrainstormTess='FileName': a brainstorm tess file
% - PialSurface: vertices used for the Talairach Bounding Box 
%   (usually the Rhemi and Lhemi surfaces)
% 
% - Atlas='FileName': an atlas file, e.g. TTareas.mat or TTgyri.mat (or any one you can design)
% Ouputs:
% - [none] : GUI version
% - or: [r, labels, xyz, ref]:
%        r: label for each vertex
%
% Examples of use:
%    > labelbrainstorm
%    > [r]=labelbrainstorm('BrainstormSubject','d:/subjects/darwin/darw_brainstormsubject.mat')
%
% Version 1.0 - K. N'Diaye

% What we need
% 1. The vertices of interest
% 2. The pial surface (R+L hemispheres)
% 3. AC, PC, IH in the same referential
% 4. The atlas

options=struct(varargin{:});
% if not(isfield(options, 'BrainstormTess')) & not(isfield(options, 'BrainstormSubjectImage'))
%     uigetfile
% end
if isfield(options, 'BrainstormSubject')
    bsj=load(options.BrainstormSubject);
    if not(isempty(bsj.Tesselation))
        options.Tesselation=bsj.Tesselation;
    end      
end 

if isfield(options, 'PialSurface')
    options.MRI2CTF=[diag([1 1 1]) zeros(3,1)];
end
data_path=[];

if isfield(options, 'BrainstormTess')
    tess=load(options.BrainstormTess);
    if length(tess.Vertices)>1
        [s,v] = listdlg('PromptString','Choose a cortical surface:',...
            'SelectionMode','single',...
            'ListString',tess.Comment);
        if not(v),return,end
        options.Tesselation.vertices=tess.Vertices{s}';
        options.Tesselation.faces=tess.Faces{s};
    else
        options.Tesselation.vertices=tess.Vertices{1}';
        options.Tesselation.faces=tess.Faces{1};
    end   
    clear tess
end


if not(isfield(options, 'Tesselation')) & not(isfield(options, 'BrainstormTess'))
    import_tess=1;
    tessfiles={};
    while import_tess
        [f,p,fidx]=uigetfile({'*tess.mat', '(*tess.mat) Brainstorm Tess File'; '*.mat' 'Matlab file'; '*.mesh' 'AIMS mesh file'} , 'pick a tesselation/mesh file', data_path);
        if isempty(f) | f==0, return, end    
        data_path=p;
        tessfiles=[tessfiles {fullfile(p,f)}];        
        if fidx<=2              
            options.BrainstormTess=tessfiles{end};
            import_tess=0;
        else
            if not(isfield(options, 'Tesselation'))     
                options.Tesselation.faces=[];
                options.Tesselation.vertices=[];
            end
            [fv.vertices,fv.faces]=readmesh(tessfiles{end});            
            fv.faces=fv.faces+1+size(options.Tesselation.vertices,1);
            options.Tesselation.faces=[options.Tesselation.faces ; fv.faces];
            options.Tesselation.vertices=[options.Tesselation.vertices ; fv.vertices];
            button = questdlg(['Add another file?' sprintf('%s\n', tessfiles{:})],'Importing tesselations','Yes','No','Cancel','Yes');
            if strmatch('No', button)
                import_tess=0;
            elseif strmatch('Cancel', button)
                return;
            end
        end        
    end
end

if not(isfield(options, 'Tesselation'))
    error(sprintf('%s: No tesselation!', mfilename));
    return
end

if not(isfield(options, 'PialSurface'))
    [f,p,fidx]=uigetfile({'*tess.mat', '(*tess.mat) Brainstorm Tess File'; '*.mat' 'Matlab file'; '*.mesh' 'AIMS mesh file'} , 'pick a tesselation/mesh file for external cortical surface',data_path);   
    if isempty(f) | f==0, return, end    
    data_path=p;
    if fidx<=2     
        tess=load(options.BrainstormTess);
        if length(tess.Vertices)>1
            [s,v] = listdlg('PromptString','Choose a cortical surface:',...
                'SelectionMode','single',...
                'ListString',tess.Comment);
            if not(v),return,end
            options.PialSurface=tess.Vertices{s}';            
        else
            options.PialSurface=tess.Vertices{1}';
        end   
        clear tess        
    else
        [options.PialSurface]=readmesh(fullfile(p,f));
    end  
end

if not(isfield(options, 'APC'))
    if not(isfield(options, 'VoxelSize'))
        prompt={'Voxel size (in mm) : '};
        dlgTitle=['MR Slices'];
        lineNo=[1];
        DefAns={'0.9375 0.9375 1.3'};
        options.VoxelSize=inputdlg(prompt,dlgTitle,lineNo, DefAns);
        options.VoxelSize=str2num(char(options.VoxelSize{1}));
        if isempty(options.VoxelSize)
            return
        end
    end
    [f,p]=uigetfile({'*.APC', 'Brainvisa APC file'} ,'Pick an APC file',data_path);
    if f==0, return, end
    data_path=p;
    options.APCfile=fullfile(p,f);
end

if not(isfield(options, 'APC'))
    options.APCmm=readAPCmm(options.APCfile, options.VoxelSize);    
end

if not(isfield(options, 'APC'))    
    if not(isfield(options, 'MRItoCTF'))
        button = questdlg('MRI to CTF registration file?','MRI to CTF registration','MegDraw','Compute it!','Cancel','MegDraw');
        if strmatch('MegDraw', button)
            [f,p]=uigetfile({'*.txt', 'megDraw MRI to CTF'} ,'Pick a megDraw MRI to CTF file',data_path);
            if f==0,return,end
            data_path=p;
            [ignore, options.MRItoCTF] =readMRItoCTF(fullfile(p,f));
        elseif strmatch('Compute it!', button, 'exact')
            [f1,p1]=uigetfile({'*.mesh', 'original mesh file'} ,'Pick a mesh file',data_path);
            if f1==0,return,end
            data_path=p;
            [f2,p2]=uigetfile({'*CTF.mesh', 'CTF registered mesh file'} ,'Pick a CTF mesh file',data_path);
            if f2==0,return,end
            data_path=p;    
            v1=readmesh(fullfile(p1,f1));
            v2=readmesh(fullfile(p2,f2));
            options.MRItoCTF=[v1 repmat(1,size(v1,1),1)]\v2;
        else            
            return
        end
        
        
        
        
    end
end
if isfield(options, 'APCmm')
    options.APC=[options.APCmm ones(3,1)]*options.MRItoCTF;
end
%    options.PialSurface=[options.PialSurface ones(size(options.PialSurface,1),1)]*options.MRItoCTF;
end




fv.vertices = ctf2tal(options.Tesselation.vertices, [], 'ACPCIH_ctf', options.APC, 'brainvert', options.PialSurface);
fv.vertices = fv.vertices * 1000;
fv.faces=options.Tesselation.faces;
load TTdemo
%error('pb w/ CTF MRI ???')
fv=reducepatch(fv,500);
r=labelize(fv.vertices, xyz, ref,'TimeBar', 'on');

labelviewer(fv, r, xyz, ref, labels)


return

function [vertices, faces]=imoprt_tess(curr_datadir)
