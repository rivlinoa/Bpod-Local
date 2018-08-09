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

function prepare_to_protocol_CueInCloud(Opstring, animals)
global BpodSystem

if isempty(BpodSystem)
    error('You must run Bpod() before launching a protocol.')
end
switch Opstring
    case 'Start'
        % initiate wave player:
        
        if (isfield(BpodSystem.ModuleUSB, 'WavePlayer1'))
            WavePlayerUSB = BpodSystem.ModuleUSB.WavePlayer1;
        else
            error('Error: To run this protocol, you must first pair the AudioPlayer1 module with its USB port. Click the USB config button on the Bpod console.')
        end
        A = BpodWavePlayer(WavePlayerUSB);
        SF = A.SamplingRate;
        
        % Program sound server
        A.SamplingRate = 50000; % max in 4 ch configurationn.
        A.BpodEvents = {'On','On','On','On'};
        A.TriggerMode = 'Master';
        A.OutputRange = '0V:5V';
        load('C:\Users\owner\Documents\Bpod Local\Protocols\CueInCloud\cloud.mat');
        load('C:\Users\owner\Documents\Bpod Local\Protocols\CueInCloud\cue.mat');
        cue = cue.*5.*0.99;
        stim = stim.*5.*0.99;
        BpodSystem.GUIData.cloud = stim;
        BpodSystem.GUIData.cue = cue;
        attenuations = linspace(0.1,1,10);
        cuemat = attenuations'*cue;
        cloudmat = attenuations'*stim;
        
        for i=1:10
            A.loadWaveform(i, cloudmat(i)); % the cloud, for now only one...
            LoadSerialMessages('WavePlayer1', ['P' ,1, i-1 ], i);
            A.loadWaveform(10+i, cuemat(i)); % the cue for now only one ....
            LoadSerialMessages('WavePlayer1', ['P' ,2, 9+i ], 10+i);
        end
        
        LoadSerialMessages('WavePlayer1', ['S'], 21 );
        %%
        BpodSystem.Data=struct;
        BpodSystem.Data.cloud = stim;
        BpodSystem.Data.cue = cue;
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
        
        BpodSystem.GUIData.LastFrequency=0;
        
        %% initialize plots:
        
        BpodSystem.ProtocolFigures.reward_supplied = figure('name','Reward supplied','numbertitle','off', 'MenuBar', 'none', 'Resize', 'off');
        BpodSystem.GUIHandles.reward_supplied = axes();
        reward_supplied_plot(BpodSystem.GUIHandles.reward_supplied,'init');
        
        BpodSystem.ProtocolFigures.visit_count = figure('name','Visit count','numbertitle','off', 'MenuBar', 'none', 'Resize', 'off');
        BpodSystem.GUIHandles.visit_count = axes();
        visit_plot(BpodSystem.GUIHandles.visit_count,'init');
        
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