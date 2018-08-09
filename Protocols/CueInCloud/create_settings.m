%% This file is used to create a settings file for protocol CueAdaptation. 
Settings=struct;

%% user should insert the desired values:

Settings.GUI.RewardAmount = 10; % ul
Settings.GUI.MinDelay = 0.5; % sec
S.GUI.ResponseDuration = 3;
Settings.GUI.MaxDelay = 2; % sec
Settings.GUI.Delay = ' '; % just for display, don't fill a value. 

%% User should insert a name to describe the settings, in ' ' , and .mat suffix 
settings_name='default.mat';

%% Save the settings 
file_name=fullfile('C:\Users\owner\Documents\Bpod Local\Protocols\CueInCloud\Settings\', settings_name)
save(file_name, 'Settings')