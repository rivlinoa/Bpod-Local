%{
Test
This is a Dummy protocol serves to test multiple issues


%}

function Test

global BpodSystem

%% Define parameters
S = BpodSystem.ProtocolSettings; % Load settings chosen in run_protocol_single_trial into current workspace as a struct called S
if isempty(fieldnames(S))  % If settings file was an empty struct, populate struct with default settings
    S.GUI.RewardAmount = 5; % ul
end

%% The state matrix
%S = BpodParameterGUI('sync', S); % Sync parameters with BpodParameterGUI plugin
R = GetValveTimes(S.GUI.RewardAmount, 1 ); ValveTime = R; % Update reward amounts
sma = NewStateMatrix(); % Assemble state matrix
sma = SetCondition(sma, 2, 'Port4', 1); % set condition to check presence detection 
sma = AddState(sma, 'Name', 'WaitForPresence', ...
    'Timer', 0,... %what are the units? seconds?
    'StateChangeConditions', {'Port1In','Delay'},...
    'OutputActions', {});
sma = AddState(sma, 'Name', 'Delay', ...
    'Timer', 0,...
    'StateChangeConditions', {'Port1Out','exit', 'Condition2', 'exit'},...
    'OutputActions', {});

SendStateMatrix(sma);
RawEvents = RunStateMatrix;

if ~isempty(fieldnames(RawEvents)) % If trial data was returned
    BpodSystem.Data = add_trial_events_RF(BpodSystem.Data,RawEvents); % Computes trial events from raw data
    %BpodSystem.Data = BpodNotebook('sync', BpodSystem.Data); % Sync with Bpod notebook plugin
    
    trial_number=BpodSystem.Data.nTrials;
   
    %Save this trial data to the pre-defined file name (in prepare to
    %protocol function)
    SessionData = BpodSystem.Data;
    save(BpodSystem.Path.CurrentDataFile, 'SessionData', '-v6');
end
HandlePauseCondition; % Checks to see if the protocol is paused. If so, waits until user resumes.
if BpodSystem.Status.BeingUsed == 0
    return
end