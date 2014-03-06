classdef datahandler
    % datahandler - A class to handle MEEG data
    %
    % dh = datahandler(varargin)
    %
    % KND

    properties
        F = [];
        file = struct('path', '', 'header', []);
        dimensions = []
        time
        channels
        trials
        markers
        classes
        badchannels        
    end

    methods
        function dh = datahandler(varargin)
            if nargin>0
                v = varargin{1};
                if isa(v,'datahandler')
                    dh = v;
                elseif ischar(v)
                    % if (exist(v, 'file') || exist(v,'dir'))
                    dh.file.path = v;
                    try
                        [dh.file.header,dh.F,dh.time] = read_lena(dh.file.path,varargin{2:end});
                    catch ME
                        rethrow(ME);
                    end
                elseif isnumeric(v)
                    dh.F = v ;
                else
                    error('[datahandler] Bad input argument');
                end
            end
            %obj = obj@uint8(data);
            %dh = datahandler(data);            
            
        end

        function s = sensornames(dh)
            s = [dh.file.header.description.sensor_range.sensor_list.sensor];
            s = {s.CONTENT};
        end

        function plot(td,varargin)
            plot(td.Strain,td.Stress,varargin{:})
            title(['Stress/Strain plot for Sample',...
                num2str(td.SampleNumber)])
            ylabel('Stress (psi)')
            xlabel('Strain %')
        end % plot


    end


end