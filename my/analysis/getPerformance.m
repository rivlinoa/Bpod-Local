function [TaskAnalysis]  = getPerformance (datafile)
Data=analysis_rig(datafile);
A=table;
VNames = unique(Data.trial_result);
mydir=pwd;
idcs = strfind(mydir,filesep);
TaskAnalysis.Info = {mydir(idcs(end-2)+1:idcs(end-1)-1)...
    datafile.Info.SessionDate,datafile.Info.SessionStartTime_UTC};

for ii=1:length(VNames)  
    percent_result=sum(strcmp(Data.trial_result,VNames(ii)))/height(Data);
    percent_light_on=sum(Data.is_light(strcmp(Data.trial_result,VNames(ii))))/sum(strcmp(Data.trial_result,VNames(ii)));
    
   if isfield(Data,'delay')
    m_delay=median(Data.delay(strcmp(Data.trial_result,VNames(ii))));
   else
       m_delay=nan;
   end
    analysis=[percent_result,percent_light_on,m_delay];
    
    A.(VNames{ii})=analysis';
    TaskAnalysis.TrialIndex.(VNames{ii})=find(strcmp(Data.trial_result,VNames(ii)));
end
A.Properties.RowNames={'Percent of Trials','Percent Light On','Median_Delay'};


TaskAnalysis.Results=A;
TaskAnalysis.Data=Data;
end