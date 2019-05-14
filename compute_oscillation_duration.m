function oscDurationMs = compute_oscillation_duration (abfFile, varargin)
%% Computes the oscillation duration from an interface recording abf file
% Usage: oscDurationMs = compute_oscillation_duration (abfFile, varargin)
% Explanation:
%       TODO
% Example(s):
%       TODO
% Outputs:
%       oscDurationMs   - oscillation duration in ms
%                       specified as a numeric scalar
% Arguments:
%       abfFile     - ABF file name; could be either the full path or 
%                       a relative path in current directory
%                       .abf is not needed (e.g. 'B20160908_0004')
%                   must be a string scalar or a character vector
%       varargin    - 'Verbose': whether to output parsed results
%                   must be numeric/logical 1 (true) or 0 (false)
%                   default == false
%                   - 'FiltFreq': cutoff frequency(ies) (Hz or normalized) 
%                                   for a bandpass filter
%                   must be a numeric a two-element vector
%                   default == [100, 1000]
%                   - 'MinDelayMs': minimum delay after stim start (ms)
%                   must be a positive scalar
%                   default == 25 ms
%                   - 'Signal2Noise': signal-to-noise ratio
%                   must be a positive scalar
%                   default == 3
%                   - 'BaseWindow': baseline window for each trace
%                   must be empty or a numeric vector with 2 elements,
%                       or a numeric array with 2 rows
%                       or a cell array of numeric vectors with 2 elements
%                   default == first half of the trace
%                   - 'BinWidthMs': bin width (ms)
%                   must be a positive scalar
%                   default == 10 ms
%                   - 'MinBurstLengthMs': minimum burst length (ms)
%                   must be a positive scalar
%                   default == 0 ms
%                   - 'MaxInterBurstIntervalMs': maximum inter-burst interval (ms)
%                   must be a positive scalar
%                   default == 0 ms
%                   - 'MinSpikeRateInBurstHz': minimum spike rate in a burst (Hz)
%                   must be a positive scalar
%                   default == 0 ms
%
% Requires:
%       cd/create_error_for_nargin.m
%       cd/struct2arglist.m
%       cd/compute_spike_histogram.m
%       cd/compute_time_window.m
%       cd/detect_spikes_multiunit.m
%       cd/parse_abf.m
%       cd/parse_stim.m
%
% Used by:
%       ~/Online_Stats/onlineOmight_interface.m

% File History:
% 2019-05-14 Created by Adam Lu
% 

%% Hard-coded parameters

%% Default values for optional arguments
verboseDefault = false;             % don't print parsed results by default
filtFreqDefault = [100, 1000];
baseWindowDefault = [];             % set later
minDelayMsDefault = 25;
signal2NoiseDefault = 3;        
binWidthMsDefault = 10;             % use a bin width of 10 ms by default
minBurstLengthMsDefault = 20;       % bursts must be at least 20 ms by default
maxInterBurstIntervalMsDefault = 1000;  % bursts are no more than 
                                        %   1 second apart by default
minSpikeRateInBurstHzDefault = 100;     % bursts must have a spike rate of 
                                        %   at least 100 Hz by default

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Deal with arguments
% Check number of required arguments
if nargin < 1
    error(create_error_for_nargin(mfilename));
end

% Set up Input Parser Scheme
iP = inputParser;
iP.FunctionName = mfilename;

% Add required inputs to the Input Parser
addRequired(iP, 'abfFile', ...
    @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
                                                % introduced after R2016b

% Add parameter-value pairs to the Input Parser
addParameter(iP, 'Verbose', verboseDefault, ...
    @(x) validateattributes(x, {'logical', 'numeric'}, {'binary'}));
addParameter(iP, 'FiltFreq', filtFreqDefault, ...
    @(x) assert(isnan(x) || isnumeric(x), ...
                ['FiltFreq must be either NaN ', ...
                    'or a numeric array of 2 elements!']));
addParameter(iP, 'BaseWindow', baseWindowDefault, ...
    @(x) assert(isnumeric(x) || iscellnumeric(x), ...
                ['BaseWindow must be either a numeric array ', ...
                    'or a cell array of numeric arrays!']));
addParameter(iP, 'MinDelayMs', minDelayMsDefault, ...
    @(x) validateattributes(x, {'numeric'}, {'scalar', 'nonnegative', 'integer'}));
addParameter(iP, 'Signal2Noise', signal2NoiseDefault, ...
    @(x) validateattributes(x, {'numeric'}, {'scalar', 'positive', 'integer'}));
addParameter(iP, 'BinWidthMs', binWidthMsDefault, ...
    @(x) validateattributes(x, {'numeric'}, {'scalar'}));
addParameter(iP, 'MinBurstLengthMs', minBurstLengthMsDefault, ...
    @(x) validateattributes(x, {'numeric'}, {'scalar'}));
addParameter(iP, 'MaxInterBurstIntervalMs', maxInterBurstIntervalMsDefault, ...
    @(x) validateattributes(x, {'numeric'}, {'scalar'}));
addParameter(iP, 'MinSpikeRateInBurstHz', minSpikeRateInBurstHzDefault, ...
    @(x) validateattributes(x, {'numeric'}, {'scalar'}));

% Read from the Input Parser
parse(iP, abfFile, varargin{:});
verbose = iP.Results.Verbose;
filtFreq = iP.Results.FiltFreq;
baseWindow = iP.Results.BaseWindow;
minDelayMs = iP.Results.MinDelayMs;
signal2Noise = iP.Results.Signal2Noise;
binWidthMs = iP.Results.BinWidthMs;
minBurstLengthMs = iP.Results.MinBurstLengthMs;
maxInterBurstIntervalMs = iP.Results.MaxInterBurstIntervalMs;
minSpikeRateInBurstHz = iP.Results.MinSpikeRateInBurstHz;

%% Parse the abf file
[abfParams, abfData] = parse_abf(abfFile, 'TimeUnits', 'ms', ...
                                'ChannelTypes', {'voltage', 'current'}, ...
                                'ChannelUnits', {'uV', 'arb'}, ...
                                'Verbose', verbose);

siMs = abfParams.siMs;
tVec = abfData.tVec;
vVecs = abfData.vVecs;
pulseVecs = abfData.iVecs;

%% Detect stimulation start
stimParams = parse_stim(pulseVecs, 'SamplingIntervalMs', siMs);

idxStimStart = stimParams.idxStimStart;
stimStartMs = stimParams.stimStartMs;

%% Construct baseline window
if isempty(baseWindow)
    baseWindow = compute_time_window(tVec, 'TimeEnd', stimStartMs);
end

%% Detect spikes
[~, spikesData] = ...
    detect_spikes_multiunit(vVecs, siMs, ...
                            'tVec', tVec, 'IdxStimStart', idxStimStart, ...
                            'FiltFreq', filtFreq, ...
                            'BaseWindow', baseWindow, ...
                            'MinDelayMs', minDelayMs, ...
                            'Signal2Noise', signal2Noise);

spikeTimesMs = spikesData.spikeTimesMs;

%% Compute the spike histogram, spikes per burst & oscillation duration
spHistParams = ...
    compute_spike_histogram(spikeTimesMs, 'StimStartMs', stimStartMs, ...
                            'BinWidthMs', binWidthMs, ...
                            'MinBurstLengthMs', minBurstLengthMs, ...
                            'MaxInterBurstIntervalMs', maxInterBurstIntervalMs, ...
                            'MinSpikeRateInBurstHz', minSpikeRateInBurstHz);

oscDurationMs = spHistParams.oscDurationMs;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
OLD CODE:

%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%