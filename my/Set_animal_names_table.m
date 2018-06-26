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
animal1.tags={'xxxxxx'};
animal1.names=1;

animal2.tags={'yyyyyy'};
animal2.names=2;

animal3.tags={'zzzzzz'};
animal3.names=3;

%% insert all animals to the table
% add more rows if needed!

animals=[animals;struct2table(animal1)];
animals=[animals;struct2table(animal2)];
animals=[animals;struct2table(animal3)];

disp(animals) %check to validate its correct

%% Save animals table in Bpod_local/Data
cd(C:/Users/owner/Documents/Bpod Local/Data);
formatOut = 'mm_dd_yy';
file_name=['animals_',datestr(now,formatOut)];
save(file_name,'animals')

%%
% strcmp (to find the right animal name)
% 
% animals.names(strcmp(animals.tags,'xxxxxx')) % to find the correct animal
% name you need. 