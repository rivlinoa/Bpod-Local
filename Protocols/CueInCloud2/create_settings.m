%% This file is used to create a settings file for protocol CueInCloud.
Settings=struct;

%% user should insert the desired values:

Settings.GUI.RewardAmount = 10; % ul
Settings.GUI.ResponseDuration = 1.5; % sec
Settings.GUI.MaxDelay = 2; % sec
Settings.GUI.MinDelay = 0.5; % sec
Settings.GUI.LightProb = 0.75; % Between 0-1, fraction of trials that would have auditory+visual stimulus.
Settings.GUI.CloudProb = 0; % Between 0-1, fraction of trials that would have tone cloud during delay .
Settings.GUI.LightCloudProb = 1; %probability of light with cloud 
Settings.GUI.DifficultyProb = 1;% Between 0-1, the proportion of easy trials (bottom 2 attenuations).

%% User should insert a name to describe the settings, in ' ' , and .mat suffix
settings_name='Stage_3a.mat';

%% Save the settings
file_name=fullfile('C:\Users\owner\Documents\Bpod Local\Protocols\CueInCloud\Settings\', settings_name)
save(file_name, 'Settings')