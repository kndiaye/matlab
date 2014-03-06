function [h]=carto_cortex(faces,varargin)
% carto_cortex - Plot cortical surface
%
% [h]=carto_cortex(FV)
%     carto_cortex(faces,vertices)
%     carto_cortex(FV, values)
%     carto_cortex(faces,vertices,values)
%     carto_cortex(FV,values, 'Option', OptionValue,...)
% INPUTS:
%   FV : is a struct with .faces and .vertices, see PATCH
% OUPUT:
%   h : a handle to the patch

options={};
if nargin>1
    dataname=inputname(2);
else
    dataname='';
end
data=[];
if nargin==1 && ~isstruct(faces) && isvector(faces)
        data=faces;
        dataname=inputname(1);
        global faces
        p.faces=faces;
        global vertices
        p.vertices=vertices;
elseif isstruct(faces) && ...
        ((isfield(faces, 'faces') | isfield(faces, 'Faces')) && (isfield(faces, 'vertices') | isfield(faces, 'Vertices')))
    p=faces;

    if ~isfield(p, 'vertices') && isfield(p, 'Vertices')
        if iscell(p.Vertices)
            if sum(cellfun('isempty',p.Vertices))==1
                p.vertices=p.Vertices{~cellfun('isempty',Vertices)};
            elseif nargin>2 && ~isempty(data)
                p.vertices=p.Vertices{cellfun('prodofsize',Vertices)/3==length(data)};
            end
        else
            p.vertices=p.Vertices;
        end
    end
    
    if ~isfield(p, 'faces') && isfield(p, 'Faces')
        if iscell(p.Faces)
            if sum(cellfun('isempty',p.Faces))==1
                p.faces=p.Faces{~cellfun('isempty',Faces)};
            elseif ~isempty(data)
                p.faces=p.Faces{cellfun('prodofsize',p.Vertices)/3==length(data)};
            end
        else
            p.faces=p.Faces;
        end
    end
    
    

elseif iscell(faces)
    p.vertices=faces{1};
    p.faces=faces{2};
    
else
    if nargin>2
        dataname=inputname(3);
    end
    if max(faces(:))==max(size(varargin{1}))
        p.faces=faces;
        p.vertices=varargin{1};          
    elseif max(varargin{1}(:))==max(size(faces))
        p.vertices=faces;
        p.faces=varargin{1};
        faces = [];
    elseif max(faces(:))==max(size(varargin{1}))-1
        p.faces=faces+1;
        p.vertices=varargin{1};
    end
    varargin(1)=[];
end


if(size(p.vertices,2) > 3), % assume transposed
    p.vertices = p.vertices';  % if the assumption is wrong, will crash below anyway
end

if nargin>=2 & ~isempty(varargin)
    if isnumeric(varargin{1})
        p.data=varargin{1};
        % if not(all(size(data) == [size(vertices, 1) 1]))
        %   error('Data should be the same length as vertex number')
        %   return
        % end
        varargin(1)=[];
    end
    options=varargin(1:end);
end

if ~isfield(p, 'data')
    p.data=[];
end

if isempty(get(0, 'CurrentFigure')) | isempty(get(gcf, 'CurrentAxes'))
    NewAxes=1;
else
    NewAxes=0;
end

h = patch('Faces',p.faces,'Vertices',p.vertices);

if ~isempty(p.data)
    if prod(size(p.data))==size(p.vertices, 1)
        p.data=p.data(:);
    elseif size(p.data,1)==size(p.vertices, 1) && size(p.data, 2)>3
v        error('Data are not a vector: you might want to use view_MNEresults instead!')
        return
    end

    set(h,'FaceVertexCData',p.data);
    if size(p.data,2)==1
        set(h,'FaceColor','interp');
    end
else
    set(h,'facecolor',rand(1,3));
end
NewAxes = NewAxes || isequal(get(gca, 'NextPlot'), 'replace');
set(h, 'FaceLighting','Gouraud','EdgeLighting','none','EdgeColor','none');
set(h, 'Tag', 'Cortex');

% Material of the surface
material(h, [0.3, 0.8, .10, 10, .50])
p.h=h;
set(h, 'UserData', p);

if ~isempty(options)
    set(h, options{:});
end

if NewAxes
    try
        view(140,20);
        bst_lighting(h);
        rotate3d on
    catch
        set(gcf, 'renderer', 'zbuffer')
        view(140,20);
        bst_lighting(h);
        rotate3d on
    end
    if ~isempty(dataname)
        title(dataname)
    end
    colorbar
    meeg_menu(h);
end
