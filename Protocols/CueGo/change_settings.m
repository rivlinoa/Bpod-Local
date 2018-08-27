%{
CHOOSE_SETTINGS
The valuse to this function must be inserted manually
for each animal's tag participating in the experiment the user can 
insert a settings file name, as a string, without .mat suffix. 
the user can use the relevant animals file to decide what the settings are:
%}

%%
function [settings] = change_settings(tag)
settings='aud_0.5-2delay';
x=randi (100);
switch tag
    case '00782B18E4AF' %m1
        TreshHold=60;
        if x> TreshHold  
   settings = 'aud_0.5-2delay';
        else
        settings = 'auditory_visual_mice1_4';
        end
    case '00782B19BBF1' %m4
        TreshHold=60;
        if x> TreshHold  
   settings = 'aud_0.5-2delay';
        else
        settings = 'auditory_visual_mice1_4';
        end
    case '00782B188CC7' %m5
        TreshHold=85;
        if x> TreshHold  
   settings = 'aud_0.5-2delay';
        else
   settings = 'auditory_visual_mice1_4';
        end
end 
   

end


