%{
----------------------------------------------------------------------------

function PREPARE_TO_PROTOCOL creates all files needed for data saving, 
and initiates the Bpod object. 

----------------------------------------------------------------------------
% Created by Noa, 21.6.18
%}
% Usage:
% prepare_to_protocol('Start') - Loads the launch manager, and creates the data
% file. 
% prepare_to_protocol('Stop') - Stops the currently running protocol. Data from the
% partially completed trial is discarded.

function prepare_to_protocol(Opstring)
global BpodSystem
if isempty(BpodSystem)
    error('You must run Bpod() before launching a protocol.')
end
switch Opstring
    case 'Start'
            BpodSystem.Data=struct;         
            % Make standard folders for this experiment.  This will fail silently if the folders exist
            % define where to save the data from this experiment. 
            folder_name= strrep(char(datetime('now')), ':', '_');
            ExperimentFolder= fullfile(BpodSystem.Path.DataFolder,folder_name);
            if ~exist(ExperimentFolder)
                mkdir(ExperimentFolder);
            end            
            mkdir(fullfile(BpodSystem.Path.DataFolder,folder_name,'Session Data'))
            mkdir(fullfile(BpodSystem.Path.DataFolder,folder_name,'Session Settings'))
            FileName = [folder_name '.mat'];
            DataFolder = fullfile(BpodSystem.Path.DataFolder,folder_name,'Session Data');                        
            BpodSystem.Path.DataFolder=ExperimentFolder;
            
            % initiate parameters in the Bpood object. 
            BpodSystem.Status.Live = 1;
            BpodSystem.Path.CurrentDataFile = fullfile(DataFolder, FileName);            
            set(BpodSystem.GUIHandles.RunButton, 'cdata', BpodSystem.GUIData.PauseButton, 'TooltipString', 'Press to pause session');
            BpodSystem.Status.BeingUsed = 1;
            BpodSystem.ProtocolStartTime = now*100000;
            figure(BpodSystem.GUIHandles.MainFig);
            % Need to check what is the phone home option. this activate
            % it: 
%            IsOnline = BpodSystem.check4Internet();
%             if (IsOnline == 1) && (BpodSystem.SystemSettings.PhoneHome == 1)
%                 BpodSystem.BpodPhoneHome(1);
%             end
            

            BpodNotebook('init'); % Initialize Bpod notebook (for manual data annotation)
       
    
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