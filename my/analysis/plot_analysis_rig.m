%% plot task analysis

cd 'C:\Users\Owner\Documents\Bpod Local\Data\2\LickResponseTDT\Session Data'  % change to the relevant folder in your computer
file_list = {'2_LickResponseTDT_20181204_180227'};                            % add as many files as you want to

performance = figure('Name', 'Performance plot');
hold on
max_x = 0;


for file = file_list
    load([cell2mat(file),'.mat']);
    TaskAnalysis = analysis_rig(SessionData);
    
    % ========= plot pie charts of performance per session ========
    h0 = figure('Name','performaceChart');
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
    h1 = figure('Name','performance');
    hold on;
    x_values = (max_x + 1):(max_x  + max(TaskAnalysis.Data.trial_number));
    x = line([x_values;x_values], [zeros(1,length(x_values));TaskAnalysis.Data.plot_result'],'Color','k');
    gscatter(x_values, TaskAnalysis.Data.plot_result, TaskAnalysis.Data.trial_result)
    max_x =max(x_values)+1;                                                  %I assumed this is what you were aiming for?
                                                                             %Otherwise there are multiple lines and MATLAB can't find the max
    x_end=line([max_x,max_x] ,[-2, 3],'Color','black', 'LineWidth' , 4);
    set(get(get(x_end,'Annotation'),'LegendInformation'),...
        'IconDisplayStyle','off');                                           %Makes so there is no legend entry for the last line
end