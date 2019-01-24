%{
----------------------------------------------------------------------------

function PREPARE_TO_PROTOCOL_CUEINFIXCLOUD creates all files needed for data saving,
and initiates the Bpod object.
it also loads thw waveplayer with the cloud and cue signal to be played.


% add input as the cue file !!!! 
----------------------------------------------------------------------------
% Created by Noa, 21.6.18,
% Eddited 23.12.18
%}


function prepare_to_protocol_CueInFixCloud(animals)

global BpodSystem

if isempty(BpodSystem)
    error('You must run Bpod() before launching a protocol.')
end

% initiate wave player:
if (isfield(BpodSystem.ModuleUSB, 'WavePlayer1'))
    WavePlayerUSB = BpodSystem.ModuleUSB.WavePlayer1;
else
    error('Error: To run this protocol, you must first pair the WavePlayer1 module with its USB port. Click the USB config button on the Bpod console.')
end
A = BpodWavePlayer(WavePlayerUSB);


% Program sound server
A.SamplingRate = 50000; % max in 4 ch configurationn.
SF = A.SamplingRate;
A.BpodEvents = {'On','On','On','On'};
A.TriggerMode = 'Master';
A.OutputRange = '0V:5V';
load('C:\Users\Owner\Documents\Bpod Local\Protocols\CueInCloud\filtered_cloud.mat');
% load('C:\Users\owner\Documents\Bpod Local\Protocols\CueInCloud\cue.mat'); % for the 4 khz rig!!!
load('C:\Users\owner\Documents\Bpod Local\Protocols\CueInFixCloud\cue6khz.mat') % for the 6 khz cage!!!
% make the cue and the cloud between 0-1:
filtered_cloud = filtered_cloud - min(filtered_cloud);
filtered_cloud = filtered_cloud / max(filtered_cloud);% make it between 0-1
cue = cue - min(cue);
cue = cue / max(cue);

attenuations = [0.25, 0.5, 1, 2, 3.5, 5];
cuemat = attenuations'*cue;

for i=1:length(attenuations)
    A.loadWaveform(i, cuemat(i,:)); % the cou, for now only one with 6 attenuations...
end
A.loadWaveform((length(attenuations)+1), filtered_cloud); % the cloud - 0-1 V

t = [0:(1/SF):0.5]; 
BBN =  wgn(1,length(t),1);                                                 % BBN creation
BBN = BBN + abs(min(BBN));
BBN = (BBN / max(BBN)) * 1 * 0.99;
A.loadWaveform((length(attenuations)+2), BBN); % BBN entry signal
%load serial messages - play cloud in 6 attenuations on channel 2
%(messages 1-6), play cue on channel 1 (message 7), play BBN chan 1
%(message 8)

LoadSerialMessages('WavePlayer1', {['P',1,0],['P',1,1],['P',1,2],['P',1,3]...
    ,['P',1,4],['P',1,5],['P',2,6], ['P', 2, 7], ['S']});
%%
% Loading the sequences to the data so it would be saved for later
% analysis.
BpodSystem.Data=struct;
BpodSystem.Data.cloud = filtered_cloud;
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
BpodSystem.GUIData.animals.not_active=zeros(size(BpodSystem.GUIData.animals.animals_names));

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
end