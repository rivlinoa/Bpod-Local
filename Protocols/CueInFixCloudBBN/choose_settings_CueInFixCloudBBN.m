%{
CHOOSE_SETTINGS
The valuse to this function must be inserted manually
for each animal's tag participating in the experiment the user can 
insert a settings file name, as a string, without .mat suffix. 
the user can use the relevant animals file to decide what the settings are:
%}

function [settings] = choose_settings_CueInFixCloudBBN(tag)
settings='Stage4'; 
switch tag
    case '00782B18C388' % mouse 1
        settings = 'Stage5a';
    case '00782B188CC7' % mouse 2
        settings = 'Stage5a';
    case '180900008899' % mouse 3
         settings = 'Stage5a' ;
    case '00782B19C389' % mouse 4
        settings = 'Stage5a';
    case '00782B1982C8' % mouse 6
        settings = 'Stage5a' ;
    case '00782B1890DB' % mouse 5
        settings = 'Stage_5c';
    case '180900000716' % mouse 7
        settings = 'Stage_5c';
end 
    
end 
