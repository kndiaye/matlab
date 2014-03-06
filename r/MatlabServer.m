% Requires:
% Java 1.x
% InputStreamByteWrapper.class from InputStreamByteWrapper.java

import java.io.*;
import java.net.*;


if (exist('server'))
  close(server); 
  clear server;
end
if (exist('is'))
  close(is);
  clear is;
end
if (exist('os'))
  close(os);
  clear os;
end

fprintf(1, '----------------------\n');
fprintf(1, 'Matlab server started!\n');
fprintf(1, '----------------------\n');

% Try to open a server socket on port 9999
% Note that we can't choose a port less than 1023 if we are not
% privileged users (root)
port = 9999;

server = ServerSocket(port);
fprintf(1, 'Server socket created.\n');


% Create a socket object from the ServerSocket to listen and accept
% connections.
% Open input and output streams

% Wait for the client to connect
clientSocket = accept(server);

fprintf(1, 'Connected to client.\n');

% ...client connected.
is = DataInputStream(getInputStream(clientSocket));
%is = BufferedReader(InputStreamReader(is0));
os = DataOutputStream(getOutputStream(clientSocket));

% Commands
commands = {'eval', 'send', 'receive', 'send-remote', 'receive-remote', 'echo'};

% As long as we receive data, echo that data back to the client.
state = 0;
while (state >= 0),
  if (state == 0)
    cmd = readByte(is);
    fprintf(1, 'Received cmd: %d\n', cmd);
    if (cmd < -1 | cmd > length(commands))
      fprintf(1, 'Unknown command code: %d\n', cmd);
    else
      state = cmd;
    end
		
  %-------------------
	% 'eval'
  %-------------------
  elseif (state == strmatch('eval', commands, 'exact'))
    bfr = char(readUTF(is));
    fprintf(1, '"eval" string: "%s"\n', bfr);
    try 
      eval(bfr);, 
      writeByte(os, 0);
      fprintf(1, 'Sent byte: %d\n', 0);
      flush(os);
    catch,
      fprintf(1, 'EvaluationException: %s\n', lasterr);
      writeByte(os, -1);
      fprintf(1, 'Sent byte: %d\n', -1);
      writeUTF(os, lasterr);
      fprintf(1, 'Sent UTF: %s\n', lasterr);
      flush(os);
    end
    flush(os);
    state = 0;
  
  %-------------------
	% 'send'
  %-------------------
  elseif (state == strmatch('send', commands, 'exact'))
    tmpname = sprintf('%s.mat', tempname);
    expr = sprintf('save %s', tmpname);
    ok = 1;
    for k=1:length(variables),
      variable = variables{k};
      if (exist(variable) ~= 1)
        lasterr = sprintf('Variable ''%s'' not found.', variable);
        ok = 0;
        break;
      end;
      expr = sprintf('%s %s', expr, variable);
    end;
    if (~ok)
      writeInt(os, -1);
      writeUTF(os, lasterr);
    else
      disp(expr);
      eval(expr);
		  writeUTF(os, tmpname);
    end
		
    answer = readByte(is);
		fprintf('answer=%d\n', answer);
		
    state = 0;
	
  %-------------------
	% 'send-remote'
  %-------------------
  elseif (state == strmatch('send-remote', commands, 'exact'))
    tmpname = sprintf('%s.mat', tempname);
    expr = sprintf('save %s', tmpname);
    ok = 1;
    for k=1:length(variables),
      variable = variables{k};
      if (exist(variable) ~= 1)
        lasterr = sprintf('Variable ''%s'' not found.', variable);
        ok = 0;
        break;
      end;
      expr = sprintf('%s %s', expr, variable);
    end;
    if (~ok)
      writeInt(os, -1);
      writeUTF(os, lasterr);
    else
      disp(expr);
      eval(expr);
      file = File(tmpname);
      maxLength = length(file);
      clear file;
      writeInt(os, maxLength);
      fprintf(1, 'Send int: %d (maxLength)\n', maxLength);
      fid = fopen(tmpname, 'r');
      count = 1;
      while (count ~= 0)
        [bfr, count] = fread(fid, 65536, 'int8');
        if (count > 0)
          write(os, bfr);
%          fprintf(1, 'Wrote %d byte(s).\n', length(bfr));
        end;
      end;
      fclose(fid);
%      fprintf(1, 'Wrote!\n');
      fprintf(1, 'Send buffer: %d bytes.\n', maxLength);
      delete(tmpname);
      clear bfr, count, maxLength, fid, tmpname;
    end
    flush(os);
		
    answer = readByte(is);
		fprintf('answer=%d\n', answer);
		
    state = 0;

	%-------------------
	% 'receive-remote'
  %-------------------
  elseif (state == strmatch('receive-remote', commands, 'exact'))
    len = readInt(is);
    fprintf(1, 'Will read MAT file structure of length: %d bytes.\n', len);

		reader = InputStreamByteWrapper(4096);
    bfr = [];
    count = 1;
    while (len > 0 & count > 0)
      count = reader.read(is, min(4096, len));
      if (count > 0)
        bfr = [bfr; reader.bfr(1:count)];
				len = len - count;
      end;
    end;

  	clear reader count len;

    tmpfile = sprintf('%s.mat', tempname);
%		tmpfile = 'tmp2.mat';
%		disp(bfr');
%		disp(tmpfile);
    fh = fopen(tmpfile, 'wb');
    fwrite(fh, bfr, 'int8');
    fclose(fh);

		clear fh, bfr;
		
		load(tmpfile);
		
    delete(tmpfile);
		clear tmpfile;
    writeByte(os, 0);

    state = 0;
		
  %-------------------
	% 'receive'
  %-------------------
  elseif (state == strmatch('receive', commands, 'exact'))
    filename = char(readUTF(is));
    fprintf(1, 'Will read MAT file: "%s"\n', filename);
		load(filename);
		clear filename;
    writeByte(os, 0);
    state = 0;
  end
end

fprintf(1, '-----------------------\n');
fprintf(1, 'Matlab server shutdown!\n');
fprintf(1, '-----------------------\n');
writeByte(os, 0);
close(os);
close(is);
close(server);

% References:
% [1] http://www.mathworks.com/access/helpdesk/help/techdoc/matlab_external/ch_jav34.shtml#49439
