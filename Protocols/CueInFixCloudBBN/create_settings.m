%% This file is used to create a settings file for protocol CueInFixCloudBBN.
Settings=struct;

%% user should insert the desired values:

Settings.GUI.RewardAmount = 15; % ul
Settings.GUI.ResponseDuration = 1.5; % sec
Settings.GUI.MaxDelay = 0.5; % sec
Settings.GUI.MinDelay = 0.5; % sec
Settings.GUI.LightProb = 1; % Between 0-1, fraction of trials that would have auditory+visual stimulus.
Settings.GUI.CloudProb = 0; % Between 0-1, fraction of trials that would have tone cloud during delay .
Settings.GUI.LightCloudProb = 0; %probability of light with cloud 
Settings.GUI.DifficultyProb = 1;% Between 0-1, the proportion of easy trials (bottom 2 attenuations).

%% User should insert a name to describe the settings, in ' ' , and .mat suffix
settings_name='AudVis0.5Delay.mat';

%% Save the settings
file_name=fullfile('C:\Users\owner\Documents\Bpod Local\Protocols\CueInFixCloudBBN\Settings\', settings_name)
save(file_name, 'Settings')