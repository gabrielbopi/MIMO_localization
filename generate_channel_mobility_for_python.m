clear all;
clc ;

M_tx = 1;
N_tx = 1;

M_rx = 8;
N_rx = 8;

nPRB = 20;

fc =  30e9;  % Frequência central
n  =  3;

% n=0 -> Df = 15Khz * 2^(0)
% n=1 -> Df = 15Khz * 2^(1)
% n=2 -> Df = 15Khz * 2^(2)
% n=3 -> Df = 15Khz * 2^(3) ....

MT_height = 1;
userPos = [10;10;MT_height];
BSpos   = [0;0;3];
ThreeGPPModel = 0;

azm = atan2(userPos(2),userPos(1));
channelModel = 'mmMAGIC_Indoor_LOS';
SD = 1.5;
fsample = 2*fc*SD/3e8;
% #fsample = 2
dist = 0.1;
numSamples = fsample*dist;

[H,h,layout,channelBuilder] = genChannelModelMobility(M_tx,N_tx,M_rx,N_rx,nPRB,fc,fsample,dist,n,BSpos,userPos,ThreeGPPModel,channelModel);

cluster_delay = channelBuilder.delay;
Hfreq = H(:,:,:,1);
impulse_response = h;

pathChannel = './models/channel.mat';
pathConfig = './models/config.mat';

save ('-v7', pathChannel ,'impulse_response', 'Hfreq' ,'cluster_delay')
save ('-v7', pathConfig ,'fc', 'M_rx','N_rx','M_tx','N_tx','userPos','numSamples')

