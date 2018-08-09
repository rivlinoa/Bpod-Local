optionalfreq = logspace(3.3,4.35,50);
stimulus_length = 4; %ms
chord_length = 0.05; %ms
chord_num = stimulus_length/chord_length;

SamplingRate = 50000;
Ramplength = 0.01;
Stlength = 0.100;
%Create evenlop
dt=1/SamplingRate;
n_ramp = Ramplength*SamplingRate;
n_trial = Stlength*SamplingRate;
on_ramp = linspace(0,1,n_ramp);
off_ramp = linspace(1,0,n_ramp);
steady_state = ones(1,n_trial-2*n_ramp+1);
env=[on_ramp steady_state off_ramp]; 


stim=[];
for i=1:chord_num
    no_of_freq = round(rand*7)+3;
    chordfreq = datasample(optionalfreq, no_of_freq, 'Replace',false);
    omega=2*pi.*chordfreq;
    tt = [0:1:(n_trial-1)] * dt;
    sig1=sin(omega'*tt);
    chord = sum(sig1);
    chord = chord  -(min(chord));
    chord = chord / max(chord);
    chord = chord.*env(1:size(chord,2));
    stim = [stim chord];
end

sound(stim,SamplingRate)
filename=fullfile('C:\Users\owner\Documents\Bpod Local\Protocols\CueInCloud', 'cloud.mat');
save(filename, 'stim')

%% generate a signal to match:
Stlength = 0.050; % in seconds
Trlength = 0.200; % in seconds
Trnumber = 1;
cue_duration = 1.5; 
cue_frequency = 4000; 
n_ramp = Ramplength*SamplingRate;
n_trial = Stlength*SamplingRate;
on_ramp = linspace(0,1,n_ramp);
off_ramp = linspace(1,0,n_ramp);
steady_state = ones(1,n_trial-2*n_ramp+1);
env=[on_ramp steady_state off_ramp]; 

%Create sound
omega=2*pi*cue_frequency;
tt = [0:1:(n_trial-1)] * dt;
sig1=sin(omega*tt);
%plot(sig)
sig1=sig1.*env(1:size(sig1,2)); % this is the signal with the envelope
sig1=[sig1 zeros(1,round((Trlength-Stlength)*SamplingRate))];

seq1=[];
for ind=1:round(cue_duration/Trlength)
seq1=[seq1 sig1];
end

seq1 = seq1  -(min(seq1));
seq1 = seq1 / max(seq1);
cue=seq1;
cuename = fullfile('C:\Users\owner\Documents\Bpod Local\Protocols\CueInCloud', 'cue.mat');
save(cuename, 'cue')
sound(seq1,SamplingRate)