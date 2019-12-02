% m3ha_oscillations_analyze.m
%% Analyzes all GAT blocker oscillations data
%
% Requires:
%       cd/archive_dependent_scripts.m
%       cd/parse_all_multiunit.m
%       cd/plot_measures.m
%       cd/plot_scale_bar.m
%       cd/update_figure_for_corel.m
%       cd/save_all_figtypes.m

% File History:
% 2019-10-17 Adapted from Glucose_analyze.m
% 2019-10-18 Changed minSpikeRateInBurstHz from 100 Hz to 200 Hz
% 2019-10-18 Changed minSpikeRateInBurstHz from 200 Hz to 100 Hz
% 2019-10-18 Changed maxInterBurstIntervalMs from 1500 ms to 1000 ms
% 2019-11-?? Changed minBurstLengthMs from 20 to 100 ms
% 2019-11-?? Changed minSpikeRateInBurstHz from 100 Hz to 30 Hz
% 2019-11-25 Added plotFigure1Population
% 2019-11-26 Changed minSpikeRateInBurstHz from 30 Hz to 50 Hz
% 2019-11-26 Changed maxInterBurstIntervalMs from 2000 ms to 1500 ms
% 2019-11-28 Fixed the usage of selectionMethod for plot_measures
% 2019-11-28 Changed minBurstLengthMs from 100 ms to 60 ms
% 2019-11-28 Changed maxInterBurstIntervalMs from 1500 ms to 2000 ms
% 2019-11-28 Changed minSpikeRateInBurstHz from 50 Hz to 100 Hz

%% Hard-coded parameters
% Folders
figure01Dir = fullfile('/media', 'adamX', 'm3ha', ...
                        'manuscript', 'figures', 'Figure01');
parentDir = fullfile('/media', 'adamX', 'm3ha', 'oscillations');
% parentDir = fullfile('/media', 'shareX', 'Data_for_test_analysis', ...
%                       'parse_multiunit_m3ha');
archiveDir = parentDir;
dirsToAnalyze = {'dual-final', 'snap5114-final', 'no711-final'};
% dirsToAnalyze = {'snap5114-final', 'dual-final'};
% dirsToAnalyze = {'no711-final'};
% dirsToAnalyze = {'dual-final'};
% dirsToAnalyze = {'snap5114-test', 'no711-test', 'dual-test'};
% dirsToAnalyze = {'no711-test', 'snap5114-test'};
% dirsToAnalyze = {'snap5114-test'};
% dirsToAnalyze = {'dual-test'};
% dirsToAnalyze = {'important-cases'};
% dirsToAnalyze = {'difficult-cases'};
specificSlicesToAnalyze = {};

% For manuscript
figTypesForVis = {'png'};
figTypesForCorel = {'epsc2'};

plotFigure1Individual = true;
parseExamplesFlag = false;
plotExampleContourFlag = false; % true;
contourXLimitsSeconds = [2, 20];
contourWidth = 11;
contourHeight = 3;
plotExampleRawTracesFlag = false; % true;
rawPlotLineWidth = 0.25;
rawSweepNumbers = [16, 56];
rawWidth = 8;
rawHeight = 3;
rawXLimits = [2, 15];
rawYLimits = [-5, 5];
plotExampleSpikeDetectionFlag = false; % true;
sampleXLimits = [2, 10];
sampleSweepNumber = 16;
samplePlotLineWidth = 0.25;
sampleRasterLineWidth = 0.25;
spikeDetWidth = 11;
spikeDetHeight = 3;
plotExampleSpikeHistogramFlag = true;
spikeHistWidth = 11;
spikeHistHeight = 3;
plotExampleAutoCorrFlag = false; % true;
autoCorrWidth = 11;
autoCorrHeight = 3;

plotFigure1Population = false;  % true;
chevronWidth = 4;               % figure width in cm
chevronHeight = 4;              % figure height in cm
chevronMarkerSize = 1;          % marker size in points

% Flags
parseIndividualFlag = false; % true;
saveMatFlag = false; % true;
plotRawFlag = false; % true;
plotSpikeDetectionFlag = false; % true;
plotRasterFlag = false; % true;
plotSpikeDensityFlag = false; % true;
plotSpikeHistogramFlag = true;
plotAutoCorrFlag = true;
plotMeasuresFlag = false; % true;
plotContourFlag = false; % true;
plotCombinedFlag = true;

parsePopulationRestrictedFlag = false; %true;
plotChevronFlag = true;
plotByFileFlag = true;
plotByPhaseFlag = true;
plotNormByFileFlag = true;
plotNormByPhaseFlag = true;
plotPopAverageFlag = true;
plotSmoothNormPopAvgFlag = true;
parsePopulationAllFlag = false; %true;
plotAllMeasurePlotsFlag = false; %true;

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
minBurstLengthMs = 60;          % bursts must be at least 60 ms by default
maxFirstInterBurstIntervalMs = 2000;
maxInterBurstIntervalMs = 2000; % bursts are no more than 
                                %   2 seconds apart
minSpikeRateInBurstHz = 100;    % bursts must have a spike rate of 
                                %   at least 100 Hz by default

% For compute_autocorrelogram.m
filterWidthMs = 100;
minRelProm = 0.02;

% For compute_phase_average.m & plot_measures.m
sweepsRelToPhase2 = -19:40;         % select between -20 & 40 min
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

% Plot raster plots for Figure 01
if plotFigure1Individual
    % Parse and save all parsed results
    if parseExamplesFlag
        parse_all_multiunit('Directory', figure01Dir, ...
                'SaveResultsFlag', true, ...
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
                'SelectionMethod', selectionMethod, ...
                'MaxRange2Mean', maxRange2Mean);
    end

    % Find all parsed files
    [~, parsePaths] = ...
        all_files('Directory', figure01Dir, 'KeyWord', 'slice', ...
                    'Extension', 'mat', 'Suffix', 'parsed');

    % Plot for each file
    for iFile = 1:numel(parsePaths)
        % Get the matfile of interest
        thisPath = parsePaths{iFile};

        % Load parsed data
        fprintf('Loading parsed data from %s ...\n', thisPath);
        load(thisPath, 'parsedParams', 'parsedData', 'fileBase');

        % Extract the data and params for the sample traces
        [parsedParamsStruct, parsedDataStruct] = ...
            argfun(@table2struct, parsedParams, parsedData);
        sampleDataStruct = parsedDataStruct(sampleSweepNumber);
        sampleParamsStruct = parsedParamsStruct(sampleSweepNumber);
        sampleBase = strcat(fileBase, '_trace', num2str(sampleSweepNumber));

        % Plot example contour plots
        if plotExampleContourFlag
            fprintf('Plotting example contour plot for %s ...\n', fileBase);

            % Create a figure base
            figBaseContour = fullfile(figure01Dir, [fileBase, '_contour']);

            % Create figure
            fig = set_figure_properties('AlwaysNew', true, ...
                                        'Width', 1100, 'Height', 300);

            % Plot spike density
            plot_spike_density_multiunit(parsedData, parsedParams, ...
                                'XLimits', contourXLimitsSeconds, ...
                                'PlotStimStart', false, ...
                                'BoundaryType', 'verticalBars', ...
                                'MaxNYTicks', 4);

            % Save the figure
            save_all_figtypes(fig, figBaseContour, figTypesForVis);

            % Plot scale bars
            plot_scale_bar('xy', 'XBarLength', 1, 'XBarUnits', 'sec', ...
                            'YBarLength', 10, 'YBarUnits', 'min', ...
                            'XPosNormalized', 0.8, 'YPosNormalized', 0.2);

            % Update figure for CorelDraw
            update_figure_for_corel(fig, 'Units', 'centimeters', ...
                            'Width', contourWidth, 'Height', contourHeight, ...
                            'RemoveXTicks', true, 'RemoveXLabel', true, ...
                            'RemoveYTicks', true, 'RemoveYLabel', true);

            % Save the figure
            save_all_figtypes(fig, figBaseContour, figTypesForCorel);
        end

        % Plot example raw traces
        if plotExampleRawTracesFlag
            fprintf('Plotting example raw traces for %s ...\n', fileBase);

            % Create a figure base
            figBaseRaw = fullfile(figure01Dir, [fileBase, '_raw_examples']);

            % Create figure
            fig = set_figure_properties('AlwaysNew', true);

            % Plot raw traces
            plot_raw_multiunit(parsedData, parsedParams, ...
                            'PlotFiltered', false, 'PlotMode', 'parallel', ...
                            'PlotStim', false, 'SweepNumbers', rawSweepNumbers, ...
                            'XLimits', rawXLimits, 'YLimits', rawYLimits, ...
                            'LineWidth', rawPlotLineWidth);

            % Save the figure
            save_all_figtypes(fig, figBaseRaw, figTypesForVis);

            % Plot scale bars
            plot_scale_bar('xy', 'XBarLength', 2, 'XBarUnits', 'sec', ...
                            'YBarLength', 5, 'YBarUnits', 'uV', ...
                            'XPosNormalized', 0.8, 'YPosNormalized', 0.2);

            % Update figure for CorelDraw
            update_figure_for_corel(fig, 'Units', 'centimeters', ...
                            'Width', rawWidth, 'Height', rawHeight, ...
                            'RemoveTicks', true, 'RemoveLabels', true, ...
                            'RemoveRulers', true, 'RemoveTitles', true);

            % Save the figure
            save_all_figtypes(fig, figBaseRaw, figTypesForCorel);
        end

        % Plot sample spike detection plot
        if plotExampleSpikeDetectionFlag
            fprintf('Plotting sample spike detection traces for %s ...\n', ...
                    sampleBase);

            % Create a figure base
            figBaseSpikeDet = fullfile(figure01Dir, ...
                                [sampleBase, '_spike_detection']);

            % Create figure
            fig = set_figure_properties('AlwaysNew', true);

            % TODO: Use plot_spike_detection.m
            % Hard-coded parameters
            MS_PER_S = 1000;
            vertBarWidth2Range = 1/10;

            % Extract from structures
            tVec = sampleDataStruct.tVec;
            vVec = sampleDataStruct.vVec;
            idxSpikes = sampleDataStruct.idxSpikes;
            vRange = sampleParamsStruct.vRange;
            vMax = sampleParamsStruct.vMax;
            vMin = sampleParamsStruct.vMin;
            figTitleBase = sampleParamsStruct.figTitleBase;

            % Compute for spike detection plot
            vertBarWidth = vRange * vertBarWidth2Range;
            yMid = vMax + vertBarWidth;
            yLimits = compute_axis_limits([vMin, yMid], 'y', 'Coverage', 100);

            % Convert to seconds
            tVec = tVec ./ MS_PER_S;

            % Plot raw trace
            plot(tVec, vVec, 'k', 'LineWidth', samplePlotLineWidth);

            % Plot spike detection
            plot_raster(tVec(idxSpikes), 'PlotOnly', true, ...
                        'YMid', yMid, 'VertBarWidth', vertBarWidth, ...
                        'LineWidth', sampleRasterLineWidth, 'ColorMap', 'r');

            % Set x limits, labels and title
            xlim(sampleXLimits);
            ylim(yLimits);
            xlabel('Time (ms)');
            ylabel('Voltage (mV)');
            title(['Spike Detection for ', figTitleBase]);

            % Save the figure
            save_all_figtypes(fig, figBaseSpikeDet, figTypesForVis);

            % Update figure for CorelDraw
            update_figure_for_corel(fig, 'Units', 'centimeters', ...
                        'Width', spikeDetWidth, 'Height', spikeDetHeight);

            % Save the figure
            save_all_figtypes(fig, figBaseSpikeDet, figTypesForCorel);
        end

        % Plot sample spike histogram plot
        if plotExampleSpikeHistogramFlag
            fprintf('Plotting sample spike histogram traces for %s ...\n', ...
                    sampleBase);

            % Create a figure base
            figBaseSpikeHist = fullfile(figure01Dir, ...
                                [sampleBase, '_spike_histogram']);

            % Create figure
            fig = set_figure_properties('AlwaysNew', true);

            % Plot spike histogram
            plot_spike_histogram(sampleDataStruct, sampleParamsStruct, ...
                                'XLimits', sampleXLimits);

            % Save the figure
            save_all_figtypes(fig, figBaseSpikeHist, figTypesForVis);

            % Update figure for CorelDraw
            update_figure_for_corel(fig, 'Units', 'centimeters', ...
                            'Width', spikeHistWidth, 'Height', spikeHistHeight);

            % Save the figure
            save_all_figtypes(fig, figBaseSpikeHist, figTypesForCorel);
        end

        % Plot sample autocorrelation function plot
        if plotExampleAutoCorrFlag
            fprintf('Plotting sample autocorr traces for %s ...\n', sampleBase);

            % Create a figure base
            figBaseAutoCorr = fullfile(figure01Dir, [sampleBase, '_autocorr']);

            % Create figure
            fig = set_figure_properties('AlwaysNew', true);

            % Plot autocorrelation function
            plot_autocorrelogram(sampleDataStruct, sampleParamsStruct, ...
                                    'DataType', 'acfFiltered');

            % Save the figure
            save_all_figtypes(fig, figBaseAutoCorr, figTypesForVis);

            % Update figure for CorelDraw
            update_figure_for_corel(fig, 'Units', 'centimeters', ...
                            'Width', autoCorrWidth, 'Height', autoCorrHeight);

            % Save the figure
            save_all_figtypes(fig, figBaseAutoCorr, figTypesForCorel);
        end

        % Remove data
        clear parsedParams parsedData
    end
end

% Plot Chevron plots for Figure 01
if plotFigure1Population
    % Get all paths to Chevron tables
    [~, allSheetPaths] = all_files('Directory', figure01Dir, ...
                                'Suffix', 'chevron', 'Extension', 'csv');
                            
	% Read in all Chevron tables
    allChevronTables = cellfun(@(x) readtable(x, 'ReadRowNames', true), ...
                                allSheetPaths, 'UniformOutput', false);

    % Create figure names
    figPathBasesChevron = extract_fileparts(allSheetPaths, 'pathbase');
 
    % Plot and save all Chevron tables
    cellfun(@(x, y) plot_and_save_chevron(x, y, figTypesForCorel, ...
                    chevronWidth, chevronHeight, chevronMarkerSize), ...
            allChevronTables, figPathBasesChevron);
end

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
                'SelectionMethod', selectionMethod, ...
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
                        'SelectionMethod', selectionMethod, ...
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
                        'SelectionMethod', selectionMethod, ...
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

function plot_and_save_chevron(chevronTable, figPathBase, figTypesForCorel, ...
                                chevronWidth, chevronHeight, chevronMarkerSize)

% Extract figure base
figBase = extract_fileparts(figPathBase, 'dirbase');

% Extract drug name
drugName = extractBefore(figBase, '-');

% Make drug name all caps
drugNameAllCaps = upper(drugName);

% Create parameter tick labels
pTickLabels = {'Baseline'; drugNameAllCaps};

% Extract readout measure
measureName = extractAfter(extractBefore(figBase, '_chevron'), 'Phase2_');

% Decide on measure-dependent stuff
switch measureName
    case 'oscDurationSec'
        readoutLimits = [0, 20];
        readoutLabel = 'Duration (s)';
    case 'oscPeriod2Ms'
        readoutLimits = [400, 1000];
        readoutLabel = 'Period (ms)';
    otherwise
        error('measureName unrecognized!');
end

% Create figure
fig = set_figure_properties('AlwaysNew', true);

% Plot Chevron
plot_chevron(chevronTable, 'PlotMeanValues', true, ...
                'PlotMeanDifference', true, 'PlotErrorBars', false, ...
                'ColorMap', 'k', 'ReadoutLimits', readoutLimits, ...
                'PTickLabels', pTickLabels, ...
                'ReadoutLabel', readoutLabel, 'FigTitle', 'suppress', ...
                'LegendLocation', 'suppress');

% Update figure for CorelDraw
update_figure_for_corel(fig, 'Units', 'centimeters', ...
                        'Width', chevronWidth, 'Height', chevronHeight, ...
                        'PlotMarkerSize', chevronMarkerSize);

% Save figure
save_all_figtypes(fig, figPathBase, figTypesForCorel);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
OLD CODE:

parentDir = fullfile('/media', 'adamX', 'Glucose', 'oscillations', 'metformin');
lastSweepToMeasure = 45;        % select between sweeps 1:45

%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%