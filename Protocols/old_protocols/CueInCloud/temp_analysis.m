%%temporary_analysis
%% How many correct with no visual clouds
a= length (find (T.names==1 & cell2mat (T.attencloud)>0 & strcmp(T.cue_type,'AudCloud')));
b= length (find (T.names==1 & cell2mat (T.attencloud)>0 & T.reward_supplied>0 & strcmp(T.cue_type,'AudCloud')));
CorrectCloudNoVis1 = (b./a)*100
c= length (find (T.names==4 & cell2mat (T.attencloud)>0 & strcmp(T.cue_type,'AudCloud')));
d= length (find (T.names==4 & cell2mat (T.attencloud)>0 & T.reward_supplied>0 & strcmp(T.cue_type,'AudCloud')));
CorrectCloudNoVis4 = (d./c)*100
e= length (find (T.names==5 & cell2mat (T.attencloud)>0 & strcmp(T.cue_type,'AudCloud')));
f= length (find (T.names==5 & cell2mat (T.attencloud)>0 & T.reward_supplied>0 & strcmp(T.cue_type,'AudCloud')));
CorrectCloudNoVis5 = (f./e)*100

%% How many correct visual clouds
a= length (find (T.names==1 & cell2mat (T.attencloud)>0 & strcmp(T.cue_type,'AudVisCloud')));
b= length (find (T.names==1 & cell2mat (T.attencloud)>0 & T.reward_supplied>0 & strcmp(T.cue_type,'AudVisCloud')));
CorrectCloudVis1 = (b./a)*100 %m1
c= length (find (T.names==4 & cell2mat (T.attencloud)>0 & strcmp(T.cue_type,'AudVisCloud')));
d= length (find (T.names==4 & cell2mat (T.attencloud)>0 & T.reward_supplied>0 & strcmp(T.cue_type,'AudVisCloud')));
CorrectCloudVis4 = (d./c)*100 %m4
e= length (find (T.names==5 & cell2mat (T.attencloud)>0 & strcmp(T.cue_type,'AudVisCloud')));
f= length (find (T.names==5 & cell2mat (T.attencloud)>0 & T.reward_supplied>0 & strcmp(T.cue_type,'AudVisCloud')));
CorrectCloudVis5 = (f./e)*100 %m5
% %% Plot
% hold on
% yy= [CorrectCloudVis1 CorrectCloudNoVis1];
% if CorrectCloudNoVis1== NaN;
%    CorrectCloudNoVis1=0;
% end
% xx= [1 2];
% subplot(1,3,1)
% plot (xx,yy)
% bar (yy)
% title ('mouse 1')
% axis ([0.5,2.5,0,100])
% xlabel ('cloud type')
% ylabel ('succes (%)')
% 
% zz= [CorrectCloudVis4 CorrectCloudNoVis4];
% if CorrectCloudNoVis4== NaN;
%     CorrectCloudNoVis4=0;
% end
% pp= [1 2];
% subplot(1,3,2)
% plot (zz,pp)
% bar (pp)
% title ('mouse 4')
% axis ([0.5,2.5,0,100])
% xlabel ('cloud type')
% ylabel ('succes (%)')
% 
% ww= [CorrectCloudVis1 CorrectCloudNoVis1];
% if CorrectCloudNoVis5== NaN;
%     CorrectCloudNoVis5=0;
% end
% mm= [1 2];
% subplot(1,3,3)
% plot (mm,ww)
% bar (ww)
% title ('mouse 1')
% axis ([0.5,2.5,0,100])
% xlabel ('cloud type')
% ylabel ('succes (%)')
% 
%    
   
%% Succes rate and atten
aa = length (find (T.names==1 & cell2mat(T.attencloud)==1));
bb = length (find (T.names==1 & cell2mat(T.attencloud)==1 & T.reward_supplied>0));
CorrectAtten1m1= bb./aa*100;

cc = length (find (T.names==1 & cell2mat(T.attencloud)==2));
dd = length (find (T.names==1 & cell2mat(T.attencloud)==2 & T.reward_supplied>0));
CorrectAtten2m1= dd./cc*100; %m1

ee = length (find (T.names==4 & cell2mat(T.attencloud)==1));
ff = length (find (T.names==4 & cell2mat(T.attencloud)==1 & T.reward_supplied>0));
CorrectAtten1m4= ff./ee*100;

gg = length (find (T.names==4 & cell2mat(T.attencloud)==2));
hh = length (find (T.names==4 & cell2mat(T.attencloud)==2 & T.reward_supplied>0));
CorrectAtten2m4= hh./gg*100; %m4

ii = length (find (T.names==5 & cell2mat(T.attencloud)==1));
jj = length (find (T.names==5 & cell2mat(T.attencloud)==1 & T.reward_supplied>0));
CorrectAtten1m5= jj./ii*100;

kk = length (find (T.names==5 & cell2mat(T.attencloud)==2));
ll = length (find (T.names==5 & cell2mat(T.attencloud)==2 & T.reward_supplied>0));
CorrectAtten2m5= ll./kk*100; %m5


%% atten succes plot
hold on
y=[CorrectAtten1m1 CorrectAtten2m1];
x= [1 2];
subplot(1,3,1)
plot (x,y)
bar (y)
title ('mouse 1')
axis ([0.5,2.5,0,100])
xlabel ('attenuation rate')
ylabel ('succes (%)')

z=[CorrectAtten1m4 CorrectAtten2m4];
p= [1 2];
subplot(1,3,2)
plot (p,z)
bar (z)
title ('mouse 4')
axis ([0.5,2.5,0,100])
xlabel ('attenuation rate')
ylabel ('succes (%)')

w=[CorrectAtten1m5 CorrectAtten2m5];
m= [1 2];
subplot(1,3,3)
plot (m,w)
bar (w)
title ('mouse 5')
axis ([0.5,2.5,0,100])
xlabel ('attenuation rate')
ylabel ('succes (%)')