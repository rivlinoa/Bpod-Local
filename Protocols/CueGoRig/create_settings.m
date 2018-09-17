%% For CueGoRig protocol.
Settings=struct;

%% user should insert the desired values:

Settings.GUI.RewardAmount = 15; % ul
Settings.GUI.ResponseDuration = 3; % sec
Settings.GUI.MaxDelay = 2; % sec
Settings.GUI.MinDelay = 0.5; % sec

Settings.GUI.CueProb = 1; % Between 0-1, fraction of trials that would have any cue .

Settings.GUI.LightProb = 0.5; % Between 0-1, fraction of trials that would have auditory+visual stimulus.
Settings.GUI.LightSoundProb = 0.5; % prob of light + sound  trials, make sure 2 numbers add to less than 1!!!
Settings.GUI.LightIntensity = 255; % from 1 to 255
Settings.GUI.SinWaveFreq = 6000; %Hz
Settings.GUI.SoundDuration = 1; %sec

%% User should insert a name to describe the settings, in ' ' , and .mat suffix
settings_name='5.9.18_m5.mat';

%% Save the settings
file_name=fullfile('C:\Users\owner\Documents\Bpod Local\Protocols\CueGoRig\Settings\', settings_name)
save(file_name, 'Settings')