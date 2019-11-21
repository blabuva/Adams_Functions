%% Analyzes all GAT blocker oscillations data
%
% Requires:
%       cd/archive_dependent_scripts.m
%       cd/parse_all_multiunit.m
%       cd/plot_measures.m

% File History:
% 2019-10-17 Adapted from Glucose_analyze.m
% 2019-10-18 Changed minSpikeRateInBurstHz from 100 Hz to 200 Hz
% 2019-10-18 Changed minSpikeRateInBurstHz from 200 Hz to 100 Hz
% 2019-10-18 Changed maxInterBurstIntervalMs from 1500 ms to 1000 ms

%% Hard-coded parameters
% parentDir = fullfile('/media', 'adamX', 'm3ha', 'oscillations');
parentDir = fullfile('/media', 'shareX', 'Data_for_test_analysis', 'parse_multiunit_m3ha');
archiveDir = parentDir;
dirsToAnalyze = {'no711-final', 'snap5114-final', 'dual-final'};
% dirsToAnalyze = {'snap5114-final', 'dual-final'};
% dirsToAnalyze = {'no711-final'};
% dirsToAnalyze = {'dual-final'};
specificSlicesToAnalyze = {};

parseIndividualFlag = true;
saveMatFlag = false; % true;
plotRawFlag = true; %false; % true;
plotSpikeDetectionFlag = false; % true;
plotRasterFlag = false; % true;
plotSpikeDensityFlag = false; % true;
plotSpikeHistogramFlag = false; % true;
plotAutoCorrFlag = false; % true;
plotMeasuresFlag = false; % true;
plotContourFlag = false; % true;
plotCombinedFlag = false; % true;

parsePopulationAllFlag = false; %true;
parsePopulationRestrictedFlag = false; %true;
plotAllMeasurePlotsFlag = false; %true;
plotChevronFlag = false; %true;
plotByFileFlag = false; %true;
plotByPhaseFlag = false; %true;
plotNormByFileFlag = false; %true;
plotNormByPhaseFlag = false; %true;
plotPopAverageFlag = false; %true;
plotSmoothNormPopAvgFlag = false; %true;

archiveScriptsFlag = false; %true; 

% For compute_default_signal2noise.m
relSnrThres2Max = 0.1;

% For detect_spikes_multiunit.m
filtFreq = [100, 1000];
minDelayMs = 25;

% For compute_spike_density.m
binWidthMs = 10;                % use a bin width of 10 ms by default
resolutionMs = 5;

% For compute_spike_histogram.m
% minBurstLengthMs = 20;          % bursts must be at least 20 ms by default
minBurstLengthMs = 100;          % bursts must be at least 100 ms by default
maxFirstInterBurstIntervalMs = 2000;
% maxInterBurstIntervalMs = 1000; % bursts are no more than 
%                                 %   1 second apart
maxInterBurstIntervalMs = 1500; % bursts are no more than 
                                %   1.5 seconds apart
% minSpikeRateInBurstHz = 100;    % bursts must have a spike rate of 
%                                   at least 100 Hz by default
minSpikeRateInBurstHz = 30;    % bursts must have a spike rate of 
                                %   at least 30 Hz by default

% For compute_autocorrelogram.m
filterWidthMs = 100;
minRelProm = 0.02;

% For compute_phase_average.m & plot_measures.m
sweepsRelToPhase2 = -19:40;         % select between -20 & 40 min
% nSweepsLastOfPhase = 5;           % select from last 10 values of each phase
nSweepsLastOfPhase = 10;            % select from last 10 values of each phase
nSweepsToAverage = 5;               % select 5 values to average
% nSweepsToAverage = 10;            % select 10 values to average
selectionMethod = 'maxRange2Mean';  % average values within 40% of mean 
% selectionMethod = 'notNaN';       % average all values that are not NaNs
maxRange2Mean = 40;                 % range is not more than 40% of mean 
                                    %   by default
removeOutliersInPlot = false;

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
    if parseIndividualFlag
        parse_all_multiunit('Directory', dirThis, ...
                'SliceBases', specificSlicesToAnalyze, ...
                'SaveMatFlag', saveMatFlag, ...
                'PlotRawFlag', plotRawFlag, ...
                'PlotSpikeDetectionFlag', plotSpikeDetectionFlag, ...
                'PlotRasterFlag', plotRasterFlag, ...
                'PlotSpikeDensityFlag', plotSpikeDensityFlag, ...
                'PlotSpikeHistogramFlag', plotSpikeHistogramFlag, ...
                'PlotAutoCorrFlag', plotAutoCorrFlag, ...
                'PlotMeasuresFlag', plotMeasuresFlag, ...
                'PlotContourFlag', plotContourFlag, ...
                'PlotCombined', plotCombinedFlag, ...
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
    end
    
    if parsePopulationAllFlag
        % Plot measures for all phases
        plot_measures('Directory', dirThis, ...
                        'PlotAll', plotAllMeasurePlotsFlag, ...
                        'PlotChevronFlag', plotChevronFlag, ...
                        'PlotByFileFlag', plotByFileFlag, ...
                        'PlotByPhaseFlag', plotByPhaseFlag, ...
                        'PlotNormByFileFlag', plotNormByFileFlag, ...
                        'PlotNormByPhaseFlag', plotNormByPhaseFlag, ...
                        'PlotPopAverageFlag', plotPopAverageFlag, ...
                        'PlotSmoothNormPopAvgFlag', plotSmoothNormPopAvgFlag, ...
                        'RemoveOutliersInPlot', removeOutliersInPlot, ...
                        'NSweepsLastOfPhase', nSweepsLastOfPhase, ...
                        'NSweepsToAverage', nSweepsToAverage, ...
                        'SelectionMethod', 'notNaN', ...
                        'MaxRange2Mean', maxRange2Mean, ...
                        'PlotType', plotType, ...
                        'SweepLengthSec', sweepLengthSec, ...
                        'TimeLabel', timeLabel, ...
                        'PhaseLabel', phaseLabel, ...
                        'PhaseStrings', phaseStrings, ...
                        'VarsToPlot', varsToPlot, ...
                        'VarLabels', varLabels);
    end

    if parsePopulationRestrictedFlag
        % Plot measures for sweeps 1-lastSweepToMeasure only
        plot_measures('Directory', dirThis, ...
                        'SweepsRelToPhase2', sweepsRelToPhase2, ...
                        'PlotAll', plotAllMeasurePlotsFlag, ...
                        'PlotChevronFlag', plotChevronFlag, ...
                        'PlotByFileFlag', plotByFileFlag, ...
                        'PlotByPhaseFlag', plotByPhaseFlag, ...
                        'PlotNormByFileFlag', plotNormByFileFlag, ...
                        'PlotNormByPhaseFlag', plotNormByPhaseFlag, ...
                        'PlotPopAverageFlag', plotPopAverageFlag, ...
                        'PlotSmoothNormPopAvgFlag', plotSmoothNormPopAvgFlag, ...
                        'RemoveOutliersInPlot', removeOutliersInPlot, ...
                        'NSweepsLastOfPhase', nSweepsLastOfPhase, ...
                        'NSweepsToAverage', nSweepsToAverage, ...
                        'SelectionMethod', 'notNaN', ...
                        'MaxRange2Mean', maxRange2Mean, ...
                        'PlotType', plotType, ...
                        'SweepLengthSec', sweepLengthSec, ...
                        'TimeLabel', timeLabel, ...
                        'PhaseLabel', phaseLabel, ...
                        'PhaseStrings', phaseStrings, ...
                        'VarsToPlot', varsToPlot, ...
                        'VarLabels', varLabels);
    end
    
    close all
end

% Archive all scripts for this run
if archiveScriptsFlag
    archive_dependent_scripts(mfilename, 'OutFolder', archiveDir);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
OLD CODE:

parentDir = fullfile('/media', 'adamX', 'Glucose', 'oscillations', 'metformin');
lastSweepToMeasure = 45;        % select between sweeps 1:45

%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%