function hfig = m3ha_plot_individual_traces (tVecs, data, varargin)
%% Plots individual voltage traces
% Usage: hfig = m3ha_plot_individual_traces (tVecs, data, varargin)
% Explanation:
%       TODO
% Example(s):
%       TODO
% Outputs:
%       hfig        - handle to figure
%                   specified as a TODO
% Arguments:
%       tVecs       - time vector(s) for plotting
%                   Note: If a cell array, each element must be a vector
%                         If a non-vector array, each column is a vector
%                   must be a numeric array or a cell array of numeric arrays
%       data        - data vectors(s)
%                   Note: If a cell array, each element must be a vector
%                         If a non-vector array, each column is a vector
%                   must be a numeric array or a cell array of numeric arrays
%       varargin    - 'DataToCompare': data vector(s) to compare against
%                   Note: If a cell array, each element must be a vector
%                         If a non-vector array, each column is a vector
%                   must be a numeric array or a cell array of numeric arrays
%                   default == []
%                   - 'XLimits': limits of x axis
%                               suppress by setting value to 'suppress'
%                   must be 'suppress' or a 2-element increasing numeric vector
%                   default == [min(tVec), max(tVec)]
%                   - 'ColorMap': a color map that also groups traces
%                                   each set of traces will be on the same row
%                                   if plot mode is 'parallel'
%                   must be a numeric array with 3 columns
%                   default == colormap(jet(nTraces))
%                   - 'FigTitle': title for the figure
%                   must be a string scalar or a character vector
%                   default == ['Traces for ', figName]
%                               or [yLabel, ' over time']
%                   - 'FigNumber': figure number for creating figure
%                   must be empty or a positive integer scalar
%                   default == 104
%                   - 'FigName': figure name for saving
%                   must be a string scalar or a character vector
%                   default == ''
%                   - 'BaseWindow': baseline window for each trace
%                   must be empty or a numeric vector with 2 elements,
%                       or a numeric array with 2 rows
%                       or a cell array of numeric vectors with 2 elements
%                   default == first half of the trace
%                   - 'FitWindow': time window to fit for each trace
%                   must be a numeric vector with 2 elements,
%                       or a numeric array with 2 rows
%                       or a cell array of numeric vectors with 2 elements
%                   default == second half of the trace
%                   - 'BaseNoise': baseline noise value(s)
%                   must be a numeric vector
%                   default == apply compute_default_sweep_info.m
%                   - 'SweepWeights': sweep weights for averaging
%                   must be empty or a numeric vector with length == nSweeps
%                   default == 1 ./ baseNoise
%                   - 'SweepErrors': sweep errors
%                   must be a numeric vector
%                   default == apply compute_sweep_errors.m
%                   - 'PlotSwpWeightsFlag': whether to plot sweep weights
%                   must be numeric/logical 1 (true) or 0 (false) or 'auto'
%                   default == 'auto'
%
% Requires:
%       ~/Downloaded_Functions.m/rgb.m
%       cd/argfun.m
%       cd/compute_default_sweep_info.m
%       cd/compute_sweep_errors.m
%       cd/force_column_cell.m
%       cd/force_column_numeric.m
%       cd/isbinaryscalar.m
%       cd/iscellnumeric.m
%       cd/isnumericvector.m
%       cd/ispositiveintegerscalar.m
%       cd/match_format_vector_sets.m
%       cd/match_row_count.m
%       cd/plot_traces.m
%       cd/plot_window_boundaries.m
%       cd/save_all_figtypes.m
%
% Used by:    
%       cd/m3ha_run_neuron_once.m
%       cd/m3ha_xolotl_plot.m

% File History:
% 2018-10-29 Created by Adam Lu
% 

%% Hard-coded parameters
maxNTracesForAnnotations = 8;
nSigFig = 3;
fontSize = 8;
plotMode = 'parallel';
% linkAxesOption = 'xy';
linkAxesOption = 'x';

%% Default values for optional arguments
dataToCompareDefault = [];      % no data to compare against by default
xLimitsDefault = [];            % set later
colorMapDefault = [];           % set later
figTitleDefault = '';           % set later
figNumberDefault = 104;         % figure 104 by default
figNameDefault = '';            % don't save figure by default
baseWindowDefault = [];         % set later
fitWindowDefault = [];          % set later
baseNoiseDefault = [];          % set later
sweepWeightsDefault = [];       % set later
sweepErrorsDefault = [];        % set later
plotSwpWeightsFlagDefault = 'auto'; % set later

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Deal with arguments
% Check number of required arguments
if nargin < 2
    error(['Not enough input arguments, ', ...
            'type ''help %s'' for usage'], mfilename);
end

% Set up Input Parser Scheme
iP = inputParser;
iP.FunctionName = mfilename;

% Add required inputs to the Input Parser
addRequired(iP, 'tVecs', ...
    @(x) assert(isnumeric(x) || iscellnumeric(x), ...
                ['vec1s must be either a numeric array ', ...
                    'or a cell array of numeric arrays!']));
addRequired(iP, 'data', ...
    @(x) assert(isnumeric(x) || iscellnumeric(x), ...
                ['vec1s must be either a numeric array ', ...
                    'or a cell array of numeric arrays!']));

% Add parameter-value pairs to the Input Parser
addParameter(iP, 'DataToCompare', dataToCompareDefault, ...
    @(x) assert(isnumeric(x) || iscellnumeric(x), ...
                ['vec1s must be either a numeric array ', ...
                    'or a cell array of numeric arrays!']));
addParameter(iP, 'XLimits', xLimitsDefault, ...
    @(x) isempty(x) || ischar(x) && strcmpi(x, 'suppress') || ...
        isnumeric(x) && isvector(x) && length(x) == 2);
addParameter(iP, 'ColorMap', colorMapDefault, ...
    @(x) isempty(x) || isnumeric(x) && size(x, 2) == 3);
addParameter(iP, 'FigTitle', figTitleDefault, ...
    @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
addParameter(iP, 'FigNumber', figNumberDefault, ...
    @(x) assert(isempty(x) || ispositiveintegerscalar(x), ...
                'FigNumber must be a empty or a positive integer scalar!'));
addParameter(iP, 'FigName', figNameDefault, ...
    @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
addParameter(iP, 'BaseWindow', baseWindowDefault, ...
    @(x) assert(isnumeric(x) || iscellnumeric(x), ...
                ['BaseWindow must be either a numeric array ', ...
                    'or a cell array of numeric arrays!']));
addParameter(iP, 'FitWindow', fitWindowDefault, ...
    @(x) assert(isnumeric(x) || iscellnumeric(x), ...
                ['FitWindow must be either a numeric array ', ...
                    'or a cell array of numeric arrays!']));
addParameter(iP, 'BaseNoise', baseNoiseDefault, ...
    @(x) assert(isnumericvector(x), 'BaseNoise must be a numeric vector!'));
addParameter(iP, 'SweepWeights', sweepWeightsDefault, ...
    @(x) assert(isnumericvector(x), 'SweepWeights must be a numeric vector!'));
addParameter(iP, 'SweepErrors', sweepErrorsDefault, ...
    @(x) assert(isnumericvector(x), 'SweepErrors must be a numeric vector!'));
addParameter(iP, 'PlotSwpWeightsFlag', plotSwpWeightsFlagDefault, ...
    @(x) assert(isbinaryscalar(x) || ischar(x) && strcmpi(x, 'auto'), ...
                'PlotSwpWeightsFlag must be a binary scalar or ''auto''!'));

% Read from the Input Parser
parse(iP, tVecs, data, varargin{:});
dataToCompare = iP.Results.DataToCompare;
xLimits = iP.Results.XLimits;
colorMap = iP.Results.ColorMap;
figTitle = iP.Results.FigTitle;
figNumber = iP.Results.FigNumber;
figName = iP.Results.FigName;
baseWindow = iP.Results.BaseWindow;
fitWindow = iP.Results.FitWindow;
baseNoise = iP.Results.BaseNoise;
sweepWeights = iP.Results.SweepWeights;
sweepErrors = iP.Results.SweepErrors;
plotSwpWeightsFlag = iP.Results.PlotSwpWeightsFlag;

%% Preparation
% If data is empty, return
if isempty(data) || iscell(data) && all(cellfun(@isempty, data))
    fprintf('Nothing to plot!\n');
    hfig = [];
    return
end

% Force time and data vectors as column cell arrays of column vectors
[tVecs, data] = argfun(@force_column_cell, tVecs, data);

% Count the number of sweeps
nSweeps = numel(data);

% Decide whether to plot sweep weights
if plotSwpWeightsFlag == 'auto'
    if nSweeps > 1 && nSweeps <= maxNTracesForAnnotations
        plotSwpWeightsFlag = true;
    else
        plotSwpWeightsFlag = false;
    end
end

% Compute default windows, noise and weights
[baseWindow, fitWindow, baseNoise, sweepWeights] = ...
    compute_default_sweep_info(tVecs, data, ...
            'BaseWindow', baseWindow, 'FitWindow', fitWindow, ...
            'BaseNoise', baseNoise, 'SweepWeights', sweepWeights);

% Re-compute sweep errors if not provided
if isempty(sweepErrors)
    % Compute sweep errors
    errorStructTemp = compute_sweep_errors (data, dataToCompare, ...
                        'TimeVecs', tVecs, 'FitWindow', fitWindow, ...
                        'SweepWeights', sweepWeights, 'NormalizeError', false);

    % Extract sweep errors for each trace
    sweepErrors = errorStructTemp.swpErrors;
end

% Match vectors format and numbers of sweep-dependent vectors with data
[tVecs, dataToCompare, fitWindow] = ...
    argfun(@(x) match_format_vector_sets(x, data), ...
            tVecs, dataToCompare, fitWindow);

% Make sure vectors are columns
[baseNoise, sweepErrors] = ...
    argfun(@force_column_numeric, baseNoise, sweepErrors);

% Match numbers of sweep-dependent scalars with data
[baseNoise, sweepErrors] = ...
    argfun(@(x) match_row_count(x, nSweeps), baseNoise, sweepErrors);

% Determine the number of rows and the number of traces per row
nRows = size(colorMap, 1);
nTracesPerRow = ceil(nSweeps / nRows);

%% Do the job
% Create and clear figure
if ~isempty(figNumber)
    hfig = figure(figNumber);
else
    hfig = figure('Visible', 'off');
end
set(hfig, 'Name', 'All individual voltage traces');
clf(hfig);

% Plot traces
[hfig, subPlots] = plot_traces(tVecs, data, 'DataToCompare', dataToCompare, ...
                        'ColorMap', colorMap, 'XLimits', xLimits, ...
                        'YLabel', 'suppress', 'LegendLocation', 'suppress', ...
                        'PlotMode', plotMode, 'LinkAxesOption', linkAxesOption);

% Plot annotations
for iSwp = 1:nSweeps
    % Get the subplot of interest
    subplot(subPlots(iSwp));

    % Hold on
    hold on

    % Plot sweep weights
    if plotSwpWeightsFlag
        % Get the current sweep weight
        sweepWeight = sweepWeights(iSwp);

        % Decide on the text color
        if sweepWeight ~= 0
            colorText = rgb('DarkGreen');
        else
            colorText = rgb('Gray');
        end

        % Show sweep weight
        text('String', ['w: ', num2str(sweepWeight, nSigFig)], ...
            'Color', colorText, 'FontSize', fontSize, ...
            'Position', [0.1 0.9], 'Units', 'normalized');
    end

    % Show sweep info and error only if nSweeps <= maxNTracesForAnnotations
    if nSweeps <= maxNTracesForAnnotations
        title(['Noise = ', num2str(baseNoise(iSwp), nSigFig), '; ', ...
                'RMSE = ', num2str(sweepErrors(iSwp), nSigFig)]);
    end

    % Plot fitWindow only if nSweeps <= maxNTracesForAnnotations
    if nSweeps <= maxNTracesForAnnotations
        plot_window_boundaries(fitWindow{iSwp}, ...
                                'LineColor', 'g', 'LineStyle', '--');
    end
end

% Create a title
suptitle(figTitle);

%% Output results
% Save figure
if ~isempty(figName)
    save_all_figtypes(hfig, figName);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
OLD CODE:

if plotSwpWeightsFlag && nSweeps < 20

% Hold off
hold off

if sweepWeight ~= 0
    colorText = 'green';
else
    colorText = 'gray';
end

text('String', ['\color{', colorText, '} \bf ', ...
                num2str(sweepWeight, 2)], ...
        'Units', 'normalized', 'Position', [0.1 0.9]);

subplot(nRows, nTracesPerRow, iSwp); hold on;

'FigTitle', figTitle, 

%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
