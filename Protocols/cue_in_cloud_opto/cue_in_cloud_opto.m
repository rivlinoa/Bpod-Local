function cue_in_cloud_opto
% function CUE_IN_CLOUD_OPTO runs an experiment for cue in cloud with
% optogenetic stimulation. it is meant to be run through Bpod consule, and
% assume only a single mouse is present in the cage at the moment. 


    % settings:
    global BpodSystem
    S = BpodSystem.ProtocolSettings; 
    if isempty(fieldnames(S))               % If settings file was an empty struct, populate struct with default settings
            S.RewardAmount = 25;            % ul
            S.ResponseDuration = 1;         % sec
            S.MaxDelay = 2;                 % sec
            S.MinDelay = 0.5;               % sec
            S.AudVis = 0.1;                 % Between 0-1, fraction of trials that would have auditory+visual stimulus.  
            S.AudVisCloud = 0.1;            % Between 0-1, auditory+visual stimulus with cloud. 
            S.Aud = 0.4;                    % Between 0-1, auditory stimulus.
            S.AudCloud = 0.4;               % Between 0-1, auditory stimulus with cloud.
            S.laser = 0.3;                  % Between 0-1, fraction of trials with stimulation ( only from aud + aud cloud ) .
    end
    if isfield(S, 'GUI')
        S = S.GUI;
    end
    % BpodSystem.SoftCodeHandlerFunction = 'SoftCodeHandler_Printout';
    
    % initiations :
    RFID2 = serial('COM15');
    
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
    W.TriggerProfileEnable = 'On';
    
    load('C:\Users\Owner\Documents\Stimuli\filtered_cloud.mat');    
    load('C:\Users\Owner\Documents\Stimuli\cue.mat');              
    load ('C:\Users\owner\Documents\Bpod Local\Protocols\cue_in_cloud_opto\stimulation.mat');
                                                                         
    filtered_cloud = filtered_cloud - min(filtered_cloud);
    filtered_cloud = filtered_cloud / max(filtered_cloud);
    filtered_cloud = filtered_cloud.*0.99.*0.5;
    cue = cue - min(cue);
    cue = cue / max(cue);
    cue = cue.*0.99;
                                             
    stimulation = stimulation.*(5).*0.99; 
    
    W.loadWaveform(1, cue)
    W.loadWaveform(2, filtered_cloud)
    W.loadWaveform(3, stimulation)
    
    W.TriggerProfiles(1,: ) = [1 0 0 0];                                   % 1- cue
    W.TriggerProfiles(2,: ) = [0 2 0 0];                                   % 2- cloud
    W.TriggerProfiles(3,: ) = [0 0 3 0];                                   % 3- stimulate
    W.TriggerProfiles(4,: ) = [0 2 3 0];                                   % 4 - cloud + stimulate 
                                                                           % 5- stop stimulation 
    LoadSerialMessages('WavePlayer1', {['P' 0],['P' 1],['P' 2],...         % Message 1 = play trigger profile 0
        ['P' 3], []});
    BpodSystem.Data=struct;
    BpodSystem.Data.cloud = filtered_cloud;
    BpodSystem.Data.cue = cue;
    BpodSystem.Data.stimulation = stimulation;
    % BpodSystem.Path.DataFolder  = '\\132.64.104.28\citri-lab\noa.rivlin\bpod_results\test';
    
    %% initiate figures
    BpodSystem.GUIData.bar = struct;
    BpodSystem.GUIData.bar.x_labels = {'On', 'Off'};
    BpodSystem.GUIData.bar.success = [0, 0];
    BpodSystem.GUIData.bar.visit_count = [0, 0];
    BpodSystem.GUIData.bar.correct_count = [0, 0];
    BpodSystem.ProtocolFigures.success = figure('name','Success_rate','numbertitle','off', 'MenuBar', 'none', 'Resize', 'off');
    BpodSystem.GUIHandles.h_ax = axes('Parent', BpodSystem.ProtocolFigures.success);
    axes(BpodSystem.GUIHandles.h_ax)
    BpodSystem.GUIHandles.h_bar = bar(categorical(BpodSystem.GUIData.bar.x_labels),...
            BpodSystem.GUIData.bar.success,  0.6);
    xlabel(BpodSystem.GUIHandles.h_ax, 'Optogenetics LED')
    ylabel(BpodSystem.GUIHandles.h_ax, 'Success rate')
    hold(BpodSystem.GUIHandles.h_ax, 'on');
    title(BpodSystem.GUIHandles.h_ax, '0 Visits'); 
    BpodSystem.GUIHandles.h_ax.YLim = [0, 1];
    
    % set(BpodSystem.GUIHandles.visit_count_bar,'ydata', BpodSystem.GUIData.animals.visit_count);

    % success rate figure - with title number of visits 
    % {'WavePlayer1', 'X'} % stop all playback in all channels \
    
  %% The main loop   
    n_trials = 1000;
    T = TrialManagerObject;
    p = struct;
    
    for i = 1:n_trials
            tmp = p;
            % define parameters for the coming trial: 
            p = define_trial(S);  
            sma = prepare_sma(p);                                          % Prepare next trial's state machine   
            if i>1; RawEvents = T.getTrialData;  end                       % Hangs here until trial end, then returns the trial's raw data
            if BpodSystem.Status.BeingUsed == 0; return; end               % If user hit console "stop" button, end session 
            T.startTrial(sma);                                             % run the state machine
              
            fopen(RFID2);                                                  % RF loop to send the soft code
            while (1)
                tag = fscanf(RFID2);
                tag = tag(logical(isstrprop(tag,'digit')+isstrprop(tag,'alpha'))); %eliminate white spaces from the RF read
                if (length(tag)==12) 
                     fclose(RFID2);
                     disp (tag)
                     p.RFID = tag;
                     SendBpodSoftCode(1)
                     break 
                end 
                     
            end 
            
            if i > 1
                BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents); % Computes trial events from raw data
                                
                if tmp.laser
                    BpodSystem.GUIData.bar.visit_count(1) = BpodSystem.GUIData.bar.visit_count(1) + 1;
                    if ~ isnan(BpodSystem.Data.RawEvents.Trial{1, 1}.States.Reward(1))
                         BpodSystem.GUIData.bar.correct_count(1) = BpodSystem.GUIData.bar.correct_count(1) + 1;
                    end
                    
                else
                    BpodSystem.GUIData.bar.visit_count(2) = BpodSystem.GUIData.bar.visit_count(2) + 1;
                    if ~ isnan(BpodSystem.Data.RawEvents.Trial{1, 1}.States.Reward(1))
                         BpodSystem.GUIData.bar.correct_count(2) = BpodSystem.GUIData.bar.correct_count(2) + 1;
                    end
                end 
                BpodSystem.GUIData.bar.success = BpodSystem.GUIData.bar.correct_count ./...
                                                     BpodSystem.GUIData.bar.visit_count;
                set(BpodSystem.GUIHandles.h_bar, 'ydata', ...
                    BpodSystem.GUIData.bar.success);
                BpodSystem.GUIHandles.h_ax.Title.String = [ num2str(i-1), '  Visits'];
                drawnow();
                
                BpodSystem.Data.Delay{i-1} = tmp.delay;
                BpodSystem.Data.attencloud{i-1} = tmp.attencloud;
                BpodSystem.Data.CueTypes{i-1} = tmp.Cuetype;
                BpodSystem.Data.ResponseDuration(i-1) = tmp.response;
                BpodSystem.Data.Laser(i-1) = tmp.laser;
                BpodSystem.Data.RFID{i-1} = tmp.RFID;
                if ~ isnan(BpodSystem.Data.RawEvents.Trial{1, 1}.States.Reward(1))
                    BpodSystem.Data.reward_supplied(i-1) = S.RewardAmount;
                else
                    BpodSystem.Data.reward_supplied(i-1) = 0;
                end
                SaveBpodSessionData;
            end         
           
    end

end 


function p = define_trial(S) 
            
    % function DEFINE_TRIAL defins the trial parameters - what is the stimulus 
    % (auditory / auditory visual). is there a cloud or not, is there a laser
    % stimulation or not. 
    current_trial = rand(1);
    is_laser = rand(1);

    if current_trial < S.AudVis
                p.Cuetype = 'AudVis';
                p.CueAction = {'WavePlayer1', 1 ,'PWM2', 255 };
                p.attencloud = 0; 
                p.CloudLaserAction = {}; 
                p.laser = 0;
      elseif current_trial < (S.AudVis + S.AudVisCloud)
                p.Cuetype = 'AudVisCloud';
                p.CueAction = {'WavePlayer1', 1 ,'PWM2', 255 };
                p.attencloud = 1; 
                p.CloudLaserAction = {'WavePlayer1', 2};
                p.laser = 0;
      elseif current_trial < (S.AudVis + S.AudVisCloud + S.Aud)
                p.Cuetype = 'Aud';
                p.CueAction = {'WavePlayer1', 1 };
                p.attencloud = 0; 
                if is_laser < S.laser
                    p.CloudLaserAction = {'WavePlayer1', 3};
                    p.laser = 1;
                else
                     p.CloudLaserAction = {};
                     p.laser = 0;
                end
      else  % audcloud 
                p.Cuetype = 'AudCloud';
                p.CueAction = {'WavePlayer1', 1 };
                p.attencloud = 1; 
                if is_laser < S.laser
                    p.CloudLaserAction = {'WavePlayer1', 4};
                    p.laser = 1;
                else
                     p.CloudLaserAction = {'WavePlayer1', 2};
                     p.laser = 0;
                end
    end 
    p.delay = S.MinDelay + rand(1) * (S.MaxDelay - S.MinDelay);
    p.response = S.ResponseDuration;  
    R = GetValveTimes(S.RewardAmount, 1 ); p.ValveTime = R;
end 


function sma = prepare_sma(p)
% function PREPARE_SMA creates a single trial of a state machine fo be run.
% the input is the cue action (aud or aud+vis), and the claoud laser action
% (+ / - cloud +/ - laser). both are stated as state machine actions. 
    
    sma = NewStateMatrix();
    sma = AddState(sma, 'Name', 'WaitForRF', ...
        'Timer', 0,...
        'StateChangeConditions', {'SoftCode1', 'Delay'},...
        'OutputActions', {});
    
    sma = AddState(sma, 'Name', 'Delay', ...
        'Timer', p.delay,...
        'StateChangeConditions', {'Port2In','WaitForExit', 'Tup', 'CueOn'},...
        'OutputActions', p.CloudLaserAction);
    
    sma = AddState(sma, 'Name', 'CueOn', ...
        'Timer', p.response,...
        'StateChangeConditions', {'Port2In', 'Reward','Tup', 'WaitForExit'},...
        'OutputActions', p.CueAction );
    
    sma = AddState(sma, 'Name', 'Reward', ...
        'Timer', p.ValveTime,...
        'StateChangeConditions', {'Tup', 'Drinking'},...
        'OutputActions', {'ValveState', 2});
    
    sma = AddState(sma, 'Name', 'Drinking', ...
        'Timer', 5,...
        'StateChangeConditions', {'Tup','exit'},...
        'OutputActions', {});
    
    sma = AddState(sma, 'Name', 'WaitForExit', ...
        'Timer', 2,...
        'StateChangeConditions', {'Tup','exit'},...
        'OutputActions', {});

end 