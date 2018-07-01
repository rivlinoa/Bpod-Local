%{
PortAdaptation
Supplies reward for the first nosepoke in the port (5 ul). 
port 1 is active, port 4 is presence detection. 

%}

function PortAdaptation

global BpodSystem

%% Define parameters
S = BpodSystem.ProtocolSettings; % Load settings chosen in run_protocol_single_trial into current workspace as a struct called S
if isempty(fieldnames(S))  % If settings file was an empty struct, populate struct with default settings
    S.GUI.RewardAmount = 5; %ul
end

%% Define trials
TrialTypes = 1; %1 just as default value, has no meaning, this is where we implement trial randomization. 
BpodSystem.Data.TrialTypes = []; % The trial type of each trial completed will be added here.

%% Initialize GUI
% BpodParameterGUI('init', S); % Initialize parameter GUI plugin

%% The state matrix
    %S = BpodParameterGUI('sync', S); % Sync parameters with BpodParameterGUI plugin
    R = GetValveTimes(S.GUI.RewardAmount, 1 ); ValveTime = R; % Update reward amounts
                   
    sma = NewStateMatrix(); % Assemble state matrix
    sma = AddState(sma, 'Name', 'WaitForPresence', ...
        'Timer', 4,... %what are the units? seconds?
        'StateChangeConditions', {'Port4In', 'WaitForPoke', 'Port4Out','exit', 'Tup', 'exit'},...
        'OutputActions', {}); 
    sma = AddState(sma, 'Name', 'WaitForPoke', ...
        'Timer', 0,...
        'StateChangeConditions', {'Port1In', 'Reward', 'Port4Out','exit'},...
        'OutputActions', {}); 
    sma = AddState(sma, 'Name', 'Reward', ...
        'Timer', ValveTime,...
        'StateChangeConditions', {'Tup', 'Drinking', 'Port4Out','exit'},...
        'OutputActions', {'ValveState', 1});
    sma = AddState(sma, 'Name', 'Drinking', ...
        'Timer', 0,...
        'StateChangeConditions', {'Port4Out','exit'},...
        'OutputActions', {});

    
    SendStateMatrix(sma);
    RawEvents = RunStateMatrix;
    if ~isempty(fieldnames(RawEvents)) % If trial data was returned
        BpodSystem.Data = add_trial_events_RF(BpodSystem.Data,RawEvents); % Computes trial events from raw data
        BpodSystem.Data = BpodNotebook('sync', BpodSystem.Data); % Sync with Bpod notebook plugin
       
        BpodSystem.Data.TrialTypes = TrialTypes; % Change that line to add the current one at the end.
        
      %Save this trial data to the pre-defined file name (in prepare to
      %protocol function) 
        SessionData = BpodSystem.Data;
        save(BpodSystem.Path.CurrentDataFile, 'SessionData', '-v6');
    end
    HandlePauseCondition; % Checks to see if the protocol is paused. If so, waits until user resumes.
    if BpodSystem.Status.BeingUsed == 0
        return
    end