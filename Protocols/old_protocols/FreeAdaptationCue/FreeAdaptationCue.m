%{
PortAdaptation
Supplies reward for the first nosepoke in the port (5 ul).
port 1 is active, port 4 is presence detection.

%}

function FreeAdaptationCue

global BpodSystem

%% Define parameters
S = BpodSystem.ProtocolSettings; % Load settings chosen in run_protocol_single_trial into current workspace as a struct called S
if isempty(fieldnames(S))  % If settings file was an empty struct, populate struct with default settings
    S.GUI.RewardAmount = 10; %ul
    S.GUI.CueType = 'auditory';
    S.GUI.SoundDuration = 1; % Duration of sound (s)
    S.GUI.SinWaveFreq = 4000; % Frequency of right cue
end

%% Define trials
CueTypes = S.GUI.CueType;
switch CueTypes
    case 'visual'
        CueAction = {'PWM1', S.GUI.CueIntensity};
        CueStop = ['PWM1', 0];
        WaitAction={};
    
    case 'auditory'
        if (isfield(BpodSystem.ModuleUSB, 'WavePlayer1'))
            WavePlayerUSB = BpodSystem.ModuleUSB.WavePlayer1;
        else
            error('Error: To run this protocol, you must first pair the WavePlayer1 module with its USB port. Click the USB config button on the Bpod console.')
        end
        
        %% Create an instance of the audioPlayer module
        A = BpodWavePlayer(WavePlayerUSB);
         
       
       
        
        %% Program sound server
        A.SamplingRate = 50000; % max in 4 ch configurationn.
        A.BpodEvents = {'On','On','On','On'};
        A.TriggerMode = 'Master';
        A.TriggerProfileEnable = 'Off';
        A.TriggerProfiles(1,:) = [1 0 0 0 ];
        
        
        %A.OutputRange = ;        
        SF = A.SamplingRate; 
        % Set Bpod serial message library with correct codes to trigger sounds 1-4 on analog output channels 1-2
        analogPortIndex = find(strcmp(BpodSystem.Modules.Name, 'WavePlayer1'));
        if isempty(analogPortIndex)
            error('Error: Bpod WavePlayer module not found. If you just plugged it in, please restart Bpod.')
        end
        
        % Remember values of left and right frequencies & durations, so a new one only gets uploaded if it was changed
        %load the module with instruction, 1=play#0, 2=play#1 ....
        if S.GUI.SinWaveFreq ~= BpodSystem.GUIData.LastFrequency
            Sound = sound_generator(SF, S.GUI.SinWaveFreq, S.GUI.SoundDuration); % Sampling freq (hz), Sine frequency (hz), duration (s)
            %Sound = GenerateSineWave(SF, S.GUI.SinWaveFreq, S.GUI.SoundDuration);
            A.loadWaveform(1, Sound);
            BpodSystem.GUIData.LastFrequency = S.GUI.SinWaveFreq;
            LoadSerialMessages('WavePlayer1', {['P' ,1, 0 ]});
        end
           
        %%
        %CueAction = {'WavePlayer1', 1};% deliver sound stimulus..
        CueAction = {'WavePlayer1', 1};
        BpodSystem.GUIData.LastFrequency = S.GUI.SinWaveFreq;
               
        
end

%% Initialize GUI
% BpodParameterGUI('init', S); % Initialize parameter GUI plugin

%% The state matrix
%S = BpodParameterGUI('sync', S); % Sync parameters with BpodParameterGUI plugin
R = GetValveTimes(S.GUI.RewardAmount, 1 ); ValveTime = R; % Update reward amounts

sma = NewStateMatrix(); % Assemble state matrix
sma = SetCondition(sma, 1, 'Port4', 1); % a condition where port 4 is in 
sma = SetCondition(sma, 2, 'Port4', 0); % a condition where port 4 is our
sma = AddState(sma, 'Name', 'WaitForPresence', ...
    'Timer', 4,... %what are the units? seconds?
    'StateChangeConditions', {'Port4In','WaitForPoke','Condition1', 'WaitForPoke', 'Port4Out','exit', 'Tup', 'exit'},...
    'OutputActions', {});
sma = AddState(sma, 'Name', 'WaitForPoke', ...
    'Timer', S.GUI.SoundDuration,...
    'StateChangeConditions', {'Port1In', 'Reward', 'Condition2','exit','Tup','CueOff'},...
    'OutputActions',  CueAction);
sma = AddState(sma, 'Name', 'CueOff', ...
    'Timer', 0,...
    'StateChangeConditions', {'Port1In', 'Reward', 'Condition2','exit'},...
    'OutputActions',  {});
sma = AddState(sma, 'Name', 'Reward', ...
    'Timer', ValveTime,...
    'StateChangeConditions', {'Tup', 'Drinking', 'Condition2','exit'},...
    'OutputActions', {'ValveState', 1 });
sma = AddState(sma, 'Name', 'Drinking', ...
    'Timer', 0,...
    'StateChangeConditions', {'Port1In', 'Reward','Condition2','exit'},...
    'OutputActions',  {});


SendStateMatrix(sma);
RawEvents = RunStateMatrix;

if ~isempty(fieldnames(RawEvents)) % If trial data was returned
    BpodSystem.Data = add_trial_events_RF(BpodSystem.Data,RawEvents); % Computes trial events from raw data
    %BpodSystem.Data = BpodNotebook('sync', BpodSystem.Data); % Sync with Bpod notebook plugin
    
    trial_number=BpodSystem.Data.nTrials;
    % save trial type into data (important whene randomizing...):
    BpodSystem.Data.CueTypes(trial_number) = {CueTypes};
    
    %update the visit count graph
    visit_plot(BpodSystem.GUIHandles.visit_count, 'update',BpodSystem.GUIData.SubjectName)
    
    %Check if the trial reached state 'drinking' and save reward
    %amount given:
    % update reward delivered graph:
    if ~isnan(BpodSystem.Data.RawEvents.Trial{1,  trial_number}.States.Drinking(1,1))
        BpodSystem.Data.reward_supplied(trial_number)=S.GUI.RewardAmount;
        reward_supplied_plot(BpodSystem.GUIHandles.reward_supplied,'update', BpodSystem.GUIData.SubjectName, BpodSystem.Data.reward_supplied(trial_number))
    end
    
    
    %Save this trial data to the pre-defined file name (in prepare to
    %protocol function)
    SessionData = BpodSystem.Data;
    save(BpodSystem.Path.CurrentDataFile, 'SessionData', '-v6');
end
HandlePauseCondition; % Checks to see if the protocol is paused. If so, waits until user resumes.
if BpodSystem.Status.BeingUsed == 0
    return
end