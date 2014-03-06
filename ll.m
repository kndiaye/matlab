function [varargout]=ll(varargin)
% ll - synonym of DIR command (display bytes & date info)
%   ll(pat) list file according to pattern and display output
%
%   f=ll(pat) ouputs a file structure.
%   Note that it uses 'ls' utility in Unix which allow advanced regexp
%   e.g. f=ll('~/.c*/*')

if nargout==0
    if isunix
        if ismac && nargin==0
            varargin={pwd};
        end
        system(['ls -l ' sprintf('%s ', varargin{:})]);
    else
        f=dir(varargin{:});
        nf=numel(f);
        %sep = repmat(sprintf('\t'), [nf,1]);
        %filedates = datevec([f.datenum]);
        %if any(strmatch('-t', varargin(:)))
        [i,i]=sort([f.datenum]);
        %end
        f=f(i);
        for i=1:numel(f)
            mfb = max([f.bytes]);
            if isequal(mfb,0)
                mfb = 0;
            else
                mfb = 1+ceil(log10(mfb));
            end
            
            fprintf(['%s\t%' sprintf(' %d',mfb) 'd\t%s\n'], datestr(f(i).datenum,31), f(i).bytes, f(i).name);
        end
        %         end
        %         try
        %             disp([ ...
        %             datestr(datevec([f.datenum]),31) ... %strvcat({f.date}) ...
        %             sep ...
        %             num2str([f.bytes]') ... %strvcat(regexprep(cellstr(num2str([f.bytes]')), '^(\s*)0$','<REP>'))
        %             sep ...
        %             strvcat({f.name}) ...             %names ...
        %             ]);
        %         catch
        %             disp([ ...
        %             datestr(datevec({f.date}),31) ... %strvcat({f.date}) ...
        %             sep ...
        %             num2str([f.bytes]') ... %strvcat(regexprep(cellstr(num2str([f.bytes]')), '^(\s*)0$','<REP>'))
        %             sep ...
        %             strvcat({f.name}) ...             %names ...
        %             ]);
        %         end
    end
else
    if isunix
        if ismac 
            if nargin==0
            varargin={[pwd]};
            end
            if isdir(varargin{end})
                varargin{end}=[varargin{end} filesep '*']
            end
            [status,s]=system(['\ls -paUogd ' sprintf('%s ', varargin{:})])
            
            [attr types bytes days months times names]=strread(s,'%s%d%d%s%s%s%s%*[^\n]');
            dates = [strvcat(days)  repmat(' ', numel(days),1) strvcat(months)  repmat(' ', numel(days),1) strvcat(times)]
            datenums = datenum(dates,31);
        else
            [status,s]=system(['\ls -paUogd --time-style="long-iso" --block-size=1 ' sprintf('%s ', varargin{:})]);
            [attr types bytes days times names]       =strread(s,'%s%d%d%s%s%s%*[^\n]');
            dates = [strvcat(days) repmat(' ', numel(days),1) strvcat(times)];
            datenums = datenum(dates,31);
        end
        if status
            varargout={[]};
            return
        end        
        
        varargout = {struct(...
            'name', names,...
            'date', cellstr(datestr(datenums)),...
            'bytes',num2cell(bytes),...
            'isdir',num2cell(types==2),...
            'datenum',num2cell(datenums)...
            )};
    else
        varargout={dir(varargin{:})};
    end
end
