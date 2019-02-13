%{
CHOOSE_SETTINGS
The valuse to this function must be inserted manually
for each animal's tag participating in the experiment the user can 
insert a settings file name, as a string, without .mat suffix. 
the user can use the relevant animals file to decide what the settings are:
%}

function [settings] = choose_settings_CueInFixCloudBBN(tag)
settings='20.9.18_default'; 
switch tag
    case '00782B1897DC' % mouse 2
        settings = 'Stage_2';
     case '00782B19B9F3' % mouse 8
         settings = 'AudVis0.5Delay' ;
    case '00782B18C388' % mouse 3
        settings = 'AudVis0.5Delay' ;

 
end 
    
end 
