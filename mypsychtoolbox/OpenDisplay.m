function [window] = OpenDisplay(subscreen,color,screen_number,debug)
% OpenDisplay - Easy open of the display using Psychtoolbox's Screen
%   [window] = OpenDisplay(subscreen,color)
%% INPUTS
if nargin<2
    color=[0 0 0];
end
if nargin<1
    subscreen = [ 640 480 ];
end
if nargin<4
    debug = ~isempty(subscreen);
end
%% Invoke PTB OpenGL functions
AssertOpenGL;
scr.Screens = Screen('Screens');
scr.nScreens = numel(scr.Screens);
if nargin<3
    scr.screenNumber = max(scr.Screens);
else
    scr.screenNumber = screen_number;
end
%scr.Resolution = Screen('Resolution',scr.screenNumber);
kPNFOW = [];

if numel(subscreen)==2
    if isempty(scr.screenNumber)
        scr.screenNumber = 0;
    end
    if scr.nScreens==1
        %do nothing
        [wh]=Screen('Rect', scr.screenNumber);
        subscreen = RectPosition(subscreen,wh,'ctmr');
    elseif all(Screen('Rect', 0)>=0) && all(Screen('Rect', 2)>=0)
        if isempty(scr.screenNumber)
            scr.screenNumber = 1;
        end
        [wh]=Screen('Rect', scr.screenNumber);
        %         if scr.screenNumber == 2
        %             wh(:,1) = wh(:,1) - wh(:,3);
        %             wh(:,3) = 0;
        %         end
        %subscreen = RectPosition(subscreen,wh,'rrrctttm');
        subscreen = RectPosition(subscreen,wh,'c');
    else
        [wh]=Screen('Rect',2);
        subscreen = 100+[ wh(1) 0 subscreen+[wh(1) 0]  ];
    end
end

if debug
    Screen('Preference', 'SkipSyncTests', 1);
else
    % kPsychNeedFastOffscreenWindows
    kPNFOW = kPsychNeedFastOffscreenWindows;
    Screen('Preference', 'SkipSyncTests', 0);
end
Screen('Preference', 'Verbosity', 1);
Screen('Preference', 'VBLTimeStampingMode', -1);

window = struct;

if numel(subscreen)==0
    % Open whole screen display
    [window.ptr, window.rect] = Screen('OpenWindow', ...
        scr.screenNumber, color, [], [], [], [], [], ...
        kPNFOW);
    [subscreen]=Screen('Rect', scr.screenNumber);
    if scr.screenNumber == 2
        subscreen(:,1) = subscreen(:,1) - subscreen(:,3);
        subscreen(:,3) = 0;
    end

else
    %Open a smaller graphic window in the screen
    [window.ptr, window.rect] = Screen('OpenWindow', ...
        scr.screenNumber, color, subscreen, [], [], [], [], ...
        kPNFOW);
end
window.screenNumber = scr.screenNumber;

    window.screen_rect = subscreen;
if scr.nScreens > 1
    all(Screen('Rect', 2)>=0) &&  all(Screen('Rect', 0)>=0) 
    window.screen_rect([1 3]) = window.screen_rect([1 3]) + Screen('Rect',2)*[-1;0;1;0];
end

window.color=color;
[window.size(1), window.size(2)] = Screen('WindowSize', window.ptr);
% Enable alpha blending with proper blend-function. We need it
% for drawing of smoothed points:
try
    Screen('BlendFunction', window.ptr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
catch
end
Screen('Flip', window.ptr);
window.fps = Screen('FrameRate', window.ptr);
window.ifi = 1./window.fps;

try
    if ~EXPERIMENT.DEBUG
        HideCursor;
        Priority(MaxPriority(window.ptr));
        % Retrieves flip interval only for fullscreen mode
        window.ifi = Screen('GetFlipInterval', window.ptr, 100, 50e-6, 10);
        % Retrieves number of frames per second
        window.fps = Screen('FrameRate', window.ptr);
        if window.fps==0
            window.fps=1/window.ifi;
        end;

        % Color calibration
        % LoadIdentityClut(window.ptr);
        % window.clut = CreateCalibratedClut(screen);
    else
        fprintf('Debug mode required\n');
    end
catch
    fprintf('Debug mode\n');
end



return

% % Activate compatibility mode: Try to behave like the old MacOS-9 Psychtoolbox:
% oldEnableFlag=Screen('Preference', 'EmulateOldPTB', [enableFlag]);
%
% % Open or close a window or texture:
% [windowPtr,rect]=Screen('OpenWindow',windowPtrOrScreenNumber [,color] [,rect] [,pixelSize] [,numberOfBuffers] [,stereomode] [,multisample][,imagingmode]);
% [windowPtr,rect]=Screen('OpenOffscreenWindow',windowPtrOrScreenNumber [,color] [,rect] [,pixelSize]);
% textureIndex=Screen('MakeTexture', WindowIndex, imageMatrix [, optimizeForDrawAngle=0] [, enforcepot=0] [, floatprecision=0] [, textureOrientation=0]);
% Screen('Close', windowOrTextureIndex);
% Screen('CloseAll');
%
% %  Draw lines and solids like QuickDraw and DirectX (OS 9 and Windows):
% Screen('SelectStereoDrawBuffer', windowPtr, bufferid);
% Screen('DrawLine', windowPtr [,color], fromH, fromV, toH, toV [,penWidth]);
% Screen('DrawArc',windowPtr,[color],[rect],startAngle,arcAngle)
% Screen('FrameArc',windowPtr,[color],[rect],startAngle,arcAngle[,penWidth] [,penHeight] [,penMode])
% Screen('FillArc',windowPtr,[color],[rect],startAngle,arcAngle)
% Screen('FillRect', windowPtr [,color] [,rect] );
% Screen('FrameRect', windowPtr [,color] [,rect] [,penWidth]);
% Screen('FillOval', windowPtr [,color] [,rect]);
% Screen('FrameOval', windowPtr [,color] [,rect] [,penWidth] [,penHeight] [,penMode]);
% Screen('FillPoly', windowPtr [,color], pointList);
%
% % New OpenGL functions for OS X:
% Screen('glPoint', windowPtr, color, x, y [,size]);
% Screen('gluDisk', windowPtr, color, x, y [,size]);
% Screen('DrawDots', windowPtr, xy [,size] [,color] [,center] [,dot_type]);
% Screen('DrawLines', windowPtr, xy [,width] [,colors] [,center] [,smooth]);
% [sourceFactorOld, destinationFactorOld]=('BlendFunction', windowIndex, [sourceFactorNew], [destinationFactorNew]);
%
% % Draw Text in windows
% textModes = Screen('TextModes');
% oldCopyMode=Screen('TextMode', windowPtr [,textMode]);
% oldTextSize=Screen('TextSize', windowPtr [,textSize]);
% oldStyle=Screen('TextStyle', windowPtr [,style]);
% [oldFontName,oldFontNumber]=Screen(windowPtr,'TextFont' [,fontNameOrNumber]);
% [normBoundsRect, offsetBoundsRect]=Screen('TextBounds', windowPtr, text);
% [newX,newY]=Screen('DrawText', windowPtr, text [,x] [,y] [,color] [,backgroundColor] [,yPositionIsBaseline]);
% oldTextColor=Screen('TextColor', windowPtr [,colorVector]);
% oldTextBackgroundColor=Screen('TextBackgroundColor', windowPtr [,colorVector]);
%
% % Copy an image, very quickly, between textures, offscreen windows and onscreen windows.
% [resident [texidresident]] = Screen('PreloadTextures', windowPtr [, texids]);
% Screen('DrawTexture', windowPointer, texturePointer [,sourceRect] [,destinationRect] [,rotationAngle] [, filterMode] [, globalAlpha]);
% Screen('CopyWindow', srcWindowPtr, dstWindowPtr, [srcRect], [dstRect], [copyMode])
%
% % Copy an image, slowly, between matrices and windows :
% imageArray=Screen('GetImage', windowPtr [,rect] [,bufferName]);
% Screen('PutImage', windowPtr, imageArray [,rect]);
%
% % Synchronize with the window's screen (on-screen only):
% [VBLTimestamp StimulusOnsetTime FlipTimestamp Missed Beampos] = Screen('Flip', windowPtr [, when] [, dontclear] [, dontsync] [, multiflip]);
% [telapsed] = Screen('DrawingFinished', windowPtr [, dontclear] [, sync]);
% framesSinceLastWait = Screen('WaitBlanking', windowPtr [, waitFrames]);
%
% % Load color lookup table of the window's screen (on-screen only):
% [gammatable, dacbits, reallutsize] = Screen('ReadNormalizedGammaTable', windowPtrOrScreenNumber);
% Screen('LoadNormalizedGammaTable', windowPtrOrScreenNumber, table [, loadOnNextFlip]);
% oldclut = Screen('LoadCLUT', windowPtrOrScreenNumber [, clut] [, startEntry=0] [, bits=8]);
%
% % Get (and set) information about a window or screen:
% screenNumbers=Screen('Screens);
% windowPtrs=Screen('Windows');
% kind=Screen(windowPtr, 'WindowKind');
% isOffscreen=Screen(windowPtr,'IsOffscreen');
% hz=Screen('FrameRate', windowPtrOrScreenNumber [, mode] [, reqFrameRate]);
% hz=Screen('NominalFrameRate', windowPtrOrScreenNumber [, mode] [, reqFrameRate]);
% [ monitorFlipInterval nrValidSamples stddev ]=Screen('GetFlipInterval', windowPtr [, nrSamples] [, stddev] [, timeout]);
% screenNumber=Screen('WindowScreenNumber', windowPtr);
% rect=Screen('Rect', windowPtrOrScreenNumber);
% pixelSize=Screen('PixelSize', windowPtrOrScreenNumber);
% pixelSizes=Screen('PixelSizes', windowPtrOrScreenNumber);
% [width, height]=Screen('WindowSize', windowPointerOrScreenNumber);
% [width, height]=Screen('DisplaySize', ScreenNumber);
% [oldmaximumvalue oldclampcolors] = Screen('ColorRange', windowPtr [, maximumvalue][, clampcolors=1]);
%
% % Get/set details of environment, computer, and video card (i.e. screen):
% struct=Screen('Version');
% comp=Screen('Computer');
% oldBool=Screen('Preference', 'IgnoreCase' [,bool]);
% tick0Secs=Screen('Preference', 'Tick0Secs', tick0Secs);
% psychTableVersion=Screen('Preference', 'PsychTableVersion');
% mexFunctionName=Screen('Preference', 'PsychTableCreator');
% proc=Screen('Preference', 'Process');
% oldBool=Screen('Preference','Backgrounding');
% oldSecondsMultiplier=Screen('Preference', 'SecondsMultiplier');
% Screen('Preference','SkipSyncTests', skipTest);
% Screen('Preference','VisualDebugLevel', level (valid values between 0 and 5));
% Screen('Preference', 'ConserveVRAM', mode (valid values between 0 and 3));
% Screen('Preference', 'Enable3DGraphics', [enableFlag]);
%
% % Helper functions.  Don't call these directly, use eponymous wrappers:
% [x, y, buttonVector]= Screen('GetMouseHelper', numButtons);
% Screen('HideCursorHelper', windowPntr);
% Screen('ShowCursorHelper', windowPntr);
% Screen('SetMouseHelper', windowPntrOrScreenNumber, x, y);
%
% % Internal testing of Screen
% timeList= Screen('GetTimelist');
% Screen('ClearTimelist');
% Screen('Preference','DebugMakeTexture', enableDebugging);
%
% % Movie and multimedia playback functions:
% [ moviePtr [duration] [fps] [width] [height] [count]]=Screen('OpenMovie', windowPtr, moviefile [, async=0]);
% Screen('CloseMovie', moviePtr);
% [ texturePtr [timeindex]]=Screen('GetMovieImage', windowPtr, moviePtr, [waitForImage], [fortimeindex]);
% [droppedframes] = Screen('PlayMovie', moviePtr, rate, [loop], [soundvolume]);
% timeindex = Screen('GetMovieTimeIndex', moviePtr);
% [oldtimeindex] = Screen('SetMovieTimeIndex', moviePtr, timeindex);
%
% % Video capture functions:
% videoPtr =Screen('OpenVideoCapture', windowPtr [, deviceIndex] [,roirectangle] [, pixeldepth] [, numbuffers] [, allowfallback] [, targetmoviename] [, recordingflags]);
% Screen('CloseVideoCapture', capturePtr);
% [fps starttime] = Screen('StartVideoCapture', capturePtr [, captureRateFPS] [, dropframes=0] [, startAt]);
% droppedframes = Screen('StopVideoCapture', capturePtr);
% [texturePtr [capturetimestamp] [droppedcount] [summed_intensity]]=Screen('GetCapturedImage', windowPtr, capturePtr [, waitForImage=1] [,oldTexture] [,specialmode]);
% oldvalue = Screen('SetVideoCaptureParameter', capturePtr, 'parameterName' [, value]);
%
% % Low level direct access to OpenGL-API functions:
% % Online info for each function available by opening a terminal window
% % and typing 'man Functionname' + Enter.
%
% Screen('glPushMatrix', windowPtr);
% Screen('glPopMatrix', windowPtr);
% Screen('glLoadIdentity', windowPtr);
% Screen('glTranslate', windowPtr, tx, ty [, tz]);
% Screen('glScale', windowPtr, sx, sy [, sz]);
% Screen('glRotate', windowPtr, angle, [rx = 0], [ry = 0] ,[rz = 1]);
%
% % Support for 3D graphics rendering and for interfacing with external OpenGL code:
% Screen('Preference', 'Enable3DGraphics', [enableFlag]);  % Enable 3D gfx support.
% Screen('BeginOpenGL', windowPtr [, sharecontext]);  % Prepare window for external OpenGL drawing.
% Screen('EndOpenGL', windowPtr);  % Finish external OpenGL drawing.
% [textureHandle rect] = Screen('SetOpenGLTextureFromMemPointer', windowPtr, textureHandle, imagePtr, width, height, depth [, upsidedown][, target][, glinternalformat][, gltype][, extdataformat]);
% [textureHandle rect] = Screen('SetOpenGLTexture', windowPtr, textureHandle, glTexid, target [, glWidth] [, glHeight] [, glDepth]);
% [ gltexid gltextarget texcoord_u texcoord_v ] =Screen('GetOpenGLTexture', windowPtr, textureHandle [, x][, y]);
%
% % Support for plugins and for builtin high performance image processing pipeline:
% [ret1, ret2, ...] = Screen('HookFunction', windowPtr, 'Subcommand', 'HookName', arg1, arg2, ...);
% proxyPtr = Screen('OpenProxy', windowPtr [, imagingmode]);
% transtexid = Screen('TransformTexture', sourceTexture, transformProxyPtr
% [, targetTexture]);