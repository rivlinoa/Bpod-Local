%% This file is used for running a protocol with RF tag reader on Bpod.
% User should enter protocol name in the appropriate place. 

% Created by Noa 26.6.18



%% create the RFID object and open it, if it was open - reset and reopen again. 
instrreset
clear
RFID=serial('COM12'); 
fopen(RFID);

%% open the Bpod object+GUI: 
Bpod('COM11')

%% Define the experiment to run, initiate data folder and graphes. 
% Load the animals data file - which mice are participating in the experiment, and their tags. 
experiment='CueInCloud'; %can be replaced by a fitting function
load('C:\Users\Owner\Documents\Bpod Local\Data\animals_10_03_18.mat')
%cd ('C:\Users\Owner\Documents\Bpod Local\Protocols\CueGo')
prepare_to_protocol_CueInCloud(animals);

%% The main loop for running the protocol 
%  To stop the loop while running:  ctrl+c,
%  To resume the same experiment, and data folder after stopping, run this section again.  

while(1)

    tag=fscanf(RFID)
    tag=tag(logical(isstrprop(tag,'digit')+isstrprop(tag,'alpha'))); %eliminate white spaces from the RF read
    if (length(tag)==12) %make sure there wasn't an error in the read (check if valid for all tags!)
        fclose(RFID);
        disp(tag)
        %Ind_Settings = choose_settings_cloud(tag);
        run_protocol_single_trial(experiment,tag,'14.10.18') % possible to add , ['settingsName'] without .mat
        fopen(RFID);
    end
    
end


%% Return lost graphs

%% Delete the RFID object handle
instrreset
