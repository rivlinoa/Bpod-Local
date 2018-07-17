function SineWave = sound_generator (SamplingRate, Frequency, Duration)

Ramplength = 0.005;
Stlength = 0.100; % in seconds
Trlength = 0.250; % in seconds
Trnumber = 1;


%Create evenlop
dt=1/SamplingRate;
n_ramp = Ramplength*SamplingRate;
n_trial = Stlength*SamplingRate;
on_ramp = linspace(0,1,n_ramp);
off_ramp = linspace(1,0,n_ramp);
steady_state = ones(1,n_trial-2*n_ramp+1);
env=[on_ramp steady_state off_ramp]; 

%Create sound
omega=2*pi*Frequency;
tt = [0:1:(n_trial-1)] * dt;
sig1=sin(omega*tt);
%plot(sig)
sig1=sig1.*env(1:size(sig1,2)); % this is the signal with the envelope
sig1=[sig1 zeros(1,(Trlength-Stlength)*SamplingRate)];

seq1=[];
for ind=1:round(Duration/Trlength)
seq1=[seq1 sig1];
end

mm1=max(abs(seq1));%wavwrite clips any signal =>1; mm is used to normalize the signal
seq1=seq1/mm1*0.999;

SineWave=seq1;
end 