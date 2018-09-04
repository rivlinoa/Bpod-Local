%{
%% CueInCloud
Following entry a tone cloud is played (or not, with some probability), in one of 10 attenuations
(logathimically spaced). 0 attenuation in the data coresponds to no cloud. 
After a random delay (default max 1 sec), a cue is
played in a second speaker. Cue is auditory or auditory + visual with some probability.
Bpod supplies reward for the first nosepoke in the port (default 10 ul) when the cue is active.
If there i a premature nosepoke the que will not be played, though the
cloud (3 sec long) will not be stopped. 
port 1 is active, port 4 is presence detection.

* currently while drinking is stops the cloud. 
%}

function CueInCloud

global BpodSystem
global A
%% Define parameters
S = BpodSystem.ProtocolSettings; % Load settings chosen in run_protocol_single_trial into current workspace as a struct called S
if isempty(fieldnames(S))  % If settings file was an empty struct, populate struct with default settings
    S.GUI.RewardAmount = 10; % ul
    S.GUI.ResponseDuration = 3;
    S.GUI.MaxDelay = 2; % sec
    S.GUI.MinDelay = 0.5; % sec
    S.GUI.LightProb = 1; % Between 0-1, fraction of trials that would have auditory+visual stimulus.  
    S.GUI.CloudProb = 1; % Between 0-1, fraction of trials that would have tone cloud during delay . 
    S.GUI.LightCloudProb = 1; % prob of light in cloud trials
    S.GUI.DifficultyProb = 1;% Between 0-1, the proportion of easy trials (bottom 2 attenuations). 
end

if ~isfield(BpodSystem.GUIData,'ParameterGUI')
    BpodParameterGUI('init', S);
end

%% Define trials

%decide what is the cue type based on light probability
if rand(1) <= S.GUI.LightProb
    CueAction = {'WavePlayer1', 11,'PWM1', 255 }; % deliver cue stimulus + led on.
    Cuetype = 'AudVis';
else 
    CueAction = {'WavePlayer1', 11};% deliver cue stimulus on channel 1
    Cuetype = 'Aud';
end


% set the cloud attenuation (1-10) base on difficulty probability
attencloud = 1;
if rand(1) <= S.GUI.DifficultyProb
    attencloud = randi(2);
else
    attencloud = randi(10);
end 

% decide if to have a cloud at all based on cloud probability
if rand(1) <= S.GUI.CloudProb
    CloudAction = {'WavePlayer1', attencloud}; % deliver sound stimulus..
    CueAction = {'WavePlayer1', 11,'PWM1', 255 }; % deliver cue stimulus + led on.
    Cuetype = 'AudVis';
else 
    CloudAction = {};
    attencloud = 0; % corresponds to no cloud
end 



StopAction = {'WavePlayer1', 12};

% define the delay
Delay = S.GUI.MinDelay + rand()*(S.GUI.MaxDelay-S.GUI.MinDelay);

%% The state matrix
%S = BpodParameterGUI('sync', S); % Sync parameters with BpodParameterGUI plugin
R = GetValveTimes(S.GUI.RewardAmount, 1 ); ValveTime = R; % Update reward amounts
sma = NewStateMatrix(); % Assemble state matrix
sma = SetCondition(sma, 1, 'Port4', 1); % a condition where port 4 is in
sma = SetCondition(sma, 2, 'Port4', 0); % a condition where port 4 is out
sma = AddState(sma, 'Name', 'WaitForPresence', ...
    'Timer', 1,... %what are the units? seconds?
    'StateChangeConditions', {'Port4In','Delay','Condition1', 'Delay', 'Port4Out','exit', 'Tup', 'exit'},...
    'OutputActions', {});
sma = AddState(sma, 'Name', 'Delay', ...
    'Timer', Delay,...
    'StateChangeConditions', {'Port1In','WaitForExit', 'Tup', 'CueOn', 'Condition2','exit'},...
    'OutputActions', CloudAction);
sma = AddState(sma, 'Name', 'CueOn', ...
    'Timer', S.GUI.ResponseDuration,...
    'StateChangeConditions', {'Port1In', 'Reward','Tup', 'WaitForExit', 'Condition2','exit'},...
    'OutputActions', CueAction );
sma = AddState(sma, 'Name', 'Reward', ...
    'Timer', ValveTime,...
    'StateChangeConditions', {'Tup', 'Drinking', 'Condition2','exit'},...
    'OutputActions', {'ValveState', 1});
sma = AddState(sma, 'Name', 'Drinking', ...
    'Timer', 0,...
    'StateChangeConditions', {'Condition2','exit'},...
    'OutputActions', StopAction);
sma = AddState(sma, 'Name', 'WaitForExit', ...
    'Timer', 0,...
    'StateChangeConditions', {'Condition2','exit'},...
    'OutputActions', {});



SendStateMatrix(sma);
RawEvents = RunStateMatrix;

if ~isempty(fieldnames(RawEvents)) % If trial data was returned
    BpodSystem.Data = add_trial_events_RF(BpodSystem.Data,RawEvents); % Computes trial events from raw data
    % BpodSystem.Data = BpodNotebook('sync', BpodSystem.Data); % Sync with Bpod notebook plugin
end
    trial_number = BpodSystem.Data.nTrials;
    % save trial type into data (important whene randomizing...):
    BpodSystem.Data.Delay{trial_number} = Delay;
    BpodSystem.Data.attencloud{trial_number} = attencloud;
    BpodSystem.Data.CueTypes{trial_number} = Cuetype;
    
    % update the visit count graph
    % If the figure was closed, first initiate it and then update it:
    if isvalid(BpodSystem.GUIHandles.visit_count)
        visit_plot(BpodSystem.GUIHandles.visit_count, 'update',BpodSystem.GUIData.SubjectName)
%     else
%         visit_plot(BpodSystem.GUIHandles.visit_count, 'init')
%         visit_plot(BpodSystem.GUIHandles.visit_count, 'update',BpodSystem.GUIData.SubjectName)
%     end
    
    % Check if the trial reached state 'drinking' and save reward
    % amount given:
    % update reward delivered graph:
    if ~isnan(BpodSystem.Data.RawEvents.Trial{1,  trial_number}.States.Drinking(1,1))
        BpodSystem.Data.reward_supplied(trial_number)=S.GUI.RewardAmount;
        % If the figure was closed, first initiate it and then update it:
        if isvalid(BpodSystem.GUIHandles.reward_supplied)
            reward_supplied_plot(BpodSystem.GUIHandles.reward_supplied,'update', BpodSystem.GUIData.SubjectName, BpodSystem.Data.reward_supplied(trial_number))
%         else
%             reward_supplied_plot(BpodSystem.GUIHandles.reward_supplied, 'init')
%             reward_supplied_plot(BpodSystem.GUIHandles.reward_supplied,'update', BpodSystem.GUIData.SubjectName, BpodSystem.Data.reward_supplied(trial_number))
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