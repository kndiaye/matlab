function Results = minnorm(OPTIONS);
%MINNORM - Mininum norm solution as called from command line or BST_SOURCEIMAGING.M
% function Results = minnorm(OPTIONS);
% -------------------------------------------------------------------------------------------------
% NOTICE:
% This function is not optimized for stand-alone command calls.
% Please use the generic BST_SOURCEIMAGING function to access Min.Norm. source map computations.
% -------------------------------------------------------------------------------------------------
%
%
% INPUTS
%       OPTIONS - a structure of parameters
% OUTPUTS
%       Results - a regular BrainStorm Results structure (see documentation for details)
%
% Details of the OPTIONS structure
%
%   Data Information:
%          .DataFile   : A string actual data file requested for localization. If isempty, look for data array(s) in .Data
%          .Data       : Array of nChannel x nTime array(s) of data.
%          .SegmentIndices: Vector of all time samples (in sample values)
%                           of the latencies specifying the time window for analysis.
%          .Trial      : A scalar specifying the trial from which to extract the data segment
%                        (not empty only when data in .DataFile is stored in native format)
%          .ChannelFlag: a vector of flags (1 for good, -1 for bad) of channels in the data file to process
%          .DataTypes  : A scalar or a vector of codes to specidy which is the type of data to use:
%                        1 is MEG, 2 is EEG, 3 is Fusion
%                        (Default is all data type available)
%          .FusionType : Code for the type of fusion to apply between MEG and EEG data
%                        1 is linear, 2 is non-linear
%                        (Defaut is 1)
%          .Data       : Specify some data to be passed independently of any data file
%                            .F : Cell array of nChannel x nTime array(s) of data.
%                                 If not empty: uses this array as input for inverse process.
%                            .ChannelFile : Channel file corresponding to data in .F
%                            .Time : Vector specifying the time instants of data samples in .Data.F
%                        (Default for .Data is empty)
%
%   Source Support Information:
%          .GridLoc    : a string or a 3xN matrix
%                        - if a string : specifies the name of the BrainStorm tessellation file where cortical support is stored
%                        - if a matrix : contains the coordinates of the cortical locations where to compute the cortical current density
%          .iGrid      : when .GridLoc is a file name, specify which imaging grid to use (Default is 1).
%
%   Forward Field Information :
%          .HeadModelFile: Cell array of strings for filename of the BrainStorm headmodel file(s) to use for imaging. If is empty, look for.GainFile field.
%                          There are only 2 options at this point:
%                                - .HeadModelFile is of length 1, a single headmodel file is used for all data sets passed to the bst_sourceimaging.
%                                - .HeadModelFile is of length the number of data sets passed to bst_sourceimaging (i.e. the length of .DataFile).
%          .GainFile   : Cell array of filenames of image gain matrix (.bin) for the selected cortical support. If is empty, look for .Gain field.
%                        Remarks about the length of .HeadModelFile hold for .GainFile too.
%          .Gain       : Cell array containing the gain matrix of the cortical support (either a single cell or a cell array the length the number of data sets passed to function)
%                        Remarks about the length of .HeadModelFile hold for .GainFile too.
%                        (Default is empty).
%
%   Processing Parameters :
%          .Method     : A string that specifies the imaging method
%                        'Minimum-Norm Imaging': MN estimate of current density using MN priors on source amplitudes (Default)
%                        'Recursive Min. Norm.': Recursive MN estimate based on adaptation of FOCUSS (NOT AVAILABLE)
%                        'SPTF' : Scanning technique constrained on cortical surface (see Denis Schwartz) (UNDER DEVELOPMENT)
%                        'ST-MAP' : Non-linear imaging technique based on sparse-focal image models (NOT AVAILABLE)
%                        'RAP-MUSIC' : link to Mosher's GUI (UNDER DEVELOPMENT)
%                        (Default is 'Minimum-Norm Imaging')
%          .Tikhonov   : Hyperparameter used in Tykhonov regularization
%                        (Default is 10)
%          .FFNormalization : Apply forward field normalization of the gain matrix
%                        (Default is 1)
%          .Rank       : Specify a rank for signal subspace following SVD of the spatio-temporal data matrix
%                        (Default is full rank)
%          .ComputeKernel : If 1, compute MN kernel to be applied subsequently to data instead of full ImageGridAmp array
%                         (Default is 0: compute full ImageGridAmp array)
%
%   Output Information:
%          .ResultFile : optional string for filename where to write results
%                        if 'default', filename as used in GUI environment is used
%                        (Default is '' (no Result file created))
%          .Verbose    : Turn ON/OFF verbose mode
%                        (Default is 1 (ON))
%          .GUIHandles : A vector of GUI handles to the SOURCEIMAGING GUI
%                        when operating in graphic mode: passed automatically to bst_sourceimaging by the source imaging switchyard
%                        in command line mode: leave this field empty (default).
%          .NNormalization : Apply noise normalization
%                        (Default is 0)

%<autobegin> ---------------------- 27-Jun-2005 10:45:06 -----------------------
% ------ Automatically Generated Comments Block Using AUTO_COMMENTS_PRE7 -------
%
% CATEGORY: Inverse Modeling
%
% Alphabetical list of external functions (non-Matlab):
%   toolbox\bst_message_window.m
%   toolbox\colnorm.m
%   toolbox\good_channel.m
%   toolbox\inorcol.m
%   toolbox\meg4read.m
%   toolbox\norcol.m
%   toolbox\read_gain.m
%   toolbox\regcheck.m
%   toolbox\regsubspace.m
%
% Subfunctions in this file, in order of occurrence in file:
%   varargout = gainmat_covar(varargin)
%
% At Check-in: $Author: Mosher $  $Revision: 38 $  $Date: 6/27/05 9:00a $
%
% This software is part of BrainStorm Toolbox Version 27-June-2005  
% 
% Principal Investigators and Developers:
% ** Richard M. Leahy, PhD, Signal & Image Processing Institute,
%    University of Southern California, Los Angeles, CA
% ** John C. Mosher, PhD, Biophysics Group,
%    Los Alamos National Laboratory, Los Alamos, NM
% ** Sylvain Baillet, PhD, Cognitive Neuroscience & Brain Imaging Laboratory,
%    CNRS, Hopital de la Salpetriere, Paris, France
% 
% See BrainStorm website at http://neuroimage.usc.edu for further information.
% 
% Copyright (c) 2005 BrainStorm by the University of Southern California
% This software distributed  under the terms of the GNU General Public License
% as published by the Free Software Foundation. Further details on the GPL
% license can be found at http://www.gnu.org/copyleft/gpl.html .
% 
% FOR RESEARCH PURPOSES ONLY. THE SOFTWARE IS PROVIDED "AS IS," AND THE
% UNIVERSITY OF SOUTHERN CALIFORNIA AND ITS COLLABORATORS DO NOT MAKE ANY
% WARRANTY, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO WARRANTIES OF
% MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, NOR DO THEY ASSUME ANY
% LIABILITY OR RESPONSIBILITY FOR THE USE OF THIS SOFTWARE.
%<autoend> ------------------------ 27-Jun-2005 10:45:06 -----------------------



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% /---Script Author--------------------------------------\
% | *** John C. Mosher, Ph.D.                            |
% |  Biophysics Group                                    |
% |                                                      |
% | *** Sylvain Baillet, Ph.D.                           |
% | Cognitive Neuroscience & Brain Imaging Laboratory    |
% | CNRS UPR640 - LENA                                   |
% | Hopital de la Salpetriere, Paris, France             |
% | sylvain.baillet@chups.jussieu.fr                     |
% \------------------------------------------------------/
%
% Date of creation: October 2002 (adapted from MINNORM_GUI.M, now obsolete and moved to ARCHIVE)
%
% Script History -----------------------------------------------------------------------------------
% SB 23-Dec-2002 Added .ComputeKernel option
%                Added .Data option
% SB 19-Oct-2003 Added .TimeSeries field to Results structure (as per BrainStorm general convention)
% EK 02-Oct-2004 Changed .Tikhonov to be defined as the percentage of the
%                maximum sigular value.
% EK 04-Oct-2004 Added noise normalization for both BST and Kernel
%                format
% SB 02-May-2005 Added deprecated code 
% SB 13-May-2005 More efficient computation of noise normalization
% SB 16-May-2005 Warning off when trying to load Projector from data file
% SB 19-May-2005 Added DP bug fix when number of sources > 10,000 (default block
%                size)
% SB 22-May-2005 Fixed bug for AAt EEG computation when length(sources) =
%                block size + 1
% SB 23-May-2005 Fixed bug: ChannelFlag are now properly read from file
%---------------------------------------------------------------------------------------------------

% General hard-wired parameter values:--------------------------------------------------------------
DataType = {'MEG','EEG','Fusion'}; % String labels corresponding to OPTIONS.DataTypes flags
OPTIONS.BLOCK = 10000; % process by blocks
OPTIONS.ExpoiG = .4; % Exponential weighting for column normalization
%---------------------------------------------------------------------------------------------------

% Load Headmodel information -----------------------------------------------------------------------

% From file, if passed to function
if ~isempty(OPTIONS.HeadModelFile)
    HeadModel = load(OPTIONS.HeadModelFile,'Function','Param',...
        'GridLoc','Gain'); % Load Basics

    if ~isempty(OPTIONS.GridLoc)
        HeadModel.GridLoc = {OPTIONS.GridLoc};
    end
    if ~isempty(OPTIONS.Gain)
        HeadModel.Gain = OPTIONS.Gain;
    end
    
    HeadModelFileWhos = whos('-file',OPTIONS.HeadModelFile);
    %     if OPTIONS.DataTypes == 3
    %         % If Fusion, force gain column normalization
    %         OPTIONS.FFNormalization = 1 ;
    %     end
    
    if OPTIONS.FFNormalization == 1 % Forward-field normalization requested
        if OPTIONS.DataType == 3 % Fusion: load specific items
            if ~isempty(find(strcmp(cellstr(char(HeadModelFileWhos(:).name)),'GainCovar_ColNormFus')))
                tmp = load(OPTIONS.HeadModelFile,'GainCovar_ColNormFus');
                AAt = tmp.GainCovar_ColNormFus{1}; % Generic name for gain covariance entry (see below)
            else
                AAt = [];
            end
            if ~isempty(find(strcmp(cellstr(char(HeadModelFileWhos(:).name)),'Gain_RowNorm')))
                tmp = load(OPTIONS.HeadModelFile,'Gain_RowNorm');
                Gain_RowNorm = tmp.Gain_RowNorm;
            else
                Gain_RowNorm = cell(size(HeadModel.Gain));
            end

        else
            if ~isempty(find(strcmp(cellstr(char(HeadModelFileWhos(:).name)),'GainCovar_ColNorm')))
                tmp = load(OPTIONS.HeadModelFile,'GainCovar_ColNorm');
                AAt = tmp.GainCovar_ColNorm{1};  % Generic name for gain covariance entry (see below)
            else
                AAt = [];
            end
        end

    else % FF is set to 0
        if ~isempty(find(strcmp(cellstr(char(HeadModelFileWhos(:).name)),'GainCovar')))
            tmp = load(OPTIONS.HeadModelFile,'GainCovar');
            AAt = tmp.GainCovar{1}; % Generic name for gain covariance entry (see below)
            if iscell(AAt)
                AAt = AAt{1};
            end
        else
            AAt = [];
        end
    end

    clear tmp

    % Gain matrix full filename
    gainfile = fullfile(fileparts(OPTIONS.HeadModelFile),HeadModel.Gain{1});

end

% Load Data Information -----------------------------------------------------------------------

if(~isempty(findstr('_results',deblank(lower(OPTIONS.DataFile))))),
    % CHEAT
    % The DataName has the string '_results' in it
    % We are trying to treat independent topographies as min norm data. Eventually this
    %  capability will be moved to a new routine.
    % name has the string '_results' in it
    Results = load(OPTIONS.DataFile);
    % now synthesize a Data structure from this
    [ignorm,Anrm] = colnorm(Results.IndepTopo);

    Data = struct('F',Anrm,'ChannelFlag',Results.ChannelFlag,...
        'Time',[1:size(Results.IndepTopo,2)],... % time is now simply an indexer
        'NoiseCov',Results.NoiseCov,'SourceCov',Results.SourceCov,'Projector',Results.Projector,...
        'Comment',sprintf('Synthesized Data Set from Results: %s',Results.Comment));
else
    if isempty(OPTIONS.Data)
        % assume it is a standard data file
        DataArray = 0; % Correponsing flag
        warning off
        Data = load(OPTIONS.DataFile,'F','ChannelFlag','Time','Projector','Comment');
        warning on
    else
        DataArray = 1;
        Data = OPTIONS.Data;
        Data.Projector = [];
        Data.Comment = '';
        Data.ChannelFlag = ones(size(Data.F,1),1);
    end

end

% Data & Channel information ------------------------------------------------------------------
if isfield(OPTIONS,'ChannelFile')
    Channel = load(OPTIONS.ChannelFile);
    OPTIONS.Channel = Channel.Channel; clear Channel
end

% now alter the data according to the bad channels
OPTIONS.GoodChannel = good_channel(OPTIONS.Channel,Data.ChannelFlag,DataType{OPTIONS.DataType}); %good channels for selected modality
OPTIONS.EEGChannel = good_channel(OPTIONS.Channel,[],'EEG');
OPTIONS.MEGChannel = good_channel(OPTIONS.Channel,[],'MEG');

if ischar(Data.F) % Data is in native file format
    VERBOSE = 1;
    Data.F = meg4read(Data.F,OPTIONS.Trial,OPTIONS.SegmentIndices,OPTIONS.Verbose);
    Data.FBaseline = meg4read(Data.F,OPTIONS.Trial,OPTIONS.NoiseSegmentIndices,OPTIONS.Verbose);
else
    % Trim the data to the requested segments
    if OPTIONS.NNormalization
        Data.FBaseline = Data.F(:,OPTIONS.NoiseSegmentIndices);
    end
    Data.F = Data.F(:,OPTIONS.SegmentIndices);


end


try
    Data.F = Data.F(OPTIONS.GoodChannel,:); % good channels only
    if OPTIONS.NNormalization
        Data.FBaseline = Data.FBaseline(OPTIONS.GoodChannel,:); % good channels for noise segment too
    end

catch
    errordlg(sprintf('Data array has %d rows while there are %d %s channels. Possible problem is wrong type assignement of reference vs. measurement channels in channel file %s',...
        size(Data.F,1),length(OPTIONS.GoodChannel), DataType{OPTIONS.DataType}, OPTIONS.ChannelFile ),'Inconsistent channel and data array sizes')
    return
end


Time = Data.Time(OPTIONS.SegmentIndices);


% Is there any projector for the data ?
if ~isfield(Data,'Projector')
    Data.Projector = [];
end
if(~isempty(Data.Projector)),
    Data.Projector = Data.Projector(OPTIONS.GoodChannel,:);
end

% Get HeadModel parmaters for GoodChannels
if 0 % Deprecated code (thanks to Nicolas Lefebvre) | SB - 02-May-2005
    HeadModel.Param = HeadModel.Param(OPTIONS.GoodChannel);
end



% ------------------------ If not available : Create & Save Gain Matrix Covariance  -------------------------------------

if isempty(AAt) % Need to compute the proper gain covariance matrix (depending on DataType and and Forward Fiels normalization option)
    % NOTE : This is a one-time computation
    %        Result will be saved to HeadModelFile
    if OPTIONS.Verbose
        bst_message_window('Starting one-time (long) computation . . .')
        if ~isempty(OPTIONS.GUIHandles)
            OPTIONS.hwaitbar = waitbar(0,'Creating Column-Normalized Gain Matrix Covariance...');
        else
            bst_message_window('Creating Column-Normalized Gain Matrix Covariance...');
        end
    end

    % Compute gain matrix covariance
    [AAt, Gain_RowNorm] = gainmat_covar(gainfile, OPTIONS);

    if OPTIONS.Verbose & ~isempty(OPTIONS.GUIHandles)
        close(OPTIONS.hwaitbar);
        bst_message_window('Saving the gain covar back into your head model');
    end

    % Now save back to headmodel file

    switch OPTIONS.FFNormalization
        case 0
            GainCovar{1} = AAt;
            save(OPTIONS.HeadModelFile,'GainCovar','-append');
        case 1
            if OPTIONS.DataType == 3
                GainCovar_ColNormFus{1} = AAt;
                Gain_RowNorm = {Gain_RowNorm}; % Save it as a cell like other Gain* entries in headmodel file
                save(OPTIONS.HeadModelFile,'GainCovar_ColNormFus','Gain_RowNorm','-append');
            else
                GainCovar_ColNorm{1} = AAt;
                save(OPTIONS.HeadModelFile,'GainCovar_ColNorm','-append');
            end
    end

end  % gain covariance matrix is created and available


% Keep only the rows and columns of AAt corresponding to GoodChannel
AAt = AAt(OPTIONS.GoodChannel,OPTIONS.GoodChannel);
if exist('Gain_RowNorm','var')
    if iscell(Gain_RowNorm)
        Gain_RowNorm = Gain_RowNorm{1};
    end
    if ~isempty(Gain_RowNorm)
        Gain_RowNorm = Gain_RowNorm(OPTIONS.GoodChannel,OPTIONS.GoodChannel);
    else
        clear Gain_RowNorm
    end
end

% if OPTIONS.DataType == 3 % Fusion: Apply gain matrix row-norm weighting.
%     Data.F = Gain_RowNorm*Data.F;
% end

% Update MEG and EEG channel indices by removing bad channels.
OPTIONS.EEGChannel = intersect(OPTIONS.GoodChannel,OPTIONS.EEGChannel);
OPTIONS.MEGChannel = intersect(OPTIONS.GoodChannel,OPTIONS.MEGChannel);

if OPTIONS.DataType == 2 & ...
        length(OPTIONS.GoodChannel) < length(OPTIONS.EEGChannel) % EEG data with bad channels

    % Adjust average reference contribution from covariance matrix
    if isempty(find(mean(Data.F >eps)))
        % Average Reference (don't use the channel.comment field that may not have been altered following manipulations in the data viewer tool)
        % Load gain matrix
        G = read_gain(gainfile,[]);
        if strcmp(OPTIONS.Col_norm,'y');
            G = G*inorcol(G);
        end

        Gm = mean(G,1)';

        I = ones(length(OPTIONS.GoodChannel),1);
        AAt = AAt - G*Gm*I' - I*Gm'*G' + Gm'*Gm*ones(size(AAt)) ;
        clear G
        % Reopen the Gain file that was closed during call to read_gain
        fid = fopen(...
            fullfile(fileparts(OPTIONS.HeadModelFile),HeadModel.Gain{1}),...
            'r','ieee-be'); % HeadModel.Gain{1} - CHEAT Dipoles only
    else
        % Do nothing
    end
end

OPTIONS = regcheck(OPTIONS); % returns OPTIONS.REG set to the appropriate field

% Did the user provide an existing control?
if(isfield(Data,'Projector')),
    %Decompose it:
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

if isempty(OPTIONS.Rank)
    OPTIONS.Rank = min(size(Data.F));
end

if(OPTIONS.Rank < min(size(Data.F))), % reduced rank

    % User has asked for an rank RANK subspace search.
    % Form the signal subspace

    if(size(Data.F,1) >= size(Data.F,2)), % skinny matrix
        [Uf,Sf,Vf] = svd(Data.F,0); % economy
    else % wide matrix
        [Vf,Sf,Uf] = svd(Data.F',0);
    end

    % form the reduced rank data
    Data.F = Uf(:,1:OPTIONS.Rank)*(Sf(1:OPTIONS.Rank,1:OPTIONS.Rank)*Vf(:,1:OPTIONS.Rank)');

    % project away if needed
    if(~isempty(Ua)),
        Data.F = Data.F - Ua*(Ua'*Data.F);
    end

    clear Ua Sa Va Uf Sf Vf
end


%                             --------------------------------------------------------------------------------------

% Begin minimum norm estimate --------------------------------------------------------------------------------------

%                             --------------------------------------------------------------------------------------

% recall the y = Ax, let x = A'c -> y = AA'c, solve for c, the 'coefs' of x.
% c = pinv(AA')*y, and we will regularize the inverse of AA' based on user selection
% Then form x = A'c.

[U,S,V] = svd(AAt);
U = regsubspace(OPTIONS,U,sqrt(S)); % condition based on svd of gain matrix
reg_rank = size(U,2); % reduced rank based on regularization
S = diag(S);
switch deblank(lower(OPTIONS.REG))
    case 'tikhonov'
        Lambda = sqrt(S(1))*OPTIONS.Tikhonov/100 ; % sing values already squared --ESEN Tikhonov percentage
        Si = 1../(S(1:reg_rank)+Lambda^2); % filtered inverse
    otherwise
        % do nothing, truncation only
        Si = 1../S(1:reg_rank);
end

% the min norm coefs
coefs = V(:,1:reg_rank)*...
    ((spdiags(Si,0,reg_rank,reg_rank)*U(:,1:reg_rank)') ); % * Data.F removed to allow optional computation of MN imaging kernel alone

clear U S V

% Contribution of MN estimate to data (Fsynth)
% let rAAt = regularized(AAt), as found by the above
%  So Data.F = AAt *c, c = inv(rAAt), so Fsynth = AAt*c, let's calculate and stick into results
Fsynth = AAt * coefs * Data.F; %Estimated Data

clear AAt

% Calculate source amplitudes explicitly  ---------------------------------------------------------------
% How many sources ?
tmp = read_gain(gainfile,OPTIONS.GoodChannel(1),[]);
nsrc = length(tmp); clear tmp % Number of sources

if OPTIONS.ComputeKernel == 0

    ImageGridAmp = single(zeros(nsrc,size(Data.F,2))); % one column per time slice / 07-Oct-2002 : SB - now stored as 'singles' (space saver)
    ImagingKernel = [];

    if OPTIONS.Verbose
        if ~isempty(OPTIONS.GUIHandles) & nsrc > OPTIONS.BLOCK
            hwaitbar = waitbar(0,'Inverse transformation running. . .');
        else
            bst_message_window('Inverse transformation running. . .');
        end

        bst_message_window({...
            sprintf('Image support: %.0f grid points . . .',nsrc)...
            })

    end

    % Iterative block computation of source amplitudes

    for i = 1:OPTIONS.BLOCK:nsrc

        if ~isempty(OPTIONS.GUIHandles)
            if nsrc > OPTIONS.BLOCK
                waitbar(i/nsrc,hwaitbar);
            end
        end

        % Indices of next sources for which amplitude needs to be estimated
        ndx = [0:(OPTIONS.BLOCK-1)]+i;
        if(ndx(end) > nsrc),  % last block too long
            ndx = [ndx(1):nsrc];
        end

        % Load and possibly normalize forward fields (Kernel) for running block of sources
        if OPTIONS.FFNormalization == 1
            clear Kernel
            if OPTIONS.DataType == 1
                Chans = OPTIONS.MEGChannel;
            elseif OPTIONS.DataType == 2
                Chans = OPTIONS.EEGChannel;
            elseif OPTIONS.DataType == 3
                Chans = OPTIONS.GoodChannel;
            end

            Kernel = read_gain(gainfile,Chans,ndx); % Chunk of gain matrix for this block of sources
            if OPTIONS.DataType == 3
                Kernel = Gain_RowNorm * Kernel;
            end

            OPTIONS.iG = sqrt(norcol(Kernel)');  % NORCOL computes the column norms to the SQUARE
            OPTIONS.iG(OPTIONS.iG == 0) = min(OPTIONS.iG(OPTIONS.iG ~= 0));
            iKernel = spdiags((1./OPTIONS.iG).^OPTIONS.ExpoiG, 0, length(OPTIONS.iG), length(OPTIONS.iG)) ;
            Kernel = (Kernel*iKernel)*iKernel;

        elseif OPTIONS.FFNormalization == 0

            Kernel = read_gain(gainfile,OPTIONS.GoodChannel,ndx); % Chunk of gain matrix for this block of sources

        end

        % next chunk of source amplitudes
        if i == 1
            if OPTIONS.NNormalization
                coefsBaseline = coefs*Data.FBaseline;
            end
            coefs = coefs * Data.F;

        end
        % ESEN - Add Noise normalization in BST Mode
        if isempty(find(Kernel==NaN)) & isreal(Kernel) % Check Kernel integrity
            if OPTIONS.NNormalization
                % Compute source baseline stats
                tmp = (Kernel'*coefsBaseline);
                mean_Baseline= mean(tmp,2);
                std_Baseline = std(tmp,0,2);

                % Plain source ampltiudes outside baseline
                ImageGridAmp(ndx, :) = (Kernel'*coefs);
                
                % Proceed to Z-score normalization
                iStd = spdiags(1./std_Baseline, 0, length(std_Baseline), length(std_Baseline)) ; % variance normalization
                ImageGridAmp(ndx, :) = single(full(iStd * (double(ImageGridAmp(ndx, :)) - double(repmat(mean_Baseline, 1, size(ImageGridAmp, 2)))))); 


                clear tmp mean_Baseline std_Baseline
            else
                ImageGridAmp(ndx,:) = single(Kernel'*coefs);  % 07-Oct-2002 SB : now stores under 'single' format (space saver)
            end
        else
            ImageGridAmp(ndx,:) = NaN;
            if OPTIONS.Verbose
                bst_message_window('wrap',{...
                        'XXXX Imaging Kernel is deficient, filling source amplitudes with NaNs.'})
            end
        end
        
        clear Kernel

    end

    if nsrc > OPTIONS.BLOCK & ~isempty(OPTIONS.GUIHandles)
        close(hwaitbar);
    end

else % Compute imaging Kernel only

    ImageGridAmp = [];

    if OPTIONS.Verbose
        bst_message_window({...
            'Computing Minimum-Norm Imaging Kernel. . .',...
            sprintf('Image support: %.0f grid points . . .',nsrc)...
            })
    end

    % Load and possibly normalize forward fields (Kernel)
    if OPTIONS.FFNormalization == 1
        clear Kernel
        if OPTIONS.DataType == 1
            Chans = OPTIONS.MEGChannel;
        elseif OPTIONS.DataType == 2
            Chans = OPTIONS.EEGChannel;
        elseif OPTIONS.DataType == 3
            Chans = OPTIONS.GoodChannel;
        end

        Kernel = read_gain(gainfile,Chans,1:nsrc); % Chunk of gain matrix for this block of sources

        if OPTIONS.DataType == 3
            Kernel = Gain_RowNorm * Kernel;
        end

        OPTIONS.iG = sqrt(norcol(Kernel)');  % NORCOL computes the column norms to the SQUARE
        OPTIONS.iG(OPTIONS.iG == 0) = min(OPTIONS.iG(OPTIONS.iG ~= 0));
        iKernel = spdiags((1./OPTIONS.iG).^OPTIONS.ExpoiG, 0, length(OPTIONS.iG), length(OPTIONS.iG)) ;
        Kernel = (Kernel*iKernel)*iKernel;

    elseif OPTIONS.FFNormalization == 0

        Kernel = read_gain(gainfile,OPTIONS.GoodChannel,1:nsrc); % Chunk of gain matrix for this block of sources

    end


    % ESEN - Add Noise normalization to Kernel only format too

    if OPTIONS.NNormalization
        tmp = (Kernel'*coefs*Data.FBaseline);
        mean_Baseline= mean(tmp,2);
        std_Baseline = std(tmp,0,2);
        tmp = (Kernel'*coefs);
        
%        ImagingKernel = (tmp - repmat(mean_Baseline, 1, size(tmp, 2))) ./  repmat(std_Baseline, 1, size(tmp, 2));
        ImagingKernel = tmp ./  repmat(std_Baseline, 1, size(tmp, 2));
        ImagingKernel = single(ImagingKernel);
        clear tmp mean_Baseline std_Baseline
    else
        ImagingKernel = single(Kernel'*coefs);
    end

    clear Kernel

end



if OPTIONS.Verbose
    bst_message_window({...
        'Inverse Transformation -> DONE.'...
        })
end

%
% MN estimate - DONE --------------------------------------------------------------------------------------------------------------------------


% Save Results in Result file -----------------------------------------------------------------------------------------------------------------
%
% Fields from Results structure
Channel = OPTIONS.Channel;
ChannelFlag = Data.ChannelFlag;
Comment = sprintf('MIN NORM, rank %.0f',OPTIONS.Rank);
DataFile = OPTIONS.DataFile;
Date = datestr(datenum(now),0);
Time = [OPTIONS.SegmentIndices];
ImageGridTime = Data.Time(Time);
ImageGridAmp = ImageGridAmp;  % monster matrix when ImagingKernel is not computed
Function = mfilename; % name of this calling routine
HeadModelFile = OPTIONS.HeadModelFile;
ModelGain = HeadModel.Gain{1};
Projector = Data.Projector;
SourceLoc = HeadModel.GridLoc{1};
SourceOrder = -1;

NoiseCov = [];
SourceCov = [];
PatchNdx = [];
PatchAmp = [];


% Reduced Results structure for call from bst_sourceimaging.
Results = struct('Comment',Comment,'Function',mfilename,...
    'OPTIONS',OPTIONS,'Date','','Time',Time,'HeadModelFile',HeadModelFile,...
    'Channel',Channel,'ChannelFlag',Data.ChannelFlag,'DataFile',OPTIONS.DataFile,...
    'NoiseCov',NoiseCov,'SourceCov',SourceCov,...
    'Projector',Projector,'SourceLoc',SourceLoc,'SourceOrder',SourceOrder,...
    'SourceOrientation',[],'TimeSeries',[],'ImagingKernel',ImagingKernel,'ModelGain',ModelGain,...
    'PatchNdx',PatchNdx,'PatchAmp',PatchAmp, ...
    'ImageGridAmp',ImageGridAmp,'ImageGridTime',ImageGridTime,'Fsynth',Fsynth);

return

% -----------------------------------------------------------------------------------------------------
%
%
%                                             SubFunctions
%
%
% -----------------------------------------------------------------------------------------------------

function varargout = gainmat_covar(varargin)

% GAINMAT_COVAR Computation of gain matrix covariance
% function [GainCovar] = gainmat_covar(gainfile,OPTIONS)
% Computation of gain matrix covariance
%
% INPUTS
%
% gainfile : a string - filename of the binary gain matrix file (imaging grid)
% OPTIONS  : a structure specifying the options for the computation
%            .Verbose : turn on/off verbose mode (1/0)
%            .DataType: scalar specifying the type of data
%                       1 is MEG
%                       2 is EEG
%                       3 is MEG/EEG fusion
%            .FFNormalization : flag specifying whether forward field normalization is requested
%                       0 off
%                       1 on
%            .GoodChannel : Indices of good channels for current DataType
%            .MEGChannel  : Indices of all MEG channels
%            .EEGChannel  : Indcies of all EEG channels
%
% OUTPUTS
% GainCovar : a structure with the proper gain covar matrix outputs
%
% /---Script Author--------------------------------------\
% | *** John C. Mosher, Ph.D.                            |
% |  Biophysics Group                                    |
% |                                                      |
% | *** Sylvain Baillet, Ph.D.                           |
% | Cognitive Neuroscience & Brain Imaging Laboratory    |
% | CNRS UPR640 - LENA                                   |
% | Hopital de la Salpetriere, Paris, France             |
% | sylvain.baillet@chups.jussieu.fr                     |
% \------------------------------------------------------/
%
% Date of creation: October 2002
% Script History -----------------------------------------------------------------------------------
%---------------------------------------------------------------------------------------------------

% Map entries
gainfile = varargin{1};
OPTIONS = varargin{2};

% Read number of sources and total number of channels
tmp = read_gain(gainfile,OPTIONS.GoodChannel(1),[]);
nsrc = length(tmp); clear tmp % Number of sources
tmp = read_gain(gainfile,[],1);
nchan = length(tmp); clear tmp % Number of channels

% if OPTIONS.Verbose
%     bst_message_window(sprintf('Image support: %.0f grid points . . .',nsrc));
% end

AAt = zeros(nchan); %  Initialize GainCovar matrix
Gain_RowNorm = [];  %  Initialize matrix containing norms of gain matrix rows (useless and therefore empty if DataType ~= 3)

for i = 1:OPTIONS.BLOCK:nsrc,

%     if OPTIONS.Verbose & ~isempty(OPTIONS.GUIHandles)
%         waitbar(i/nsrc,OPTIONS.hwaitbar);
%     end

    ndx = [0:(OPTIONS.BLOCK-1)]+i;
    if(ndx(end) > nsrc),  % last block too long
        ndx = [ndx(1):nsrc];
    end

    % Normalize EEG and MEG forward fields separately
    % Fusion Case
    if OPTIONS.DataType == 3 % Compute gain matrix row norm on first block only
        if i == 1
            Gain_RowNorm = zeros(length(OPTIONS.Channel));
            if ~isempty(OPTIONS.GUIHandles)
                hkk = waitbar(0,'Processing Lead-Field Normalization...');
            end
            
            tmp = inorcol((read_gain(gainfile,OPTIONS.GoodChannel,1:nsrc))');
            Gain_RowNorm(OPTIONS.GoodChannel,OPTIONS.GoodChannel) = diag(diag([tmp]));
            if 0 
                for kk = OPTIONS.GoodChannel
                    Gain_RowNorm(kk,kk) = 1/norm(read_gain(gainfile,kk,1:nsrc));
                    if ~isempty(OPTIONS.GUIHandles)
                        waitbar((kk-OPTIONS.GoodChannel(1)+1)/length(OPTIONS.GoodChannel))
                    end
                end
            end

            if ~isempty(OPTIONS.GUIHandles)
                close(hkk)
            end
        end

        temp = Gain_RowNorm([OPTIONS.GoodChannel],[OPTIONS.GoodChannel])*read_gain(gainfile,[OPTIONS.GoodChannel],ndx);
        OPTIONS.iG = sqrt(norcol(temp)'); % NORCOL computes the column norms to the SQUARE
        OPTIONS.iG(OPTIONS.iG == 0)= min(OPTIONS.iG(OPTIONS.iG ~= 0));
        OPTIONS.iG = spdiags((1./OPTIONS.iG).^OPTIONS.ExpoiG, 0, length(OPTIONS.iG), length(OPTIONS.iG)) ;
        AAt(OPTIONS.GoodChannel,OPTIONS.GoodChannel) = AAt(OPTIONS.GoodChannel,OPTIONS.GoodChannel) + temp*(OPTIONS.iG*OPTIONS.iG)*temp';  % next chunk of correlations

    else % MEG | EEG
        temp = read_gain(gainfile,[OPTIONS.MEGChannel],ndx);
        if ~isempty(OPTIONS.MEGChannel) & ~isempty(temp)
            temp(find(isnan(temp))) = 0;
            if OPTIONS.FFNormalization % Forward field normalization is requested
                OPTIONS.iG = sqrt(norcol(temp)');  % NORCOL computes the column norms to the SQUARE
                OPTIONS.iG(OPTIONS.iG == 0)= min(OPTIONS.iG(OPTIONS.iG ~= 0));
                OPTIONS.iG = spdiags((1./OPTIONS.iG).^OPTIONS.ExpoiG, 0, length(OPTIONS.iG), length(OPTIONS.iG)) ;
                AAt(OPTIONS.MEGChannel,OPTIONS.MEGChannel) = AAt(OPTIONS.MEGChannel,OPTIONS.MEGChannel) + temp*(OPTIONS.iG*OPTIONS.iG)*temp';  % next chunk of correlations
            else % no FF normalization
                AAt(OPTIONS.MEGChannel,OPTIONS.MEGChannel) = AAt(OPTIONS.MEGChannel,OPTIONS.MEGChannel) + temp*temp';  % next chunk of correlations
            end
        end

        clear temp OPTIONS.iG

        temp = read_gain(gainfile,OPTIONS.EEGChannel,ndx);
        if ~isempty(OPTIONS.EEGChannel) & ~isempty(temp)
            temp(find(isnan(temp))) = 0;
            if OPTIONS.FFNormalization
                OPTIONS.iG = sqrt(norcol(temp)');  % NORCOL computes the column norms to the SQUARE
                if (min(OPTIONS.iG(:)) == max(OPTIONS.iG(:))) & length(OPTIONS.iG) > 1 % as it happens when EEG channels stand for ECoG or EMG
                    OPTIONS.iG = eps;
                end

                OPTIONS.iG(OPTIONS.iG == 0) = min(OPTIONS.iG(OPTIONS.iG ~= 0));

                OPTIONS.iG = spdiags((1./OPTIONS.iG).^OPTIONS.ExpoiG, 0, length(OPTIONS.iG), length(OPTIONS.iG)) ;
                AAt(OPTIONS.EEGChannel,OPTIONS.EEGChannel) = AAt(OPTIONS.EEGChannel,OPTIONS.EEGChannel) + temp*(OPTIONS.iG*OPTIONS.iG)*temp';  % next chunk of correlations
            else
                AAt(OPTIONS.EEGChannel,OPTIONS.EEGChannel) = AAt(OPTIONS.EEGChannel,OPTIONS.EEGChannel) + temp*temp';  % next chunk of correlations
            end
        end

        clear temp OPTIONS.iG

    end % datatype

end % for each block of sources

varargout{1} = AAt;
varargout{2} = Gain_RowNorm;



% -----------------------------------------------------------------------------------------------------------------------
