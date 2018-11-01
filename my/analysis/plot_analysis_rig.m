%% plot task analysis

cd 'C:\Users\owner\Documents\Bpod Local\Data for remote\Rig'  % change to the relevant folder in your computer
file_list = {'2_LickResponseTDT_20181015_130903'};            % add as many files as you want to

performance = figure('Name', 'Performance plot');
hold on
max_x = 0; 


for file = file_list
    load([cell2mat(file),'.mat']);
    TaskAnalysis = analysis_rig(SessionData);
    
    % ========= plot pie charts of performance per session ========
    figure()
    p = pie(table2array(TaskAnalysis.Results(1,:)));
    pText = findobj(p,'Type','text');
    percentValues = get(pText,'String'); 
    txt = TaskAnalysis.Results.Properties.VariableNames'; 
    combinedtxt = strcat(txt,percentValues); 
    for i= 1:length(combinedtxt)
        pText(i).String = combinedtxt(i);
    end 
    title(strrep(cell2mat(file), '_', '-'));
    
    % === plot performance of the mouse over sessions on the same plot ======
    figure(performance)
    x_values = (max_x + 1):(max_x  + max(TaskAnalysis.Data.trial_number));
    x = line(x_values, TaskAnalysis.Data.plot_result);
    gscatter(x_values, TaskAnalysis.Data.plot_result, TaskAnalysis.Data.trial_result)
    max_x = max(x.XData); 
    line([max_x,max_x] ,[-2, 3],'Color','black', 'LineWidth' , 4)
end 