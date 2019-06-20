function  read_rf(~)
global BpodSystem
global RFID
    fopen(RFID);   
    % RF loop to send the soft code
            while (1)
                tag = fscanf(RFID);
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