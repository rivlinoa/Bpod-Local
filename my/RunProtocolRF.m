%{
----------------------------------------------------------------------------

function PREPARE_TO_PROTOCOL creates all files needed for data saving, 
and initiates the Bpod object. 

----------------------------------------------------------------------------

%}
% Usage:
% prepare_to_protocol('Start') - Loads the launch manager
% prepare_to_protocol('Stop') - Stops the currently running protocol. Data from the
% partially completed trial is discarded.

function prepare_to_protocol(Opstring)
global BpodSystem
if isempty(BpodSystem)
    error('You must run Bpod() before launching a protocol.')
end
switch Opstring
    case 'Start'
            NewLaunchManager;
          
            DataPath = fullfile(BpodSystem.Path.DataFolder,subjectName);
            if ~exist(DataPath)
                error(['Error starting protocol: Test subject "' subjectName '" must be added first, from the launch manager.'])
            end
            %Make standard folders for this protocol.  This will fail silently if the folders exist
            mkdir(DataPath, protocolName);
            mkdir(fullfile(DataPath,protocolName,'Session Data'))
            mkdir(fullfile(DataPath,protocolName,'Session Settings'))
            DateInfo = datestr(now, 30); 
            DateInfo(DateInfo == 'T') = '_';
            FileName = [subjectName '_' protocolName '_' DateInfo '.mat'];
            DataFolder = fullfile(BpodSystem.Path.DataFolder,subjectName,protocolName,'Session Data');
            if ~exist(DataFolder)
                mkdir(DataFolder);
            end
            
            % Ensure that a default settings file exists
            DefaultSettingsFilePath = fullfile(DataPath,protocolName,'Session Settings', 'DefaultSettings.mat');
            if ~exist(DefaultSettingsFilePath)
                ProtocolSettings = struct;
                save(DefaultSettingsFilePath, 'ProtocolSettings')
            end
            SettingsFileName = fullfile(BpodSystem.Path.DataFolder, subjectName, protocolName, 'Session Settings', [settingsName '.mat']);
            if ~exist(SettingsFileName)
                error(['Error: Settings file: ' settingsName '.mat does not exist for test subject: ' subjectName ' in protocol: ' protocolName '.'])
            end
            BpodSystem.Status.Live = 1;
            BpodSystem.GUIData.ProtocolName = protocolName;
            BpodSystem.GUIData.SubjectName = subjectName;
            BpodSystem.GUIData.SettingsFileName = SettingsFileName;
            BpodSystem.Path.Settings = SettingsFileName;
            BpodSystem.Path.CurrentDataFile = fullfile(DataFolder, FileName);
            BpodSystem.Status.CurrentProtocolName = protocolName;
            BpodSystem.Status.CurrentSubjectName = subjectName;
            SettingStruct = load(BpodSystem.Path.Settings);
            F = fieldnames(SettingStruct);
            FieldName = F{1};
            BpodSystem.ProtocolSettings = eval(['SettingStruct.' FieldName]);
            addpath(ProtocolRunFile);
            set(BpodSystem.GUIHandles.RunButton, 'cdata', BpodSystem.GUIData.PauseButton, 'TooltipString', 'Press to pause session');
            IsOnline = BpodSystem.check4Internet();
            if (IsOnline == 1) && (BpodSystem.SystemSettings.PhoneHome == 1)
                BpodSystem.BpodPhoneHome(1);
            end
            BpodSystem.Status.BeingUsed = 1;
            BpodSystem.ProtocolStartTime = now*100000;
            figure(BpodSystem.GUIHandles.MainFig);
            run(ProtocolRunFile);
        end
    case 'StartPause'
        if BpodSystem.Status.BeingUsed == 0
            if BpodSystem.EmulatorMode == 0
                BpodSystem.StopModuleRelay;
            end
            NewLaunchManager;
        else
            if BpodSystem.Status.Pause == 0
                disp('Pause requested. The system will pause after the current trial completes.')
                BpodSystem.Status.Pause = 1;
                set(BpodSystem.GUIHandles.RunButton, 'cdata', BpodSystem.GUIData.PauseRequestedButton, 'TooltipString', 'Pause scheduled after trial end'); 
            else
                disp('Session resumed.')
                BpodSystem.Status.Pause = 0;
                set(BpodSystem.GUIHandles.RunButton, 'cdata', BpodSystem.GUIData.PauseButton, 'TooltipString', 'Press to pause session');
            end
        end
    case 'Stop'
        if ~isempty(BpodSystem.Status.CurrentProtocolName)
            disp(' ')
            disp([BpodSystem.Status.CurrentProtocolName ' ended.'])
        end
        rmpath(fullfile(BpodSystem.Path.ProtocolFolder, BpodSystem.Status.CurrentProtocolName));
        BpodSystem.Status.BeingUsed = 0;
        BpodSystem.Status.CurrentProtocolName = '';
        BpodSystem.Path.Settings = '';
        BpodSystem.Status.Live = 0;
        if BpodSystem.EmulatorMode == 0
            BpodSystem.SerialPort.write('X', 'uint8');
            pause(.1);
            nBytes = BpodSystem.SerialPort.bytesAvailable;
            if nBytes > 0
                BpodSystem.SerialPort.read(nBytes, 'uint8');
            end
            if isfield(BpodSystem.PluginSerialPorts, 'TeensySoundServer')
                TeensySoundServer('end');
            end   
        end
        BpodSystem.Status.InStateMatrix = 0;
        
        set(BpodSystem.GUIHandles.RunButton, 'cdata', BpodSystem.GUIData.GoButton, 'TooltipString', 'Launch behavior session');
        if BpodSystem.Status.Pause == 1
            BpodSystem.Status.Pause = 0;
        end
        % ---- end Shut down Plugins
end