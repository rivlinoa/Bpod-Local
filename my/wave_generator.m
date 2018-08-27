Bpod
%% prepare analog output module
WavePlayerUSB = BpodSystem.ModuleUSB.WavePlayer1;
A = BpodWavePlayer(WavePlayerUSB);
A.SamplingRate = 50000; % max in 4 ch configurationn.
A.BpodEvents = {'On','On','On','On'};
A.TriggerMode = 'Master';
A.OutputRange = '0V:5V';

%%  prepare wave-form
SF = A.SamplingRate; 
Stlength = 0.500; % in seconds (write something in Hz)
Trlength = 1; % in seconds 
Duration = 5;
sig1=ones(1,Stlength*SF); % this is the signal with the envelope
sig1=[sig1 zeros(1,(Trlength-Stlength)*SF)];

Max_voltage = 5; %V find a way to extract from object

wave = [];
for ind=1:round(Duration/Trlength)
wave = [wave sig1];
end

wave = wave.*Max_voltage;

%% activate
A.loadWaveform(1, wave);
A.play(3,1);
% TTL config is working, volume is controlled by thr laser itself. 
%%
sig1=sin(omega*tt);
sig1=sig1+1;
sig1=sig1.*(Max_voltage/2).*0.99;
A.loadWaveform(2, sig1);
A.play(3,2);




LoadSerialMessages('WavePlayer1', {['P' ,1, 0 ]});