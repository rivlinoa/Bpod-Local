function cue_in_cloud_consule

% function CUE_IN_CLOUD_CONSULE runs an experiment for cue in cloud.
% it is meant to be run through Bpod consule, and incorporate the use of
% sending and recieving soft codes. 
% there are 4 possible cue attenuations. 
try
    disp('start')

    % settings:
    global BpodSystem
    settings = BpodSystem.ProtocolSettings; 
    
    % find the settings path and store it in Bpodsystem path:
    settings_path = [ BpodSystem.Path.ProtocolFolder,...
        BpodSystem.Status.CurrentProtocolName, ...
        '\Settings' ];
    x = dir(settings_path);
    y = {x.name};                
    if ismember('template.mat', y)
        BpodSystem.Path.settings_path = settings_path;      
    else
        BpodSystem.Path.settings_path = [settings_path, ...
        '\Settings_files'];
    end
    
    if isempty(fieldnames(settings))            % If settings file was an empty struct, populate struct with default settings
            S.GUI.RewardAmount = 25;            % ul
            S.GUI.ResponseDuration = 1;         % sec
            S.GUI.MaxDelay = 2;                 % sec
            S.GUI.MinDelay = 0.5;               % sec
            S.GUI.AudVis = 0.1;                 % Between 0-1, fraction of trials that would have auditory+visual stimulus.  
            S.GUI.AudVisCloud = 0.1;            % Between 0-1, auditory+visual stimulus with cloud. 
            S.GUI.Aud = 0.4;                    % Between 0-1, auditory stimulus.
            S.GUI.AudCloud = 0.4;               % Between 0-1, auditory stimulus with cloud.
            S.GUI.CueAtten = 0.4;               % Between 0-1, the proportion of easy trials. 
            S.GUI.is_bbn = 0;
    end
   
    BpodSystem.SoftCodeHandlerFunction = 'read_rf';
    
    % initiations :
    global RFID
    RFID = serial('COM8');
    
    
    %% load the wave player 
    if (isfield(BpodSystem.ModuleUSB, 'WavePlayer1'))
        WavePlayerUSB = BpodSystem.ModuleUSB.WavePlayer1;
    else
        error('Error: To run this protocol, you must first pair the WavePlayer1 module with its USB port. Click the USB config button on the Bpod console.')
    end
    
    W = BpodWavePlayer(WavePlayerUSB);
    W.SamplingRate = 50000;                                                % max in 4 ch configurationn.
    SF = W.SamplingRate;
    W.BpodEvents = {'On','On','On','On'};
    W.TriggerMode = 'Master';
    W.OutputRange = '0V:5V';                                                                % maximal rage in 0-5v outputrange
       
    load('C:\Users\owner\Documents\Bpod Local\Protocols\CueInCloud\filtered_cloud.mat');    % change in the annex!
    load('C:\Users\owner\Documents\Bpod Local\Protocols\CueInCloud\cue.mat');               % change in the annex!
    cue =  (cue - min(cue));
    cue = cue / max(abs(cue));
    cue = cue.*0.99;                                                                    
    filtered_cloud =  (filtered_cloud - min(filtered_cloud));
    filtered_cloud = filtered_cloud / max(abs(filtered_cloud));
    filtered_cloud = filtered_cloud.*(1).*0.99;                                            
    
    cue_attenuations = [0.2, 0.5, 1, 2]';                                  % change in the annex!
    cue_mat = cue_attenuations * cue;
    BBN_LENGTH = 0.1;
    t = [0:(1/SF):BBN_LENGTH];                                                    % used for the BBN creation
    BBN =  wgn(1,length(t),1);                                             % BBN creation
    BBN = BBN + abs(min(BBN));
    BBN = (BBN / max(BBN)) * 1.5 * 0.99;                                   % scale BBN to be at output range of 0-5 

    % Add cue attenuations here : 
    W.loadWaveform(1, cue_mat(1,:))                                            % 4 attenuations of the cue
    W.loadWaveform(2, cue_mat(2,:))
    W.loadWaveform(3, cue_mat(3,:))
    W.loadWaveform(4, cue_mat(4,:))
    W.loadWaveform(5, filtered_cloud)
    W.loadWaveform(6, BBN);
                                                                     
    LoadSerialMessages('WavePlayer1', {['P', 1, 0], ['P', 1, 1],...
        ['P', 1, 2], ['P', 1, 3], ['P', 2, 4], ['P', 1, 5]});                       % play cue on ch 1 play cloud on ch 2
    BpodSystem.Data = struct;             
    BpodSystem.Data.cloud = filtered_cloud;
    BpodSystem.Data.cue = cue;
    BpodSystem.Data.TESTER_RFID = '00782B1799DD';
    % BpodSystem.Path.DataFolder  = '\\132.64.104.28\citri-lab\noa.rivlin\bpod_results\test';
    
    %% initiate figures
    BpodSystem.GUIData.bar = struct;
    BpodSystem.GUIData.bar.x_labels = categorical(settings.names);
    BpodSystem.GUIData.bar.success = zeros(1, height(settings));
    BpodSystem.GUIData.bar.visit_count = zeros(1, height(settings));
    BpodSystem.GUIData.bar.correct_count = zeros(1, height(settings));
    BpodSystem.GUIData.bar.reward_count = zeros(1, height(settings));
    
    BpodSystem.ProtocolFigures.success = figure('name','Success_rate','numbertitle','off', 'MenuBar', 'none', 'Resize', 'off');
    BpodSystem.ProtocolFigures.visits = figure('name','Visit_count','numbertitle','off', 'MenuBar', 'none', 'Resize', 'off');
    BpodSystem.ProtocolFigures.reward = figure('name','Reward_supplied','numbertitle','off', 'MenuBar', 'none', 'Resize', 'off');
    BpodSystem.GUIHandles.success_ax = axes('Parent', BpodSystem.ProtocolFigures.success);
    BpodSystem.GUIHandles.visit_ax = axes('Parent', BpodSystem.ProtocolFigures.visits);
    BpodSystem.GUIHandles.reward_ax = axes('Parent', BpodSystem.ProtocolFigures.reward);
    BpodSystem.GUIHandles.success_bar = bar(BpodSystem.GUIHandles.success_ax, ...
        categorical(BpodSystem.GUIData.bar.x_labels),...
            BpodSystem.GUIData.bar.success,  0.6);
    BpodSystem.GUIHandles.visit_bar = bar(BpodSystem.GUIHandles.visit_ax, ...
        categorical(BpodSystem.GUIData.bar.x_labels),...
            BpodSystem.GUIData.bar.visit_count,  0.6);
    BpodSystem.GUIHandles.reward_bar = bar(BpodSystem.GUIHandles.reward_ax, ...
        categorical(BpodSystem.GUIData.bar.x_labels),...
            BpodSystem.GUIData.bar.reward_count,  0.6);
        
        
 % replace with real vlues :        
%     xlabel(BpodSystem.GUIHandles.h_ax, 'Optogenetics LED')
%     ylabel(BpodSystem.GUIHandles.h_ax, 'Success rate')
%     hold(BpodSystem.GUIHandles.h_ax, 'on');
%     title(BpodSystem.GUIHandles.h_ax, '0 Visits'); 
%     BpodSystem.GUIHandles.h_ax.YLim = [0, 1];
    
  %% The main loop   
    n_trials = 100000;
    T = TrialManagerObject;
    T.Timer.Period = 0.001; %0.22;
    p = struct;
    BpodSystem.Status.tmp_rf = BpodSystem.Data.TESTER_RFID;                % Start a dummy trial with the tester RFID and template settings                                      
    % disp('loop')
    for i = 1:n_trials
            disp(datetime('now'));                                         % serves as validation the the experiment is running
            tmp = p;
            subject_settings = load_settings(BpodSystem.Status.tmp_rf, settings);
            p = define_trial(subject_settings);                            % define parameters for the coming trial: 
            sma = prepare_sma(p);                                          % Prepare next trial's state machine   
            p.subject_settings = subject_settings;
            p.RFID = BpodSystem.Status.tmp_rf;                             % the current animal that was read. 
            if BpodSystem.Status.BeingUsed == 0
                
                return; 
            end               % If user hit console "stop" button, end session 
            % disp('trial')
            T.startTrial(sma);                                             % run the state machine
            
            %%% inside the state machine: sent a soft code to start read_rf 
            % function when a tag was read matlab sends a soft code to end 
            % the current trial so a new trial can be initiated. 
            
            if i > 1
                BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents); % Computes trial events from raw data
                
                % update online graphics :
                animal_ind = strcmp(settings.tags, tmp.RFID);
                if all(~animal_ind)                                          % if there is n unrecognized read mark it as the tester
                    animal_ind(length(animal_ind)) = 1;
                end 
                is_success = 0;
                reward = 0;
                
                if ~ isnan(BpodSystem.Data.RawEvents.Trial{1, (i-1)}.States.Reward (1))
                    is_success = 1;
                    reward = tmp.reward;
                end 
                update_graphs(animal_ind, is_success, reward)
              
                % save data :           
                BpodSystem.Data.reward_supplied(i-1) = reward;
                BpodSystem.Data.Delay{i-1} = tmp.delay;
                BpodSystem.Data.attencloud{i-1} = tmp.attencloud;
                BpodSystem.Data.cue_atten{i-1} = tmp.cue_atten;
                BpodSystem.Data.CueTypes{i-1} = tmp.Cuetype;
                BpodSystem.Data.ResponseDuration(i-1) = tmp.response;
                BpodSystem.Data.RFID{i-1} = tmp.RFID;
                BpodSystem.Data.settings{i-1} = tmp.subject_settings; 
                SaveBpodSessionData;
                                      
            end         
           RawEvents = T.getTrialData;                         % Hangs here until trial end, then returns the trial's raw data
    end
    
catch ME
    mail = 'citrilabbpod@gmail.com';
    subject = 'Matlab has crashed';
    message = ME.message;
    disp(message);
    %sendmail(mail,subject,message)
end 
end 

function p = define_trial(S) 
            
    % function DEFINE_TRIAL defins the trial parameters - what is the stimulus 
    % (auditory / auditory visual). is there a cloud or not... attenuations
    current_trial = rand(1);
    if current_trial < S.CueAtten
        p.cue_atten = 4;
    else
        p.cue_atten = randi(4);
    end
    
    current_trial = rand(1);
    if current_trial < S.AudVis
                p.Cuetype = 'AudVis';
                p.CueAction = {'WavePlayer1', p.cue_atten ,'PWM1', 255 };
                p.attencloud = 0; 
                p.CloudAction = {}; 
    elseif current_trial < (S.AudVis + S.AudVisCloud)
                p.Cuetype = 'AudVisCloud';
                p.CueAction = {'WavePlayer1', p.cue_atten ,'PWM1', 255 };
                p.attencloud = 1; 
                p.CloudAction = {'WavePlayer1', 5};                        % 5 = the cloud
    elseif current_trial < (S.AudVis + S.AudVisCloud + S.Aud)
                p.Cuetype = 'Aud';
                p.CueAction = {'WavePlayer1', p.cue_atten };
                p.attencloud = 0; 
                p.CloudAction = {};
    else                                                                   % audcloud 
                p.Cuetype = 'AudCloud';
                p.CueAction = {'WavePlayer1', p.cue_atten };
                p.attencloud = 1; 
                p.CloudAction = {'WavePlayer1', 5};
    end 
    p.delay = S.MinDelay + rand(1) * (S.MaxDelay - S.MinDelay);
    p.response = S.ResponseDuration;
    p.ValveTime = GetValveTimes(S.RewardAmount, 1 ); 
    p.reward = S.RewardAmount;
    
    if isfield(S, 'is_bbn')
        p.is_bbn = S.is_bbn;
    else
        p.is_bbn = 0;
    end 
    
    if p.is_bbn
        p.bbn_timer = 0.1;                                                 % 0.1 sec is the length of the BBN signal. change it if its changed. 
        p.bbn_action = {'WavePlayer1', 6};
    else
        p.bbn_timer = 0.001;
        p.bbn_action = {};
    end 
    end 

function sma = prepare_sma(p)
% function PREPARE_SMA creates a single trial of a state machine fo be run.
% the input is the cue action (aud or aud+vis), and the claoud laser action
% (+ / - cloud +/ - laser). both are stated as state machine actions. 
    
    sma = NewStateMatrix();
    
    sma = AddState(sma, 'Name', 'BBN', ...
        'Timer', p.bbn_timer,...
        'StateChangeConditions', {'Port1In','WaitForExit', 'Tup', 'Delay'},...
        'OutputActions',  p.bbn_action);
    
    sma = AddState(sma, 'Name', 'Delay', ...
        'Timer', p.delay,...
        'StateChangeConditions', {'Port1In','WaitForExit', 'Tup', 'CueOn'},...
        'OutputActions', p.CloudAction);
    
    sma = AddState(sma, 'Name', 'CueOn', ...
        'Timer', p.response,...
        'StateChangeConditions', {'Port1In', 'Reward','Tup', 'WaitForExit'},...
        'OutputActions', p.CueAction );
    
    sma = AddState(sma, 'Name', 'Reward', ...
        'Timer', p.ValveTime,...
        'StateChangeConditions', {'Tup', 'Drinking'},...
        'OutputActions', {'ValveState', 1});
    
    sma = AddState(sma, 'Name', 'Drinking', ...
        'Timer', 5,...
        'StateChangeConditions', {'Tup','ReadRF'},...
        'OutputActions', {});
    
    sma = AddState(sma, 'Name', 'WaitForExit', ...
        'Timer', 3,...
        'StateChangeConditions', {'Tup','ReadRF'},...
        'OutputActions', {});
    
    sma = AddState(sma, 'Name', 'ReadRF', ...
        'Timer', 0,...
        'StateChangeConditions', {'SoftCode1', 'exit'},...
        'OutputActions', {'SoftCode', 2});

end 

function subject_settings = load_settings(tag, settings)
    global BpodSystem
    animal_ind = strcmp(settings.tags, tag);
    if all(~animal_ind)
        settings_name = 'template';
    else
        settings_name = settings.settings{animal_ind};
    end 
    subject_settings = load([BpodSystem.Path.settings_path, '\', settings_name]);
    tmp = fields(subject_settings);
    subject_settings = subject_settings.(tmp{1});
    if isfield(subject_settings, 'GUI')
        subject_settings = subject_settings.GUI;
    end 
end 
 
function update_graphs(animal_ind, is_success, reward)

    global BpodSystem
    % update visits:
    BpodSystem.GUIData.bar.visit_count(animal_ind) = ...
        BpodSystem.GUIData.bar.visit_count(animal_ind) + 1;
    set(BpodSystem.GUIHandles.visit_bar, 'ydata', ...
        BpodSystem.GUIData.bar.visit_count);
    
    % update success
    if is_success
      BpodSystem.GUIData.bar.correct_count(animal_ind) = ...
           BpodSystem.GUIData.bar.correct_count(animal_ind) +1; 
       BpodSystem.GUIData.bar.success = BpodSystem.GUIData.bar.correct_count ./ ...
           BpodSystem.GUIData.bar.visit_count;
       set(BpodSystem.GUIHandles.success_bar, 'ydata', ...
            BpodSystem.GUIData.bar.success);
        
        
      % update reward_supplied
        BpodSystem.GUIData.bar.reward_count(animal_ind) = ...
           BpodSystem.GUIData.bar.reward_count(animal_ind) + reward; 
        set(BpodSystem.GUIHandles.reward_bar, 'ydata', ...
            BpodSystem.GUIData.bar.reward_count);
    end 
    
    
    
    drawnow();
end 