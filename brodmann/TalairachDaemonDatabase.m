function [TTareas]=TalairachDaemonDatabase()
if exist('')
  tddb='C:\Program Files\Talairach Deamon Database\database\database.dat'
else
  tddb='/pclxserver2/home/ndiaye/downld/Talairach/TalairachDaemonClient/database/database.dat'
end
fid=fopen(tddb, 'r');
  
fread(fid, 80, 'int8')'
fclose(fid)

  
return  
  
  
  
types={'uint8', 'int8'} % 'int32', 'uint32' }
frewind(fid)
s=recc(fid, 7, types);
fclose(fid)

TTareas=s;
return


fprintf(1,'ok\n')

fid = fopen('TTdatabase.txt','wt');
fprintf(fid,'%s',s);
fclose(fid);

return

function [s]=recc(fid, l,types)
if l==0    
    s=sprintf('');
    return
end
a=ftell(fid);
for i=1:length(types)
    fseek(fid,a, 'bof');
    u=sprintf('%d [%s]\t', fread(fid, 1, types{i}), types{i});    
    t=recc(fid, l-1, types);
    s{i}=[repmat(u, size(t,1),1) t];
end
s=strvcat(s);
return


frewind(fid);


nvert=fread(fid, 1, 'uint32')
for i=1 % :nvert
    n=fread(fid, 1, 'int8');
    xyz(i,:)=fread(fid, 3, 'int8')';
    for j=1:n-3
        b{i}(j)=fread(fid, 1, 'int8');
    end 
end
fclose(fid)

TTareas.xyz=xyz;

% public void Load_Database(String s, String dbTextFile)
%     {
%         int i = 0;
%         d_lenght = 0;
%         try
%         {
%             FileInputStream fileinputstream = new FileInputStream(s);
%             BufferedInputStream bufferedinputstream = new BufferedInputStream(fileinputstream, 1000);
%             DataInputStream datainputstream1 = new DataInputStream(bufferedinputstream);

%% KND: Nb of points in the atlas (Reads a signed 32-bit integer):
%             d_lenght = datainputstream1.readInt();


%             TD_brain = new Hashtable(d_lenght + 1000, 1.0F);
%             String s1 = new String();
%             for(long l = 0L; l < (long)d_lenght; l++)
%             {
%                 boolean flag = false;
%                 byte byte0 = datainputstream1.readByte();
%                 String s2 = "";
%                 short word0 = datainputstream1.readByte();
%                 s2 = s2 + word0 + ",";
%                 word0 = datainputstream1.readByte();
%                 s2 = s2 + word0 + ",";
%                 word0 = datainputstream1.readByte();
%                 s2 = s2 + word0;
%                 byte abyte0[] = new byte[byte0 - 3];
%                 for(int i1 = 0; i1 < byte0 - 3; i1++)
%                     abyte0[i1] = datainputstream1.readByte();
% 
%                 TD_brain.put(s2, abyte0);
%                 if(++i == 1000)
%                 {
%                     // IBO
%                     // father.prog.update(((int)l * 100) / d_lenght);
%                     i = 0;
%                 }
%             }
% 
%         }
%         catch(IOException ioexception)
%         {
%             Error = ioexception.toString();
%             ioexception.printStackTrace();
%             loaded = false;
%         }
%         try
%         {
%             //IBO
%             DataInputStream datainputstream = new DataInputStream(new FileInputStream(dbTextFile));   //"./database/database.txt"));
%             int j = Integer.valueOf(datainputstream.readLine()).intValue();
%             for(int k = 0; k < j;)
%             {
%                 StringTokenizer stringtokenizer = new StringTokenizer(datainputstream.readLine(), ",");
%                 Labels[k] = stringtokenizer.nextToken();
%                 Level[k++] = Byte.valueOf(stringtokenizer.nextToken()).byteValue();
%             }
% 
%             loaded = true;
%             return;
%         }
%         catch(Exception exception)
%         {
%             Error = "Error in loading database headers from file" + exception.toString();
%         }
%         loaded = false;
%     }
