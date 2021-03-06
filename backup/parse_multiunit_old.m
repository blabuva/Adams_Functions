function varargout = parse_multiunit (vVecs, siMs, varargin)
%% Parses multiunit recordings: detect spikes, computes spike histograms and autocorrelograms
% Usage: [parsedParams, parsedData, figs] = parse_multiunit (vVecs, siMs, varargin)
% Explanation:
%       TODO
% Example(s):
%       TODO
% Outputs:
%       parsedParams- parsed parameters, a table with columns:
%                       phaseNumber
%                       phaseName
%                       signal2Noise
%                       minDelayMs
%                       minDelaySamples
%                       binWidthMs
%                       binWidthSec
%                       filterWidthMs
%                       minRelProm
%                       minSpikeRateInBurstHz
%                       minBurstLengthMs
%                       maxInterBurstIntervalMs
%                       maxInterBurstIntervalSec
%                       siMs
%                       idxStimStart
%                       stimStartMs
%                       stimStartSec
%                       baseWindow
%                       baseSlopeNoise
%                       slopeThreshold
%                       idxDetectStart
%                       detectStartMs
%                       detectStartSec
%                       nSpikesTotal
%                       idxFirstSpike
%                       firstSpikeMs
%                       firstSpikeSec
%                       vMin
%                       vMax
%                       vRange
%                       slopeMin
%                       slopeMax
%                       slopeRange
%                       nBins
%                       halfNBins
%                       histLeftMs
%                       histLeftSec
%                       nSpikesPerBurst
%                       nSpikesPerBurstIn10s
%                       nSpikesPerBurstInOsc
%                       nSpikesIn10s
%                       nSpikesInOsc
%                       nBurstsTotal
%                       nBurstsIn10s
%                       nBurstsInOsc
%                       iBinLastOfLastBurst
%                       iBinLastOfLastBurstIn10s
%                       iBinLastOfLastBurstInOsc
%                       timeOscEndMs
%                       timeOscEndSec
%                       oscDurationMs
%                       oscDurationSec
%                       oscIndex1
%                       oscIndex2
%                       oscIndex3
%                       oscIndex4
%                       oscPeriod1Ms
%                       oscPeriod2Ms
%                       minOscPeriod2Bins
%                       maxOscPeriod2Bins
%                       figPathBase
%                       figTitleBase
%                   specified as a table
%       parsedData  - parsed parameters, a table with columns:
%                       tVec
%                       vVec
%                       vVecFilt
%                       slopes
%                       idxSpikes
%                       spikeTimesMs
%                       spikeTimesSec
%                       spikeCounts
%                       edgesMs
%                       edgesSec
%                       spikeCountsEachBurst
%                       spikeCountsEachBurstIn10s
%                       spikeCountsEachBurstInOsc
%                       iBinBurstStarts
%                       iBinBurstEnds
%                       iBinBurstIn10sStarts
%                       iBinBurstIn10sEnds
%                       iBinBurstInOscStarts
%                       iBinBurstInOscEnds
%                       timeBurstStartsMs
%                       timeBurstEndsMs
%                       timeBurstIn10sStartsMs
%                       timeBurstIn10sEndsMs
%                       timeBurstInOscStartsMs
%                       timeBurstInOscEndsMs
%                       timeBurstStartsSec
%                       timeBurstEndsSec
%                       autoCorr
%                       acf
%                       acfFiltered
%                       acfFilteredOfInterest
%                       indPeaks
%                       indTroughs
%                       ampPeaks
%                       ampTroughs
%                       halfPeriodsToMultiple
%                   specified as a table
%       figs        - figure handles
%                   specified as a Figure object handle array
% Arguments:
%       vVecs       - original voltage vector(s) in mV
%                   must be a numeric array or a cell array of numeric arrays
%       siMs        - sampling interval in ms
%                   must be a positive vector
%       varargin    - 'PlotAllFlag': whether to plot everything
%                   must be numeric/logical 1 (true) or 0 (false)
%                   default == false
%                   - 'PlotCombinedFlag': whether to plot raw data, 
%                           spike density and oscillation duration together
%                   must be numeric/logical 1 (true) or 0 (false)
%                   default == false
%                   - 'PlotSpikeDetectionFlag': whether to plot spike detection
%                   must be numeric/logical 1 (true) or 0 (false)
%                   default == false
%                   - 'PlotSpikeDensityFlag': whether to plot spike density
%                   must be numeric/logical 1 (true) or 0 (false)
%                   default == false
%                   - 'PlotSpikeHistogramFlag': whether to plot spike histograms
%                   must be numeric/logical 1 (true) or 0 (false)
%                   default == false
%                   - 'PlotAutoCorrFlag': whether to plot autocorrelegrams
%                   must be numeric/logical 1 (true) or 0 (false)
%                   default == false
%                   - 'PlotRawFlag': whether to plot raw traces
%                   must be numeric/logical 1 (true) or 0 (false)
%                   default == false
%                   - 'PlotRasterFlag': whether to plot raster plots
%                   must be numeric/logical 1 (true) or 0 (false)
%                   default == false
%                   - 'PlotMeasuresFlag': whether to plot time series 
%                                           of measures
%                   must be numeric/logical 1 (true) or 0 (false)
%                   default == false
%                   - 'OutFolder': directory to place outputs
%                   must be a string scalar or a character vector
%                   default == pwd
%                   - 'FileBase': base of filename (without extension)
%                   must be a string scalar or a character vector
%                   default == 'unnamed'
%                   - 'StimStartMs': time of stimulation start (ms)
%                   must be a positive scalar
%                   default == detect from pulse vector
%                   - 'PulseVectors': vector that contains the pulse itself
%                   must be a numeric vector
%                   default == [] (not used)
%                   - 'PhaseBoundaries': vector of phase boundaries
%                   must be a numeric vector
%                   default == [] (not used)
%                   - 'tVecs': original time vector(s)
%                   must be a numeric array or a cell array of numeric arrays
%                   default == [] (not used)
%                   
% Requires:
%       cd/argfun.m
%       cd/check_dir.m
%       cd/check_subdir.m
%       cd/compute_axis_limits.m
%       cd/compute_spike_density.m
%       cd/compute_spike_histogram.m
%       cd/compute_time_window.m
%       cd/compute_stats.m
%       cd/count_samples.m
%       cd/count_vectors.m
%       cd/create_error_for_nargin.m
%       cd/create_time_vectors.m
%       cd/detect_spikes_multiunit.m
%       cd/extract_elements.m
%       cd/extract_subvectors.m
%       cd/find_nearest_multiple.m
%       cd/force_column_cell.m
%       cd/force_matrix.m
%       cd/iscellnumeric.m
%       cd/match_time_info.m
%       cd/movingaveragefilter.m
%       cd/parse_stim.m
%       cd/plot_horizontal_line.m
%       cd/plot_raster.m
%       cd/plot_table.m
%       cd/save_all_zooms.m
%       cd/set_default_flag.m
%       cd/transform_vectors.m
%
% Used by:
%       cd/parse_all_multiunit.m

% File History:
% 2019-02-19 Created by Adam Lu
% 2019-02-24 Added computation of oscillation index and period
% 2019-02-25 Added computation of oscillation duration
% 2019-02-26 Updated computation of oscillation duration
% 2019-02-26 Updated computation of oscillation index
% 2019-03-14 Nows places figures in subdirectories
% 2019-03-14 Nows computes appropriate x and y limits for all traces
% 2019-03-14 Fixed plotting of oscillation duration in histograms
% 2019-03-14 Redefined the oscillation period so that it is between the primary
%               peak and the next largest-amplitude peak
% 2019-03-14 Redefined the oscillatory index so that it is the reciprocal of 
%               the coefficient of variation of the lag differences 
%               between consecutive peaks
% 2019-03-15 Redefined the oscillatory index so that it is 
%               1 minus the average of all distances 
%               (normalized by half the oscillation period)
%               to the closest multiple of the period over all peaks
% 2019-03-17 Added nSpikesPerBurstInOsc, nSpikesInOsc, nBurstsInOsc, etc ...
% 2019-03-19 Added nSpikesPerBurstIn10s, nSpikesIn10s, nBurstsIn10s, etc ...
% 2019-03-24 Fixed bugs in prepare_for_plot_horizontal_line.m
% 2019-03-24 Renamed setNumber -> phaseNumber, setName -> phaseName
% 2019-05-03 Moved code to detect_spikes_multiunit.m
% 2019-05-06 Expanded plot flags
% 2019-05-16 Added spike density computation and plot
% 2019-05-16 Changed maxInterBurstIntervalMs to 1500
% 2019-05-16 Changed signal2Noise to 2.5 
% 2019-06-02 Added compute_default_signal2noise.m
% 2019-06-03 Moved code to save_all_zooms.m
% 2019-06-10 Compartmentalized plot code
% 2019-06-10 Added plotCombinedFlag

% Hard-coded constants
MS_PER_S = 1000;

%% Hard-coded parameters
plotTypeMeasures = 'bar'; %'tuning';
yAmountToStagger = 10;
% zoomWinRelStimStartSec = [-1; 10];
zoomWinRelStimStartSec = [-1; 20];
zoomWinRelDetectStartSec = [-0.2; 2];
zoomWinRelFirstSpikeSec = [0; 0.1];
rawDir = 'raw';
rasterDir = 'rasters';
autoCorrDir = 'autocorrelograms';
acfDir = 'autocorrelation_functions';
spikeHistDir = 'spike_histograms';
spikeDensityDir = 'spike_density';
spikeDetectionDir = 'spike_detections';
measuresDir = 'measures';
combinedDir = 'combined';
measuresToPlot = {'oscIndex1', 'oscIndex2', 'oscIndex3', 'oscIndex4', ...
                    'oscPeriod1Ms', 'oscPeriod2Ms', ...
                    'oscDurationSec', ...
                    'nSpikesTotal', 'nSpikesIn10s', 'nSpikesInOsc', ...
                    'nBurstsTotal', 'nBurstsIn10s', 'nBurstsInOsc', ...
                    'nSpikesPerBurst', 'nSpikesPerBurstIn10s', ...
                    'nSpikesPerBurstInOsc'};

%% Default values for optional arguments
plotAllFlagDefault = false;
plotCombinedFlagDefault = false;
plotSpikeDetectionFlagDefault = [];
plotSpikeDensityFlagDefault = [];
plotSpikeHistogramFlagDefault = [];
plotAutoCorrFlagDefault = [];
plotRawFlagDefault = [];
plotRasterFlagDefault = [];
plotMeasuresFlagDefault = [];
outFolderDefault = pwd;
fileBaseDefault = '';           % set later
stimStartMsDefault = [];        % set later
pulseVectorsDefault = [];       % don't use pulse vectors by default
phaseBoundariesDefault = [];   	% no phase boundaries by default
tVecsDefault = [];              % set later

% TODO: Make optional argument
baseWindows = [];
relSnrThres2Max = [];           % set in compute_default_signal2noise.m

% Must be consistent with compute_oscillation_duration.m
filtFreq = [100, 1000];
minDelayMs = 25;
binWidthMs = 10;
resolutionMs = 5;
signal2Noise = [];              % set later
minBurstLengthMs = 20;
maxInterBurstIntervalMs = 2000;
minSpikeRateInBurstHz = 100;
filterWidthMs = 100;
minRelProm = 0.02;

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
addRequired(iP, 'vVecs', ...
    @(x) assert(isnumeric(x) || iscellnumeric(x), ...
                ['vVecs must be either a numeric array', ...
                    'or a cell array of numeric arrays!']));
addRequired(iP, 'siMs', ...
    @(x) validateattributes(x, {'numeric'}, {'positive', 'vector'}));

% Add parameter-value pairs to the Input Parser
addParameter(iP, 'PlotAllFlag', plotAllFlagDefault, ...
    @(x) validateattributes(x, {'logical', 'numeric'}, {'binary'}));
addParameter(iP, 'PlotCombinedFlag', plotCombinedFlagDefault, ...
    @(x) validateattributes(x, {'logical', 'numeric'}, {'binary'}));
addParameter(iP, 'PlotSpikeDetectionFlag', plotSpikeDetectionFlagDefault, ...
    @(x) validateattributes(x, {'logical', 'numeric'}, {'binary'}));
addParameter(iP, 'PlotSpikeDensityFlag', plotSpikeDensityFlagDefault, ...
    @(x) validateattributes(x, {'logical', 'numeric'}, {'binary'}));
addParameter(iP, 'PlotSpikeHistogramFlag', plotSpikeHistogramFlagDefault, ...
    @(x) validateattributes(x, {'logical', 'numeric'}, {'binary'}));
addParameter(iP, 'PlotAutoCorrFlag', plotAutoCorrFlagDefault, ...
    @(x) validateattributes(x, {'logical', 'numeric'}, {'binary'}));
addParameter(iP, 'PlotRawFlag', plotRawFlagDefault, ...
    @(x) validateattributes(x, {'logical', 'numeric'}, {'binary'}));
addParameter(iP, 'PlotRasterFlag', plotRasterFlagDefault, ...
    @(x) validateattributes(x, {'logical', 'numeric'}, {'binary'}));
addParameter(iP, 'PlotMeasuresFlag', plotMeasuresFlagDefault, ...
    @(x) validateattributes(x, {'logical', 'numeric'}, {'binary'}));
addParameter(iP, 'OutFolder', outFolderDefault, ...
    @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
addParameter(iP, 'FileBase', fileBaseDefault, ...
    @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
addParameter(iP, 'StimStartMs', stimStartMsDefault, ...
    @(x) validateattributes(x, {'numeric'}, {'scalar'}));
addParameter(iP, 'PulseVectors', pulseVectorsDefault, ...
    @(x) assert(isnumeric(x) || iscellnumeric(x), ...
                ['PulseVectors must be either a numeric array', ...
                    'or a cell array of numeric arrays!']));
addParameter(iP, 'PhaseBoundaries', phaseBoundariesDefault, ...
    @(x) validateattributes(x, {'numeric'}, {'2d'}));
addParameter(iP, 'tVecs', tVecsDefault, ...
    @(x) assert(isnumeric(x) || iscellnumeric(x), ...
                ['tVecs must be either a numeric array', ...
                    'or a cell array of numeric arrays!']));

% Read from the Input Parser
parse(iP, vVecs, siMs, varargin{:});
plotAllFlag = iP.Results.PlotAllFlag;
plotCombinedFlag = iP.Results.PlotCombinedFlag;
plotSpikeDetectionFlag = iP.Results.PlotSpikeDetectionFlag;
plotSpikeDensityFlag = iP.Results.PlotSpikeDensityFlag;
plotSpikeHistogramFlag = iP.Results.PlotSpikeHistogramFlag;
plotAutoCorrFlag = iP.Results.PlotAutoCorrFlag;
plotRawFlag = iP.Results.PlotRawFlag;
plotRasterFlag = iP.Results.PlotRasterFlag;
plotMeasuresFlag = iP.Results.PlotMeasuresFlag;
outFolder = iP.Results.OutFolder;
fileBase = iP.Results.FileBase;
stimStartMs = iP.Results.StimStartMs;
pulseVectors = iP.Results.PulseVectors;
phaseBoundaries = iP.Results.PhaseBoundaries;
tVecs = iP.Results.tVecs;

%% Preparation
% Set default flags
fprintf('Setting default flags for %s ...\n', fileBase);
[plotSpikeDetectionFlag, plotSpikeDensityFlag, ...
plotSpikeHistogramFlag, plotAutoCorrFlag, ...
plotRawFlag, plotRasterFlag, plotMeasuresFlag] = ...
    argfun(@(x) set_default_flag(x, plotAllFlag), ...
                plotSpikeDetectionFlag, plotSpikeDensityFlag, ...
                plotSpikeHistogramFlag, plotAutoCorrFlag, ...
                plotRawFlag, plotRasterFlag, plotMeasuresFlag);

% Count the number of vectors
nVectors = count_vectors(vVecs);

% Count the number of samples for each vector
nSamples = count_samples(vVecs);

% Match time vector(s) with sampling interval(s) and number(s) of samples
[tVecs, siMs, nSamples] = match_time_info(tVecs, siMs, nSamples);

% Count the number of measures to plot
nMeasures = numel(measuresToPlot);

% Initialize figures array
figs = gobjects(nMeasures + 3, 1);

% Create a figure title base
titleBase = replace(fileBase, '_', '\_');

%% Do the job
% Detect stimulation start time if not provided
%   Otherwise find the corresponding index in the time vector
fprintf('Detecting stimulation start for %s ...\n', fileBase);
[stimParams, stimData] = ...
    parse_stim(pulseVectors, 'SamplingIntervalMs', siMs, ...
                    'StimStartMs', stimStartMs, 'tVecs', tVecs);

idxStimStart = stimParams.idxStimStart;
stimStartMs = stimParams.stimStartMs;

% Compute the minimum delay in samples
minDelaySamples = round(minDelayMs ./ siMs);

% Find the starting index for detecting a spike
idxDetectStart = idxStimStart + minDelaySamples;

% Construct default baseline windows
if isempty(baseWindows)
    fprintf('Constructing baseline window for %s ...\n', fileBase);
    baseWindows = compute_time_window(tVecs, 'TimeEnd', stimStartMs);
end

% Determine a slice-dependent signal-to-noise ratio if not provided
%   Note: This assumes all sweeps have the same protocol
if isempty(signal2Noise)
    fprintf('Determining signal-to-noise ratio for %s ...\n', fileBase);
    signal2Noise = compute_default_signal2noise(vVecs, siMs, 'tVecs', tVecs, ...
                        'IdxDetectStart', idxDetectStart, ...
                        'BaseWindows', baseWindows, ...
                        'FiltFreq', filtFreq, ...
                        'RelSnrThres2Max', relSnrThres2Max);
end

% Force as a cell array of vectors
[vVecs, tVecs, baseWindows] = ...
    argfun(@force_column_cell, vVecs, tVecs, baseWindows);

% Parse all of them in a parfor loop
fprintf('Parsing recording for %s ...\n', fileBase);
parsedParamsCell = cell(nVectors, 1);
parsedDataCell = cell(nVectors, 1);
parfor iVec = 1:nVectors
%for iVec = 1:nVectors
%for iVec = 1:1
    [parsedParamsCell{iVec}, parsedDataCell{iVec}] = ...
        parse_multiunit_helper(iVec, vVecs{iVec}, tVecs{iVec}, siMs(iVec), ...
                                idxStimStart(iVec), stimStartMs(iVec), ...
                                baseWindows{iVec}, ...
                                filtFreq, filterWidthMs, ...
                                minDelayMs, binWidthMs, ...
                                resolutionMs, signal2Noise, ...
                                minBurstLengthMs, maxInterBurstIntervalMs, ...
                                minSpikeRateInBurstHz, minRelProm, ...
                                fileBase, titleBase, phaseBoundaries);
end

% Convert to a struct array
%   Note: This removes all entries that are empty
[parsedParamsStruct, parsedDataStruct] = ...
    argfun(@(x) [x{:}], parsedParamsCell, parsedDataCell);

% Convert to a table
[parsedParams, parsedData] = ...
    argfun(@(x) struct2table(x, 'AsArray', true), ...
            parsedParamsStruct, parsedDataStruct);

% Save the parameters table
writetable(parsedParams, fullfile(outFolder, [fileBase, '_params.csv']));

%% Prepare for plotting
% Determine zoom windows for multi-trace plots
if plotRawFlag || plotRasterFlag || plotSpikeDensityFlag || plotCombinedFlag
    % Retrieve params
    stimStartSec = parsedParams.stimStartSec;
    detectStartSec = parsedParams.detectStartSec;
    firstSpikeSec = parsedParams.firstSpikeSec;

    % Set zoom windows
    zoomWin1 = mean(stimStartSec) + zoomWinRelStimStartSec;
    zoomWin2 = mean(detectStartSec) + zoomWinRelDetectStartSec;
    meanFirstSpike = nanmean(firstSpikeSec);
    if ~isnan(meanFirstSpike)
        zoomWin3 = meanFirstSpike + zoomWinRelFirstSpikeSec;
    else
        zoomWin3 = zoomWinRelFirstSpikeSec;
    end

    % Combine zoom windows
    zoomWinsMulti = [zoomWin1, zoomWin2, zoomWin3];
end

%% Plot spike detection figures
if plotSpikeDetectionFlag
    fprintf('Plotting all spike detection plots for %s ...\n', fileBase);

    % Create output directory
    outFolderSpikeDetection = fullfile(outFolder, spikeDetectionDir);

    % Plot and save figures
    plot_all_spike_detections(parsedData, parsedParams, outFolderSpikeDetection, nVectors);
end

%% Plot spike histograms
if plotSpikeHistogramFlag
    fprintf('Plotting all spike histograms for %s ...\n', fileBase);
    % Create output directory
    outFolderHist = fullfile(outFolder, spikeHistDir);

    % Plot and save figures
    plot_all_spike_histograms(parsedData, parsedParams, outFolderHist, nVectors);
end

%% Plot autocorrelograms
if plotAutoCorrFlag
    fprintf('Plotting all autocorrelograms for %s ...\n', fileBase);
    % Create output directories
    outFolderAutoCorr = fullfile(outFolder, autoCorrDir);
    outFolderAcf = fullfile(outFolder, acfDir);

    % Plot and save figures
    plot_all_autocorrelograms(parsedData, parsedParams, ...
                                outFolderAutoCorr, outFolderAcf, nVectors);
end

%% Plot raw traces
if plotRawFlag
    fprintf('Plotting raw traces for %s ...\n', fileBase);

    % Create a figure base
    figBaseRaw = fullfile(outFolder, rawDir, [fileBase, '_raw']);

    % Plot figure
    figs(1) = plot_raw_multiunit(parsedData, parsedParams, ...
                                    phaseBoundaries, titleBase, ...
                                    yAmountToStagger,nVectors);

    % Save the figure zoomed to several x limits
    save_all_zooms(figs(1), figBaseRaw, zoomWinsMulti);
end

%% Plot raster plot
if plotRasterFlag
    fprintf('Plotting raster plot for %s ...\n', fileBase);

    % Create a figure base
    figBaseRaster = fullfile(outFolder, rasterDir, [fileBase, '_raster']);

    % Plot figure
    figs(2) = plot_raster_multiunit(parsedData, parsedParams, ...
                                    phaseBoundaries, titleBase);

    % Save the figure zoomed to several x limits
    save_all_zooms(figs(2), figBaseRaster, zoomWinsMulti);
end

%% Plot spike den plot_all_spike_detectionssity
if plotSpikeDensityFlag
    fprintf('Plotting spike density plot for %s ...\n', fileBase);

    % Create a figure base
    figBaseSpikeDensity = fullfile(outFolder, spikeDensityDir, ...
                                    [fileBase, '_spike_density']);

    % Plot figure
    figs(3) = plot_spike_density_multiunit(parsedData, parsedParams, ...
                                         phaseBoundaries, titleBase);

    % Save the figure zoomed to several x limits
    save_all_zooms(figs(3), figBaseSpikeDensity, zoomWinsMulti);
end

%% Plot time series of measures
if plotMeasuresFlag
    fprintf('Plotting time series of measures for %s ...\n', fileBase);    

    % Create output directory and subdirectories for each measure
    outFolderMeasures = fullfile(outFolder, measuresDir);

    % Check if output directory exists
    check_dir(outFolderMeasures);
    check_subdir(outFolderMeasures, measuresToPlot);

    % Create full figure paths
    figPathsMeasures = fullfile(outFolderMeasures, measuresToPlot, ...
                                strcat(fileBase, '_', measuresToPlot));

    % Create custom figure titles
    figTitlesMeasures = strcat(measuresToPlot, [' for ', titleBase]);

    % Plot table and save figures
    figs(4:(nMeasures + 3)) = ...
        plot_table(parsedParams, 'PlotType', plotTypeMeasures, ...
                    'VariableNames', measuresToPlot, ...
                    'PLabel', 'Time (min)', 'FigNames', figPathsMeasures, ...
                    'FigTitles', figTitlesMeasures, ...
                    'PBoundaries', phaseBoundaries, ...
                    'PlotSeparately', true);
end

%% Plot combined plots
if plotCombinedFlag
    fprintf('Plotting a combined plot for %s ...\n', fileBase);    

    % Create output directory and subdirectories for each measure
    outFolderCombined = fullfile(outFolder, combinedDir);

    % Create a figure base
    figBaseCombined = fullfile(outFolderCombined, [fileBase, '_combined']);

    % Create a new figure
    figCombined = figure;
    
    % Expand the position of the figure
    % TODO: Make this a function
    positionOrig = figCombined.Position;
    positionNew = positionOrig;
    positionNew(1) = positionOrig(1) - positionOrig(3);
    positionNew(3) = 3 * positionOrig(3);
    figCombined.Position = positionNew;

    % Plot raw data
    subplot(1, 3, 1);
    plot_raw_multiunit(parsedData, parsedParams, ...
                        phaseBoundaries, titleBase, ...
                        yAmountToStagger, nVectors);

    % Plot spike density
    subplot(1, 3, 2);
    plot_spike_density_multiunit(parsedData, parsedParams, ...
                                 phaseBoundaries, titleBase, nVectors);

    % Plot oscillation duration
    subplot(1, 3, 3);
    plot_bar(parsedParams.oscDurationMs, ...
                'ForceVectorAsRow', false, ...
                'ReverseOrder', true, ...
                'BarDirection', 'horizontal', ...
                'PValues', pValues, ...
                'PTicks', pTicks, 'PTickLabels', pTickLabels, ...
                'PTickAngle', pTickAngle, ...
                'PLabel', 'Time (min)', ...
                'ReadoutLabel', 'Oscillation Duration (s)', ...
                'PBoundaries', phaseBoundaries, ...
                otherArguments)
end

%% Outputs
varargout{1} = parsedParams;
varargout{2} = parsedData;
varargout{3} = figs;

fprintf('%s analyzed! ...\n\n', fileBase);  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function signal2Noise = compute_default_signal2noise(vVecs, siMs, varargin)
%% Computes a default signal-to-noise ratio
% Usage: signal2Noise = compute_default_signal2noise(vVecs, siMs, tVecs (opt), varargin)
% Requires:
%       cd/compute_baseline_noise.m
%       cd/compute_time_window.m
%       cd/count_samples.m
%       cd/extract_elements.m
%       cd/extract_subvectors.m
%       cd/force_matrix.m
%       cd/freqfilter.m
%       cd/match_time_info.m

% File History:
% 2019-06-02 Created by Adam Lu
% TODO: Pull out to its own function and use in detect_spikes_multiunit.m

%% Hard-coded constants
MS_PER_S = 1000;

% Must be consistent with detect_spikes_multiunit.m   
artifactLengthMs = 25;
defaultRelSnrThres2Max = 0.1;

%% Default values for optional arguments
idxStimStartDefault = 1;        % stim at first time point by default
idxDetectStartDefault = [];     % set later
baseWindowsDefault = [];        % set later
filtFreqDefault = NaN;          % no bandpass filter by default 
minDelayMsDefault = [];         % set later
relSnrThres2MaxDefault = [];    % set later
tVecsDefault = [];              % set later

%% Deal with arguments
% Check number of required arguments
if nargin < 2
    error(create_error_for_nargin(mfilename));
end

% Set up Input Parser Scheme
iP = inputParser;
iP.FunctionName = mfilename;

% Add required inputs to the Input Parser
addRequired(iP, 'vVecs', ...
    @(x) assert(isnumeric(x) || iscellnumeric(x), ...
                ['vVecs must be either a numeric array', ...
                    'or a cell array of numeric arrays!']));
addRequired(iP, 'siMs', ...
    @(x) validateattributes(x, {'numeric'}, {'positive', 'vector'}));

% Add parameter-value pairs to the Input Parser
addParameter(iP, 'IdxStimStart', idxStimStartDefault, ...
    @(x) validateattributes(x, {'numeric'}, {'positive', 'integer'}));
addParameter(iP, 'IdxDetectStart', idxDetectStartDefault, ...
    @(x) validateattributes(x, {'numeric'}, {'2d'}));
addParameter(iP, 'BaseWindows', baseWindowsDefault, ...
    @(x) assert(isnumeric(x) || iscellnumeric(x), ...
                ['baseWindows must be either a numeric array ', ...
                    'or a cell array of numeric arrays!']));
addParameter(iP, 'FiltFreq', filtFreqDefault, ...
    @(x) isnumeric(x) && isvector(x) && numel(x) <= 2);
addParameter(iP, 'MinDelayMs', minDelayMsDefault, ...
    @(x) validateattributes(x, {'numeric'}, {'2d'}));
addParameter(iP, 'RelSnrThres2Max', relSnrThres2MaxDefault, ...
    @(x) validateattributes(x, {'numeric'}, {'2d'}));
addParameter(iP, 'tVecs', tVecsDefault, ...
    @(x) assert(isnumeric(x) || iscellnumeric(x), ...
                ['tVecs must be either a numeric array', ...
                    'or a cell array of numeric arrays!']));

% Read from the Input Parser
parse(iP, vVecs, siMs, varargin{:});
idxStimStart = iP.Results.IdxStimStart;
idxDetectStart = iP.Results.IdxDetectStart;
baseWindows = iP.Results.BaseWindows;
filtFreq = iP.Results.FiltFreq;
minDelayMs = iP.Results.MinDelayMs;
relSnrThres2Max = iP.Results.RelSnrThres2Max;
tVecs = iP.Results.tVecs;

%% Preparation
% Count the number of samples for each vector
nSamples = count_samples(vVecs);

% Match time vector(s) with sampling interval(s) and number(s) of samples
[tVecs, siMs, nSamples] = match_time_info(tVecs, siMs, nSamples);

% Compute the average sampling interval in ms
siMsAvg = mean(siMs);

% Set default relative signal-2-noise ratio from threshold and maximum
if isempty(relSnrThres2Max)
    relSnrThres2Max = defaultRelSnrThres2Max;
end

% Set default minimum delay in ms
if isempty(minDelayMs)
    minDelayMs = artifactLengthMs;
end

% Find the starting index for detecting a spike
if isempty(idxDetectStart)
    % Compute the minimum delay in samples
    minDelaySamples = round(minDelayMs ./ siMs);

    % Find the starting index for detecting a spike
    idxDetectStart = idxStimStart + minDelaySamples;
end

% Construct default baseline windows
if isempty(baseWindows)
    % Convert to the time of stimulation start
    stimStartMs = extract_elements(tVecs, 'Index', idxStimStart);

    % Compute baseline windows
    baseWindows = compute_time_window(tVecs, 'TimeEnd', stimStartMs);
end

%% Do the job
% Force as a matrix
tVecs = force_matrix(tVecs);
vVecs = force_matrix(vVecs);

% Bandpass filter if requested
if ~isnan(filtFreq)
    siSeconds = siMsAvg / MS_PER_S;    
    vVecsFilt = freqfilter(vVecs, filtFreq, siSeconds, 'FilterType', 'band');
else
    vVecsFilt = vVecs;
end

% Compute all instantaneous slopes in uV/ms == mV/s
slopes = diff(vVecsFilt) ./ siMsAvg;

% Compute baseline slope noise in mV/s
baseSlopeNoise = compute_baseline_noise(slopes, tVecs(1:(end-1), :), ...
                                        baseWindows);

% Compute the average baseline slope noise
avgBaseSlopeNoise = mean(baseSlopeNoise);

% Extract slopes after detection start
slopesAfterDetectStart = ...
    extract_subvectors(slopes, 'IndexStart', idxDetectStart);

% Compute the average maximum slope after detection start
avgSlopeAfterDetectStart = ...
    mean(extract_elements(slopesAfterDetectStart, 'max'));

% Compute a default signal-to-noise ratio
signal2Noise = 1 + relSnrThres2Max * ...
                (avgSlopeAfterDetectStart / avgBaseSlopeNoise - 1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [parsedParams, parsedData] = ...
                parse_multiunit_helper(iVec, vVec, tVec, siMs, ...
                                idxStimStart, stimStartMs, baseWindow, ...
                                filtFreq, filterWidthMs, ...
                                minDelayMs, binWidthMs, ...
                                resolutionMs, signal2Noise, ...
                                minBurstLengthMs, maxInterBurstIntervalMs, ...
                                minSpikeRateInBurstHz, minRelProm, ...
                                fileBase, figTitleBase, phaseBoundaries)

% Parse a single multiunit recording

%% Hard-coded constants
MS_PER_S = 1000;

%% Preparation
% Compute the bin width in seconds
binWidthSec = binWidthMs ./ MS_PER_S;

% Compute the number of phase boundaries
nBoundaries = numel(phaseBoundaries);

% Determine which phase number this sweep belongs to
if nBoundaries > 0
    % For the first n - 1 sets, use find
    phaseNumber = find(phaseBoundaries > iVec, 1, 'first');

    % For the last phase, use numel(phaseBoundaries) + 1
    if isempty(phaseNumber)
        phaseNumber = numel(phaseBoundaries) + 1;
    end
else
    phaseNumber = NaN;
end

% Create phase names
if nBoundaries == 2
    if phaseNumber == 1
        phaseName = 'baseline';
    elseif phaseNumber == 2
        phaseName = 'washon';
    elseif phaseNumber == 3
        phaseName = 'washoff';
    end
else
    phaseName = '';
end

% Compute the maximum and minimum times
maxTimeMs = tVec(end);
minTimeMs = tVec(1);

%% Detect spikes
% Detect spikes (bandpass filter before detection)
%   Note: This checks whether each inflection point 
%           crosses a sweep-dependent slope threshold, 
%           given a slice-dependent signal-to-noise ratio
[spikesParams, spikesData] = ...
    detect_spikes_multiunit(vVec, siMs, ...
                            'tVec', tVec, 'IdxStimStart', idxStimStart, ...
                            'FiltFreq', filtFreq, ...
                            'BaseWindow', baseWindow, ...
                            'MinDelayMs', minDelayMs, ...
                            'Signal2Noise', signal2Noise);

idxDetectStart = spikesParams.idxDetectStart;
detectStartMs = spikesParams.detectStartMs;
baseSlopeNoise = spikesParams.baseSlopeNoise;
slopeThreshold = spikesParams.slopeThreshold;
nSpikesTotal = spikesParams.nSpikesTotal;
idxFirstSpike = spikesParams.idxFirstSpike;
firstSpikeMs = spikesParams.firstSpikeMs;
vMin = spikesParams.vMin;
vMax = spikesParams.vMax;
vRange = spikesParams.vRange;
slopeMin = spikesParams.slopeMin;
slopeMax = spikesParams.slopeMax;
slopeRange = spikesParams.slopeRange;

vVecFilt = spikesData.vVecFilt;
slopes = spikesData.slopes;
idxSpikes = spikesData.idxSpikes;
spikeTimesMs = spikesData.spikeTimesMs;

%% Compute spike density
spikeDensityHz = ...
    compute_spike_density(spikeTimesMs, 'TimeWindow', [0, tVec(end)], ...
                            'BinWidth', binWidthMs, ...
                            'Resolution', resolutionMs, ...
                            'TimeUnits', 'ms');

%% Compute the spike histogram, spikes per burst & oscillation duration
[spHistParams, spHistData] = ...
    compute_spike_histogram(spikeTimesMs, 'StimStartMs', stimStartMs, ...
                            'BinWidthMs', binWidthMs, ...
                            'MinBurstLengthMs', minBurstLengthMs, ...
                            'MaxInterBurstIntervalMs', maxInterBurstIntervalMs, ...
                            'MinSpikeRateInBurstHz', minSpikeRateInBurstHz);

nBins = spHistParams.nBins;
halfNBins = spHistParams.halfNBins;
histLeftMs = spHistParams.histLeftMs;
nBurstsTotal = spHistParams.nBurstsTotal;
nBurstsIn10s = spHistParams.nBurstsIn10s;
nBurstsInOsc = spHistParams.nBurstsInOsc;
iBinLastOfLastBurst = spHistParams.iBinLastOfLastBurst;
iBinLastOfLastBurstIn10s = spHistParams.iBinLastOfLastBurstIn10s;
iBinLastOfLastBurstInOsc = spHistParams.iBinLastOfLastBurstInOsc;
nSpikesPerBurst = spHistParams.nSpikesPerBurst;
nSpikesPerBurstIn10s = spHistParams.nSpikesPerBurstIn10s;
nSpikesPerBurstInOsc = spHistParams.nSpikesPerBurstInOsc;
nSpikesIn10s = spHistParams.nSpikesIn10s;
nSpikesInOsc = spHistParams.nSpikesInOsc;
timeOscEndMs = spHistParams.timeOscEndMs;
oscDurationMs = spHistParams.oscDurationMs;

spikeCounts = spHistData.spikeCounts;
edgesMs = spHistData.edgesMs;
iBinBurstStarts = spHistData.iBinBurstStarts;
iBinBurstEnds = spHistData.iBinBurstEnds;
iBinBurstIn10sStarts = spHistData.iBinBurstIn10sStarts;
iBinBurstIn10sEnds = spHistData.iBinBurstIn10sEnds;
iBinBurstInOscStarts = spHistData.iBinBurstInOscStarts;
iBinBurstInOscEnds = spHistData.iBinBurstInOscEnds;
spikeCountsEachBurst = spHistData.spikeCountsEachBurst;
spikeCountsEachBurstIn10s = spHistData.spikeCountsEachBurstIn10s;
spikeCountsEachBurstInOsc = spHistData.spikeCountsEachBurstInOsc;
timeBurstStartsMs = spHistData.timeBurstStartsMs;
timeBurstEndsMs = spHistData.timeBurstEndsMs;
timeBurstIn10sStartsMs = spHistData.timeBurstIn10sStartsMs;
timeBurstIn10sEndsMs = spHistData.timeBurstIn10sEndsMs;
timeBurstInOscStartsMs = spHistData.timeBurstInOscStartsMs;
timeBurstInOscEndsMs = spHistData.timeBurstInOscEndsMs;

%% Compute the autocorrelogram, oscillation period & oscillatory index
% TODO: compute_autocorrelogram.m
if nSpikesTotal == 0
    oscIndex1 = 0;
    oscIndex2 = 0;
    oscIndex3 = NaN;
    oscIndex4 = 0;
    oscPeriod1Ms = 0;
    oscPeriod2Ms = 0;
    minOscPeriod2Bins = 0;
    maxOscPeriod2Bins = 0;
    autoCorr = [];
    acf = [];
    acfFiltered = [];
    acfFilteredOfInterest = [];
    indPeaks = [];
    indTroughs = [];
    ampPeaks = [];
    ampTroughs = [];
    halfPeriodsToMultiple = [];
else
    % Compute an unnormalized autocorrelogram in Hz^2
    autoCorr = xcorr(spikeCounts, 'unbiased') ./ binWidthSec ^ 2;

    % Take just half of the positive side to get the autocorrelation function
    acf = autoCorr(nBins:(nBins + halfNBins));

    % Compute a normalized autocorrelation function
    % autocorr(spikeCounts, nBins - 1);
    % acf = autocorr(spikeCounts, nBins - 1);

    % Smooth the autocorrelation function with a moving-average filter
    acfFiltered = movingaveragefilter(acf, filterWidthMs, binWidthMs);

    % Record the amplitude of the primary peak
    ampPeak1 = acfFiltered(1);

    % Compute the oscillation duration in bins
    oscDurationBins = floor(oscDurationMs ./ binWidthMs);

    % Find the maximum bin of interest
    maxBinOfInterest = min(1 + oscDurationBins, numel(acfFiltered));
    
    % Restrict the autocorrelation function to oscillation duration
    acfFilteredOfInterest = acfFiltered(1:maxBinOfInterest);

    % Find the index and amplitude of peaks within oscillation duration
    if numel(acfFilteredOfInterest) > 3
        [peakAmp, peakInd] = ...
            findpeaks(acfFilteredOfInterest, ...
                        'MinPeakProminence', minRelProm * ampPeak1);

        % Record all peak indices and amplitudes
        indPeaks = [1; peakInd];
        ampPeaks = [ampPeak1; peakAmp];
    else
        indPeaks = 1;
        ampPeaks = ampPeak1;
    end

    % Compute the number of peaks
    nPeaks = numel(indPeaks);

    % Compute the lags of peaks in bins
    if nPeaks <= 1
        lagsPeaksBins = [];
    else
        lagsPeaksBins = indPeaks(2:end) - indPeaks(1);
    end

    % Compute the oscillation period
    %   Note: TODO
    % TODO: Try both:
    %   1. Use fminsearch on the distance to multiples function
    %   2. Use the largest peak in the frequency spectrum
    if nPeaks <= 1
        oscPeriod1Bins = 0;
        oscPeriod2Bins = 0;
        minOscPeriod2Bins = 0;
        maxOscPeriod2Bins = 0;
    else
        % Compute the oscillation period version 1
        %   Note: The lag between the primary peak and the second peak
        oscPeriod1Bins = indPeaks(2) - indPeaks(1);

        % Compute the oscillation period version 2
        %   Note: TODO
        if nPeaks <= 2
            % Just use the lag between first two peaks
            oscPeriod2Bins = oscPeriod1Bins;
            minOscPeriod2Bins = oscPeriod1Bins;
            maxOscPeriod2Bins = oscPeriod1Bins;
        else
            % Create a function for computing the average distance
            %   of each peak lag to a multiple of x
            average_distance_for_a_period = ...
                @(x) compute_average_distance_to_a_multiple(lagsPeaksBins, x);

            % Define the range the actual oscillation period can lie in
            minOscPeriod2Bins = oscPeriod1Bins * 2 / 3;
            maxOscPeriod2Bins = oscPeriod1Bins * 3 / 2;

            % Find the oscillation period in bins by looking for the 
            %   value of x that minimizes myFun, using the range
            %   oscPeriod1Bins / 3 to oscPeriod1Bins * 3
            oscPeriod2Bins = ...
                fminbnd(average_distance_for_a_period, ...
                        minOscPeriod2Bins, maxOscPeriod2Bins);
        end
    end

    % Convert to ms
    oscPeriod1Ms = oscPeriod1Bins .* binWidthMs;
    oscPeriod2Ms = oscPeriod2Bins .* binWidthMs;

    % Find the troughs
    if numel(indPeaks) <= 1
        indTroughs = [];
        ampTroughs = [];
    else
        % Find the indices and amplitudes of the troughs in between 
        %   each pair of peaks
        [ampTroughs, indTroughs] = ...
            find_troughs_from_peaks(acfFilteredOfInterest, indPeaks);
    end

    % Compute the oscillatory index version 1
    %   Note: This is defined in Sohal's paper 
    %           as the ratio of the difference between 
    %           the average of first two peaks and the first trough
    %           and the average of first two peaks
    if numel(indPeaks) <= 1
        oscIndex1 = 0;
    else
        % Compute the average amplitude of the first two peaks
        ampAvgFirstTwoPeaks = mean(ampPeaks(1:2));

        % Compute the oscillatory index
        oscIndex1 = (ampAvgFirstTwoPeaks - ampTroughs(1)) / ampAvgFirstTwoPeaks;
    end

    % Compute the oscillatory index version 2
    %   Note: This is the average of all oscillatory indices as defined
    %           by Sohal's paper between adjacent peaks
    if numel(indPeaks) <= 1
        oscIndex2 = 0;
    else
        % Compute the average amplitudes between adjacent peaks
        ampAdjPeaks = mean([ampPeaks(1:(end-1)), ampPeaks(2:end)], 2);

        % Take the average of oscillatory indices as defined by Sohal's paper
        oscIndex2 = mean((ampAdjPeaks - ampTroughs) ./ ampAdjPeaks);
    end

    % Compute the oscillatory index version 3
    %   Note: This is 1 minus the average of all distances 
    %           (normalized by half the oscillation period)
    %           to the closest multiple of the period over all peaks from the
    %           2nd and beyond. However, if there are less than two peaks,
    %           consider it non-oscillatory
    if numel(indPeaks) <= 2
        % If there are no more than two peaks, don't compute
        halfPeriodsToMultiple = [];
        oscIndex3 = NaN;
    else
        % Compute the distance to the closest multiple of the oscillation period 
        %   for each peak from the 2nd and beyond,
        %   normalize by half the oscillation period
        [averageDistance, halfPeriodsToMultiple] = ...
            compute_average_distance_to_a_multiple(lagsPeaksBins, ...
                                                    oscPeriod2Bins);

        % Compute the oscillatory index 
        oscIndex3 = 1 - averageDistance;
    end

    % Compute the oscillatory index version 4
    %   Note: This is 
    if numel(indPeaks) <= 1
        oscIndex4 = 0;
    else
        % Get the amplitude of the primary peak
        primaryPeakAmp = ampPeaks(1);

        % Find the peak with maximum amplitude other than the primary peak
        %   call this the "secondary peak"
        [~, iSecPeak] = max(ampPeaks(2:end));

        % Get the amplitude of the "secondary peak"
        secPeakAmp = ampPeaks(iSecPeak + 1);

        % Get the minimum trough amplitude between the primary peak
        %   and the secondary peak
        troughAmp = min(ampTroughs(1:iSecPeak));

        % The oscillatory index is the ratio between 
        %   the difference of maximum peak to trough in between
        %   and the different of primary peak to trough in between
        oscIndex4 = (secPeakAmp - troughAmp) / (primaryPeakAmp - troughAmp);
    end
end

%% For plotting later
% Modify the figure base
figPathBase = [fileBase, '_trace', num2str(iVec)];
figTitleBase = [figTitleBase, '\_trace', num2str(iVec)];

% Convert to seconds
[siSeconds, maxTimeSec, minTimeSec, ...
    stimStartSec, detectStartSec, firstSpikeSec, ...
    histLeftSec, timeOscEndSec, oscDurationSec, ...
    maxInterBurstIntervalSec, spikeTimesSec, edgesSec, ...
    timeBurstStartsSec, timeBurstEndsSec] = ...
    argfun(@(x) x ./ MS_PER_S, ...
            siMs, maxTimeMs, minTimeMs, ...
            stimStartMs, detectStartMs, firstSpikeMs, ...
            histLeftMs, timeOscEndMs, oscDurationMs, ...
            maxInterBurstIntervalMs, spikeTimesMs, edgesMs, ...
            timeBurstInOscStartsMs, timeBurstInOscEndsMs);

%% Store in outputs
parsedParams.phaseNumber = phaseNumber;
parsedParams.phaseName = phaseName;
parsedParams.filtFreq = filtFreq;
parsedParams.signal2Noise = signal2Noise;
parsedParams.minDelayMs = minDelayMs;
parsedParams.binWidthMs = binWidthMs;
parsedParams.binWidthSec = binWidthSec;
parsedParams.filterWidthMs = filterWidthMs;
parsedParams.minRelProm = minRelProm;
parsedParams.minSpikeRateInBurstHz = minSpikeRateInBurstHz;
parsedParams.minBurstLengthMs = minBurstLengthMs;
parsedParams.maxInterBurstIntervalMs = maxInterBurstIntervalMs;
parsedParams.maxInterBurstIntervalSec = maxInterBurstIntervalSec;
parsedParams.resolutionMs = resolutionMs;
parsedParams.siMs = siMs;
parsedParams.minTimeMs = minTimeMs;
parsedParams.maxTimeMs = maxTimeMs;
parsedParams.siSeconds = siSeconds;
parsedParams.minTimeSec = minTimeSec;
parsedParams.maxTimeSec = maxTimeSec;
parsedParams.idxStimStart = idxStimStart;
parsedParams.stimStartMs = stimStartMs;
parsedParams.stimStartSec = stimStartSec;
parsedParams.baseWindow = baseWindow;
parsedParams.baseSlopeNoise = baseSlopeNoise;
parsedParams.slopeThreshold = slopeThreshold;
parsedParams.idxDetectStart = idxDetectStart;
parsedParams.detectStartMs = detectStartMs;
parsedParams.detectStartSec = detectStartSec;
parsedParams.nSpikesTotal = nSpikesTotal;
parsedParams.idxFirstSpike = idxFirstSpike;
parsedParams.firstSpikeMs = firstSpikeMs;
parsedParams.firstSpikeSec = firstSpikeSec;
parsedParams.vMin = vMin;
parsedParams.vMax = vMax;
parsedParams.vRange = vRange;
parsedParams.slopeMin = slopeMin;
parsedParams.slopeMax = slopeMax;
parsedParams.slopeRange = slopeRange;
parsedParams.nBins = nBins;
parsedParams.halfNBins = halfNBins;
parsedParams.histLeftMs = histLeftMs;
parsedParams.histLeftSec = histLeftSec;
parsedParams.nSpikesPerBurst = nSpikesPerBurst;
parsedParams.nSpikesPerBurstIn10s = nSpikesPerBurstIn10s;
parsedParams.nSpikesPerBurstInOsc = nSpikesPerBurstInOsc;
parsedParams.nSpikesIn10s = nSpikesIn10s;
parsedParams.nSpikesInOsc = nSpikesInOsc;
parsedParams.nBurstsTotal = nBurstsTotal;
parsedParams.nBurstsIn10s = nBurstsIn10s;
parsedParams.nBurstsInOsc = nBurstsInOsc;
parsedParams.iBinLastOfLastBurst = iBinLastOfLastBurst;
parsedParams.iBinLastOfLastBurstIn10s = iBinLastOfLastBurstIn10s;
parsedParams.iBinLastOfLastBurstInOsc = iBinLastOfLastBurstInOsc;
parsedParams.timeOscEndMs = timeOscEndMs;
parsedParams.timeOscEndSec = timeOscEndSec;
parsedParams.oscDurationMs = oscDurationMs;
parsedParams.oscDurationSec = oscDurationSec;
parsedParams.oscIndex1 = oscIndex1;
parsedParams.oscIndex2 = oscIndex2;
parsedParams.oscIndex3 = oscIndex3;
parsedParams.oscIndex4 = oscIndex4;
parsedParams.oscPeriod1Ms = oscPeriod1Ms;
parsedParams.oscPeriod2Ms = oscPeriod2Ms;
parsedParams.minOscPeriod2Bins = minOscPeriod2Bins;
parsedParams.maxOscPeriod2Bins = maxOscPeriod2Bins;
parsedParams.figPathBase = figPathBase;
parsedParams.figTitleBase = figTitleBase;

parsedData.tVec = tVec;
parsedData.vVec = vVec;
parsedData.vVecFilt = vVecFilt;
parsedData.slopes = slopes;
parsedData.idxSpikes = idxSpikes;
parsedData.spikeTimesMs = spikeTimesMs;
parsedData.spikeTimesSec = spikeTimesSec;
parsedData.spikeDensityHz = spikeDensityHz;
parsedData.spikeCounts = spikeCounts;
parsedData.edgesMs = edgesMs;
parsedData.edgesSec = edgesSec;
parsedData.spikeCountsEachBurst = spikeCountsEachBurst;
parsedData.spikeCountsEachBurstIn10s = spikeCountsEachBurstIn10s;
parsedData.spikeCountsEachBurstInOsc = spikeCountsEachBurstInOsc;
parsedData.iBinBurstStarts = iBinBurstStarts;
parsedData.iBinBurstEnds = iBinBurstEnds;
parsedData.iBinBurstIn10sStarts = iBinBurstIn10sStarts;
parsedData.iBinBurstIn10sEnds = iBinBurstIn10sEnds;
parsedData.iBinBurstInOscStarts = iBinBurstInOscStarts;
parsedData.iBinBurstInOscEnds = iBinBurstInOscEnds;
parsedData.timeBurstStartsMs = timeBurstStartsMs;
parsedData.timeBurstEndsMs = timeBurstEndsMs;
parsedData.timeBurstIn10sStartsMs = timeBurstIn10sStartsMs;
parsedData.timeBurstIn10sEndsMs = timeBurstIn10sEndsMs;
parsedData.timeBurstInOscStartsMs = timeBurstInOscStartsMs;
parsedData.timeBurstInOscEndsMs = timeBurstInOscEndsMs;
parsedData.timeBurstStartsSec = timeBurstStartsSec;
parsedData.timeBurstEndsSec = timeBurstEndsSec;
parsedData.autoCorr = autoCorr;
parsedData.acf = acf;
parsedData.acfFiltered = acfFiltered;
parsedData.acfFilteredOfInterest = acfFilteredOfInterest;
parsedData.indPeaks = indPeaks;
parsedData.indTroughs = indTroughs;
parsedData.ampPeaks = ampPeaks;
parsedData.ampTroughs = ampTroughs;
parsedData.halfPeriodsToMultiple = halfPeriodsToMultiple;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [averageDistance, halfPeriodsToMultiple] = ...
                compute_average_distance_to_a_multiple(values, period)

[~, halfPeriodsToMultiple] = ...
    arrayfun(@(x) find_nearest_multiple(period, x, ...
                                    'RelativeToHalfBase', true), values);

averageDistance = mean(halfPeriodsToMultiple);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ampTroughs, indTroughs] = find_troughs_from_peaks(vec, indPeaks)
%% Finds troughs in between given peak indices

nPeaks = numel(indPeaks);

if nPeaks < 2
    % No troughs
    ampTroughs = [];
    indTroughs = [];
else
    % Left peak indices
    indLeftPeak = indPeaks(1:(end-1));

    % Right peak indices
    indRightPeak = indPeaks(2:end);

    % Use the minimums in each interval
    [ampTroughs, indTroughsRel] = ...
        arrayfun(@(x, y) min(vec(x:y)), indLeftPeak, indRightPeak);

    % Compute the original indices
    indTroughs = arrayfun(@(x, y) x + y - 1, indTroughsRel, indLeftPeak);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function vector = prepare_for_plot_horizontal_line(starts, ends)
%% Put in the form [start1, end1, start2, end2, ..., startn, endn]

if isempty(starts) || isempty(ends)
    form1 = [0; 0];
else
    % Put in the form [start1, start2, ..., startn;
    %                   end1,   end2,  ...,  endn]
    form1 = transpose([starts, ends]);
end

% Reshape as a column vector
vector = reshape(form1, [], 1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [fig, ax, lines, markers, raster] = ...
                plot_spike_detection(tVec, vVec, vVecFilt, ...
                                    slopes, idxSpikes, ...
                                    baseSlopeNoise, slopeThreshold, ...
                                    vMin, vMax, vRange, slopeMin, slopeMax, ...
                                    figHandle, figTitle)
%% Plots the spike detection

% Hard-coded constants
barWidth2Range = 1/10;

% Compute the midpoint and bar width for the raster
% barWidth = vRange * barWidth2Range;
barWidth = 1;
% yMid = vMax + barWidth;
yMid = 9;

% Compute y axis limits
yLimits1 = compute_axis_limits([slopeMin, slopeMax], 'y', 'Coverage', 100);
% yLimits1 = [-15, 15];
yLimits2 = compute_axis_limits([vMin, vMax], 'y', 'Coverage', 100);
% yLimits2 = [-10, 10];
yLimits3 = compute_axis_limits([vMin, yMid], 'y', 'Coverage', 100);
% yLimits3 = [-10, 10];

% Initialize graphics object handles
ax = gobjects(3, 1);
lines = gobjects(5, 1);
markers = gobjects(2, 1);

% Make a figure for spike detection
if ~isempty(figHandle)
    fig = figure(figHandle);
else
    fig = figure('Visible', 'off');
end
clf; 

% Plot the slope trace with peaks
ax(1) = subplot(3, 1, 1);
cla; hold on
lines(1) = plot(tVec(1:(end-1)), slopes, 'k');
lines(6) = plot_horizontal_line(baseSlopeNoise, 'Color', 'b', 'LineStyle', '--');
lines(7) = plot_horizontal_line(slopeThreshold, 'Color', 'g', 'LineStyle', '--');
if ~isempty(idxSpikes)
    markers(1) = plot(tVec(idxSpikes - 1), slopes(idxSpikes - 1), 'rx', 'LineWidth', 2);
else
    markers(1) = gobjects(1);
end
ylim(yLimits1);
ylabel('Slope (mV/s)');
title('Detection of peaks in the slope vector');

% Plot the original trace with maximum slope locations
ax(2) = subplot(3, 1, 2);
cla; hold on
lines(2) = plot(tVec, vVec, 'k');
lines(3) = plot(tVec, vVecFilt, 'b');
if ~isempty(idxSpikes)
    markers(2) = plot(tVec(idxSpikes), vVec(idxSpikes), 'rx', 'LineWidth', 2);
else
    markers(2) = gobjects(1);
end
ylim(yLimits2);
ylabel('Voltage (mV)');
title('Corresponding positions in the voltage vector');

% Plot the original trace with spike raster
ax(3) = subplot(3, 1, 3);
cla; hold on
lines(4) = plot(tVec, vVec, 'k');
lines(5) = plot(tVec, vVecFilt, 'b');
raster = plot_raster(tVec(idxSpikes), 'YMid', yMid, 'BarWidth', barWidth, ...
                    'LineWidth', 0.5, 'Colors', {'Red'}, ...
                    'YLimits', 'suppress', 'YTickLocs', 'suppress', ...
                    'YTickLabels', 'suppress');
ylim(yLimits3);
xlabel('Time (ms)');
ylabel('Voltage (mV)');
title('Original voltage vector with spikes');

% Create an overarching title
suptitle(figTitle);

% Link the x axes
linkaxes(ax, 'x');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [histBars, histFig] = ...
                plot_spike_histogram(spikeCounts, edgesSec, durationWindows, ...
                                oscDurationSec, nSpikesInOsc, ...
                                xLimitsHist, yLimitsHist, figTitleBase)


% Plot figure
histFig = figure('Visible', 'off');
hold on;
[histBars, histFig] = ...
    plot_histogram([], 'Counts', spikeCounts, 'Edges', edgesSec, ...
                    'XLimits', xLimitsHist, 'YLimits', yLimitsHist, ...
                    'XLabel', 'Time (seconds)', ...
                    'YLabel', 'Spike Count per 10 ms', ...
                    'FigTitle', ['Spike histogram for ', figTitleBase], ...
                    'FigHandle', histFig);
text(0.5, 0.95, sprintf('Oscillation Duration = %.2g seconds', ...
    oscDurationSec), 'Units', 'normalized');
text(0.5, 0.9, sprintf('Number of spikes in oscillation = %d', ...
    nSpikesInOsc), 'Units', 'normalized');
plot_horizontal_line(0, 'XLimits', durationWindows, ...
                    'Color', 'r', 'LineStyle', '-', 'LineWidth', 2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [autoCorrFig, acfFig, acfLine1, acfLine2, acfFilteredLine] = ...
                plot_autocorrelogram(autoCorr, acf, acfFiltered, indPeaks, ...
                                    indTroughs, ampPeaks, ampTroughs, ...
                                    binWidthSec, nBins, halfNBins, ...
                                    oscIndex1, oscIndex2, oscIndex3, oscIndex4, ...
                                    oscPeriod1Ms, oscPeriod2Ms, ...
                                    oscDurationSec, nSpikesInOsc, ...
                                    xLimitsAutoCorr, yLimitsAutoCorr, ...
                                    xLimitsAcfFiltered, yLimitsAcfFiltered, ...
                                    yOscDur, figTitleBase)
                                
% Create time values 
if nBins > 1
    tAcfTemp = create_time_vectors(nBins - 1, 'SamplingIntervalSec', binWidthSec, ...
                                'TimeUnits', 's');
    tAcf = [0; tAcfTemp(1:halfNBins)];
    tAutoCorr = [-flipud(tAcfTemp); 0; tAcfTemp];
    timePeaksSec = (indPeaks - indPeaks(1)) * binWidthSec;
    timeTroughsSec = (indTroughs - indPeaks(1)) * binWidthSec;
else
    tAcf = NaN(size(acf));
    tAutoCorr = NaN(size(autoCorr));
    timePeaksSec = NaN(size(ampPeaks));
    timeTroughsSec = NaN(size(ampTroughs));
end

xLimitsOscDur = [0, oscDurationSec];

% Plot the autocorrelogram
autoCorrFig = figure('Visible', 'off');
acfLine1 = plot(tAutoCorr, autoCorr);
xlim(xLimitsAutoCorr);
ylim(yLimitsAutoCorr);
xlabel('Lag (s)');
ylabel('Spike rate squared (Hz^2)');
title(['Autocorrelation for ', figTitleBase]);

% Plot the autocorrelation function
acfFig = figure('Visible', 'off');
hold on;
acfLine2 = plot(tAcf, acf, 'k');
acfFilteredLine = plot(tAcf, acfFiltered, 'g', 'LineWidth', 1);
plot(timePeaksSec, ampPeaks, 'ro', 'LineWidth', 2);
plot(timeTroughsSec, ampTroughs, 'bx', 'LineWidth', 2);
plot_horizontal_line(yOscDur, 'XLimits', xLimitsOscDur, ...
                    'Color', 'r', 'LineStyle', '-', 'LineWidth', 2);
text(0.5, 0.98, sprintf('Oscillatory Index 4 = %.2g', oscIndex4), ...
    'Units', 'normalized');
text(0.5, 0.94, sprintf('Oscillatory Index 3 = %.2g', oscIndex3), ...
    'Units', 'normalized');
text(0.5, 0.90, sprintf('Oscillatory Index 2 = %.2g', oscIndex2), ...
    'Units', 'normalized');
text(0.5, 0.86, sprintf('Oscillatory Index 1 = %.2g', oscIndex1), ...
    'Units', 'normalized');
text(0.5, 0.82, sprintf('Oscillation Period 2 = %.3g ms', oscPeriod2Ms), ...
    'Units', 'normalized');
text(0.5, 0.78, sprintf('Oscillation Period 1 = %.3g ms', oscPeriod1Ms), ...
    'Units', 'normalized');
text(0.5, 0.74, sprintf('Total spike count = %g', nSpikesInOsc), ...
    'Units', 'normalized');
text(0.5, 0.70, sprintf('Oscillation Duration = %.2g seconds', ...
    oscDurationSec), 'Units', 'normalized');
xlim(xLimitsAcfFiltered);
ylim(yLimitsAcfFiltered);
xlabel('Lag (s)');
ylabel('Spike rate squared (Hz^2)');
title(['Autocorrelation function for ', figTitleBase]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plot_all_spike_detections(parsedData, parsedParams, outFolder, nVectors)

% Retrieve data for plotting
tVec = parsedData.tVec;
vVec = parsedData.vVec;
vVecFilt = parsedData.vVecFilt;
slopes = parsedData.slopes;
idxSpikes = parsedData.idxSpikes;

stimStartMs = parsedParams.stimStartMs;
detectStartMs = parsedParams.detectStartMs;
firstSpikeMs = parsedParams.firstSpikeMs;
baseSlopeNoise = parsedParams.baseSlopeNoise;
slopeThreshold = parsedParams.slopeThreshold;
vMin = parsedParams.vMin;
vMax = parsedParams.vMax;
vRange = parsedParams.vRange;
slopeMin = parsedParams.slopeMin;
slopeMax = parsedParams.slopeMax;
figTitleBase = parsedParams.figTitleBase;
figPathBase = parsedParams.figPathBase;

% Check if output directory exists
check_dir(outFolder);

parfor iVec = 1:nVectors
    % Plot spike detection
    [fig, ax, lines, markers, raster] = ...
        plot_spike_detection(tVec{iVec}, vVec{iVec}, vVecFilt{iVec}, ...
                            slopes{iVec}, idxSpikes{iVec}, ...
                            baseSlopeNoise(iVec), slopeThreshold(iVec), ...
                            vMin(iVec), vMax(iVec), vRange(iVec), ...
                            slopeMin(iVec), slopeMax(iVec), ...
                            [], figTitleBase{iVec});

    % Get the current figure path base
    figBaseThis = fullfile(outFolder, figPathBase{iVec});

    % Set zoom windows
    zoomWin1 = stimStartMs(iVec) + [0; 1e4];
%       zoomWin1 = stimStartMs(iVec) + [0; 2e4];
    zoomWin2 = detectStartMs(iVec) + [0; 2e3];
    if ~isnan(firstSpikeMs(iVec))
        zoomWin3 = firstSpikeMs(iVec) + [0; 60];
    else
        zoomWin3 = [0; 60];
    end            

    % Put zoom windows together
    zoomWins = [zoomWin1, zoomWin2, zoomWin3];

    % Save the figure zoomed to several x limits
    save_all_zooms(fig, figBaseThis, zoomWins);

    % Close all figures
    close all force hidden
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plot_all_spike_histograms(parsedData, parsedParams, outFolder, nVectors)

% Retrieve data for plotting
spikeCounts = parsedData.spikeCounts;
edgesSec = parsedData.edgesSec;
timeBurstStartsSec = parsedData.timeBurstStartsSec;
timeBurstEndsSec = parsedData.timeBurstEndsSec;

binWidthSec = parsedParams.binWidthSec;
histLeftSec = parsedParams.histLeftSec;
timeOscEndSec = parsedParams.timeOscEndSec;
maxInterBurstIntervalSec = parsedParams.maxInterBurstIntervalSec;
oscDurationSec = parsedParams.oscDurationSec;
nSpikesInOsc = parsedParams.nSpikesInOsc;
figTitleBase = parsedParams.figTitleBase;
figPathBase = parsedParams.figPathBase;

% Find appropriate x limits
histLeft = min(histLeftSec);
% histRight = nanmean(timeOscEndSec) + 1.96 * stderr(timeOscEndSec) + ...
%                 1.5 * max(maxInterBurstIntervalSec);
histRight = 10;
xLimitsHist = [histLeft, histRight];

% Compute x limits for durations
%    durationWindows = force_column_cell(transpose([histLeft, timeOscEndSec]));
durationWindows = cellfun(@(x, y) prepare_for_plot_horizontal_line(x, y), ...
                        timeBurstStartsSec, timeBurstEndsSec, ...
                        'UniformOutput', false);

% Find the last bin to show for all traces
lastBinToShow = floor((histRight - histLeft) ./ binWidthSec) + 1;

% Find appropriate y limits
spikeCountsOfInterest = extract_subvectors(spikeCounts, ...
                        'IndexEnd', lastBinToShow);
largestSpikeCount = apply_iteratively(@max, spikeCountsOfInterest);
yLimitsHist = [0, largestSpikeCount * 1.1];

% Check if output directory exists
check_dir(outFolder);

% Plot histograms
parfor iVec = 1:nVectors
    [histBars, histFig] = ...
        plot_spike_histogram(spikeCounts{iVec}, edgesSec{iVec}, ...
                            durationWindows{iVec}, oscDurationSec(iVec), ...
                            nSpikesInOsc(iVec), ...
                            xLimitsHist, yLimitsHist, figTitleBase{iVec});

    saveas(histFig, fullfile(outFolder, ...
                    [figPathBase{iVec}, '_spike_histogram']), 'png');
    close all force hidden
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plot_all_autocorrelograms(parsedData, parsedParams, ...
                                    outFolderAutoCorr, outFolderAcf, nVectors)

% Retrieve data for plotting
autoCorr = parsedData.autoCorr;
acf = parsedData.acf;
acfFiltered = parsedData.acfFiltered;
indPeaks = parsedData.indPeaks;
indTroughs = parsedData.indTroughs;
ampPeaks = parsedData.ampPeaks;
ampTroughs = parsedData.ampTroughs;

binWidthSec = parsedParams.binWidthSec;
nBins = parsedParams.nBins;
halfNBins = parsedParams.halfNBins;
oscIndex1 = parsedParams.oscIndex1;
oscIndex2 = parsedParams.oscIndex2;
oscIndex3 = parsedParams.oscIndex3;
oscIndex4 = parsedParams.oscIndex4;
oscPeriod2Ms = parsedParams.oscPeriod2Ms;
oscPeriod1Ms = parsedParams.oscPeriod1Ms;
oscDurationSec = parsedParams.oscDurationSec;
nSpikesInOsc = parsedParams.nSpikesInOsc;
figTitleBase = parsedParams.figTitleBase;
figPathBase = parsedParams.figPathBase;

% Compute appropriate x limits
allLastPeaksBins = extract_elements(indPeaks, 'last');
allLastPeaksSec = allLastPeaksBins .* binWidthSec;
allOscDur = oscDurationSec;
bestRightForAll = max([allOscDur, allLastPeaksSec], [], 2) + 1;
acfFilteredRight = compute_stats(bestRightForAll, 'upper95', ...
                                'RemoveOutliers', true);
% xLimitsAutoCorr = [-acfFilteredRight, acfFilteredRight];
xLimitsAutoCorr = [-10, 10];
% xLimitsAcfFiltered = [0, acfFilteredRight];
xLimitsAcfFiltered = [0, 10];

% Find the last index to show
lastIndexToShow = floor(acfFilteredRight ./ binWidthSec) + 1;

% Compute appropriate y limits
acfOfInterest = extract_subvectors(acf, 'IndexEnd', lastIndexToShow);
largestAcfValues = extract_elements(acfOfInterest, 'max');
bestUpperLimit = compute_stats(largestAcfValues, 'upper95', ...
                                'RemoveOutliers', true);
yLimitsAutoCorr = compute_axis_limits([0, bestUpperLimit], ...
                                        'y', 'Coverage', 95);
yLimitsAcfFiltered = compute_axis_limits([0, bestUpperLimit], ...
                                        'y', 'Coverage', 90);
yOscDur = -(bestUpperLimit * 0.025);

% Check if output directory exists
check_dir(outFolderAutoCorr);
check_dir(outFolderAcf);

parfor iVec = 1:nVectors
    [autoCorrFig, acfFig] = ...
        plot_autocorrelogram(autoCorr{iVec}, acf{iVec}, acfFiltered{iVec}, ...
            indPeaks{iVec}, indTroughs{iVec}, ...
            ampPeaks{iVec}, ampTroughs{iVec}, ...
            binWidthSec(iVec), nBins(iVec), halfNBins(iVec), ...
            oscIndex1(iVec), oscIndex2(iVec), ...
            oscIndex3(iVec), oscIndex4(iVec), ...
            oscPeriod1Ms(iVec), oscPeriod2Ms(iVec), ...
            oscDurationSec(iVec), nSpikesInOsc(iVec), ...
            xLimitsAutoCorr, yLimitsAutoCorr, ...
            xLimitsAcfFiltered, yLimitsAcfFiltered, ...
            yOscDur, figTitleBase{iVec});

    saveas(autoCorrFig, fullfile(outFolderAutoCorr, ...
            [figPathBase{iVec}, '_autocorrelogram']), 'png');
    saveas(acfFig, fullfile(outFolderAcf, ...
            [figPathBase{iVec}, '_autocorrelation_function']), 'png');

    close all force hidden
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function fig = plot_raw_multiunit(parsedData, parsedParams, ...
                                phaseBoundaries, titleBase, yAmountToStagger, nVectors)

%% Hard-coded constants
MS_PER_S = 1000;

%% Preparation
% Extract parameters
stimStartSec = parsedParams.stimStartSec;
detectStartSec = parsedParams.detectStartSec;
firstSpikeSec = parsedParams.firstSpikeSec;
timeOscEndSec = parsedParams.timeOscEndSec;

% Extract parameters
tVecs = parsedData.tVec;
vVecs = parsedData.vVec;
vVecsFilt = parsedData.vVecFilt;

% Count the number of sweeps
nVectors = height(parsedParams);

% Convert time vector to seconds
tVecsSec = transform_vectors(tVecs, MS_PER_S, 'divide');

% Prepare for the plot
xLabel = 'Time (s)';
figTitle = ['Raw and Filtered traces for ', titleBase];

% Compute the original y limits from data
bestYLimits = compute_axis_limits(vVecs, 'y', 'AutoZoom', true);

% Compute the amount of y to stagger
if isempty(yAmountToStagger)
    yAmountToStagger = range(bestYLimits);
end

%% Plot
% Create figure and plot
fig = figure('Visible', 'off');
clf
plot_traces(tVecsSec, vVecs, 'Verbose', false, ...
            'PlotMode', 'staggered', 'SubplotOrder', 'list', ...
            'YLimits', bestYLimits, 'YAmountToStagger', yAmountToStagger, ...
            'XLabel', xLabel, 'LinkAxesOption', 'y', ...
            'YLabel', 'suppress', 'TraceLabels', 'suppress', ...
            'FigTitle', figTitle, 'FigHandle', fig, ...
            'Color', 'k');
plot_traces(tVecsSec, vVecsFilt, 'Verbose', false, ...
            'PlotMode', 'staggered', 'SubplotOrder', 'list', ...
            'YLimits', bestYLimits, 'YAmountToStagger', yAmountToStagger, ...
            'XLabel', xLabel, 'LinkAxesOption', 'y', ...
            'YLabel', 'suppress', 'TraceLabels', 'suppress', ...
            'FigTitle', figTitle, 'FigHandle', fig, ...
            'Color', 'b');

% Plot stimulation start
vertLine = plot_vertical_line(mean(stimStartSec), 'Color', 'g', ...
                                'LineStyle', '--');

% Plot phase boundaries
if ~isempty(phaseBoundaries)
    yBoundaries = (nVectors - phaseBoundaries + 1) * yAmountToStagger;
    horzLine = plot_horizontal_line(yBoundaries, 'Color', 'g', ...
                                    'LineStyle', '--', 'LineWidth', 2);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function fig = plot_raster_multiunit(parsedData, parsedParams, ...
                                        phaseBoundaries, titleBase)
%% Plots a spike raster plot from parsed multiunit data
% TODO: Plot burst duration
% TODO: Plot oscillatory index

% Extract the spike times
spikeTimesSec = parsedData.spikeTimesSec;
timeBurstStartsSec = parsedData.timeBurstStartsSec;
timeBurstEndsSec = parsedData.timeBurstEndsSec;

stimStartSec = parsedParams.stimStartSec;
timeOscEndSec = parsedParams.timeOscEndSec;

% Count the number of sweeps
nVectors = height(parsedParams);

% Convert oscillatory index to a window
% TODO

% Oscillation window
oscWindow = transpose([stimStartSec, timeOscEndSec]);

% Burst windows
burstWindows = cellfun(@(x, y) prepare_for_plot_horizontal_line(x, y), ...
                        timeBurstStartsSec, timeBurstEndsSec, ...
                        'UniformOutput', false);

% Create colors
nSweeps = numel(spikeTimesSec);
colorsRaster = repmat({'Black'}, nSweeps, 1);

% Create figure and plot
fig = figure('Visible', 'on');
% clf; 
hold on
[hLines, eventTimes, yEnds, yTicksTable] = ...
    plot_raster(spikeTimesSec, 'DurationWindow', burstWindows, ...
                'LineWidth', 0.5, 'Colors', colorsRaster);
% [hLines, eventTimes, yEnds, yTicksTable] = ...
%     plot_raster(spikeTimesSec, 'DurationWindow', oscWindow, ...
%                 'LineWidth', 0.5, 'Colors', colorsRaster);

% Plot stimulation start
vertLine = plot_vertical_line(mean(stimStartSec), 'Color', 'g', ...
                                'LineStyle', '--');
% Plot phase boundaries
if ~isempty(phaseBoundaries)
    yBoundaries = nVectors - phaseBoundaries + 1;
    horzLine = plot_horizontal_line(yBoundaries, 'Color', 'g', ...
                                    'LineStyle', '--', 'LineWidth', 2);
end
xlabel('Time (s)');
ylabel('Trace #');
title(['Spike times for ', titleBase]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function fig = plot_spike_density_multiunit(parsedData, parsedParams, ...
                                    phaseBoundaries, titleBase)
%% Plots a spike density plot from parsed multiunit data

% Retrieve data for plotting
spikeDensityHz = parsedData.spikeDensityHz;

siSeconds = parsedParams.siSeconds;
minTimeSec = parsedParams.minTimeSec;
maxTimeSec = parsedParams.maxTimeSec;
stimStartSec = parsedParams.stimStartSec;

% Create figure and plot
% fig = figure('Visible', 'off');
fig = figure('Visible', 'on');

clf; hold on

% Plot as a heatmap
% TODO: plot_heat_map(spikeDensityHz);

% Maximum number of y ticks
maxNYTicks = 20;

% Count traces
nSweeps = numel(spikeDensityHz);

% Get the average sampling interval in seconds
siSeconds = mean(siSeconds);

% Set x and y end points
xEnds = [min(minTimeSec); max(maxTimeSec)];
yEnds = [1; nSweeps];

% Set x and y limits
xLimits = [xEnds(1) - 0.5 * siSeconds; xEnds(2) + 0.5 * siSeconds];
yLimits = [yEnds(1) - 0.5; yEnds(2) + 0.5];

% Set y ticks and labels
yTicks = create_indices('IndexEnd', nSweeps, 'MaxNum', maxNYTicks, ...
                        'AlignMethod', 'left');
yTickLabels = create_labels_from_numbers(nSweeps - yTicks + 1);

% Force as a matrix and transpose it so that
%   each trace is a row
spikeDensityMatrix = transpose(force_matrix(spikeDensityHz));

% colormap(flipud(gray));
colormap(jet);

imagesc(xEnds, flipud(yEnds), spikeDensityMatrix);
yticks(yTicks);
yticklabels(yTickLabels);

% TODO: Make this optional
% % Plot stimulation start
% vertLine = plot_vertical_line(mean(stimStartSec), 'Color', 'g', ...
%                                 'LineStyle', '--', 'LineWidth', 0.5, ...
%                                 'YLimits', yLimits);
  
% TODO: Make this optional
% % Plot phase boundaries
% if ~isempty(phaseBoundaries)
%     yBoundaries = nSweeps - phaseBoundaries + 1;
%     horzLine = plot_horizontal_line(yBoundaries, 'Color', 'g', ...
%                                 'LineStyle', '--', 'LineWidth', 1, ...
%                                 'XLimits', xLimits);
% end

xlim(xLimits);
ylim(yLimits);
xlabel('Time (s)');
ylabel('Trace #');
title(['Spike density (Hz) for ', titleBase]);

% Show a scale bar
colorbar;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
OLD CODE:

% Compute baseline rms noise from window
baseNoises = compute_baseline_noise(vVecs, tVec, baseWindow);

% Compute a baseline slope noise in V/s
baseSlopeNoise = baseNoise / siMs;

parsedParams.baseNoise = baseNoise;

idxDetectStart = find(tVec > detectStartMs, 1);

xlim([detectStartMs, detectStartMs + 1e4]);
xlim([detectStartMs, detectStartMs + 2e3]);
xlim([3410, 3470]);

% Query the maximum and range of vVec after detectStartMs
vVecTrunc = vVec(idxDetectStart:end);
vMean = mean(vVecTrunc);
vStd = std(vVecTrunc);
vMin = vMean - 10 * vStd;
vMax = vMean + 10 * vStd;
vRange = vMax - vMin;

% Query the maximum and range of slope after detectStartMs
slopesTrunc = slopes(idxDetectStart:end);
slopesMean = mean(slopesTrunc);
slopesStd = std(slopesTrunc);
slopeMin = slopesMean - 10 * slopesStd;
slopeMax = slopesMean + 10 * slopesStd;
slopeRange = slopeMax - slopeMin;

filterCutoffHz = 3;
acfFiltered = freqfilter(acf, filterCutoffHz, binWidthMs / 1000);
parsedParams.filterCutoffHz = filterCutoffHz;

oscWindow = transpose([stimStartMs, timeOscEndMs]);
[hLines, eventTimes, yEnds, yTicksTable] = ...
    plot_raster(spikeTimesMs, 'DurationWindow', oscWindow, ...
                'LineWidth', 0.5);
vertLine = plot_vertical_line(mean(stimStartMs), 'Color', 'g', ...
                                'LineStyle', '--');
save_all_zooms(figs(nVectors + 1), figPathBaseThis, ...
                mean(stimStartMs), mean(detectStartMs), mean(firstSpikeMs));

function save_all_zooms(fig, figPathBase, stimStartMs, detectStartMs, firstSpikeMs)
%% Save the figure as .fig and 4 zooms as .png
% Get the figure
figure(fig)
% Save the full figure
%save_all_figtypes(fig, [figPathBase, '_full'], {'png', 'fig'});
saveas(fig, [figPathBase, '_full'], 'png');
% Zoom #1
xlim([stimStartMs, stimStartMs + 1e4]);
saveas(fig, [figPathBase, '_zoom1'], 'png');
% Zoom #2
xlim([detectStartMs, detectStartMs + 2e3]);
saveas(fig, [figPathBase, '_zoom2'], 'png');
% Zoom #3
xlim([firstSpikeMs, firstSpikeMs + 60]);
saveas(fig, [figPathBase, '_zoom3'], 'png');

% Compute the minimum spikes per bin in the last burst
minSpikesPerBinLastBurst = ceil(minSpikeRateLastBurstHz * binWidthSec);
% Find the bins with number of spikes greater than minSpikesPerBinLastBurst
binsManyManySpikes = find(spikeCounts > minSpikesPerBinLastBurst);
% Find the time of oscillation end in ms
if isempty(binsManyManySpikes)
    timeOscEndMs = stimStartMs;
else
    iBin = numel(binsManyManySpikes) + 1;
    lastBurstBin = [];
    while isempty(lastBurstBin) && iBin > 1
        % Decrement the bin number
        iBin = iBin - 1;
        % Find the last bin left with 
        %   number of spikes greater than minSpikesPerBinLastBurst
        idxBinLast = binsManyManySpikes(iBin);
        % Compute the maximum number of bins between last two bursts
        maxIbiBins = floor(maxInterBurstIntervalMs / binWidthMs);
        % Compute the last bin index that is within maxIbiBins of 
        %   the last bin with many many spikes
        idxBinMax = min(idxBinLast + maxIbiBins, nBins);
        % Determine whether each bin is within maxIbiBins of 
        %   the last bin with many many spikes
        withinIBI = false(nBins, 1);
        withinIBI(idxBinLast:idxBinMax) = true;
        % Determine whether each bin has number of spikes at least a threshold
        isManySpikes = (spikeCounts >= minSpikesPerBinLastBurst);
        % Find the last consecutive bin with number of spikes greater than threshold
        %   within maxIbiBins of the last bin with many many spikes
        %   Note: First bin must be true
        lastBurstBin = find([false; isManySpikes(1:end-1)] & isManySpikes & ...
                            withinIBI, 1, 'last');
    end
    % If still not found, the last burst bin is the one with many many spikes
    if isempty(lastBurstBin)
        lastBurstBin = idxBinLast;
    end
    % Compute the time of oscillation end in ms
    timeOscEndMs = histLeftMs + lastBurstBin * binWidthMs;
end

% Compute the minimum spikes per bin in the last burst
minSpikesPerBinInBurst = ceil(minSpikeRateInBurstHz * binWidthSec);
% Determine whether each bin passes the number of spikes criterion
isInBurst = spikeCounts >= minSpikesPerBinInBurst;
% Determine whether each bin and its previous minBinsInBurst
%   consecutive bins all pass the number of spikes criterion
isLastBinInBurst = isInBurst;
previousInBurst = isInBurst;
for i = 1:minBinsInBurst
    % Whether the previous ith bin passes the number of spikes criterion
    previousInBurst = [false; previousInBurst(1:(end-1))];

    % Whether the previous i bins all pass the number of spikes criterion
    isLastBinInBurst = isLastBinInBurst & previousInBurst;
end
% Find the last bins of each burst
iBinBurstEnds = find(isLastBinInBurst);

% Record the amplitude of the primary peak
ampPeak1 = acfFiltered(1);
% Find the index and amplitude of the secondary peak
% TODO: Use all peaks
[peakAmp, peakInd] = ...
    findpeaks(acfFiltered, 'MinPeakProminence', minRelProm * ampPeak1);
idxPeak2 = peakInd(1);
ampPeak2 = peakAmp(1);
% Find the amplitude of the first trough
[troughNegAmp, troughInd] = findpeaks(-acfFiltered);
idxTrough1 = troughInd(1);
ampTrough1 = -troughNegAmp(1);
% Compute the average amplitude of first two peaks
ampPeak12 = mean([ampPeak1, ampPeak2]);
% Compute the oscillatory index
oscIndex3 = (ampPeak12 - ampTrough1) / ampPeak12;
% Compute the oscillation period
oscPeriod2Ms = idxPeak2 * binWidthMs;
parsedParams.ampPeak1 = ampPeak1;
parsedParams.idxPeak2 = idxPeak2;
parsedParams.ampPeak2 = ampPeak2;
parsedParams.idxTrough1 = idxTrough1;
parsedParams.ampTrough1 = ampTrough1;
parsedParams.ampPeak12 = ampPeak12;
timePeak1Sec = 0;
timeTrough1Sec = idxTrough1 * binWidthSec;
timePeak2Sec = idxPeak2 * binWidthSec;
plot(timePeak1Sec, ampPeak1, 'ro', 'LineWidth', 2);
plot(timeTrough1Sec, ampTrough1, 'bx', 'LineWidth', 2);
plot(timePeak2Sec, ampPeak2, 'ro', 'LineWidth', 2);
xlim([0, 7]);

% Take just the positive side
acf = autoCorr(nBins:end);

% Create figure path base
figPathBase = fullfile(outFolder, [fileBase, '_spike_detection']);
figPathBase = [fileBase, '_spike_detection'];

minDelaySamples = 2000;
minDelayMs = 200;

check_subdir(outFolder, {rasterDir, autoCorrDir, acfDir, ...
                spikeHistDir, spikeDetectionDir});

% Compute x and y limits
acfOfInterest = acf(1:floor(7/binWidthSec));
maxAcf = max(acfOfInterest);
yLimits = compute_axis_limits({acfOfInterest, 0}, 'y', 'Coverage', 90);
yOscDur = -(maxAcf * 0.025);
xLimitsOscDur = [0, oscDurationMs - autoCorrDelayMs] / MS_PER_S;
xLimitsAcfFiltered = [0, max(timePeaksSec(end), xLimitsOscDur(2)) + 1];
% xLimitsAcfFiltered = [0, 7];

% Convert to seconds
spikeTimesSec = cellfun(@(x) x/MS_PER_S, spikeTimesMs, ...
                        'UniformOutput', false);

% Record the delay for the autocorrelogram
autoCorrDelayMs = histLeftMs - stimStartMs;
autoCorrDelaySec = autoCorrDelayMs / MS_PER_S;
parsedParams.autoCorrDelayMs = autoCorrDelayMs;
parsedParams.autoCorrDelaySec = autoCorrDelaySec;
autoCorrDelayMs = NaN;
xLimitsOscDur = [0, oscDurationSec - autoCorrDelaySec];

xLimitsAcfFiltered = [0, max(timePeaksSec(end), xLimitsOscDur(2)) + 1];

acfOfInterest = acf(1:floor(7/binWidthSec));
maxAcf = max(acfOfInterest);
yLimits = compute_axis_limits({acfOfInterest, 0}, 'y', 'Coverage', 90);
yOscDur = -(maxAcf * 0.025);

acfFilteredRight = nanmean(bestRightForAll) + 1.96 * nanstderr(bestRightForAll);
bestUpperLimit = nanmean(largestAcfValues) + 1.96 * nanstderr(largestAcfValues);

xLimitsOscDur = [histLeftSec, timeOscEndSec];

% Find the index and amplitude of the peaks
if numel(acfFiltered) > 3
    [peakAmp, peakInd] = ...
        findpeaks(acfFiltered, 'MinPeakProminence', minRelProm * ampPeak1);

    % Record all peak indices and amplitudes
    indPeaks = [1; peakInd];
    ampPeaks = [ampPeak1; peakAmp];
else
    indPeaks = 1;
    ampPeaks = ampPeak1;
end

% Compute the number of peaks
nPeaks = numel(indPeaks);

% Find the indices and amplitudes of the troughs in between each pair of peak
[ampTroughs, indTroughs] = find_troughs_from_peaks(acfFiltered, indPeaks);

% Compute the average amplitudes between adjacent peaks
ampAdjPeaks = mean([ampPeaks(1:(end-1)), ampPeaks(2:end)], 2);

% Compute the oscillatory index
oscIndex3 = mean((ampAdjPeaks - ampTroughs) ./ ampAdjPeaks);

if nPeaks > 1
    oscPeriod2Ms = (indPeaks(2) - indPeaks(1)) * binWidthMs;
else
    oscPeriod2Ms = 0;
end

% Compute the lags between adjacent peaks in ms
lagsBetweenPeaksMs = diff(indPeaks) * binWidthMs;

% Compute the oscillatory index 
%   Note: This is one over the coefficient of variation 
%           of the lag differences between adjacent peaks
if numel(lagsBetweenPeaksMs) < 2
    oscIndex3 = NaN;
else
    oscIndex3 = 1 ./ compute_stats(lagsBetweenPeaksMs, 'cov');
end

parsedData.lagsBetweenPeaksMs = lagsBetweenPeaksMs;
    lagsBetweenPeaksMs = [];

if nPeaks > 1
    [~, iPeak] = max(ampPeaks(2:end));
    oscPeriod2Bins = indPeaks(iPeak + 1) - indPeaks(1);
else
    oscPeriod2Bins = 0;
end

[~, iPeak] = max(ampPeaks(2:end));
oscPeriod1Bins = indPeaks(iPeak + 1) - indPeaks(1);

% Check if total spike count is correct
if nSpikesTotal2 ~= nSpikesTotal
    error('Code logic error!');
end

plot_traces(tVecs, vVecs, 'Verbose', false, ...
            'PlotMode', 'parallel', 'SubplotOrder', 'list', ...
            'YLimit', [-4, 4], ...
            'XLabel', xLabel, 'LinkAxesOption', 'y', ...
            'TraceLabels', 'suppress', ...
            'FigTitle', figTitle, 'FigHandle', figs(1), ...
            'Color', 'k');

'RemoveOutliers', true, 'PlotSeparately', true);

% Compute the sampling interval in seconds
siSeconds = siMs / MS_PER_S;

% Compute the minimum delay in samples
minDelaySamples = ceil(minDelayMs ./ siMs);
parsedParams.minDelaySamples = minDelaySamples;

% Updated plot flags
if plotAllFlag
    if isempty(plotSpikeDetectionFlag)
        plotSpikeDetectionFlag = true;
    end
    if isempty(plotSpikeDensityFlag)
        plotSpikeDensityFlag = true;
    end
    if isempty(plotSpikeHistogramFlag)
        plotSpikeHistogramFlag = true;
    end
    if isempty(plotAutoCorrFlag)
        plotAutoCorrFlag = true;
    end
    if isempty(plotRawFlag)
        plotRawFlag = true;
    end
    if isempty(plotRasterFlag)
        plotRasterFlag = true;
    end
    if isempty(plotMeasuresFlag)
        plotMeasuresFlag = true;
    end
end

function save_all_zooms(fig, outFolder, figBase, zoomWin1, zoomWin2, zoomWin3)
%% Save the figure as .fig and 4 zooms as .png

%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
