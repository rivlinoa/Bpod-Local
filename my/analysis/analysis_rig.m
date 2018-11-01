%{ function ANALYSIS_RIG accepts as an input the SessionData structure (i.e.
% the bpod output). The user should load the relevant data file to the
% Workspace and call the function to analyze it.
% The function returns a table with fields : 
%-result (premature, correct, late, omitted)
%-delay
%-is_light
%}


function [TaskAnalysis] = analysis_rig(SessionData)
T = table();
if isfield(SessionData, 'Delay')
    T.delay = SessionData.Delay';
    
end

if isfield(SessionData, 'IsLight')
    T.is_light = SessionData.IsLight';
end

if isfield(SessionData, 'Settings')
    response_duration = SessionData.Settings{1,1}.GUI.ResponseDuration;
else
    response_duration = 1.5;
end

T.trial_number = [1:height(T)]';


for i=1:length(T.is_light)
    % first inintiaite as empty just in case of a bug. 
    T.trial_result(i)={' '};
    T.plot_result(i)= nan ;
    % if cue wasnt presented mark as premature (later will change some to
    % be omitted)
    if isnan(SessionData.RawEvents.Trial{1, i}.States.CueTrig(1,1)) && ...
            isfield(SessionData.RawEvents.Trial{1, i}.Events, 'Port1In')
        T.trial_result(i) = {'premature'};
        T.plot_result(i) = -1;
 
    % if there was no nosepoke mark as omitted
    elseif ~isfield(SessionData.RawEvents.Trial{1, i}.Events, 'Port1In')
        T.trial_result(i) = {'omitted'};
        T.plot_result(i) = 0;
    
    % if there was a reward state mark as correct
    elseif ~isnan(SessionData.RawEvents.Trial{1, i}.States.Reward(1,1))
        T.trial_result(i) = {'correct'};
        T.plot_result(i) = 1;
      
    
    % other cases are late... 
    elseif (isfield(SessionData.RawEvents.Trial{1, i}.Events, 'GlobalTimer1_End')) && ...
           isfield(SessionData.RawEvents.Trial{1, i}.Events, 'Port1In')
        T.trial_result(i) = {'late'};
        T.plot_result(i) = 2;

    end
    
end

% get the information of the 
mydir = pwd;

%% un comment later
% idcs = strfind(mydir,filesep);
% TaskAnalysis.Info = {mydir(idcs(end-2)+1:idcs(end-1)-1)...
%     datafile.Info.SessionDate,datafile.Info.SessionStartTime_UTC};
%% 

A=table;
VNames = unique(T.trial_result);
for ii=1:length(VNames)  
    percent_result=sum(strcmp(T.trial_result,VNames(ii)))/height(T);
    percent_light_on=sum(T.is_light(strcmp(T.trial_result,VNames(ii))))/sum(strcmp(T.trial_result,VNames(ii)));
    
   if isfield(T,'delay')
    m_delay=median(T.delay(strcmp(T.trial_result,VNames(ii))));
   else
       m_delay=nan;
   end
    analysis=[percent_result,percent_light_on,m_delay];
    
    A.(VNames{ii})=analysis';
    TaskAnalysis.TrialIndex.(VNames{ii})=find(strcmp(T.trial_result,VNames(ii)));
end
A.Properties.RowNames={'Percent of Trials','Percent Light On','Median_Delay'};

TaskAnalysis.Results=A;
TaskAnalysis.Data=T;

end 


