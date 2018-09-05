%% Offline analysis for Bpod - CueGo protocol
% In this file I create a table of specific featured from the output data
% in an analysis convinient way.
% The user should load the correct data and animals files.


function [T] = create_table(SessionData, animals, filename)
%% Generate a table of the data in a convinient format.
if isfield(SessionData,'SessionData')
    SessionData=SessionData.SessionData;
end
    
%% create table and insert RFID values
if ~ismember('RFID', animals.Properties.VariableNames)
    animals.Properties.VariableNames{'tags'} = 'RFID';
end
% manually add test RFID to animals:
animals(size(animals,1)+1,:)= table({'00782B1799DD'}, 0);
T = table();
T.RFID = SessionData.RFID';
T.names = zeros(SessionData.nTrials,1);
% set animals name to the table
for i=1:SessionData.nTrials
    if ismember(SessionData.RFID(i), animals.RFID)
        T.names(i) = animals.names(strcmp(SessionData.RFID{i},animals.RFID));
    else 
        T.names(i) = 0; % 0 represents the test tag and problematic reads
    end   
end

T.RFID=categorical(T.RFID);
 
%% add different parameters
T.protocol_name = SessionData.ProtocolName';
T.cue_type = SessionData.CueTypes';
T.reward_supplied = zeros(SessionData.nTrials,1); % If last trial was not rewarded, rewared supplied length is shorter.
T.reward_supplied(1:size(SessionData.reward_supplied,2)) = SessionData.reward_supplied';
T.delay=SessionData.Delay';

if isfield(SessionData, 'attencloud')
    T.attencloud = cell2mat(SessionData.attencloud)';
         
end 

T.trial_time=SessionData.Info.SessionStartTime_UTC';
T.trial_time=datetime(T.trial_time);
T.date=datestr(T.trial_time,  'dd');
T.date=str2num(T.date);

%% Import settings - change!!!

if isfield(SessionData, 'ResponseDuration')
    T.response_duration = SessionData.ResponseDuration';
else
    T.response_duration = 1*ones(SessionData.nTrials,1);
end 

%% Add reaction time +  visit duration
T.reaction_time = NaN(SessionData.nTrials,1);
T.visit_duration = NaN(SessionData.nTrials,1);
% calculate the time diffrence between presnce detection and first
% nosepoke.
for i=1:SessionData.nTrials
    if isfield(SessionData.RawEvents.Trial{1, i}.Events, 'Port1In')
        T.reaction_time(i) = SessionData.RawEvents.Trial{1, i}.Events.Port1In(1) - ...
            SessionData.RawEvents.Trial{1, i}.States.WaitForPresence(2);
    end
    if isfield(SessionData.RawEvents.Trial{1, i}.Events, 'Condition1')
       T.visit_duration(i) = SessionData.RawEvents.Trial{1, i}.Events.Condition2  - SessionData.RawEvents.Trial{1, i}.Events.Condition1 ;
    else
       T.visit_duration(i) = 0;
    end 
end
T.RT = T.reaction_time - cell2mat(T.delay);



%% a loop for defining trial results:

T.trial_result=cell(SessionData.nTrials,1);
for i=1:SessionData.nTrials
    % first inintiaite as empty just in case of a bug. 
    T.trial_result(i)={' '};
    % if cue wasnt presented mark as premature (later will change some to
    % be omitted)
    if isnan(SessionData.RawEvents.Trial{1, i}.States.CueOn(1,1))
        T.trial_result(i)={'premature'};
    end
    
    % if there was no nosepoke mark as omitted
    if ~isfield(SessionData.RawEvents.Trial{1, i}.Events, 'Port1In')
        T.trial_result(i)={'omitted'};
    end
    % if there was a reward state mark as correct
    if ~isnan(SessionData.RawEvents.Trial{1, i}.States.Reward(1,1))
        T.trial_result(i)={'correct'};
    end
    % other cases are late...
    if (isfield(SessionData.RawEvents.Trial{1, i}.Events, 'Port1In'))&&...
            (T.reaction_time(i)>(T.delay{i}+T.response_duration(i)))
        T.trial_result(i)={'late'};
    end
    
end


%%  save the table

full_file_name = fullfile('C:\Users\owner\Documents\Bpod Local\my\analysis\tables', filename);
save(full_file_name, 'T')
end

%% useful other stuff

% %define the units for each variable in the table:
% T.Properties.VariableUnits = {'' 'Yrs' 'In' 'Lbs' '' ''};
% %description, units, min, max median of every variable in a table
% summary(T)

