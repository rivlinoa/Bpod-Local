
% A.loadWaveform(i, cloudmat(i,:)); % the cloud, for now only one...
% A.loadWaveform(10+i, cuemat(i,:)); % the cue for now only one ....
% LoadSerialMessages('WavePlayer1', {['P' ,1, 10 ],['P' ,1, 10 ]});
% LoadSerialMessages('WavePlayer1', ['P' ,1, 10 ], 3);
clear sma            
sma = NewStateMatrix();
sma = AddState(sma, 'Name', 'a1', ...
    'Timer', 6,... %what are the units? seconds?
    'StateChangeConditions', {'Tup', 'a2'},...
    'OutputActions', {'WavePlayer1',1});
sma = AddState(sma, 'Name', 'a2', ...
    'Timer', 6,... %what are the units? seconds?
    'StateChangeConditions', {'Tup', 'a3'},...
    'OutputActions', {'WavePlayer1',2});
sma = AddState(sma, 'Name', 'a3', ...
    'Timer', 6,... %what are the units? seconds?
    'StateChangeConditions', {'Tup', 'a4'},...
    'OutputActions', {'WavePlayer1',3});
sma = AddState(sma, 'Name', 'a4', ...
    'Timer', 6,... %what are the units? seconds?
    'StateChangeConditions', {'Tup', 'a5'},...
    'OutputActions', {'WavePlayer1',4});
sma = AddState(sma, 'Name', 'a5', ...
    'Timer', 6,... %what are the units? seconds?
    'StateChangeConditions', {'Tup', 'a6'},...
    'OutputActions', {'WavePlayer1',5});
sma = AddState(sma, 'Name', 'a6', ...
    'Timer', 6,... %what are the units? seconds?
    'StateChangeConditions', {'Tup', 'a7'},...
    'OutputActions', {'WavePlayer1',6});
sma = AddState(sma, 'Name', 'a7', ...
    'Timer', 6,... %what are the units? seconds?
    'StateChangeConditions', {'Tup', 'exit'},...
    'OutputActions', {'WavePlayer1',7});

SendStateMatrix(sma);
RawEvents = RunStateMatrix;