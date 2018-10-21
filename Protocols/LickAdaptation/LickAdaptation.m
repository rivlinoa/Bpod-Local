function LickAdaptation
% This protocol introduces a naive mouse to water available in the lick
% port.

global BpodSystem
S = BpodSystem.ProtocolSettings; % Load settings chosen in launch manager into current workspace as a struct called S
if isempty(fieldnames(S))  % If settings file was an empty struct, populate struct with default settings
    S.GUI.RewardAmount = 5; %ul
end
MaxTrials = 100000;

% BpodSystem.ProtocolFigures.LickCount = figure('name','Outcome plot','numbertitle','off', 'MenuBar', 'none', 'Resize', 'off');
% BpodSystem.GUIHandles.OutcomePlot = axes('Position', [.075 .3 .89 .6]);
 BpodParameterGUI('init', S); % Initialize parameter GUI plugin
% BpodSystem.GUIData.animals.reward_supplied=zeros(size(BpodSystem.GUIData.animals.animals_names));
% BpodSystem.GUIData.animals.visit_count=zeros(size(BpodSystem.GUIData.animals.animals_names));
% BpodSystem.ProtocolFigures.reward_supplied = figure('name','Reward supplied','numbertitle','off', 'MenuBar', 'none', 'Resize', 'off');
% BpodSystem.GUIHandles.reward_supplied = axes();
% reward_supplied_plot(BpodSystem.GUIHandles.reward_supplied,'init');
% 
% BpodSystem.ProtocolFigures.visit_count = figure('name','Visit count','numbertitle','off', 'MenuBar', 'none', 'Resize', 'off');
% BpodSystem.GUIHandles.visit_count = axes();
% visit_plot(BpodSystem.GUIHandles.visit_count,'init');

for currentTrial = 1:MaxTrials
    %S = BpodParameterGUI('sync', S); % Sync parameters with BpodParameterGUI plugin
    R = GetValveTimes(S.GUI.RewardAmount, 1); 
    ValveTime = R; % Update reward amounts
    sma = NewStateMatrix(); % Assemble state matrix
    sma = AddState(sma, 'Name', 'WaitForLick', ...
        'Timer', 0,...
        'StateChangeConditions', {'Port1In', 'Reward'},...
        'OutputActions', {}); 
    sma = AddState(sma, 'Name', 'Reward', ...
        'Timer', ValveTime,...
        'StateChangeConditions', {'Tup', 'Drinking'},...
        'OutputActions', {'ValveState', 1,'BNCState', 1 });
    sma = AddState(sma, 'Name', 'Drinking', ...
        'Timer', 1,...
        'StateChangeConditions', {'Tup', 'exit'},...
        'OutputActions', {});
    SendStateMatrix(sma);
    RawEvents = RunStateMatrix;
    if ~isempty(fieldnames(RawEvents)) % If trial data was returned
        BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents); % Computes trial events from raw data
        BpodSystem.Data.TrialSettings(currentTrial) = S; % Adds the settings used for the current trial to the Data struct (to be saved after the trial ends)
        SaveBpodSessionData; % Saves the field BpodSystem.Data to the current data file
    end
    HandlePauseCondition; % Checks to see if the protocol is paused. If so, waits until user resumes.
    if BpodSystem.Status.BeingUsed == 0
        return
    end
end
end 
    
    