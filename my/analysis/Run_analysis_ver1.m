  %% Run analysis ver 1 - offline analysis for gocue protocol in Bpod.

%% A - load data files (as exported from bpod):
% User should loadd as much data files as needed (all should be from the
% same cage and experiment. each data file should be loaded to a seperate
% variable. you can drag the file to the workspace and copy the correct line from the command window.

file1 = load('C:\Users\Owner\Documents\Bpod Local\Data\18.08.23_17.51.45\Session Data\18.08.23_17.51.45.mat');
% file2 = load('C:\Users\Owner\Documents\Bpod Local\Data\18.08.12_12.46.24\Session Data\18.08.12_12.46.24.mat');
% file3 = ...
%% B- load animals file
load('C:\Users\owner\Documents\Bpod Local\Data\animals_23_07_18.mat');

%% C - Cretae a table for each of the files, you should specify the file name to save each of them.
% example: T = create_table(SessionData, animals, filename)
% you can ignore warnings if they appear
T1 = create_table(file1, animals, 'table1');
% T2 = create_table(file2, animals, 'table2');


%% Connect two tables
T = [T1];

%% create summary table and 2 plots:
[result_inds, resultID] = findgroups(T.trial_result);
T.result_inds = result_inds;
T.RT = T.reaction_time-cell2mat(T.delay);

data_set=struct();
figure_ind=1;

%settings_figure = figure ('Name','Settings plot'); %---ADDED 22/8
reward_figure = figure('Name', 'Reward plot');
performance_figure = figure('Name', 'Performance plot');
histogram_figure = figure('Name', 'Histogram plot');
rt_figure = figure('Name', 'Reaction time plot');

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
    
    figure(reward_figure)
    hold on
    subplot(1, length(unique(T.date)),  day_ind);
    bar(categorical(data_set.(['day',num2str(day)]).animalsID),  data_set.(['day',num2str(day)]).reward)
    xlabel('Mouce name')
    ylabel('Reward supplied /ul')
    title (['Day',num2str(day)])
    
    % figure for performance
    
    figure(performance_figure)
    hold on
    subplot(1, length(unique(T.date)),  day_ind);
    ytoplot = table2array([data_set.(['day',num2str(day)]).results_table(:,2:end);]);
    bar(categorical(data_set.(['day',num2str(day)]).animalsID), ytoplot, 'stacked');
    ylabel('Visits count')
    xlabel('Mouce name')
    title(['Day',num2str(day)])
    
    % ADDED 22/8----------------------------
    % figure for settings
    
    %day_ind=find(day==unique(T.date));
    
    %figure(settings_figure)
    %hold on
    %subplot(1, length(unique(T.date)),  day_ind,(SessionData.(['settings',num2str(day)]).SettingsFile), settings_ind);
    %bar(categorical(data_set.(['day',num2str(day)]).animalsID),  data_set.(['day',num2str(day)]).reward) 
    %bar(categorial(data_set.(['SettingsFile',num2str(settings)]).SettingsFile))
    %xlabel('settings') 
    %ylabel('Reward supplied /ul')
    %title (['Day',num2str(day)])
    %---------------------------------------
    %Histogram
    for animal_ind = animalsID(animalsID>0)'
        
        data_inds2 = (T_day.names==animal_ind);
        T_animal = T_day(data_inds2,:);
        
        animal_i=find(animal_ind==animalsID(animalsID>0)'); % to ignore test trials, name=0
        delay_correct=cell2mat(T_animal.delay(strcmp(T_animal.trial_result,'correct')));
        delay_omitted=cell2mat(T_animal.delay(strcmp(T_animal.trial_result,'omitted')));
        delay_premature=cell2mat(T_animal.delay(strcmp(T_animal.trial_result,'premature')));
        delay_late=cell2mat(T_animal.delay(strcmp(T_animal.trial_result,'late')));
        
        figure(histogram_figure)
        subplot_value = ((animal_i-1)*length(unique(T.date)))+day_ind
        subplot(sum(animalsID>0), length(unique(T.date)),  subplot_value);
        hold on
     
        histogram(delay_correct,'BinWidth',0.05,'facecolor', 'g','facealpha',.3,'edgecolor','none')
        histogram(delay_omitted,'BinWidth',0.05,'facecolor', 'b','facealpha',.3,'edgecolor','none')
        histogram(delay_premature,'BinWidth',0.05,'facecolor', 'r','facealpha',.3,'edgecolor','none')
        xlabel('Delay time')
        ylabel('Visit count')
        title(['Day ',num2str(day), ' mouce ' , num2str(animal_ind)])
       
        figure(rt_figure)
        subplot_value = ((animal_i-1)*length(unique(T.date)))+day_ind
        subplot(sum(animalsID>0), length(unique(T.date)),  subplot_value);
        hold on
        histogram( T_animal.RT,'BinWidth',0.05)
        xlabel('Reaction time relative to cue onset')
        ylabel('Visit count')
        title(['Day ',num2str(day), ' mouce ' , num2str(animal_ind)])
        xlim([-1 3])
       
    end
    
end

figure(performance_figure)
legend('Correct', 'Omitted', 'Premature', 'Late')
figure(histogram_figure)
legend('Ccorrect','Omitted','Premature')
%% figure for histograms






