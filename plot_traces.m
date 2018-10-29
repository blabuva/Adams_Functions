function h = plot_traces (tVecs, data, varargin)
%% Plots traces all in one place, overlapped or in parallel
% Usage: h = plot_traces (tVecs, data, varargin)
% Outputs:
%       h           - figure handle for the created figure
%                   specified as a figure handle
%
% Arguments:
%       tVecs       - time vector(s) for plotting
%                   Note: If a cell array, each element must be a vector
%                         If a non-vector array, each column is a vector
%                   must be a numeric array or a cell array of numeric arrays
%       data        - data vectors(s)
%                   Note: If a cell array, each element must be a vector
%                         If a non-vector array, each column is a vector
%                   must be a numeric array or a cell array of numeric arrays
%       varargin    - 'PlotMode': plotting mode for multiple traces
%                   must be an unambiguous, case-insensitive match to one of: 
%                       'overlapped'    - overlapped in a single plot
%                       'parallel'      - in parallel in subplots
%                   must be consistent with plot_traces_abf.m
%                   default == 'overlapped'
%                   - 'DataToCompare': data vector(s) to compare against
%                   Note: If a cell array, each element must be a vector
%                         If a non-vector array, each column is a vector
%                   must be a numeric array or a cell array of numeric arrays
%                   default == []
%                   - 'XLimits': limits of x axis
%                               suppress by setting value to 'suppress'
%                   must be 'suppress' or a 2-element increasing numeric vector
%                   default == [min(tVec), max(tVec)]
%                   - 'YLimits': limits of y axis, 
%                               suppress by setting value to 'suppress'
%                   must be 'suppress' or a 2-element increasing numeric vector
%                   default == expand by a little bit
%                   - 'LinkAxesOption': option for the linkaxes()
%                   must be an unambiguous, case-insensitive match to one of: 
%                       'none' - don't apply the function
%                       'x'    - link x axes only
%                       'y'    - link y axes only
%                       'xy'   - link x and y axes
%                       'off'  - unlink axes
%                   must be consistent with linkaxes()
%                   default == 'none'
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
%                   - 'ColorMap': a color map that also groups traces
%                                   each set of traces will be on the same row
%                                   if plot mode is 'parallel'
%                   must be a numeric array with 3 columns
%                   default == colormap(jet(nTraces))
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
%       cd/argfun.m
%       cd/count_vectors.m
%       cd/create_colormap.m
%       cd/force_column_cell.m
%       cd/isfigtype.m
%       cd/islegendlocation.m
%       cd/match_array_counts.m
%       cd/match_dimensions.m
%       cd/save_all_figtypes.m
%       ~/Downloaded_Function/suplabel.m
%       ~/Downloaded_Function/subplotsqueeze.m
%
% Used by:
%       cd/plot_traces_abf.m

% File History:
% 2018-09-18 Moved from plot_traces_abf.m
% 2018-09-25 Implemented the input parser
% 2018-09-25 Added 'PlotMode' and 'LegendLocation' as optional parameters
% 2018-10-29 Added 'ColorMap' as an optional parameter
% 2018-10-29 Number of rows in parallel mode is now dependent on the 
%               number of rows in the colorMap provided
% 2018-10-29 Added 'DataToCompare' as an optional parameter

%% Hard-coded parameters
validPlotModes = {'overlapped', 'parallel'};
validLinkAxesOptions = {'none', 'x', 'y', 'xy', 'off'};

%% Default values for optional arguments
plotModeDefault = 'overlapped'; % plot traces overlapped by default
dataToCompareDefault = [];      % no data to compare against by default
xLimitsDefault = [];            % set later
yLimitsDefault = [];            % set later
linkAxesOptionDefault = 'none'; % don't force link axes by default
xLabelDefault = 'Time';         % the default x-axis label
yLabelDefault = '';             % set later
colorMapDefault = [];           % set later
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
addRequired(iP, 'tVecs', ...
    @(x) assert(isnumeric(x) || iscellnumeric(x), ...
                ['vec1s must be either a numeric array ', ...
                    'or a cell array of numeric arrays!']));
addRequired(iP, 'data', ...
    @(x) assert(isnumeric(x) || iscellnumeric(x), ...
                ['vec1s must be either a numeric array ', ...
                    'or a cell array of numeric arrays!']));

% Add parameter-value pairs to the Input Parser
addParameter(iP, 'PlotMode', plotModeDefault, ...
    @(x) any(validatestring(x, validPlotModes)));
addParameter(iP, 'DataToCompare', dataToCompareDefault, ...
    @(x) assert(isnumeric(x) || iscellnumeric(x), ...
                ['vec1s must be either a numeric array ', ...
                    'or a cell array of numeric arrays!']));
addParameter(iP, 'XLimits', xLimitsDefault, ...
    @(x) isempty(x) || ischar(x) && strcmpi(x, 'suppress') || ...
        isnumeric(x) && isvector(x) && length(x) == 2);
addParameter(iP, 'YLimits', yLimitsDefault, ...
    @(x) isempty(x) || ischar(x) && strcmpi(x, 'suppress') || ...
        isnumeric(x) && isvector(x) && length(x) == 2);
addParameter(iP, 'LinkAxesOption', linkAxesOptionDefault, ...
    @(x) any(validatestring(x, validLinkAxesOptions)));
addParameter(iP, 'XLabel', xLabelDefault, ...
    @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
addParameter(iP, 'YLabel', yLabelDefault, ...
    @(x) ischar(x) || iscellstr(x) || isstring(x));
addParameter(iP, 'TraceLabels', traceLabelsDefault, ...
    @(x) ischar(x) || iscellstr(x) || isstring(x));
addParameter(iP, 'ColorMap', colorMapDefault, ...
    @(x) isempty(x) || isnumeric(x) && size(x, 2) == 3);
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
parse(iP, tVecs, data, varargin{:});
plotMode = validatestring(iP.Results.PlotMode, validPlotModes);
dataToCompare = iP.Results.DataToCompare;
xLimits = iP.Results.XLimits;
yLimits = iP.Results.YLimits;
linkAxesOption = validatestring(iP.Results.LinkAxesOption, ...
                                validLinkAxesOptions);
xLabel = iP.Results.XLabel;
yLabel = iP.Results.YLabel;
traceLabels = iP.Results.TraceLabels;
colorMap = iP.Results.ColorMap;
[~, legendLocation] = islegendlocation(iP.Results.LegendLocation, ...
                                        'ValidateMode', true);
figTitle = iP.Results.FigTitle;
figNumber = iP.Results.FigNumber;
figName = iP.Results.FigName;
[~, figTypes] = isfigtype(iP.Results.FigTypes, 'ValidateMode', true);

%% Preparation
% Force data vectors as column cell arrays of column vectors
[tVecs, data, dataToCompare] = ...
    argfun(@force_column_cell, tVecs, data, dataToCompare);

% Match the number of vectors between data and dataToCompare
[data, dataToCompare] = match_array_counts(data, dataToCompare);

% Match the dimensions of tVecs to data
tVecs = match_dimensions(tVecs, size(data));

% Extract number of traces
nTraces = count_vectors(data);

% Decide on the colormap
if isempty(colorMap)
    if nTraces <= 12
        colorMap = create_colormap(nTraces);
    else
        colorMap = create_colormap(floor(sqrt(nTraces)));
    end
end

% Determine the number of rows and the number of traces per row
nRows = size(colorMap, 1);
nTracesPerRow = ceil(nTraces / nRows);

% Compute minimum and maximum Y values
% TODO: Consider dataToCompare range too
minY = min(cellfun(@min, data));
maxY = max(cellfun(@max, data));
rangeY = maxY - minY;

% Set the default time axis limits
if isempty(xLimits)
    % Compute minimum and maximum time values
    minT = min(cellfun(@min, tVecs));
    maxT = max(cellfun(@max, tVecs));

    % Compute x limits
    xLimits = [minT, maxT];
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
            yLabel = arrayfun(@(x) ['Trace #', num2str(x)], ...
                                transpose(1:nTraces), 'UniformOutput', false);
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
    % Force as column cell arrays
    yLabel = force_column_cell(yLabel);

    % Match up to nTraces elements
    yLabel = match_dimensions(yLabel, [nTraces, 1]);
otherwise
    error(['The plot mode ', plotMode, ' has not been implemented yet!']);
end

% Set the default trace labels
if isempty(traceLabels)
    traceLabels = arrayfun(@(x) ['Trace #', num2str(x)], ...
                            transpose(1:nTraces), 'UniformOutput', false);
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
if strcmpi(legendLocation, 'auto')
    if nTraces > 1 && nTraces < 10
        legendLocation = 'northeast';
    elseif nTraces >= 10 && nTraces < 20
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

%% Plot
% Plot all traces
switch plotMode
case 'overlapped'
    % Hold on
    hold on

    % Plot all traces together
    for iTrace = 1:nTraces
        % Get the current row (color) number
        thisRowNumber = ceil(iTrace/nTracesPerRow);

        % Plot data to compare against as a black trace
        if ~isempty(dataToCompare{iTrace})
            p2(iTrace) = plot(tVecs{iTrace}, dataToCompare{iTrace}, ...
                'Color', 'k');
        end
        
        % Plot the data using the color map
        p1(iTrace) = plot(tVecs{iTrace}, data{iTrace}, ...
            'Color', colorMap(thisRowNumber, :));

        % Set the legend label as the trace label if provided
        if ~strcmpi(traceLabels, 'suppress')
            set(p1(iTrace), 'DisplayName', traceLabels{iTrace});
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
        legend(p1, 'location', legendLocation);
    end

    % Hold off
    hold off
case 'parallel'
    if ~strcmpi(legendLocation, 'suppress')
        % Set a legend location differently    
        legendLocation = 'northeast';
    end

    % Plot each trace as a different subplot
    %   Note: the number of rows is based on the number of rows in the color map
    for iTrace = 1:nTraces
        % Create a subplot and hold on
        ax = subplot(nRows, nTracesPerRow, iTrace); hold on

        % Get the current row number
        thisRowNumber = ceil(iTrace/nTracesPerRow);

        % Get the current column number
        thisColNumber = mod(iTrace, nTracesPerRow);
        
        % Plot data to compare against as a black trace
        if ~isempty(dataToCompare{iTrace})
            p2 = plot(tVecs{iTrace}, dataToCompare{iTrace}, ...
                'Color', 'k');
        end

        % Plot the data using the color map
        p1 = plot(tVecs{iTrace}, data{iTrace}, ...
                'Color', colorMap(thisRowNumber, :));

        % Set the legend label as the trace label if provided
        if ~strcmpi(traceLabels, 'suppress')
            set(p1, 'DisplayName', traceLabels{iTrace});
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
            legend(p1, 'location', legendLocation);
        end

        % Remove x tick labels except for the last row
        if thisRowNumber ~= nRows
            set(ax, 'XTickLabel', []);
        end

        % Remove x tick labels except for the first column
        if thisColNumber ~= 1
            set(ax, 'YTickLabel', []);
        end

        % Create a title for the first subplot
        if ~strcmpi(figTitle, 'suppress') && nTracesPerRow == 1 && ...
            iTrace == 1
            title(figTitle, 'Interpreter', 'none');
        end

        % Create a label for the X axis only for the last row
        if ~strcmpi(xLabel, 'suppress') && nTracesPerRow == 1 && ...
            iTrace == nTraces
            xlabel(xLabel);
        end

        % Save axes in array
        axesAll(iTrace) = ax;

        % Hold off
        hold off
    end

    % If requested, link or unlink axes of subplots
    if ~strcmpi(linkAxesOption, 'none')
        linkaxes(axesAll, linkAxesOption);
    end

    % If nTraces >= 20, expand all subplots by 1.2
    if nTraces >= 20
        subplotsqueeze(h, 1.2);
    end
    
    % Create an overarching title
    if ~strcmpi(figTitle, 'suppress') && nTracesPerRow > 1
        suptitle(figTitle);
    end

    % Create an overarching x-axis label
    if ~strcmpi(xLabel, 'suppress') && nTracesPerRow > 1
        suplabel(xLabel, 'x');
    end
otherwise
    error(['The plot mode ', plotMode, ' has not been implemented yet!']);
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

subplot(nTraces, 1, iTrace);

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

nTraces = size(data, 2);

xLimits = cellfun(@(x), [min(x), max(x)], tVecs, 'UniformOutput', false);

minY = min(min(data));
maxY = max(max(data));

yLabel = cell(1, nTraces);
parfor iTrace = 1:nTraces
    yLabel{iTrace} = ['Trace #', num2str(iTrace)];
end

traceLabels = cell(1, nTraces);
parfor iTrace = 1:nTraces
    traceLabels{iTrace} = ['Trace #', num2str(iTrace)];
end

% Hold on if more than one trace
if nTraces > 1
    hold on
end
% Hold off if more than one trace
if nTraces > 1
    hold off
end

%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
