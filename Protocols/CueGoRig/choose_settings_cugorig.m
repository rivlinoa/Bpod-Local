%{
CHOOSE_SETTINGS
The valuse to this function must be inserted manually
for each animal's tag participating in the experiment the user can 
insert a settings file name, as a string, without .mat suffix. 
the user can use the relevant animals file to decide what the settings are:
%}

function [settings] = choose_settings_cugorig(tag)
settings='20.9.18_default'; 
switch tag
    case '00782B19A0EA' % mouse 2
        settings = '20.9.18_m5' ;
    case '00782B19CC86' % mouse 5
        settings = '20.9.18_default' ;
    case '00782B19B9F3' % mouse 1
        settings = '20.9.18_default';
end 
    
end 
