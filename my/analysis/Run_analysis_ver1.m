%% Run analysis ver 1 - offline analysis for gocue protocol in Bpod.

%% A - load data files (as exported from bpod):
% User should loadd as much data files as needed (all should be from the
% same cage and experiment. each data file should be loaded to a seperate
% variable. you can drag the file to the workspace and copy the correct line from the command window.

file1 = load('C:\Users\owner\Documents\Bpod Local\Data\18.08.23_17.51.45\Session Data\18.08.23_17.51.45.mat');
%file2 = load('C:\Users\owner\Documents\Bpod Local\Data\18.08.06_08.41.38\Session Data\18.08.06_08.41.38.mat');
% file3 = ...
%% B- load animals file
load('C:\Users\owner\Documents\Bpod Local\Data\animals_23_07_18.mat');

%% C - Cretae a table for each of the files, you should specify the file name to save each of them.
% example: T = create_table(SessionData, animals, filename)
% you can ignore warnings if they appear
T1 = create_table(file1, animals, 'table1');
% T2 = create_table(file2, animals, 'table2');


%% Connect two tables
%T = [T1; T2];
T = T1;
%% create summary table and 2 plots:
T.RT = T.reaction_time - cell2mat(T.delay);

data_set=struct();

F.reward_figure = figure('Name', 'Reward plot');
F.performance_figure = figure('Name', 'Performance plot');
F.histogram_figure = figure('Name', 'Histogram plot');
F.rt_figure = figure('Name', 'Reaction time plot');
F.cue_type_figure = figure('Name', 'Cue type plot');
F.RT_delay_figure = figure('Name', 'RT vs. delay');
F.presence_omission_figure = figure('Name', 'Presence to omission');

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
    day_ind=find(day==unique(T.date));
    
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
        
        %% plot presence to omission  histogram
        figure(F.presence_omission_figure)
        presence_H(subplot_value) = subplot(sum(animalsID>0), length(unique(T.date)),  subplot_value);
        hold on
        omission_inds = strcmp(T_animal.trial_result, 'omitted');
        histogram( T_animal.visit_duration(omission_inds),'BinWidth',0.1)
        xlabel('Presence before omission')
        ylabel('Visit count')
        title(['Day ',num2str(day), ' mouse ' , num2str(animal_ind)])
        xlim([0 5])       
        
        %% prepare data to plot performance by cue type
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
        for cue=unique(T_animal.cue_type)'
            relevant_inds = strcmp(T_animal.cue_type, cue);
            plot(cell2mat(T_animal.delay(relevant_inds)), T_animal.RT(relevant_inds),'o')
        end
        line(xlim(), [0,0]);
        xlabel('Delay (sec)')
        ylabel ('RT relative to cue (sec)')
        ylim ([-3,3])
        title(['Day ',num2str(day), ' mouse ' , num2str(animal_ind)])
        legend(unique(T_animal.cue_type))
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
control_axes(presence_H)

%% success rate line figure
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
        plot(unique(success_data.IDday), success_data.success(relevant_inds))
    end
    subplot_ind = subplot_ind+1;
    xlabel ('Day')
    title( ['Mouse ', num2str(current_animal)])
    ylabel('Success rate')
    ylim ([0 1])
    legend(unique(success_data.IDcue))
end

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
save(data_file_full, 'T')





