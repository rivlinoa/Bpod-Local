%
function LickResponseTDT
global BpodSystem
S = BpodSystem.ProtocolSettings;     % Load settings chosen in run_protocol_single_trial into current workspace as a struct called S
if isempty(fieldnames(S))            % If settings file was an empty struct, populate struct with default settings
    S.GUI.RewardAmount = 5;          % ul
    S.GUI.ResponseDuration = 1.5;    % sec
    S.GUI.LightProb = 0.25;           % Between 0-1, fraction of trials that would have auditory+visual stimulus.
    S.GUI.RewardProb = 1;            % Between 0-1, fraction of correct trials that would be rewarded.
    S.GUI.LightIntensity = 15;       % 1-255
    S.GUI.MaxDelay = 3;              % sec
    S.GUI.MinDelay = 0.5;            % sec
end

BpodParameterGUI('init', S);
BpodNotebook('init'); % Initialize Bpod notebook (for manual data annotation)

%% Initialize plots


%% 
MaxTrials = 10000;
REPORT_LATE_TIMER = 2;

for currentTrial = 1:MaxTrials
    S = BpodParameterGUI('sync', S); % Sync parameters with BpodParameterGUI plugin
    R = GetValveTimes(S.GUI.RewardAmount, 1 ); ValveTime = R;
    Delay = S.GUI.MinDelay + rand()*(S.GUI.MaxDelay-S.GUI.MinDelay);
    
    if rand(1)<=S.GUI.LightProb
             CueAction = {'PWM1', S.GUI.LightIntensity};
             Cuetype = 'AudVis';
             IsLight=1;
    else 
             CueAction = {};      % only auditory produced by TDT
             Cuetype ='Aud';
             IsLight=0;
    end
    
    
    if rand(1) <= S.GUI.RewardProb
        RewardAction = {'ValveState', 1, 'BNCState', 1,'GlobalTimerTrig',2};
        IsReward = 1;           % if there would be a reward for correct trial
    else 
        RewardAction = {'ValveState', 1, 'BNCState', 1,'GlobalTimerTrig',2};
        IsReward = 1;           % if there would be a reward for correct trial
    end 
    
    
    sma = NewStateMatrix();     % Assemble state matrix
    sma = SetGlobalTimer(sma, 1, Delay+S.GUI.ResponseDuration); 
    sma = SetGlobalTimer(sma, 2, (S.GUI.ResponseDuration+3)); 
    sma = AddState(sma, 'Name', 'WaitForBBN', ...
        'Timer', 0,...
        'StateChangeConditions', {'Port1In', 'ReportLick', 'BNC1High', 'Delay'},...
        'OutputActions', {}); 
    sma = AddState(sma, 'Name', 'ReportLick', ...
        'Timer', 0.001,...
        'StateChangeConditions', {'Tup', '>back'},...
        'OutputActions', {'BNCState', 1});
    sma = AddState(sma, 'Name', 'Delay', ...
        'Timer', Delay,...
        'StateChangeConditions', {'Tup', 'CueTrig', 'Port1In', 'ReportPremature'},...
        'OutputActions', {'GlobalTimerTrig',1}); 
    sma = AddState(sma, 'Name', 'ReportPremature', ...
        'Timer', 0.001,...
        'StateChangeConditions', {'Tup', 'exit'},...
        'OutputActions', {'BNCState', 1});
    sma = AddState(sma, 'Name', 'CueTrig', ...
        'Timer', 0.001,...
        'StateChangeConditions', {'Port1In', 'exit', 'Tup', 'CueOn'},...
        'OutputActions', {'BNCState', 2});
    sma = AddState(sma, 'Name', 'CueOn', ...
        'Timer', 0,...
        'StateChangeConditions', {'Port1In', 'Reward','GlobalTimer1_End', 'Report_late' },...
        'OutputActions', CueAction);
     sma = AddState(sma, 'Name', 'Report_late', ...
        'Timer', REPORT_LATE_TIMER,...
        'StateChangeConditions', {'Port1In', 'ReportLick','Tup', 'exit' },...
        'OutputActions', CueAction);
    sma = AddState(sma, 'Name', 'Reward', ...
        'Timer', ValveTime,...
        'StateChangeConditions', {'Tup', 'Drinking'},...
        'OutputActions', RewardAction); 
    sma = AddState(sma, 'Name', 'Drinking', ...
        'Timer', 0,...
        'StateChangeConditions', {'GlobalTimer2_End', 'exit', 'Port1In', 'ReportLick'},...
        'OutputActions', {}); 
    
    SendStateMatrix(sma);
    RawEvents = RunStateMatrix;
    if ~isempty(fieldnames(RawEvents)) % If trial data was returned
        BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents); % Computes trial events from raw data
        BpodSystem.Data.TrialSettings(currentTrial) = S; % Adds the settings used for the current trial to the Data struct (to be saved after the trial ends)
        BpodSystem.Data.Cuetype{currentTrial} = Cuetype; % Adds the trial type of the current trial to data
        BpodSystem.Data.IsLight(currentTrial) = IsLight; % Adds the trial type of the current trial to data
        BpodSystem.Data.Delay(currentTrial) = Delay; % Adds the trial type of the current trial to data
        BpodSystem.Data.IsReward(currentTrial) = IsReward; % Adds the trial type of the current trial to data
        BpodSystem.Data.Settings{currentTrial} = S; % Adds the trial type of the current trial to data
        
        BpodSystem.Data = BpodNotebook('sync', BpodSystem.Data); % Sync with Bpod notebook plugin
        SaveBpodSessionData; % Saves the field BpodSystem.Data to the current data file
    end
    HandlePauseCondition; % Checks to see if the protocol is paused. If so, waits until user resumes.
    if BpodSystem.Status.BeingUsed == 0
        return
    end
end
end