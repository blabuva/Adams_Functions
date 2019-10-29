%%function m3ha_network_launch(nCells, useHH, templateIDs)
%% Launches NEURON with simulation commands and plot output figures
%
% Requires:
%       cd/check_dir.m
%       cd/construct_fullpath.m
%       cd/create_looped_params.m
%       cd/create_time_stamp.m
%       cd/find_in_strings.m
%       cd/m3ha_locate_homedir.m
%       cd/m3ha_network_change_params.m
%       cd/m3ha_network_show_net.m
%       cd/m3ha_network_raster_plot.m
%       cd/m3ha_network_single_neuron.m
%       cd/m3ha_network_define_actmode.m
%       /media/adamX/m3ha/network_model/m3ha_run5.hoc
%       /media/adamX/m3ha/network_model/m3ha_net1.hoc
%       /media/adamX/m3ha/network_model/RE.tem
%       /media/adamX/m3ha/network_model/TC3.tem
%       /media/adamX/m3ha/network_model/ipulse2.mod
%       /media/adamX/m3ha/network_model/gabaA_Cl.mod
%       /media/adamX/m3ha/network_model/gabaa.mod (potentially)
%       /media/adamX/m3ha/network_model/m3ha_run5_small.hoc
%       /media/adamX/m3ha/network_model/m3ha_net1.hoc
%       /media/adamX/m3ha/network_model/m3ha_run12_tiny.hoc
%       /media/adamX/m3ha/network_model/m3ha_net1.hoc

% File History:
% 2017-10-23 Modified from /RTCl/neuronlaunch112.m
% 2017-10-30 Added pCond, gIncr, etc.
% 2017-10-31 Removed REuseca and added useHH
% 2017-11-03 Added bicucullineFlag & heteroTCFlag
% 2017-11-04 gIncr now scales TCgabaa as well
% 2017-11-06 Moved code to define_actmode.m
% 2017-11-07 Added templateIDs
% 2017-11-07 Added actMode = 8~10
% 2017-11-08 Added templateLabel to outFolderName
% 2017-11-08 Added repNum
% 2018-02-28 Don't use HH
% 2018-03-29 Fixed ordering of useHH and REnsegs
% 2018-04-17 Plot inSlopeWatching if useHH is 0
% 2018-04-24 Moved pfiles sources from ../optimizer4gabab/pfiles 
%               to just pfiles
% 2018-04-26 Added the case for nCells == 2
% 2018-04-26 Made templateIDs an argument
% 2018-04-26 Made nCells and useHH arguments
% TODO: Plot gAMPA and gGABA instead of the i's for synaptic event monitoring
% TODO: Make the network circular to lose edge effects
% TODO: Perform simulations to generate a linear model
% TODO: Update specs for m3ha_network_raster_plot.m
%

%% Experiment Name
experimentname = 'm3ha';
nCells = 1;
% nCells = 100;
useHH = true;
% templateIDs = [25, 36, 27];
templateIDs = 25;
% experimentSuffix = 'stimstart_3000';
experimentSuffix = ['ncells_', num2str(nCells), '_useHH_', num2str(useHH), ...
            '_templateIDs_', strjoin(strsplit(num2str(templateIDs)), ',')];

%% Hard-coded parameters
homeDirName = 'network_model';
paramsDirName = fullfile('best_params', ...
                'bestparams_20180424_singleneuronfitting21_Rivanna');

%% Flags
debugFlag = 0;                  % whether to do a very short simulation
repNum = 1;                     % number to seed random number generator
singleTrialNumber = 0;     %5;     % run only one trial with this trial number
onLargeMemFlag = 0;     %1;     % whether to run on large memory nodes
bicucullineFlag = 1;    %0;     % whether GABA-A conductances are removed
loopmode = 'cross'; %grid;      % how to loop through parameters: 
                                %   'cross' - Loop through each parameter 
                                %               while fixing others
                                %   'grid'  - Loop through all possible 
                                %               combinations of parameters

% Decide on what to save and plot
savePlotMode = 'spikes';
% if nCells == 1 || nCells == 2
%     savePlotMode = 'spikes&special';
% elseif nCells == 20 || nCells == 100
%     savePlotMode = 'spikes';    
% else
%     error('nCells = %d is not implemented yet!', nCells);
% end

%% Simulation modes
simmode = 2;    % 1 - full simulation
                % 2 - short simulation
                % 3 - medium simulation

%% Activation modes
% 1 - Activate a single RE cell by injecting a train of current pulses
% 2 - Activate every (RERErad + 1)th RE cell by injecting trains of 
%       current pulses
% 3 - Activate 3 RE cells (RERErad + 1) cells apart by injecting 
%       trains of current pulses
% 4 - Activate a single RE cell by changing the membrane potential 
%       instantaneously
% 5 - Activate RE cells with a Gaussian likelihood by changing 
%       the membrane potential instantaneously
% 6 - Activate every 3rd RE cell by injecting trains of current pulses
% 7 - Activate all RE cells by injecting trains of current pulses
% 8 - Activate 3 RE cells RETCrad cells apart by injecting trains of 
%       current pulses
% 9 - Activate 10 center RE cells by injecting current pulses
% 10 - Activate 20 center RE cells by injecting current pulses

% actMode = 10;   
actMode = 1;   

% Decide on template TC neurons to use
%% Template TC neurons;
templateNames = {'D091710', 'E091710', 'B091810', 'D091810', ...
                'E091810', 'F091810', 'A092110', 'C092110', ...
                'B092710', 'C092710', 'E092710', 'A092810', ...
                'C092810', 'K092810', 'A092910', 'C092910', ...
                'D092910', 'E092910', 'B100110', 'E100110', ...
                'A100810', 'B100810', 'D100810', 'A101210', ...
                'C101210', 'D101210', 'E101210', 'F101210', ...
                'I101210', 'M101210', 'B101310', 'D101310', ...
                'E101310', 'F101310', 'G101310', 'H101310'};
%templateIDs = 21;
%templateIDs = 3;
%templateIDs = 20;
%templateIDs = 21;
%templateIDs = 22;
%templateIDs = 26;
%templateIDs = 27;
%templateIDs = 33;
%templateIDs = 25;
%templateIDs = [22, 27];
%templateIDs = [22, 33];
%templateIDs = [20, 22, 33];
%templateIDs = [20, 22, 27, 33];
%templateIDs = [3, 20, 22, 26, 27, 33];
%templateIDs = [3, 20, 22, 25, 26, 27, 33];
%templateIDs = [3, 20, 21, 22, 25, 26, 27, 33];
%templateIDs = 1:36;
%templateIDs = [22, 27, 33];      % 'B100810', 'E101210', 'E101310'

% In ascending order of total error in singleneuronfitting16_Rivanna:
%templateIDs = 25;                 % 'C101210'
%templateIDs = 36;                 % 'H101310'
%templateIDs = 27;                 % 'E101210'
%templateIDs = [25, 36, 27];       % 'C101210', 'H101310', 'E101210'

%templateIDs = 20;                 % 'E100110'
%templateIDs = 22;                 % 'B100810'
%templateIDs = 30;                 % 'M101210'
%templateIDs = 34;                 % 'F101310'
%templateIDs = 10;                 % 'C092710'
%templateIDs = 21;                 % 'A100810'
%templateIDs = 3;                  % 'B091810'

%% For parpool
if onLargeMemFlag || debugFlag || singleTrialNumber ~= 0 || simmode == 2
    % No need renew parpool each batch if memory is not an issue
    renewParpoolFlagNeuron = 0;    % whether to renew parpool every batch to release memory
    maxNumWorkersNeuron = 20;      % maximum number of workers for running NEURON 
    renewParpoolFlagPlots = 0;     % whether to renew parpool every batch to release memory
    maxNumWorkersPlots = 20;       % maximum number of workers for plotting things
else
    switch savePlotMode
    case 'all'          % saving and plotting everything
        %% For parpool
        renewParpoolFlagNeuron = 1;% whether to renew parpool every batch to release memory
        maxNumWorkersNeuron = 12;  % maximum number of workers for running NEURON 
        renewParpoolFlagPlots = 1; % whether to renew parpool every batch to release memory
        maxNumWorkersPlots = 12;   % maximum number of workers for plotting things
    case 'curves'           % saving spikes and plotting curves/maps only
        renewParpoolFlagNeuron = 0;% whether to renew parpool every batch to release memory
        maxNumWorkersNeuron = 20;  % maximum number of workers for running NEURON 
        renewParpoolFlagPlots = 0; % whether to renew parpool every batch to release memory
        maxNumWorkersPlots = 20;   % maximum number of workers for plotting things
    case 'spikes'           % saving spikes and plotting raster plots and curves/maps only
        renewParpoolFlagNeuron = 0;% whether to renew parpool every batch to release memory
        maxNumWorkersNeuron = 20;  % maximum number of workers for running NEURON 
        renewParpoolFlagPlots = 0; % whether to renew parpool every batch to release memory
        maxNumWorkersPlots = 20;   % maximum number of workers for plotting things
    case 'spikes&special'   % saving spikes and special neuron traces only
        renewParpoolFlagNeuron = 0;% whether to renew parpool every batch to release memory
        maxNumWorkersNeuron = 12;  % maximum number of workers for running NEURON 
        renewParpoolFlagPlots = 1; % whether to renew parpool every batch to release memory
        maxNumWorkersPlots = 12;   % maximum number of workers for plotting things
    end
end

switch savePlotMode
case 'all'
    %% Save flags
    saveNetwork = 1;        % whether to save network topology
    saveSpikes = 1;         % whether to save spike data
    saveSomaVoltage = 1;    % whether to save all voltage data
    saveSomaCli = 1;        % whether to save all chloride concentration data
    saveSpecial = 1;        % whether to save special neuron data

    %% Plot flags
    plotNetwork = 1;        % whether to plot network topology
    plotSpikes = 1;         % whether to plot spike data
    plotTuning = 1;         % whether to plot tuning curves
    plotSingleNeuronData = 1;% whether to plot single neuron data
case 'curves'
    %% Save flags
    saveNetwork = 0;        % whether to save network topology
    saveSpikes = 1;         % whether to save spike data
    saveSomaVoltage = 0;    % whether to save all voltage data
    saveSomaCli = 0;        % whether to save all chloride concentration data
    saveSpecial = 0;        % whether to save special neuron data

    %% Plot flags
    plotNetwork = 0;        % whether to plot network topology
    plotSpikes = 0;         % whether to plot spike data
    plotTuning = 1;         % whether to plot tuning curves
    plotSingleNeuronData = 0;% whether to plot single neuron data
case 'spikes'
    %% Save flags
    saveNetwork = 0;        % whether to save network topology
    saveSpikes = 1;         % whether to save spike data
    saveSomaVoltage = 0;    % whether to save all voltage data
    saveSomaCli = 0;        % whether to save all chloride concentration data
    saveSpecial = 0;        % whether to save special neuron data

    %% Plot flags
    plotNetwork = 0;        % whether to plot network topology
    plotSpikes = 1;         % whether to plot spike data
    plotTuning = 1;         % whether to plot tuning curves
    plotSingleNeuronData = 0;% whether to plot single neuron data
case 'spikes&special'
    %% Save flags
    saveNetwork = 0;        % whether to save network topology
    saveSpikes = 1;         % whether to save spike data
    saveSomaVoltage = 0;    % whether to save all voltage data
    saveSomaCli = 0;        % whether to save all chloride concentration data
    saveSpecial = 1;        % whether to save special neuron data

    %% Plot flags
    plotNetwork = 0;        % whether to plot network topology
    plotSpikes = 1;         % whether to plot spike data
    plotTuning = 1;         % whether to plot tuning curves
    plotSingleNeuronData = 1;% whether to plot single neuron data
end

% Code not fixed yet
plotTuning = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Parameters to loop through
%{
pnames  = {'REdiam'};       % names of parameters to loop through
plabels = {'REdiam (um)'};  % labels of parameters to loop through
pmin    = [2];              % minimum values of parameters to loop through
pmax    = [20];             % maximum values of parameters to loop through
pinc    = [2];              % increments of parameters to loop through
pislog  = [0];              % whether increments of parameters is in log
%}
%{
pnames  = {'REgabaGmax'};      % names of parameters to loop through
plabels = {'REgabaGmax (uS)'}; % labels of parameters to loop through
pmin    = [0.0025];         % minimum values of parameters to loop through
pmax    = [0.045];          % maximum values of parameters to loop through
pinc    = [0.0025];         % increments of parameters to loop through
pislog  = [0];              % whether increments of parameters is in log
%}
%{
pnames  = {'stimFreq'};    % names of parameters to loop through
plabels = {'Stimulation Frequency (Hz)'};% labels of parameters to loop through
pmin    = [1];              % minimum values of parameters to loop through
pmax    = [128];            % maximum values of parameters to loop through
pinc    = [2^(1/2)];        % increments of parameters to loop through
pislog  = [1];              % whether increments of parameters is in log
%}
%{
pnames  = {'REtauKCC2'};    % names of parameters to loop through
plabels = {'Time constant of KCC2 (s)'};    % labels of parameters to loop through
pmin    = [4];              % minimum values of parameters to loop through
pmax    = [64];             % maximum values of parameters to loop through
pinc    = [2^(1/4)];        % increments of parameters to loop through
pislog  = [1];              % whether increments of parameters is in log
%}
%{
pnames  = {'REdiam', 'REgabaGmax', 'stimFreq', 'REtauKCC2'};    % names of parameters to loop through
plabels = {'REdiam (um)', 'REgabaGmax (uS)', 'Stimulation Frequency (Hz)', 'Time constant of KCC2 (s)'};    % labels of parameters to loop through
pmin    = [4, 0.0025, 0.125, 0.25]; % minimum values of parameters to loop through
pmax    = [15, 0.045, 256, 64];     % maximum values of parameters to loop through
pinc    = [1, 0.0025, 2, sqrt(2)];  % increments of parameters to loop through
pislog  = [0, 0, 1, 1];             % whether increments of parameters is in log
%}
%{
pnames  = {'stimFreq', 'REtauKCC2'};   % names of parameters to loop through
plabels = {'Stimulation Frequency (Hz)', 'Time constant of KCC2 (s)'};    % labels of parameters to loop through
pmin    = [16, 32*2^(1/4)];         % minimum values of parameters to loop through
pmax    = [19, 64];                 % maximum values of parameters to loop through
pinc    = [0.1, 2^(1/64)];          % increments of parameters to loop through
pislog  = [0, 1];                   % whether increments of parameters is in log
%}
%{
pnames  = {'REdiam', 'REgabaGmax'};    % names of parameters to loop through
plabels = {'REdiam (um)', 'REgabaGmax (uS)'};    % labels of parameters to loop through
pmin    = [8, 0.1];                 % minimum values of parameters to loop through
pmax    = [12, 0.5];                % maximum values of parameters to loop through
pinc    = [0.5, 0.05];              % increments of parameters to loop through
pislog  = [0, 0];                   % whether increments of parameters is in log
%}

pnames  = {'pCond', 'gIncr'};       % names of parameters to loop through
plabels = {'Pharm Condition', 'gGABAB amp scaling (%)'};  % labels of parameters to loop through
pmin    = [1, 7.5];                 % minimum values of parameters to loop through
pmax    = [4, 22.5];                % maximum values of parameters to loop through
pinc    = [1, 7.5];                 % increments of parameters to loop through
pislog  = [0, 0];                   % whether increments of parameters is in log

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Global parameters to be defined at the start of NEURON
%   Will call either m3ha_run5.hoc or m3ha_run5_small.hoc or m3ha_run12_small.hoc
% nCells = 2; %100; %20;

%% Global parameters to be defined at the start of NEURON, to be consistent with m3ha_run5.hoc
celsius = 33;   % SET IN m3ha_run5.hoc: temperature of experiment (celsius) % TODO: What did Mark use?
nSpecial = 2;        % SET IN m3ha_run5.hoc: number of special RE or TC neurons
if nCells == 100 || nCells == 20
    RERErad = 8;    % SET IN m3ha_run5.hoc: radius of intra-RE connections
                    %   Sohal & Huguenard 2004 used 8
                    %   RTCl & Sohal & Huguenard 2003 used 4
elseif nCells == 2
    RERErad = 2;
elseif nCells == 1
    RERErad = 1;
else
    error('nCells unrecognized!');
end

%% Parameters for various GABA-B conductance profiles
pCond = 1;      % Pharmacological condition
                %   1 - Control; 2 - GAT 1 Block; 3 - GAT 3 Block; 4 - Dual Block
gIncr = 100;    % GABA-B conductance amplitude scaling (%)

%% Network parameters
if nCells == 100 || nCells == 20
    TCRErad = 4; %1; %2;    % radius of TC-RE connections
                    %   Sohal & Huguenard 2004 used 2
    RETCrad = 8; %4; % radius of RE-TC connections
                    %   Sohal & Huguenard 2004 used 4
elseif nCells == 2
    TCRErad = 2;
    RETCrad = 2;
elseif nCells == 1
    TCRErad = 1;
    RETCrad = 1;
else
    error('nCells unrecognized!');
end
spThr = 0;     % action potential threshold (mV)
synDel = 1;    % synaptic delay (ms)
synWeight = 1;      % synaptic weight (fraction of channels activated)
                %     for simplicity assume channels are always activated and that 
                %     channels have linearly additive effects

% useHH = 0;      % whether to use HH channels

%% RE neuron parameters
REnsegs = 1;    % number of segments in an RE cell (1, 3 or 9)
                %     if REnsegs >= 3, the GABAA synapses will be distributed on each side
REcldnum = 2;   % which cld mechanism to use (0 or 1 or 2) in RE cells
REconsyn = 0;   % whether to concentrate synapses (0 or 1) in RE cells
                %     for REnsegs = 1 or 3, we have soma, soma_flank[0], soma_flank[1]
REtauKCC2 = 32; % Cl- removal time constant (s) in RE cells
REepas = -70;   % leak reversal potential (mV) of RE cells, Peter's value
                %    Sohal & Huguenard 2003 & 2004 used -77 mV
                %    Jedlicka et al 2011 used -60 mV
REdiam = 10;    % diameter (um) of an RE cell, Peter's value
REgpasLB = 4.5e-5;  % lower bound for passive leak conductance (S/cm^2) in RE cells, Sohal & Huguenard 2003
REgpasUB = 5.5e-5;  % upper bound for passive leak conductance (S/cm^2) in RE cells, Sohal & Huguenard 2003
                %     Jedlicka et al 2011 used 2e-4 S/cm^2 %%% What should we use?

%% Synapse parameters
if bicucullineFlag
    REgabaGmax = 0;
else
    REgabaGmax = 0.005; %0;     % maximal conductance (uS) of the GABA-A receptor on RE cells
                            %   Sohal & Huguenard 2003 varied between 5~12.5 nS
                            %   RTCl used 0.02 nS
end
%REampaGmax = 0.007 * (2*TCRErad + 1);
REampaGmax = 0.007;
                            % maximal conductance (uS) of the AMPA receptor on RE cells
                            %   Deleuze & Huguenard 2016 has about 7 nS per synapse 
                            %       (a minimal stimulation protocol was used)
                            %   Sohal & Huguenard 2004 used 0.05 uS
TCgabaaErev = -80;          % reversal potential (mV) of the GABA-A receptor on TC cells
                            %   Sohal & Huguenard 2004 used -85 mV; Traub 2005 used -81 mV
                            %   Peter's measurement gave -80 mV                           
if bicucullineFlag
    TCgabaaGmax = 0;
else
    TCgabaaGmax = 0.00896;  % maximal conductance (uS) of the GABA-A receptor on TC cells 
                            %   Sohal & Huguenard 2004 used 0.1 uS
                            %   The maximal GABA-B conductance is 0.00448 uS
                            %   Based on Huguenard & Prince, 1994, 
                            %       the maximal GABA-A conductance is about 5 times that of GABA-B away from Erev
                            %       and about 2 time that of GABA-B close to Erev
                            %   This must be consistent with /home/Matlab/Adams_Functions/m3ha_network_update_params.m
end
TCgababErev = -100; %-105; %-115        % reversal potential (mV) of the GABA-B receptor on TC cells
                            %   Christine used -115 mV in dynamic clamp experiments
                            %   Huguenard & Prince 1994 has -105 mV
                            %   ek is -100 mV
TCgababAmp = 0.016;         % conductance amplitude (uS) of the GABA-B receptor on TC cells
TCgababTrise = 52;          % rising phase time constant (ms) of the GABA-B receptor on TC cells
TCgababTfallFast = 90.1;    % fast decay time constant (ms) of the GABA-B receptor on TC cells
TCgababTfallSlow = 1073.2;  % slow decay time constant (ms) of the GABA-B receptor on TC cells
TCgababW = 0.952;           % weight (1) of the fast decay of the GABA-B receptor on TC cells

%% Initial ion concentrations
cai0 = 2.4e-4;  % initial intracellular [Ca++] (mM), Destexhe et al
cao0 = 2;       % initial extracellular [Ca++] (mM), Peter's value
% cli0 = 5;     % initial intracellular [Cl-] (mM), 
                %   corresponding to eGABA = -71 mV
                %            TODO: Ulrich
cli0 = 8;       % initial intracellular [Cl-] (mM),
                %   corresponding to eGABA = -61 mV
                %            Jedlicka et al 2011 (agrees with Peter's data)
% cli0 = 11;    % initial intracellular [Cl-] (mM),
                %   corresponding to eGABA = -54 mV
                %            TODO: Peter's data with ChABC added
% cli0 = 17;    % initial intracellular [Cl-] (mM),
                %   corresponding to eGABA = -45 mV
                %            TODO: Sun
clo0 = 130.5;   % initial extracellular [Cl-] (mM), Peter's value (Jedlicka et al 2011 used 133.5 mM)

%% Activation parameters for actMode == 1~3, 6~9
actCellID = floor(nCells/2);    % ID # of central neuron to activate
stimStart = 3000; %300;        % stimulation delay (ms)
stimDur = 40;                  % stimulation duration (ms)
stimFreq = 0.1;                % stimulation frequency (Hz),
                                %   must be less than 1000/cpDur
cpDur = 40;                    % current pulse duration (ms)

% The following must be consistent with m3ha_network_update_params.m
cpAmp = 0.2*(REdiam/10)^2;     % current pulse amplitude (nA),
                                %   must be proportional to square of diameter 
cpPer = floor(1000/stimFreq); % current pulse period (ms),
                                %   i.e. interval between pulse onsets
cpNum = ceil(stimDur/cpPer); % number of current pulses

%% Activation parameters for actMode == 4
actCellV = 0;                   % voltage (mV) to set activated neuron to

%% Activation parameters for actMode == 5
actWidth = 50;                  % width of Gaussian distribution for
                                %   randomly activating cells
actMaxP = 0.5;                  % maximum likelihood of activation at center

%% Simulation parameters
if simmode == 1
    tStop = 30000;              % total time of simulation (ms)
elseif simmode == 2
    tStop = 4000; %1000;        % total time of simulation (ms)
elseif simmode == 3
    tStop = 7000; %4000;        % total time of simulation (ms)
end
dt = 0.1;                       % time step of integration (ms)

%% Recording parameters
if simmode == 1
    tStart = 0;                 % time to start plotting (ms)
elseif simmode == 2
    tStart = 0;                 % time to start plotting (ms)
elseif simmode == 3
    tStart = 0;                 % time to start plotting (ms)
end
REsp1cellID = actCellID;        % ID # of 1st special RE neuron to record
if nCells > 1
    REsp2cellID = actCellID - 1;    % ID # of 2nd special RE neuron to record
else
    REsp2cellID = actCellID;    % ID # of 2nd special RE neuron to record
end
TCsp1cellID = actCellID;        % ID # of 1st special TC neuron to record
if nCells > 1
    TCsp2cellID = actCellID - 1;    % ID # of 2nd special TC neuron to record
else
    TCsp2cellID = actCellID;    % ID # of 2nd special TC neuron to record
end

%% Set ID #s of neurons to plot
act = actCellID;            % ID # of the activated neuron
if nCells == 100
    actLeft1 = actCellID - 1;  % ID # of the neuron one below the activated neuron
    actLeft2 = actCellID - 10; % ID # of the neuron 10 below the activated neuron
    far = actCellID - 20;       % ID # of a far away neuron
elseif nCells == 20
    actLeft1 = actCellID - 1;  % ID # of the neuron one below the activated neuron
    actLeft2 = actCellID - 2;  % ID # of the neuron 2 below the activated neuron
    far = actCellID - 10;       % ID # of a far away neuron
elseif nCells == 2
    actLeft1 = actCellID - 1;  % ID # of the neuron one below the activated neuron
    actLeft2 = actCellID;      % Repeat for compatibility
    far = actCellID - 1;        % Repeat for compatibility
elseif nCells == 1
    actLeft1 = actCellID;       % Repeat for compatibility
    actLeft2 = actCellID;       % Repeat for compatibility
    far = actCellID;            % Repeat for compatibility
else
    error('nCells unrecognized!');
end

%% Arguments for plotting (not logged in sim_params)
propertiesToPlot = 1:8;         % property #s of special neuron to record to be plotted (maximum range: 1~8, must be consistent with net.hoc)
%[1, 5, 6, 8]; 
cellsToPlot = [act, actLeft1, actLeft2, far]; % ID #s for neurons whose voltage is to be plotted

%% Set output file names; must have only one '.' (not logged in sim_params)
simparamsF = 'sim_params.csv';  % file with simulation parameters
scmdsF = 'sim_commands.txt';    % file with simulation commands
soutF = 'sim_output.txt';       % file with simulation standard outputs
sREREsynF = 'RERE.syn';         % file with RE-RE synaptic connections
sTCREsynF = 'TCRE.syn';         % file with TC-RE synaptic connections
sRETCsynF = 'RETC.syn';         % file with RE-TC synaptic connections
sREspikeF = 'RE.spi';           % file with RE spike train output
sTCspikeF = 'TC.spi';           % file with TC spike train output
sREvF = 'RE.singv';             % file with RE single neuron voltage traces
sTCvF = 'TC.singv';             % file with TC single neuron voltage traces
sREcliF = 'RE.singcli';         % file with RE single neuron chloride concentration traces
sREsp1F = ['RE[', num2str(REsp1cellID), '].singsp'];    % file with RE special neuron #1 other traces
sREsp2F = ['RE[', num2str(REsp2cellID), '].singsp'];    % file with RE special neuron #2 other traces
sTCsp1F = ['TC[', num2str(TCsp1cellID), '].singsp'];    % file with TC special neuron #1 other traces
sTCsp2F = ['TC[', num2str(TCsp2cellID), '].singsp'];    % file with TC special neuron #2 other traces
sREleakF = 'REleak.csv';        % file with RE neuron leak properties
sREparamsF = 'REparams.csv';    % file with RE neuron parameters
sTCparamsF = 'TCparams.csv';    % file with TC neuron parameters

%% For debug mode
if debugFlag
    tStart = 0;
    tStop = 2000;

    % Minimize number of points
    for p = 1:length(pnames)
        if pislog(p)
            pinc(p) = pmax(p)/pmin(p);
        else
            pinc(p) = pmax(p) - pmin(p);
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Preparation
% Count the number of template candidates
nCandidates = length(templateIDs);

% Set a flag for whether heterogeneity is introduced
if nCandidates > 1
    heteroTCFlag = 1;
else
    heteroTCFlag = 0;
end

%% Set folders for reading and saving files
% Find parent and home directory
parentDirectory = m3ha_locate_homedir;
homeDirectory = fullfile(parentDirectory, homeDirName);

% Test if there is a .mod file present in the home directory
[~, modPaths] = all_files('Directory', homeDirectory, 'Extension', 'mod');

% Change to the home directory and compile NEURON mod files
if isempty(modPaths)
    fprintf('There are no .mod files in %s!\n', homeDirectory);
    return
else
    cd(homeDirectory);
    unix('nrnivmodl');
end

% Make directory to save all data
%   Note: Use current date & time in the format: YYYYMMDDThhmm
timeStamp = create_time_stamp('FormatOut', 'yyyymmddTHHMM');
if nCandidates > 1
    templateLabel = ['hetero', num2str(nCandidates)];
else
    templateLabel = templateNames{templateIDs(1)};
end
outFolderName = [timeStamp, '_', templateLabel, '_', experimentSuffix];
outFolder = fullfile(homeDirectory, outFolderName);     
check_dir(outFolder);

%% Construct looped parameters
[pchnames, pchvalues, nTrials, nump, pvalues, nperp] = ...
    create_looped_params (loopmode, pnames, plabels, pislog, pmin, pmax, pinc, ...
            'OutFolder', outFolder, 'FileLabel', outFolderName, ...
            'NCells', nCells, 'ActMode', actMode);

%% Create a table for simulation parameters
paramLabels = {
    '# of cells', 'temperature of experiment (celsius)', ...
    'number of special neurons', 'radius of intra-RE connections', ...
    'radius of TC-RE synaptic connections', ...
    'radius of RE-TC synaptic connections', ...
    'pharm condition', 'GABA-B conductance amplitude scaling (%)' ...
    'action potential threshold (mV)', 'synaptic delay (ms)', ...
    'synaptic weight (fraction of channels activated)', ...
    'whether to use HH channels', ...
    'number of segments in an RE cell (must be odd)', ...
    'which cld mechanism to use (0 or 1 or 2) in RE cells', ...
    'whether to concentrate synapses (0 or 1) in RE cells', ...
    'Cl- removal time constant (ms) in RE cells', ...
    'leak reversal potential (mV) of RE cells', ...
    'diameter (um) of an RE cell', ...
    'lower bound for passive leak conductance (S/cm^2) in RE cells', ...
    'upper bound for passive leak conductance (S/cm^2) in RE cells', ...
    'maximal conductance (uS) of the GABA-A receptor on RE cells', ...
    'maximal conductance (uS) of the AMPA receptor on RE cells', ...
    'reversal potential (mV) of the GABA-A receptor on TC cells', ...
    'maximal conductance (uS) of the GABA-A receptor on TC cells', ...
    'reversal potential (mV) of the GABA-B receptor on TC cells', ...
    'conductance amplitude (uS) of the GABA-B receptor on TC cells', ...
    'rising phase time constant (ms) of the GABA-B receptor on TC cells', ...
    'fast decay time constant (ms) of the GABA-B receptor on TC cells', ...
    'slow decay time constant (ms) of the GABA-B receptor on TC cells', ...
    'weight (1) of the fast decay of the GABA-B receptor on TC cells', ...
    'initial intracellular [Ca++] (mM)', 'initial extracellular [Ca++] (mM)', ...
    'initial intracellular [Cl-] (mM)', 'initial extracellular [Cl-] (mM)', ...
    'activation mode', 'ID # of central neuron to activate', ...
    'stimulation delay (ms)', 'stimulation duration (ms)', 'stimulation frequency (Hz)', ...
    'current pulse duration (ms)', 'current pulse amplitude (nA)', ...
    'current pulse period (ms)', 'number of current pulses', ...
    'voltage (mV) to set activated neuron to', ...
    'width of Gaussian distribution for randomly activating cells', ...
    'maximum likelihood of activation at center', ...
    'simulation mode', 'total time of simulation (ms)', ...
    'time step of integration (ms)', 'time to start plotting (ms)', ...
    'ID # of 1st special RE neuron to record', 'ID # of 2nd special RE neuron to record', ...
    'ID # of 1st special TC neuron to record', 'ID # of 2nd special TC neuron to record', ...
    'ID # of the activated neuron', 'ID # of the neuron one below the activated neuron', ...
    'ID # of the neuron 2 below the activated neuron', 'ID # of a far away neuron', ...
    'whether in debug mode', ...
    'number to seed random number generator', ...
    'run only one trial with this trial number', ...
    'whether to run on large memory nodes', ...
    'whether TC neurons are heterogeneous', ...
    'whether GABA-A conductances are removed', ...
    'whether to save network topology', 'whether to save spike data', 'whether to save all voltage data', ...
    'whether to save all chloride concentration data', 'whether to save special neuron data', ...
    'whether to plot network topology', 'whether to plot spike data', 'whether to plot single neuron data', ...
    'number of times to run simulation', 'current trial number'};

% Note: Must be consistent with m3ha_network_update_params.m
paramNames = { ...
    'nCells', 'celsius', 'nSpecial', 'RERErad', ...
    'TCRErad', 'RETCrad', 'pCond', 'gIncr', ...
    'spThr', 'synDel', 'synWeight', 'useHH', ...
    'REnsegs', 'REcldnum', ...
    'REconsyn', 'REtauKCC2', ...
    'REepas', 'REdiam', 'REgpasLB', 'REgpasUB', ...
    'REgabaGmax', 'REampaGmax', 'TCgabaaErev', 'TCgabaaGmax', 'TCgababErev', ...
    'TCgababAmp', 'TCgababTrise', 'TCgababTfallFast', 'TCgababTfallSlow', 'TCgababW', ...
    'cai0', 'cao0', 'cli0', 'clo0', ...
    'actMode', 'actCellID', ...
    'stimStart', 'stimDur', 'stimFreq', ...
    'cpDur', 'cpAmp', 'cpPer', 'cpNum', ...
    'actCellV', 'actWidth', 'actMaxP', ...
    'simmode', 'tStop', ...
    'dt', 'tStart', ...
    'REsp1cellID', 'REsp2cellID', ...
    'TCsp1cellID', 'TCsp2cellID', ...
    'act', 'actLeft1', 'actLeft2', 'far', ...
    'debugFlag', 'repNum', 'singleTrialNumber', 'onLargeMemFlag', ...
    'heteroTCFlag', 'bicucullineFlag', ...
    'saveNetwork', 'saveSpikes', 'saveSomaVoltage', ...
    'saveSomaCli', 'saveSpecial', ...
    'plotNetwork', 'plotSpikes', 'plotSingleNeuronData', ...
    'nTrials', 'trialNumber'};

% Set initial values for all parameters
paramsInit = [ ...
    nCells, celsius, nSpecial, RERErad, ...
    TCRErad, RETCrad, pCond, gIncr, ...
    spThr, synDel, synWeight, useHH, ...
    REnsegs, REcldnum, ...
    REconsyn, REtauKCC2, ...
    REepas, REdiam, REgpasLB, REgpasUB, ...
    REgabaGmax, REampaGmax, TCgabaaErev, TCgabaaGmax, TCgababErev, ...
    TCgababAmp, TCgababTrise, TCgababTfallFast, TCgababTfallSlow, TCgababW, ...
    cai0, cao0, cli0, clo0, ...
    actMode, actCellID, ...
    stimStart, stimDur, stimFreq, ...
    cpDur, cpAmp, cpPer, cpNum, ...
    actCellV, actWidth, actMaxP, ...
    simmode, tStop, ...
    dt, tStart, ...
    REsp1cellID, REsp2cellID, TCsp1cellID, TCsp2cellID, ...
    act, actLeft1, actLeft2, far, ...
    debugFlag, repNum, singleTrialNumber, onLargeMemFlag, ...
    heteroTCFlag, bicucullineFlag, ...
    saveNetwork, saveSpikes, saveSomaVoltage, ...
    saveSomaCli, saveSpecial, ...
    plotNetwork, plotSpikes, plotSingleNeuronData, ...
    nTrials, singleTrialNumber];

if max([numel(paramLabels), numel(paramNames), length(paramsInit)]) ~= ...
    min([numel(paramLabels), numel(paramNames), length(paramsInit)])
    error('paramLabels, paramNames and paramsInit not equal length!');
end

% Create an initial parameters table
% TODO: Use this instead
paramTableInit = table(paramNames, paramsInit, paramLabels, ...
                        'RowNames', paramNames);

%% Setup parameters and filenames for each trial
paramValues = cell(1, nTrials);     % stores parameters used for each trial
simParamsPaths = cell(1, nTrials);
sREREsynPaths = cell(1, nTrials);
sTCREsynPaths = cell(1, nTrials);
sRETCsynPaths = cell(1, nTrials);
sREspikePaths = cell(1, nTrials);
sTCspikePaths = cell(1, nTrials);
sREvPaths = cell(1, nTrials);
sTCvPaths = cell(1, nTrials);
sREcliPaths = cell(1, nTrials);
sREsp1Paths = cell(1, nTrials);
sREsp2Paths = cell(1, nTrials);
sTCsp1Paths = cell(1, nTrials);
sTCsp2Paths = cell(1, nTrials);
sREleakPaths = cell(1, nTrials);
sREparamsPaths = cell(1, nTrials);
sTCparamsPaths = cell(1, nTrials);
for k = 1:nTrials
    % Update trial count
    idxTrialNumber = find_in_strings('trialNumber', paramNames);
    paramValues{k}(idxTrialNumber) = k;

    % Set parameters for this trial according to pchnames and pchvalues
    pchnamesThis = pchnames{k};
    if iscell(pchvalues)
        pchvaluesThis = pchvalues{k};
    elseif isnumeric(pchvalues)
        pchvaluesThis = pchvalues(k);
    end
    paramValues{k} = ...
        m3ha_network_change_params(pchnamesThis, pchvaluesThis, ...
                    paramNames, paramsInit, 'ExperimentName', experimentname);

    % Create name-value pairs
    nameValuePairsThis = {pchnamesThis, pchvaluesThis};

    % Print parameters to a comma-separated-value file
    simParamsPaths{k} = construct_fullpath(simparamsF, 'Directory', outFolder, ...
                        'NameValuePairs', nameValuePairsThis);
    fid = fopen(simParamsPaths{k}, 'w');
    for i = 1:length(paramValues{k})
        fprintf(fid, '%s, %g, %s\n', ...
            paramNames{i}, paramValues{k}(i), paramLabels{i});
    end
    fclose(fid);

    % Construct full file names
    sREREsynPaths{k}   = construct_fullpath(sREREsynF, 'Directory', outFolder, ...
                        'NameValuePairs', nameValuePairsThis);
    sTCREsynPaths{k}   = construct_fullpath(sTCREsynF, 'Directory', outFolder, ...
                        'NameValuePairs', nameValuePairsThis);
    sRETCsynPaths{k}   = construct_fullpath(sRETCsynF, 'Directory', outFolder, ...
                        'NameValuePairs', nameValuePairsThis);
    sREspikePaths{k}   = construct_fullpath(sREspikeF, 'Directory', outFolder, ...
                        'NameValuePairs', nameValuePairsThis);
    sTCspikePaths{k}   = construct_fullpath(sTCspikeF, 'Directory', outFolder, ...
                        'NameValuePairs', nameValuePairsThis);
    sREvPaths{k}       = construct_fullpath(sREvF, 'Directory', outFolder, ...
                        'NameValuePairs', nameValuePairsThis);
    sTCvPaths{k}       = construct_fullpath(sTCvF, 'Directory', outFolder, ...
                        'NameValuePairs', nameValuePairsThis);
    sREcliPaths{k}     = construct_fullpath(sREcliF, 'Directory', outFolder, ...
                        'NameValuePairs', nameValuePairsThis);
    sREsp1Paths{k}     = construct_fullpath(sREsp1F, 'Directory', outFolder, ...
                        'NameValuePairs', nameValuePairsThis);
    sREsp2Paths{k}     = construct_fullpath(sREsp2F, 'Directory', outFolder, ...
                        'NameValuePairs', nameValuePairsThis);
    sTCsp1Paths{k}     = construct_fullpath(sTCsp1F, 'Directory', outFolder, ...
                        'NameValuePairs', nameValuePairsThis);
    sTCsp2Paths{k}     = construct_fullpath(sTCsp2F, 'Directory', outFolder, ...
                        'NameValuePairs', nameValuePairsThis);
    sREleakPaths{k}     = construct_fullpath(sREleakF, 'Directory', outFolder, ...
                        'NameValuePairs', nameValuePairsThis);
    sREparamsPaths{k}     = construct_fullpath(sREparamsF, 'Directory', outFolder, ...
                        'NameValuePairs', nameValuePairsThis);
    sTCparamsPaths{k}     = construct_fullpath(sTCparamsF, 'Directory', outFolder, ...
                        'NameValuePairs', nameValuePairsThis);
end

% Find the IDs of cells that are stimulated or artificially activated
stimcellIDs = m3ha_network_define_actmode(actMode, actCellID, nCells, ...
                                            RERErad, RETCrad);

% Seed random number generator with repetition number
rng(repNum);

% Load parameters for TC neurons
templateIDsUsed = zeros(1, nCells);
templateNamesUsed = cell(1, nCells);
for iCell = 1:nCells
    % Index of TC neuron starts from 0
    TCcellID(iCell) = iCell - 1;

    % Select a .p file to import
    % Randomly select a template TC neuron for the candidates
    templateIDsUsed(iCell) = templateIDs(randi(nCandidates));
    templateNamesUsed{iCell} = templateNames{templateIDsUsed(iCell)};

fullfile(homeDirectory, paramsDirName, )

    % Import .p file data
    pfiledata = importdata(sprintf('pfiles/bestparams_%s.p', ...
                                    templateNamesUsed{iCell}));  % a XX x 4 array
    nTCParams = size(pfiledata, 1);
    for k = 1:nTCParams                 % for each parameter saved
        % Store parameter in the corresponding vector
        eval(sprintf('TC%s(%d) = %g;', pfiledata{k, 1}, iCell, pfiledata{k, 2}));
    end
end

%% Build simulation commands to be read by NEURON through the here-document
simCommands = cell(1, nTrials);             % stores simulation commands
scmdsPaths = cell(1, nTrials);
for k = 1:nTrials
    % Update parameters for this trial
    for i = 1:length(paramValues{k})
        eval(sprintf('%s = %g;', paramNames{i}, paramValues{k}(i)));
    end
    simCommands{k} = '';
    
    % Commands to create TC neurons
    for i = 1:nCells
        simCommands{k} = [simCommands{k}, sprintf(['buildTC(%d, %g, %g, %g, %g, %g, %g, %g, ', ...
                    '%g, %g, %g, %g, %g, %g, %g, ', ...
                    '%g, %g, %g, %g, %g, ', ...
                    '%g, %g, %g, %g, %g, %g, %g, %g, %g, %d, %d)\n'], ...
                    TCcellID(i), TCdiamSoma(i), TCLDend(i), TCdiamDendToSoma(i), TCdistDendPercent(i), ...
                    TCcorrD(i), TCgpas(i), TCepas(i), ...
                    TCpcabarITSoma(i), TCpcabarITDend1(i), TCpcabarITDend2(i), ...
                    TCshiftmIT(i), TCshifthIT(i), TCslopemIT(i), TCslopehIT(i), ...
                    TCghbarIhSoma(i), TCghbarIhDend1(i), TCghbarIhDend2(i), TCehIh(i), TCshiftmIh(i), ...
                    TCgkbarIASoma(i), TCgkbarIADend1(i), TCgkbarIADend2(i), ...
                    TCgkbarIKirSoma(i), TCgkbarIKirDend1(i), TCgkbarIKirDend2(i), ...
                    TCgnabarINaPSoma(i), TCgnabarINaPDend1(i), TCgnabarINaPDend2(i), ...
                    useHH, templateIDsUsed(i))];
    end

    % Commands to create RE neurons and build network
    simCommands{k} = [simCommands{k}, sprintf(['buildnet("%s", "%s", "%s", %g, %g, %g, %g, %g, %d, ', ...
                '%g, %g, %g, %g, %g, %g, %g, %g, %g, %g, ', ...
                '%g, %g, %g, %g, %g, %g, %g, %g, ', ...
                '%g, %g, %g, %g, %g, %g, %g, ', ...
                '%d, %d, %d, %d, %d, %d, %d)\n'], ...
                sREREsynPaths{k}, sTCREsynPaths{k}, sRETCsynPaths{k}, ...
                REsp1cellID, REsp2cellID, TCsp1cellID, TCsp2cellID, useHH, REnsegs, ...
                REcldnum, REconsyn, REtauKCC2, REepas, REdiam, ...
                REgabaGmax, REampaGmax, TCgabaaErev, TCgabaaGmax, TCgababErev, ...
                TCgababAmp, TCgababTrise, TCgababTfallFast, TCgababTfallSlow, TCgababW, ...
                RERErad, TCRErad, RETCrad, ...
                spThr, synDel, synWeight, cai0, cao0, cli0, clo0, ...
                actCellID, actMode, saveNetwork, saveSpikes, saveSomaVoltage, saveSomaCli, saveSpecial)];

    % Commands to randomize leak current properties
    %     uniformly randomizes leak conductance in [REgpasLB, REgpasUB]
    simCommands{k} = [simCommands{k}, sprintf('randleak(%g, %g, "%s")\n', ...
        REgpasLB, REgpasUB, sREleakPaths{k})];

    % Commands to initialize variables
    simCommands{k} = [simCommands{k}, sprintf('vinitRE(%g)\n', REepas)];

    % Commands to set up neural activation protocol
    switch actMode
    case 1
        % Activate a single RE cell by injecting a train of current pulses
        simCommands{k} = [simCommands{k}, sprintf('REsinglecp(%g, %g, %g, %g, %g, %g)\n', ...
                    actCellID, stimStart, cpDur, cpAmp, cpPer, cpNum)];
    case 2
        % Activate every (RERErad + 1)th RE cell by injecting trains of current pulses
        simCommands{k} = [simCommands{k}, sprintf('REmultcp(%g, %g, %g, %g, %g, %g, %g)\n', ...
                    actCellID, stimStart, cpDur, cpAmp, cpPer, cpNum, RERErad)];
    case 3
        % Activate 3 RE cells (RERErad + 1) apart by injecting trains of current pulses
        simCommands{k} = [simCommands{k}, sprintf('REthreecp(%g, %g, %g, %g, %g, %g, %g)\n', ...
                    actCellID, stimStart, cpDur, cpAmp, cpPer, cpNum, RERErad)];
    case 4
        % Activate a single RE cell at a specific voltage
        simCommands{k} = [simCommands{k}, sprintf('REsingleact(%g, %g)\n', ...
                    actCellID, actCellV)];    
    case 5
        % Activate RE cells with a Gaussian likelihood at a specific voltage
        simCommands{k} = [simCommands{k}, sprintf('RErandact(%g, %g, %g, %g)\n', ...
                    actCellID, actWidth, actMaxP, actCellV)];
    case 6
        % Activate every 3rd RE cell by injecting trains of current pulses
        simCommands{k} = [simCommands{k}, sprintf('REmultcp(%g, %g, %g, %g, %g, %g, %g)\n', ...
                    actCellID, stimStart, cpDur, cpAmp, cpPer, cpNum, 2)];
    case 7
        % Activate every RE cell by injecting trains of current pulses
        simCommands{k} = [simCommands{k}, sprintf('REmultcp(%g, %g, %g, %g, %g, %g, %g)\n', ...
                    actCellID, stimStart, cpDur, cpAmp, cpPer, cpNum, 0)];
    case 8
        % Activate 3 RE cells RETCrad apart by injecting trains of current pulses
        simCommands{k} = [simCommands{k}, sprintf('REthreecp(%g, %g, %g, %g, %g, %g, %g)\n', ...
                    actCellID, stimStart, cpDur, cpAmp, cpPer, cpNum, RETCrad-1)];
    case 9
        % Activate 10 center RE cells by injecting trains of current pulses
        simCommands{k} = [simCommands{k}, sprintf('REcentercp(%g, %g, %g, %g, %g, %g, %d)\n', ...
                    actCellID, stimStart, cpDur, cpAmp, cpPer, cpNum, 10)];
    case 10
        % Activate 20 center RE cells by injecting trains of current pulses
        simCommands{k} = [simCommands{k}, sprintf('REcentercp(%g, %g, %g, %g, %g, %g, %d)\n', ...
                    actCellID, stimStart, cpDur, cpAmp, cpPer, cpNum, 20)];
    otherwise
        error('actMode undefined!');
    end

    % Commands to run simulation
    %%%%%%
    %%%%%%%%%%%%
    simCommands{k} = [simCommands{k}, sprintf(['sim(%g, %g, "%s", "%s", "%s", "%s", "%s", ', ...
                                        '"%s", "%s", "%s", "%s", %d, %d, %d, %d)\n'], ...
                    tStop, dt, ...
                    sREspikePaths{k}, sTCspikePaths{k}, sREvPaths{k}, sTCvPaths{k}, sREcliPaths{k}, ...
                    sREsp1Paths{k}, sREsp2Paths{k}, sTCsp1Paths{k}, sTCsp2Paths{k}, ...
                    saveSpikes, saveSomaVoltage, saveSomaCli, saveSpecial)];
    %%%%%%%%%%%%
    %%%%%%

    % Commands to print all parameters
    simCommands{k} = [simCommands{k}, sprintf('print_params("%s", "%s", %g, %g, %g, %g)\n', ...
                    sREparamsPaths{k}, sTCparamsPaths{k}, useHH, REnsegs, REcldnum, REconsyn)];

    % Print simulation commands to a text file
    pchnamesThis = pchnames{k};
    if iscell(pchvalues)
        pchvaluesThis = pchvalues{k};
    elseif isnumeric(pchvalues)
        pchvaluesThis = pchvalues(k);
    end

    % Create name-value pairs
    nameValuePairsThis = {pchnamesThis, pchvaluesThis};

    scmdsPaths{k} = construct_fullpath(scmdsF, 'Directory', outFolder, ...
                    'NameValuePairs', nameValuePairsThis);
    fid = fopen(scmdsPaths{k}, 'w');
    fprintf(fid, '%s\n\n', simCommands{k});
    fclose(fid);
end

% Initialize results saying "No errors!"
results = cell(1, nTrials);     % stores simulation standard outputs
for k = 1:nTrials
    results{k} = 'No_Errors!';
end

% Set actual number of trials to simulate
if singleTrialNumber ~= 0
    nTrialsActual = 1;
else
    nTrialsActual = nTrials;    
end

%% Launch NEURON and execute run.hoc
timer1 = tic();
%##########
%##############
ct = 0;                         % counts number of trials completed
poolObj = gcp('nocreate');      % get current parallel pool object without creating a new one
if isempty(poolObj)
    poolObj = parpool;          % create a default parallel pool object
    oldNumWorkers = poolObj.NumWorkers;    % number of workers in the default parallel pool object
else
    oldNumWorkers = poolObj.NumWorkers;    % number of workers in the current parallel pool object
end
numWorkers = min(oldNumWorkers, maxNumWorkersNeuron);    % number of workers to use for running NEURON
if renewParpoolFlagNeuron
    delete(poolObj);            % delete the parallel pool object to release memory
end
while ct < nTrialsActual        % while not all trials are completed yet
    if singleTrialNumber    % if running only one trial
        first = singleTrialNumber; % run that trial
    else
        first = ct + 1;         % first trial in this batch
    end
    if singleTrialNumber           % if running only one trial
        last = singleTrialNumber;      % run only that trial
    elseif renewParpoolFlagNeuron && ...
        ct + numWorkers <= nTrialsActual    % if memory is to be released
        last = ct + numWorkers;             % limit the batch to numWorkers
    else
        last = nTrialsActual;   % run all trials at once
    end
    if renewParpoolFlagNeuron
        % Recreate a parallel pool object using fewer workers to prevent running out of memory
        poolObj = parpool('local', numWorkers); 
    end
    parfor k = first:last
    %for k = first:last

        %% Use m3ha_run5.hoc with simCommands
        if nCells == 100
            [status, results{k}] = ...
                unix(sprintf('x86_64/special m3ha_run5.hoc - << here\n%s\nprint "No_Errors!"\nhere', ...
                    simCommands{k}));    
        elseif nCells == 20
            [status, results{k}] = ...
                unix(sprintf('x86_64/special m3ha_run5_small.hoc - << here\n%s\nprint "No_Errors!"\nhere', ...
                    simCommands{k}));    
        elseif nCells == 2
            [status, results{k}] = ...
                unix(sprintf('x86_64/special m3ha_run12_tiny.hoc - << here\n%s\nprint "No_Errors!"\nhere', ...
                    simCommands{k}));    
        elseif nCells == 1
            [status, results{k}] = ...
                unix(sprintf('x86_64/special m3ha_run_1cell.hoc - << here\n%s\nprint "No_Errors!"\nhere', ...
                    simCommands{k}));    
        else
            status = -3;
            results{k} = 'NEURON wasn''t run because nCells is not correct\n';
        end

        fid = fopen(fullfile(outFolder, replace(soutF, 'sim', ['sim_', num2str(k)])), 'w');
        fprintf(fid, 'Return status was: %d\n\nSimulation output was:\n\n%s\n', status, results{k});
        fclose(fid);
        fprintf('Simulation #%d complete!\n', k);
    end
    if renewParpoolFlagNeuron
        delete(poolObj);    % delete the parallel pool object to release memory
    end
    if singleTrialNumber
        ct = nTrialsActual + 1;   % don't run again
    else
        ct = last;          % update number of trials completed
    end
end
if renewParpoolFlagNeuron
    poolObj = parpool('local', oldNumWorkers);    % recreate a parallel pool object using the previous number of workers
end
%##############
%##########

%% Analyze simulation standard outputs
timeTaken = toc(timer1);
fprintf('It took %3.3g seconds to run all %d simulations with NEURON!!\n', timeTaken, nTrialsActual);
fprintf('\n');
ranIntoErrors = cellfun(@isempty, strfind(results, 'No_Errors!'));
if sum(ranIntoErrors) == 0
    fprintf('No Errors in NEURON!\n');
    fprintf('\n');

    % Could use the following to display simulation outputs for debugging purposes 
    %     (these are always saved as text files though)
    %{
    for k = 1:nTrialsActual
        disp(results{k});
        fprintf('\n');
    end
    %}
else
    indProblematic = find(ranIntoErrors > 0, 1);
    fprintf(['Simulation for Sweep #', num2str(indProblematic), ' ran into errors with output:\n']);
    fprintf('%s\n', results{indProblematic});
end

%% Save all variables in a mat file named by the date & time
save(fullfile(outFolder, sprintf('%s.mat', outFolderName)), '-v7.3');

%% Plot stuff
timer2 = tic();

% Read data from the previous outFolder
inFolder = outFolder;

% Show network topology
if plotNetwork
    [RERE, TCRE, RETC] = m3ha_network_show_net(inFolder, 'OutFolder', outFolder, ...
                                    'FirstOnly', true);
end

% Show spike raster plot for each set of neurons (each .spi file)
[~, ~, numActive, latency, oscDur] ...
    = m3ha_network_raster_plot(inFolder, 'OutFolder', outFolder, ...
            'RenewParpool', renewParpoolFlagPlots, ...
            'MaxNumWorkers', maxNumWorkersPlots, ...
            'SingleTrialNum', singleTrialNumber, ...
            'PlotSpikes', plotSpikes, 'PlotTuning', plotTuning);

% Show single neuron traces and heat maps for selected neurons (each .singv, .singcli & .singsp file)
if plotSingleNeuronData
    m3ha_network_single_neuron(inFolder, 'OutFolder', outFolder, ...
            'CellsToPlot', cellsToPlot, 'PropertiesToPlot', propertiesToPlot, ...
            'RenewParpool', renewParpoolFlagPlots, ...
            'MaxNumWorkers', maxNumWorkersPlots);
end

%% Compute time taken
timeTaken = toc(timer2);
fprintf('It took %3.3g seconds to plot and save stuff!!\n', timeTaken);
fprintf('\n');

%% Save all variables again in a mat file named by the date & time
save(fullfile(outFolder, sprintf('%s.mat', outFolderName)), '-v7.3');

%% Play Handel if not on Rivanna
if exist('/media/adamX/', 'dir') == 7
    load handel
    sound(y, Fs);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
OLD CODE:

%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%