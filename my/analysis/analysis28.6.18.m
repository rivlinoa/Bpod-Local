% In this file I create a table of specific featured from the output data
% in an analysis convinient way. 
% The user should load the correct data and animals files. 


% load the data file - user should specify the correct file, alternatively user
% can drag the file from its folder to the "Workspace". 
load ('C:\Users\owner\Documents\Bpod Local\Data\27-Jun-2018 14_10_49.mat')
load('C:\Users\owner\Documents\Bpod Local\Data\animals_06_27_18.mat')

% load the settings file - the data file point to this location so the user
% dont need to specify the file. 
load ('SessionData.SettingsFile{1, 1}')
single_reward=10; (%Read it from the settings file)

T=table();
T.RFID= SessionData.RFID';
T.ProtocolName=SessionData.ProtocolName';
T.reward_amount=zeros(size(T,1),1);

%see how many rewarded nosepokes were recorded in each entry
for i=1:SessionData.nTrials
    
    T.reward_amount(i)= sum(~isnan(SessionData.RawEvents.Trial{1, i}.States.Drinking(:,1)));
       
end
%calculate the amount of water supplied in each visit (in ul). 
T.reward_amount=T.reward_amount*single_reward;

%sum the amount of water supplied per mouse. 
animals.reward_given=zeros(size(animals,1),1);
for animal=1:size(animals,1)
    current_animal=strcmp(T.RFID,animals.tags{animal});
    animals.reward_given(animal)=sum(T.reward_amount(current_animal));
end
'C:\Users\owner\Documents\Bpod Local\Protocols\FreeAdaptation\Settings\DefaultSettings.mat'

bar(categorical(animals.names),animals.reward_given)
xlabel('Mouse name')
ylabel('Reward supplied (\mul)')
bar_title= ['Session started on ', SessionData.Info.SessionDate,'  ', SessionData.Info.SessionStartTime_UTC{1, 1}];
title(bar_title)