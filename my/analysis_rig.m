%{ function ANALYSIS_RIG accepts as an input the SessionData structure (i.e.
% the bpod output). The user should load the relevant data file to the
% Workspace and call the function to analyze it.
% The function returns a table with fields : 
%-result (premature, correct, late, omitted)
%-delay
%-is_light
%}


function [T] = analysis_rig(SessionData)
T = table();
if isfield(SessionData, 'Delay')
    T.delay = SessionData.delay';
    
end
T.is_light = SessionData.IsLight';

if isfield(SessionData, 'Settings')
    response_duration = SessionData.Settings(1).S.GUI.ResponseDuration;
else
    response_duration = 1.5;
end


for i=1:length(T.is_light)
    % first inintiaite as empty just in case of a bug. 
    T.trial_result(i)={' '};
    % if cue wasnt presented mark as premature (later will change some to
    % be omitted)
    if isnan(SessionData.RawEvents.Trial{1, i}.States.CueTrig(1,1))
        T.trial_result(i)={'premature'};
    end
    
    % if there was no nosepoke mark as omitted
    if ~isfield(SessionData.RawEvents.Trial{1, i}.Events, 'Port1In')
        T.trial_result(i)={'omitted'};
    end
    
    % if there was a reward state mark as correct
    if ~isnan(SessionData.RawEvents.Trial{1, i}.States.Reward(1,1))
        T.trial_result(i)={'correct'};
      
    
    % other cases are late... (I THINK THIS CHANGES OMISSIONS TO LATE AS
    % WELL)
    elseif (isfield(SessionData.RawEvents.Trial{1, i}.Events, 'GlobalTimer1_End')) && ...
           isfield(SessionData.RawEvents.Trial{1, i}.Events, 'Port1In')
        T.trial_result(i)={'late'};               

    end
    
end






end 


