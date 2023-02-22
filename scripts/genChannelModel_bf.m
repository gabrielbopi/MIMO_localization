clear all;
if (!strcmp(strsplit(pwd,'\')(end),'scripts'))
  cd ./scripts
endif
addpath ("../QuaDriGa/quadriga_src/")
##mkdir ("./models/");
clc ;

pathChannel = '../models/channel.mat';
pathConfig = '../models/config.mat';
pathParamet = '../models/parameters.mat';
paramet = load('-v7',pathParamet);

M_tx = paramet.array.Mtx; N_tx = paramet.array.Ntx;
M_rx = paramet.array.Mrx; N_rx = paramet.array.Nrx;
n_tx = M_tx*N_tx;
n_rx = M_rx*N_rx;
array_d = paramet.array.d;

##nPRB = 20;
fc =  paramet.fc;  % Frequencia central
nSubcarrier = double(paramet.nSubcarr);
subcarrierSpacing = paramet.freqSubcarr;
Bandwidth = nSubcarrier*subcarrierSpacing;

userPos = transpose(paramet.UE);
BSpos = transpose(paramet.BS);
ThreeGPPModel = 0;
channelModel = 'mmMAGIC_Indoor_LOS';
##channelModel = '3GPP_38.901_InF_LOS';
SD = 1.5;
fsample = 2*fc*SD/3e8;
% #fsample = 2
##dist = 0.1;
##numSamples = fsample*dist;

s = qd_simulation_parameters;
s.center_frequency = [fc];                   % Set the three carrier frequencies
s.use_3GPP_baseline = ThreeGPPModel;         % 0 ou 1
s.show_progress_bars = 0;
s.samples_per_meter = fsample;

layout = qd_layout( s );                                     % New QuaDRiGa layout
layout.set_scenario(channelModel);
layout.simpar.use_absolute_delays = 1;

##layout.no_tx = length(BSpos(1,:));
##layout.no_rx = length(userPos(1,:));
##layout.tx_position = BSpos;
##layout.rx_position = userPos;
layout.no_rx = length(BSpos(1,:));
layout.no_tx = length(userPos(1,:));
layout.tx_position = userPos;
layout.rx_position = BSpos;                                                       % Number of Horizontal elements
layout.tx_array(1,:) = qd_arrayant('3gpp-3d', M_tx, N_tx, fc,1);     % Set BS height for all scenarios
layout.rx_array(1,:) = qd_arrayant('3gpp-3d', M_rx, N_rx, fc,1);
for i = 1:layout.no_rx
 layout.rx_array(1,i).element_position(1,:) = single(0:(n_rx-1))*array_d;
endfor
if (layout.rx_array(1,1).no_elements!=1)
  ##calc_element_position(layout.rx_array(1,1));
  d_array = layout.rx_array(1,1).element_position(1,2);
else
  d_array=0;
endif

##layout.rx_array(1,1).rotate_pattern(315,'z')
##layout.rx_array(1,2).rotate_pattern(270,'z')


b = layout.init_builder;
cluster_delay = cell(layout.no_tx,1);                                    % Create new builder object
H = cell(layout.no_tx,1);
Hfreq = cell(layout.no_tx,1);
for i = 1:layout.no_tx
    b(i).gen_parameters;                                      % Generate small-scale-fading parameters                                       % Disable path loss model
    c = get_channels(b(i));
    c = merge( c, [], 0 );
    h = [];
    delay_j = [];
    for j=1:length(c(:))
      c(j).individual_delays = 0;                    % Remove per-antenna delays
      h = cat(4, h, c(j).fr(Bandwidth,nSubcarrier));#,1));
      delay_j = [delay_j, min(c(j).delay)];
    endfor
    Hfreq{i} = h;
    cluster_delay{i} = delay_j;
end


save ('-v7', pathChannel ,'Hfreq' ,'cluster_delay')
Tx = M_tx*N_tx; Rx = M_rx*N_rx;
save ('-v7', pathConfig ,'fc','nSubcarrier','subcarrierSpacing', 'Tx','Rx','BSpos','userPos','d_array')

##% PRINT
##set(0,'defaultTextFontSize', 18)                      	% Default Font Size
##set(0,'defaultAxesFontSize', 18)                     	% Default Font Size
##set(0,'defaultAxesFontName','Times')               	    % Default Font Type
##set(0,'defaultTextFontName','Times')                 	% Default Font Type
####set(0,'defauHltFigurePaperPositionMode','auto')       	% Default Plot position
####set(0,'DefaultFigurePaperType','<custom>')             	% Default Paper Type
##set(0,'DefaultFigurePaperSize',[14.5 7.8])            	% Default Paper Size
##
##[ map,x_coords,y_coords] = layout.power_map( 'mmMAGIC_Indoor_LOS','quick',5,-500,500,-500,500,1.5 );
##P = 10*log10( sum(cat(3,map{:}),3));                    % Total received power
##
##layout.visualize([],[],0);                                   % Show BS and MT positions on the map
##hold on
##imagesc( x_coords, y_coords, P );                       % Plot the received power
##hold off
##axis([-20 50 -50 70])                               % Plot size
##caxis( max(P(:)) + [-20 0] )                            % Color range
##colmap = colormap;
##colormap( colmap*0.5 + 0.5 );                           % Adjust colors to be "lighter"
##set(gca,'layer','top')                                  % Show grid on top of the map
##title('Correct antenna orientation');
####% PRINT
clc
disp('Done')
fc
nSubcarrier
subcarrierSpacing
