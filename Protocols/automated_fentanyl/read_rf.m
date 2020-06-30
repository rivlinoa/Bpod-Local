function  read_rf(~)
global BpodSystem
global RFID
global W
    fopen(RFID);   
    % RF loop to send the soft code
            while (1)
                if BpodSystem.Status.BeingUsed == 0
                    delete(W)
                    delete(RFID)
                    return; 
                end 
                
                tag = fscanf(RFID);
                %disp(isempty(tag))
                tag = tag(logical(isstrprop(tag,'digit')+isstrprop(tag,'alpha'))); %eliminate white spaces from the RF read
                if (length(tag)==12)
                     BpodSystem.Status.tmp_rf = tag;
                     fclose(RFID);
                     disp (tag)
                     SendBpodSoftCode(1)
                     break 
                end 
                     
            end
end 