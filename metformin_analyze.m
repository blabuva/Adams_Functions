%% Analyzes all metformin data
%
% Requires: 
%       cd/parse_all_multiunit.m
%       cd/plot_measures.m

% File History:
% 2019-08-08 Adapted from clc2_analyze.m

%% Hard-coded parameters
parentDir = fullfile('/media', 'adamX', 'Glucose', 'oscillations', 'metformin');
dirsToAnalyze = {'all'};

% For compute_default_signal2noise.m
relSnrThres2Max = 0.1;

% For detect_spikes_multiunit.m
filtFreq = [100, 1000];
minDelayMs = 25;

% For compute_spike_density.m
binWidthMs = 10;                % use a bin width of 10 ms by default
resolutionMs = 5;

% For compute_spike_histogram.m
minBurstLengthMs = 20;          % bursts must be at least 20 ms by default
maxFirstInterBurstIntervalMs = 2000;
maxInterBurstIntervalMs = 1500; % bursts are no more than 
                                %   1 second apart by default
minSpikeRateInBurstHz = 100;    % bursts must have a spike rate of 
                                %   at least 100 Hz by default

% For compute_autocorrelogram.m
filterWidthMs = 100;
minRelProm = 0.02;

% For compute_phase_average.m & plot_measures.m
nSweepsLastOfPhase = 10;         % select from last 10 values by default
nSweepsToAverage = 5;            % select 5 values by default
maxRange2Mean = 40;              % range is not more than 40% of mean 
                                 %   by default

% For plot_measures.m
plotType = 'tuning';
sweepLengthSec = 60;
timeLabel = 'Time';
phaseLabel = 'Phase';
phaseStrings = {'Baseline', 'Wash-on', 'Wash-out'};
varsToPlot = {'oscIndex4'; 'oscPeriod2Ms'; ...
                    'oscDurationSec'; ...
                    'nSpikesTotal'; 'nSpikesInOsc'; ...
                    'nBurstsTotal'; 'nBurstsInOsc'; ...
                    'nSpikesPerBurst'; 'nSpikesPerBurstInOsc'};
varLabels = {'Oscillatory Index 4'; 'Oscillation Period 2 (ms)'; ...
                'Oscillation Duration (s)'; ...
                'Total Spike Count'; 'Number of Spikes in Oscillation'; ...
                'Total Number of Bursts'; 'Number of Bursts in Oscillation'; ...
                'Number of Spikes Per Burst'; ...
                'Number of Spikes Per Burst in Oscillation'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Run through all directories
for iDir = 1:numel(dirsToAnalyze)
    % Get the current directory to analyze
    dirThis = fullfile(parentDir, dirsToAnalyze{iDir});

    % Parse all slices in this directory
    parse_all_multiunit('Directory', dirThis, ...
            'SaveMatFlag', true, ...
            'PlotCombined', true, ...
            'PlotMeasures', true, ...
            'PlotSpikeDensity', true, ...
            'RelSnrThres2Max', relSnrThres2Max, ...
            'FiltFreq', filtFreq, ...
            'MinDelayMs', minDelayMs, ...
            'BinWidthMs', binWidthMs, ...
            'ResolutionMs', resolutionMs, ...
            'MinBurstLengthMs', minBurstLengthMs, ...
            'MaxFirstInterBurstIntervalMs', maxFirstInterBurstIntervalMs, ...
            'MaxInterBurstIntervalMs', maxInterBurstIntervalMs, ...
            'MinSpikeRateInBurstHz', minSpikeRateInBurstHz, ...
            'FilterWidthMs', filterWidthMs, ...
            'MinRelProm', minRelProm, ...
            'NSweepsLastOfPhase', nSweepsLastOfPhase, ...
            'NSweepsToAverage', nSweepsToAverage, ...
            'MaxRange2Mean', maxRange2Mean);

    % Plot measures for all phases
    plot_measures('Directory', dirThis, ...
                    'PlotAll', true, ...
                    'NSweepsLastOfPhase', nSweepsLastOfPhase, ...
                    'NSweepsToAverage', nSweepsToAverage, ...
                    'MaxRange2Mean', maxRange2Mean, ...
                    'PlotType', plotType, ...
                    'SweepLengthSec', sweepLengthSec, ...
                    'TimeLabel', timeLabel, ...
                    'PhaseLabel', phaseLabel, ...
                    'PhaseStrings', phaseStrings, ...
                    'VarsToPlot', varsToPlot, ...
                    'VarLabels', varLabels);

    % Plot measures for sweeps 1-50 only
    plot_measures('SweepNumbers', 1:50, ...
                    'PlotAll', true, ...
                    'Directory', dirThis, ...
                    'NSweepsLastOfPhase', nSweepsLastOfPhase, ...
                    'NSweepsToAverage', nSweepsToAverage, ...
                    'MaxRange2Mean', maxRange2Mean, ...
                    'PlotType', plotType, ...
                    'SweepLengthSec', sweepLengthSec, ...
                    'TimeLabel', timeLabel, ...
                    'PhaseLabel', phaseLabel, ...
                    'PhaseStrings', phaseStrings, ...
                    'VarsToPlot', varsToPlot, ...
                    'VarLabels', varLabels);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
OLD CODE:

%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%