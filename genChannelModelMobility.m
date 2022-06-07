function [H,h,layout,c] = genChannelModelMobility(M_tx,N_tx,M_rx,N_rx,nPRB,fc,fsample,dist,n,BSpos,userPos,ThreeGPPModel,channelModel)


%   Obe BS with M_tx x N_tx antenna array
%   L users with M_rx x N_rx antenna array

s = qd_simulation_parameters;
s.center_frequency = [fc];                   % Set the three carrier frequencies
s.use_3GPP_baseline = ThreeGPPModel;         % 0 ou 1
s.show_progress_bars = 0;
s.samples_per_meter = fsample;


nSubcarrier=nPRB*12;
subcarrierSpacing = 15e3*2^n;
Bandwidth = nSubcarrier*subcarrierSpacing;



layout = qd_layout( s );                                     % New QuaDRiGa layout
#layout.set_scenario(channelModel);

layout.simpar.use_absolute_delays = 1;

layout.no_tx = 1;
layout.no_rx = 1;                                       % One BS for each scenario
layout.tx_position = BSpos;

                                                        % Number of Horizontal elements
layout.tx_array(1,1) = qd_arrayant('3gpp-3d', M_tx, N_tx, fc,1);     % Set BS height for all scenarios
layout.rx_array(1,1) = qd_arrayant('3gpp-3d', M_rx, N_rx, fc,1);

layout.rx_track = qd_track('linear',dist,pi/2);        % go 50 meters to north
layout.rx_track.initial_position = userPos;          % Set start positions and MT height

interpolate(layout.rx_track,'distance',1/s.samples_per_meter,[],[],1);

layout.rx_track.scenario = channelModel;

c = layout.get_channels;                        % Generate the channel coefficients
c = merge( c, [], 0 );                          % Combine output channels
c.individual_delays = 0;                        % Remove per-antenna delays


# Create channel Matrix H
H = c.fr(Bandwidth,nSubcarrier);
h = c.coeff ;

