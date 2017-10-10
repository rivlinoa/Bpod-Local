function SaveOneSession (
global BpodSystem
SessionData = BpodSystem.Data;
save(BpodSystem.Path.CurrentDataFile, 'SessionData', '-v6');








data = [data1 data2 data3 data4];    %# Create a structure array of your data
names = fieldnames(data);            %# Get the field names
cellData = cellfun(@(f) {vertcat(data.(f))},names);  %# Collect field data into
                                                     %#   a cell array
data = cell2struct(cellData,names);  %# Convert the cell array into a structure




