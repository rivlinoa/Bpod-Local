%% Use this code to create a table of all animals participating in the experiment 
% User should connect the RFID reader to the USB port, and record all
% inserted chips.

%% Initiate the table with empty variables
animals=table();
animals.tags=zeros(0);
animals.names=zeros(0);

%% Cal the RFID reader (make sire its connected to the usb port.
% change the COM port number if needed (you can view the port number in
% windows device manager. 

RFID=serial('COM8'); 
fopen(RFID);
tag=fscanf(RFID)
tag=tag(logical(isstrprop(tag,'digit')+isstrprop(tag,'alpha'))); %erase non digit/letter figures from tag

%% User should manually insert animal name and tag to its structure. Add more animals as needed. 
animal1.tags={'00782B199CD6'};
animal1.names=6;

animal2.tags={'00782B19C389'};
animal2.names=5;

animal3.tags={'00782B17E1A5'};
animal3.names=7;

%% insert all animals to the table
% add more rows if needed!

animals=[animals;struct2table(animal1)];
animals=[animals;struct2table(animal2)];
animals=[animals;struct2table(animal3)];

disp(animals) %check to validate its correct

%% Save animals table in Bpod_local/Data

formatOut = 'mm_dd_yy';
file_name=['animals_',datestr(now,formatOut)];
file_name= fullfile('Data/', file_name)
save(file_name,'animals')

%%
% strcmp (to find the right animal name)
% 
% animals.names(strcmp(animals.tags,'xxxxxx')) % to find the correct animal
% name you need. 