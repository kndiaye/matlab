function [mrk]=read_mrk(mrkfile)
%read_mrk - reads .MRK marker file (Cartool)

ascii=1;

if ascii
    mrk.Filename = mrkfile;
    mrk.Name=textread(mrkfile, '%s', 1);
    [mrk.Position mrk.To mrk.Type]=textread(mrkfile, '%d %d %s', 'headerlines',1);
    
else
    fid=fopen('Waridel\Alan_UG.EEG.MRK', 'r')
    % struct mrkheader { 
    %       char magic[4];      // always 'TL01'
    %   } mrkheader; // size 4
    magic=char(fread(fid,4,'char')');
    
    % And the format for a single marker is:
    % struct onemrk { 
    %       long   Position;    // from this TF
    %       long   To;          // to this TF
    %       ushort Code;        // trigger code
    %       ushort Type;        // should always be 0x2 for a marker
    %       ushort Dummy;       // not used, for the user
    %       char   Name[6];     // name of the tag
    %   } onemrk;   // size 20
    mrk.Position=fread(fid,1,'uint32');
    mrk.To=fread(fid,1,'uint32');
    mrk.Type=fread(fid,1,'uint16');
    mrk.Dummy=fread(fid,1,'uint16');
    mrk.Name=char(fread(fid,6,'char'));
    fclose(fid)
end