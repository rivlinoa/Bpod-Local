%This file is used for running a protocol with RF tag reader on Bpod.
%User should enter protocol name in the appropriate place. 

%Created by Noa 26.6.18




RFID=serial('COM8'); 
fopen(RFID);


%% Define the experiment to run:
Bpod()

experiment='PortAdaptation'; %can be replaced by a fitting function
load('C:\Users\owner\Documents\Bpod Local\Data\animals_06_27_18.mat');
prepare_to_protocol('Start', animals);

%TrialStatePlot(AxesHandle, 'init')

%% The main loop for running the protocol 

%while(1)
for x= 1:1
    tag=fscanf(RFID)
    tag=tag(logical(isstrprop(tag,'digit')+isstrprop(tag,'alpha'))); %eliminate white spaces from the RF read
    if (length(tag)==12) %make sure there wasn't an error in the read (check if valid for all tags!)
        fclose(RFID);
        global tag
        disp(tag)
        %CurrentMouseDisplay('init')
        run_protocol_single_trial(experiment, tag)% possible to add , ['settingsName']
        fopen(RFID);
    end
    
end

%RunProtocol('Start', 'FreeAdaptation','0782B19CC86')
prepare_to_protocol('Stop')
run_protocol_single_trial('FreeAdaptation', '0782B19CC86')


%% Delete the RFID object handle
instrreset
