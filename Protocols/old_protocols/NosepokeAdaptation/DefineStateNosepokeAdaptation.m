
function FinalState=DefineStateNosepokeAdaptation(data)
SessionData=data;

state='';
% Define the result of the trial:
%First maeke sure there was presence detection - is not this is omitted
%trial.
if isnan(SessionData.RawEvents.Trial{1,1}.States.WaitForPresence)
    state='Omitted';
end
%If there was no stimulus presented - differentiate between omitted and
%premature response:
if isnan(SessionData.RawEvents.Trial{1,1}.States.DeliverStimulus)
    state='Omitted';
    if ~isnan(SessionData.RawEvents.Trial{1,1}.States.Punish)
        state='PreMature';
    end
else
    %If there was a stimuuls; if no punish then omitted (will be
    %changed later if its a rewarded trial). if punish before time out
    %<- side, if timeout before punish <- late.
    if isnan(SessionData.RawEvents.Trial{1,1}.States.Punish)
        state='Omitted';
    end
    if SessionData.RawEvents.Trial{1,1}.States.TimeOut(1)<SessionData.RawEvents.Trial{1,1}.States.Punish(1)
        state='Late';
    elseif SessionData.RawEvents.Trial{1,1}.States.TimeOut(1)>SessionData.RawEvents.Trial{1,1}.States.Punish(1)
        state='Side';
    end
end

if ~isnan(SessionData.RawEvents.Trial{1,1}.States.Reward)
    state='Reward';
    
end
FinalState={state};
end

