classdef DAQToolboxHandler
    %UNTITLED5 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Devices
        Session
        Rate
        SessionIsContinuous
        SessionDurationInSeconds
        SelectedChannels
        AddedChannels
        AddedChannelLabels
        
        SelectedDevice
        
        ToolboxAvailable
        
        WaitTimeout
        DAQSessionDataListener
    end
    
    methods
        function obj = DAQToolboxHandler()
            %UNTITLED5 Construct an instance of this class
            %   Detailed explanation goes here
            try
                obj.Devices = daq.getDevices;
                obj.ToolboxAvailable = true;
                obj.SelectedDevice = 1;
                obj.SessionIsContinuous = true;
                obj.SessionDurationInSeconds = 0;
            catch
                disp('DAQ Toolbox function unavailable');
                obj.Devices = [];
                obj.ToolboxAvailable = false;
            end
            
            obj.WaitTimeout = 60 * 60 * 24;
        end
        
        function obj = ReleaseSession(obj)
            if ~(isempty(obj.Session))
                release(obj.Session);
            end
        end
        
        function obj = Reset(obj)
            daqreset;
        end
        
%         function obj = CreateSession(obj)
%             obj.Session = daq.createSession(obj.Devices(obj.SelectedDevice).Vendor.ID);
%             
%             obj = obj.UpdateSessionParameters();
%             
%             obj.AddedChannels = addAnalogInputChannel(obj.Session, obj.Devices(obj.SelectedDevice).ID, obj.SelectedChannels, 'Voltage');
%             for i = 1:length(obj.AddedChannels)
%                 obj.AddedChannels(i).TerminalConfig = 'SingleEnded';
%             end
%             
%             obj.DAQSessionDataListener = addlistener(obj.Session, 'DataAvailable', @DAQSessionDataAvailable);
%         end
%         
%         function obj = RunSession(obj)
%             prepare(obj.Session);
%             display(obj.Session);
%             startBackground(obj.Session);
%             wait(obj.Session, obj.WaitTimeout);
%         end
        
        function obj = UpdateSessionParameters(obj)
            obj.Session.Rate = obj.Rate;
            obj.Session.NotifyWhenDataAvailableExceeds = obj.Rate;
            obj.Session.IsContinuous = obj.SessionIsContinuous;
            if ~obj.Session.IsContinuous
                obj.Session.DurationInSeconds = obj.SessionDurationInSeconds;
            end
%             obj.AddedChannels = addAnalogInputChannel(obj.Session, obj.Devices(obj.SelectedDevice).ID, obj.SelectedChannels, 'Voltage');
%             for i = 1:length(obj.AddedChannels)
%                 obj.AddedChannels(i).TerminalConfig = 'SingleEnded';
%             end
        end
        
        function obj = set.Rate(obj, rate)
            obj.Rate = rate;
            obj = obj.UpdateSessionParameters();
        end
        
        function obj = set.SessionIsContinuous(obj, isContinuous)
            obj.SessionIsContinuous = isContinuous;
            obj = obj.UpdateSessionParameters();
        end
        
        function obj = set.SessionDurationInSeconds(obj, duration)
            obj.SessionDurationInSeconds = duration;
            obj = obj.UpdateSessionParameters();
        end
        
        function obj = set.SelectedDevice(obj, selectedDevice)
            obj.SelectedDevice = selectedDevice;
        end
        
        function device = CurrentDevice(obj)
            device = obj.Devices(obj.SelectedDevice);
        end
        
        function deviceList = DeviceList(obj)
            for i = 1:length(obj.Devices)
                deviceList(i) = strcat(obj.Devices(i).ID, {' - '}, obj.Devices(i).Description);
            end
        end
    end
end

