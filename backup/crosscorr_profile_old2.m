function [corrProfMatrix, lagProfMatrix, corrMatrix, lagMatrix] = ...
                crosscorr_profile (dataRaw, varargin)
%% Computes and plots cross correlation profiles between signals
% Usage: [corrProfMatrix, lagProfMatrix, corrMatrix, lagMatrix] = ...
%               crosscorr_profile (dataRaw, varargin)
% Explanation:
%       TODO
%
% Side Effects:
%       TODO
%
% Outputs:
%       TODO
%
% Arguments:    
%       dataRaw     - raw signal with each column being a channel
%                   must be a 2D numeric array
%       varargin    TODO
%
% Requires:
%       cd/check_dir.m
%       cd/compute_best_lag.m
%       cd/all_index_pairs.m
%       cd/create_subplots.m
%       cd/find_subscript.m
%       cd/freqfilter.m
%       cd/plot_vertical_line.m
%       cd/reorganize_as_matrix.m
%       cd/sscanf_full.m
%
% Used by:
%       cd/analyze_cobalt.m

% File History: 
% 2018-08-25 Added dataRaw and lag profile
% 2018-09-11 Fixed the order of i and j (now i must be less than j)
%             so that the upper triangle is computed and used
%             for the correlation profiles and lag profiles over time
% 2018-09-11 Now only use windows that have complete size
% 2021-05-14 Added maxLagSeconds
% 2021-05-14 Now uses check_dir.m and freqfilter.m
% 2021-05-14 Implemented input parser
% 2021-05-14 Added ChannelNumbers as an optional argument
% 2021-05-15 Now makes sure x axis of profiles are centered at time windows
% 2021-05-15 Made WindowSizeSeconds, WindowIntervalSeconds, 
%               MaxLagSeconds, Normalization, ChannelToPlot1, ChannelToPlot2, 
%               SignalLabel optional arguments
% 2021-05-15 Now links y axes of EEG plots
% 2021-05-15 Made SelectMethod an optional argument
% 2021-05-15 Now uses all_index_pairs.m
% 2021-05-15 Now computes all correlation coefficients and plots a matrix
% 2021-05-15 Now plots corr coeff and lag matrices
% 2021-05-15 Added corrThreshold
% 2021-05-15 Made CorrThreshold an optional argument
% 2021-05-15 Now plots lags for only pairs with significant correlations

%% Hard-coded parameters
validSelectMethods = {'consecutive', 'significant'};

%% Default values for optional arguments
samplingRateHzDefault = 1;
windowSizeSecondsDefault = 1;
windowIntervalSecondsDefault = [];
corrThresholdDefault = 0;
maxLagSecondsDefault = Inf;
normalizationDefault = 'normalized';
channelToPlot1Default = [];
channelToPlot2Default = [];
selectMethodDefault = 'significant';
signalLabelDefault = 'Signal Units';
lowFreqDefault = [];
highFreqDefault = [];
channelNumbersDefault = [];
dataFiltDefault = [];
outFolderDefault = 'crosscorr';
fileBaseDefault = 'sample';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Deal with arguments
% Check number of required arguments
if nargin < 1
    error(create_error_for_nargin(mfilename));
end

% Set up Input Parser Scheme
iP = inputParser;
iP.FunctionName = mfilename;
iP.KeepUnmatched = true;                        % allow extraneous options

% Add required inputs to the Input Parser
addRequired(iP, 'dataRaw', ...
    @(x) validateattributes(x, {'numeric', 'logical'}, {'2d'}));

% Add parameter-value pairs to the Input Parser
addParameter(iP, 'SamplingRateHz', samplingRateHzDefault, ...
    @(x) validateattributes(x, {'numeric'}, {'2d'}));
addParameter(iP, 'WindowSizeSeconds', windowSizeSecondsDefault, ...
    @(x) validateattributes(x, {'numeric'}, {'2d'}));
addParameter(iP, 'WindowIntervalSeconds', windowIntervalSecondsDefault, ...
    @(x) validateattributes(x, {'numeric'}, {'2d'}));
addParameter(iP, 'CorrThreshold', corrThresholdDefault, ...
    @(x) validateattributes(x, {'numeric'}, {'2d'}));
addParameter(iP, 'MaxLagSeconds', maxLagSecondsDefault, ...
    @(x) validateattributes(x, {'numeric'}, {'2d'}));
addParameter(iP, 'Normalization', normalizationDefault, ...
    @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
addParameter(iP, 'ChannelToPlot1', channelToPlot1Default, ...
    @(x) validateattributes(x, {'numeric'}, {'2d'}));
addParameter(iP, 'ChannelToPlot2', channelToPlot2Default, ...
    @(x) validateattributes(x, {'numeric'}, {'2d'}));
addParameter(iP, 'SelectMethod', selectMethodDefault, ...
    @(x) any(validatestring(x, validSelectMethods)));
addParameter(iP, 'SignalLabel', signalLabelDefault, ...
    @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
addParameter(iP, 'LowFreq', lowFreqDefault, ...
    @(x) validateattributes(x, {'numeric'}, {'2d'}));
addParameter(iP, 'HighFreq', highFreqDefault, ...
    @(x) validateattributes(x, {'numeric'}, {'2d'}));
addParameter(iP, 'ChannelNumbers', channelNumbersDefault, ...
    @(x) validateattributes(x, {'numeric'}, {'2d'}));
addParameter(iP, 'DataFilt', dataFiltDefault, ...
    @(x) validateattributes(x, {'numeric', 'logical'}, {'2d'}));
addParameter(iP, 'OutFolder', outFolderDefault, ...
    @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
addParameter(iP, 'FileBase', fileBaseDefault, ...
    @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));

% Read from the Input Parser
parse(iP, dataRaw, varargin{:});
samplingRateHz = iP.Results.SamplingRateHz;
windowSizeSeconds = iP.Results.WindowSizeSeconds;
windowIntervalSeconds = iP.Results.WindowIntervalSeconds;
corrThreshold = iP.Results.CorrThreshold;
maxLagSeconds = iP.Results.MaxLagSeconds;
normalization = iP.Results.Normalization;
channelToPlot1 = iP.Results.ChannelToPlot1;
channelToPlot2 = iP.Results.ChannelToPlot2;
selectMethod = validatestring(iP.Results.SelectMethod, validSelectMethods);
signalLabel = iP.Results.SignalLabel;
lowFreq = iP.Results.LowFreq;
highFreq = iP.Results.HighFreq;
channelNumbers = iP.Results.ChannelNumbers;
dataFilt = iP.Results.DataFilt;
outFolder = iP.Results.OutFolder;
fileBase = iP.Results.FileBase;

%% Preparation
% Check if output directory exists
check_dir(outFolder);

% Count the number of samples
nSamples = size(dataRaw, 1);

% Count the number of channels
nChannels = size(dataRaw, 2);

% Dimension of output matrices
dimMatrix = [nChannels, nChannels];

% Create channel numbers if not provided
if isempty(channelNumbers)
    channelNumbers = transpose(1:nChannels);
end

% Decide on window interval if not provided
if isempty(windowIntervalSeconds)
    windowIntervalSeconds = windowSizeSeconds / 2;
end

% Determine the window size (samples) for the correlation profile
windowSizeSamples = windowSizeSeconds * samplingRateHz;

% Determine the window interval (samples) for the correlation profile
windowIntervalSamples = windowIntervalSeconds * samplingRateHz;

% Determine the maximum lag (samples) for the correlation profile
maxLagSamples = maxLagSeconds * samplingRateHz;

% Determine the number of windows for the correlation profile
nWindows = floor(nSamples / windowIntervalSamples);

% Determine the number of pairs
nPairsToCompute = nchoosek(nChannels, 2);

% Create a time vector in seconds centered at the windows
windowCenters = (transpose(1:nWindows) - 1) * windowIntervalSeconds + ...
                windowIntervalSeconds / 2;

% Create a time vector in seconds for the entire signal
tVec = transpose(1:nSamples) / samplingRateHz;

% Get the maximum time
maxTime = tVec(end);

% Find the mouse number from the file base
mouseCell = regexp(fileBase, 'mouse(\d+)', 'match');
if ~isempty(mouseCell)
    mouseStr = mouseCell{1};
    mouseNumber = sscanf_full(mouseStr, '%d');
else
    mouseNumber = [];
end
    
% Find the cutoff filter bounds from the file base if any
if isempty(lowFreq) && isempty(highFreq)
    bandCell = regexp(fileBase, 'band(\d+)to(\d+)', 'match');
    if ~isempty(bandCell)
        bandStr = bandCell{1};
        freqs = sscanf_full(bandStr, '%g');
        if length(freqs) >= 1
            lowFreq = freqs(1);
        else
            lowFreq = [];
        end
        if length(freqs) >= 2
            highFreq = freqs(2);
        else
            highFreq = [];    
        end
    end
end

%% Filter raw data if requested
% TODO: Simplify this by making freqfilter smarter
if isempty(dataFilt)
    if isempty(lowFreq) && isempty(highFreq)
        dataFilt = dataRaw;
    elseif ~isempty(lowFreq) && isempty(highFreq)
        dataFilt = freqfilter(dataRaw, lowFreq, ...
                                'FilterType', 'highpass');
    elseif isempty(lowFreq) && ~isempty(highFreq)
        dataFilt = freqfilter(dataRaw, highFreq, ...
                                'FilterType', 'lowpass');
    else
        dataFilt = freqfilter(dataRaw, [lowFreq, highFreq], ...
                                'FilterType', 'bandpass');
    end
end

%% Decide on pairs of channels to compute
% Iterate over all pairs of channels
indPairsToCompute = all_index_pairs(nChannels);
firstOfPairsToCompute = indPairsToCompute(:, 1);
secondOfPairsToCompute = indPairsToCompute(:, 2);

%% Compute summary correlation coefficients and lag between channels
% Return as a list for speed
corrList = nan(nPairsToCompute, 1);
lagList = nan(nPairsToCompute, 1);
acorAllList = cell(nPairsToCompute, 1);
lagAllList = cell(nPairsToCompute, 1);
parfor iPair = 1:nPairsToCompute
    % Get the indices in corrProfList for this pair
    i = firstOfPairsToCompute(iPair);
    j = secondOfPairsToCompute(iPair);
    
    % Compute the cross-correlation coefficient between the two channels
    %   (treat all samples as independent)
    corrList(iPair) = corr2(dataFilt(:, i), dataFilt(:, j));

    % Compute the lag with highest correlation between the two channels
    [lagBest, acorAll, lagAll] = ...
        compute_best_lag(dataFilt(:, i), dataFilt(:, j), ...
                        'MaxLag', maxLagSamples, 'ScaleOption', normalization);

    % Convert the lag to seconds
    % Store acorAll and lagAll for plotting
    lagList(iPair) = lagBest / samplingRateHz;
    lagAllList{iPair} = lagAll / samplingRateHz;
    acorAllList{iPair} = acorAll;
end

% Reorganize as a matrix
corrMatrix = reorganize_as_matrix(corrList, indPairsToCompute, dimMatrix);
lagMatrix = reorganize_as_matrix(lagList, indPairsToCompute, dimMatrix);
acorAllMatrix = reorganize_as_matrix(acorAllList, indPairsToCompute, dimMatrix);
lagAllMatrix = reorganize_as_matrix(lagAllList, indPairsToCompute, dimMatrix);

%% Compute correlation and lag profiles between channels over time
% Compute all correlation profiles over time using corr2 
%   (treat all samples within a time window as independent)
corrProfList = cell(nPairsToCompute, 1);
parfor iPair = 1:nPairsToCompute
    % Get the channel indices for this pair
    i = firstOfPairsToCompute(iPair);
    j = secondOfPairsToCompute(iPair);
    
    % Compute a cross-correlation coefficient vector over time
    corrThis = nan(nWindows, 1);
    for iWindow = 1:nWindows
        % Compute indices for this time window
        ind = get_window_ind(iWindow, windowSizeSamples, ...
                            windowIntervalSamples, nSamples);

        % Calculate the cross-correlation coefficient for the
        % two channels in this time window
        corrThis(iWindow) = corr2(dataFilt(ind, i), dataFilt(ind, j));
    end

    % Store the correlation profile in the cell array
    corrProfList{iPair} = corrThis;
end
corrProfMatrix = reorganize_as_matrix(corrProfList, indPairsToCompute, dimMatrix);

% Compute all lag profiles over time using xcorr
lagProfList = cell(nPairsToCompute, 1);
parfor iPair = 1:nPairsToCompute
    % Get the channel indices for this pair
    i = firstOfPairsToCompute(iPair);
    j = secondOfPairsToCompute(iPair);
    
    % Compute a time lag vector between the two channels over time
    lagThis = nan(nWindows, 1);
    for iWindow = 1:nWindows
        % Compute indices for this time window
        ind = get_window_ind(iWindow, windowSizeSamples, ...
                            windowIntervalSamples, nSamples);

        % Compute the lag with highest correlation between 
        %   the two channels within this time window
        lagBest = compute_best_lag(dataFilt(ind, i), dataFilt(ind, j), ...
                        'MaxLag', maxLagSamples, 'ScaleOption', normalization);

        % Convert the lag to seconds
        lagThis(iWindow) = lagBest / samplingRateHz;
    end

    % Store the correlation profile in the cell array
    lagProfList{iPair} = lagThis;
end
lagProfMatrix = reorganize_as_matrix(lagProfList, indPairsToCompute, dimMatrix);

% Determine the pairs that are significante
isSignificant = corrList > corrThreshold;
lagListSig = lagList(isSignificant);
indPairsSignificant = indPairsToCompute(isSignificant, :);
lagMatrixSig = reorganize_as_matrix(lagListSig, indPairsSignificant, dimMatrix);

%% Plot overall correlation and lag matrices
% Decide on figure expansion
if nChannels < 20
    figExpansion = [1, 2];
else
    figExpansion = [2, 4];
end

% Create a new figure
[fig, ax] = create_subplots(2, 1, 'AlwaysNew', true, ...
                            'FigExpansion', figExpansion);

% Set x and y values
xValues = channelNumbers;
yValues = channelNumbers;

% Plot correlation matrix as a heat map
subplot(ax(1));
map1 = heatmap(xValues, yValues, corrMatrix);
xlabel('Channel #');
ylabel('Channel #');
title('Correlation Coefficients for all pairs');

% Plot lag matrix (pairs with significant correlation only) as a heat map
subplot(ax(2));
map2 = heatmap(xValues, yValues, lagMatrixSig);
xlabel('Channel #');
ylabel('Channel #');
title('Lag (seconds) for pairs with significant correlation');

% Change the colormap
colormap(jet);

% Save the figure
figname = fullfile(outFolder, [fileBase, '_corrmatrix']);
saveas(fig, figname, 'jpg');

%% Plot correlation profiles for selected pairs
% Decide on pairs to plot
switch selectMethod
    case 'consecutive'
        indPairsToPlot = [transpose(1:nChannels-1), transpose(2:nChannels)];
    case 'significant'
        indPairsToPlot = indPairsSignificant;
    otherwise
        error('selectMethod unrecognized!');
end
nPairsToPlot = size(indPairsToPlot, 1);

% Return if no pairs are to be plotted
if nPairsToPlot < 1
    return
end

% Determine the channel indices to plot
if ~isempty(channelToPlot1) && ~isempty(channelToPlot2)
    iChannelToPlot1 = find(channelNumbers == channelToPlot1, 1, 'first');
    iChannelToPlot2 = find(channelNumbers == channelToPlot2, 1, 'first');
elseif isempty(channelToPlot1) && ~isempty(channelToPlot2)
    iChannelToPlot2 = find(channelNumbers == channelToPlot2, 1, 'first');
    iChannelToPlot1 = find_channel_best_corr(corrMatrix, iChannelToPlot2);
elseif ~isempty(channelToPlot1) && isempty(channelToPlot2)
    iChannelToPlot1 = find(channelNumbers == channelToPlot1, 1, 'first');
    iChannelToPlot2 = find_channel_best_corr(corrMatrix, iChannelToPlot1);
else
    [iChannelToPlot1, iChannelToPlot2] = find_subscript(corrMatrix, @max);
end

% Decide on the colormap
cm = colormap(jet(nPairsToPlot));

% Create a new figure
fig = set_figure_properties('AlwaysNew', true);

% Plot raw EEG
ax1 = subplot(4, 5, 1:4);
hold on
plot(tVec, dataRaw(:, iChannelToPlot1));
ylabel(signalLabel);
title(['Signal for Channel ', num2str(channelNumbers(iChannelToPlot1))]);

% Plot filtered EEG or second raw EEG
ax2 = subplot(4, 5, 6:9);
hold on
ylabel(signalLabel);
if ~isempty(lowFreq) || ~isempty(highFreq)
    plot(tVec, dataFilt(:, iChannelToPlot1));
    title(['Filtered Signal (', num2str(lowFreq), '-', ...
            num2str(highFreq), ' Hz) for Channel ', ...
            num2str(channelNumbers(iChannelToPlot1))]);
else
    plot(tVec, dataRaw(:, iChannelToPlot2));
    title(['Signal for Channel ', num2str(channelNumbers(iChannelToPlot2))]);
end

% Plot the correlation profiles of each pair of channels to plot
legendTexts = cell(1, nPairsToPlot);
ax3 = subplot(4, 5, 11:14);
hold on
forLegend = gobjects(nPairsToPlot, 1);
for iPair = 1:nPairsToPlot
    % Extract channel indices
    i = indPairsToPlot(iPair, 1);
    j = indPairsToPlot(iPair, 2);
    
    % Plot correlation profile for this pair
    corrLabel = create_corr_label(channelNumbers, i, j);
    legendTexts{iPair} = corrLabel;
    forLegend(iPair) = plot(windowCenters, corrProfMatrix{i, j}, ...
                         'Color', cm(iPair, :), 'DisplayName', corrLabel);
end
ylim([0, 1]);
ylabel('Corr Coeff')
title('Cross Correlation Profile');

% Plot the time lag profiles of each pair of consecutive channels
ax4 = subplot(4, 5, 16:19);
hold on
for iPair = 1:nPairsToPlot
    % Extract channel indices
    i = indPairsToPlot(iPair, 1);
    j = indPairsToPlot(iPair, 2);
    
    % Plot lag profile for this pair 
    lagLabel = create_corr_label(channelNumbers, i, j);
    plot(windowCenters, lagProfMatrix{i, j}, ...
         'Color', cm(iPair, :), 'DisplayName', lagLabel);
end
xlabel('Time (seconds)')
ylabel('Lag (sec)')
title('Time Lag Profile');

% Align the x axes of all plots
linkaxes([ax1, ax2, ax3, ax4], 'x');

% Align the y axes of first two plots
linkaxes([ax1, ax2], 'y');

% Create a legend
ax5 = subplot(4, 5, [15, 20], 'Visible', 'off');
legendPosition = get(ax5, 'OuterPosition');
legendPosition(1) = legendPosition(1) + 0.02;
legend(forLegend, legendTexts, 'Position', legendPosition);
% ax5 = subplot(4, 5, 15);
% legend(forLegend1);
% ax6 = subplot(4, 5, 20);
% legend(forLegend2);

% Set the x axis limits
xlim([0, maxTime]);

% Create an overarching title
if ~isempty(mouseNumber)
    suplabel(['Mouse #', num2str(mouseNumber)], 't');
end

% Save the figure
figname = fullfile(outFolder, [fileBase, '_corrprofile']);
saveas(fig, figname, 'jpg');

%% Plot cross-correlograms for selected pairs
for iPair = 1:nPairsToPlot
    % Extract channel indices
    i = indPairsToPlot(iPair, 1);
    j = indPairsToPlot(iPair, 2);
    lagBestSec = lagMatrix(i, j);

    % Create a new figure
    fig = set_figure_properties('AlwaysNew', true);

    % Plot the the cross correlation
    corrLabel = create_corr_label(channelNumbers, i, j);
    hPlot = plot(lagAllMatrix{i, j}, acorAllMatrix{i, j}, ...
                'Color', cm(iPair, :), 'DisplayName', corrLabel);

    % Create a text for the lagBest
    diffSampl = ['lagBest = ', num2str(lagBestSec), ' seconds'];
    hText = text(0.05, 0.95, diffSampl, 'Units', 'normalized');

    % Set a y axis limit if normalized
    if strcmp(normalization, 'normalized') || strcmp(normalization, 'coeff')
        ylim([0, 1]);
    end

    % Create a legend
    % legend('location', 'northeast', 'AutoUpdate', 'off');

    % Mark the lagBest with a vertical dotted line
    hLine = plot_vertical_line(lagBestSec, 'Color', 'k', 'LineStyle', ':');
    
    % Reorder things
    set(gca, 'Children', [hLine, hPlot, hText]);

    % Create an x label
    xlabel('Lag (seconds)')
    
    % Create a y label
    ylabel('Correlation Coefficient')
    
    % Create a title
    title(['Cross correlation between Channel ', num2str(channelNumbers(i)), ...
            ' and Channel ', num2str(channelNumbers(j))]);

    % Save the figure
    figname = fullfile(outFolder, [fileBase, '_', corrLabel]);
    saveas(fig, figname, 'jpg');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function corrLabel = create_corr_label (channelNumbers, i1, i2)

corrLabel = ['Ch', num2str(channelNumbers(i1)), ...
            '-Ch', num2str(channelNumbers(i2))];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ind = get_window_ind (iWindow, windowSizeSamples, ...
                                windowIntervalSamples, nSamples)

% Get the starting index of the time window
iStart = (iWindow - 1) * windowIntervalSamples + 1;

% Get the ending index of the time window
iEnd = min([iStart + windowSizeSamples - 1, nSamples]);

% Return the vector of indices in between endpoints
ind = iStart:iEnd;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function iChannel2 = find_channel_best_corr (corrMatrix, iChannel1)

% Find the first linear index with maximum correlation with iChannel1
maxCorrWith2 = max([corrMatrix(iChannel1, :), ...
                    transpose(corrMatrix(:, iChannel1))]);
idxLinear = find(corrMatrix == maxCorrWith2, 1, 'first');

% Find the corresponding iChannel2
[row, col] = ind2sub(size(corrMatrix), idxLinear);
if row == iChannel1
    iChannel2 = col;
else
    iChannel2 = row;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
OLD CODE:

% Find the corresponding index in indPairsToCompute for the pair [i, j]
idxPair = find(firstOfPairsToCompute == i & secondOfPairsToCompute == j);

%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
