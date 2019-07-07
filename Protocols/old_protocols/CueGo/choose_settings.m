%{
CHOOSE_SETTINGS
The valuse to this function must be inserted manually
for each animal's tag participating in the experiment the user can 
insert a settings file name, as a string, without .mat suffix. 
the user can use the relevant animals file to decide what the settings are:
%}

function [settings] = choose_settings(tag)
settings='auditory_visual_mice1_4'; 
switch tag
    case '00782B18E4AF' % mouse 1
        settings = 'aud_0.5-2delay' ;
    case '00782B19BBF1' % mouse 4
        settings = 'aud_0.5-2delay' ;
    case '00782B188CC7' % mouse 5
        settings = 'auditory_visual_mice1_4';
end 
    
end 
