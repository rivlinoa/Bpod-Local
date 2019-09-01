
%{
Nosepoke adaptation
The mouse initiates a trial upon RfID read,
If presence is detected within 3 sec from RF read the protocol starts.

After a defined delay period a light is on in the left/right port (for a
defined duration)
A nosepoke in the correct port during a defined response window will result
in a reward supply.

Assume port 1 is left, port 3 is right
port 4 is presence detection 1 (out) port 5 is presence detection 2 (in)
%}

function NosepokeAdaptation2

global BpodSystem
global tag
global FileName

%% Define parameters
%CurrentMouseDisplay('update', tag)
S = BpodSystem.ProtocolSettings; % Load settings chosen in launch manager into current workspace as a struct called S
if isempty(fieldnames(S))  % If settings file was an empty struct, populate struct with default settings
    S.GUI.RewardAmount = 10; %ul
    S.GUI.Delay=0; %sec
    S.GUI.CueDuration=2; %sec
    S.GUI.ResponseDuration=2; %sec
    S.GUI.NegativeReinforcerSound=0; %0=off, 1=on
    S.GUI.LightIntensity=255; % values between 0 to 255
 end

%% Define trials
%1=choose left, 2=choose right

%load the data of previous trials, and calculate the fraction of
%occurence of each condition for this specific mouse. use that as a 
%threshold for applying any of the possible conditions.   


threshold=0.5;
TrialNumber=1;
if exist(FileName, 'file')==2
    load(FileName)
    TrialNumber=length(SessionData.TrialNumber)+1;
    TrialHistory=[];
    for trial=1:size(SessionData.RFID,1)%maybe I dont need a loop if I can use some compare string function...
        if strcmp(SessionData.RFID{trial},tag)
            TrialHistory=[TrialHistory, SessionData.TrialTypes(trial)];
        end
    end
    if ~isempty(TrialHistory)
        threshold= mean(TrialHistory)-1;
    end
end
TrialTypes = (rand(1)>threshold)+1;

BpodSystem.Data.TrialTypes = []; % The trial type of each trial completed will be added here.

%% Initialize GUI
BpodNotebook('init'); % Initialize Bpod notebook (for manual data annotation)
BpodParameterGUI('init', S); % Initialize parameter GUI plugin

%% Initialize plots
% add total reward, total visit number, sucess rate
% maybe timeline of choices + outcomes...

%% Analog module intiation (should not be defined each time ...) maybe add a different file. 

% SF = 100000; % Analog module sampling rate
% SinWaveFreq=4000;
SoundDuration=0.1;
% NegativeReinforcerSound = GenerateSineWave(SF, SinWaveFreq, SoundDuration)*.9; % Sampling freq (hz), Sine frequency (hz), duration (s)
% Program sound server...

%% Main virtual state machine code
%Here I dont use a loop since I want only a single trial per RF read.


S = BpodParameterGUI('sync', S); % Sync parameters with BpodParameterGUI plugin

if S.GUI.NegativeReinforcerSound
        PunishOutputAction = {'PWM3',0,'PWM1',0};%,'WavePlayer1', 3};
    else
        PunishOutputAction = {'PWM3',0,'PWM1',0};
end
R = GetValveTimes(S.GUI.RewardAmount, [1 3]); LeftValveTime = R(1); RightValveTime = R(2); % Update reward amounts

% Assume port 1 is left, port 3 is right(port 4 is presence detection)
switch TrialTypes % Determine trial-specific state matrix fields
        case 1
            Stimulus={'PWM1', S.GUI.LightIntensity, 'GlobalTimerTrig', 1}; 
            LeftActionState = 'Reward'; RightActionState = 'Punish'; 
            ValveCode = 1; ValveTime = LeftValveTime;
        case 2
            Stimulus={'PWM3', S.GUI.LightIntensity, 'GlobalTimerTrig', 1}; 
            LeftActionState = 'Punish'; RightActionState = 'Reward'; 
            ValveCode = 4; ValveTime = RightValveTime;
end

    
sma = NewStateMatrix(); % Assemble state matrix
sma = SetGlobalTimer(sma, 1, S.GUI.ResponseDuration); 
sma = AddState(sma, 'Name', 'WaitForPresence', ...
    'Timer',  12,... %what are the units? seconds?
    'StateChangeConditions', {'Port4In', 'Delay','Port5In', 'Delay' 'Tup', 'exit'},...
    'OutputActions', {});
sma = AddState(sma, 'Name', 'Delay', ...
    'Timer', S.GUI.Delay,... 
    'StateChangeConditions', {'Port4Out', 'exit', 'Tup','DeliverStimulus','Port1In', 'Punish', 'Port3In', 'Punish'},...
    'OutputActions', {});
sma = AddState(sma, 'Name', 'DeliverStimulus', ...
    'Timer', S.GUI.CueDuration,... 
    'StateChangeConditions', {'Port4Out', 'exit', 'Tup','WaitForPoke', 'Port1In', LeftActionState,'Port3In' ,RightActionState, 'GlobalTimer1_End', 'TimeOut'},...
    'OutputActions', Stimulus);
sma = AddState(sma, 'Name', 'WaitForPoke', ...
    'Timer', 0,...
    'StateChangeConditions', {'Port1In', LeftActionState, 'Port3In' ,RightActionState,'GlobalTimer1_End', 'TimeOut', 'Port4Out','exit'},...
    'OutputActions', {});
sma = AddState(sma, 'Name', 'TimeOut', ...
    'Timer', 0,...
    'StateChangeConditions', {'Port1In', 'Punish', 'Port3In' ,'Punish', 'Port4Out','exit'},...
    'OutputActions', {});
sma = AddState(sma, 'Name', 'Reward', ...
    'Timer', ValveTime,...
    'StateChangeConditions', {'Tup', 'Drinking', 'Port4Out','exit'},...
    'OutputActions', {'ValveState', ValveCode});
sma = AddState(sma, 'Name', 'Punish', ...
    'Timer',SoundDuration ,...
    'StateChangeConditions', {'Port4Out','exit', 'Tup', 'TimeOut'},...
    'OutputActions', PunishOutputAction); 
sma = AddState(sma, 'Name', 'Drinking', ...
    'Timer', 10,...
    'StateChangeConditions', {'Tup', 'TimeOut', 'Port4Out','exit'},...
    'OutputActions', {});


SendStateMatrix(sma);
RawEvents = RunStateMatrix;
if ~isempty(fieldnames(RawEvents)) % If trial data was returned
    BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents); % Computes trial events from raw data
    BpodSystem.Data = BpodNotebook('sync', BpodSystem.Data); % Sync with Bpod notebook plugin
    BpodSystem.Data.TrialSettings = S; % Adds the settings used for the current trial to the Data struct (to be saved after the trial ends)
    BpodSystem.Data.TrialTypes = TrialTypes; % Adds the trial type of the current trial to data
    BpodSystem.Data.RFID = {tag};
    BpodSystem.Data.State = DefineStateNosepokeAdaptation(BpodSystem.Data);
    BpodSystem.Data.TrialNumber=TrialNumber;
    
    RewardAmount=BpodSystem.Data.TrialSettings.GUI.RewardAmount;
    if ~isnan(BpodSystem.Data.RawEvents.Trial{1,1}.States.Reward)
        BpodSystem.Data.RewardDelivered=RewardAmount;
    else
        BpodSystem.Data.RewardDelivered=0;
    end

    SaveOneTrial(FileName);
end 
%% Prepare data for online plotting:
disp(BpodSystem.Data.State);
           

    
%% End
HandlePauseCondition; % Checks to see if the protocol is paused. If so, waits until user resumes.
if BpodSystem.Status.BeingUsed == 0
    return
end
%CurrentMouseDisplay('update', ' ') %update the current mouse display to no mouse since the mouse left the corner (probably). 
% TrialStatePlot(BpodSystem.ProtocolFigures.TrialStatePlotFig,'update', TrialNumber , cell2mat(BpodSystem.Data.State),  {tag}, 50);

end 



