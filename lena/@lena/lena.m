function obj = lena(varargin)
% LENA - Constructor of the LENA data class
%
% obj = lena(varargin)
%
% KND
if nargin==0
    obj.header = [];
    obj.F = [];
    obj.Time = [];
    obj.filename = '';
    obj.events = [];
    obj.trialclass = [];
    obj.badchannels = [];
    
    obj = class(obj,'lena');
else
    v = varargin{1};
    if isa(v,'lena')
        obj = v;
    elseif ischar(v)
        % if (exist(v, 'file') || exist(v,'dir'))
        obj.filename = v;
        try
            [obj.header,obj.F,obj.Time] = read_lena(obj.filename,varargin{2:end});
        catch ME
            rethrow(ME);
        end
        obj = class(obj,'lena');
    elseif isnumeric(v)        
        obj.F = v ;
        obj = class(obj,'lena');
    else
        error('[LENA] Bad input argument');
    end

end

function [names] = sensornames 
names = 1;

function [pos] = sensorpositions


function [F] = data(o)
F = o.F;


