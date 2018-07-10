%{
updated from sanworks file by Noa 26.6.18

This function adds the current trial data into Bpod object data field. 
%}
function newTE = add_trial_events_RF(TE, RawTrialEvents)
global BpodSystem

if isfield(TE, 'RawEvents')
    TrialNum = length(TE.RawEvents.Trial) + 1;
else
    TrialNum = 1;
    TE.Info = struct;
    if BpodSystem.EmulatorMode == 1
        TE.Info.StateMachineVersion = 'Bpod 0.7-0.9 EMULATOR';
    else
        switch BpodSystem.MachineType
            case 1
                TE.Info.StateMachineVersion = 'Bpod 0.5';
            case 2
                TE.Info.StateMachineVersion = 'Bpod 0.7-0.9';
            case 3
                TE.Info.StateMachineVersion = 'Bpod 2.0';
        end
    end
    TE.Info.SessionDate = datestr(now, 1);
    
end
TheTime = now;
TE.Info.SessionStartTime_UTC{TrialNum} = datestr(TheTime);
TE.Info.SessionStartTime_MATLAB{TrialNum} = TheTime;
TE.nTrials = TrialNum;
%% Parse and add raw events for this trial
States = RawTrialEvents.States;
nPossibleStates = length(BpodSystem.StateMatrix.StateNames);
VisitedStates = zeros(1,nPossibleStates);
% determine unique states while preserving visited order
UniqueStates = zeros(1,nPossibleStates);
nUniqueStates = 0;
UniqueStateIndexes = zeros(1,length(States));
for x = 1:length(States)
    if sum(UniqueStates == States(x)) == 0
        nUniqueStates = nUniqueStates + 1;
        UniqueStates(nUniqueStates) = States(x);
        VisitedStates(States(x)) = 1;
        UniqueStateIndexes(x) = nUniqueStates;
    else
        UniqueStateIndexes(x) = find(UniqueStates == States(x));
    end
end
UniqueStates = UniqueStates(1:nUniqueStates);
UniqueStateDataMatrices = cell(1,nUniqueStates);
% Create a 2-d matrix for each state in a cell array
for x = 1:length(States)
    UniqueStateDataMatrices{UniqueStateIndexes(x)} = [UniqueStateDataMatrices{UniqueStateIndexes(x)}; [RawTrialEvents.StateTimestamps(x) RawTrialEvents.StateTimestamps(x+1)]];
end
for x = 1:nUniqueStates
    TE.RawEvents.Trial{TrialNum}.States.(BpodSystem.StateMatrix.StateNames{UniqueStates(x)}) = UniqueStateDataMatrices{x};
end
for x = 1:nPossibleStates
    if VisitedStates(x) == 0
        TE.RawEvents.Trial{TrialNum}.States.(BpodSystem.StateMatrix.StateNames{x}) = [NaN NaN];
    end
end
Events = RawTrialEvents.Events;
for x = 1:length(Events)
    TE.RawEvents.Trial{TrialNum}.Events.(BpodSystem.StateMachineInfo.EventNames{Events(x)}) = RawTrialEvents.EventTimestamps(Events == Events(x));
end
TE.RawData.OriginalStateNamesByNumber{TrialNum} = BpodSystem.StateMatrix.StateNames;
TE.RawData.OriginalStateData{TrialNum} = RawTrialEvents.States;
TE.RawData.OriginalEventData{TrialNum} = RawTrialEvents.Events;
TE.RawData.OriginalStateTimestamps{TrialNum} = RawTrialEvents.StateTimestamps;
TE.RawData.OriginalEventTimestamps{TrialNum} = RawTrialEvents.EventTimestamps;
TE.TrialStartTimestamp(TrialNum) = RawTrialEvents.TrialStartTimestamp;
TE.TrialEndTimestamp(TrialNum) = RawTrialEvents.TrialEndTimestamp;
TE.RawData.StateMachineErrorCodes{TrialNum} = RawTrialEvents.ErrorCodes;
TE.SettingsFile{TrialNum} = BpodSystem.Path.Settings;
TE.RFID{TrialNum}=BpodSystem.GUIData.SubjectName; 
TE.ProtocolName{TrialNum}=BpodSystem.GUIData.ProtocolName;

newTE = TE;
