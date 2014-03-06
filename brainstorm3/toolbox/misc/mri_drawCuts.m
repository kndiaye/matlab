function [hCuts, OutputOptions] = mri_drawCuts(hFig, OPTIONS)
% MRI_DRAWMRICUTS: Plot a MRI volume in a 3D visualization figure (three orthogonal cuts).
%
% USAGE:  hCuts = mri_drawCuts(hFig, OPTIONS)
% INPUT: (structure OPTIONS)
%     - sMri             : Brainstorm MRI structure
%     - iMri             : Indice of MRI structure in GlobalData.Mri array
%     - cutsCoords       : [x,y,z] location of the cuts in the volume
%                          (value that is set to NaN => cut is not displayed)
%     - MriThreshold     : Intensity threshold above which a voxel is displayed in the MRI slice.
%     - MriAlpha         : Transparency of MRI slices
%     - MriColormap      : Colormap to use to display the slices
%    (optional)
%     - OverlayCube      : 3d-volume (same size than MRI) with specific data values
%     - OverlayIntThreshold : Intensity threshold above which a voxel is overlayed in the MRI slices.
%     - OverlayExtThreshold : Extent threshold, minimal size of clusters overlayed in the MRI slices.
%     - OverlayAlpha     : Overlayed voxels transparency 
%     - OverlayColormap  : Colormap to use to display the overlayed data
%     - OverlayBounds    : [minValue, maxValue]: amplitude of the OverlayColormap
%     - isMipAnatomy     : 1=compute maximum intensity projection in the MRI volume
%     - isMipAnatomy     : 1=compute maximum intensity projection in the OVerlay volume
%
% OUTPUT:
%     - hCuts         : [3x1 double] Graphic handles to the images that were created
%     - OutputOptions : structure with some output information
%          |- MipAnatomy    : {3x1 cell}
%          |- MipFunctional : {3x1 cell}

% @=============================================================================
% This software is part of The Brainstorm Toolbox
% http://neuroimage.usc.edu/brainstorm
% 
% Copyright (c)2009 Brainstorm by the University of Southern California
% This software is distributed under the terms of the GNU General Public License
% as published by the Free Software Foundation. Further details on the GPL
% license can be found at http://www.gnu.org/copyleft/gpl.html.
% 
% FOR RESEARCH PURPOSES ONLY. THE SOFTWARE IS PROVIDED "AS IS," AND THE
% UNIVERSITY OF SOUTHERN CALIFORNIA AND ITS COLLABORATORS DO NOT MAKE ANY
% WARRANTY, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO WARRANTIES OF
% MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, NOR DO THEY ASSUME ANY
% LIABILITY OR RESPONSIBILITY FOR THE USE OF THIS SOFTWARE.
%
% For more information type "brainstorm licence" at command prompt.
% =============================================================================@
%
% Authors: Francois Tadel, 2006 (University of Geneva)
% ----------------------------- Script History ---------------------------------
% FT  24-Jun-2008  Adaptation for brainstorm3
% ------------------------------------------------------------------------------


%% ===== INITIALIZATION =====
mriSize = size(OPTIONS.sMri.Cube);
isOverlay = ~isempty(OPTIONS.OverlayCube);
% Output variable
hCuts = [-1 -1 -1];
OutputOptions.MipAnatomy    = cell(3,1);
OutputOptions.MipFunctional = cell(3,1);
% Colormap bounds
if isempty(OPTIONS.sMri.Histogram.intensityMax)
    MriColormapBounds = [];
else
    MriColormapBounds = [0 double(OPTIONS.sMri.Histogram.intensityMax)];
end
% Get the type of figure
FigureId = getappdata(hFig, 'FigureId');
% Get in which axes we are supposed to display the MRI
switch (FigureId.Type)
    case '3DViz'
        hTarget = findobj(hFig, 'tag', 'Axes3D');
    case 'MriViewer'
        % Get figure handles
        Handles = gui_figuresManager('GetFigureHandles', hFig);
        hTarget = [Handles.imgs_mri, Handles.imgc_mri, Handles.imga_mri];
end



%% ===== DISPLAY SLICES =====
for iCoord = 1:3
    % Ignore the slice if indice is NaN
    if isnan(OPTIONS.cutsCoords(iCoord))
        continue
    end
    
    % === GET MRI SLICE ===
    % If maximum intensity power required
    if OPTIONS.isMipAnatomy 
        % If the maximum is not yet computed: compute it
        if isempty(OPTIONS.MipAnatomy{iCoord})
            sliceMri = double(mri_getSlice(OPTIONS.sMri.Cube, OPTIONS.cutsCoords(iCoord), iCoord, OPTIONS.isMipAnatomy)');
            OutputOptions.MipAnatomy{iCoord} = sliceMri;
        % Else: use the previously computed maximum
        else
            sliceMri = OPTIONS.MipAnatomy{iCoord};
        end
    % Else: just extract a slice from the volume
    else
        sliceMri = double(mri_getSlice(OPTIONS.sMri.Cube, OPTIONS.cutsCoords(iCoord), iCoord, OPTIONS.isMipAnatomy)');
    end
    
    % === GET OVERLAY SLICE ===
    % Get Overlay slice
    if isOverlay
        % If maximum intensity power required
        if OPTIONS.isMipFunctional 
            % If the maximum is not yet computed: compute it
            if isempty(OPTIONS.MipFunctional{iCoord})
                sliceOverlay = double(mri_getSlice(OPTIONS.OverlayCube, OPTIONS.cutsCoords(iCoord), iCoord, OPTIONS.isMipFunctional)');
                OutputOptions.MipFunctional{iCoord} = sliceOverlay;
            % Else: use the previously computed maximum
            else
                sliceOverlay = OPTIONS.MipFunctional{iCoord};
            end
        % Else: just extract a slice from the volume
        else
            sliceOverlay = double(mri_getSlice(OPTIONS.OverlayCube, OPTIONS.cutsCoords(iCoord), iCoord, OPTIONS.isMipFunctional)');
        end
    else
        sliceOverlay = [];
    end

    % === APPLY COLORMAP ===
    % Alpha value depends on if MIP is used
    if OPTIONS.isMipFunctional && ~OPTIONS.isMipAnatomy
        alphaValue = .3;
    else
        alphaValue = 0;
    end
    % Compute alpha map
    sliceSize = size(sliceMri);
    AlphaMap = ones(sliceSize) * (1 - OPTIONS.MriAlpha);
    AlphaMap(sliceMri < OPTIONS.MriThreshold) = alphaValue;
    % Apply colormap to slice
    cmapSlice = applyColormap(sliceMri, OPTIONS.MriColormap, MriColormapBounds);

    % === Display overlay slice ===
    if isOverlay
        % Get max value for slice
        %MaxValue = max(abs(sliceOverlay(:)));
        % Apply colormap to overlay slice
        %cmapOverlaySlice = applyColormap(sliceOverlay, OverlayColormap, MaxValue * [0 1]);
        cmapOverlaySlice = applyColormap(sliceOverlay, OPTIONS.OverlayColormap, OPTIONS.OverlayBounds);
        % Build overlay mask
        overlayMask = ones(sliceSize) * (1 - OPTIONS.OverlayAlpha);
        overlayMask(abs(sliceOverlay) <= OPTIONS.OverlayIntThreshold .* OPTIONS.OverlayBounds(2)) = 0;
        %knd: to do:
        % overlayMask(abs(sliceOverlay) <= OPTIONS.OverlayExtThreshold .* OPTIONS.OverlayBounds(2)) = 0;
        
        % Draw overlay slice over MRI slice
        cmapSlice(:,:,1) = cmapSlice(:,:,1) .* (1 - overlayMask) + cmapOverlaySlice(:,:,1) .* overlayMask;
        cmapSlice(:,:,2) = cmapSlice(:,:,2) .* (1 - overlayMask) + cmapOverlaySlice(:,:,2) .* overlayMask;
        cmapSlice(:,:,3) = cmapSlice(:,:,3) .* (1 - overlayMask) + cmapOverlaySlice(:,:,3) .* overlayMask;
    end

    % Display function depends on figure type
    switch (FigureId.Type)
        case '3DViz'
            hCut = plotSlice3DViz(hTarget, cmapSlice, OPTIONS.cutsCoords(iCoord), iCoord);
            if ~isempty(hCut)
                hCuts(iCoord) = hCut;
            end
        case 'MriViewer'
            hCut = plotSliceMriViewer(hTarget(iCoord), cmapSlice);
    end
end


%% ================================================================================================
%  ===== INTERNAL FUNCTIONS =======================================================================
%  ================================================================================================
%% ===== PLOT SLICES IN 3D ======
    function hCut = plotSlice3DViz(hAxes, cmapSlice, sliceLocation, dimension)
        % Get locations of the slice
        nbPts = 50;
        baseVect = linspace(0,1,nbPts);
        switch(dimension)
            case 1
                X = ones(nbPts) .* sliceLocation .* OPTIONS.sMri.Voxsize(1); 
                Y = meshgrid(baseVect)  .* mriSize(2) .* OPTIONS.sMri.Voxsize(2);   
                Z = meshgrid(baseVect)' .* mriSize(3) .* OPTIONS.sMri.Voxsize(3); 
            case 2
                X = meshgrid(baseVect)  .* mriSize(1) .* OPTIONS.sMri.Voxsize(1); 
                Y = ones(nbPts) .* sliceLocation .* OPTIONS.sMri.Voxsize(2);     
                Z = meshgrid(baseVect)' .* mriSize(3) .* OPTIONS.sMri.Voxsize(3); 
            case 3
                X = meshgrid(baseVect)  .* mriSize(1) .* OPTIONS.sMri.Voxsize(1); 
                Y = meshgrid(baseVect)' .* mriSize(2) .* OPTIONS.sMri.Voxsize(2); 
                Z = ones(nbPts) .* sliceLocation .* OPTIONS.sMri.Voxsize(3);            
        end
        
        % === Switch coordinates from MRI-CS to SCS ===
        % Apply Rotation/Translation
        XYZ = [reshape(X, 1, []);
               reshape(Y, 1, []); 
               reshape(Z, 1, [])];
        XYZ = mri2scs(OPTIONS.sMri, XYZ);
        % Convert to milimeters
        XYZ = XYZ ./ 1000;
            
        % === PLOT SURFACE ===
        tag = sprintf('MriCut%d', dimension);
        % Delete previous cut
        delete(findobj(hFig, 'Tag', tag));
        % Plot new surface  
        hCut = surface('XData',     reshape(XYZ(1,:),nbPts,nbPts), ...
                       'YData',     reshape(XYZ(2,:),nbPts,nbPts), ...
                       'ZData',     reshape(XYZ(3,:),nbPts,nbPts), ...
                       'CData',     cmapSlice, ...
                       'FaceColor',        'texturemap', ...
                       'FaceAlpha',        'texturemap', ...
                       'AlphaData',        AlphaMap, ...
                       'AlphaDataMapping', 'none', ...
                       'EdgeColor',        'none', ...
                       'AmbientStrength',  .5, ...
                       'DiffuseStrength',  .5, ...
                       'SpecularStrength', .6, ...
                       'Tag',              tag, ...
                       'Parent',           hAxes);
    end


%% ===== PLOT SLICES IN MRIVIEWER ======
    function hCut = plotSliceMriViewer(hImg, cmapSlice)
        % Get locations of the slice
        set(hImg, 'CData', cmapSlice);
        hCut = hImg;
    end
end
