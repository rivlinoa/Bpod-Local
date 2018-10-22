function NotActive

global BpodSystem
%% Define parameters
S = BpodSystem.ProtocolSettings; % Load settings chosen in run_protocol_single_trial into current workspace as a struct called S
if isempty(fieldnames(S))  % If settings file was an empty struct, populate struct with default settings
    S.GUI = []; 
end


sma = NewStateMatrix(); % Assemble state matrix
sma = AddState(sma, 'Name', 'ReportEntry', ...
    'Timer', 0.01,... 
    'StateChangeConditions', {'Tup', 'exit'},...
    'OutputActions', {});

SendStateMatrix(sma);
RawEvents = RunStateMatrix;

if ~isempty(fieldnames(RawEvents)) % If trial data was returned
    BpodSystem.Data = add_trial_events_RF(BpodSystem.Data,RawEvents); % Computes trial events from raw data
    trial_number=BpodSystem.Data.nTrials;
    
    if isvalid(BpodSystem.GUIHandles.not_active)
        not_active_plot(BpodSystem.GUIHandles.not_active, 'update',BpodSystem.GUIData.SubjectName)
    else
        not_active_plot(BpodSystem.GUIHandles.not_active, 'init')
        not_active_plot(BpodSystem.GUIHandles.not_active, 'update',BpodSystem.GUIData.SubjectName)
    end
    
      
    %Save this trial data to the pre-defined file name (by prepare to
    %protocol function)
    SessionData = BpodSystem.Data;
    save(BpodSystem.Path.CurrentDataFile, 'SessionData', '-v6');
end
end 

