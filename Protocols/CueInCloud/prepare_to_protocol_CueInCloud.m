%{
----------------------------------------------------------------------------

function PREPARE_TO_PROTOCOL_CUEINCLOUD creates all files needed for data saving,
and initiates the Bpod object.
it also loads thw waveplayer with the cloud and cue signal to be played.

----------------------------------------------------------------------------
% Created by Noa, 21.6.18,
% Eddited 3.10.18
%}


function prepare_to_protocol_CueInCloud(animals)

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
global A

% Program sound server
A.SamplingRate = 50000; % max in 4 ch configurationn.
SF = A.SamplingRate;
A.BpodEvents = {'On','On','On','On'};
A.TriggerMode = 'Master';
A.OutputRange = '0V:5V';
load('C:\Users\owner\Documents\Bpod Local\Protocols\CueInCloud\cloud.mat');
load('C:\Users\owner\Documents\Bpod Local\Protocols\CueInCloud\cue.mat');
cue = cue.*5.*0.99; % maximal rage in 0-5v outputrange
stim = stim.*(5).*0.99;% maximal rage in 0-5v outputrange

attenuations = logspace(-0.2,1,6);
cloudmat = attenuations'*stim.*0.1;

for i=1:length(attenuations)
    A.loadWaveform(i, cloudmat(i,:)); % the cloud, for now only one with 10 attenuations...
end
A.loadWaveform(11, cue); % the cue - maximal volume

%load serial messages - play cloud in 10 attenuations on channel 2
%(messages 1-10), play cue on channel 1 (message 11)
LoadSerialMessages('WavePlayer1', {['P',2,0],['P',2,1],['P',2,2],['P',2,3]...
    ,['P',2,4],['P',2,5],['P',2,6],['P',2,7],['P',2,8],['P',2,9],['P',1,10],['S']});
%%
% Loading the sequences to the data so it would be saved for later
% analysis.
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