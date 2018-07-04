tag=cell2mat(animals{1,1})
for x= 1:2
    
    
    if (length(tag)==12) %make sure there wasn't an error in the read (check if valid for all tags!)
        
        global tag
        disp(tag)
        %CurrentMouseDisplay('init')
        run_protocol_single_trial(experiment, tag)% possible to add , ['settingsName']
       
    end
    
end
