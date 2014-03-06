function [hnames,A,B,tvals,rowlevel] = read_eprimetxt(filename, varnames)
% read_eprimetxt - reads E-prime text files as edat
%     V = read_eprimetxt('FILENAME') returns in V, the names of variables found in
%     the E-Prime text file FILENAME (in alphabetical order)
%
%     [V, A, B] = read_eprimetxt('FILENAME') also returns numeric data, stored in A, and text
%     data, stored in B.
%
% See also: xlsread

txt=textread(filename, '%s', 1, 'delimiter', '\n');
if isequal(double(textread(filename, '%c', 3))', [65535 65534 42])
    %  Null separated characters...
    fid=fopen(filename,'rt');
    txt=char(fread(fid, getfield(dir(filename), 'bytes'), 'char'))';
    fclose(fid);
    txt(txt==255)=[];
    txt(txt==254)=[];
    txt(txt==0)=[];
    txt=strread(txt, '%s', 'delimiter', '\n');
elseif isequal(txt, {'*** Header Start ***'})
    txt=textread(filename, '%s', 'delimiter', '\n');
else
    hnames{1} = 'impossible';
    A = [];
    B = [];
    tvals = [];
    rowlevel = [];
    return
    error('Wrong type of file, it should be an E-prime generated text file, starting with a header');
end
% Header.nvars=strmatch('*** Header End ***', txt)-strmatch('*** Header Start ***', txt)-1;


%% Vars
v=txt;
v(strmatch('*** ', txt))=[];
if datenum(version('-date')) > 733044 %732892 % 732687 % 732341
    [vnames, vvals]=strread(v,'%s%s',1,'delimiter', ': ');
    % elseif str2num(version('-release'))>=14
    %         %it still bugs with Matlab 7.0.4.365 (R14) Service Pack 2 !!
    %         for i=1:size(v,1)
    %             [vnames(i), vvals(i)]=strread(v{i},'%s%s',1,'delimiter', ': ');
    %         end
else
    vnames=cell(length(v),1);
    vvals=vnames;
    for i=1:length(v)
        [vnames{i},b]= strtok(v{i}, ': ');
        vvals{i}=b(3:end);
    end
end

%% LevelNames
LevelNames=vvals(strmatch('LevelName', vnames));
vvals(strmatch('LevelName', vnames))=[];
vnames(strmatch('LevelName', vnames))=[];

% Identical variable names across levels should be specified using []
ilevels=strmatch('Level', vnames, 'exact');
levels=str2num(strvcat(vvals(ilevels)));
vlevels=zeros(length(vnames),1);
for i=1:length(ilevels)
    vlevels(ilevels(i):end)=levels(i);
end
% vvals(strmatch('Level', vnames))=[];
% vlevels(strmatch('Level', vnames))=[];
% vnames(strmatch('Level', vnames))=[];


% List of column headers
[hnames,i,j]=unique(vnames);
%j(     strmatch('Level', hnames, 'exact'))=NaN;


for i=1:length(hnames)
    if ~isequal(hnames{i},'Level')
        l=unique(vlevels(j==i));
        l=nonzeros(l);
        if length(l)>1
            %hnames(i)
            for k=2:length(l)
                hnames{end+1}=[ hnames{i} '[' LevelNames{l(k)} ']'];
                vnames(intersect(find(vlevels==l(k)),strmatch(hnames{i},vnames,'exact')))=hnames(end);
            end
            hnames{i} = [ hnames{i} '[' LevelNames{l(1)} ']'];
            vnames(intersect(find(vlevels==l(1)),strmatch(hnames{i},vnames,'exact')))=hnames(i);
        end
    end
end
hnames(strmatch('Level', hnames, 'exact'))=[];
hnames=[hnames ; LevelNames(2:max(levels)) ];
[i,i]=sort(lower(hnames));
hnames=hnames(i)';
if nargout <= 1
    %returns headers only
    %     k=strmatch('Level',hnames, 'exact');
    %     hnames(k)=[];
    %     k=strmatch('LevelName',hnames, 'exact');
    %     hnames(k)=[];
    k=strmatch('VersionPersist',hnames, 'exact');
    hnames(k)=[];
    return
end


%% Converts text to numerical values
% To tease apart numerical/text values, we create a new array containing
% mixed data types
% try
%     % With version > 7.0
%     xvals=cellfun(str2func('str2num'), vvals, 'UniformOutput', 0);
%
%     %Where non numerical data were...
%     tvals=cellfun('isempty', xvals);
%     % We also need to check for a strange behavior of str2num
%     tvals=tvals | cellfun('length',xvals) > 1;
%
%     % we put them back in the mixed type array xvals
%     xvals(tvals)=vvals(tvals);
% catch
%     xvals=cell(length(vvals),1);
%     tvals=logical(zeros(length(vvals),1));
%     for i=1:length(vvals)
%         xvals{i}=str2num(vvals{i});
%         if isempty(xvals{i}) & ~isempty(vvals{i})
%             xvals{i}=vvals{i};
%             tvals(i)=1;
%         end
%     end
% end

nrows=sum(diff(levels)==0)+sum(diff(levels)>0)+1;
nvars= length(hnames);
%table of values
tvals=cell(nrows,length(hnames));

rowlevel=zeros(nrows,1);
row=0;
for i=1:length(levels)-1
    if i==1 || levels(i)>=levels(i-1)
        row=row(end)+1;
    else
        row=find(rowlevel>levels(i));
    end
    rowlevel(row)=levels(i);
    for j=ilevels(i)+1:ilevels(i+1)-1
        % Fills with values for the corresponding level
        k=strmatch(vnames(j),hnames, 'exact');
        if strcmp(vvals{j},'i')
            v = NaN;
        else
            v=str2double(vvals{j});
        end
        if isnan(v) && ~isempty(vvals{j})
            v=vvals{j};
        end
        tvals(row,k)={v};
    end
    k=strmatch(LevelNames(levels(i)),hnames, 'exact');
    if row(1)>1
        tvals(row,k)={tvals{row(1)-1,k}+1};
    else
        tvals(row,k)={1};
    end
end

for j=ilevels(end)+1:length(vvals)
    % Fills with values for the corresponding level
    k=strmatch(vnames(j),hnames, 'exact');
    if strcmp(vvals{j},'i')
        v = NaN;
    else
        v=str2double(vvals{j});
    end
    if isnan(v) && ~isempty(vvals{j})
        v=vvals{j};
    end
    tvals(:,k)={v};
end


%% Converts to Number and Text arrays
B = cell(nrows,nvars);
B(:) = {''};
vIsNaN = false(nrows,nvars);
% find non-numeric entries in data cell array
vIsText = cellfun('isclass',tvals,'char');
% place text cells in text array
% then replace them with NaN
if any(vIsText(:))
    vIsText=any(vIsText);
    B(:,vIsText) = deblank(tvals(:,vIsText));
    % Replace [] in char array...
    B(cellfun('isempty',B))={''};
    tvals(:,vIsText)={NaN};
end
% place NaN in empty numeric cells
vIsNaN  = ...
    cellfun('isempty',tvals)|...
    cellfun('isclass',tvals,'char');
if any(vIsNaN(:))
    tvals(vIsNaN)={NaN};
end
A = cell2mat(tvals);
B=reshape(B,[nrows,nvars]);

%% Ouputs requested variables
if nargin>1
    if ~iscell(varnames)
        varnames={varnames};
    end
    k=zeros(1,length(varnames));
    for i=1:length(varnames)
        if ismember(varnames(i),hnames)
            k(i)=strmatch(varnames{i},hnames,'exact');
        else
            %k(i)=strmatch(varnames{i},hnames,'exact');
        end
    end
    if any(k==0)
        error('Variable name not found');
    end
    hnames=hnames(k);
    A=A(:,k);
    B=B(:,k);
    return
end

% add: Procedure[Block]	Procedure[Trial] Running[Block]	Running[Trial]
k=strmatch('Level',hnames, 'exact');
A(:,k)=[];B(:,k)=[];hnames(k)=[];
k=strmatch('LevelName',hnames, 'exact');
A(:,k)=[];B(:,k)=[];hnames(k)=[];
k=strmatch('VersionPersist',hnames, 'exact');
A(:,k)=[];B(:,k)=[];hnames(k)=[];
k=strmatch('Procedure',hnames, 'exact');
A(:,k)=[];B(:,k)=[];hnames(k)=[];
k=strmatch('Running',hnames, 'exact');
A(:,k)=[];B(:,k)=[];hnames(k)=[];

return

function [tvals,rowlevel,varlevel]=filllevels(tvals,rowlevel,varlevel,curlevel,row,nlevels)
% fill lower levels in the hierarchy
for j=nlevels:-1:curlevel
    k=(varlevel<j) & varlevel>0;
    tvals(row-[0:rowlevel(j)-1],k)=repmat(tvals(row,k),rowlevel(j),1);
end
varlevel(varlevel>=curlevel)=0;
rowlevel(curlevel:end)=0;
return