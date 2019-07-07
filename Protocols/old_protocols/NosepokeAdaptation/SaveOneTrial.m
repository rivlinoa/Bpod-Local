%% This function should recieve file name with its path as a string
%  It only works if there is the same number of trials in each datafile. 
%  Usually I will run it with only a single trial per session so there
%  shouldnt be a problem. 

% I have a bug in this function - it doesnt work if the RFID names are not
% in the same length. 

function SaveOneTrial(FileName)
    global BpodSystem
    
    if exist(FileName, 'file')==2
        load(FileName); 
        tmp = BpodSystem.Data; 
        data=[SessionData,tmp];%create an array of the wo structures
        names = fieldnames(data);
        cellData = cellfun(@(f) {vertcat(data.(f))},names);
        data = cell2struct(cellData,names);
        
        SessionData=data;
        save(FileName, 'SessionData', '-v6');

    else
    SessionData=BpodSystem.Data; 
    save(FileName, 'SessionData', '-v6');
    end 
end 


%Check function struct2table

