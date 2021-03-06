%{
CueAdaptation
Supplies reward for the first nosepoke in the port (5 ul) when the cue is active .
No punishment for pokes before or after the cue onset.
By default randon delay of 0-1 sec. setting MaxDelay to 0 will result in no
delay.
port 1 is active, port 4 is presence detection.

Cue could be either visula or auditory (default visual).

%}

function CueAdaptation

global BpodSystem

%% Define parameters
S = BpodSystem.ProtocolSettings; % Load settings chosen in run_protocol_single_trial into current workspace as a struct called S
if isempty(fieldnames(S))  % If settings file was an empty struct, populate struct with default settings
    S.GUI.RewardAmount = 5; % ul
     S.GUI.ResponseDuration = 3;
    S.GUI.CueType = 'visual';
    S.GUI.CueDuration = 3;
    S.GUI.CueIntensity = 255; % from 1 to 255
    S.GUI.MaxDelay = 2; % sec
    S.GUI.MinDelay = 0; % sec
    S.GUI.Delay = ' ';
    
end

if ~isfield(BpodSystem.GUIData,'ParameterGUI')
    BpodParameterGUI('init', S);
end


%% Define trials
CueTypes = S.GUI.CueType;
switch CueTypes
    case 'visual'
        CueAction = {'PWM1', S.GUI.CueIntensity};
    case 'auditory'
        CueAction = 1;% deliver sound stimulus..
end
Delay = rand() * S.GUI.MaxDelay;
%% Sync parameters GUI after randomization of delay time. :)

S.GUI.Delay = Delay;
BpodParameterGUI('sync', S);

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
    'StateChangeConditions', {'Port4In','Delay','Condition1', 'Delay', 'Port4Out','exit', 'Tup', 'exit'},...
    'OutputActions', {});
sma = AddState(sma, 'Name', 'Delay', ...
    'Timer', Delay,...
    'StateChangeConditions', {'Tup', 'CueOn', 'Condition2','exit'},...
    'OutputActions', {});
sma = AddState(sma, 'Name', 'CueOn', ...
    'Timer', S.GUI.CueDuration,...
    'StateChangeConditions', {'Port1In', 'Reward','Tup', 'WaitForExit', 'Condition2','exit'},...
    'OutputActions', CueAction );
sma = AddState(sma, 'Name', 'Reward', ...
    'Timer', ValveTime,...
    'StateChangeConditions', {'Tup', 'Drinking', 'Condition2','exit'},...
    'OutputActions', {'ValveState', 1});
sma = AddState(sma, 'Name', 'Drinking', ...
    'Timer', 0,...
    'StateChangeConditions', {'Condition2','exit'},...
    'OutputActions', {});
sma = AddState(sma, 'Name', 'WaitForExit', ...
    'Timer', 0,...
    'StateChangeConditions', {'Condition2','exit'},...
    'OutputActions', {});



SendStateMatrix(sma);
RawEvents = RunStateMatrix;

if ~isempty(fieldnames(RawEvents)) % If trial data was returned
    BpodSystem.Data = add_trial_events_RF(BpodSystem.Data,RawEvents); % Computes trial events from raw data
    % BpodSystem.Data = BpodNotebook('sync', BpodSystem.Data); % Sync with Bpod notebook plugin
    
    trial_number=BpodSystem.Data.nTrials;
    % save trial type into data (important whene randomizing...):
    BpodSystem.Data.CueTypes{trial_number} = CueTypes;
    BpodSystem.Data.Delay{trial_number} = Delay;
    
    % update the visit count graph
    % If the figure was closed, first initiate it and then update it:
    if isvalid(BpodSystem.GUIHandles.visit_count)
        visit_plot(BpodSystem.GUIHandles.visit_count, 'update',BpodSystem.GUIData.SubjectName)
    else
        visit_plot(BpodSystem.GUIHandles.visit_count, 'init')
        visit_plot(BpodSystem.GUIHandles.visit_count, 'update',BpodSystem.GUIData.SubjectName)
    end
    
    % Check if the trial reached state 'drinking' and save reward
    % amount given:
    % update reward delivered graph:
    if ~isnan(BpodSystem.Data.RawEvents.Trial{1,  trial_number}.States.Drinking(1,1))
        BpodSystem.Data.reward_supplied(trial_number)=S.GUI.RewardAmount;
        % If the figure was closed, first initiate it and then update it:
        if isvalid(BpodSystem.GUIHandles.reward_supplied)
            reward_supplied_plot(BpodSystem.GUIHandles.reward_supplied,'update', BpodSystem.GUIData.SubjectName, BpodSystem.Data.reward_supplied(trial_number))
        else
            reward_supplied_plot(BpodSystem.GUIHandles.reward_supplied, 'init')
            reward_supplied_plot(BpodSystem.GUIHandles.reward_supplied,'update', BpodSystem.GUIData.SubjectName, BpodSystem.Data.reward_supplied(trial_number))
        end
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