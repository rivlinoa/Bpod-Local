%{
----------------------------------------------------------------------------

function PREPARE_TO_PROTOCOL creates all files needed for data saving,
and initiates the Bpod object.

----------------------------------------------------------------------------
% Created by Noa, 21.6.18
%}
% Usage:
% prepare_to_protocol('Start', animals) - Loads the launch manager, and creates the data
% file.
% prepare_to_protocol('Stop', animals) - Stops the currently running protocol. Data from the
% partially completed trial is discarded.

function prepare_to_protocol(Opstring, animals)
global BpodSystem
if isempty(BpodSystem)
    error('You must run Bpod() before launching a protocol.')
end
switch Opstring
    case 'Start'
        BpodSystem.Path.DataFolder  = '\\132.64.104.28\citri-lab\noa.rivlin\bpod_results\cage_1\data';
 
        BpodSystem.Data=struct;
        % Make standard folders for this experiment.  This will fail silently if the folders exist
        % define where to save the data from this experiment.
        formatOut = 'yy.mm.dd_HH.MM.SS';
        folder_name = datestr(now,formatOut);
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
        
        %BpodNotebook('init'); % Initialize Bpod notebook (for manual data annotation)
        
        %% insert animals data into the bpod object for plotting and analysis.
        
        BpodSystem.GUIData.animals=struct;
        BpodSystem.GUIData.animals.animals_names=animals.names;
        BpodSystem.GUIData.animals.animals_tags=animals.tags;
        BpodSystem.GUIData.animals.reward_supplied=zeros(size(BpodSystem.GUIData.animals.animals_names));
        BpodSystem.GUIData.animals.visit_count=zeros(size(BpodSystem.GUIData.animals.animals_names));
        BpodSystem.GUIData.animals.not_active=zeros(size(BpodSystem.GUIData.animals.animals_names));
        
        BpodSystem.GUIData.LastFrequency=0;
        
        %% initialize plots:
        
        BpodSystem.ProtocolFigures.reward_supplied = figure('name','Reward supplied','numbertitle','off', 'MenuBar', 'none', 'Resize', 'off');
        BpodSystem.GUIHandles.reward_supplied = axes();
        reward_supplied_plot(BpodSystem.GUIHandles.reward_supplied,'init');
        
        BpodSystem.ProtocolFigures.visit_count = figure('name','Visit count','numbertitle','off', 'MenuBar', 'none', 'Resize', 'off');
        BpodSystem.GUIHandles.visit_count = axes();
        visit_plot(BpodSystem.GUIHandles.visit_count,'init');
        
        BpodSystem.ProtocolFigures.not_active = figure('name','Not active','numbertitle','off', 'MenuBar', 'none', 'Resize', 'off');
        BpodSystem.GUIHandles.not_active = axes();
        not_active_plot(BpodSystem.GUIHandles.not_active,'init');
        
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