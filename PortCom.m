classdef PortCom<handle
    properties
        %% values to the port
        portName='COM3'
        baudRate=9600
        samplingTime=20e-3
        graphicsNumber=1
        minY=0
        maxY=1
        yLimResizable=false
    end
    properties(GetAccess=private)
        %% constants of the port
        serialObj
        baudRatesAvailables=[300,1200,2400,4800,9600,19200,38400,57600,115200]
        colors=['r','b','g']
        graphInterval=500
    end
    methods
        function obj=PortCom(portName,baudRate)
            %PortCom(portName,baudRate) Open a serial Com Port
            %   Creates a serial com port, the port name is "portName", the
            %   baud rate of the comunication is "baudRate"
            %   
            %   portName is the from 'COMx' in windows
            %   baudRate must be [300,1200,2400,4800,9600,19200,38400,57600,115200]
            
            %% check if the portName is a char
            if ~isa(portName,'char')
                error('PortCom:InvalidPortNameType','Input portName must be a char, not a %s',class(portName))
            end
            %% check if the baudRate is a double
            if ~isa(baudRate,'double')
                error('PortCom:InvalidBaudRateType','Input baudRate must be a double, not a %s',class(baudRate))
            end
            %% check if the baudRate is in the available baut rate list
            baudRateState=false;
            for value=obj.baudRatesAvailables
                if baudRate==value
                    baudRateState=true;
                end
            end
            %% if the baud rate selected is invalid
            if ~baudRateState
                error('PortCom:InvalidBaudRate','You have selected an invalid baudRate value %d',baudRate)
            end
            %% save the data
            obj.portName=upper(portName);
            obj.baudRate=baudRate;
            obj.serialObj=serial(obj.portName,'baudRate',obj.baudRate);
        end
        function delete(obj)
            %delete destructor of the object
            delete(instrfind('port',obj.portName));
        end
        function setSamplingTime(obj,samplingTime)
            %setSamplingTime(samplingTime) set the sampling time of the data
            %   sets the sampling interval of the serial data, this value
            %   do not represent the time when Matab ask for data to the
            %   serial port, this data represent the sampling interval of
            %   the data to generate a right time vector
            
            %% check if the samplig time is double
            if ~isa(samplingTime,'double')
                error('PortCom:setSamplingTime','Input samplingTime must be an double, not a %s',class(samplingTime))
            end
            %% check if the sampling time is higher tha zero
            if samplingTime<=0
                error('The samplingTime interval must be higher than zero because is an interval of time beetween the samplings')
            end
            %% save the sampling time
            obj.samplingTime=samplingTime;
        end
        function setGraphicsNumber(obj,graphicsNumber)
            %%setGraphicsNumber(graphicsNumber) set the number of graphics
            %   receive the stream and separate the data into a diferents
            %   vectors to plot it
            %% check if number of graphics are double
            if ~isa(graphicsNumber,'double')
                error('PortCom:InvalidNumberGraphicsType','Input graphicsNumber must be a double, not a %s',class(graphicsNumber))
            end
            %% check if the number of graphics are higher than zero
            if graphicsNumber<=0
                error('PortCom:InvalidNumberOfGraphics','The graphicsNumber must be higher than zero, it will be the number of graphics')
            end
            obj.graphicsNumber=graphicsNumber;
        end
        function setYLimType(obj,yLimResizable)
            %%setYLimType(yLimResizable) set the yLim type
            %   set if the y limit must be static or dinamic
            
            %% check if yLimType is resizable or inmobile otherwise error
            if strcmp(yLimResizable,'resizable')
                obj.yLimResizable=true;
            elseif strcmp(yLimResizable,'inmobile')
                obj.yLimResizable=false;
            else
                error('PortCom:InvalidYLimType','Invalid yLim type, must be resizable or inmobile not %s',yLimResizable)
            end
        end
        function setLimY(obj,minY,maxY)
            %%setLimY(minY,maxY) set the limits if the graphics
            %   set the limits of the graphic
            
            %% check the type of the arguments
            if ~isa(maxY,'double')
                error('PortCom:InvalidMaxYType','maxY value must be an double not a %s',class(maxY))
            end
            if ~isa(minY,'double')
                error('PortCom:InvalidMinYType','minY value must be an double not a %s',class(minY))
            end
            %% check if the maxY is higher that the minY
            if minY>=maxY
                error('The minY must be higher than maxY')
            end
            %% save the data
            obj.minY=minY;
            obj.maxY=maxY;
        end
        function [x,y]=plot(obj,samples)
            %% if the samples argument is not sended
            if nargin==1
                samples=1000;
            end
            %% check the type of the samples argument
            if ~isa(samples,'double')
                error('PortCom:InvalidSamplesType','samples value must be an double not a %s',class(samples))
            end
            %% if the number of samples is not valid
            if samples<=0
                error('PortCom:InvalidSamplesNumber','The number of samples must be higher than 0')
            end
            %% create a vector
            y=zeros(obj.graphicsNumber,samples);
            posx=0;
            % get and plot data
            try
                % open port
                fopen(obj.serialObj);
                % get the number of samples required
                for i=1:samples
                    %% get data for the number of graphics
                    for graphic=1:obj.graphicsNumber
                        % scan for floats
                        try
                            y(graphic,i)=fscanf(obj.serialObj,'%f');
                        catch Me
                            display(Me)
                        end
                    end
                    % get the colors
                    [~,colorSize]=size(obj.colors);
                    colorIndex=1;
                    %% graph data
                    for graphic=1:obj.graphicsNumber
                        % move the y lim
                        if obj.yLimResizable==true
                            if y(graphic,i)>obj.maxY
                                obj.maxY=y(graphic,i);
                            end
                            if y(graphic,i)<obj.minY
                                obj.minY=y(graphic,i);
                            end
                        end
                        ylim([obj.minY,obj.maxY])
                        % graph the data with a color
                        plot(y(graphic,1:end),obj.colors(colorIndex));
                        % get the next color
                        if colorIndex==colorSize
                            colorIndex=1;
                        else
                            colorIndex=colorIndex+1;
                        end
                        % hold for the next graph
                        hold on
                    end
                    % stop the hold graph
                    hold off
                    %% move the x interval
                    if i>obj.graphInterval
                        posx=posx+1;
                    end
                    xlim([posx,i])
                    %% draw data
                    drawnow
                end
                % close port
                fclose(obj.serialObj);
                % create time vector
                x=0:obj.samplingTime:(samples-1)*obj.samplingTime;
            catch Me
                %% if error close port and rethrow the error
                fclose(obj.serialObj);
                rethrow(Me)
            end
        end
        function write(obj,data)
            %% under development
            if isa(data,'double')
                data=double2str(data);
            end
            try
                fopen(obj.serialObj);
                fwrite(obj.serialObj,data);
                fprintf('Writed into %s: %s\n',obj.portName,data)
            catch Me
                rethrow(Me);
            end
            fclose(obj.serialObj);
        end
    end
end