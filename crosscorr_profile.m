function corrProf = crosscorr_profile (dataFilt, dataRaw, samplingRateHz, outFolder, fileBase)
%% Creates cross correlation profiles between signals
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
%       TODO
%       dataFilt: each channel is a column
%
% Requires:
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

%% Hard-coded parameters
windowSizeSeconds = 4;              % window size in seconds
windowIntervalSeconds = 0.5;        % window interval in seconds
iChannelToPlot = 2;                 % the channel number to plot

samplingRateDefault = 20000;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Deal with arguments
% Check number of required arguments
if nargin < 1
    error(create_error_for_nargin(mfilename));
end

% Set default arguments
if nargin < 2
    dataRaw = dataFilt;
end
if nargin < 3
    samplingRateHz = samplingRateDefault;
end
if nargin < 4
    outFolder = pwd;
end
if nargin < 5
    fileBase = 'sample';
end

%% Create an output folder for cross correlation figures
figFolder = fullfile(outFolder, 'crosscorr');
if exist(figFolder, 'dir') ~= 7
    mkdir(figFolder);
end

%% Preparation

% Count the number of samples
nSamples = size(dataFilt, 1);

% Count the number of channels
nChannels = size(dataFilt, 2);

% Determine the window size (samples) for the correlation profile
windowSize = windowSizeSeconds * samplingRateHz;

% Determine the window interval (samples) for the correlation profile
windowInterval = windowIntervalSeconds * samplingRateHz;

% Determine the number of windows for the correlation profile
nWindows = floor(nSamples / windowInterval);

% Determine the number of pairs
nPairs = nChannels * (nChannels - 1) / 2;

% Create a time vector in seconds for the windows
timeWindows = (0.5:(nWindows - 0.5))' * windowIntervalSeconds;

% Create a time vector in seconds for the entire channel
timeVector = (1:nSamples)' * 1/samplingRateHz;

% Get the maximum time
maxTime = timeVector(end);

% Find the mouse number from the file base
mouseCell = regexp(fileBase, 'mouse(\d+)', 'match');
if ~isempty(mouseCell)
    mouseStr = mouseCell{1};
    mouseNumber = sscanf_full(mouseStr, '%d');
else
    mouseNumber = [];
end
    
% Find the band pass filter bounds from the file base if any
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
else
    lowFreq = [];
    highFreq = [];    
end
    
%% Filtered dataFilt cross correlation with corr2
% Iterate over each channel
indPairs = zeros(nPairs, 2);
ct = 0;
for i = 1:nChannels
    % Only store index pairs from the upper right triangle
    for j = i:nChannels
        if i ~= j
            % Increment the count
            ct = ct + 1;
            
            % Store the index
            indPairs(ct, 1) = i;
            indPairs(ct, 2) = j;            
        end
    end
end
firstOfPairs = indPairs(:, 1);
secondOfPairs = indPairs(:, 2);

% Compute all correlation profiles over time with corr2 
%   (treat all samples within a time window as independent)
corrProf = cell(nPairs, 1);
parfor iPair = 1:nPairs
    % Get the indices in corrProf for this pair
    i = firstOfPairs(iPair);
    j = secondOfPairs(iPair);
    
    % Initialize a cross correlation vector over time
    corrThis = zeros(nWindows, 1);

    for k = 1:nWindows
        % Get the starting index of the time window
        idxStart = (k - 1) * windowInterval + 1;

        % Get the ending index of the time window
        idxEnd = min(idxStart + windowSize - 1, nSamples);

        % Calculate the cross-correlation coefficient for the
        % two channels in this time window
        corrThis(k) = corr2(dataFilt(idxStart:idxEnd, i), ...
                            dataFilt(idxStart:idxEnd, j));

    end

    % Store the correlation profile in the cell array
    corrProf{iPair} = corrThis;
    
end

% Compute all time lags over time with xcorr
lagProf = cell(nPairs, 1);
parfor iPair = 1:nPairs
    % Get the indices in lagProf for this pair
    i = firstOfPairs(iPair);
    j = secondOfPairs(iPair);
    
    % Initialize a time lag vector over time
    lagThis = zeros(nWindows, 1);

    for k = 1:nWindows
        % Get the starting index of the time window
        idxStart = (k - 1) * windowInterval + 1;

        % Get the ending index of the time window
        idxEnd = min(idxStart + windowSize - 1, nSamples);

        % Calculate the lags for the
        % two channels in this time window
        [acorAll, lagAll] = xcorr(dataFilt(idxStart:idxEnd, i), ...
                                  dataFilt(idxStart:idxEnd, j));

        % Find the lag difference with the largest correlation
        [~, I] = max(abs(acorAll));
        lagDiff = lagAll(I);

        % Compute the lag in seconds
        lagThis(k) = lagDiff/samplingRateHz;
    end

    % Store the correlation profile in the cell array
    lagProf{iPair} = lagThis;
end

% Decide on the colormap
cm = colormap(jet(nChannels - 1));

% Plot EEG and correlation coefficient
h = figure;

% iChannnel raw EEG plot
ax1 = subplot(4, 5, [1:4]);
hold on
plot(timeVector, dataRaw(:, iChannelToPlot));
ylabel('Voltage (mV)')
title(['EEG for channel ', num2str(iChannelToPlot)]);

% iChannnel filtered EEG plot
ax2 = subplot(4, 5, [6:9]);
hold on
plot(timeVector, dataFilt(:, iChannelToPlot));
ylabel('Voltage (mV)')
if ~isempty(lowFreq) && ~isempty(highFreq)
    title(['Filtered EEG (', num2str(lowFreq), ' ~ ', ...
            num2str(highFreq), ' Hz) for channel ', num2str(iChannelToPlot)]);
elseif ~isempty(lowFreq)
    title(['Filtered EEG (', num2str(lowFreq), ' Hz) for channel ', ...
            num2str(iChannelToPlot)]);
else
    title(['Raw EEG for channel ', num2str(iChannelToPlot)]);
end
        
% Plot the correlation profiles of each pair of consecutive channels
legendTexts = cell(1, nChannels - 1);
ax3 = subplot(4, 5, [11:14]);
hold on
for i = 1:(nChannels - 1)
    % Find the corresponding index in indPairs for the pair [i, i+1]
    idxPair = find(firstOfPairs == i & secondOfPairs == i + 1);
    
    % Correlation profile plot
    corrLabel = ['ch', num2str(i), '-ch', num2str(i + 1)];
    legendTexts{i} = corrLabel;
    forLegend(i) = plot(timeWindows, corrProf{idxPair}, ...
                         'Color', cm(i, :), 'DisplayName', corrLabel);
end
ylabel('Correlation Coefficients')
title('Cross correlation profile');

% Plot the time lag profiles of each pair of consecutive channels
ax4 = subplot(4, 5, [16:19]);
hold on
for i = 1:(nChannels - 1)
    % Find the corresponding index in indPairs for the pair [i, i+1]
    idxPair = find(firstOfPairs == i & secondOfPairs == i + 1);
    
    % Correlation profile plot
    lagLabel = ['ch', num2str(i), '-ch', num2str(i + 1)];
    plot(timeWindows, lagProf{idxPair}, ...
         'Color', cm(i, :), 'DisplayName', lagLabel);
end
xlabel('Time (seconds)')
ylabel('Time lag (seconds)')
title('Time lag profile');

% Link the x axes
linkaxes([ax1, ax2, ax3, ax4], 'x');

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
figname = fullfile(figFolder, [fileBase, '_corrprofile']);
saveas(h, figname, 'jpg');

%% Filtered dataFilt cross correlation with xcorr
for i = 1:(nChannels-1)
    % Only iterate up to current channel number because lower triangle of
    % matrix is same as upper
    [acorAll, lagAll] = xcorr(dataFilt(:, i), dataFilt(:, i+1));

    % Find the lag difference with the largest correlation
    [~, I] = max(abs(acorAll));
    lagDiff = lagAll(I);
    
    % Compute the lag in seconds
    timeDiff = lagDiff/samplingRateHz;

    % Create a figure
    h = figure;

    % Plot the the cross correlation
    corrLabel = ['ch', num2str(i), '-ch', num2str(i+1)];
    plot(lagAll, acorAll, 'Color', cm(i, :), 'DisplayName', corrLabel);

    % Mark the lagDiff
    a3 = gca;
    a3.XTick = unique([a3.XTick, lagDiff]);

    % Create a text for the lagDiff
    diffSampl = ['lagDiff = ', num2str(lagDiff), ' samples'];
    text(0.55, 0.55, diffSampl, 'Units', 'normalized');

    % Create a legend
    legend('location', 'northeast');
    
    % Create an x label
    xlabel('Lag (samples)')
    
    % Create a y label
    ylabel('Correlation')
    
    % Create a title
    title(['Cross correlation between channel ', num2str(i), ...
            ' and channel ', num2str(i+1)]);
        
    % Save the figure
    figname = fullfile(figFolder, [fileBase, '_', corrLabel]);
    saveas(h, figname, 'jpg');
    
    % Plot the correlation profiles of 'xcorr'
    %ax4 = subplot(4, 1, 4);
    %hold on

    % Find the corresponding index in indPairs for the pair [i, i+1]
    %idxPair = find(firstOfPairs == i + 1 & secondOfPairs == i);
    
    % Correlation profile plot
    %corrLabel = ['ch', num2str(i), '-ch', num2str(i + 1)];
    %plot(timeWindows, xcorrProf{idxPair}, ...
    %     'Color', cm(i, :), 'DisplayName', corrLabel);
    %legend('location', 'northeast');
    %xlabel('Time (seconds)')
    %ylabel('xcorr Correlation Coefficients')
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
OLD CODE:

%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%