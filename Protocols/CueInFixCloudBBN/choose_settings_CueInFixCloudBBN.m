%{
CHOOSE_SETTINGS
The valuse to this function must be inserted manually
for each animal's tag participating in the experiment the user can 
insert a settings file name, as a string, without .mat suffix. 
the user can use the relevant animals file to decide what the settings are:
%}

function [settings] = choose_settings_CueInFixCloudBBN(tag)
settings='Aud0.5_delay0.5-1'; 
switch tag
    case '180900001405' % mouse 11
        settings = 'Stage_5b';
    case '18090000CCDD' % mouse 12
        settings = 'Stage_4bNoAtten' ;
  
end 
    
end 
