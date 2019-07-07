function LickAdaptationCgae
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
% BpodParameterGUI('init', S); % Initialize parameter GUI plugin
% BpodSystem.GUIData.animals.reward_supplied=zeros(size(BpodSystem.GUIData.animals.animals_names));
% BpodSystem.GUIData.animals.visit_count=zeros(size(BpodSystem.GUIData.animals.animals_names));
% BpodSystem.ProtocolFigures.reward_supplied = figure('name','Reward supplied','numbertitle','off', 'MenuBar', 'none', 'Resize', 'off');
% BpodSystem.GUIHandles.reward_supplied = axes();
% reward_supplied_plot(BpodSystem.GUIHandles.reward_supplied,'init');
% 
% BpodSystem.ProtocolFigures.visit_count = figure('name','Visit count','numbertitle','off', 'MenuBar', 'none', 'Resize', 'off');
% BpodSystem.GUIHandles.visit_count = axes();
% visit_plot(BpodSystem.GUIHandles.visit_count,'init');
%'Port4In','WaitForLick',

    %S = BpodParameterGUI('sync', S); % Sync parameters with BpodParameterGUI plugin
    R = GetValveTimes(S.GUI.RewardAmount, 1); 
    ValveTime = R; % Update reward amounts
    sma = NewStateMatrix(); % Assemble state matrix
    sma = SetCondition(sma, 1, 'Port4', 1); % a condition where port 4 is in
    sma = SetCondition(sma, 2, 'Port4', 0); % a condition where port 4 is out
    sma = AddState(sma, 'Name', 'WaitForPresence', ...
    'Timer', 1,... %what are the units? seconds?
    'StateChangeConditions', {'Condition1', 'WaitForLick', 'Port4Out','exit', 'Tup', 'exit'},...
    'OutputActions', {});
    sma = AddState(sma, 'Name', 'WaitForLick', ...
        'Timer', 0,...
        'StateChangeConditions', {'Port1In', 'Reward','Condition2','exit'},...
        'OutputActions', {}); 
    sma = AddState(sma, 'Name', 'Reward', ...
        'Timer', ValveTime,...
        'StateChangeConditions', {'Tup', 'Drinking','Condition2','exit'},...
        'OutputActions', {'ValveState', 1});
    sma = AddState(sma, 'Name', 'Drinking', ...
        'Timer', 1,...
        'StateChangeConditions', {'Tup','WaitForLick','Condition2','exit'},...
        'OutputActions', {});
    SendStateMatrix(sma);
    RawEvents = RunStateMatrix;
    if ~isempty(fieldnames(RawEvents)) % If trial data was returned
    BpodSystem.Data = add_trial_events_RF(BpodSystem.Data,RawEvents); % Computes trial events from raw data
    % BpodSystem.Data = BpodNotebook('sync', BpodSystem.Data); % Sync with Bpod notebook plugin
    
    trial_number=BpodSystem.Data.nTrials;
    % save trial type into data (important whene randomizing...):
    
    
    
    % update the visit count graph
    % If the figure was closed, first initiate it and then update it:
    if isvalid(BpodSystem.GUIHandles.visit_count)
        visit_plot(BpodSystem.GUIHandles.visit_count, 'update',BpodSystem.GUIData.SubjectName)
    end
    if ~isnan(BpodSystem.Data.RawEvents.Trial{1,  trial_number}.States.Drinking(1,1))
        BpodSystem.Data.reward_supplied(trial_number)=...
            S.GUI.RewardAmount*length(BpodSystem.Data.RawEvents.Trial{1,  trial_number}.States.Drinking);
        
        if isvalid(BpodSystem.GUIHandles.reward_supplied)
            reward_supplied_plot(BpodSystem.GUIHandles.reward_supplied,'update', BpodSystem.GUIData.SubjectName, BpodSystem.Data.reward_supplied(trial_number))

        end
    end
    end    
    HandlePauseCondition; % Checks to see if the protocol is paused. If so, waits until user resumes.
    if BpodSystem.Status.BeingUsed == 0
        return
    end

end 
    