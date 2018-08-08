%% Offline analysis for Bpod - CueGo protocol
% In this file I create a table of specific featured from the output data
% in an analysis convinient way.
% The user should load the correct data and animals files.

%% load the data file - user should specify the correct file, alternatively user
% can drag the file from its folder to the "Workspace".

% load('C:\Users\owner\Documents\Bpod Local\Data\Data_usb\18.07.10_14.47.07.mat')
% load('C:\Users\owner\Documents\Bpod Local\Data\animals_06_27_18.mat')
% load('C:\Users\owner\Documents\Bpod Local\Data\Data_usb\18.07.12_13.23.03.mat')
% load('C:\Users\owner\Documents\Bpod Local\Data\Data_usb\18.07.11_10.50.24.mat')

function [T] = create_table(SessionData, animals, filename)
%% Generate a table of the data in a convinient format.
if isfield(SessionData,'SessionData')
    SessionData=SessionData.SessionData;
end
    

%% create table by innserting RFID values
if ~ismember('RFID', animals.Properties.VariableNames)
    animals.Properties.VariableNames{'tags'} = 'RFID';
end
% manually add test RFID to animals:
animals(size(animals,1)+1,:)= table({'00782B1799DD'}, 0);
T = table();
T.RFID = SessionData.RFID';
T.names = zeros(SessionData.nTrials,1);
% set animals name to the table
% T = join(T,animals,'Keys','RFID'); I changed this method since I had a
% bug where new RFID suddenly appeared. 
for i=1:SessionData.nTrials
    if ismember(SessionData.RFID(i), animals.RFID)
        T.names(i) = animals.names(strcmp(SessionData.RFID{i},animals.RFID));
    else 
        T.names(i) = 0;
    end   
end

T.RFID=categorical(T.RFID);
 
%% add different parameters
T.protocol_name=SessionData.ProtocolName';
T.reward_supplied=zeros(SessionData.nTrials,1); % If last trial was not rewarded, rewared supplied length is shorter.
T.reward_supplied(1:size(SessionData.reward_supplied,2))=SessionData.reward_supplied';
%T.reward_supplied=str2num(T.reward_supplied);

T.delay=SessionData.Delay';

T.trial_time=SessionData.Info.SessionStartTime_UTC';
T.trial_time=datetime(T.trial_time);
T.date=datestr(T.trial_time,  'dd');
T.date=str2num(T.date);

%% Import settings

%first load first setting file to find out what was the cue duration. if it
%varies between subjects, change this section.
% ** a potentioal bug in calling settings name and fields. **
load(SessionData.SettingsFile{1, 1});
cue_duration=0;
if isempty(fieldnames(Settings)) % **** chage to Settings *****
    cue_duration = 3; % !!!! change for different protocol or if protocol is changed
else
    cue_duration = Settings.GUI.CueDuration;
end

%% add reaction time
T.reaction_time=NaN(SessionData.nTrials,1);

% calculate the time diffrence between presnce detection and first
% nosepoke.
for i=1:SessionData.nTrials
    if isfield(SessionData.RawEvents.Trial{1, i}.Events, 'Port1In')
        T.reaction_time(i) = SessionData.RawEvents.Trial{1, i}.Events.Port1In(1) - ...
            SessionData.RawEvents.Trial{1, i}.States.WaitForPresence(2);
    end
end

%% a loop for defining trial results:

T.trial_result=cell(SessionData.nTrials,1);
for i=1:SessionData.nTrials
    % if cue wasnt presented mark as premature (later will change some to
    % ba omitted)
    if isnan(SessionData.RawEvents.Trial{1, i}.States.CueOn(1,1))
        T.trial_result(i)={'premature'};
    end
    
    % if there was no nosepoke mark as omitted
    if ~isfield(SessionData.RawEvents.Trial{1, i}.Events, 'Port1In')
        T.trial_result(i)={'omitted'};
    end
    % if there was reward state mark as correct
    if ~isnan(SessionData.RawEvents.Trial{1, i}.States.Reward(1,1))
        T.trial_result(i)={'correct'};
    end
    % other cases are late...
    if (isfield(SessionData.RawEvents.Trial{1, i}.Events, 'Port1In'))&&...
            (T.reaction_time(i)>(T.delay{i}+cue_duration))
        T.trial_result(i)={'late'};
    end
    
end


%%  save the table

full_file_name = fullfile('C:\Users\owner\Documents\Bpod Local\my\analysis\tables', filename);
save(full_file_name, 'T')
end

%% usful other stuff

% %define the units for each variable in the table:
% T.Properties.VariableUnits = {'' 'Yrs' 'In' 'Lbs' '' ''};
% %description, units, min, max median of every variable in a table
% summary(T)

