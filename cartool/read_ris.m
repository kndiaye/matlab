function [R,SF]=read_ris(risfile)
%read_ris() - reads RIS result of inverse solution file (Cartool)
%   [R,SF]=read_ris(risfile)
%   R is the values 
%   FS ssampling frequency
fid=fopen(risfile, 'rb');
tag=char(fread(fid,4,'char')');
switch (tag)
    case 'RI01'
    otherwise
        warning('Unknown tag in file header: %s', tag)
end

ns=fread(fid,1,'int32');
nt=fread(fid,1,'int32');
SF=fread(fid,1,'float32');
isinversescalar=double(fread(fid,1,'char'));
K=fread(fid,ns*(3 - 2*isinversescalar)*nt,datatype);
K=reshape(K,[ns*(3 - 2*isinversescalar) nt]);
K=transpose(K);
K=reshape(K,[nt ns (3 - 2*isinversescalar) ]);

% We keep the transposed inverse matrix.
% if scalar
%     K=transpose(K);
% else
%    K=permute(K, [2 3 1]);
% end
