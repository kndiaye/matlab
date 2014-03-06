function [K]=read_is(seffile)
%read_is() - reads IS inverse solution file (Cartool)
%   [K]=read_is(isfile)
%   K is the transposed inverse matrix [M electrodes]-by-[N sources]
%   or possibly, if vectorial, [M electrodes]-by-[N sources]-by-3

fid=fopen(seffile, 'rb');
tag=char(fread(fid,4,'char')');
switch (tag)
    case 'IS01'
        datatype='float32';
    case 'IS02'
        datatype='double';
    otherwise
        error('Unknown tag: %s', tag)
end
ne=fread(fid,1,'int32');
ns=fread(fid,1,'int32');
scalar=double(fread(fid,1,'char'));
K=fread(fid,ne*ns*(3 - 2*scalar),datatype);
K=reshape(K,[ne ns (3 - 2*scalar) ]);

% We keep the transposed inverse matrix.
% if scalar
%     K=transpose(K);
% else
%    K=permute(K, [2 3 1]);
% end
