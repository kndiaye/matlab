function spm_mask(P1,P2, thresh2)
% Masks Images.
% FORMAT spm_mask(P1,P2, thresh2)
% P1     - matrix of input image filenames from which
%          to compute the mask.
% P2     - matrix of input image filenames on which
%          to apply the mask.
% thresh2 - optional threshold(s) for defining the mask. If
%           * thresh2=[x] keeps values ABOVE x (same as spm_mask)
%           * thresh2=[x y] keeps masking values BETWEEN x and y (included)
%           * thresh2=[x x] keeps masking voxels EXACTLY equal to x 
%           * thresh2={x [y z] t} keeps values matching x, t, OR falling
%             between y and z (inclusive masking)
%
% The masked images are prepended with the prefix `m'.
%
% If any voxel in the series of images is zero (for data types without
% a floating point representation) or does not have a finite value (for
% floating point and double precision images), then that voxel is set to
% NaN or zero in all the images.  
%
% If a list of masking files is passed, then if necessary, the threshold is
% expanded to match the  length of this list. The resulting masking is then
% the INTERSECTION of all the (threshold-dependent) masks.
%
% Images sampled in different orientations and positions can be passed
% to the routine.  Providing the `.mat' files are correct, then these
% should be handled appropriately.
%_______________________________________________________________________
% @(#)spm_mask.m	2.12 John Ashburner 03/02/03

if nargin==0,
	P1=spm_get(Inf,'IMAGE','Images to compute mask from');
	P2=spm_get(Inf,'IMAGE','Images to apply mask to');
end;
if nargin==1,
	P2 = P1;
end;
thresh={0};
if nargin==3,
    thresh=thresh2;
    if not(iscell(thresh)) && isnumeric(thresh)
        % makes it backward compatible with spm_mask
        if size(thresh,2) == 1; thresh=[thresh repmat(Inf,size(thresh,1),1)]; end
        thresh=mat2cell(mat2cell(thresh, ones(size(thresh,1),1),2 ), size(thresh,1),1);
    elseif not(iscell(thresh{1}))
        thresh={thresh};
    end    
end;

V1=spm_vol(P1);
V2=spm_vol(P2);

m1=prod(size(V1));
m2=prod(size(V2));

if size(thresh,1)==1,
    thresh = repmat(thresh,m1,1);
end
if size(P1,1) ~= size(thresh,1),
    error('threshold input is wrong size.');
end;


% Create headers
VO=V2;
for i=1:m2,
	[pth,nm,xt,vr] = fileparts(deblank(VO(i).fname));
	%VO(i).fname   = fullfile(pth,['m' nm xt vr]);
	VO(i).fname    = ['m' nm '.img'];
	VO(i).descrip  = 'Masked';
	VO(i).mat      = VO(1).mat;
	VO(i).dim(1:3) = VO(1).dim(1:3);
end;
VO  = spm_create_vol(VO);
M   = VO(1).mat;
dim = VO(1).dim(1:3);

spm_progress_bar('Init',VO(1).dim(3),'Masking','planes completed')
for j=1:dim(3),

	msk = zeros(dim(1:2));
	Mi  = spm_matrix([0 0 j]);

	% Load slice j from all images
	for i=1:m1
		M1  = M\V1(i).mat\Mi;
		%if sum((M1(:)-Mi(:)).^2<eps) M1 = Mi; end;

		img = spm_slice_vol(V1(i),M1,dim(1:2),[0 NaN]);
		if nargin<3
			if ~spm_type(V1(i).dim(4),'nanrep'),
				msk = msk + (img~=0 & finite(img));
			else,
				msk = msk + finite(img);
			end;
		else,
            for v=1:length(thresh{i})
                switch length(thresh{i}{v})
                    case 0
                        msk = msk + (finite(img) & (~spm_type(V1(i).dim(4),'nanrep') || img~=0));
                    case 1
                        msk = msk + ((img==thresh{i}{v}) & finite(img));
                    case 2 
                        msk = msk + ((img>=thresh{i}{v}(1) & img<=thresh{i}{v}(2)) & finite(img));
                end
                    
            end
        end;
      
	end;

	msk = find(msk~=m1);

	% Write the images.
	for i=1:m2,
		M1       = M\V2(i).mat\Mi;
		img      = spm_slice_vol(V2(i),M1,dim(1:2),[1 0]);
		img(msk) = NaN;
        VO(i)    = spm_write_plane(VO(i),img,j); 
%         if numel(msk)<numel(img)
%             fig=figure;imagesc(img);colorbar;drawnow;
%             pause(.1);    
%             close(fig);
%         end     
	end;

	spm_progress_bar('Set',j);
end;
VO = spm_close_vol(VO);
spm_progress_bar('Clear');
return;
