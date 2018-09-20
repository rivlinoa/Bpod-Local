
A.loadWaveform(i, cloudmat(i,:)); % the cloud, for now only one...
A.loadWaveform(10+i, cuemat(i,:)); % the cue for now only one ....
LoadSerialMessages('WavePlayer1', {['P' ,1, 10 ],['P' ,1, 10 ]});
LoadSerialMessages('WavePlayer1', ['P' ,1, 10 ], 3);
clear sma            
sma = NewStateMatrix();
sma = AddState(sma, 'Name', 'WaitForPresence', ...
    'Timer', 10,... %what are the units? seconds?
    'StateChangeConditions', {'Tup', 'exit'},...
    'OutputActions', {'WavePlayer1', 2});
SendStateMatrix(sma);
RawEvents = RunStateMatrix;