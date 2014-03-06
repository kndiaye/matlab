function []=bst_lighting(varargin)
% bst_lighting - nice viewing parameters for 3D surfaces

Referential='CTF'; % not: 'AIMS' nor 'SPM'

% Process inputs (or no input!) & link to handles
[hp,ha,hf]=findTessellationHandles(varargin{:});

if not(isempty(hp))
    verts=get(hp,'Vertices');
    % [k,k]=sort(max(verts)-min(verts));
    % if isequal(k,[3 2 1])

    % If the frontal pole is lower (in Z) than the vertex
    if mean(verts(:,3)) > median(verts(:,3))
        Referential='MNI';
    elseif verts(imax(verts(:,1)),3) < max(verts(:,3))
        Referential='CTF';
    else
        Referential='AIMS';
    end
end

% Lighting
hl=findobj(ha, 'type', 'light');
delete(hl)
clear hl;
switch Referential
    case 'CTF'
        %         hl(1) = light('Position', [1 1 1 ]);
        %         hl(2) = light('Position', [1 -1 1 ]);
        %         hl(3) = light('Position', [-1 0 0 ]);
        %         hl(4) = light('Position', [0 1 -.2 ]);
        %         hl(5) = light('Position', [0 -1 -.2 ]);
        hl(1) = camlight(30,30 );
        hl(2) = camlight(120,30);
        hl(3) = camlight(90,-60);
        hl(3) = camlight(0, 90);
        hl(4) = camlight(-65, -20, 'infinite'); % light('Position', [0 -.2  1]);
        hl(5) = camlight(-115, -20, 'infinite'); % light('Position', [0 -.2 -1]);
            set(hl,'color',[.8 1 1]/3/.7); % mute the intensity of the lights

    case 'AIMS'
        hl(1) = light('Position', [1 1 -1 ]);
        hl(2) = light('Position', [1 -1 -1 ]);
        hl(3) = light('Position', [-1 0 0 ]);
        hl(4) = light('Position', [0 1 .2 ]);
        hl(5) = light('Position', [0 -1 .2 ]);
        set(ha, 'Zdir', 'reverse')
        %         hl(1) = camlight(-20,30);
        %         hl(2) = camlight(20,30);
        %         hl(3) = camlight(-20,-30);
        %         hl(4) = light('Position', [0 -.2  1]);
        %         hl(5) = light('Position', [0 -.2 -1]);
        set(hl,'color',[.8 1 1]/3/.7); % mute the intensity of the lights

    case 'MNI'
        hl(1) = light('Position', [ 1  1 1 ]);
        hl(2) = light('Position', [-1  1 1 ]);
        hl(3) = light('Position', [ 0 -1 0 ]);
        hl(4) = light('Position', [ 1  0 -.2 ]);
        hl(5) = light('Position', [-1  0 -.2 ]);
        %         hl(1) = camlight(-20,30);
        %         hl(2) = camlight(20,30);
        %         hl(3) = camlight(-20,-30);
        %         hl(4) = light('Position', [0 -.2  1]);
        %         hl(5) = light('Position', [0 -.2 -1]);
            set(hl,'color',[.8 1 1]/3/.7); % mute the intensity of the lights

end

% Viewing parameters
% if isequal(Referential, 'CTF') & mean(verts(:,3)) < 0
%     set(ha, 'Zdir', 'reverse')
% end
% view(2)
% view([0 180 0])
% view(140,20);
axis off
axis image
% rotate3daxes(ha,'on')
