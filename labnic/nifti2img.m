function varargout = nifti2ana(P)
% NIFTI2ANA converts images from nifti to analyze format readable in SPM2
%    V = NIFTI2ANA(P) converts files that are in SPM5's nifti format to the
%    analyze format that was readable by SPM2. This allows one to use files
%    processed in SPM5 to be analyzed in SPM2.
%
%    P are the filenames to be converted. If P is empty the user is
%    prompted to select the files.
%
%    V is a structure array of mapped volumes. This can be used to read the
%    new files or discarded.
%
%    SPM5 must be in the Matlab path.
%
%    The converted files are prepended with 'n2a_'
%
%    The program REQUIRES SPM5 image files (either .nii or .img) as input,
%    and outputs SPM2 compatible analyze-type files. This program is not
%    for converting SPM5 .nii to SPM5 .img files. To do that simply read
%    in the data, change the filename to have a .img extension, and write
%    out the new file. For example:
%       v          = spm_vol('my_file_name.nii');
%       img        = spm_read_vols(v);
%       vnew       = v;
%       vnew.fname = [vnew.fname(1:end-3), 'img'];
%       vnew       = spm_create_vol(vnew);
%       vnew       = spm_write_vol(vnew,img);
%
% Author: Darren Gitelman
% $Id: nifti2ana.m,v 1.3 2008-07-22 13:06:43-05 drg Exp drg $
% updated 2010-07-14 by drg.

% Get image filenames if none are provided
if nargin < 1
    P = spm_select(Inf,'image','Select images to convert');
end
if isempty(P)
    disp('No files selected. Aborting conversion.')
    return;
end

% Map the volumes using SPM5 file handling tools
fprintf('Reading SPM5 NIFTI volume headers..');
Vin = spm_vol(deblank(P));
fprintf('Done\n');
fprintf('There are %i files to be converted.\n',numel(Vin));

Vout = struct('fname'  , '',...
    'dim'    , [],...
    'mat'    , [],...
    'pinfo'  , [],...
    'descrip', '',...
    'n'      , [],...
    'private', []);
V = Vout;
% Convert the volume structures to be analyze compatible
fprintf('Creating SPM2-compatible headers..')

for i = 1:numel(Vin)
    fprintf('%5i',i);
    [tmppth tmpfn tmpext] = fileparts(Vin(i).fname);
    dt    = Vin(i).dt(1);
    tmpfn = ['n2a_',tmpfn];
    Vtmp.fname   = fullfile(tmppth,[tmpfn,tmpext]);
    Vtmp.dim     = [Vin(i).dim dt];
    Vtmp.mat     = Vin(i).mat;
    if spm_flip_analyze_images
        fprintf(' : Flipping image L/R\n')
        Vtmp.mat = spm_matrix([0 0 0 0 0 0 -1 1 1 0 0 0])*Vtmp.mat;
        fprintf('Creating SPM2-compatible headers..%5i',i)
    end
    Vtmp.pinfo   = Vin(i).pinfo;
    Vtmp.descrip = ['nifti2analyze converted: ',Vin(i).descrip];

    dtype = Vin(i).private.dat.dtype;

    % must pass the dtype to figure out if endianness is swapped.
    Vout(i)= my_spm2_create_vol(Vtmp,'noopen',dtype);
    fprintf(sprintf(repmat('\b',1,5)))
end
fprintf('Done\n')

fprintf('Writing SPM2-compatible image files..')
for i = 1:numel(Vout)
    fprintf('%5i',i);
    y = spm_read_vols(Vin(i));
    V(i) = my_spm2_write_vol(Vout(i),y,dtype);
    fprintf(sprintf(repmat('\b',1,5)))
end
fprintf('All Done!\n')
if nargout == 1
    varargout{1} = V;
end

%_______________________________________________________________________
%_______________________________________________________________________
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     THESE FUNCTIONS COME FROM THE SPM2 VERSION OF SPM_CREATE_VOL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function V = my_spm2_create_vol(V,varargin)
% Create an image file.
% FORMAT Vo = spm_create_vol(Vi,['noopen'])
% Vi   - data structure containing image information.
%      - see spm_vol for a description.
% 'noopen' - optional flag to say "don't open/create the image file".
% Vo   - data structure after modification for writing.
% varargin can now have 2 arguments, 'noopen' and the dtype.
%_______________________________________________________________________
% @(#)spm_create_vol.m	2.14 John Ashburner 03/07/31
for i=1:numel(V)
    if nargin>1,
        v = my_spm2_internal_create_vol(V(i),varargin{:});
    else
        v = my_spm2_internal_create_vol(V(i));
    end;
    f = fieldnames(v);
    for j=1:size(f,1),
        %eval(['V(i).' f{j} ' = v.' f{j} ';']);
        V = setfield(V,{i},f{j},getfield(v,f{j}));
    end;
end;
return;
%_______________________________________________________________________
%_______________________________________________________________________
function V = my_spm2_internal_create_vol(V,varargin)
if ~isfield(V,'n') || isempty(V.n)
    V.n  = 1;
end;

if ~isfield(V,'descrip') || isempty(V.descrip)
    V.descrip = 'SPM2 compatible';
end;
V.private = struct('hdr',[]);

% Orientation etc...
M  = V.mat;
if spm_flip_analyze_images, M = diag([-1 1 1 1])*M; end;
vx = sqrt(sum(M(1:3,1:3).^2));
if det(M(1:3,1:3))<0, vx(1) = -vx(1); end;
origin = M\[0 0 0 1]';
origin = round(origin(1:3));

[pth nam] = fileparts(V.fname);
fname         = fullfile(pth,[nam, '.hdr']);
try
    [hdr swapped] = my_spm2_spm_read_hdr(fname);
catch
    warning(['Could not read "' fname '"']);
    swapped = 0;
    hdr     = [];
end;

if ~isempty(hdr) && (hdr.dime.dim(5)>1 || V.n>1),
    % cannot simply overwrite the header

    hdr.dime.dim(5) = max(V.n,hdr.dime.dim(5));
    if any(V.dim(1:3) ~= hdr.dime.dim(2:4))
        error('Incompatible image dimensions');
    end;

    if sum((vx-hdr.dime.pixdim(2:4)).^2)>1e-6,
        error('Incompatible voxel sizes');
    end;

    V.dim(4) = spm_type(spm_type(hdr.dime.datatype));
    mach     = 'native';
    if swapped,
        V.dim(4) = V.dim(4)*256;
        if spm_platform('bigend'),
            mach = 'ieee-le';
        else
            mach = 'ieee-be';
        end;
    end;

    if isfinite(hdr.dime.funused1) && hdr.dime.funused1
        scal  = hdr.dime.funused1;
        if isfinite(hdr.dime.funused2),
            dcoff = hdr.dime.funused2;
        else
            dcoff = 0;
        end;
    else
        if hdr.dime.glmax-hdr.dime.glmin && hdr.dime.cal_max-hdr.dime.cal_min
            scal  = (hdr.dime.cal_max-hdr.dime.cal_min)/(hdr.dime.glmax-hdr.dime.glmin);
            dcoff = hdr.dime.cal_min - scal*hdr.dime.glmin;
        else
            scal  = 1;
            dcoff = 0;
            warning(['Assuming a scalefactor of 1 for "' V.fname '".']);
        end;
    end;
    V.pinfo(1:2)    = [scal dcoff]';
    V.private.hdr   = hdr;
else

    V.private.hdr = my_spm2_create_defaults;

    my_endianess = spm_platform('bigend');
    if nargin == 3
        dtype = varargin{2};
    elseif nargin ==2
        dtype = varargin{1};
    end

    if my_endianess && ~isempty(findstr(dtype,'BE')) || ...
            ~my_endianess && isempty(findstr(dtype,'BE'))
        swapped = 0;
    else
        swapped = 1;
    end
    dt      = spm_type(spm_type(V.dim(4)));
    if any(dt == [128+2 128+4 128+8]),
        % Convert to a form that Analyze will support
        dt  = dt - 128;
    end;
    V.dim(4) = dt;
    mach     = 'native';
    if swapped
        V.dim(4) = V.dim(4)*256;
        if spm_platform('bigend'),
            mach = 'ieee-le';
        else
            mach = 'ieee-be';
        end;
    end;
    V.private.hdr.dime.datatype    = dt;
    V.private.hdr.dime.bitpix      = spm_type(dt,'bits');

    if spm_type(dt,'intt'),

        V.private.hdr.dime.glmax    = spm_type(dt,'maxval');
        V.private.hdr.dime.glmin    = spm_type(dt,'minval');

        if 0, % Allow DC offset
            V.private.hdr.dime.cal_max  = max(V.private.hdr.dime.glmax*V.pinfo(1,:) + V.pinfo(2,:));
            V.private.hdr.dime.cal_min  = min(V.private.hdr.dime.glmin*V.pinfo(1,:) + V.pinfo(2,:));
            V.private.hdr.dime.funused1 = 0;
            scal                = (V.private.hdr.dime.cal_max - V.private.hdr.dime.cal_min)/...
                (V.private.hdr.dime.glmax   - V.private.hdr.dime.glmin);
            dcoff               =  V.private.hdr.dime.cal_min - V.private.hdr.dime.glmin*scal;
            V.pinfo             = [scal dcoff 0]';
        else % Don't allow DC offset
            cal_max                     = max(V.private.hdr.dime.glmax*V.pinfo(1,:) + V.pinfo(2,:));
            cal_min                     = min(V.private.hdr.dime.glmin*V.pinfo(1,:) + V.pinfo(2,:));
            V.private.hdr.dime.funused1 = cal_max/V.private.hdr.dime.glmax;
            if V.private.hdr.dime.glmin,
                V.private.hdr.dime.funused1 = max(V.private.hdr.dime.funused1,...
                    cal_min/V.private.hdr.dime.glmin);
            end;
            V.private.hdr.dime.cal_max  = V.private.hdr.dime.glmax*V.private.hdr.dime.funused1;
            V.private.hdr.dime.cal_min  = V.private.hdr.dime.glmin*V.private.hdr.dime.funused1;
            V.pinfo             = [V.private.hdr.dime.funused1 0 0]';
        end;
    else
        V.private.hdr.dime.glmax    = 1;
        V.private.hdr.dime.glmin    = 0;
        V.private.hdr.dime.cal_max  = 1;
        V.private.hdr.dime.cal_min  = 0;
        V.private.hdr.dime.funused1 = 1;
    end;

    V.private.hdr.dime.pixdim(2:4) = vx;
    V.private.hdr.dime.dim(2:4)    = V.dim(1:3);
    V.private.hdr.dime.dim(5)      = V.n;
    V.private.hdr.hist.origin(1:3) = origin;

    d                              = 1:min([length(V.descrip) 79]);
    V.private.hdr.hist.descrip     = char(zeros(1,80));
    V.private.hdr.hist.descrip(d)  = V.descrip(d);
    V.private.hdr.hk.db_name       = char(zeros(1,18));
    [pth, nam]                  = fileparts(V.fname);
    d                              = 1:min([length(nam) 17]);
    V.private.hdr.hk.db_name(d)    = nam(d);
end;

V.pinfo(3) = prod(V.private.hdr.dime.dim(2:4))*V.private.hdr.dime.bitpix/8*(V.n-1);

fid           = fopen(fname,'w',mach);
if (fid == -1),
    error(['Error opening ' fname '. Check that you have write permission.']);
end;

my_spm2_write_hk(fid,V.private.hdr.hk);
my_spm2_write_dime(fid,V.private.hdr.dime);
my_spm2_write_hist(fid,V.private.hdr.hist);
fclose(fid);

fname = fullfile(pth,[nam, '.mat']);
off   = -vx'.*origin;
mt    = [vx(1) 0 0 off(1) ; 0 vx(2) 0 off(2) ; 0 0 vx(3) off(3) ; 0 0 0 1];
if spm_flip_analyze_images, mt = diag([-1 1 1 1])*mt; end;

if sum((V.mat(:) - mt(:)).*(V.mat(:) - mt(:))) > eps*eps*12 || exist(fname,'file')==2
    if exist(fname,'file')==2,
        clear mat
        str = load(fname);
        if isfield(str,'mat'),
            mat = str.mat;
        elseif isfield(str,'M'),
            mat = str.M;
            if spm_flip_analyze_images,
                for i=1:size(mat,3),
                    mat(:,:,i) = diag([-1 1 1 1])*mat(:,:,i);
                end;
            end;
        end;
        mat(:,:,V.n) = V.mat;
        mat          = my_spm2_fill_empty(mat,mt);
        M = mat(:,:,1);
        if spm_flip_analyze_images
            M = diag([-1 1 1 1])*M;
        end;
        try
            save(fname,'mat','M','-append');
        catch    % Mat-file was probably Matlab 4
            save(fname,'mat','M');
        end;
    else
        clear mat
        mat(:,:,V.n) = V.mat;
        mat          = my_spm2_fill_empty(mat,mt);
        M = mat(:,:,1);
        if spm_flip_analyze_images
            M = diag([-1 1 1 1])*M;
        end;
        save(fname,'mat','M');
    end;
end;

if nargin==1 || ~strcmp(varargin{1},'noopen')
    fname         = fullfile(pth,[nam, '.img']);
    V.private.fid = fopen(fname,'r+',mach);
    if (V.private.fid == -1),
        V.private.fid     = fopen(fname,'w',mach);
        if (V.private.fid == -1),
            error(['Error opening ' fname '. Check that you have write permission.']);
        end;
    end;
end;
return;
%_______________________________________________________________________
%_______________________________________________________________________
function Mo = my_spm2_fill_empty(Mo,Mfill)
todo = [];
for i=1:size(Mo,3)
    if ~any(any(Mo(:,:,i))),
        todo = [todo i];
    end;
end;
if ~isempty(todo)
    for i=1:length(todo),
        Mo(:,:,todo(i)) = Mfill;
    end;
end;
return;
%_______________________________________________________________________
%_______________________________________________________________________
function my_spm2_write_hk(fid,hk)
% write (struct) header_key
%-----------------------------------------------------------------------
fseek(fid,0,'bof');
fwrite(fid,hk.sizeof_hdr,	'int32');
fwrite(fid,hk.data_type,	'char' );
fwrite(fid,hk.db_name,		'char' );
fwrite(fid,hk.extents,		'int32');
fwrite(fid,hk.session_error,'int16');
fwrite(fid,hk.regular,		'char' );
if fwrite(fid,hk.hkey_un0,	'char' )~= 1,
    error(['Error writing '  fopen(fid) '. Check your disk space.']);
end;
return;
%_______________________________________________________________________
%_______________________________________________________________________
function my_spm2_write_dime(fid,dime)
% write (struct) image_dimension
%-----------------------------------------------------------------------
fseek(fid,40,'bof');
fwrite(fid,dime.dim,		'int16');
fwrite(fid,dime.vox_units,	'uchar' );
fwrite(fid,dime.cal_units,	'uchar' );
fwrite(fid,dime.unused1,	'int16' );
fwrite(fid,dime.datatype,	'int16');
fwrite(fid,dime.bitpix,		'int16');
fwrite(fid,dime.dim_un0,	'int16');
fwrite(fid,dime.pixdim,		'float');
fwrite(fid,dime.vox_offset,	'float');
fwrite(fid,dime.funused1,	'float');
fwrite(fid,dime.funused2,	'float');
fwrite(fid,dime.funused2,	'float');
fwrite(fid,dime.cal_max,	'float');
fwrite(fid,dime.cal_min,	'float');
fwrite(fid,dime.compressed,	'int32');
fwrite(fid,dime.verified,	'int32');
fwrite(fid,dime.glmax,		'int32');
if fwrite(fid,dime.glmin,		'int32')~=1,
    error(['Error writing '  fopen(fid) '. Check your disk space.']);
end;
return;
%_______________________________________________________________________
%_______________________________________________________________________
function my_spm2_write_hist(fid,hist)
% write (struct) data_history
%-----------------------------------------------------------------------
fseek(fid,148,'bof');
fwrite(fid,hist.descrip,	'uchar');
fwrite(fid,hist.aux_file,	'uchar');
fwrite(fid,hist.orient,		'uchar');
fwrite(fid,hist.origin,		'int16');
fwrite(fid,hist.generated,	'uchar');
fwrite(fid,hist.scannum,	'uchar');
fwrite(fid,hist.patient_id,	'uchar');
fwrite(fid,hist.exp_date,	'uchar');
fwrite(fid,hist.exp_time,	'uchar');
fwrite(fid,hist.hist_un0,	'uchar');
fwrite(fid,hist.views,		'int32');
fwrite(fid,hist.vols_added,	'int32');
fwrite(fid,hist.start_field,'int32');
fwrite(fid,hist.field_skip,	'int32');
fwrite(fid,hist.omax,		'int32');
fwrite(fid,hist.omin,		'int32');
fwrite(fid,hist.smax,		'int32');
if fwrite(fid,hist.smin,	'int32')~=1,
    error(['Error writing '  fopen(fid) '. Check your disk space.']);
end;
return;
%_______________________________________________________________________
%_______________________________________________________________________
function hdr = my_spm2_create_defaults
hk.sizeof_hdr	= 348;
hk.data_type	= ['dsr      ' 0];
hk.db_name		= char(zeros(1,18));
hk.extents		= 0;
hk.session_error= 0;
hk.regular		= 'r';
hk.hkey_un0		= 0;

dime.dim		= [4 0 0 0 1 0 0 0];
dime.vox_units	= ['mm ' 0];
dime.cal_units	= char(zeros(1,8));
dime.unused1	= 0;
dime.datatype	= -1;
dime.bitpix		= 0;
dime.dim_un0	= 0;
dime.pixdim		= [0 1 1 1 1 0 0 0];
dime.vox_offset	= 0;
dime.funused1	= 1;
dime.funused2	= 0;
dime.funused3	= 0;
dime.cal_max	= 1;
dime.cal_min	= 0;
dime.compressed	= 0;
dime.verified	= 0;
dime.glmax		= 1;
dime.glmin		= 0;

hist.descrip	= char(zeros(1,80));
hist.descrip(1:length('SPM2 compatible')) = 'SPM2 compatible';
hist.aux_file	= char(zeros(1,24));
hist.orient		= char(0);
hist.origin		= [0 0 0  0 0];
hist.generated	= char(zeros(1,10));
hist.scannum	= char(zeros(1,10));
hist.patient_id	= char(zeros(1,10));
hist.exp_date	= char(zeros(1,10));
hist.exp_time	= char(zeros(1,10));
hist.hist_un0	= char(zeros(1,3));
hist.generated(1:5)	= 'today';
hist.views		= 0;
hist.vols_added	= 0;
hist.start_field= 0;
hist.field_skip	= 0;
hist.omax		= 0;
hist.omin		= 0;
hist.smax		= 0;
hist.smin		= 0;

hdr.hk   = hk;
hdr.dime = dime;
hdr.hist = hist;
return;
%_______________________________________________________________________
%_______________________________________________________________________
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      THESE FUNCTIONS COME FROM THE SPM2 VERSION OF SPM_READ_HDR
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [hdr,otherendian] = my_spm2_spm_read_hdr(fname)
% Read (SPM customised) Analyze header
% FORMAT [hdr,otherendian] = spm_read_hdr(fname)
% fname       - .hdr filename
% hdr         - structure containing Analyze header
% otherendian - byte swapping necessary flag
%_______________________________________________________________________
% @(#)spm_read_hdr.m	2.2 John Ashburner 03/07/17

fid         = fopen(fname,'r','native');
otherendian = 0;
if (fid > 0)
    dime = my_spm2_read_dime(fid);
    if dime.dim(1)<0 || dime.dim(1)>15  % Appears to be other-endian
        % Re-open other-endian
        fclose(fid);
        if spm_platform('bigend'), fid = fopen(fname,'r','ieee-le');
        else                      fid = fopen(fname,'r','ieee-be'); end;
        otherendian = 1;
        dime = my_spm2_read_dime(fid);
    end;
    hk       = my_spm2_read_hk(fid);
    hist     = my_spm2_read_hist(fid);
    hdr.hk   = hk;
    hdr.dime = dime;
    hdr.hist = hist;
    fclose(fid);
else
    hdr = [];
    otherendian = NaN;
    %error(['Problem opening header file (' fopen(fid) ').']);
end;
return;
%_______________________________________________________________________
%_______________________________________________________________________
function hk = my_spm2_read_hk(fid)
% read (struct) header_key
%-----------------------------------------------------------------------
fseek(fid,0,'bof');
hk.sizeof_hdr 		= fread(fid,1,'int32');
hk.data_type  		= my_spm2_mysetstr(fread(fid,10,'uchar'))';
hk.db_name    		= my_spm2_mysetstr(fread(fid,18,'uchar'))';
hk.extents    		= fread(fid,1,'int32');
hk.session_error	= fread(fid,1,'int16');
hk.regular			= my_spm2_mysetstr(fread(fid,1,'uchar'))';
hk.hkey_un0			= my_spm2_mysetstr(fread(fid,1,'uchar'))';
if isempty(hk.hkey_un0)
    error(['Problem reading "hk" of header file (' fopen(fid) ').']);
end;
return;
%_______________________________________________________________________
%_______________________________________________________________________
function dime = my_spm2_read_dime(fid)
% read (struct) image_dimension
%-----------------------------------------------------------------------
fseek(fid,40,'bof');
dime.dim		= fread(fid,8,'int16')';
dime.vox_units	= my_spm2_mysetstr(fread(fid,4,'uchar'))';
dime.cal_units	= my_spm2_mysetstr(fread(fid,8,'uchar'))';
dime.unused1	= fread(fid,1,'int16');
dime.datatype	= fread(fid,1,'int16');
dime.bitpix		= fread(fid,1,'int16');
dime.dim_un0	= fread(fid,1,'int16');
dime.pixdim		= fread(fid,8,'float')';
dime.vox_offset	= fread(fid,1,'float');
dime.funused1	= fread(fid,1,'float');
dime.funused2	= fread(fid,1,'float');
dime.funused3	= fread(fid,1,'float');
dime.cal_max	= fread(fid,1,'float');
dime.cal_min	= fread(fid,1,'float');
dime.compressed	= fread(fid,1,'int32');
dime.verified	= fread(fid,1,'int32');
dime.glmax		= fread(fid,1,'int32');
dime.glmin		= fread(fid,1,'int32');
if isempty(dime.glmin)
    error(['Problem reading "dime" of header file (' fopen(fid) ').']);
end;
return;
%_______________________________________________________________________
%_______________________________________________________________________
function hist = my_spm2_read_hist(fid)
% read (struct) data_history
%-----------------------------------------------------------------------
fseek(fid,148,'bof');
hist.descrip	= my_spm2_mysetstr(fread(fid,80,'uchar'))';
hist.aux_file	= my_spm2_mysetstr(fread(fid,24,'uchar'))';
hist.orient		= fread(fid,1,'uchar');
hist.origin		= fread(fid,5,'int16')';
hist.generated	= my_spm2_mysetstr(fread(fid,10,'uchar'))';
hist.scannum	= my_spm2_mysetstr(fread(fid,10,'uchar'))';
hist.patient_id	= my_spm2_mysetstr(fread(fid,10,'uchar'))';
hist.exp_date	= my_spm2_mysetstr(fread(fid,10,'uchar'))';
hist.exp_time	= my_spm2_mysetstr(fread(fid,10,'uchar'))';
hist.hist_un0	= my_spm2_mysetstr(fread(fid,3,'uchar'))';
hist.views		= fread(fid,1,'int32');
hist.vols_added	= fread(fid,1,'int32');
hist.start_field= fread(fid,1,'int32');
hist.field_skip	= fread(fid,1,'int32');
hist.omax		= fread(fid,1,'int32');
hist.omin		= fread(fid,1,'int32');
hist.smax		= fread(fid,1,'int32');
hist.smin		= fread(fid,1,'int32');
if isempty(hist.smin)
    error(['Problem reading "hist" of header file (' fopen(fid) ').']);
end;
return;
%_______________________________________________________________________
%_______________________________________________________________________
function out = my_spm2_mysetstr(in)
tmp = find(in == 0);
tmp = min([min(tmp) length(in)]);
out = char([in(1:tmp)' zeros(1,length(in)-(tmp))])';
return;
%_______________________________________________________________________
%_______________________________________________________________________
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     THESE FUNCTIONS COME FROM THE SPM2 VERSION OF SPM_WRITE_VOL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function V = my_spm2_write_vol(V,Y,dtype)
% Write an image volume to disk, setting scales and offsets as appropriate
% FORMAT V = my_spm2_write_vol(V,Y)
% V (input)  - a structure containing image volume information (see spm_vol)
% Y          - a one, two or three dimensional matrix containing the image voxels
% V (output) - data structure after modification for writing.
%_______________________________________________________________________
% @(#)spm_write_vol.m	2.9 John Ashburner 03/02/26

if ndims(Y)>3, error('Can only handle a maximum of 3 dimensions.'), end

if ~isfield(V,'pinfo'), V.pinfo = [1,0,0]'; end

dim = [size(Y) 1 1 1];
if ~all(dim(1:3) == V.dim(1:3)) || (size(V.pinfo,2)~=1 && size(V.pinfo,2)~=dim(3)),
    error('Incompatible dimensions.');
end


% Set scalefactors and offsets
%-----------------------------------------------------------------------
dt = V.dim(4); if dt>256, dt = dt/256; end;
if any(dt == [128+2 128+4 128+8]),
    % Convert to a form that Analyze will support
    dt = dt - 128;
end;
s            = find(dt == [2 4 8 128+2 128+4 128+8]);
dmnmx        = [0 -2^15 -2^31 -2^7 0 0 ; 2^8-1 2^15-1 2^31-1 2^7-1 2^16 2^32];
dmnmx        = dmnmx(:,s);
V.pinfo(1,:) = 1;
V.pinfo(2,:) = 0;
mxs          = zeros(dim(3),1)+NaN;
mns          = zeros(dim(3),1)+NaN;
if ~isempty(s),
    for p=1:dim(3),
        tmp    = double(Y(:,:,p));
        tmp    = tmp(isfinite(tmp));
        if ~isempty(tmp),
            mxs(p) = max(tmp);
            mns(p) = min(tmp);
        end;
    end;

    if size(V.pinfo,2) ~= 1
        for p=1:dim(3),
            mx = mxs(p);
            mn = mns(p);
            if ~isfinite(mx), mx = 0; end;
            if ~isfinite(mn), mn = 0; end;
            if mx~=mn,
                V.pinfo(1,p) = (mx-mn)/(dmnmx(2)-dmnmx(1));
                V.pinfo(2,p) = ...
                    (dmnmx(2)*mn-dmnmx(1)*mx)/(dmnmx(2)-dmnmx(1));
            else
                V.pinfo(1,p) = 0;
                V.pinfo(2,p) = mx;
            end;
        end;
    else
        mx = max(mxs(isfinite(mxs)));
        mn = min(mns(isfinite(mns)));
        if isempty(mx), mx = 0; end;
        if isempty(mn), mn = 0; end;
        if mx~=mn
            V.pinfo(1,1) = (mx-mn)/(dmnmx(2)-dmnmx(1));
            V.pinfo(2,1) = (dmnmx(2)*mn-dmnmx(1)*mx)/(dmnmx(2)-dmnmx(1));
        else
            V.pinfo(1,1) = 0;
            V.pinfo(2,1) = mx;
        end;
    end;
end;

%-Create and write image
%-----------------------------------------------------------------------
V = my_spm2_create_vol(V,dtype);

for p=1:V.dim(3),
    V = my_spm2_write_plane(V,Y(:,:,p),p);
end;
V = my_spm2_close_vol(V);
%_______________________________________________________________________
%_______________________________________________________________________
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     THESE FUNCTIONS COME FROM THE SPM2 VERSION OF SPM_WRITE_PLANE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function V = my_spm2_write_plane(V,A,p)
% Write a transverse plane of image data.
% FORMAT V = my_spm2_write_plane(V,A,p)
% V   - data structure containing image information.
%       - see spm_vol for a description.
% A   - the two dimensional image to write.
% p   - the plane number (beginning from 1).
%
% VO  - (possibly) modified data structure containing image information.
%       It is possible that future versions of spm_write_plane may
%       modify scalefactors (for example).
%
%_______________________________________________________________________
% @(#)spm_write_plane.m	2.19 John Ashburner 03/07/16

if any(V.dim(1:2) ~= size(A)), error('Incompatible image dimensions');      end;
if p>V.dim(3),                 error('Plane number too high');              end;

% Write Analyze image by default
V = my_spm2_write_analyze_plane(V,A,p);
return;
%_______________________________________________________________________

%_______________________________________________________________________
function V = my_spm2_write_analyze_plane(V,A,p)

types   = [    2      4      8   16   64   130    132    136,   512   1024   2048 4096 16384 33280  33792  34816];
maxval  = [2^8-1 2^15-1 2^31-1  Inf  Inf 2^7-1 2^16-1 2^32-1, 2^8-1 2^15-1 2^31-1  Inf   Inf 2^8-1 2^16-1 2^32-1];
minval  = [    0  -2^15  -2^31 -Inf -Inf  -2^7      0      0,     0  -2^15  -2^31 -Inf  -Inf  -2^7      0      0];
intt    = [    1      1      1    0    0     1      1      1,     1      1      1    0     0     1      1      1];
prec = str2mat('uint8','int16','int32','float','double','int8','uint16','uint32','uint8','int16','int32','float','double','int8','uint16','uint32');
swapped = [    0      0      0    0    0     0      0      0,     1      1      1    1     1     1      1      1];
bits    = [    8     16     32   32   64     8     16     32,     8     16     32   32    64     8     16     32];

dt      = find(types==V.dim(4));
if isempty(dt), error('Unknown datatype'); end;

A = double(A);

% Rescale to fit appropriate range
if intt(dt),
    A(isnan(A)) = 0;
    mxv         = maxval(dt);
    mnv         = minval(dt);
    A           = round(A*(1/V.pinfo(1)) - V.pinfo(2));
    A(A > mxv)  = mxv;
    A(A < mnv)  = mnv;
end;

[pth,nam] = fileparts(V.fname);
fname     = fullfile(pth,[nam, '.img']);
if ~isfield(V,'private') || ~isfield(V.private,'fid') || isempty(V.private.fid)
    mach = 'native';
    if swapped(dt)
        if spm_platform('bigend')
            mach = 'ieee-le';
        else
            mach = 'ieee-be';
        end;
    end;
    fid       = fopen(fname,'r+',mach);
    if fid == -1
        fid   = fopen(fname,'w',mach);
        if fid == -1
            error(['Error opening ' fname '. Check that you have write permission.']);
        end;
    end;
else
    if isempty(fopen(V.private.fid)),
        mach = 'native';
        if swapped(dt)
            if spm_platform('bigend')
                mach = 'ieee-le';
            else
                mach = 'ieee-be';
            end;
        end;
        V.private.fid = fopen(fname,'r+',mach);
        if V.private.fid == -1
            error(['Error opening ' fname '. Check that you have write permission.']);
        end;
    end;
    fid = V.private.fid;
end;

% Seek to the appropriate offset
datasize = bits(dt)/8;
off   = (p-1)*datasize*prod(V.dim(1:2)) + V.pinfo(3,1);
fseek(fid,0,'bof'); % A bug in Matlab 6.5 means that a rewind is needed
if fseek(fid,off,'bof')==-1,
    % Need this because fseek in Matlab does not seek past the EOF
    fseek(fid,0,'bof'); % A bug in Matlab 6.5 means that a rewind is needed
    fseek(fid,0,'eof');
    curr_off = ftell(fid);
    blanks   = zeros(off-curr_off,1);
    if fwrite(fid,blanks,'uchar') ~= numel(blanks)
        my_spm2_write_error_message(V.fname);
        error(['Error writing ' V.fname '.']);
    end;
    fseek(fid,0,'bof'); % A bug in Matlab 6.5 means that a rewind is needed
    if fseek(fid,off,'bof') == -1,
        my_spm2_write_error_message(V.fname);
        error(['Error writing ' V.fname '.']);
    end;
end;

if fwrite(fid,A,deblank(prec(dt,:))) ~= numel(A)
    my_spm2_write_error_message(V.fname);
    error(['Error writing ' V.fname '.']);
end;

if ~isfield(V,'private') || ~isfield(V.private,'fid') || isempty(V.private.fid), fclose(fid); end;

return;
%_______________________________________________________________________

%_______________________________________________________________________
function my_spm2_write_error_message(q)
str = {...
    'Error writing:',...
    ' ',...
    ['        ',spm_str_manip(q,'k40d')],...
    ' ',...
    'Check disk space / disk quota.'};
spm('alert*',str,mfilename,sqrt(-1));

return;
%_______________________________________________________________________
%_______________________________________________________________________
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     THIS FUNCTION COMES FROM THE SPM2 VERSION OF SPM_CLOSE_VOL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function V = my_spm2_close_vol(V)
% Close image volume
% See: spm_create_vol and spm_write_plane.
%_______________________________________________________________________
% @(#)spm_close_vol.m	2.4 John Ashburner 02/08/16
for i=1:numel(V),
    if isfield(V,'private') && isfield(V(i).private,'fid') && ~isempty(V(i).private.fid),
        if ~isempty(fopen(V(i).private.fid)),
            fclose(V(i).private.fid);
        end;
        V(i).private = rmfield(V(i).private,'fid');
    end;
end;