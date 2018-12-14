% m3ha_xolotl_test
%% Tests xolotl
%
% Requires:
%       cd/m3ha_xolotl_create_neuron.m
%       cd/xolotl_add_current_pulse.m
%       cd/xolotl_add_holding_current.m
%       cd/xolotl_add_voltage_clamp.m
%       cd/xolotl_set_simparams.m
%       cd/xolotl_simulate_voltage_clamp.m
%       cd/m3ha_xolotl_plot.m

% File History:
% 2018-12-12 Created by Adam Lu
% 2018-12-13 Added voltage clamp

% Hard-coded parameters
neuronParamsFile = fullfile('/media/adamX/m3ha/optimizer4gabab', ...
                            'initial_params/initial_params_D091710.csv');
closedLoop = false;     % whether to use the final state as the initial
                        %   condition for the next simulation
solverOrder = 0;        % uses the implicit Crank-Nicholson scheme
                        %   for multi-compartment models
temperature = 33;       % temperature of 33 degrees Celsius used by Christine
timeStep = 0.1;         % output time step in ms
simTimeStep = 0.1;      % simulation time step in ms

initialVoltageVc = -70; % initial voltage level for voltage clamp
timeEndVc = 1000;       % simulation end time in ms for voltage clamp

initialVoltageCpr = -60;% initial voltage level for current pulse response
timeEndCpr = 1350;      % simulation end time in ms for current pulse response
compToPatch = 'soma';   % compartment to be patched
holdingPotential = -65; % holding potential in mV
cpDelay = 1100;         % current pulse delay in ms
cpDuration = 10;        % current pulse duration in ms
cpAmplitude = -0.050;   % current pulse amplitude in nA

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Create a xolotl object based on a parameters file
m3ha = m3ha_xolotl_create_neuron(neuronParamsFile);

%% Set general simulation parameters
m3ha = xolotl_set_simparams(m3ha, 'ClosedLoop', closedLoop, ...
                    'SolverOrder', solverOrder, 'Temperature', temperature, ...
                    'TimeStep', timeStep, 'SimTimeStep', simTimeStep);

%% Find the holding current necessary to match the holding potential
holdingCurrent = xolotl_find_holding_current(m3ha, holdingPotential);

function holdingCurrent = xolotl_find_holding_current(m3ha, holdingPotential);
%% Finds the holding current necessary to match a certain holding potential


% Set simulation parameters for voltage clamp
m3ha = xolotl_set_simparams(m3ha, 'InitialVoltage', initialVoltageVc, ...
                            'TimeEnd', timeEndVc);

% Add a voltage clamp
m3haTest = xolotl_add_voltage_clamp(m3ha, 'Compartment', compToPatch, ...
                                    'Amplitude', holdingPotential);

% Simulate the voltage clamp experiment
% TODO: holdingCurrents = xolotl_simulate(m3haTest, 'OutputType', 0);

% Find the index for the compartment to patch
idxCompToPatch = xolotl_compartment_index(m3ha, compToPatch);

% Find the holding current necessary to match the holding potential
holdingCurrent = holdingCurrents(end, idxCompToPatch);

%% Simulate the current pulse protocol
% Set simulation parameters for current pulse response
m3ha = xolotl_set_simparams(m3ha, 'InitialVoltage', initialVoltageCpr, ...
                            'TimeEnd', timeEndCpr);

% Add a holding current
m3ha = xolotl_add_holding_current(m3ha, 'Compartment', compToPatch, ...
                                    'Amplitude', holdingCurrent);

% Add a current pulse protocol
m3ha = xolotl_add_current_pulse(m3ha, 'Compartment', compToPatch, ...
                                'Delay', cpDelay, 'Duration', cpDuration, ...
                                'Amplitude', cpAmplitude);

% Simulate and plot
% m3ha.plot;

% Simulate only
% vVecs = m3ha.integrate;

% Plot
% m3ha = m3ha_xolotl_plot(m3ha, vVecs);

% Save the xolotl object
% xolotl_save(m3ha, fileName);

% Displays a list of properties
% properties(xolotl)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
OLD CODE:

%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%