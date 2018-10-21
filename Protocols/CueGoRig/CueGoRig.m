%{
CueGoRig
when a mouce enters the presence detection LED, a sound indicates whether
this trial will contain a cue. (white noise for yes, sweep for no). 
The could be visual / auditory + visual / auditory in some probabilities. 
sound frequency and light intensity can be set in the settings file.

Created by Noa 17.9.18

%}

function CueGoRig

global BpodSystem

%% Define parameters
S = BpodSystem.ProtocolSettings; % Load settings chosen in run_protocol_single_trial into current workspace as a struct called S
if isempty(fieldnames(S))  % If settings file was an empty struct, populate struct with default settings
    S.GUI.RewardAmount = 15; % ul
    S.GUI.ResponseDuration = 3; % sec
    S.GUI.MaxDelay = 2; % sec
    S.GUI.MinDelay = 0.5; % sec
    
    S.GUI.CueProb = 1; % Between 0-1, fraction of trials that would have any cue .
    
    S.GUI.LightProb = 0.5; % Between 0-1, fraction of trials that would have auditory+visual stimulus.  
    S.GUI.LightSoundProb = 0.5; % prob of light + sound  trials, make sure 2 numbers add to less than 1!!!
    S.GUI.LightIntensity = 255; % from 1 to 255
    S.GUI.SinWaveFreq = 6000; %Hz
    S.GUI.SoundDuration = 1; %sec 
end

if ~isfield(BpodSystem.GUIData,'ParameterGUI')
    BpodParameterGUI('init', S);
end


%% Load sounds to wave player
if (isfield(BpodSystem.ModuleUSB, 'WavePlayer1'))
        WavePlayerUSB = BpodSystem.ModuleUSB.WavePlayer1;
    else
        error('Error: To run this protocol, you must first pair the AudioPlayer1 module with its USB port. Click the USB config button on the Bpod console.')
end

A = BpodWavePlayer(WavePlayerUSB);
A.SamplingRate = 49900; % max in 4 ch configurationn.
A.BpodEvents = {'On','On','On','On'};
A.TriggerMode = 'Master';
SF = A.SamplingRate;
analogPortIndex = find(strcmp(BpodSystem.Modules.Name, 'WavePlayer1'));
if isempty(analogPortIndex)
    error('Error: Bpod WavePlayer module not found. If you just plugged it in, please restart Bpod.')
end

 if S.GUI.SinWaveFreq ~= BpodSystem.GUIData.LastFrequency
        % generate sound for the cue
        Sound = sound_generator(SF, S.GUI.SinWaveFreq, S.GUI.SoundDuration); % Sampling freq (hz), Sine frequency (hz), duration (s)
        Sound = Sound+1;
        A.loadWaveform(1, Sound);
        
        % generate sweeps sounds for entry = will / will not be a cue. 
        t = [0:(1/SF):0.5];
        IsCue =  wgn(1,length(t),1);
        IsCue = IsCue / max(IsCue);
        IsCue = IsCue + abs(min(IsCue));
        NoCue =  chirp(t, 200, t(end), 5000);
        NoCue = NoCue + abs(min(NoCue));
        A.loadWaveform(2, IsCue);
        A.loadWaveform(3, NoCue);
        BpodSystem.GUIData.LastFrequency = S.GUI.SinWaveFreq;
        BpodSystem.Data.Cue = Sound;
        BpodSystem.Data.IsCueSignal = IsCue; 
        BpodSystem.Data.NoCueSignal = NoCue; 
        % All sounds are playes on the same channel . 
        LoadSerialMessages('WavePlayer1', {['P' ,1, 0 ],['P' ,1, 1 ],['P' ,1, 2 ]});
        
 end
 BpodSystem.GUIData.LastFrequency = S.GUI.SinWaveFreq;


%% Define trials
if rand(1) <= S.GUI.CueProb % if its a cued trial
    EntryAction = {'WavePlayer1', 2}; % deliver is cue signal.
    %define cue type
    define_cue = rand(1);
    if define_cue <= S.GUI.LightProb % only visual
        CueAction = {'PWM1', S.GUI.LightIntensity};
        Cuetype = 'Vis';
        CueState = 'CueOn'; 
    elseif define_cue <= (S.GUI.LightProb + S.GUI.LightSoundProb) % visual + auditory
        CueAction = {'WavePlayer1',1,'PWM1', S.GUI.LightIntensity};
        Cuetype ='AudVis';
        CueState = 'CueOn'; 
    else
        CueAction = {'WavePlayer1',1}; % only auditory
        Cuetype ='Aud';
        CueState = 'CueOn'; 
    end 
    
else % no cue trial
    EntryAction = {'WavePlayer1', 3}; % deliver no cue signal.
    CueAction = {};
    Cuetype = nan;
    CueState = 'WaitForExit'; 
end 

%% Sync parameters GUI after randomization of delay time. :)
Delay = S.GUI.MinDelay + rand()*(S.GUI.MaxDelay-S.GUI.MinDelay);
S.GUI.Delay = Delay;

%% The state matrix
%S = BpodParameterGUI('sync', S); % Sync parameters with BpodParameterGUI plugin
R = GetValveTimes(S.GUI.RewardAmount, 1 ); ValveTime = R; % Update reward amounts
sma = NewStateMatrix(); % Assemble state matrix
sma = SetCondition(sma, 1, 'Port4', 1); % a condition where port 4 is in
sma = SetCondition(sma, 2, 'Port4', 0); % a condition where port 4 is out
sma = AddState(sma, 'Name', 'WaitForPresence', ...
    'Timer', 1,... %what are the units? seconds?
    'StateChangeConditions', {'Port4In','EntrySignal','Condition1', 'EntrySignal', 'Port4Out','exit', 'Tup', 'exit'},...
    'OutputActions', {});
sma = AddState(sma, 'Name', 'EntrySignal', ...
    'Timer', 0.5,... %the length of the entry sound 
    'StateChangeConditions', {'Tup','Delay','Condition2','exit'},...
    'OutputActions', EntryAction);
sma = AddState(sma, 'Name', 'Delay', ...
    'Timer', Delay,...
    'StateChangeConditions', {'Port1In','WaitForExit', 'Tup', CueState, 'Condition2','exit'},...
    'OutputActions', {});
sma = AddState(sma, 'Name', 'CueOn', ...
    'Timer', S.GUI.ResponseDuration,...
    'StateChangeConditions', {'Port1In', 'Reward','Tup', 'WaitForExit', 'Condition2','exit'},...
    'OutputActions', CueAction );
sma = AddState(sma, 'Name', 'Reward', ...
    'Timer', ValveTime,...
    'StateChangeConditions', {'Tup', 'Drinking', 'Condition2','exit'},...
    'OutputActions', {'ValveState', 1});
sma = AddState(sma, 'Name', 'Drinking', ...
    'Timer', 0,...
    'StateChangeConditions', {'Condition2','exit'},...
    'OutputActions', {});
sma = AddState(sma, 'Name', 'WaitForExit', ...
    'Timer', 0,...
    'StateChangeConditions', {'Condition2','exit'},...
    'OutputActions', {});

SendStateMatrix(sma);
RawEvents = RunStateMatrix;

if ~isempty(fieldnames(RawEvents)) % If trial data was returned
    BpodSystem.Data = add_trial_events_RF(BpodSystem.Data,RawEvents); % Computes trial events from raw data
    trial_number=BpodSystem.Data.nTrials;
    % save trial type into data (important whene randomizing...):
    BpodSystem.Data.CueTypes{trial_number} = Cuetype;
    BpodSystem.Data.Delay{trial_number} = Delay;
    % update the visit count graph
    % If the figure was closed, first initiate it and then update it:
    if isvalid(BpodSystem.GUIHandles.visit_count)
        visit_plot(BpodSystem.GUIHandles.visit_count, 'update',BpodSystem.GUIData.SubjectName)
    else
        visit_plot(BpodSystem.GUIHandles.visit_count, 'init')
        visit_plot(BpodSystem.GUIHandles.visit_count, 'update',BpodSystem.GUIData.SubjectName)
    end
    
    % Check if the trial reached state 'drinking' and save reward
    % amount given:
    % update reward delivered graph:
    if ~isnan(BpodSystem.Data.RawEvents.Trial{1,  trial_number}.States.Drinking(1,1))
        BpodSystem.Data.reward_supplied(trial_number)=S.GUI.RewardAmount;
        BpodSystem.Data.ResponseDuration(trial_number)=S.GUI.ResponseDuration;
        BpodSystem.Data.settings{trial_number}=S;
        % If the figure was closed, first initiate it and then update it:
        if isvalid(BpodSystem.GUIHandles.reward_supplied)
            reward_supplied_plot(BpodSystem.GUIHandles.reward_supplied,'update', BpodSystem.GUIData.SubjectName, BpodSystem.Data.reward_supplied(trial_number))
        else
            reward_supplied_plot(BpodSystem.GUIHandles.reward_supplied, 'init')
            reward_supplied_plot(BpodSystem.GUIHandles.reward_supplied,'update', BpodSystem.GUIData.SubjectName, BpodSystem.Data.reward_supplied(trial_number))
        end
    end
    
    %Save this trial data to the pre-defined file name (by prepare to
    %protocol function)
    SessionData = BpodSystem.Data;
    save(BpodSystem.Path.CurrentDataFile, 'SessionData', '-v6');
end

HandlePauseCondition; % Checks to see if the protocol is paused. If so, waits until user resumes.
if BpodSystem.Status.BeingUsed == 0
    return
end