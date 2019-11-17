function [errorStruct, hFig, simData] = ...
                m3ha_neuron_run_and_analyze (neuronParamsTable, varargin)
%% Runs and analyzes "one iteration" of NEURON simulations (once for each of the sweeps)
% Usage: [errorStruct, hFig, simData] = ...
%               m3ha_neuron_run_and_analyze (neuronParamsTable, varargin)
% Explanation:
%       TODO
% 
% Outputs: 
%       TODO
%       simData     - simulated data
%                   specified as a numeric array
%                       or a cell array of numeric arrays
% Arguments:
%       neuronParamsTable   
%                   - table(s) of single neuron parameters with 
%                       parameter names as 'RowNames' and with variables:
%                       'Value': value of the parameter
%                       'LowerBound': lower bound of the parameter
%                       'UpperBound': upper bound of the parameter
%                       'JitterPercentage': jitter percentage of the parameter
%                       'IsLog': whether the parameter is 
%                                   to be varied on a log scale
%                   must be a 2d table or a cell array of 2d tables
%       varargin    - 'Hfig': handles structure for figures
%                   must be a TODO
%                   default == TODO
%                   - 'SimMode': simulation mode
%                   must be an unambiguous, case-insensitive match to one of: 
%                       'passive' - simulate a current pulse response
%                       'active'  - simulate an IPSC response
%                   default == 'passive'
%                   - 'NSweeps': number of sweeps
%                   must be a positive integer scalar
%                   default == numel(realData) or 1
%                   - 'Prefix': prefix to prepend to file names
%                   must be a character array
%                   default == ''
%                   - 'OutFolder': the directory where outputs will be placed
%                   must be a string scalar or a character vector
%                   default == pwd
%                   - 'FileBase': base of filename (without extension) 
%                                   corresponding to each vector
%                   must be a character vector, a string vector 
%                       or a cell array of character vectors
%                   default == set in decide_on_filebases.m
%                   - 'DebugFlag': whether debugging
%                   must be numeric/logical 1 (true) or 0 (false)
%                   default == false
%                   - 'CustomHoldCurrentFlag': whether to use a custom 
%                                               holding current
%                   must be numeric 1 or 0
%                   default == false
%                   - 'OnHpcFlag': whether on a high performance 
%                                   computing server
%                   must be numeric/logical 1 (true) or 0 (false)
%                   default == false
%                   - 'GenerateDataFlag': whether generating surrogate data
%                   must be numeric/logical 1 (true) or 0 (false)
%                   default == false
%                   - 'AverageCprFlag': whether to average current pulse 
%                                       responses according to vHold
%                   must be numeric/logical 1 (true) or 0 (false)
%                   default == false
%                   - 'BootstrapCprFlag': whether to bootstrap-average current  
%                                       pulse responses according to vHold
%                   must be numeric/logical 1 (true) or 0 (false)
%                   default == false
%                   - 'Normalize2InitErrFlag': whether to normalize errors
%                                               to initial errors
%                   must be numeric/logical 1 (true) or 0 (false)
%                   default == false
%                   - 'SaveParamsFlag': whether to save simulation parameters
%                   must be numeric/logical 1 (true) or 0 (false)
%                   default == true
%                   - 'SaveSimCmdsFlag': whether to save simulation commands
%                   must be numeric/logical 1 (true) or 0 (false)
%                   default == true
%                   - 'SaveStdOutFlag': whether to save standard outputs
%                   must be numeric/logical 1 (true) or 0 (false)
%                   default == true
%                   - 'SaveSimOutFlag': whether to save simulation outputs
%                                           when there are no errors
%                   must be numeric/logical 1 (true) or 0 (false)
%                   default == true
%                   - 'SaveLtsInfoFlag': whether to save LTS info
%                   must be numeric/logical 1 (true) or 0 (false)
%                   default == true
%                   - 'SaveLtsStatsFlag': whether to save LTS statistics
%                   must be numeric/logical 1 (true) or 0 (false)
%                   default == true
%                   - 'PlotIndividualFlag': whether to plot individual traces
%                   must be numeric/logical 1 (true) or 0 (false)
%                   default == true
%                   - 'PlotResidualsFlag': whether to plot residuals
%                   must be numeric/logical 1 (true) or 0 (false)
%                   default == true
%                   - 'PlotOverlappedFlag': whether to plot overlapped traces
%                   must be numeric/logical 1 (true) or 0 (false)
%                   default == true
%                   - 'PlotConductanceFlag': whether to plot conductance traces
%                   must be numeric/logical 1 (true) or 0 (false)
%                   default == true
%                   - 'PlotCurrentFlag': whether to plot current traces
%                   must be numeric/logical 1 (true) or 0 (false)
%                   default == true
%                   - 'PlotIpeakFlag': whether to current peak analyses
%                   must be numeric/logical 1 (true) or 0 (false)
%                   default == true
%                   - 'PlotLtsFlag': whether to plot vtrace/LTS/burst analyses
%                   must be numeric/logical 1 (true) or 0 (false)
%                   default == true
%                   - 'PlotStatisticsFlag': whether to plot LTS statistics
%                   must be numeric/logical 1 (true) or 0 (false)
%                   default == true
%                   - 'PlotSwpWeightsFlag': whether to show a green 'ON' 
%                                       for sweeps in use
%                   must be numeric/logical 1 (true) or 0 (false)
%                   default == true
%                   - 'PlotMarkFlag': whether to plot the way Mark 
%                                       wants plots to look
%                   must be numeric/logical 1 (true) or 0 (false)
%                   default == true
%                   - 'ShowSweepsFlag': whether to show sweep figures
%                   must be numeric/logical 1 (true) or 0 (false)
%                   default == true
%                   - 'JitterFlag': whether to introduce noise in parameters
%                   must be numeric/logical 1 (true) or 0 (false)
%                   default == false
%                   - 'Grouping': a grouping vector used to group traces
%                   must be a vector
%                   default == []
%                   - 'CprWindow': current pulse response window in ms
%                   must be a numeric vector with 2 elements
%                   default == [0, 360] + timeToStabilize
%                   - 'IpscTime': start time of IPSC in ms
%                   must be a numeric scalar
%                   default == 1000 + timeToStabilize
%                   - 'IpscPeakWindow': window (ms) to look for IPSC peak
%                   must be a numeric vector
%                   default == [1000, 1300] + timeToStabilize
%                   - 'IpscrWindow': IPSC response window in ms
%                   must be a numeric vector with 2 elements
%                   default == [0, 8000] + timeToStabilize
%                   - 'OutFilePath': path to NEURON output file(s)
%                   must be a characeter vector, a string array 
%                       or a cell array of character arrays
%                   default == 'auto'
%                   - 'Tstop': simulation end time
%                   must be a numeric vector
%                   default == based on simMode, cprWindow(2) & ipscrWindow(2)
%                   - 'RealDataIpscr': recorded data to compare against
%                   must be a numeric array
%                       or a cell array of numeric arrays
%                   default == []
%                   - 'RealDataCpr': recorded data to compare against
%                   must be a numeric array
%                       or a cell array of numeric arrays
%                   default == []
%                   - 'HoldPotentialIpscr': holding potential for (mV)
%                                           IPSC response
%                   must be a numeric vector
%                   default == -70 mV
%                   - 'HoldPotentialCpr': holding potential for (mV)
%                                           current pulse response
%                   must be a numeric vector
%                   default == -70 mV
%                   - 'CurrentPulseAmplitudeIpscr': current pulse amplitude (nA)
%                   must be a numeric vector
%                   default == -0.050 nA
%                   - 'CurrentPulseAmplitudeCpr': current pulse amplitude (nA)
%                   must be a numeric vector
%                   default == -0.050 nA
%                   - 'GababAmp': GABA-B IPSC amplitude (uS)
%                   must be a numeric vector
%                   default == set of all 12 input waveforms
%                   - 'GababTrise': GABA-B IPSC rising time constant (ms)
%                   must be a numeric vector
%                   default == set of all 12 input waveforms
%                   - 'GababTfallFast': GABA-B IPSC falling phase 
%                                           fast component time constant (ms)
%                   must be a numeric vector
%                   default == set of all 12 input waveforms
%                   - 'GababTfallSlow': GABA-B IPSC falling phase 
%                                           slow component time constant (ms)
%                   must be a numeric vector
%                   default == set of all 12 input waveforms
%                   - 'GababWeight': GABA-B IPSC falling phase 
%                                           fast component weight
%                   must be a numeric vector
%                   default == set of all 12 input waveforms
%                   - 'HoldCurrentIpscr': custom holding current (nA)
%                                           for IPSC response
%                   must be a numeric vector
%                   default == 0 nA
%                   - 'HoldCurrentCpr': custom holding current (nA)
%                                       for current pulse response
%                   must be a numeric vector
%                   default == 0 nA
%                   - 'HoldCurrentNoiseIpscr': custom holding current noise (nA)
%                                               for IPSC response
%                   must be a numeric vector
%                   default == 0 nA
%                   - 'HoldCurrentNoiseCpr': custom holding current noise (nA)
%                                               for current pulse response
%                   must be a numeric vector
%                   default == 0 nA
%                   - 'RowConditionsIpscr': row conditions for plotting
%                                               IPSC response
%                       Note: each row is assigned a different color
%                   must be a numeric 2D array
%                   default == transpose(1:nSweeps)
%                   - 'RowConditionsCpr': row conditions for plotting
%                                               current pulse response
%                       Note: each row is assigned a different color
%                   must be a numeric 2D array
%                   default == transpose(1:nSweeps)
%                   - 'FitWindowCpr': time window to fit (ms)
%                                       for current pulse response
%                   must be a numeric vector with 2 elements
%                   default == [100, 250] + timeToStabilize
%                   - 'FitWindowIpscr': time window to fit (ms)
%                                       for IPSC response
%                   must be a numeric vector with 2 elements
%                   default == [1000, 8000] + timeToStabilize
%                   - 'BaseWindowCpr': baseline window (ms)
%                                       for current pulse response
%                   must be a numeric vector with 2 elements
%                   default == [0, 100] + timeToStabilize
%                   - 'BaseWindowIpscr': baseline window (ms)
%                                       for IPSC response
%                   must be a numeric vector with 2 elements
%                   default == [0, 1000] + timeToStabilize
%                   - 'BaseNoiseCpr': baseline noise (mV)
%                                       for current pulse response
%                   must be a numeric vector
%                   default == 1 mV
%                   - 'BaseNoiseIpscr': baseline noise (mV)
%                                       for IPSC response
%                   must be a numeric vector
%                   default == 1 mV
%                   - 'SweepWeightsCpr': sweep weights 
%                                       for current pulse response
%                   must be a numeric vector
%                   default == 1
%                   - 'SweepWeightsIpscr': sweep weights
%                                       for IPSC response
%                   must be a numeric vector
%                   default == 1
%                   - 'LtsFeatureWeights': LTS feature weights for averaging
%                   must be empty or a numeric vector with length == nSweeps
%                   default == set in compute_lts_errors.m
%                   - 'LtsExistError': a dimensionless error that penalizes 
%                               a misprediction of the existence/absence of LTS
%                   must be empty or a numeric vector with length == nSweeps
%                   default == set in compute_lts_errors.m
%                   - 'Lts2SweepErrorRatio': ratio of LTS error to sweep error
%                   must be empty or a numeric vector with length == nSweeps
%                   default == 2
%
% Requires:
%       ~/m3ha/optimizer4gabab/singleneuron4compgabab.hoc
%       cd/argfun.m
%       cd/compute_combined_data.m
%       cd/compute_default_sweep_info.m
%       cd/compute_residuals.m
%       cd/compute_rms_error.m
%       cd/compute_sampling_interval.m
%       cd/compute_single_neuron_errors.m
%       cd/create_colormap.m
%       cd/decide_on_colormap.m
%       cd/decide_on_filebases.m
%       cd/extract_columns.m
%       cd/extract_subvectors.m
%       cd/find_IPSC_peak.m
%       cd/find_LTS.m
%       cd/find_window_endpoints.m
%       cd/force_matrix.m
%       cd/load_neuron_outputs.m
%       cd/match_time_points.m
%       cd/m3ha_neuron_create_simulation_params.m
%       cd/m3ha_neuron_create_TC_commands.m
%       cd/m3ha_plot_individual_traces.m
%       cd/parse_ipsc.m
%       cd/parse_lts.m
%       cd/parse_pulse_response.m
%       cd/plot_bar.m
%       cd/run_neuron.m
%       cd/save_all_figtypes.m
%       cd/set_figure_properties.m
%       cd/test_var_difference.m
%
%       cd/save_params.m TODO
%
% Used by:    
%       cd/m3ha_fminsearch3.m
%       ~/m3ha/optimizer4gabab/m3ha_optimizer_4compgabab.m

% File History:
% 2014-04-XX - Created by Christine
% 2016-07-19 - changed ltsWindow
% 2016-07-20 - Added JITTER mode option
% 2016-07-20 - changed di
% 2016-07-20 - Analyze & plot LTS data
% 2016-10-04 - Changed the way NEURON is run: Added parfor and simCommands, etc.
% 2016-10-04 - Changed the method for execution to be from a here document 
%               written in the Matlab code directly
% 2016-10-05 - Moved outparams.lts2SweepErrorRatio to 
%               the calculation of total error (instead of total LTS error)
% 2016-10-05 - Added current pulse response
% 2016-10-05 - Changed the way error calculations are organized; 
%               added compute_and_compare_statistics
% 2016-10-06 - Reorganized code
% 2016-10-06 - Removed err_stats2_sim{bi} & err_stats2_real{bi}
% 2016-10-06 - Changed swpreg to fitreg
% 2016-10-06 - Renamed figure handles so that they are now all in a structure 
%               hFig that is passed to and from functions
% 2016-10-07 - outparams.currpulse(iSwp) is now already in nA
% 2016-10-07 - Added cprflag, findLtsFlag, ltsBurstStatsFlag, ltsErrorFlag
% 2016-10-14 - Updated outputs for find_IPSC_peak & find_LTS
% 2016-10-14 - Fixed outparams.fitreg to fitreg inside parfor loop
% 2016-10-14 - Changed from root mean-squared error to mean-squared error
% 2017-01-14 - Added build() to simCommands
% 2017-01-14 - Added simMode to both build() and sim() of simCommands
% 2017-02-06 - Fixed fprintf of status to be %d from %s
% 2017-04-21 - Added outFolder to output file names
% 2017-04-24 - Renamed simulation_params -> neuronparams
% 2017-05-13 - Now gets outFolder from outparams
% 2017-05-15 - Changed outparams.prefix so that '_cpr' is already incorporated
% 2017-05-15 - Made simMode the last argument of build()
% 2017-05-16 - Added saveParamsFlag, saveStdOutFlag, 
%               saveSimCmdsFlag & saveSimOutFlag
% 2017-05-17 - Added saveLtsInfoFlag & saveLtsStatsFlag
% 2017-05-17 - Updated color groups to reflect pharm-g incr pairs
% 2017-05-17 - Now uses root-mean-squared errors instead of mean-squared errors
% 2017-05-17 - Weighting of errors is now normalized
% 2017-05-17 - Made 'a' column vectors
% 2017-05-17 - Now computes average sweep error instead of total sweep error
% 2017-05-17 - Made all errors dimensionless by normalizing by the real data value
% 2017-05-17 - Normalize by initial error instead, rmse now has units of mV again
% 2017-05-17 - Added outparams.isLtsError
% 2017-05-17 - Fixed the case where simulation correctly predicted 
%               the non-existence of LTS (should be 0 error)
% 2017-05-19 - Moved update_sweeps_figures() here from m3ha_optimizer_4compgabab.m
% 2017-05-19 - Separated update_sweeps_figures() into 
%               decide_on_xlimits(), plot_overlapped_traces(),
%               plot_conductance_traces(), plot_current_traces() 
%               && m3ha_plot_individual_traces()
% 2017-05-22 - Changed line width and indentation
% 2017-05-23 - Removed modeselected from outparams and replaced with updated outparams.runMode
% 2017-07-27 - Now extracts all NEURON parameters to workspace
% 2017-07-28 - Added commands for calling adjust_globalpas, adjust_leak, 
%               adjust_IT, adjust_Ih, adjust_IA, adjust_IKir, adjust_INaP
% 2017-07-28 - Changed precision of parameters from %6.3f to %g
% 2017-07-28 - Made normalization to starting error an option (outparams.normalize2InitErrFlag)
% 2017-07-28 - Made sweep error dimensionless by dividing by the holding potential
% 2017-07-28 - Made sweep error dimensionless by dividing by the the maximum noise of sweep
% 2017-07-29 - Now normalizes LTS amp error by maximum noise instead
% 2017-07-29 - Now normalizes LTS time error by ioffset instead
% 2017-07-29 - Now normalizes LTS slope error by 
%               slope*(2*maximum noise/peakprom + 2*ioffset/peakwidth) instead
% 2017-07-29 - Now normalizes LTS time error by peakwidth instead
% 2017-08-11 - Added outparams.colmode and load across trials NEURON parameters
%               from outparams.neuronparamsBest for each cell
% 2017-08-12 - Now loads across cells NEURON parameters from 
%               outparams.neuronparamsAcrossCells when fitting across trials
% 2017-08-21 - Fixed ncg = size(colorMap, 2) -> size(colorMap, 1);
%               colorMap{cgn} -> colorMap(cgn, :)
% 2017-08-29 - Removed dend0
% 2017-11-09 - Replaced saveas with save_all_figtypes
% 2017-11-09 - Now uses plot_bar.m instead of errorbar
% 2017-12-21 - Added some more output ~s to find_LTS.m 
% 2018-01-24 - Added isdeployed
% 2018-03-02 - Added runNeuronCommand, moduleLoadCommands, moduleLoadCommandsHpc
% 2018-03-02 - Added onHpcFlag as an optional argument
% 2018-03-07 - Added outparams.showStatisticsFlag
% 2018-03-09 - Fixed the case of plotting scatter plots when the standard
%               deviation is zero
% 2018-05-21 - Changed voltage uncertainty from outparams.maxNoise to 
%               outparams.baseNoise or outparams.baseNoiseCpr
% 2018-05-21 - Now uses nanmean to compute rmse() to account for 
%               NaN in cpr response values
% 2018-05-21 - Changed color groups for current pulse response to 3 groups
% 2018-07-09 - Now uses compute_rms_error
% 2018-07-12 - BT - Added plotting residuals
% 2018-08-09 - Now does not divide by baseNoise, but use baseNoise
%               to modify sweep weights inst
% 2018-08-09 - Now plots sweep weights
% 2018-08-10 - Changed fitreg to fitWindow
% 2018-08-26 - Now links x and y axes for subplots
% 2018-10-01 - Added holdcurrentNoise
% 2018-10-15 - Updated usage of TC3
% 2018-10-16 - Now uses save_params.m
% 2018-10-19 - Made 'RealData' as an optional parameter
% 2018-11-16 - Separated 'RealDataCpr' from 'RealDataIpscr'
% 2019-01-08 - Reorganized code so that one can run a single simulation easily
%                   from a set of parameters
% 2019-01-09 - Added 'GenerateDataFlag' as an optional parameter
% 2019-01-14 - Added 'BootstrapCprFlag' as an optional parameter
% 2019-05-08 - Updated usage of plot_bar.m
% 2019-10-13 - Updated simulated data column numbers
% 2019-11-15 - Added 'IpscTime' as an optional parameter
% 2019-11-15 - Added 'IpscPeakWindow' as an optional parameter
% 2019-11-15 - Added 'FileBase' as an optional parameter
%   TODO: Use save_params.m
%   TODO: plotConductanceFlag
%   TODO: plotCurrentFlag

%% Hard-coded parameters
validSimModes = {'active', 'passive'};
hocFile = 'singleneuron4compgabab.hoc';
maxRowsWithOneOnly = 8;
verbose = false;

% The following must be consistent with both dclampDataExtractor.m & ...
%   singleneuron4compgabab.hoc
cprWinOrig = [0, 360];          % current pulse response window (ms), original
ipscTimeOrig = 1000;            % time of IPSC application (ms), original
ipscrWinOrig = [0, 8000];       % IPSC response window (ms), original
ipscpWinOrig = [1000, 1300];    % window (ms) in which IPSC reaches peak 
                                %   amplitude , original
                                %   Based on observation, IPSCs are 
                                %   not influenced by LTSs before 1300 ms

% The following must be consistent with singleneuron4compgabab.hoc
timeToStabilize = 2000;         % padded time (ms) to make sure initial value 
                                %   of simulations are stabilized

%% Column numbers for recorded data
%   Note: Must be consistent with ResaveSweeps.m
TIME_COL_REC = 1;
VOLT_COL_REC = 2;
CURR_COL_REC = 3;

%% Column numbers for simulated data
%   Note: Must be consistent with singleneuron4compgabab.hoc
TIME_COL_SIM = 1;
VOLT_COL_SIM = 2;
DEND1_COL_SIM = 3;
DEND2_COL_SIM = 4;
IDCLAMP_COL_SIM = 5;
GGABAB_COL_SIM = 6;
iCP_COL_SIM = 7;
IEXT_COL_SIM = 8;
ICA_COL_SIM = 9;
ITM_COL_SIM = 10;
ITMINF_COL_SIM = 11;
ITH_COL_SIM = 12;
ITHINF_COL_SIM = 13;
IH_COL_SIM = 14;
IHM_COL_SIM = 15;
IKA_COL_SIM = 16;
IAM1_COL_SIM = 17;
IAH1_COL_SIM = 18;
IAM2_COL_SIM = 19;
IAH2_COL_SIM = 20;
IKKIR_COL_SIM = 21;
IKIRM_COL_SIM = 22;
INAPNA_COL_SIM = 23;
INAPM_COL_SIM = 24;
INAPH_COL_SIM = 25;

%% Default values for optional arguments
hFigDefault = '';               % no prior hFig structure by default
simModeDefault = 'active'; %'passive';     % simulate a current pulse response by default
nSweepsDefault = [];            % set later
prefixDefault = '';             % prepend nothing to file names by default
outFolderDefault = pwd;         % use the present working directory for outputs
                                %   by default
fileBaseDefault = {};           % set later
debugFlagDefault = false;       % not in debug mode by default
customHoldCurrentFlagDefault = 0; % don't use custom hold current by default
onHpcFlagDefault = false;       % not on a high performance computing
                                %   server by default
generateDataFlagDefault = false;% not generating surrogate data by default
averageCprFlagDefault = false;  % don't average current pulse responses 
                                %   according to vHold by default
bootstrapCprFlagDefault = false;% don't bootstrap-average current pulse  
                                %   responses according to vHold by default
normalize2InitErrFlagDefault = false;
saveParamsFlagDefault = true;   % save simulation parameters by default
saveSimCmdsFlagDefault = true;  % save simulation commands by default
saveStdOutFlagDefault = true;   % save standard outputs by default
saveSimOutFlagDefault = true;   % save simulation outputs by default
saveLtsInfoFlagDefault = true;  % save LTS info by default
saveLtsStatsFlagDefault = true; % save LTS statistics by default
plotIndividualFlagDefault = true;   % all zoomed traces plotted by default
plotResidualsFlagDefault = true;    % all residuals plotted by default
plotOverlappedFlagDefault = true;   % all overlapped traces plotted by default
plotConductanceFlagDefault = true;  % all conductance traces plotted by default
plotCurrentFlagDefault = true;      % all current traces plotted by default
plotIpeakFlagDefault = true;        % current peak analyses plotted by default
plotLtsFlagDefault = true;          % LTS/burst analyses plotted by default
plotStatisticsFlagDefault = true;   % LTS & burst statistics plotted by default
plotSwpWeightsFlagDefault = 'auto'; % set in m3ha_plot_inidividual_traces.m
plotMarkFlagDefault = true;         % the way Mark wants plots to look
showSweepsFlagDefault = true;       % whether to show sweep figures
jitterFlagDefault = false;          % no jitter by default
groupingDefault = [];               % no grouping by default
cprWindowDefault = cprWinOrig + timeToStabilize;
ipscTimeDefault = ipscTimeOrig + timeToStabilize;
ipscPeakWindowDefault = ipscpWinOrig + timeToStabilize;
ipscrWindowDefault = ipscrWinOrig + timeToStabilize;
outFilePathDefault = 'auto';    % set later
tstopDefault = [];              % set later
realDataIpscrDefault = [];      % no data to compare against by default
realDataCprDefault = [];        % no data to compare against by default
holdPotentialIpscrDefault = -70;% (mV)
holdPotentialCprDefault = -70;  % (mV)
currentPulseAmplitudeIpscrDefault = -0.050;  % (nA)
currentPulseAmplitudeCprDefault = -0.050;  % (nA)
gababAmpDefault = [];           % set later
gababTriseDefault = [];         % set later
gababTfallFastDefault = [];     % set later
gababTfallSlowDefault = [];     % set later
gababWeightDefault = [];        % set later
holdCurrentIpscrDefault = 0;    % (nA)
holdCurrentCprDefault = 0;      % (nA)
holdCurrentNoiseIpscrDefault = 0;% (nA)
holdCurrentNoiseCprDefault = 0; % (nA)
rowConditionsIpscrDefault = []; % set later
rowConditionsCprDefault = [];   % set later
fitWindowCprDefault = [100, 250] + timeToStabilize;
fitWindowIpscrDefault = [ipscTimeOrig, ipscrWinOrig(2)] + timeToStabilize;
baseWindowCprDefault = [0, 100] + timeToStabilize;
baseWindowIpscrDefault = [ipscrWinOrig(1), ipscTimeOrig] + timeToStabilize;
baseNoiseCprDefault = [];       % set later
baseNoiseIpscrDefault = [];     % set later
sweepWeightsCprDefault = [];    % set later
sweepWeightsIpscrDefault = [];  % set later
ltsFeatureWeightsDefault = [];  % set later
ltsExistErrorDefault = [];      % set later
lts2SweepErrorRatioDefault = [];% set later

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Deal with arguments
% Check number of required arguments
if nargin < 1
    error(['Not enough input arguments, ', ...
            'type ''help %s'' for usage'], mfilename);
end

% Set up Input Parser Scheme
iP = inputParser;         
iP.FunctionName = mfilename;
iP.KeepUnmatched = true;                        % allow extraneous options

% Add required inputs to the Input Parser
addRequired(iP, 'neuronParamsTable', ...
    @(x) validateattributes(x, {'table', 'cell'}, {'2d'}));

% Add parameter-value pairs to the Input Parser
addParameter(iP, 'HFig', hFigDefault);
addParameter(iP, 'SimMode', simModeDefault, ...
    @(x) any(validatestring(x, validSimModes)));
addParameter(iP, 'NSweeps', nSweepsDefault, ...
    @(x) validateattributes(x, {'numeric'}, {'scalar', 'positive', 'integer'}));
addParameter(iP, 'Prefix', prefixDefault, ...
    @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
addParameter(iP, 'OutFolder', outFolderDefault, ...
    @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
addParameter(iP, 'FileBase', fileBaseDefault, ...
    @(x) assert(ischar(x) || iscellstr(x) || isstring(x), ...
        ['FileBase must be a character array or a string array ', ...
            'or cell array of character arrays!']));
addParameter(iP, 'DebugFlag', debugFlagDefault, ...
    @(x) validateattributes(x, {'logical', 'numeric'}, {'binary'}));
addParameter(iP, 'CustomHoldCurrentFlag', customHoldCurrentFlagDefault, ...
    @(x) validateattributes(x, {'numeric'}, {'binary'}));
addParameter(iP, 'OnHpcFlag', onHpcFlagDefault, ...   
    @(x) validateattributes(x, {'logical', 'numeric'}, {'binary'}));
addParameter(iP, 'GenerateDataFlag', generateDataFlagDefault, ...   
    @(x) validateattributes(x, {'logical', 'numeric'}, {'binary'}));
addParameter(iP, 'AverageCprFlag', averageCprFlagDefault, ...   
    @(x) validateattributes(x, {'logical', 'numeric'}, {'binary'}));
addParameter(iP, 'BootstrapCprFlag', bootstrapCprFlagDefault, ...   
    @(x) validateattributes(x, {'logical', 'numeric'}, {'binary'}));
addParameter(iP, 'Normalize2InitErrFlag', normalize2InitErrFlagDefault, ...
    @(x) validateattributes(x, {'logical', 'numeric'}, {'binary'}));
addParameter(iP, 'SaveParamsFlag', saveParamsFlagDefault, ...
    @(x) validateattributes(x, {'logical', 'numeric'}, {'binary'}));
addParameter(iP, 'SaveSimCmdsFlag', saveSimCmdsFlagDefault, ...
    @(x) validateattributes(x, {'logical', 'numeric'}, {'binary'}));
addParameter(iP, 'SaveStdOutFlag', saveStdOutFlagDefault, ...
    @(x) validateattributes(x, {'logical', 'numeric'}, {'binary'}));
addParameter(iP, 'SaveSimOutFlag', saveSimOutFlagDefault, ...
    @(x) validateattributes(x, {'logical', 'numeric'}, {'binary'}));
addParameter(iP, 'SaveLtsInfoFlag', saveLtsInfoFlagDefault, ...
    @(x) validateattributes(x, {'logical', 'numeric'}, {'binary'}));
addParameter(iP, 'SaveLtsStatsFlag', saveLtsStatsFlagDefault, ...
    @(x) validateattributes(x, {'logical', 'numeric'}, {'binary'}));
addParameter(iP, 'PlotIndividualFlag', plotIndividualFlagDefault, ...   
    @(x) validateattributes(x, {'logical', 'numeric'}, {'binary'}));
addParameter(iP, 'PlotResidualsFlag', plotResidualsFlagDefault, ...   
    @(x) validateattributes(x, {'logical', 'numeric'}, {'binary'}));
addParameter(iP, 'PlotOverlappedFlag', plotOverlappedFlagDefault, ...   
    @(x) validateattributes(x, {'logical', 'numeric'}, {'binary'}));
addParameter(iP, 'PlotConductanceFlag', plotConductanceFlagDefault, ...   
    @(x) validateattributes(x, {'logical', 'numeric'}, {'binary'}));
addParameter(iP, 'PlotCurrentFlag', plotCurrentFlagDefault, ...   
    @(x) validateattributes(x, {'logical', 'numeric'}, {'binary'}));
addParameter(iP, 'PlotIpeakFlag', plotIpeakFlagDefault, ...   
    @(x) validateattributes(x, {'logical', 'numeric'}, {'binary'}));
addParameter(iP, 'PlotLtsFlag', plotLtsFlagDefault, ...   
    @(x) validateattributes(x, {'logical', 'numeric'}, {'binary'}));
addParameter(iP, 'PlotStatisticsFlag', plotStatisticsFlagDefault, ...   
    @(x) validateattributes(x, {'logical', 'numeric'}, {'binary'}));
addParameter(iP, 'PlotSwpWeightsFlag', plotSwpWeightsFlagDefault, ...   
    @(x) validateattributes(x, {'logical', 'numeric'}, {'binary'}));
addParameter(iP, 'PlotMarkFlag', plotMarkFlagDefault, ...   
    @(x) validateattributes(x, {'logical', 'numeric'}, {'binary'}));
addParameter(iP, 'ShowSweepsFlag', showSweepsFlagDefault, ...
    @(x) validateattributes(x, {'logical', 'numeric'}, {'binary'}));
addParameter(iP, 'JitterFlag', jitterFlagDefault, ...
    @(x) validateattributes(x, {'logical', 'numeric'}, {'binary'}));
addParameter(iP, 'Grouping', groupingDefault);
addParameter(iP, 'CprWindow', cprWindowDefault, ...
    @(x) validateattributes(x, {'numeric'}, {'vector', 'numel', 2}));
addParameter(iP, 'IpscTime', ipscTimeDefault, ...
    @(x) validateattributes(x, {'numeric'}, {'vector'}));
addParameter(iP, 'IpscPeakWindow', ipscPeakWindowDefault, ...
    @(x) validateattributes(x, {'numeric'}, {'vector'}));
addParameter(iP, 'IpscrWindow', ipscrWindowDefault, ...
    @(x) validateattributes(x, {'numeric'}, {'vector', 'numel', 2}));
addParameter(iP, 'OutFilePath', outFilePathDefault, ...
    @(x) ischar(x) || isstring(x) || iscellstr(x));
addParameter(iP, 'Tstop', tstopDefault, ...
    @(x) validateattributes(x, {'numeric'}, {'vector'}));
addParameter(iP, 'RealDataIpscr', realDataIpscrDefault, ...
    @(x) assert(isnumeric(x) || iscellnumeric(x), ...
                ['RealDataIpscr must be either a numeric array', ...
                    'or a cell array of numeric arrays!']));
addParameter(iP, 'RealDataCpr', realDataCprDefault, ...
    @(x) assert(isnumeric(x) || iscellnumeric(x), ...
                ['RealDataCpr must be either a numeric array', ...
                    'or a cell array of numeric arrays!']));
addParameter(iP, 'HoldPotentialIpscr', holdPotentialIpscrDefault, ...
    @(x) validateattributes(x, {'numeric'}, {'vector'}));
addParameter(iP, 'HoldPotentialCpr', holdPotentialCprDefault, ...
    @(x) validateattributes(x, {'numeric'}, {'vector'}));
addParameter(iP, 'CurrentPulseAmplitudeIpscr', currentPulseAmplitudeIpscrDefault, ...
    @(x) validateattributes(x, {'numeric'}, {'vector'}));
addParameter(iP, 'CurrentPulseAmplitudeCpr', currentPulseAmplitudeCprDefault, ...
    @(x) validateattributes(x, {'numeric'}, {'vector'}));
addParameter(iP, 'GababAmp', gababAmpDefault, ...
    @(x) validateattributes(x, {'numeric'}, {'2d'}));
addParameter(iP, 'GababTrise', gababTriseDefault, ...
    @(x) validateattributes(x, {'numeric'}, {'2d'}));
addParameter(iP, 'GababTfallFast', gababTfallFastDefault, ...
    @(x) validateattributes(x, {'numeric'}, {'2d'}));
addParameter(iP, 'GababTfallSlow', gababTfallSlowDefault, ...
    @(x) validateattributes(x, {'numeric'}, {'2d'}));
addParameter(iP, 'GababWeight', gababWeightDefault, ...
    @(x) validateattributes(x, {'numeric'}, {'2d'}));
addParameter(iP, 'HoldCurrentIpscr', holdCurrentIpscrDefault, ...
    @(x) validateattributes(x, {'numeric'}, {'vector'}));
addParameter(iP, 'HoldCurrentCpr', holdCurrentCprDefault, ...
    @(x) validateattributes(x, {'numeric'}, {'vector'}));
addParameter(iP, 'HoldCurrentNoiseIpscr', holdCurrentNoiseIpscrDefault, ...
    @(x) validateattributes(x, {'numeric'}, {'vector'}));
addParameter(iP, 'HoldCurrentNoiseCpr', holdCurrentNoiseCprDefault, ...
    @(x) validateattributes(x, {'numeric'}, {'vector'}));
addParameter(iP, 'RowConditionsIpscr', rowConditionsIpscrDefault, ...
    @(x) validateattributes(x, {'numeric'}, {'2d'}));
addParameter(iP, 'RowConditionsCpr', rowConditionsCprDefault, ...
    @(x) validateattributes(x, {'numeric'}, {'2d'}));
addParameter(iP, 'FitWindowCpr', fitWindowCprDefault, ...
    @(x) validateattributes(x, {'numeric'}, {'vector', 'numel', 2}));
addParameter(iP, 'FitWindowIpscr', fitWindowIpscrDefault, ...
    @(x) validateattributes(x, {'numeric'}, {'vector', 'numel', 2}));
addParameter(iP, 'BaseWindowCpr', baseWindowCprDefault, ...
    @(x) validateattributes(x, {'numeric'}, {'vector', 'numel', 2}));
addParameter(iP, 'BaseWindowIpscr', baseWindowIpscrDefault, ...
    @(x) validateattributes(x, {'numeric'}, {'vector', 'numel', 2}));
addParameter(iP, 'BaseNoiseCpr', baseNoiseCprDefault, ...
    @(x) validateattributes(x, {'numeric'}, {'vector'}));
addParameter(iP, 'BaseNoiseIpscr', baseNoiseIpscrDefault, ...
    @(x) validateattributes(x, {'numeric'}, {'vector'}));
addParameter(iP, 'SweepWeightsCpr', sweepWeightsCprDefault, ...
    @(x) validateattributes(x, {'numeric'}, {'vector'}));
addParameter(iP, 'SweepWeightsIpscr', sweepWeightsIpscrDefault, ...
    @(x) validateattributes(x, {'numeric'}, {'vector'}));
addParameter(iP, 'LtsFeatureWeights', ltsFeatureWeightsDefault, ...
    @(x) assert(isnumericvector(x), 'LtsFeatureWeights must be a numeric vector!'));
addParameter(iP, 'LtsExistError', ltsExistErrorDefault, ...
    @(x) assert(isnumericvector(x), 'LtsExistError must be a numeric vector!'));
addParameter(iP, 'Lts2SweepErrorRatio', lts2SweepErrorRatioDefault, ...
    @(x) assert(isnumericvector(x), 'InitLtsError must be a numeric vector!'));

% Read from the Input Parser
parse(iP, neuronParamsTable, varargin{:});
hFig = iP.Results.HFig;
simMode = validatestring(iP.Results.SimMode, validSimModes);
nSweepsUser = iP.Results.NSweeps;
prefix = iP.Results.Prefix;
outFolder = iP.Results.OutFolder;
fileBase = iP.Results.FileBase;
debugFlag = iP.Results.DebugFlag;
customHoldCurrentFlag = iP.Results.CustomHoldCurrentFlag;
onHpcFlag = iP.Results.OnHpcFlag;
generateDataFlag = iP.Results.GenerateDataFlag;
averageCprFlag = iP.Results.AverageCprFlag;
bootstrapCprFlag = iP.Results.BootstrapCprFlag;
normalize2InitErrFlag = iP.Results.Normalize2InitErrFlag;
saveParamsFlag = iP.Results.SaveParamsFlag;
saveSimCmdsFlag = iP.Results.SaveSimCmdsFlag;
saveStdOutFlag = iP.Results.SaveStdOutFlag;
saveSimOutFlag = iP.Results.SaveSimOutFlag;
saveLtsInfoFlag = iP.Results.SaveLtsInfoFlag;
saveLtsStatsFlag = iP.Results.SaveLtsStatsFlag;
plotIndividualFlag = iP.Results.PlotIndividualFlag;
plotResidualsFlag = iP.Results.PlotResidualsFlag;
plotOverlappedFlag = iP.Results.PlotOverlappedFlag;
plotConductanceFlag = iP.Results.PlotConductanceFlag;
plotCurrentFlag = iP.Results.PlotCurrentFlag;
plotIpeakFlag = iP.Results.PlotIpeakFlag;
plotLtsFlag = iP.Results.PlotLtsFlag;
plotStatisticsFlag = iP.Results.PlotStatisticsFlag;
plotSwpWeightsFlag = iP.Results.PlotSwpWeightsFlag;
plotMarkFlag = iP.Results.PlotMarkFlag;
showSweepsFlag = iP.Results.ShowSweepsFlag;
jitterFlag = iP.Results.JitterFlag;
grouping = iP.Results.Grouping;
cprWindow = iP.Results.CprWindow;
ipscTime = iP.Results.IpscTime;
ipscPeakWindow = iP.Results.IpscPeakWindow;
ipscrWindow = iP.Results.IpscrWindow;
outFilePath = iP.Results.OutFilePath;
tstop = iP.Results.Tstop;
realDataIpscr = iP.Results.RealDataIpscr;
realDataCpr = iP.Results.RealDataCpr;
holdPotentialIpscr = iP.Results.HoldPotentialIpscr;
holdPotentialCpr = iP.Results.HoldPotentialCpr;
currentPulseAmplitudeIpscr = iP.Results.CurrentPulseAmplitudeIpscr;
currentPulseAmplitudeCpr = iP.Results.CurrentPulseAmplitudeCpr;
gababAmp = iP.Results.GababAmp;
gababTrise = iP.Results.GababTrise;
gababTfallFast = iP.Results.GababTfallFast;
gababTfallSlow = iP.Results.GababTfallSlow;
gababWeight = iP.Results.GababWeight;
holdCurrentIpscr = iP.Results.HoldCurrentIpscr;
holdCurrentCpr = iP.Results.HoldCurrentCpr;
holdCurrentNoiseIpscr = iP.Results.HoldCurrentNoiseIpscr;
holdCurrentNoiseCpr = iP.Results.HoldCurrentNoiseCpr;
rowConditionsIpscr = iP.Results.RowConditionsIpscr;
rowConditionsCpr = iP.Results.RowConditionsCpr;
fitWindowCpr = iP.Results.FitWindowCpr;
fitWindowIpscr = iP.Results.FitWindowIpscr;
baseWindowCpr = iP.Results.BaseWindowCpr;
baseWindowIpscr = iP.Results.BaseWindowIpscr;
baseNoiseCpr = iP.Results.BaseNoiseCpr;
baseNoiseIpscr = iP.Results.BaseNoiseIpscr;
sweepWeightsCpr = iP.Results.SweepWeightsCpr;
sweepWeightsIpscr = iP.Results.SweepWeightsIpscr;
ltsFeatureWeights = iP.Results.LtsFeatureWeights;
ltsExistError = iP.Results.LtsExistError;
lts2SweepErrorRatio = iP.Results.Lts2SweepErrorRatio;

%% Preparation
% Initialize outputs
errorStruct = struct;
hFig = struct;
simData = [];

% Decide on simulation-mode-dependent variables
if strcmpi(simMode, 'passive')
    realData = realDataCpr;
    currentPulseAmplitude = currentPulseAmplitudeCpr;
    holdPotential = holdPotentialCpr;
    holdCurrent = holdCurrentCpr;
    holdCurrentNoise = holdCurrentNoiseCpr;
    rowConditions = rowConditionsCpr;
    fitWindow = fitWindowCpr;
    baseWindow = baseWindowCpr;
    baseNoise = baseNoiseCpr;
    sweepWeights = sweepWeightsCpr;
    errorMode = 'SweepOnly';
elseif strcmpi(simMode, 'active')
    realData = realDataIpscr;
    currentPulseAmplitude = currentPulseAmplitudeIpscr;
    holdPotential = holdPotentialIpscr;
    holdCurrent = holdCurrentIpscr;
    holdCurrentNoise = holdCurrentNoiseIpscr;
    rowConditions = rowConditionsIpscr;
    fitWindow = fitWindowIpscr;
    baseWindow = baseWindowIpscr;
    baseNoise = baseNoiseIpscr;
    sweepWeights = sweepWeightsIpscr;
    errorMode = 'Sweep&LTS';
end

% Decide whether to plot anything
if plotOverlappedFlag || plotConductanceFlag || ...
        plotCurrentFlag || plotIndividualFlag || plotResidualsFlag
    plotFlag = true;
else
    plotFlag = false;
end

% Decide on the number of sweeps to run and compare
nSweeps = decide_on_nSweeps(realData, nSweepsUser);

% Create file bases if not provided
fileBase = decide_on_filebases(fileBase, nSweeps);

% Decide on x-axis limits for plotting
if plotFlag
    xLimits = decide_on_xlimits(fitWindow, baseWindow, simMode, plotMarkFlag);
end

% Decide on figure numbers
if showSweepsFlag
    figNumberIndividual = 104;
else
    figNumberIndividual = [];
end

% Decide on rowConditions and nRows
[rowConditions, nRows] = ...
    decide_on_row_conditions(rowConditions, nSweeps, maxRowsWithOneOnly);

% Decide on the colors for each row in the plots
colorMapOverlapped = create_colormap(nRows);
colorMapIndividual = decide_on_colormap('r', nRows);

% Create output file paths if not provided
if strcmpi(outFilePath, 'auto')
    outFilePath = create_simulation_output_filenames(nSweeps, ...
                            'OutFolder', outFolder, 'Prefix', prefix);
end

% Create a table of simulation parameters
simParamsTable = m3ha_neuron_create_simulation_params(neuronParamsTable, ...
                        'Prefix', prefix, 'OutFolder', outFolder, ...
                        'SaveParamsFlag', saveParamsFlag, ...
                        'JitterFlag', jitterFlag, ...
                        'CprWindow', cprWindow, 'IpscrWindow', ipscrWindow, ...
                        'NSims', nSweeps, 'SimMode', simMode, ...
                        'OutFilePath', outFilePath, 'Tstop', tstop, ...
                        'HoldPotential', holdPotential, ...
                        'CurrentPulseAmplitude', currentPulseAmplitude, ...
                        'GababAmp', gababAmp, 'GababTrise', gababTrise, ...
                        'GababTfallFast', gababTfallFast, ...
                        'GababTfallSlow', gababTfallSlow, ...
                        'GababWeight', gababWeight, ...
                        'CustomHoldCurrentFlag', customHoldCurrentFlag, ...
                        'HoldCurrent', holdCurrent, ...
                        'HoldCurrentNoise', holdCurrentNoise);

% Create simulation commands to be read by NEURON
simCommands = m3ha_neuron_create_TC_commands(simParamsTable, ...
                        'Prefix', prefix, 'OutFolder', outFolder, ...
                        'SaveSimCmdsFlag', saveSimCmdsFlag);

% Extract vectors from recorded data
%   Note: these will be empty if realData not provided
[tVecs, vVecsRec, iVecsRec] = ...
    extract_columns(realData, [TIME_COL_REC, VOLT_COL_REC, CURR_COL_REC]);

% Compute baseline noise and sweep weights if not provided
[~, ~, baseNoise, sweepWeights] = ...
    compute_default_sweep_info(tVecs, vVecsRec, ...
            'BaseWindow', baseWindow, 'BaseNoise', baseNoise, ...
            'SweepWeights', sweepWeights);

%% Run NEURON
% Run NEURON with the hocfile and attached simulation commands
output = run_neuron(hocFile, 'SimCommands', simCommands, ...
                    'Prefix', prefix, 'OutFolder', outFolder, ...
                    'DebugFlag', debugFlag, 'OnHpcFlag', onHpcFlag, ...
                    'SaveStdOutFlag', saveStdOutFlag);

% Check if there are errors
if any(output.hasError)
    fprintf('Simulations ran into error!\n');
    return
end
                
%% TODO: Break the function here into two

%% Analyze results
% Print to standard output
if verbose
    fprintf('Extracting simulation results ... \n');
end

% Create an experiment identifier
expStr = prefix;

% Create an experiment identifier for title
expStrForTitle = strrep(expStr, '_', '\_');

% Load .out files created by NEURON
simDataOrig = load_neuron_outputs('FileNames', outFilePath, ...
                                'RemoveAfterLoad', ~saveSimOutFlag);

% If recorded data provided (tVecs not empty at this point),
%   interpolate simulated data to match the time points of recorded data
% Note: This is necessary because CVODE (variable time step method) 
%       is applied in NEURON
if ~isempty(tVecs)
    simData = cellfun(@(x, y) match_time_points(x, y), ...
                        simDataOrig, tVecs, 'UniformOutput', false);
else
    simData = simDataOrig;
end

% Extract vectors from simulated data
%   Note: these are arrays with 25 columns
if strcmpi(simMode, 'passive')
    [tVecs, vVecsSim, iVecsSim, vVecsDend1, vVecsDend2] = ...
        extract_columns(simData, [TIME_COL_SIM, VOLT_COL_SIM, ...
                        IEXT_COL_SIM, DEND1_COL_SIM, DEND2_COL_SIM]);
elseif strcmpi(simMode, 'active')
    [tVecs, vVecsSim, gVecsSim, iVecsSim, icaVecsSim, ...
            itmVecsSim, itminfVecsSim, ithVecsSim, ithinfVecsSim, ...
            ihVecsSim, ihmVecsSim, ikaVecsSim, iam1VecsSim, iah1VecsSim, ...
            iam2VecsSim, iah2VecsSim, ikkirVecsSim, ikirmVecsSim, ...
            inapnaVecsSim, inapmVecsSim, inaphVecsSim] = ...
        extract_columns(simData, [TIME_COL_SIM, VOLT_COL_SIM, ...
                        GGABAB_COL_SIM, IEXT_COL_SIM, ...
                        ICA_COL_SIM, ITM_COL_SIM, ITMINF_COL_SIM, ...
                        ITH_COL_SIM, ITHINF_COL_SIM, ...
                        IH_COL_SIM, IHM_COL_SIM, ...
                        IKA_COL_SIM, IAM1_COL_SIM, IAH1_COL_SIM, ...
                        IAM2_COL_SIM, IAH2_COL_SIM, ...
                        IKKIR_COL_SIM, IKIRM_COL_SIM, ...
                        INAPNA_COL_SIM, INAPM_COL_SIM, INAPH_COL_SIM]);
end

% If requested, bootstrap both recorded and simulated responses 
%   according to a grouping condition
if bootstrapCprFlag && ~isempty(realData) && strcmpi(simMode, 'passive')
    % Print to standard output
    if verbose
        fprintf('Bootstrap-averaging results ... \n');
    end

    % Decide on the combination method
    if bootstrapCprFlag
        method = 'bootmean';
    else
        error('Code logic error!');
    end

    % Combine both recorded and simulated responses 
    realData = compute_combined_data(realData, method, 'Grouping', grouping, ...
                                    'ColNum', [VOLT_COL_REC, CURR_COL_REC]);
    simData = compute_combined_data(simData, method, 'Grouping', grouping, ...
                                    'ColNum', [VOLT_COL_SIM, IEXT_COL_SIM]);

    % Re-extract columns
    [vVecsRec, iVecsRec] = ...
        extract_columns(realData, [VOLT_COL_REC, CURR_COL_REC]);
    if strcmpi(simMode, 'passive')
        [tVecs, vVecsSim, iVecsSim, vVecsDend1, vVecsDend2] = ...
            extract_columns(simData, [TIME_COL_SIM, VOLT_COL_SIM, ...
                            IEXT_COL_SIM, DEND1_COL_SIM, DEND2_COL_SIM]);
    elseif strcmpi(simMode, 'active')
        [tVecs, vVecsSim, gVecsSim, iVecsSim, icaVecsSim, ...
                itmVecsSim, itminfVecsSim, ithVecsSim, ithinfVecsSim, ...
                ihVecsSim, ihmVecsSim, ikaVecsSim, iam1VecsSim, iah1VecsSim, ...
                iam2VecsSim, iah2VecsSim, ikkirVecsSim, ikirmVecsSim, ...
                inapnaVecsSim, inapmVecsSim, inaphVecsSim] = ...
            extract_columns(simData, [TIME_COL_SIM, VOLT_COL_SIM, ...
                            GGABAB_COL_SIM, IEXT_COL_SIM, ...
                            ICA_COL_SIM, ITM_COL_SIM, ITMINF_COL_SIM, ...
                            ITH_COL_SIM, ITHINF_COL_SIM, ...
                            IH_COL_SIM, IHM_COL_SIM, ...
                            IKA_COL_SIM, IAM1_COL_SIM, IAH1_COL_SIM, ...
                            IAM2_COL_SIM, IAH2_COL_SIM, ...
                            IKKIR_COL_SIM, IKIRM_COL_SIM, ...
                            INAPNA_COL_SIM, INAPM_COL_SIM, INAPH_COL_SIM]);
    end

    % Re-compute number of sweeps
    nSweeps = numel(realData);

    % Re-compute baseline noise and sweep weights
    [~, ~, baseNoise, sweepWeights] = ...
        compute_default_sweep_info(tVecs, vVecsRec, ...
                                    'BaseWindow', baseWindow);
end

% Analyze the responses and compare
if generateDataFlag
    % Print to standard output
    if verbose
        fprintf('Analyzing responses ... \n');
    end

    % Compute the sampling interval
    siMs = compute_sampling_interval(tVecs);

    % Decide on spreadsheet names
    featuresFile = fullfile(outFolder, [expStr, '_features.csv']);
    testResultsFile = fullfile(outFolder, [expStr, '_test_results.csv']);

    % Parse the simulated responses
    featuresSim = analyze_response(vVecsSim, iVecsSim, siMs, simMode, ...
                                    'simulated', ipscTime, ipscpWindow);

    % Parse the recorded responses
    if ~isempty(realData)
        featuresRec = analyze_response(vVecsRec, iVecsRec, siMs, simMode, ...
                                        'recorded', ipscTime, ipscpWindow);

        % Combine the features tables
        featuresTable = vertcat(featuresSim, featuresRec);
    else
        featuresTable = featuresSim;
    end

    % Save the results
    writetable(featuresTable, featuresFile);

    % Print to standard output
    if verbose
        fprintf('Comparing simulated versus recorded responses ... \n');
    end

    % Do the appropriate comparison test
    if strcmpi(simMode, 'passive')
        featuresToCompare = {'steadyAmplitude', 'tauSlow', 'tauFast'};
    elseif strcmpi(simMode, 'active')
        featuresToCompare = {'peakProm', 'peakWidth', ...
                                'peakTime', 'spikesPerPeak'};
    end

    % Test the difference of features between dataType
    testResults = test_var_difference(featuresTable, featuresToCompare, ...
                                'dataType', 'SheetName', testResultsFile, ...
                                'Prefix', expStr, 'OutFolder', outFolder);
end

% If requested, combine both recorded and simulated responses 
%   according to a grouping condition
if averageCprFlag && ~isempty(realData) && strcmpi(simMode, 'passive')
    % Decide on the combination method
    if averageCprFlag
        method = 'mean';
    else
        error('Code logic error!');
    end

    % Combine both recorded and simulated responses 
    realData = compute_combined_data(realData, method, 'Grouping', grouping, ...
                                    'ColNum', [VOLT_COL_REC, CURR_COL_REC]);
    simData = compute_combined_data(simData, method, 'Grouping', grouping, ...
                                    'ColNum', [VOLT_COL_SIM, IEXT_COL_SIM]);

    % Re-extract columns
    [vVecsRec, iVecsRec] = ...
        extract_columns(realData, [VOLT_COL_REC, CURR_COL_REC]);
    if strcmpi(simMode, 'passive')
        [tVecs, vVecsSim, iVecsSim, vVecsDend1, vVecsDend2] = ...
            extract_columns(simData, [TIME_COL_SIM, VOLT_COL_SIM, ...
                            IEXT_COL_SIM, DEND1_COL_SIM, DEND2_COL_SIM]);
    elseif strcmpi(simMode, 'active')
        [tVecs, vVecsSim, gVecsSim, iVecsSim, icaVecsSim, ...
                itmVecsSim, itminfVecsSim, ithVecsSim, ithinfVecsSim, ...
                ihVecsSim, ihmVecsSim, ikaVecsSim, iam1VecsSim, iah1VecsSim, ...
                iam2VecsSim, iah2VecsSim, ikkirVecsSim, ikirmVecsSim, ...
                inapnaVecsSim, inapmVecsSim, inaphVecsSim] = ...
            extract_columns(simData, [TIME_COL_SIM, VOLT_COL_SIM, ...
                            GGABAB_COL_SIM, IEXT_COL_SIM, ...
                            ICA_COL_SIM, ITM_COL_SIM, ITMINF_COL_SIM, ...
                            ITH_COL_SIM, ITHINF_COL_SIM, ...
                            IH_COL_SIM, IHM_COL_SIM, ...
                            IKA_COL_SIM, IAM1_COL_SIM, IAH1_COL_SIM, ...
                            IAM2_COL_SIM, IAH2_COL_SIM, ...
                            IKKIR_COL_SIM, IKIRM_COL_SIM, ...
                            INAPNA_COL_SIM, INAPM_COL_SIM, INAPH_COL_SIM]);
    end

    % Re-compute number of sweeps
    nSweeps = numel(realData);

    % Re-compute baseline noise and sweep weights
    [~, ~, baseNoise, sweepWeights] = ...
        compute_default_sweep_info(tVecs, vVecsRec, ...
                                    'BaseWindow', baseWindow);
end

% Compare with recorded data
if ~isempty(realData)
    % Calculate voltage residuals (simulated - recorded)
    residuals = compute_residuals(vVecsSim, vVecsRec);

    % TODO: Fix this when normalize2InitErrFlag is true
    %       initSwpError needs to be read from the previous errorStruct somehow
    %       initLtsError needs to be read from the previous errorStruct somehow
    initSwpError = NaN;
    initLtsError = NaN;
    if normalize2InitErrFlag
        error('initSwpError needs to be fixed first!')
    end

    % Calculate errors (sweep errors, LTS errors, etc.)
    errorStruct = compute_single_neuron_errors(vVecsSim, vVecsRec, ...
                    'ErrorMode', errorMode, 'TimeVecs', tVecs, ...
                    'IvecsSim', iVecsSim, 'IvecsReal', iVecsRec, ...
                    'FitWindow', fitWindow, 'BaseWindow', baseWindow, ...
                    'BaseNoise', baseNoise, 'SweepWeights', sweepWeights, ...
                    'LtsFeatureWeights', ltsFeatureWeights, ...
                    'LtsExistError', ltsExistError, ...
                    'Lts2SweepErrorRatio', lts2SweepErrorRatio, ...
                    'NormalizeError', normalize2InitErrFlag, ...
                    'InitSwpError', initSwpError, ...
                    'InitLtsError', initLtsError, ...
                    'IpscTime', ipscTime, 'IpscPeakWindow', ipscPeakWindow, ...
                    'OutFolder', outFolder, 'FileBase', fileBase, ...
                    'SaveLtsInfoFlag', saveLtsInfoFlag, ...
                    'SaveLtsStatsFlag', saveLtsStatsFlag, ...
                    'PlotIpeakFlag', plotIpeakFlag, ...
                    'PlotLtsFlag', plotLtsFlag, ...
                    'PlotStatisticsFlag', plotStatisticsFlag);


    % Extract just the sweep errors
    swpErrors = errorStruct.swpErrors;
else
    residuals = [];
    errorStruct = struct;
    swpErrors = [];
end

%% Plot figures
if plotFlag
    % Print message
    if strcmpi(simMode, 'passive')
        fprintf('UPDATING current pulse response figures for %s ...\n', prefix);
    elseif strcmpi(simMode, 'active')
        fprintf('UPDATING GABAB IPSC response figures for %s ...\n', prefix);
    end

    % Find the indices of the x-axis limit endpoints
    endPointsForPlots = find_window_endpoints(xLimits, tVecs);

    % Prepare vectors for plotting
    if strcmpi(simMode, 'passive')
        [tVecs, vVecsSim, vVecsRec, residuals, ...
            iVecsSim, vVecsDend1, vVecsDend2] = ...
            argfun(@(x) prepare_for_plotting(x, endPointsForPlots), ...
                    tVecs, vVecsSim, vVecsRec, residuals, ...
                    iVecsSim, vVecsDend1, vVecsDend2);
    elseif strcmpi(simMode, 'active')
        [tVecs, residuals, vVecsRec, vVecsSim, gVecsSim, iVecsSim, ...
            icaVecsSim, itmVecsSim, itminfVecsSim, ...
            ithVecsSim, ithinfVecsSim, ihVecsSim, ihmVecsSim, ...
            ikaVecsSim, iam1VecsSim, iah1VecsSim, ...
            iam2VecsSim, iah2VecsSim, ikkirVecsSim, ikirmVecsSim, ...
            inapnaVecsSim, inapmVecsSim, inaphVecsSim] = ...
            argfun(@(x) prepare_for_plotting(x, endPointsForPlots), ...
                    tVecs, residuals, vVecsRec, vVecsSim, gVecsSim, iVecsSim, ...
                    icaVecsSim, itmVecsSim, itminfVecsSim, ...
                    ithVecsSim, ithinfVecsSim, ihVecsSim, ihmVecsSim, ...
                    ikaVecsSim, iam1VecsSim, iah1VecsSim, ...
                    iam2VecsSim, iah2VecsSim, ikkirVecsSim, ikirmVecsSim, ...
                    inapnaVecsSim, inapmVecsSim, inaphVecsSim);
    end

    % Plot individual simulated traces against recorded traces
    if plotIndividualFlag
        % Print to standard output
        fprintf('Plotting figure of individual voltage traces for %s ...\n', ...
                expStr);

        % Decide on figure title and file name
        figTitle = sprintf('All traces for Experiment %s', expStrForTitle);
        figName = fullfile(outFolder, [expStr, '_individual.png']);

        % Plot the individual traces
        hFig.individual = ...
            m3ha_plot_individual_traces(tVecs, vVecsSim, ...
                    'DataToCompare', vVecsRec, 'PlotMode', 'parallel', ...
                    'SubplotOrder', 'bycolor', 'ColorMode', 'byRow', ...
                    'ColorMap', colorMapIndividual, ...
                    'XLimits', xLimits, 'LinkAxesOption', 'xy', ...
                    'FitWindow', fitWindow, 'BaseWindow', baseWindow, ...
                    'BaseNoise', baseNoise, 'SweepErrors', swpErrors, ...
                    'FigTitle', figTitle, 'FigName', figName, ...
                    'FigNumber', figNumberIndividual, ...
                    'PlotSwpWeightsFlag', plotSwpWeightsFlag);
    end
    
    % Plot residuals
    if plotResidualsFlag
        % Print to standard output
        fprintf('Plotting figure of residual traces for %s ...\n', ...
                expStr);

        % Decide on figure title and file name
        figTitle = sprintf('Residuals for Experiment %s', expStrForTitle);
        figName = fullfile(outFolder, [expStr, '_residuals.png']);

        % Plot the individual traces
        hFig.residuals = ...
            m3ha_plot_individual_traces(tVecs, residuals, ...
                    'PlotMode', 'residuals', ...
                    'SubplotOrder', 'bycolor', 'ColorMode', 'byRow', ...
                    'ColorMap', colorMapIndividual, ...
                    'XLimits', xLimits, 'LinkAxesOption', 'xy', ...
                    'FitWindow', fitWindow, 'BaseWindow', baseWindow, ...
                    'BaseNoise', baseNoise, 'SweepErrors', swpErrors, ...
                    'FigTitle', figTitle, 'FigName', figName, ...
                    'FigNumber', figNumberIndividual, ...
                    'PlotSwpWeightsFlag', plotSwpWeightsFlag);
    end    

    % Plot different types of traces with different conditions overlapped
    if plotOverlappedFlag
        % Print to standard output
        fprintf('Plotting figure of overlapped traces for %s ...\n', ...
                expStr);

        % Compute processed data
        if strcmpi(simMode, 'active')
            itm2hVecsSim = (itmVecsSim .^ 2) .* ithVecsSim;
            itminf2hinfVecsSim = (itminfVecsSim .^ 2) .* ithinfVecsSim;
        end

        % Select data to plot
        if strcmpi(simMode, 'passive')
            dataForOverlapped = {vVecsSim; vVecsDend1; vVecsDend2; iVecsSim};
        elseif strcmpi(simMode, 'active')
            dataForOverlapped = {vVecsSim; gVecsSim; iVecsSim; ...
                    icaVecsSim; itm2hVecsSim; itminf2hinfVecsSim; ...
                    itmVecsSim; itminfVecsSim; ithVecsSim; ithinfVecsSim; ...
                    ihVecsSim; ihmVecsSim; ...
                    ikaVecsSim; iam1VecsSim; iah1VecsSim; ...
                    iam2VecsSim; iah2VecsSim; ikkirVecsSim; ikirmVecsSim; ...
                    inapnaVecsSim; inapmVecsSim; inaphVecsSim};
        end


        % Construct matching y labels
        if strcmpi(simMode, 'passive')
            yLabelsOverlapped = {'V_{soma} (mV)'; 'V_{dend1} (mV)'; ...
                                'V_{dend2} (mV)'; 'I_{stim} (nA)'};
        elseif strcmpi(simMode, 'active')
            yLabelsOverlapped = {'V_{soma} (mV)'; 'g_{GABA_B} (uS)'; ...
                    'I_{stim} (nA)'; 'I_{Ca} (mA/cm^2)'; ...
                    'm^2h_{T}'; 'm_{\infty}^2h_{\infty,T}'; ...
                    'm_{T}'; 'm_{\infty,T}'; 'h_{T}'; 'h_{\infty,T}'; ...
                    'I_{h} (mA/cm^2)'; 'm_{h}'; 'I_{A} (mA/cm^2)'; ...
                    'm_{1,A}'; 'h_{1,A}'; 'm_{2,A}'; 'h_{2,A}'; ...
                    'I_{Kir} (mA/cm^2)'; 'm_{\infty,Kir}'; ...
                    'I_{NaP} (mA/cm^2)'; 'm_{\infty,NaP}'; 'h_{NaP}'};
        end

        % Add recorded voltage on the top if exists
        if ~isempty(vVecsRec)
            dataForOverlapped = [{vVecsRec}; dataForOverlapped];
            yLabelsOverlapped = [{'V_{rec} (mV)'}; yLabelsOverlapped];
        end
            
        % Construct matching time vectors
        tVecsForOverlapped = repmat({tVecs}, size(dataForOverlapped));

        % Expand the colormap if necessary
        if nSweeps > nRows
            colorMap = decide_on_colormap([], 4);
            nColumns = ceil(nSweeps / nRows);
            nSlots = nColumns * nRows;
            colorMap = reshape(repmat(reshape(colorMap, 1, []), ...
                                nColumns, 1), nSlots, 3);
        end

        % Decide on figure title and file name
        figTitle = sprintf('Overlapped traces for Experiment %s', ...
                            expStrForTitle);
        figName = fullfile(outFolder, [expStr, '_overlapped.png']);

        % Plot overlapped traces
        % TODO: Integrate into m3ha_plot_simulated_traces.m
        lineWidth = 1;
        nSubPlots = numel(yLabelsOverlapped);
        figHandle = set_figure_properties('AlwaysNew', true, ...
                        'FigExpansion', [1, nSubPlots/4]);
        hFig.overlapped = ...
            plot_traces(tVecsForOverlapped, dataForOverlapped, ...
                        'Verbose', false, 'PlotMode', 'parallel', ...
                        'SubplotOrder', 'list', 'ColorMode', 'byTraceInPlot', ...
                        'LegendLocation', 'suppress', ...
                        'ColorMap', colorMapOverlapped, ...
                        'XLimits', xLimits, ...
                        'LinkAxesOption', 'x', 'XUnits', 'ms', ...
                        'YLabel', yLabelsOverlapped, ...
                        'FigTitle', figTitle, 'FigHandle', figHandle, ...
                        'FigName', figName, 'LineWidth', lineWidth);

        % handles = m3ha_plot_simulated_traces('Directory', outFolder, ...
        %                                     'ColorMap', colorMapOverlapped);
    end

    %% TODO TODO
    % if plotConductanceFlag
    %     hFig.conductance = ...
    %         plot_conductance_traces(realData, simData, outparams, hFig, nSweeps, colorMap, ncg, npercg, xlimitsMax);
    % end
    % if plotCurrentFlag
    %     hFig.current = ...
    %         plot_current_traces(realData, simData, outparams, hFig, nSweeps, colorMap, ncg, npercg, xlimitsMax);
    % end

    % Print an empty line
    fprintf('\n');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function nSweeps = decide_on_nSweeps (realData, nSweepsUser)
%% Returns the number of sweeps to run and compare

if ~isempty(realData)
    % Simulate as many sweeps as recorded data
    nSweeps = numel(realData);

    % Check whether the user provided a different nSweeps
    if ~isempty(nSweepsUser) && nSweepsUser ~= nSweeps
        fprintf('realData provided, so nSweepsUser ignored!\n\n');
    end
elseif ~isempty(nSweepsUser)
    nSweeps = nSweepsUser;
else
    nSweeps = 1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [rowConditions, nRows] = ...
                decide_on_row_conditions (rowConditions, nSweeps, ...
                                            maxRowsWithOneOnly)
%% Decide on rowConditions and nRows

% Place each sweep on its own row if rowConditions not provided
if isempty(rowConditions)
    % Decide on the number of rows
    if nSweeps <= maxRowsWithOneOnly
        nRows = nSweeps;
    else
        nRows = floor(sqrt(nSweeps));
    end

    % Label the rows 1, 2, ..., nRows
    rowConditions = transpose(1:nRows);
else
    % Get the number of rows for plotting
    nRows = size(rowConditions, 1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function xLimits = decide_on_xlimits (fitWindow, baseWindow, simMode, plotMarkFlag)
%% Decide on x-axis limits

% Put all window endpoints together
allEndpoints = [baseWindow, fitWindow];
allEndpoints = allEndpoints(:);

if plotMarkFlag && strcmpi(simMode, 'active')
    xLimits = [2800, 4500];
else
    xLimits = [min(allEndpoints), max(allEndpoints)];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function vecs = prepare_for_plotting(vecs, endPointsForPlots)
%% Prepare vectors for plotting

% Restrict vectors to xLimits to save time on plotting
vecs = extract_subvectors(vecs, 'Endpoints', endPointsForPlots);

% Combine vectors into matrices
vecs = force_matrix(vecs, 'AlignMethod', 'leftAdjustPad');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function featuresTable = analyze_response (vVecs, iVecs, siMs, simMode, ...
                                            dataType, ipscTime, ipscPeakWindow)

% Hard-coded parameters
meanVoltageWindow = 0.5;    % width in ms for calculating mean voltage 
                            %   for input resistance calculations

% Parse the response (generate statistics)
if strcmpi(simMode, 'passive')
    % Parse the pulse response
    featuresTable = parse_pulse_response(vVecs, siMs, 'PulseVectors', iVecs, ...
                                'SameAsPulse', true, 'DetectPeak', false, ...
                                'FitResponse', true, ...
                                'MeanValueWindowMs', meanVoltageWindow);
elseif strcmpi(simMode, 'active')
    % Parse the IPSC current
    ipscTable = parse_ipsc(iVecs, siMs, 'StimStartMs', ipscTime, ...
                            'PeakWindowMs', ipscPeakWindow);

    % Extract peak delay
    ipscDelay = ipscTable.peakDelayMs;

    % Parse the LTS response
    featuresTable = parse_lts(vVecs, siMs, 'StimStartMs', ipscTime, ...
                                'MinPeakDelayMs', ipscDelay);
end

% Count the number of rows
nRows = height(featuresTable);

% Add a column for dataType ('simulated' or 'recorded')
featuresTable.dataType = repmat({dataType}, nRows, 1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [err, outparams] = errorcalc(realData, simData, outparams, nSweeps, colorMap, ncg, npercg)
%% Error calculator
%% TODO: Make functions out of this

%% Compare LTS and burst statistics if GABAB IPSC response is simulated
if ~cprflag && findLtsFlag && ltsBurstStatsFlag
    % Save statistics first
    if outparams.saveLtsInfoFlag
        save(fullfile(outFolder, [prefix, '_LTS_info.mat']), ...
            'real_ipeakt', 'real_ltsv', 'real_ltst', ...
            'real_ltsdvdtv', 'real_ltsdvdtt', ...
            'real_pkprom', 'real_pkwidth', 'real_pkclass', ...
            'real_np2der', 'real_spp', 'real_btime', 'real_spb', ...
            'sim_ipeakt', 'sim_ltsv', 'sim_ltst', ...
            'sim_ltsdvdtv', 'sim_ltsdvdtt', ...
            'sim_pkprom', 'sim_pkwidth', 'sim_pkclass', ...
            'sim_np2der', 'sim_spp', 'sim_btime', 'sim_spb', ...
            '-v7.3');
    end
    compute_and_compare_statistics(nSweeps, colorMap, ncg, npercg, ...
        cellID, outparams, plotStatisticsFlag, ...
        real_ipeakt, real_ltsv, real_ltst, real_ltsdvdtv, real_ltsdvdtt, ...
        real_pkprom, real_pkwidth, real_pkclass, real_np2der, real_spp, real_btime, real_spb, ...
        sim_ipeakt, sim_ltsv, sim_ltst, sim_ltsdvdtv, sim_ltsdvdtt, ...
        sim_pkprom, sim_pkwidth, sim_pkclass, sim_np2der, sim_spp, sim_btime, sim_spb);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ltst_all, ltst_mean_real, ltst_mean_sim, ltst_mean_all, ...
    ltst_std_real, ltst_std_sim, ltst_cv_real, ltst_cv_sim, ltst_cv_all, ltst_max_dev_all, ...
    ltsdvdtv_all, ltsdvdtv_mean_real, ltsdvdtv_mean_sim, ltsdvdtv_mean_all, ...
    ltsdvdtv_std_real, ltsdvdtv_std_sim, ltsdvdtv_cv_real, ltsdvdtv_cv_sim, ...
    ltsdvdtv_cv_all, ltsdvdtv_max_dev_all] ...
        = compute_and_compare_statistics(nSweeps, colorMap, ncg, npercg, ...
            cellID, outparams, plotStatisticsFlag, ...
            real_ipeakt, real_ltsv, real_ltst, real_ltsdvdtv, real_ltsdvdtt, ...
            real_pkprom, real_pkwidth, real_pkclass, real_np2der, real_spp, real_btime, real_spb, ...
            sim_ipeakt, sim_ltsv, sim_ltst, sim_ltsdvdtv, sim_ltsdvdtt, ...
            sim_pkprom, sim_pkwidth, sim_pkclass, sim_np2der, sim_spp, sim_btime, sim_spb)
%% Calculate statistics and plot those of simulated data against real data
%% TODO: Make functions out of this

%% Extract from outparams
outFolder = outparams.outFolder;
prefix = outparams.prefix;

%% Compute LTS statistics
ltsp = zeros(ncg, 2);            % LTS probability
ltsv_real = cell(ncg, 1);
ltst_real = cell(ncg, 1);
ltsdvdtv_real = cell(ncg, 1);
ltsdvdtt_real = cell(ncg, 1);
ltsv_sim = cell(ncg, 1);
ltst_sim = cell(ncg, 1);
ltsdvdtv_sim = cell(ncg, 1);
ltsdvdtt_sim = cell(ncg, 1);
both_has_lts_ct = zeros(ncg, 1);
ltst_all = cell(ncg, 1);
ltst_mean_real = zeros(ncg, 1);
ltst_mean_sim = zeros(ncg, 1);
ltst_mean_all = zeros(ncg, 1);
ltst_std_real = zeros(ncg, 1);
ltst_std_sim = zeros(ncg, 1);
ltst_std_all = zeros(ncg, 1);
ltst_cv_real = zeros(ncg, 1);
ltst_cv_sim = zeros(ncg, 1);
ltst_cv_all = zeros(ncg, 1);
ltst_max_dev_all = zeros(ncg, 1);
ltsdvdtv_all = cell(ncg, 1);
ltsdvdtv_mean_real = zeros(ncg, 1);
ltsdvdtv_mean_sim = zeros(ncg, 1);
ltsdvdtv_mean_all = zeros(ncg, 1);
ltsdvdtv_std_real = zeros(ncg, 1);
ltsdvdtv_std_sim = zeros(ncg, 1);
ltsdvdtv_std_all = zeros(ncg, 1);
ltsdvdtv_cv_real = zeros(ncg, 1);
ltsdvdtv_cv_sim = zeros(ncg, 1);
ltsdvdtv_cv_all = zeros(ncg, 1);
ltsdvdtv_max_dev_all = zeros(ncg, 1);
for cgn = 1:ncg            % color group number
    % LTS probability
    ct_real = 0;    % counts sweeps with LTS
    ct_sim = 0;    % counts sweeps with LTS
    for iSwp = 1:nSweeps
        if ceil(iSwp/npercg) == cgn && ~isnan(real_ltst(iSwp))
            ct_real = ct_real + 1;
        end
        if ceil(iSwp/npercg) == cgn && ~isnan(sim_ltst(iSwp))
            ct_sim = ct_sim + 1;
        end
    end
    ltsp(cgn, 1) = ct_real/npercg;
    ltsp(cgn, 2) = ct_sim/npercg;

    % Data for those sweeps that have LTSs both in real and simulated conditions
    ct = 0;         % counts sweeps with LTSs
    for iSwp = 1:nSweeps
        if ceil(iSwp/npercg) == cgn ...
            && ~isnan(real_ltst(iSwp)) && ~isnan(sim_ltst(iSwp))  
            ct = ct + 1;
            ltsv_real{cgn}(1, ct) = real_ltsv(iSwp);
            ltst_real{cgn}(1, ct) = real_ltst(iSwp);
            ltsdvdtv_real{cgn}(1, ct) = real_ltsdvdtv(iSwp);
            ltsdvdtt_real{cgn}(1, ct) = real_ltsdvdtt(iSwp);
            ltsv_sim{cgn}(1, ct) = sim_ltsv(iSwp);
            ltst_sim{cgn}(1, ct) = sim_ltst(iSwp);
            ltsdvdtv_sim{cgn}(1, ct) = sim_ltsdvdtv(iSwp);
            ltsdvdtt_sim{cgn}(1, ct) = sim_ltsdvdtt(iSwp);
        end
    end
    both_has_lts_ct(cgn) = ct;
    if both_has_lts_ct(cgn) > 0
        % LTS peak time data
        ltst_all{cgn} = [ltst_real{cgn} ltst_sim{cgn}];
        ltst_mean_real(cgn) = mean(ltst_real{cgn});
        ltst_mean_sim(cgn) = mean(ltst_sim{cgn});
        ltst_mean_all(cgn) = mean(ltst_all{cgn});
        ltst_std_real(cgn) = std(ltst_real{cgn});
        ltst_std_sim(cgn) = std(ltst_sim{cgn});
        ltst_std_all(cgn) = std([ltst_real{cgn} ltst_sim{cgn}]);
        ltst_cv_real(cgn) = ltst_std_real(cgn)/ltst_mean_real(cgn);
        ltst_cv_sim(cgn) = ltst_std_sim(cgn)/ltst_mean_sim(cgn);
        ltst_cv_all(cgn) = ltst_std_all(cgn)/ltst_mean_all(cgn);
        ltst_max_dev_all(cgn) = max(abs(ltst_all{cgn} - ltst_mean_all(cgn))/ltst_mean_all(cgn));

        % LTS max slope data
        ltsdvdtv_all{cgn} = [ltsdvdtv_real{cgn} ltsdvdtv_sim{cgn}];
        ltsdvdtv_mean_real(cgn) = mean(ltsdvdtv_real{cgn});
        ltsdvdtv_mean_sim(cgn) = mean(ltsdvdtv_sim{cgn});
        ltsdvdtv_mean_all(cgn) = mean(ltsdvdtv_all{cgn});
        ltsdvdtv_std_real(cgn) = std(ltsdvdtv_real{cgn});
        ltsdvdtv_std_sim(cgn) = std(ltsdvdtv_sim{cgn});
        ltsdvdtv_std_all(cgn) = std([ltsdvdtv_real{cgn} ltsdvdtv_sim{cgn}]);
        ltsdvdtv_cv_real(cgn) = ltsdvdtv_std_real(cgn)/ltsdvdtv_mean_real(cgn);
        ltsdvdtv_cv_sim(cgn) = ltsdvdtv_std_sim(cgn)/ltsdvdtv_mean_sim(cgn);
        ltsdvdtv_cv_all(cgn) = ltsdvdtv_std_all(cgn)/ltsdvdtv_mean_all(cgn);
        ltsdvdtv_max_dev_all(cgn) = max(abs(ltsdvdtv_all{cgn} - ltsdvdtv_mean_all(cgn))/ltsdvdtv_mean_all(cgn));
    end
end
if outparams.saveLtsStatsFlag
    save(fullfile(outFolder, [prefix, '_LTS_statistics.mat']), ...
        'ltst_all', 'ltst_mean_real', 'ltst_mean_sim', 'ltst_mean_all', ...
        'ltst_std_real', 'ltst_std_sim', 'ltst_cv_real', 'ltst_cv_sim', 'ltst_cv_all', 'ltst_max_dev_all', ...
        'ltsdvdtv_all', 'ltsdvdtv_mean_real', 'ltsdvdtv_mean_sim', 'ltsdvdtv_mean_all', ...
        'ltsdvdtv_std_real', 'ltsdvdtv_std_sim', 'ltsdvdtv_cv_real', 'ltsdvdtv_cv_sim', ...
        'ltsdvdtv_cv_all', 'ltsdvdtv_max_dev_all', '-v7.3');
end

%% Compute LTS/burst statistics

% Items to compute
statstitle = {'LTS onset time (ms)', 'LTS time jitter (ms)', 'LTS probability', 'Spikes per LTS', ...
        'Burst onset time (ms)', 'Burst time jitter (ms)', 'Burst probability', 'Spikes per burst'};
statsfilename = {'lts_onset_time', 'lts_time_jitter', 'lts_probability', 'spikes_per_lts', ...
                'burst_onset_time', 'burst_time_jitter', 'burst_probability', 'spikes_per_burst'};
pplabel2 = {'Con', 'GAT1', 'GAT3', 'Dual'};

% Initialize stats vectors
all_stats_real = cell(1, length(statstitle));
mean_stats_real = cell(1, length(statstitle));
std_stats_real = cell(1, length(statstitle));
ct_stats_real = cell(1, length(statstitle));
err_stats_real = cell(1, length(statstitle));
highbar_stats_real = cell(1, length(statstitle));
lowbar_stats_real = cell(1, length(statstitle));
all_stats_sim = cell(1, length(statstitle));
mean_stats_sim = cell(1, length(statstitle));
std_stats_sim = cell(1, length(statstitle));
ct_stats_sim = cell(1, length(statstitle));
err_stats_sim = cell(1, length(statstitle));
highbar_stats_sim = cell(1, length(statstitle));
lowbar_stats_sim = cell(1, length(statstitle));
for bi = 1:length(statstitle)
    all_stats_real{bi} = cell(ncg, 1);
    mean_stats_real{bi} = zeros(ncg, 1);
    std_stats_real{bi} = zeros(ncg, 1);
    ct_stats_real{bi} = zeros(ncg, 1);
    err_stats_real{bi} = zeros(ncg, 1);
    highbar_stats_real{bi} = zeros(ncg, 1);
    lowbar_stats_real{bi} = zeros(ncg, 1);

    all_stats_sim{bi} = cell(ncg, 1);
    mean_stats_sim{bi} = zeros(ncg, 1);
    std_stats_sim{bi} = zeros(ncg, 1);
    ct_stats_sim{bi} = zeros(ncg, 1);
    err_stats_sim{bi} = zeros(ncg, 1);
    highbar_stats_sim{bi} = zeros(ncg, 1);
    lowbar_stats_sim{bi} = zeros(ncg, 1);
end

for cgn = 1:ncg            % color group number
    thisp_ind = (cgn - 1) * npercg + (1:npercg);
    [all_stats, mean_stats, std_stats, ct_stats, err_stats, highbar_stats, lowbar_stats] = ...
        ltsburst_statistics(thisp_ind, cellID, real_ltst, real_spp, real_btime, real_spb);
%    [all_stats, mean_stats, std_stats, ct_stats, err_stats, highbar_stats, lowbar_stats] = ...
%        ltsburst_statistics(thisp_ind, cellID, outparams.ltspeaktime, outparams.spikesperpeak, outparams.bursttime, outparams.spikesperburst);
    for bi = 1:length(statstitle)
        all_stats_real{bi}{cgn} = all_stats{bi};
        mean_stats_real{bi}(cgn) = mean_stats(bi);
        std_stats_real{bi}(cgn) = std_stats(bi);
        ct_stats_real{bi}(cgn) = ct_stats(bi);
        err_stats_real{bi}(cgn) = err_stats(bi);
        highbar_stats_real{bi}(cgn) = highbar_stats(bi);
        lowbar_stats_real{bi}(cgn) = lowbar_stats(bi);
    end
    [all_stats, mean_stats, std_stats, ct_stats, err_stats, highbar_stats, lowbar_stats] = ...
        ltsburst_statistics(thisp_ind, cellID, sim_ltst, sim_spp, sim_btime, sim_spb);
    for bi = 1:length(statstitle)
        all_stats_sim{bi}{cgn} = all_stats{bi};
        mean_stats_sim{bi}(cgn) = mean_stats(bi);
        std_stats_sim{bi}(cgn) = std_stats(bi);
        ct_stats_sim{bi}(cgn) = ct_stats(bi);
        err_stats_sim{bi}(cgn) = err_stats(bi);
        highbar_stats_sim{bi}(cgn) = highbar_stats(bi);
        lowbar_stats_sim{bi}(cgn) = lowbar_stats(bi);
    end
end

% Plot statistics if plotStatisticsFlag == 1
if plotStatisticsFlag

    % Plot bar graph comparing LTS probabilities
    fprintf('Plotting bar graph comparing LTS probabilities ...\n');
    if outparams.showStatisticsFlag
        hFig.ltstp_bar = figure(201);
    else
        hFig.ltstp_bar = figure('Visible', 'off');
    end
    set(hFig.ltstp_bar, 'Name', 'Low threshold spike probability');
    clf(hFig.ltstp_bar);
    bar(1:size(colorMap, 1), ltsp);
    legend('Real data', 'Simulated data');
    xlabel('Pharm condition #');
    ylabel('LTS probability');
    title('Low threshold spike probability');
    figName = fullfile(outFolder, [prefix, '_ltstp_bar.png']);
    save_all_figtypes(hFig.ltstp_bar, figName);

    % Plot scatter plot of LTS onset times, don't save yet (axes not fixed)
    fprintf('Plotting scatter plot of LTS onset times ...\n');
    if outparams.showStatisticsFlag
        hFig.ltstcorr = figure(202);
    else
        hFig.ltstcorr = figure('Visible', 'off');
    end
    set(hFig.ltstcorr, 'Name', 'LTS onset times (ms)');
    clf(hFig.ltstcorr);
    for cgn = 1:size(colorMap, 1)            % color group number
        if both_has_lts_ct(cgn) > 0
            if ncg == 4
                subplot(2, 2, cgn); hold on;
                title(['Pharm condition ', num2str(cgn)])
            elseif ncg == 12
                subplot(4, 3, cgn); hold on;
                title(['Pharm condition ', num2str(floor(cgn/3) + 1)])
            end
            xlabel('Real data')
            ylabel('Simulated data')
            plot(ltst_real{cgn}, ltst_sim{cgn}, 'LineStyle', 'none', ...
                'Marker', 'o', 'MarkerEdgeColor', colorMap(cgn, :), 'MarkerFaceColor', colorMap(cgn, :));
        end
    end
    title('Correlation of LTS onset times (ms)')

    % Plot scatter plot of LTS max slopes, don't save yet (axes not fixed)
    fprintf('Plotting scatter plot of LTS max slopes ...\n');
    if outparams.showStatisticsFlag
        hFig.ltsdvdtvcorr = figure(203);
    else
        hFig.ltsdvdtvcorr = figure('Visible', 'off');
    end
    set(hFig.ltsdvdtvcorr, 'Name', 'LTS max slopes (mV/ms)');
    clf(hFig.ltsdvdtvcorr);
    for cgn = 1:size(colorMap, 1)            % color group number
        if both_has_lts_ct(cgn) > 0
            if ncg == 4
                subplot(2, 2, cgn); hold on;
                title(['Pharm condition ', num2str(cgn)])
            elseif ncg == 12
                subplot(4, 3, cgn); hold on;
                title(['Pharm condition ', num2str(floor(cgn/3) + 1)])
            end
            xlabel('Real data')
            ylabel('Simulated data')
            plot(ltsdvdtv_real{cgn}, ltsdvdtv_sim{cgn}, 'LineStyle', 'none', ...
                'Marker', 'o', 'MarkerEdgeColor', colorMap(cgn, :), 'MarkerFaceColor', colorMap(cgn, :));
        end
    end
    title('Correlation of LTS max slopes (mV/ms)')
    

    % Fix axes to make the scales consistent among subplots
    if sum(both_has_lts_ct) ~= 0
        ltst_max_dev_all_max = max(ltst_max_dev_all);
        ltst_std_all_max = max(ltst_std_all);
        if ltst_max_dev_all_max > 3 * ltst_std_all_max
            width = ltst_std_all_max;
        else
            width = ltst_max_dev_all_max;
        end

        % Don't let width be 0
        if width == 0
            width = 0.1;
        end

        set(0, 'CurrentFigure', hFig.ltstcorr);
        for cgn = 1:ncg            % color group number
            if both_has_lts_ct(cgn) > 0
                if ncg == 4
                    subplot(2, 2, cgn);
                elseif ncg == 12
                    subplot(4, 3, cgn);
                end                
                xmin = ltst_mean_all(cgn) * (1 - 1.1 * width);
                xmax = ltst_mean_all(cgn) * (1 + 1.1 * width);
                ymin = xmin;
                ymax = xmax;
                axis([xmin, xmax, ymin, ymax]);
            end
        end
        figName = fullfile(outFolder, [prefix, '_ltstcorr.png']);
        save_all_figtypes(hFig.ltstcorr, figName);

        ltsdvdtv_max_dev_all_max = max(ltsdvdtv_max_dev_all);
        ltsdvdtv_std_all_max = max(ltsdvdtv_std_all);
        if ltsdvdtv_max_dev_all_max > 3 * ltsdvdtv_std_all_max
            width = ltsdvdtv_std_all_max;
        else
            width = ltsdvdtv_max_dev_all_max;
        end

        % Don't let width be 0
        if width == 0
            width = 0.1;
        end

        set(0, 'CurrentFigure' , hFig.ltsdvdtvcorr);
        for cgn = 1:ncg            % color group number
            if both_has_lts_ct(cgn) > 0
                if ncg == 4
                    subplot(2, 2, cgn);
                elseif ncg == 12
                    subplot(4, 3, cgn);
                end                
                xmin = ltsdvdtv_mean_all(cgn) * (1 - 1.1 * width);
                xmax = ltsdvdtv_mean_all(cgn) * (1 + 1.1 * width);
                ymin = xmin;
                ymax = xmax;
                axis([xmin, xmax, ymin, ymax]);
            end
        end
        figName = fullfile(outFolder, [prefix, '_ltsdvdtvcorr.png']);
        save_all_figtypes(hFig.ltsdvdtvcorr, figName);
    end

    %% Create 2D bar graphs for LTS/burst statistics
    ltsburst_stats = cell(1, length(statstitle));    % for parfor
    parfor bi = 1:length(statstitle)
        if outparams.showStatisticsFlag
            ltsburst_stats{bi} = figure(210 + bi);
        else
            ltsburst_stats{bi} = figure('Visible', 'off');
        end
        fprintf('2D bar graph for %s ...\n', statsfilename{bi});
        set(ltsburst_stats{bi}, 'Name', [statsfilename{bi}]);
        clf(ltsburst_stats{bi});

        % Plot means with 95% confidence intervals
        plot_bar([mean_stats_real{bi}, mean_stats_sim{bi}], ...
                    [lowbar_stats_real{bi}, lowbar_stats_sim{bi}], ...
                    [highbar_stats_real{bi}, highbar_stats_sim{bi}], ...
                    'PValues', (1:ncg)', 'PTickLabels', pplabel2, ...
                    'FigHandle', ltsburst_stats{bi});

        if bi == 1
%            ylim([0 2500]);
        elseif bi == 2
%            ylim([0 800]);
        elseif bi == 3
%            ylim([0 1]);
        elseif bi == 4
%            ylim([0 6]);
        end
        legend('Real data', 'Simulated data');
        xlabel('Pharm Condition');
%        ylabel(statstitle{bi});
        title(statstitle{bi});
        figName = fullfile(outFolder, [prefix, '_', statsfilename{bi}]);
%        save_all_figtypes(ltsburst_stats{bi}, figName, {'png', 'fig'});
        save_all_figtypes(ltsburst_stats{bi}, figName, {'png'});
    end

    fprintf('\n');
    hFig.ltsburst_stats = ltsburst_stats;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function hFig = plot_conductance_traces (realData, simData, outparams, hFig, nSweeps, colorMap, ncg, npercg, xlimitsMax)
%% Update figure comparing current traces between real data and simulations
%% TODO: Incorporate into plot_traces.m

% See vMat of singleneuron4compgabab.hoc for simData columns
fprintf('Plotting figure comparing current traces between real data and simulations for %s ...\n', outparams.prefix);
if outparams.showSweepsFlag
    if outparams.cprflag
        hFig.GABABi_comparison = figure(102);
    else
        hFig.GABABi_comparison = figure(112);
    end
else
    hFig.GABABi_comparison = figure('Visible', 'off');
end
set(hFig.GABABi_comparison, 'Name', 'GABAB currents');

% Plot GABAB IPSC current traces from experiments
clf(hFig.GABABi_comparison);
subplot(2,1,1); hold on;
for iSwp = 1:nSweeps  
    cgn = ceil(iSwp/npercg);        % color group number
    plot(realData{iSwp}(:, 1), realData{iSwp}(:, 3), 'Color', colorMap(cgn, :), 'LineStyle', '-');
end
if outparams.cprflag
    title('Current pulses, recorded')        %% TODO: To fix: It's not showing the current pulse!
else
    title('GABAB IPSC currents, recorded')
end
xlim(xlimitsMax);
if nSweeps == 4                % Legend only works if there are exactly 4 sweeps
    legend('Control', 'GAT1 Block', 'GAT3 Block', 'Dual Block')
end
xlabel('Time (ms)')
ylabel('Current (nA)')

% Plot current traces from simulations
subplot(2,1,2); hold on;
for iSwp = 1:nSweeps  
    cgn = ceil(iSwp/npercg);        % color group number
    if outparams.cprflag
        % Plot current pulse traces from simulations
        plot(simData{iSwp}(:, 1), simData{iSwp}(:, 11), 'Color', colorMap(cgn, :), 'LineStyle', '-');
    else
        % Plot GABAB IPSC current traces from simulations
        plot(simData{iSwp}(:, 1), simData{iSwp}(:, 9), 'Color', colorMap(cgn, :), 'LineStyle', '-');
    end
end
if outparams.cprflag
    title('Current pulses, simulated')
else
    title('GABAB IPSC currents, simulated')
end
xlim(xlimitsMax);
if nSweeps == 4                % Legend only works if there are exactly 4 sweeps
    legend('Control', 'GAT1 Block', 'GAT3 Block', 'Dual Block')
end
xlabel('Time (ms)')
ylabel('Current (nA)')
if outparams.cprflag
    figName = fullfile(outparams.outFolder, [outparams.prefix, '_cpi_comparison.png']);
else
    figName = fullfile(outparams.outFolder, [outparams.prefix, '_GABABi_comparison.png']);
end
save_all_figtypes(hFig.GABABi_comparison, figName);
% Copy figure handle so it won't be overwritten
if outparams.cprflag
    hFig.cpr_GABABi_comparison = hFig.GABABi_comparison;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function hFig = plot_current_traces (realData, simData, outparams, hFig, nSweeps, colorMap, ncg, npercg, xlimitsMax)
%% Update figure comparing current traces between real data and simulations
%% TODO: Incorporate into plot_traces.m

% See vMat of singleneuron4compgabab.hoc for simData columns
fprintf('Plotting figure comparing current traces between real data and simulations for %s ...\n', outparams.prefix);
if outparams.showSweepsFlag
    if outparams.cprflag
        hFig.GABABg_comparison = figure(103);
    else
        hFig.GABABg_comparison = figure(113);
    end
else
    hFig.GABABg_comparison = figure('Visible', 'off');
end
set(hFig.GABABg_comparison, 'Name', 'GABAB conductances');
clf(hFig.GABABg_comparison);
subplot(2,1,1); hold on;
for iSwp = 1:nSweeps
    cgn = ceil(iSwp/npercg);        % color group number
    plot(realData{iSwp}(:, 1), realData{iSwp}(:, 4), 'Color', colorMap(cgn, :), 'LineStyle', '-');    
end
if outparams.cprflag
    title('Conductance during current pulse, recorded')
else
    title('GABAB IPSC conductances, recorded')
end
xlim(xlimitsMax);
if nSweeps == 4                % Legend only works if there are exactly 4 sweeps
    legend('Control', 'GAT1 Block', 'GAT3 Block', 'Dual Block')
end
xlabel('Time (ms)')
ylabel('Conductance (uS)')
subplot(2,1,2); hold on;
for iSwp = 1:nSweeps  
    cgn = ceil(iSwp/npercg);        % color group number
    plot(simData{iSwp}(:, 1), simData{iSwp}(:, 10), 'Color', colorMap(cgn, :), 'LineStyle', '-'); % 20160722 GABABg added
end
if outparams.cprflag
    title('Conductance during current pulse, simulated')
else
    title('GABAB IPSC conductances, simulated')
end
xlim(xlimitsMax);
if nSweeps == 4                % Legend only works if there are exactly 4 sweeps
    legend('Control', 'GAT1 Block', 'GAT3 Block', 'Dual Block')
end
xlabel('Time (ms)')
ylabel('Conductance (uS)')
if outparams.cprflag
    figName = fullfile(outparams.outFolder, [outparams.prefix, '_cpg_comparison.png']);
else
    figName = fullfile(outparams.outFolder, [outparams.prefix, '_GABABg_comparison.png']);
end
save_all_figtypes(hFig.GABABg_comparison, figName);
% Copy figure handle so it won't be overwritten
if outparams.cprflag
    hFig.cpr_GABABg_comparison = hFig.GABABg_comparison;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
OLD CODE:

%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
