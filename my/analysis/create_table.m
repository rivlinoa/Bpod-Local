%% Offline analysis for Bpod - CueGo protocol
% In this file I create a table of specific featured from the output data
% in an analysis convinient way.
% The user should load the correct data and animals files.


function [T] = create_table(SessionData, animals, filename)
%% Generate a table of the data in a convinient format.
if isfield(SessionData,'SessionData')
    SessionData=SessionData.SessionData;
end
%% Check if the last trial was ended successfully (if not take it out of the analysis)

if isfield(SessionData.RawEvents.Trial{1, end}.Events, 'Condition2') % if the mouse exit the presence detectors
    last = SessionData.nTrials;
else
    last = SessionData.nTrials-1;
end

%% create table and insert RFID values
if ~ismember('RFID', animals.Properties.VariableNames)
    animals.Properties.VariableNames{'tags'} = 'RFID';
end
% manually add test RFID to animals:
animals(size(animals,1)+1,:)= table({'00782B1799DD'}, 0);
T = table();
T.RFID = SessionData.RFID(1:last)';
T.names = zeros(last,1);
% set animals name to the table
for i=1:last
    if ismember(SessionData.RFID(i), animals.RFID)
        T.names(i) = animals.names(strcmp(SessionData.RFID{i},animals.RFID));
    else
        T.names(i) = 0; % 0 represents the test tag and problematic reads
    end
end

T.RFID=categorical(T.RFID);

%% add different parameters
T.protocol_name = SessionData.ProtocolName(1:last)';

T.cue_type = cell(last,1);
if size(SessionData.CueTypes,2)< last
    T.cue_type(1:size(SessionData.CueTypes,2)) = SessionData.CueTypes';
else
    T.cue_type(1:last) = SessionData.CueTypes(1:last)';
end

T.reward_supplied = zeros(last,1); % If last trial was not rewarded, rewared supplied length is shorter.
if size(SessionData.reward_supplied,2)< last
    T.reward_supplied(1:size(SessionData.reward_supplied,2)) = SessionData.reward_supplied';
else
    T.reward_supplied(1:last) = SessionData.reward_supplied(1:last)';
end

T.delay = cell(last,1);
if size(SessionData.Delay,2) < last
    T.delay(1:size(SessionData.Delay,2))=SessionData.Delay';
else
    T.delay(1:last)=SessionData.Delay(1:last)';
end

if isfield(SessionData, 'attencloud')
    T.attencloud = cell2mat(SessionData.attencloud(1:last))';
    
end

T.trial_time=SessionData.Info.SessionStartTime_UTC(1:last)';
T.trial_time=datetime(T.trial_time);
T.date=datestr(T.trial_time,  'dd');
T.date=str2num(T.date);

%% Import settings - change!!!

if isfield(SessionData, 'ResponseDuration')
    T.response_duration = zeros(last,1); % If last trial was not rewarded, response duration length is shorter.
    if size(SessionData.ResponseDuration,2)< last
        T.response_duration(1:size(SessionData.ResponseDuration,2)) = SessionData.ResponseDuration';
    else
        T.response_duration(1:last) = SessionData.ResponseDuration(1:last)';
    end
else
    T.response_duration = 3*ones(SessionData.nTrials,1);
end

%% Add reaction time +  visit duration
T.reaction_time = NaN(last,1);
T.visit_duration = NaN(last,1);
T.RT = NaN(last,1);
% calculate the time diffrence between presnce detection and first
% nosepoke.
for i=1:last
    if isfield(SessionData.RawEvents.Trial{1, i}.Events, 'Port1In')
        T.reaction_time(i) = SessionData.RawEvents.Trial{1, i}.Events.Port1In(1) - ...
            SessionData.RawEvents.Trial{1, i}.States.WaitForPresence(2);
        T.RT(i) = T.reaction_time(i) - cell2mat(T.delay(i));
    end
    if isfield(SessionData.RawEvents.Trial{1, i}.Events, 'Condition1')
        T.visit_duration(i) = SessionData.RawEvents.Trial{1, i}.Events.Condition2  - SessionData.RawEvents.Trial{1, i}.Events.Condition1 ;
    else
        T.visit_duration(i) = 0;
    end
    
end




%% a loop for defining trial results:

T.trial_result=cell(last,1);
for i=1:last
    if ~strcmp(SessionData.ProtocolName{1, i} , 'NotActive')
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
        % If there is no presence mark as 'no presence'.
        if ~isfield(SessionData.RawEvents.Trial{1, i}.Events, 'Condition1')
            T.trial_result(i)={'no_presence'};
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

