%% This file is used to create a settings file for protocol CueAdaptation. 
Settings=struct;

%% user should insert the desired values:

Settings.GUI.RewardAmount = 10; % ul
Settings.GUI.CueType = 'visual'; % visual / auditory
Settings.GUI.CueDuration = 3; % sec 
Settings.GUI.CueIntensity = 255; % from 1 to 255
Settings.GUI.MaxDelay = 1; % sec
Settings.GUI.Delay = ' ' % just for display, don't fill a value. 

%% User should insert a name to describe the settings, in ' ' , and .mat suffix 
settings_name='reward10delay1.mat';

%% Save the settings 
file_name=fullfile('C:\Users\owner\Documents\Bpod Local\Protocols\CueGo\Settings\', settings_name)
save(file_name, 'Settings')