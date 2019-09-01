%{
CHOOSE_SETTINGS
The valuse to this function must be inserted manually
for each animal's tag participating in the experiment the user can 
insert a settings file name, as a string, without .mat suffix. 
the user can use the relevant animals file to decide what the settings are:
%}

function [settings] = choose_settings_cloud(tag)
settings='29_8_18_a'; 
switch tag
    case '00782B188CC7' % mouse 2
        settings = 'AllHardAtten';
    case '00782B19C389' % mouse 3
        settings = 'AllHardAtten';
    case '00782B19B8F2' % mouse 4
        settings = 'AllHardAtten';
    case '00782B18E4AF' % mouse 5
        settings = 'AllHardAtten';
    case '00782B1982C8' % mouse 10
        settings = 'AllHardAtten';
    case '00782B1890DB' % mouse 20
        settings = 'AllHardAtten';
    case '00782B19D09A' % mouse 30
        settings = 'AllHardAtten' ;
    case '00782B17BBFF' % mouse 40
        settings = 'AllHardAtten';  
end 
    
end 
