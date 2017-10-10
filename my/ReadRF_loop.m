%% Define the experiment to run:
experiment='FreeAdaptation';
%% RF read
RFID=serial('COM4'); 
fopen(RFID);
%% creates the file name for saving the data of the current experiment
%  I specified the whole path of the file, may be changed on different computer

path='C:/Users/owner/Documents/BpodTop/Bpod Local/Data/FreeAdaptation/';
TimeString=strrep(char(datetime('now')), ':', '_');
FileName=strcat(path,TimeString,'.mat');
global FileName

%% The main loop for running the protocol 
Bpod()
%TrialStatePlot(AxesHandle, 'init')
while(1)
    
    tag=fscanf(RFID)
    tag=tag(logical(isstrprop(tag,'digit')+isstrprop(tag,'alpha'))); %eliminate white spaces from the RF read
    if (length(tag)==12) %make sure there wasn't an error in the read (check if valid for all tags!)
        fclose(RFID);
        global tag
        disp(tag)
        %CurrentMouseDisplay('init')
        RunProtocol('Start', experiment,tag)
        RunProtocol('Stop')
        fopen(RFID);
    end
    
end

%RunProtocol('Start', 'FreeAdaptation','0782B19CC86')