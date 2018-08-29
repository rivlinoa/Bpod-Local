%% This file is used to create a settings file for protocol CueAdaptation.
Settings=struct;

%% user should insert the desired values:

Settings.GUI.RewardAmount = 10; % ul
Settings.GUI.ResponseDuration = 3;
Settings.GUI.MaxDelay = 2; % sec
Settings.GUI.MinDelay = 0.5; % sec
Settings.GUI.LightProb = 0.5; % Between 0-1, fraction of trials that would have auditory+visual stimulus.
Settings.GUI.CloudProb = 0.5; % Between 0-1, fraction of trials that would have tone cloud during delay .
Settings.GUI.DifficultyProb = 0.5;% Between 0-1, the proportion of easy trials (bottom 2 attenuations).

%% User should insert a name to describe the settings, in ' ' , and .mat suffix
settings_name='allProb0_5.mat';

%% Save the settings
file_name=fullfile('C:\Users\owner\Documents\Bpod Local\Protocols\Cuego\Settings\', settings_name)
save(file_name, 'Settings')