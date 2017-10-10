load FileName;
tmp=struct;
for trial=1:size(SessionData.RFID,1)
    tmp.RFID{trial}= SessionData.RFID(trial,:);
    
    % Define the reward amount of the trial:
    RewardAmount=SessionData.TrialSettings(trial).GUI.RewardAmount;
    if ~isnan(SessionData.RawEvents(trial).Trial{1,1}.States.Reward)
        tmp.Reward(trial)=RewardAmount;
    else
        tmp.Reward(trial)=0;
    end
    
    % Define the result of the trial:
    %First maeke sure there was presence detection - is not this is omitted
    %trial.
    if isnan(SessionData.RawEvents(trial).Trial{1,1}.States.WaitForPresence)
        tmp.Outcome{trial}='Omitted';
    end
    %If there was no stimulus presented - differentiate between omitted and
    %premature response:
    if isnan(SessionData.RawEvents(trial).Trial{1,1}.States.DeliverStimulus)
        tmp.Outcome{trial}='Omitted';
        if ~isnan(SessionData.RawEvents(trial).Trial{1,1}.States.Punish)
            tmp.Outcome{trial}='PreMature';
        end
    else
        %If there was a stimuuls; if no punish then omitted (will be
        %changed later if its a rewarded trial). if punish before time out
        %<- side, if timeout before punish <- late.
        if isnan(SessionData.RawEvents(trial).Trial{1,1}.States.Punish)
            tmp.Outcome{trial}='Omitted';
        end
        if SessionData.RawEvents(trial).Trial{1,1}.States.TimeOut(1)<SessionData.RawEvents(trial).Trial{1,1}.States.Punish(1)
            tmp.Outcome{trial}='Late';
        elseif SessionData.RawEvents(trial).Trial{1,1}.States.TimeOut(1)>SessionData.RawEvents(trial).Trial{1,1}.States.Punish(1)
            tmp.Outcome{trial}='Side';
        end
    end

    if ~isnan(SessionData.RawEvents(trial).Trial{1,1}.States.Reward)
        tmp.Outcome{trial}='Reward';
    end
end
  
           
end