% A protocol with trial manager object
min_delay = 0;
max_delay = 2;

%% define a state matrix for a single trial :
delay = min_delay + rand(1) * (max_delay - min_delay);
sma = NewStateMatrix(); % Assemble state matrix
sma = AddState(sma, 'Name', 'Delay', ...
    'Timer', delay,... 
    'StateChangeConditions', {'Port1In','exit', 'Tup', 'Cue'},...
    'OutputActions', {});
sma = AddState(sma, 'Name', 'Cue', ...
    'Timer', 1,...
    'StateChangeConditions', {'Port1In','exit', 'Tup', 'exit'},...
    'OutputActions', {'PWM1', 255});

%%
trial_manager = TrialManagerObject;