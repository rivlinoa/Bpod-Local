%% Run analysis ver 2 - offline analysis for gocue protocol in Bpod.

% all graphes represents activity in the activ hours only, unkess specified
% otherwise. 

% created by Noa
% editted 21.10.18, 5.11.18



%% A - load data files (as exported from bpod):
file_list = {'19.01.13_11.09.39'}; 


%  file_list = {'18.08.26_11.01.07', '18.08.28_09.42.23', '18.08.28_12.44.56', ...
%      '18.08.28_16.20.45', '18.08.29_10.31.04', '18.08.29_18.39.11', ...
%      '18.08.30_11.34.14', '18.09.02_09.35.10',   ...
%      '18.09.02_12.27.02', '18.09.02_14.38.44' }; % pilot cloud start
 
% file_list = {'18.11.05_09.56.57','18.11.05_15.38.44', '18.11.05_19.46.26', ...
% '18.11.06_12.40.25','18.11.06_13.22.34', '18.11.06_16.59.16', '18.11.07_08.48.47', ...
%   '18.11.07_14.31.56', '18.11.07_15.21.42',  '18.11.07_22.54.59', '18.11.08_10.47.28', ...
%  '18.11.08_12.28.25',    ...
%  '18.11.09_10.47.47', '18.11.09_14.23.40','18.11.10_19.25.41', ...
% '18.11.14_08.59.51' }; % training with cloud

% file_list = {'18.12.09_11.03.28','18.11.05_15.38.44','18.12.10_11.15.50','18.12.11_14.20.50',...
%     '18.12.12_08.54.52','18.12.13_10.38.23','18.12.13_16.45.02'}; %Noa's experiment
   
% file_list = {'18.12.03_10.50.01','18.12.03_12.04.58','18.12.03_13.17.40','18.12.03_14.27.31','18.12.03_15.36.39',...
%     '18.12.03_16.54.34','18.12.04_09.04.44','18.12.04_10.03.46','18.12.04_11.08.03','18.12.04_12.15.37','18.12.04_13.08.37',...
%     '18.12.05_10.07.03','18.12.05_10.40.42','18.12.05_12.00.15','18.12.05_12.33.23','18.12.05_13.42.46','18.12.05_15.25.06',...
%     '18.12.05_15.59.21','18.12.05_17.12.21','18.12.06_11.00.55','18.12.06_12.32.33','18.12.06_14.07.11','18.12.06_15.34.19',...
%     '18.12.06_17.05.49','18.12.07_07.53.32','18.12.07_14.10.21'}; % the
%     week of the experiment.


                                   % write only the file name. without .mat suffix
                                   % user can add as many filed as wanted
devide_analysis_hours = 0;         % Do you want to analyze some of the data by hours? 1- yes, 0-no.                                   
analysis_start_hour = '11:30';     % start the analysis at 'hour:minute'
analysis_end_hour = '12:30';       % end the analysis at 'hour:minute'

%% B- load animals file
load('C:\Users\owner\Documents\Bpod Local\Data\animals_10_03_18.mat')

%%
T_all=table();
for file_name = file_list
    char_file_name = cell2mat(file_name);
    full_file_name = ['C:\Users\owner\Documents\Bpod Local\Data\',char_file_name,'\Session Data\', char_file_name,'.mat'];
    file1 = load(full_file_name);
    T1 = create_table_no_presence(file1, animals);
    T_all = [T_all;T1];
end 


%% take only trials in the active hours
T_all.hour_minute = datestr(T_all.trial_time,'HH:mm:ss');
T = T_all(~strcmp(T_all.protocol_name, 'NotActive'),:);

analysis_start_hour = datestr(analysis_start_hour,'HH:mm');
analysis_end_hour = datestr(analysis_end_hour,'HH:mm');

if devide_analysis_hours
    %time_a < time_b ---> time_a is *after* time_b
    T.to_analyze = datenum(T.hour_minute) > datenum(analysis_start_hour) & ...
                    datenum(T.hour_minute) < datenum(analysis_end_hour);
               
    T = T( T.to_analyze, :);
end 
    
%% delete later!
for i=1: height(T)
    if ~isempty(T.attencloud{i}) && T.attencloud{i} > 0
        T.cue_type{i} = [T.cue_type{i}, 'Cloud'];
    end 
end 
%% create summary table and 2 plots:
data_set=struct();

F.reward_figure = figure('Name', 'Reward plot');
F.performance_figure = figure('Name', 'Performance plot');
F.histogram_figure = figure('Name', 'Histogram plot');
F.rt_figure = figure('Name', 'Reaction time plot');
F.cue_type_figure = figure('Name', 'Cue type plot');
F.RT_delay_figure = figure('Name', 'RT vs. delay');

if ismember('attencloud', T.Properties.VariableNames)
    F.success_attenuation_figure = figure('Name', 'Success attenuation plot');
end 
if ismember('cue_atten', T.Properties.VariableNames)
    F.success_cue_attenuation_figure = figure('Name', 'Success cue attenuation plot');
end 




for day = unique(T.date)'
    data_inds = (T.date==day);
    T_day = T(data_inds,:);
    [animals_inds, animalsID] = findgroups (T_day.names);
    
    sum_reward_supplies = splitapply(@sum,T_day.reward_supplied,animals_inds);
    sum_visit_count = splitapply(@length,T_day.RFID,animals_inds);
    
    data_set.(['day',num2str(day)]).animalsID = animalsID;
    data_set.(['day',num2str(day)]).reward = sum_reward_supplies;
    data_set.(['day',num2str(day)]).visits = sum_visit_count;
    
    correct = splitapply((@(r) sum(strcmp(r,'correct'))),T_day.trial_result, animals_inds);
    omitted = splitapply((@(r) sum(strcmp(r,'omitted'))),T_day.trial_result, animals_inds);
    premature = splitapply((@(r) sum(strcmp(r,'premature'))),T_day.trial_result, animals_inds);
    late = splitapply((@(r) sum(strcmp(r,'late'))),T_day.trial_result, animals_inds);
    
    data_set.(['day',num2str(day)]).results_table = table(animalsID ,correct,omitted,premature,late);
   
    % figure for licks
    day_ind = find(day==unique(T.date));
        figure(F.reward_figure)
    hold on
    reward_H(day_ind) = subplot(1, length(unique(T.date)),  day_ind);
    bar(categorical(data_set.(['day',num2str(day)]).animalsID),  data_set.(['day',num2str(day)]).reward)
    xlabel('Mouse name')
    ylabel('Reward supplied /ul')
    title (['Day',num2str(day)])
    
    % figure for performance
    figure(F.performance_figure)
    hold on
    visit_H(day_ind) = subplot(1, length(unique(T.date)),  day_ind);
    ytoplot = table2array([data_set.(['day',num2str(day)]).results_table(:,2:end);]);
    bar(categorical(data_set.(['day',num2str(day)]).animalsID), ytoplot, 'stacked');
    ylabel('Visits count')
    xlabel('Mouse name')
    title(['Day',num2str(day)])
    
    %subplot by day & animal
    for animal_ind = animalsID(animalsID>0)'
        
        data_inds2 = (T_day.names==animal_ind);
        T_animal = T_day(data_inds2,:);
        %% prepare data to plot histograms of trials result by delay.
        animal_i=find(animal_ind==animalsID(animalsID>0)'); % to ignore test trials, name=0
        delay_correct=cell2mat(T_animal.delay(strcmp(T_animal.trial_result,'correct')));
        delay_omitted=cell2mat(T_animal.delay(strcmp(T_animal.trial_result,'omitted')));
        delay_premature=cell2mat(T_animal.delay(strcmp(T_animal.trial_result,'premature')));
        delay_late=cell2mat(T_animal.delay(strcmp(T_animal.trial_result,'late')));
        
        %Plot trial result by delay
        figure(F.histogram_figure)
        subplot_value = ((animal_i-1)*length(unique(T.date)))+day_ind;
        hist_H(subplot_value) = subplot(sum(animalsID>0), length(unique(T.date)),  subplot_value);
        hold on
        
        histogram(delay_correct,'BinWidth',0.1,'facecolor', 'g','facealpha',.3,'edgecolor','none')
        histogram(delay_omitted,'BinWidth',0.1,'facecolor', 'b','facealpha',.3,'edgecolor','none')
        histogram(delay_premature,'BinWidth',0.1,'facecolor', 'r','facealpha',.3,'edgecolor','none')
        xlabel('Delay time')
        ylabel('Visit count')
        title(['Day ',num2str(day), ' mouse ' , num2str(animal_ind)])
        
        %% plot RT relative to cue onset histogram
        figure(F.rt_figure)
        subplot_value = ((animal_i-1)*length(unique(T.date)))+day_ind;
        RT_H(subplot_value) = subplot(sum(animalsID>0), length(unique(T.date)),  subplot_value);
        hold on
        histogram( T_animal.RT,'BinWidth',0.05)
        xlabel('Reaction time relative to cue onset')
        ylabel('Visit count')
        title(['Day ',num2str(day), ' mouse ' , num2str(animal_ind)])
        xlim([-1 3])
        
            
        
        %% prepare data to plot performance by cue type
        T_animal.cue_type = categorical(T_animal.cue_type);
        [cue_inds, cueID] = findgroups (T_animal.cue_type);
        T_animal.cue_inds = cue_inds;
        correct = splitapply((@(r) sum(strcmp(r,'correct'))),T_animal.trial_result, T_animal.cue_inds);
        omitted = splitapply((@(r) sum(strcmp(r,'omitted'))),T_animal.trial_result, T_animal.cue_inds);
        premature = splitapply((@(r) sum(strcmp(r,'premature'))),T_animal.trial_result, T_animal.cue_inds);
        late = splitapply((@(r) sum(strcmp(r,'late'))),T_animal.trial_result, T_animal.cue_inds);
        
        
        figure(F.cue_type_figure)
        subplot_value = ((animal_i-1)*length(unique(T.date)))+day_ind;
        cue_H(subplot_value) = subplot(sum(animalsID>0), length(unique(T.date)),  subplot_value);
        hold on
        ytoplot = [correct,omitted,premature,late];
        if length(categorical(cueID))<2
            dummy = NaN(size(ytoplot));
            ytoplot = [ytoplot;dummy];
            xtoplot = [cueID; {'_'}];
            xtoplot = categorical(xtoplot);
            bar(categorical(xtoplot), ytoplot, 'stacked');
        else
            bar(categorical(cueID), ytoplot, 'stacked');
        end
        
        ylabel('Visits count')
        title(['Day ',num2str(day), ' mouse ' , num2str(animal_ind)])
        axis tight
        
        
        % plot RT vs. delay
        figure(F.RT_delay_figure)
        RT_delay_H(subplot_value) = subplot(sum(animalsID>0), length(unique(T.date)),  subplot_value);
        hold on
        for cue=categories(T_animal.cue_type)'
            relevant_inds = (T_animal.cue_type == cell2mat(cue));
            plot(cell2mat(T_animal.delay(relevant_inds)), T_animal.RT(relevant_inds),'o')
        end
        line(xlim(), [0,0]);
        xlabel('Delay (sec)')
        ylabel ('RT relative to cue (sec)')
        ylim ([-3,3])
        title(['Day ',num2str(day), ' mouse ' , num2str(animal_ind)])
        legend(categories(T_animal.cue_type))
        
        % plot sucess rate by attenuation for cue in cloud protocol:
        
        if ismember('attencloud', T_animal.Properties.VariableNames) && ...
                (~isempty(cell2mat(T_animal.attencloud)))
            cloud_inds  =  ~(cellfun(@isempty,T_animal.attencloud));
            figure(F.success_attenuation_figure)
           [atten_groups, IDatten] = findgroups (cell2mat(T_animal.attencloud));
           
            %subplot_value = ((animal_i-1)*length(unique(T_presence.date)))+day_ind;
            visits_atten = splitapply (@length, T_animal.RFID(cloud_inds), atten_groups);
            success_atten =  splitapply((@(r) sum(strcmp(r,'correct'))),T_animal.trial_result(cloud_inds), atten_groups);
            success_atten = success_atten./visits_atten;
            atten_H(subplot_value) = subplot(sum(animalsID>0), length(unique(T.date)),  subplot_value);
            hold on
            disp( subplot_value)
            plot (IDatten,success_atten) 
            xlabel('cloud attenuation (1-10)')
            ylabel ('Success rate')
            ylim ([0,1])
            title(['Day ',num2str(day), ' mouse ' , num2str(animal_ind)])
        end
        
        % plot sucess rate by attenuation for cue in fixed cloud protocol (cue is changed):
        
        if ismember('cue_atten', T_animal.Properties.VariableNames) 
            figure(F.success_cue_attenuation_figure)
           [atten_groups, IDatten] = findgroups (cell2mat(T_animal.cue_atten));
           
           %subplot_value = ((animal_i-1)*length(unique(T_presence.date)))+day_ind;
            visits_atten = splitapply (@length, T_animal.RFID, atten_groups);
            success_atten =  splitapply((@(r) sum(strcmp(r,'correct'))),T_animal.trial_result, atten_groups);
            success_atten = success_atten./visits_atten;
            cue_atten_H(subplot_value) = subplot(sum(animalsID>0), length(unique(T.date)),  subplot_value);
            hold on
            disp( subplot_value)
            plot (IDatten,success_atten) 
            xlabel('cloud attenuation (1-10)')
            ylabel ('Success rate')
            ylim ([0,1])
            title(['Day ',num2str(day), ' mouse ' , num2str(animal_ind)])
        end
    end
    
    
end

figure(F.performance_figure)
legend('Correct', 'Omitted', 'Premature', 'Late')

figure(F.cue_type_figure)
legend('Correct', 'Omitted', 'Premature', 'Late')
control_axes(cue_H)

figure(F.histogram_figure)
legend('Ccorrect','Omitted','Premature')
control_axes(hist_H)

control_axes(RT_H)
control_axes(reward_H)
control_axes(visit_H)


%% success rate line figure - per day & cue type  -with omissions!!!
%there is some redundancy in the code but its the easyiest way :(
[group_inds, IDanimal,IDcue,IDday ] = findgroups (T.names,T.cue_type, T.date );
visits_2 = splitapply (@length, T.RFID, group_inds);
success =  splitapply((@(r) sum(strcmp(r,'correct'))),T.trial_result, group_inds);
success = success./visits_2;
success_table = table(success ,IDanimal , IDcue , IDday);

F.success_rate_figure = figure('Name', 'Success rate plot');
subplot_ind = 1;
figure(F.success_rate_figure)
for current_animal = unique(IDanimal)'
    success_H = subplot(1,length(unique(IDanimal)),subplot_ind);
    hold on
    success_data = success_table(IDanimal == current_animal,:);
        for cue=unique(success_data.IDcue)'
        relevant_inds = strcmp(success_data.IDcue, cue);
        unique_days = unique(success_data.IDday);
            if (length(relevant_inds) ~= length(unique_days))
                disp('there was a day with no trials of a certain type');
                day_vec = ismember(unique(success_data.IDday), success_data.IDday(relevant_inds)); % which day is missing?
                relevant_success = nan(1,length(unique_days));                                     % missing days are nan
                relevant_success(day_vec) = success_data.success(relevant_inds);                   % fill in non missing days
                plot(1:length(unique_days), relevant_success, '-o')
                
            else
                relevant_success(day_vec) = success_data.success(relevant_inds); 
                plot(1:length(unique_days), relevant_success(relevant_inds), '-o')
            end
        end
        
    success_H.XTickLabel =  cellstr(num2str(unique_days));
    subplot_ind = subplot_ind+1;
    xlabel ('Day')
    title( ['Mouse ', num2str(current_animal)])
    ylabel('Success rate')
    ylim ([0 1])
    legend(unique(success_data.IDcue))
end
%% average success rate plot

[avg_group_inds, avgIDcue,avgIDday] = findgroups (success_table.IDcue,success_table.IDday);
avg_success = splitapply(@sum,success_table.success,avg_group_inds)./numel(unique(success_table.IDanimal));
avg_success_table = table(avg_success, avgIDcue, avgIDday);

F.avg_success_rate_figure = figure('Name', 'Average success rate plot');
figure(F.avg_success_rate_figure)
hold on
    for cue=unique(avg_success_table.avgIDcue)'
        avg_relevant_inds = strcmp(avg_success_table.avgIDcue, cue);
        if (length(avg_relevant_inds) ~= length(unique_days))
                disp('there was a day with no trials of a certain type');
                day_vec = ismember(unique(avg_success_table.avgIDday), avg_success_table.avgIDday(avg_relevant_inds)); %which day is missing?
                avg_relevant_success = nan(1,length(unique_days));                                                     % missing days are nan
                avg_relevant_success(day_vec) = avg_success_table.avg_success(avg_relevant_inds);                      % fill in non missing days
                plot(1:length(unique_days),avg_relevant_success,'-O')
        else
            avg_relevant_success(day_vec) = avg_success_table.avg_success(avg_relevant_inds); 
            plot(1:length(unique_days),  avg_relevant_success(avg_relevant_inds), '-o')
        end 
    end
    h_ax = F.avg_success_rate_figure.Children;
    h_ax.XTickLabels = cellstr(num2str(unique_days));
    xlabel ('Day')
    ylabel('Success rate')
    ylim ([0 1])
    legend(unique(avg_success_table.avgIDcue))
       
    


% figure(F.avg_success_rate_figure)
% hold on
% for avg_cue=unique(success_table.IDcue)'
%     avg_relevant_success=splitapply(@sum,success_table.success,avg_group_inds)./numel(unique(success_table.IDanimal))
%     plot(unique_days, avg_relevant_success, '-o')
% end


    
% [avg_group_inds,IDcue,IDday ] = findgroups (T.cue_type, T.date );
% avg_visits_2 = splitapply (@length, T.RFID, avg_group_inds);
% avg_success =  splitapply((@(r) sum(strcmp(r,'correct'))),T.trial_result, avg_group_inds);
% avg_success = avg_success./avg_visits_2;
% avg_success_table = table(avg_success , IDcue , IDday);
% 
% F.avg_success_rate_figure = figure('Name', 'Average success rate plot');
% figure(F.avg_success_rate_figure)
% hold on
%     for cue=unique(avg_success_table.IDcue)'
%         avg_relevant_inds = strcmp(avg_success_table.IDcue, cue);
%         plot(unique(avg_success_table.IDday), avg_success_table.avg_success(avg_relevant_inds),'-O')
%         xlabel ('Day')
%         ylabel('Success rate')
%         ylim ([0 1])
%         legend(unique(success_data.IDcue))
%     end

%% success rate line figure - per day & cue type  -without omissions!!!
% ============= No omissions ============================================
T_no_omittion = T(~strcmp(T.trial_result, 'omitted'),:);
[group_inds, IDanimal,IDcue,IDday ] = findgroups (T_no_omittion.names,T_no_omittion.cue_type, T_no_omittion.date );
visits = splitapply (@length, T_no_omittion.RFID, group_inds);
success =  splitapply((@(r) sum(strcmp(r,'correct'))),T_no_omittion.trial_result, group_inds);
success = success./visits;
success_table = table(success ,IDanimal , IDcue , IDday);

F.success_no_omission = figure('Name', 'Success rate without omission!!!');
subplot_ind = 1;
figure(F.success_no_omission)
for current_animal = unique(IDanimal)'
    success_H = subplot(1,length(unique(IDanimal)),subplot_ind);
    hold on
    success_data = success_table(IDanimal == current_animal,:);
    for cue=unique(success_data.IDcue)'
        relevant_inds = strcmp(success_data.IDcue, cue);
        unique_days = unique(success_data.IDday);
        if (length(relevant_inds) ~= length(unique_days))
            disp('there was a day with no trials of a certain type');
            day_vec = ismember(unique(success_data.IDday), success_data.IDday(relevant_inds)); %which day is missing?
            relevant_success = nan(1,length(unique_days));                                     % missing days are nan
            relevant_success(day_vec) = success_data.success(relevant_inds);                   % fill in non missing days
            plot(1:length(unique_days), relevant_success, '-o')
            else
                relevant_success(day_vec) = success_data.success(relevant_inds); 
                plot(1:length(unique_days), relevant_success(relevant_inds), '-o')
            end
        end
end
    success_H.XTickLabel =  cellstr(num2str(unique_days));
    subplot_ind = subplot_ind+1;
    xlabel ('Day')
    title( ['Mouse ', num2str(current_animal)])
    ylabel('Success rate')
    ylim ([0 1])
    legend(unique(success_data.IDcue))
    title ('Success without omssions')
    




%% figure for activity during the day
% all mice in the cage collapsed
figure()
histogram(T_all.trial_time.Hour)
xlabel('Hour in the day')
ylabel('Count')
title('Activity during the day (active + not active), whole cage')

%collored by mouse (to see if thee is one that has different hours)
figure()
hold on
for name = unique(T_all.names)'
    histogram(T_all.trial_time.Hour(T_all.names==name))
end
legend(num2str(unique(T_all.names)))
xlabel('Hour in the day')
ylabel('Count')
title('Activity during the day (active+not), by mouse')

%% save all figures in a folder.
% notice the file name of the figure is named after the date of the
% analysis. if you run analysis in the same day it will over write it. 

formatOut = 'yymmdd';    
figure_folder_name = datestr(now,formatOut);
figure_file_name = [figure_folder_name,'.fig'];
figure_folder_path = 'C:\Users\owner\Documents\Bpod Local\Results';
figure_folder_full = fullfile(figure_folder_path, figure_folder_name);
if exist(figure_folder_full,'dir')==0
    mkdir (figure_folder_full)
end 

figure_file_full = fullfile(figure_folder_full, ['figures',figure_folder_name]);
data_file_full = fullfile(figure_folder_full, 'data.mat');
fignames = fields(F);
for fig=1:length(fignames)
    F1(fig) = F.(fignames{fig});
end
    
savefig(F1,figure_file_full)
save(data_file_full, 'T_all')





