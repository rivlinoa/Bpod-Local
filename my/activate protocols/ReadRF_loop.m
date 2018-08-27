%% This file is used for running a protocol with RF tag reader on Bpod.
% User should enter protocol name in the appropriate place. 

% Created by Noa 26.6.18



%% create the RFID object and open it, if it was open - reset and reopen again. 
instrreset
clear
RFID=serial('COM4'); 
fopen(RFID);

%% open the Bpod object+GUI: 
Bpod()

%% Define the experiment to run, initiate data folder and graphes. 
% Load the animals data file - which mice are participating in the experiment, and their tags. 
experiment='CueGo'; %can be replaced by a fitting function
load('C:\Users\Owner\Documents\Bpod Local\Data\animals_23_07_18.mat')
% prepare_to_protocol_CueInCloud('Start', animals)
%cd ('C:\Users\Owner\Documents\Bpod Local\Protocols\CueGo')
prepare_to_protocol('Start', animals);



%% The main loop for running the protocol 
%  To stop the loop while running:  ctrl+c,
%  To resume the same experiment, and data folder after stopping, run this section again.  

while(1)

    
    tag=fscanf(RFID)
    tag=tag(logical(isstrprop(tag,'digit')+isstrprop(tag,'alpha'))); %eliminate white spaces from the RF read
        x=randi(100); %----ADDED 19/08
     if (length(tag)==12) %make sure there wasn't an error in the read (check if valid for all tags!)
        fclose(RFID);
        disp(tag)
        Ind_Settings=change_settings(tag);
        run_protocol_single_trial(experiment,tag,Ind_Settings) % possible to add , ['settingsName'] without .mat
        fopen(RFID);
    end
    
end

%%

prepare_to_protocol('Stop');
%run_protocol_single_trial('FreeAdaptation', '0782B19CC86')

%% Return lost graphs

%% Delete the RFID object handle
instrreset
