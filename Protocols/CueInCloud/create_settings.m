%% This file is used to create a settings file for protocol CueAdaptation.
Settings=struct;

%% user should insert the desired values:

Settings.GUI.RewardAmount = 15; % ul
Settings.GUI.ResponseDuration = 1; % sec
Settings.GUI.MaxDelay = 1; % sec
Settings.GUI.MinDelay = 0.5; % sec
Settings.GUI.LightProb = 0.5; % Between 0-1, fraction of trials that would have auditory+visual stimulus.
Settings.GUI.CloudProb = 0.7; % Between 0-1, fraction of trials that would have tone cloud during delay .
Settings.GUI.LightCloudProb = 0.5; %probability of light with cloud 
Settings.GUI.DifficultyProb = 1;% Between 0-1, the proportion of easy trials (bottom 2 attenuations).

%% User should insert a name to describe the settings, in ' ' , and .mat suffix
settings_name='5.9.18_m5.mat';

%% Save the settings
file_name=fullfile('C:\Users\owner\Documents\Bpod Local\Protocols\CueInCloud\Settings\', settings_name)
save(file_name, 'Settings')