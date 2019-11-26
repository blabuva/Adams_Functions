%% Analyzes all CLC2 data
%
% Requires: 
%       cd/archive_dependent_scripts.m
%       cd/parse_all_multiunit.m
%       cd/plot_measures.m

% File History:
% 2019-08-06 Created by Adam Lu
% 2019-08-10 Changed nSweepsToAverage to 10
% 2019-08-10 Added SelectionMethod as a parameter
% 2019-08-12 Now runs archive_dependent_scripts.m

%% Hard-coded parameters
archiveDir = '/media/adamX/CLC2/data';
parentDir = '/media/adamX/CLC2/data/blinded';
% dirsToAnalyze = {'drug-clean', 'control-clean'};
dirsToAnalyze = {'drug-clean'};
% dirsToAnalyze = {'control-clean'};

parseIndividualFlag = false; %true;
saveMatFlag = false; %true;
plotSpikeDetectionFlag = false; %true;
plotMeasuresFlag = false; %true;
plotSpikeDensityFlag = false; %true;
plotContourFlag = false; %true;

parsePopulationFlag = true;
plotChevronFlag = true;

% For compute_default_signal2noise.m
relSnrThres2Max = 0.1;          % parameter for calculating signal-to-noise ratio

% For detect_spikes_multiunit.m
filtFreq = [100, 1000];         % bandpass filter frequency
minDelayMs = 25;                % minimum delay after stimulation start

% For compute_spike_density.m
binWidthMs = 10;                % use a bin width of 10 ms
resolutionMs = 5;               % plots have a 5 ms resolution

% For compute_spike_histogram.m
minBurstLengthMs = 20;          % bursts must be at least 20 ms
maxFirstInterBurstIntervalMs = 2000;
maxInterBurstIntervalMs = 2000; % bursts are no more than 1 second apart
minSpikeRateInBurstHz = 100;    % bursts must have a spike rate of 
                                %   at least 100 Hz

% For compute_autocorrelogram.m
filterWidthMs = 100;            % moving average filter width for 
                                %   smoothing the raw autocorrelation function
minRelProm = 0.02;              % minimum relative prominence for 
                                %   a frequency peak

% For compute_phase_average.m & plot_measures.m
nSweepsLastOfPhase = 10;        % select from last 10 values of each phase
nSweepsToAverage = 10;          % select 10 values to average
selectionMethod = 'notNaN';     % average all values that are not NaNs

% For plot_measures.m
plotType = 'tuning';
sweepLengthSec = 60;
timeLabel = 'Time';
phaseLabel = 'Phase';
phaseStrings = {'Baseline', 'Wash-on', 'Wash-out'};
varsToPlot = {'oscIndex1'; 'oscIndex2'; 'oscIndex3'; 'oscIndex4'; ...
                    'oscPeriod1Ms'; 'oscPeriod2Ms'; ...
                    'oscDurationSec'; ...
                    'nSpikesTotal'; 'nSpikesIn10s'; 'nSpikesInOsc'; ...
                    'nBurstsTotal'; 'nBurstsIn10s'; 'nBurstsInOsc'; ...
                    'nSpikesPerBurst'; 'nSpikesPerBurstIn10s'; ...
                    'nSpikesPerBurstInOsc'};
varLabels = {'Oscillatory Index 1'; 'Oscillatory Index 2'; ...
                'Oscillatory Index 3'; 'Oscillatory Index 4'; ...
                'Oscillation Period 1 (ms)'; 'Oscillation Period 2 (ms)'; ...
                'Oscillation Duration (s)'; ...
                'Total Spike Count'; 'Number of Spikes in First 10 s'; 
                'Number of Spikes in Oscillation'; ...
                'Total Number of Bursts'; 'Number of Bursts in First 10 s'; ...
                'Number of Bursts in Oscillation'; ...
                'Number of Spikes Per Burst'; ...
                'Number of Spikes Per Burst in First 10 s'; ...
                'Number of Spikes Per Burst in Oscillation'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Run through all directories
for iDir = 1:numel(dirsToAnalyze)
    % Get the current directory to analyze
    dirThis = fullfile(parentDir, dirsToAnalyze{iDir});

    % Parse all slices in this directory
    if parseIndividualFlag
        parse_all_multiunit('Directory', dirThis, ...
                'SaveMatFlag', saveMatFlag, ...
                'PlotSpikeDetectionFlag', plotSpikeDetectionFlag, ...
                'PlotMeasuresFlag', plotMeasuresFlag, ...
                'PlotSpikeDensityFlag', plotSpikeDensityFlag, ...
                'PlotContourFlag', plotContourFlag, ...
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
                'SelectionMethod', selectionMethod);
    end
    
    if parsePopulationFlag
        % Plot measures for all phases
        plot_measures('Directory', dirThis, ...
                        'PlotChevronFlag', plotChevronFlag, ...
                        'NSweepsLastOfPhase', nSweepsLastOfPhase, ...
                        'NSweepsToAverage', nSweepsToAverage, ...
                        'SelectionMethod', 'notNaN', ...
                        'PlotType', plotType, ...
                        'SweepLengthSec', sweepLengthSec, ...
                        'TimeLabel', timeLabel, ...
                        'PhaseLabel', phaseLabel, ...
                        'PhaseStrings', phaseStrings, ...
                        'VarsToPlot', varsToPlot, ...
                        'VarLabels', varLabels);

        % Plot measures for phases 1 & 2 only
        plot_measures('PhaseNumbers', [1, 2], ...
                        'Directory', dirThis, ...
                        'PlotChevronFlag', plotChevronFlag, ...
                        'NSweepsLastOfPhase', nSweepsLastOfPhase, ...
                        'NSweepsToAverage', nSweepsToAverage, ...
                        'SelectionMethod', selectionMethod, ...
                        'PlotType', plotType, ...
                        'SweepLengthSec', sweepLengthSec, ...
                        'TimeLabel', timeLabel, ...
                        'PhaseLabel', phaseLabel, ...
                        'PhaseStrings', phaseStrings, ...
                        'VarsToPlot', varsToPlot, ...
                        'VarLabels', varLabels);
    end
end

% Archive all scripts for this run
archive_dependent_scripts(mfilename, 'OutFolder', archiveDir);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
OLD CODE:

                        'MaxRange2Mean', maxRange2Mean);
                        'MaxRange2Mean', maxRange2Mean, ...
                        'MaxRange2Mean', maxRange2Mean, ...
maxRange2Mean = 40;              % range is not more than 40% of mean 
                                 %   by default

%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%