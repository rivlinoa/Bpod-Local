%% This file is used to create a settings file for protocol CueAdaptation. 
Settings=struct;

%% user should insert the desired values:

Settings.RewardAmount = 5; % ul
Settings.CueType = 'visual'; % visual / auditory
Settings.CueDuration = 3; % sec 
Settings.CueIntensity = 255; % from 1 to 255
Settings.MaxDelay = 2; % sec

%% User should insert a name to describe the settings, in ' ' , and .mat suffix 
settings_name='default.mat';

%% Save the settings 
file_name=fullfile('C:\Users\owner\Documents\Bpod Local\Protocols\CueAdaptation\Settings\', settings_name)
save(file_name, 'Settings')