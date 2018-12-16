%{
CHOOSE_SETTINGS
The valuse to this function must be inserted manually
for each animal's tag participating in the experiment the user can 
insert a settings file name, as a string, without .mat suffix. 
the user can use the relevant animals file to decide what the settings are:
%}

function [settings] = choose_settings_CueInCloudBBN(tag)
settings='20.9.18_default'; 
switch tag
    case '002FBE7249AA' % mouse 1
        settings = 'Stage_5b';
     case '00782B1799DD' % tester
         settings = 'Stage_4a' ;
%     case '002FBE7341A3' % mouse 3
%         settings = 'RT_3_Delay_0.5' ;
%     case '00782B1897DC' % mouse 4
%         settings = 'RT_3_Delay_0.5' ;
      case '002FBE71BA5A' % mouse 5
        settings = 'Stage_5a' ;
%     case '002FBE717999' % mouse 6
%         settings = 'adaptation' ;
 
end 
    
end 
