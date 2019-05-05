%{
CHOOSE_SETTINGS
The valuse to this function must be inserted manually
for each animal's tag participating in the experiment the user can 
insert a settings file name, as a string, without .mat suffix. 
the user can use the relevant animals file to decide what the settings are:
%}

function [settings] = choose_settings_Fixcloud(tag)
settings='Stage_5b'; 
switch tag
%    case '00782B199CD6' % mouse 1
%         settings = 'Stage_3a' ;
%     case '00782B188CC7' % mouse 2
%         settings = 'Stage_3a';
%     case '00782B19C389' % mouse 3
%         settings = 'Stage_3a';
    case '00782B19B8F2' % mouse 4
        settings = 'Stage_5b';
%     case '00782B18E4AF' % mouse 5
%         settings = 'Stage_3a';
    case '00782B1982C8' % mouse 10
        settings = 'Stage_5b';
    case '00782B1890DB' % mouse 20
        settings = 'Stage_5b';
%     case '00782B19D09A' % mouse 30
%         settings = 'Stage_3a' ;
    case '00782B17BBFF' % mouse 40
        settings = 'Stage_5b';  
end 
    
end 
