function h = plot_traces (tVec, data, varargin)
%% Plots traces all in one place, overlapped or in parallel
% Usage: h = plot_traces (tVec, data, varargin)
% Outputs:
%       h           - figure handle for the created figure
%                   specified as a figure handle
%
% Arguments:
%       tVec        - time vector for plotting
%                   must be a numeric vector
%       data        - data array (each column is a data vector)
%                   must be a numeric 2-D array
%       varargin    - 'PlotMode': plotting mode for multiple traces
%                   must be an unambiguous, case-insensitive match to one of: 
%                       'overlapped'    - overlapped in a single plot
%                       'parallel'      - in parallel in subplots
%                   must be consistent with plot_traces_abf.m
%                   default == 'overlapped'
%                   - 'XLimits': limits of x axis
%                               suppress by setting value to 'suppress'
%                   must be 'suppress' or a 2-element increasing numeric vector
%                   default == [min(tVec), max(tVec)]
%                   - 'YLimits': limits of y axis, 
%                               suppress by setting value to 'suppress'
%                   must be 'suppress' or a 2-element increasing numeric vector
%                   default == expand by a little bit
%                   - 'XLabel': label for the time axis, 
%                               suppress by setting value to 'suppress'
%                   must be a string scalar or a character vector 
%                       or a cell array of strings or character vectors
%                   default == 'Time'
%                   - 'YLabel': label(s) for the y axis, 
%                               suppress by setting value to 'suppress'
%                   must be a string scalar or a character vector
%                   default == 'Data' if plotMode is 'overlapped'
%                               {'Trace #1', 'Trace #2', ...}
%                                   if plotMode is 'parallel'
%                   - 'TraceLabels': labels for the traces, 
%                               suppress by setting value to 'suppress'
%                   must be a string scalar or a character vector 
%                       or a cell array of strings or character vectors
%                   default == {'Trace #1', 'Trace #2', ...}
%                   - 'LegendLocation': location for legend
%                   must be an unambiguous, case-insensitive match to one of: 
%                       'auto'      - use default
%                       'suppress'  - no legend
%                       anything else recognized by the legend() function
%                   default == 'suppress' if nTraces == 1 
%                               'northeast' if nTraces is 2~9
%                               'eastoutside' if nTraces is 10+
%                   - 'FigTitle': title for the figure
%                   must be a string scalar or a character vector
%                   default == ['Traces for ', figName]
%                               or [yLabel, ' over time']
%                   - 'FigNumber': figure number for creating figure
%                   must be a positive integer scalar
%                   default == []
%                   - 'FigName': figure name for saving
%                   must be a string scalar or a character vector
%                   default == ''
%                   - 'FigTypes': figure type(s) for saving; 
%                               e.g., 'png', 'fig', or {'png', 'fig'}, etc.
%                   could be anything recognised by 
%                       the built-in saveas() function
%                   (see isfigtype.m under Adams_Functions)
%                   default == 'png'
%
% Requires:
%       cd/isfigtype.m
%       cd/islegendlocation.m
%       cd/save_all_figtypes.m
%
% Used by:
%       cd/plot_traces_abf.m

% File History:
% 2018-09-18 Moved from plot_traces_abf.m
% 2018-09-25 Implemented the input parser
% 2018-09-25 Added PlotMode and LegendLocation as parameters

%% Hard-coded parameters
validPlotModes = {'overlapped', 'parallel'};

%% Default values for optional arguments
plotModeDefault = 'overlapped'; % plot traces overlapped by default
xLimitsDefault = [];            % set later
yLimitsDefault = [];            % set later
xLabelDefault = 'Time';         % the default x-axis label
yLabelDefault = '';             % set later
traceLabelsDefault = '';        % set later
legendLocationDefault = 'auto'; % set later
figTitleDefault = '';           % set later
figNumberDefault = [];          % invisible figure by default
figNameDefault = '';            % don't save figure by default
figTypesDefault = 'png';        % save as png file by default

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

% Add required inputs to an Input Parser
addRequired(iP, 'tVec', ...
    @(x) validateattributes(x, {'numeric'}, {'vector'}));
addRequired(iP, 'data', ...
    @(x) validateattributes(x, {'numeric'}, {'2d'}));
addParameter(iP, 'PlotMode', plotModeDefault, ...
    @(x) any(validatestring(x, validPlotModes)));
addParameter(iP, 'XLimits', xLimitsDefault, ...
    @(x) isempty(x) || ischar(x) && strcmpi(x, 'suppress') || ...
        isnumeric(x) && isvector(x) && length(x) == 2);
addParameter(iP, 'YLimits', yLimitsDefault, ...
    @(x) isempty(x) || ischar(x) && strcmpi(x, 'suppress') || ...
        isnumeric(x) && isvector(x) && length(x) == 2);
addParameter(iP, 'XLabel', xLabelDefault, ...
    @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
addParameter(iP, 'YLabel', yLabelDefault, ...
    @(x) ischar(x) || iscellstr(x) || isstring(x));
addParameter(iP, 'TraceLabels', traceLabelsDefault, ...
    @(x) ischar(x) || iscellstr(x) || isstring(x));
addParameter(iP, 'LegendLocation', legendLocationDefault, ...
    @(x) all(islegendlocation(x, 'ValidateMode', true)));
addParameter(iP, 'FigTitle', figTitleDefault, ...
    @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
addParameter(iP, 'FigNumber', figNumberDefault, ...
    @(x) validateattributes(x, {'numeric'}, {'scalar', 'positive', 'integer'}));
addParameter(iP, 'FigName', figNameDefault, ...
    @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
addParameter(iP, 'FigTypes', figTypesDefault, ...
    @(x) all(isfigtype(x, 'ValidateMode', true)));

% Read from the Input Parser
parse(iP, tVec, data, varargin{:});
plotMode = validatestring(iP.Results.PlotMode, validPlotModes);
xLimits = iP.Results.XLimits;
yLimits = iP.Results.YLimits;
xLabel = iP.Results.XLabel;
yLabel = iP.Results.YLabel;
traceLabels = iP.Results.TraceLabels;
[~, legendLocation] = islegendlocation(iP.Results.LegendLocation, ...
                                        'ValidateMode', true);
figTitle = iP.Results.FigTitle;
figNumber = iP.Results.FigNumber;
figName = iP.Results.FigName;
[~, figTypes] = isfigtype(iP.Results.FigTypes, 'ValidateMode', true);

%% Preparation
% Extract number of traces
nTraces = size(data, 2);

% Compute minimum and maximum Y values
minY = min(min(data));
maxY = max(max(data));
rangeY = maxY - minY;

% Set the default time axis limits
if isempty(xLimits)
    xLimits = [min(tVec), max(tVec)];
end

% Set the default y-axis limits
if isempty(yLimits) && ~strcmpi(plotMode, 'parallel') && rangeY ~= 0
    yLimits = [minY - 0.2 * rangeY, maxY + 0.2 * rangeY];
end

% Set the default y-axis labels
if isempty(yLabel)
    switch plotMode
    case 'overlapped'
        yLabel = 'Data';
    case 'parallel'
        if nTraces > 1
            yLabel = cell(1, nTraces);
            parfor iTrace = 1:nTraces
                yLabel{iTrace} = ['Trace #', num2str(iTrace)];
            end
        else
            yLabel = {'Data'};
        end
    otherwise
        error(['The plot mode ', plotMode, ' has not been implemented yet!']);
    end
end

% Make sure y-axis labels are consistent
switch plotMode
case 'overlapped'
    if iscell(yLabel)
        fprintf('Only the first yLabel will be used!\n');
        yLabel = yLabel{1};
    end
case 'parallel'
    if ~iscell(yLabel)
        yLabel = {yLabel};
    end
    if iscell(yLabel)
        if numel(yLabel) > nTraces
            fprintf('Too many y labels! Only some will be used!\n');
        elseif numel(yLabel) < nTraces
            fprintf('Not enough y labels!!\n');
            return;
        end
    end
otherwise
    error(['The plot mode ', plotMode, ' has not been implemented yet!']);
end

% Set the default trace labels
if isempty(traceLabels)
    traceLabels = cell(1, nTraces);
    parfor iTrace = 1:nTraces
        traceLabels{iTrace} = ['Trace #', num2str(iTrace)];
    end
end

% Make sure trace labels are cell arrays
if ~isempty(traceLabels) && ...
    (ischar(traceLabels) || isstring(traceLabels)) && ...
    ~strcmpi(traceLabels, 'suppress')
    traceLabels = {traceLabels};
end

% Check if traceLabels has the correct length
if iscell(traceLabels) && numel(traceLabels) ~= nTraces
    error('traceLabels has %d elements instead of %d!!', ...
            numel(traceLabels), nTraces);
end

% Set the default figure title
if isempty(figTitle)
    if ~isempty(figName) && nTraces == 1
        figTitle = ['Traces for ', traceLabels{1}];
    elseif ~isempty(figName)
        figTitle = ['Traces for ', figName];
    elseif ischar(yLabel)
        figTitle = [yLabel, ' over ', xLabel];
    else
        figTitle = ['Data over ', xLabel];        
    end
end

% Set legend location based on number of traces
if isempty(legendLocation)
    if nTraces > 1 && nTraces < 10
        legendLocation = 'northeast';
    elseif nTraces >= 10
        legendLocation = 'eastoutside';
    else
        legendLocation = 'suppress';
    end
end

% Decide on the figure to plot on
if ~isempty(figName)
    % Create an invisible figure and clear it
    if ~isempty(figNumber)
        h = figure(figNumber);
        set(h, 'Visible', 'Off');
    else
        h = figure('Visible', 'Off');
    end
    clf(h);
else
    % Get the current figure
    h = gcf;
end

% Decide on the colormap
colorMap = colormap(jet(nTraces));

%% Plot
% Hold on if more than one trace
if nTraces > 1
    hold on
end

% Plot all traces
switch plotMode
case 'overlapped'
    % Plot all traces together
    for iTrace = 1:nTraces
        % Plot the trace
        p = plot(tVec, data(:, iTrace), ...
            'Color', colorMap(iTrace, :));
        
        % Set the legend label as the trace label if provided
        if ~strcmpi(traceLabels, 'suppress')
            set(p, 'DisplayName', traceLabels{iTrace});
        end
    end
    
    % Set time axis limits
    if ~strcmpi(xLimits, 'suppress')
        xlim(xLimits);
    end

    % Set y axis limits
    if ~isempty(yLimits) && ~strcmpi(yLimits, 'suppress')
        ylim(yLimits);
    end

    % Generate an x-axis label
    if ~strcmpi(xLabel, 'suppress')
        xlabel(xLabel);
    end

    % Generate a y-axis label
    if ~strcmpi(yLabel, 'suppress')
        ylabel(yLabel);
    end

    % Generate a title
    if ~strcmpi(figTitle, 'suppress')
        title(figTitle, 'Interpreter', 'none');
    end

    % Generate a legend if there is more than one trace
    if ~strcmpi(legendLocation, 'suppress')
        legend('location', legendLocation);
    end
case 'parallel'
    if ~strcmpi(legendLocation, 'suppress')
        % Set a legend location differently    
        legendLocation = 'northeast';
    end

    % Plot each trace as a different subplot
    for iTrace = 1:nTraces
        % Create a subplot
        subplot(nTraces, 1, iTrace);
        
        % Plot the signal against the time vector
        p = plot(tVec, data(:, iTrace), ...
                'Color', colorMap(iTrace, :));

        % Set the legend label as the trace label if provided
        if ~strcmpi(traceLabels, 'suppress')
            set(p, 'DisplayName', traceLabels{iTrace});
        end

        % Set time axis limits
        if ~strcmpi(xLimits, 'suppress')
            xlim(xLimits);
        end

        % Set y axis limits
        if ~isempty(yLimits) && ~strcmpi(yLimits, 'suppress')
            ylim(yLimits);
        end

        % Generate a y-axis label
        if ~strcmpi(yLabel{iTrace}, 'suppress')
            ylabel(yLabel{iTrace});
        end

        % Generate a legend
        if ~strcmpi(legendLocation, 'suppress')
            legend('location', legendLocation);
        end

        % Create a title for the first subplot
        if iTrace == 1 && ~strcmpi(figTitle, 'suppress')
            title(figTitle, 'Interpreter', 'none');
        end
        
        % Create a label for the X axis only for the last subplot
        if iTrace == nTraces && ~strcmpi(xLabel, 'suppress')
            xlabel(xLabel);
        end
    end
otherwise
    error(['The plot mode ', plotMode, ' has not been implemented yet!']);
end

% Hold off if more than one trace
if nTraces > 1
    hold off
end

%% Save
% Save figure
if ~isempty(figName)
    save_all_figtypes(h, figName, figTypes);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{ 
OLD CODE:

function h = plot_traces(tVec, data, xLimits, xLabel, yLabel, ...
                            traceLabels, figTitle, figName, figNum)
%       xLimits     - x-axis limits
%       xLabel      - x-axis label
%       yLabel      - y-axis label
%       traceLabels - legend labels for each trace
%       figTitle    - figure title
%       figName     - figure name
%       figNum      - figure number

% Hold off and close figure
hold off;
close(h);

saveas(h, figName, 'png');

h = figure(figNum);
set(h, 'Visible', 'Off');

% Determine the appropriate time axis limits
if ~isempty(xLimits)
    if ~strcmpi(xLimits, 'suppress')
        xlim(xLimits);
    end
else
    xlim([min(tVec), max(tVec)]);
end

% Determine the appropriate y axis limits
if ~isempty(yLimits)
    if ~strcmpi(yLimits, 'suppress')
        ylim(yLimits);
    end
else
    if rangeY ~= 0
        ylim([minY - 0.2 * rangeY, maxY + 0.2 * rangeY]);
    end
end

    @(x) any(validatestring(x, validLegendLocations)));
legendLocation = validatestring(iP.Results.LegendLocation, ...
                                validLegendLocations);

%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
