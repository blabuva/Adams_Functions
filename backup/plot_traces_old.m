function [fig, subPlots, plotsData, plotsDataToCompare] = ...
                plot_traces (tVecs, data, varargin)
%% Plots traces all in one place, overlapped or in parallel
% Usage: [fig, subPlots, plotsData, plotsDataToCompare] = ...
%               plot_traces (tVecs, data, varargin)
% Examples:
%       plot_traces(1:3, magic(3))
%       plot_traces(1:3, magic(3), 'PlotMode', 'parallel')
%       plot_traces(1:100, rand(100, 3), 'PlotMode', 'staggered')
%       plot_traces(1:100, rand(100, 3), 'PlotMode', 'staggered', 'YAmount', 1)
%       plot_traces(1:3, magic(3), 'PlotMode', 'parallel', 'ReverseOrder', true)
%       plot_traces(1:60, magic(60), 'PlotMode', 'parallel', 'LinkAxesOption', 'y')
%       plot_traces(1:60, magic(60), 'PlotMode', 'parallel', 'SubplotOrder', 'list', 'LinkAxesOption', 'y')
%
% Outputs:
%       fig         - figure handle for the created figure
%                   specified as a figure object handle
%       subPlots    - axes handles for the subplots
%                   specified as a vector of axes object handles
%       plotsData   - line handles for the data plots
%                   specified as a vector of chart line object handles
%       plotsDataToCompare  - line handles for the data to compare plots
%                   specified as a vector of chart line object handles
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
%       varargin    - 'Verbose': whether to write to standard output
%                   must be numeric/logical 1 (true) or 0 (false)
%                   default == true
%                   - 'OverWrite': whether to overwrite existing output
%                   must be numeric/logical 1 (true) or 0 (false)
%                   default == true
%                   - 'AutoZoom': whether to zoom in on the y axis 
%                                   to within a certain number of SDs 
%                                       of the mean
%                                   cf. compute_axis_limits.m
%                   must be numeric/logical 1 (true) or 0 (false)
%                   default == false
%                   - 'ReverseOrder': whether to reverse the order of the traces
%                   must be numeric/logical 1 (true) or 0 (false)
%                   default == false
%                   - 'PlotMode': plotting mode for multiple traces
%                   must be an unambiguous, case-insensitive match to one of: 
%                       'parallel'      - in parallel in subPlots
%                       'overlapped'    - overlapped in a single plot
%                       'staggered'     - staggered in a single plot
%                   default == 'overlapped'
%                   - 'SubplotOrder': ordering of subplots
%                   must be an unambiguous, case-insensitive match to one of: 
%                       'auto'    - use default
%                       'bycolor' - by the color map if it is provided
%                       'square'  - as square as possible
%                       'list'    - one column
%                   default == 'auto'
%                   - 'ColorMode': how to map colors
%                   must be an unambiguous, case-insensitive match to one of: 
%                       'auto'          - use default
%                       'byPlot'        - by each plot
%                       'byRow'         - by each row
%                       'byTraceInPlot' - by each trace in a plot
%                   default == 'auto'
%                   - 'DataToCompare': data vector(s) to compare against
%                   Note: If a cell array, each element must be a vector
%                         If a non-vector array, each column is a vector
%                   must be a numeric array or a cell array of numeric arrays
%                   default == []
%                   - 'LineStyleToCompare': line style for 
%                                           data vector(s) to compare
%                   must be an unambiguous, case-insensitive match to one of: 
%                       '-'     - solid line
%                       '--'    - dashed line
%                       ':'     - dotted line
%                       '-.'    - dash-dotted line
%                       'none'  - no line
%                   default == '-'
%                   - 'YAmountToStagger': amount to stagger 
%                                           if 'plotmode' is 'stagger'
%                   must be a positive scalar
%                   default == uses the original y axis range
%                   - 'XLimits': limits of x axis
%                               suppress by setting value to 'suppress'
%                   must be 'suppress' or a 2-element increasing numeric vector
%                   default == uses compute_axis_limits.m
%                   - 'YLimits': limits of y axis, 
%                               suppress by setting value to 'suppress'
%                   must be 'suppress' or a 2-element increasing numeric vector
%                   default == uses compute_axis_limits.m
%                   - 'LinkAxesOption': option for the linkaxes() function
%                   must be an unambiguous, case-insensitive match to one of: 
%                       'none' - don't apply the function
%                       'x'    - link x axes only
%                       'y'    - link y axes only
%                       'xy'   - link x and y axes
%                       'off'  - unlink axes
%                   must be consistent with linkaxes()
%                   default == 'none'
%                   - 'XUnits': x-axis units
%                   must be a string scalar or a character vector 
%                       or a cell array of strings or character vectors
%                   default == 'unit'
%                   - 'XLabel': label for the time axis, 
%                               suppress by setting value to 'suppress'
%                   must be a string scalar or a character vector 
%                       or a cell array of strings or character vectors
%                   default == ['Time (', xUnits, ')']
%                   - 'YLabel': label(s) for the y axis, 
%                               suppress by setting value to 'suppress'
%                   must be a string scalar or a character vector 
%                       or a cell array of strings or character vectors
%                   default == 'Data' if plotMode is 'overlapped'
%                               {'Trace #1', 'Trace #2', ...}
%                                   if plotMode is 'parallel'
%                   - 'TraceLabels': labels for the traces, 
%                               suppress by setting value to 'suppress'
%                   must be a string scalar or a character vector 
%                       or a cell array of strings or character vectors
%                   default == {'Trace #1', 'Trace #2', ...}
%                   - 'YTickLocs': locations of Y ticks
%                   must be 'suppress' or a numeric vector
%                   default == ntrials:1
%                   - 'YTickLabels': labels for each raster
%                   must be 'suppress' or a cell array of character/string arrays
%                   default == trial numbers
%                   - 'ColorMap': a color map that also groups traces
%                                   each set of traces will be on the same row
%                                   if the plot mode is 'parallel' and 
%                                       the subplot order is 'bycolor'
%                   must be a numeric array with 3 columns
%                   default == colormap(jet(nPlots))
%                   - 'LegendLocation': location for legend
%                   must be an unambiguous, case-insensitive match to one of: 
%                       'auto'      - use default
%                       'suppress'  - no legend
%                       anything else recognized by the legend() function
%                   default == 'suppress' if nPlots == 1 
%                               'northeast' if nPlots is 2~9
%                               'eastoutside' if nPlots is 10+
%                   - 'FigTitle': title for the figure
%                   must be a string scalar or a character vector
%                   default == ['Traces for ', figName]
%                               or [yLabel, ' over time']
%                   - 'FigHandle': figure handle for created figure
%                   must be a empty or a figure object handle
%                   default == []
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
%                   - Any other parameter-value pair for the plot() function
%
% Requires:
%       cd/apply_iteratively.m
%       cd/argfun.m
%       cd/compute_axis_limits.m
%       cd/count_vectors.m
%       cd/create_colormap.m
%       cd/create_error_for_nargin.m
%       cd/create_indices.m
%       cd/create_labels_from_numbers.m
%       cd/set_figure_properties.m
%       cd/extract_subvectors.m
%       cd/find_window_endpoints.m
%       cd/isemptycell.mplot_traces
%       cd/isfigtype.m
%       cd/islegendlocation.m
%       cd/islinestyle.m
%       cd/ispositiveintegerscalar.m
%       cd/match_format_vector_sets.m
%       cd/save_all_figtypes.m
%       cd/transform_vectors.m
%       ~/Downloaded_Function/suplabel.m
%       ~/Downloaded_Function/subplotsqueeze.m
%
% Used by:
%       cd/plot_fitted_traces.m
%       cd/plot_traces_abf.m

% File History:
% 2018-09-18 Moved from plot_traces_abf.m
% 2018-09-25 Implemented the input parser
% 2018-09-25 Added 'PlotMode' and 'LegendLocation' as optional parameters
% 2018-10-29 Added 'ColorMap' as an optional parameter
% 2018-10-29 Number of rows in parallel mode is now dependent on the 
%               number of rows in the colorMap provided
% 2018-10-29 Added 'DataToCompare' as an optional parameter
% 2018-10-31 Now uses match_format_vector_sets.m
% 2018-11-01 Now returns axes handles for subplots
% 2018-11-22 Now accepts xLimits as a cell array
% 2018-11-22 Added 'XUnits' as an optional parameter
% 2018-12-15 Fixed the passing of parameters to the helper function
% 2018-12-15 Now returns the axes handle as the second output
%               for overlapped plots
% 2018-12-17 Now uses create_labels_from_numbers.m
% 2018-12-17 Now uses iP.Unmatched
% 2018-12-17 Now uses compute_xlimits.m and compute_ylimits.m
% 2018-12-19 Now returns line object handles for the plots
% 2018-12-19 Added 'FigHandle' as an optional argument
% 2018-12-19 Now restricts vectors to x limits first
% 2018-12-19 Now considers dataToCompare range too when computing y axis limits
% 2019-01-03 Now allows multiple traces to be plotted on one subplot
% 2019-01-03 Added 'SubplotOrder' as an optional argument
% 2019-01-03 Added 'ColorMode' as an optional argument
% 2019-01-03 Now allows TeX interpretation in titles
% 2019-04-08 Added 'ReverseOrder' as an optional argument
% 2019-04-24 Added 'AutoZoom' as an optional argument
% 2019-04-26 Added 'staggered' as a valid plot mode 
%               and added 'YAmountToStagger' as an optional argument
% 2019-05-10 Now uses set_figure_properties.m
% 2019-07-25 Added maxNYTicks

%% Hard-coded parameters
validPlotModes = {'overlapped', 'parallel', 'staggered'};
validSubplotOrders = {'bycolor', 'square', 'list', 'auto'};
validColorModes = {'byPlot', 'byRow', 'byTraceInPlot', 'auto'};
validLinkAxesOptions = {'none', 'x', 'y', 'xy', 'off'};
maxRowsWithOneOnly = 8;
maxNPlotsForTraceNum = 8;
maxNPlotsForAnnotations = 8;
maxNYLabels = 10;
maxNPlotsForLegends = 12;
maxNColsForTicks = 30;
maxNColsForXTickLabels = 30;
maxNRowsForTicks = 30;
maxNRowsForYTickLabels = 30;
maxNRowsForXAxis = 30;
maxNColsForYAxis = 30;
maxNYTicks = 20;                % maximum number of Y ticks
subPlotSqeezeFactor = 1.2;

%% Default values for optional arguments
verboseDefault = true;
overWriteDefault = true;        % overwrite previous plots by default
autoZoomDefault = false;        % don't zoom in on y axis by default
reverseOrderDefault = false;    % don't reverse order by default
plotModeDefault = 'overlapped'; % plot traces overlapped by default
subplotOrderDefault = 'auto';   % set later
colorModeDefault = 'auto';      % set later
dataToCompareDefault = [];      % no data to compare against by default
lineStyleToCompareDefault = '-';% data to compare are solid lines by default
yAmountToStaggerDefault = [];   % set later  
xLimitsDefault = [];            % set later
yLimitsDefault = [];            % set later
linkAxesOptionDefault = 'none'; % don't force link axes by default
xUnitsDefault = 'unit';         % the default x-axis units
xLabelDefault = '';             % set later
yLabelDefault = '';             % set later
traceLabelsDefault = '';        % set later
yTickLocsDefault = [];          % set later
yTickLabelsDefault = {};        % set later
colorMapDefault = [];           % set later
legendLocationDefault = 'auto'; % set later
figTitleDefault = '';           % set later
figHandleDefault = [];          % no existing figure by default
figNumberDefault = [];          % no figure number by default
figNameDefault = '';            % don't save figure by default
figTypesDefault = 'png';        % save as png file by default

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Deal with arguments
% Check number of required arguments
if nargin < 2
    error(create_error_for_nargin(mfilename));
end

% Set up Input Parser Scheme
iP = inputParser;
iP.FunctionName = mfilename;
iP.KeepUnmatched = true;                        % allow extraneous options

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
addParameter(iP, 'Verbose', verboseDefault, ...
    @(x) validateattributes(x, {'logical', 'numeric'}, {'binary'}));
addParameter(iP, 'OverWrite', overWriteDefault, ...
    @(x) validateattributes(x, {'logical', 'numeric'}, {'binary'}));
addParameter(iP, 'AutoZoom', autoZoomDefault, ...
    @(x) validateattributes(x, {'logical', 'numeric'}, {'binary'}));
addParameter(iP, 'ReverseOrder', reverseOrderDefault, ...
    @(x) validateattributes(x, {'logical', 'numeric'}, {'binary'}));
addParameter(iP, 'PlotMode', plotModeDefault, ...
    @(x) any(validatestring(x, validPlotModes)));
addParameter(iP, 'SubplotOrder', subplotOrderDefault, ...
    @(x) any(validatestring(x, validSubplotOrders)));
addParameter(iP, 'ColorMode', colorModeDefault, ...
    @(x) any(validatestring(x, validColorModes)));
addParameter(iP, 'DataToCompare', dataToCompareDefault, ...
    @(x) assert(isnumeric(x) || iscellnumeric(x), ...
                ['vec1s must be either a numeric array ', ...
                    'or a cell array of numeric arrays!']));
addParameter(iP, 'LineStyleToCompare', lineStyleToCompareDefault, ...
    @(x) all(islinestyle(x, 'ValidateMode', true)));
addParameter(iP, 'YAmountToStagger', yAmountToStaggerDefault, ...
    @(x) validateattributes(x, {'numeric'}, {'positive', 'scalar'}));
addParameter(iP, 'XLimits', xLimitsDefault, ...
    @(x) isempty(x) || iscell(x) || ischar(x) && strcmpi(x, 'suppress') || ...
        isnumeric(x) && isvector(x) && length(x) == 2);
addParameter(iP, 'YLimits', yLimitsDefault, ...
    @(x) isempty(x) || ischar(x) && strcmpi(x, 'suppress') || ...
        isnumeric(x) && isvector(x) && length(x) == 2);
addParameter(iP, 'LinkAxesOption', linkAxesOptionDefault, ...
    @(x) any(validatestring(x, validLinkAxesOptions)));
addParameter(iP, 'XUnits', xUnitsDefault, ...
    @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
addParameter(iP, 'XLabel', xLabelDefault, ...
    @(x) ischar(x) || iscellstr(x) || isstring(x));
addParameter(iP, 'YLabel', yLabelDefault, ...
    @(x) ischar(x) || iscellstr(x) || isstring(x));
addParameter(iP, 'TraceLabels', traceLabelsDefault, ...
    @(x) ischar(x) || iscellstr(x) || isstring(x));
addParameter(iP, 'YTickLocs', yTickLocsDefault, ...
    @(x) assert(ischar(x) && strcmpi(x, 'suppress') || isnumericvector(x), ...
        'YTickLocs must be ''suppress'' or a numeric vector!'));
addParameter(iP, 'YTickLabels', yTickLabelsDefault, ...
    @(x) assert(ischar(x) && strcmpi(x, 'suppress') || ...
                iscell(x) && all(cellfun(@(x) ischar(x) || isstring(x), x)), ...
        'YTickLabels must be ''suppress'' or a cell array of character/string arrays!'));
addParameter(iP, 'ColorMap', colorMapDefault, ...
    @(x) isempty(x) || isnumeric(x) && size(x, 2) == 3);
addParameter(iP, 'LegendLocation', legendLocationDefault, ...
    @(x) all(islegendlocation(x, 'ValidateMode', true)));
addParameter(iP, 'FigTitle', figTitleDefault, ...
    @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
addParameter(iP, 'FigHandle', figHandleDefault);
addParameter(iP, 'FigNumber', figNumberDefault, ...
    @(x) assert(isempty(x) || ispositiveintegerscalar(x), ...
                'FigNumber must be a empty or a positive integer scalar!'));
addParameter(iP, 'FigName', figNameDefault, ...
    @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
addParameter(iP, 'FigTypes', figTypesDefault, ...
    @(x) all(isfigtype(x, 'ValidateMode', true)));

% Read from the Input Parser
parse(iP, tVecs, data, varargin{:});
verbose = iP.Results.Verbose;
overWrite = iP.Results.OverWrite;
autoZoom = iP.Results.AutoZoom;
reverseOrder = iP.Results.ReverseOrder;
plotMode = validatestring(iP.Results.PlotMode, validPlotModes);
subplotOrder = validatestring(iP.Results.SubplotOrder, validSubplotOrders);
colorMode = validatestring(iP.Results.ColorMode, validColorModes);
dataToCompare = iP.Results.DataToCompare;
[~, lineStyleToCompare] = ...
    islinestyle(iP.Results.LineStyleToCompare, 'ValidateMode', true);
yAmountToStagger = iP.Results.YAmountToStagger;
xLimits = iP.Results.XLimits;
yLimits = iP.Results.YLimits;
linkAxesOption = validatestring(iP.Results.LinkAxesOption, ...
                                validLinkAxesOptions);
xUnits = iP.Results.XUnits;
xLabel = iP.Results.XLabel;
yLabel = iP.Results.YLabel;
traceLabels = iP.Results.TraceLabels;
yTickLocs = iP.Results.YTickLocs;
yTickLabels = iP.Results.YTickLabels;
colorMap = iP.Results.ColorMap;
[~, legendLocation] = islegendlocation(iP.Results.LegendLocation, ...
                                        'ValidateMode', true);
figTitle = iP.Results.FigTitle;
figHandle = iP.Results.FigHandle;
figNumber = iP.Results.FigNumber;
figName = iP.Results.FigName;
[~, figTypes] = isfigtype(iP.Results.FigTypes, 'ValidateMode', true);

% Keep unmatched arguments for the plot() function
otherArguments = iP.Unmatched;

%% Preparation
% If data is empty, return
if isempty(data) || iscell(data) && all(isemptycell(data))
    fprintf('Nothing to plot!\n');
    return
end

% If not to overwrite, check if the figure already exists
if ~overWrite && check_fullpath(figName, 'Verbose', verbose)
    % Skip this figure
    fprintf('%s skipped!\n', figName);
    return;
end

% Restrict to x limits for faster processing
if ~isempty(xLimits) && isnumeric(xLimits)
    % Find the end points
    endPoints = find_window_endpoints(xLimits, tVecs);

    % Restrict to these end points
    [tVecs, data, dataToCompare] = ...
        argfun(@(x) extract_subvectors(x, 'EndPoints', endPoints), ...
                tVecs, data, dataToCompare);
end

% Match the number of vectors between data and dataToCompare
%   and make sure boths are column cell arrays of column vectors
[data, dataToCompare] = ...
    match_format_vector_sets(data, dataToCompare, 'ForceCellOutputs', true);

% Extract number of subplots (under parallel mode)
nPlots = count_vectors(data, 'TreatMatrixAsVector', true);

% Count the number of traces per subplot (under parallel mode)
nTracesPerPlot = count_vectors(data, 'TreatMatrixAsVector', false);

% Determine the number of rows and the number of columns
[nRows, nColumns] = ...
    decide_on_subplot_placement(subplotOrder, nPlots, ...
                                colorMap, maxRowsWithOneOnly);

% Decide on a default colorMode if not provided
if strcmpi(colorMode, 'auto')
    if ~isempty(colorMap)
        colorMode = 'byRow';
    else
        colorMode = 'byPlot';
    end
end

% Decide on a colormap
if isempty(colorMap)
    switch colorMode
        case 'byPlot'
            colorMap = create_colormap(nPlots);
        case 'byRow'
            colorMap = create_colormap(nRows);
        case 'byColumn'
            colorMap = create_colormap(nColumns);
        case 'byTraceInPlot'
            colorMap = create_colormap(nTracesPerPlot);
        otherwise
            error('colorMode unrecognized!');
    end
end

% Force as column cell array and match up to nPlots elements 
tVecs = match_format_vector_sets(tVecs, data);

% Reverse the order of the traces if requested
if reverseOrder
    [tVecs, data, dataToCompare] = ...
        argfun(@flipud, tVecs, data, dataToCompare);
end

% Set the default trace numbers
if reverseOrder
    defaultTraceNumbers = nPlots:-1:1;
else
    defaultTraceNumbers = 1:nPlots;
end

% Set the default trace labels
if nPlots > maxNPlotsForTraceNum
    defaultTraceLabels = create_labels_from_numbers(defaultTraceNumbers);
else
    defaultTraceLabels = ...
        create_labels_from_numbers(defaultTraceNumbers, 'Prefix', 'Trace #');
end

% Set the default x-axis labels
if isempty(xLabel)
    xLabel = ['Time (', xUnits, ')'];
end

% Set the default y-axis labels
if isempty(yLabel)
    switch plotMode
    case 'overlapped'
        yLabel = 'Data';
    case 'staggered'
        yLabel = 'Trace #';
    case 'parallel'
        if nPlots > 1
            yLabel = defaultTraceLabels;
        else
            yLabel = {'Data'};
        end
    otherwise
        error(['The plot mode ', plotMode, ' has not been implemented yet!']);
    end
end

% Make sure y-axis labels are consistent
switch plotMode
case {'overlapped', 'staggered'}
    if iscell(yLabel)
        fprintf('Only the first yLabel will be used!\n');
        yLabel = yLabel{1};
    end
case 'parallel'
    % Force as column cell array and match up to nPlots elements
    yLabel = match_format_vector_sets(yLabel, data);
otherwise
    error(['The plot mode ', plotMode, ' has not been implemented yet!']);
end

% Set the default trace labels
if isempty(traceLabels)
    traceLabels = defaultTraceLabels;
end

% Make sure trace labels are cell arrays
if ~isempty(traceLabels) && ...
    (ischar(traceLabels) || isstring(traceLabels)) && ...
    ~strcmpi(traceLabels, 'suppress')
    traceLabels = {traceLabels};
end

% Check if traceLabels has the correct length
if iscell(traceLabels) && numel(traceLabels) ~= nPlots
    error('traceLabels has %d elements instead of %d!!', ...
            numel(traceLabels), nPlots);
end

% Set the default figure title
if isempty(figTitle)
    if ~isempty(figName) && nPlots == 1
        figTitle = ['Traces for ', traceLabels{1}];
    elseif ~isempty(figName)
        figTitle = ['Traces for ', figName];
    elseif ischar(yLabel) && ~strcmp(plotMode, 'staggered')
        figTitle = [yLabel, ' over ', xLabel];
    else
        figTitle = ['Data over ', xLabel];        
    end
end

% Set legend location based on number of subplots
if strcmpi(legendLocation, 'auto')
    if nPlots > 1 && nPlots <= maxNPlotsForAnnotations
        legendLocation = 'northeast';
    elseif nPlots > maxNPlotsForAnnotations && nPlots <= maxNPlotsForLegends
        legendLocation = 'eastoutside';
    else
        legendLocation = 'suppress';
    end
end

%% Plot data over all possible intervals
if iscell(xLimits)
    % Count the number of intervals
    nIntervals = numel(xLimits);

    % Run through all intervals
    % TODO: Implement the updating data strategy instead
    parfor iInterval = 1:nIntervals
    % Get the current x-axis limits
        xLimitsThis = xLimits{iInterval};

        % Create a string for the interval
        intervalStrThis = sprintf('%.0f-%.0f%s', ...
                            xLimitsThis(1), xLimitsThis(2), xUnits);

        % Extract the file extension
        % TODO: Make a function append_suffix_to_filename.m
        fileExt = extract_fileparts(figName, 'extension');

        % Construct a file suffix
        suffixThis = sprintf('_%s%s', intervalStrThis, fileExt);

        % Create a new figure name
        figNameThis = regexprep(figName, [fileExt, '$'], [suffixThis, '$']);

        % If not to overwrite, check if the figure already exists
        if ~overWrite && check_fullpath(figNameThis, 'Verbose', verbose)
            % Skip this figure
            fprintf('%s skipped!\n', figNameThis);
        else
            % Print to standard output
            if verbose
                fprintf('Interval to show = %s\n', intervalStrThis);
            end
            
            % Create a new figure title
            if ~strcmpi(figTitle, 'suppress')
                figTitleThis = [figTitle, ' (', intervalStrThis, ')'];
            else
                figTitleThis = 'suppress';
            end

            % Find the corresponding index endpoints
            endPoints = find_window_endpoints(xLimitsThis, tVecs, ...
                                                'BoundaryMode', 'inclusive');

            % Truncate all traces
            [tVecsThis, dataThis, dataToCompareThis] = ...
                argfun(@(x) extract_subvectors(x, 'EndPoints', endPoints), ...
                        tVecs, data, dataToCompare);

            % Plot all traces
            fig = plot_traces_helper(verbose, plotMode, colorMode, ...
                            autoZoom, yAmountToStagger, ...
                            tVecsThis, dataThis, ...
                            dataToCompareThis, lineStyleToCompare, ...
                            xUnits, xLimitsThis, yLimits, linkAxesOption, ...
                            xLabel, yLabel, traceLabels, ...
                            yTickLocs, yTickLabels, colorMap, ...
                            legendLocation, figTitleThis, ...
                            figHandle, figNumber, figNameThis, figTypes, ...
                            nPlots, nRows, nColumns, nTracesPerPlot, ...
                            maxNPlotsForAnnotations, maxNYLabels, ...
                            maxNColsForTicks, maxNColsForXTickLabels, ...
                            maxNRowsForTicks, maxNRowsForYTickLabels, ...
                            maxNRowsForXAxis, maxNColsForYAxis, ...
                            maxNYTicks, ...
                            subPlotSqeezeFactor, ...
                            otherArguments);
            
            % Hold off and close figure
            hold off;
            close(fig)
        end
    end

    % Return nothing
    fig = gobjects(1);
    subPlots = gobjects(1);
    plotsData = gobjects(1);
    plotsDataToCompare = gobjects(1);
else
    % Plot all traces
    [fig, subPlots, plotsData, plotsDataToCompare] = ...
        plot_traces_helper(verbose, plotMode, colorMode, ...
                        autoZoom, yAmountToStagger, ...
                        tVecs, data, dataToCompare, lineStyleToCompare, ...
                        xUnits, xLimits, yLimits, linkAxesOption, ...
                        xLabel, yLabel, traceLabels, ...
                        yTickLocs, yTickLabels, colorMap, ...
                        legendLocation, figTitle, ...
                        figHandle, figNumber, figName, figTypes, ...
                        nPlots, nRows, nColumns, nTracesPerPlot, ...
                        maxNPlotsForAnnotations, maxNYLabels, ...
                        maxNColsForTicks, maxNColsForXTickLabels, ...
                        maxNRowsForTicks, maxNRowsForYTickLabels, ...
                        maxNRowsForXAxis, maxNColsForYAxis, ...
                        maxNYTicks, ...
                        subPlotSqeezeFactor, ...
                        otherArguments);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [fig, subPlots, plotsData, plotsDataToCompare] = ...
                plot_traces_helper (verbose, plotMode, colorMode, ...
                        autoZoom, yAmountToStagger, ...
                        tVecs, data, dataToCompare, lineStyleToCompare, ...
                        xUnits, xLimits, yLimits, linkAxesOption, ...
                        xLabel, yLabel, traceLabels, ...
                        yTickLocs, yTickLabels, colorMap, ...
                        legendLocation, figTitle, ...
                        figHandle, figNumber, figName, figTypes, ...
                        nPlots, nRows, nColumns, nTracesPerPlot, ...
                        maxNPlotsForAnnotations, maxNYLabels, ...
                        maxNColsForTicks, maxNColsForXTickLabels, ...
                        maxNRowsForTicks, maxNRowsForYTickLabels, ...
                        maxNRowsForXAxis, maxNColsForYAxis, ...
                        maxNYTicks, ...
                        subPlotSqeezeFactor, ...
                        otherArguments)

% Decide on the figure to plot on
fig = set_figure_properties('FigHandle', figHandle, 'FigNumber', figNumber);

% Set the default time axis limits
if isempty(xLimits)
    xLimits = compute_axis_limits(tVecs, 'x');
end

% Initialize graphics object arrays for plots
if numel(nTracesPerPlot) > 1
    plotsData = cell(nPlots, 1);
    plotsDataToCompare = cell(nPlots, 1);
else
    plotsData = gobjects(nPlots, 1);
    plotsDataToCompare = gobjects(nPlots, 1);
end

switch plotMode
case {'overlapped', 'staggered'}
    % Hold on
    hold on

    % Decide whether to stagger
    if strcmp(plotMode, 'staggered')
        toStagger = true;
    else
        toStagger = false;
    end

    % Set the default y-axis limits
    if isempty(yLimits)
        % Compute the y limits from both data and dataToCompare
        yLimits = compute_axis_limits({data, dataToCompare}, 'y', ...
                                        'AutoZoom', autoZoom);
    elseif iscell(yLimits)
        % TODO: Deal with yLimits if it is a cell array
    end

    % Decide on the amount in y axis units to stagger
    %   and the new y-axis limits
    if toStagger
        % Use the mean and range of the original computed y axis limits 
        %   from the data
        yMean = mean(yLimits);
        if isempty(yAmountToStagger)
            yAmountToStagger = range(yLimits);
        end

        % Compute new y axis limits
        yLimits = yAmountToStagger * ([0, nPlots]  + 0.5);

        % Create indices in reverse
        indRev = create_indices([nPlots; 1]);

        % Compute y offsets (where the means are placed)
        yOffsets = yAmountToStagger .* indRev;

        % Create indices for y ticks
        indYTicks = create_indices([1; nPlots], 'MaxNum', maxNYTicks, ...
                                    'AlignMethod', 'left');

        % Set y tick locations
        %   Note: this must be increasing
        if isempty(yTickLocs)
            % Compute y tick locations
            yTickLocs = yAmountToStagger .* indYTicks;
        end

        % Set y tick labels
        %   Note: this must correspond to yTickLocs
        if isempty(yTickLabels)
            yTickLabels = create_labels_from_numbers(nPlots + 1 - indYTicks);
        end

        % Subtract by the mean
        [data, dataToCompare] = ...
            argfun(@(x) transform_vectors(x, yMean, 'subtract'), ...
                    data, dataToCompare);

        % Add offsets
        [data, dataToCompare] = ...
            argfun(@(x) transform_vectors(x, num2cell(yOffsets), 'add'), ...
                    data, dataToCompare);
    else
        yAmountToStagger = NaN;
        yOffsets = [];
        yTickLocs = [];
        yTickLabels = {};
    end

    % Plot all plots together
    for iPlot = 1:nPlots
        % Get the current tVecs and data
        tVecsThis = tVecs{iPlot};
        dataThis = data{iPlot};
        dataToCompareThis = dataToCompare{iPlot};

        % Decide on the color for this plot
        colorThis = decide_on_this_color(colorMode, colorMap, ...
                                        iPlot, nColumns);

        % Get the number of colors for this plot
        nColorsThis = size(colorThis, 1);

        % Plot data to compare against as a black trace
        if ~isempty(dataToCompareThis)
            p2 = plot(tVecsThis, dataToCompareThis, 'Color', 'k', ...
                        'LineStyle', lineStyleToCompare, otherArguments);
        end
        
        % Plot the data using the color map
        if size(colorThis, 1) == 1
            p1 = plot(tVecsThis, dataThis, 'Color', colorThis, otherArguments);
        else
            p1 = arrayfun(@(x) plot(tVecsThis(:, x), dataThis(:, x), ...
                                'Color', colorThis(:, x), otherArguments), ...
                            transpose(1:nColorsThis));
        end

        % Set the legend label as the trace label if provided
        if ~strcmpi(traceLabels, 'suppress')
            set(p1, 'DisplayName', traceLabels{iPlot});
        end

        % Store handles in array
        if iscell(plotsData)
            plotsData{iPlot} = p1;
        else
            plotsData(iPlot) = p1;
        end
        if ~isempty(dataToCompareThis)
            if iscell(plotsDataToCompare)
                plotsDataToCompare{iPlot} = p2;
            else
                plotsDataToCompare(iPlot) = p2;
            end
        end
    end
    
    % Set time axis limits
    if ~iscell(xLimits) && ...
        ~(ischar(xLimits) && ~strcmpi(xLimits, 'suppress'))
        xlim(xLimits);
    end

    % Set y axis limits
    if ~isempty(yLimits) && ...
        ~(ischar(yLimits) && strcmpi(yLimits, 'suppress'))
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

    % Decide on Y tick values
    if ~isempty(yTickLocs)
        if ischar(yTickLocs) && strcmpi(yTickLocs, 'suppress')
            set(gca, 'YTick', []);
        else
            set(gca, 'YTick', yTickLocs);
        end
    end

    % Decide on Y tick labels
    if ~isempty(yTickLabels)
        if ischar(yTickLabels) && strcmpi(yTickLabels, 'suppress')
            set(gca, 'YTickLabel', {});
        else
            set(gca, 'YTickLabel', yTickLabels);
        end
    end

    % Generate a title
    if ~strcmpi(figTitle, 'suppress')
        title(figTitle);
    end

    % Generate a legend if there is more than one trace
    if ~strcmpi(legendLocation, 'suppress')
        legend(gca, 'location', legendLocation);
    end

    % Save current axes handle
    subPlots = gca;
case 'parallel'
    if ~strcmpi(legendLocation, 'suppress')
        % Set a legend location differently    
        legendLocation = 'northeast';
    end

    % Initialize graphics object arrays for subplots
    subPlots = gobjects(nPlots, 1);

    % Find the rows that will have y labels
    if nRows > maxNYLabels
        rowsWithYLabels = ...
            create_indices('IndexEnd', nRows, 'MaxNum', maxNYLabels);
    else
        rowsWithYLabels = create_indices('IndexEnd', nRows);
    end

    % Plot each trace as a different subplot
    %   Note: the number of rows is based on the number of rows in the color map
    for iPlot = 1:nPlots
        % Create a subplot and hold on
        ax = subplot(nRows, nColumns, iPlot); hold on

        % Get the current tVecs and data
        tVecsThis = tVecs{iPlot};
        dataThis = data{iPlot};

        % Compute the number of vectors in dataThis
        nVectors = size(dataThis, 2);

        % Set the default y-axis limits
        if isempty(yLimits)
            % Compute the y limits from both data and dataToCompare
            yLimitsThis = ...
                compute_axis_limits({data{iPlot}, dataToCompare{iPlot}}, ...
                                        'y', 'AutoZoom', autoZoom);
        elseif iscell(yLimits)
            yLimitsThis = yLimits{iPlot};
        else
            yLimitsThis = yLimits;
        end

        % Get the current row number
        thisRowNumber = ceil(iPlot/nColumns);

        % Get the current column number
        if nColumns > 1
            thisColNumber = mod(iPlot, nColumns);
        else
            thisColNumber = 1;
        end
        
        % Decide on the color for this plot
        colorThis = decide_on_this_color(colorMode, colorMap, ...
                                        iPlot, nColumns);

        % Get the number of colors for this plot
        nColorsThis = size(colorThis, 1);

        % Make sure the color map is big enough
        if nColorsThis < nVectors
            colorThis = match_row_count(colorThis, nVectors);
        end

        % Plot data to compare against as a black trace
        if ~isempty(dataToCompare{iPlot})
            plotsDataToCompare(iPlot) = ...
                plot(tVecs{iPlot}, dataToCompare{iPlot}, 'Color', 'k', ...
                        'LineStyle', lineStyleToCompare, otherArguments);
        end

        % Plot the data using the color map
        if size(colorThis, 1) == 1
            p = plot(tVecsThis, dataThis, 'Color', colorThis, otherArguments);
        else
            p = arrayfun(@(x) plot(tVecsThis(:, x), dataThis(:, x), ...
                                'Color', colorThis(x, :), otherArguments), ...
                            transpose(1:nVectors));
        end

        % Set the legend label as the trace label if provided
        if ~strcmpi(traceLabels, 'suppress')
            set(p, 'DisplayName', traceLabels{iPlot});
        end

        % Set time axis limits
        if ~iscell(xLimits) && ~strcmpi(xLimits, 'suppress')
            xlim(xLimits);
        end

        % Set y axis limits
        if ~isempty(yLimitsThis) && ~strcmpi(yLimitsThis, 'suppress')
            ylim(yLimitsThis);
        end

        % Generate a y-axis label
        % TODO: Make it horizontal if more than 3? Center it?
        if ~strcmpi(yLabel{iPlot}, 'suppress') && ...
                ismember(thisRowNumber, rowsWithYLabels)
            % if nRows > 3
            %     ylabel(yLabel{iPlot}, 'Rotation', 0);
            % else
                ylabel(yLabel{iPlot});
            % end
        end

        % Generate a legend
        if ~strcmpi(legendLocation, 'suppress')
            legend(ax, 'location', legendLocation);
        end

        % Remove x ticks if too many columns
        if nColumns > maxNColsForTicks
            set(ax, 'XTick', []);
            set(ax, 'TickLength', [0, 0]);
        end

        % Remove y ticks if too many rows
        if nRows > maxNRowsForTicks
            set(ax, 'YTick', []);
            set(ax, 'TickLength', [0, 0]);
        end

        % Remove x tick labels except for the last row
        %   or if too many columns
        if thisRowNumber ~= nRows || nColumns > maxNColsForXTickLabels
            set(ax, 'XTickLabel', []);
        end

        % Remove x tick labels except for the first column
        %   or if too many rows
        if thisColNumber ~= 1 || nRows > maxNRowsForYTickLabels
            set(ax, 'YTickLabel', []);
        end

        % TODO: Hide the X axis ruler if too many rows
        if nRows > maxNRowsForXAxis
            % ax.XRuler.Axle.Visible = 'off';
            xTick = get(ax, 'XTick');
            xTickLabel = get(ax, 'XTickLabel');
            set(ax.XAxis, 'Color', 'none');
            set(ax.XAxis.Label, 'Color', 'k');
            set(ax.XAxis.Label, 'Visible', 'on');
            set(ax, 'XTick', xTick);
            set(ax, 'XTickLabel', xTickLabel);
        end

        % Hide the Y axis ruler if too many columns
        if nColumns > maxNColsForYAxis
            % set(ax.YAxis, 'Color', 'r');
            % set(ax.YAxis.Label, 'Color', 'k');
            % set(ax.YAxis.Label, 'Visible', 'on');
        end

        % Create a title for the first subplot
        if ~strcmpi(figTitle, 'suppress') && ...
            nColumns == 1 && iPlot == 1
            title(figTitle);
        end

        % Create a label for the X axis only for the last row
        if ~strcmpi(xLabel, 'suppress') && nColumns == 1 && ...
                iPlot == nPlots
            xlabel(xLabel);
        end

        % Store handles in array
        subPlots(iPlot) = ax;
        if iscell(plotsData)
            plotsData{iPlot} = p;
        else
            plotsData(iPlot) = p;
        end
    end

    % If requested, link or unlink axes of subPlots
    if ~strcmpi(linkAxesOption, 'none')
        linkaxes(subPlots, linkAxesOption);
    end

    % If nPlots > maxNPlotsForAnnotations, expand all subPlots by 1.2
    if nPlots > maxNPlotsForAnnotations
        subplotsqueeze(fig, subPlotSqeezeFactor);
    end
    
    % Create an overarching title
    if ~strcmpi(figTitle, 'suppress') && nColumns > 1
        suptitle(figTitle);
    end

    % Create an overarching x-axis label
    if ~strcmpi(xLabel, 'suppress') && nColumns > 1 && ...
            nColumns < maxNPlotsForAnnotations
        suplabel(xLabel, 'x');
    end
otherwise
    error(['The plot mode ', plotMode, ' has not been implemented yet!']);
end

%% Save
% Save figure
if ~isempty(figName)
    % TODO: Save figure with other varying attributes
    if iscell(xLimits)
        % TODO: Pull out to function save_all_intervals.m
        %   Note: this part is very slow for large data

        % Count the number of intervals
        nIntervals = numel(xLimits);

        % Run through all intervals
        for iInterval = 1:nIntervals
            % Get the current x-axis limits
            xLimitsThis = xLimits{iInterval};

            % Create a string for the interval
            intervalStrThis = sprintf('%.0f-%.0f%s', ...
                                xLimitsThis(1), xLimitsThis(2), xUnits);

            % Print to standard output
            if verbose
                fprintf('Interval to show = %s\n', intervalStrThis);
            end
            
            % Create a new figure title
            if ~strcmpi(figTitle, 'suppress')
                figTitleThis = [figTitle, ' (', intervalStrThis, ')'];
            else
                figTitleThis = 'suppress';
            end

            % Change the x-axis limits
            switch plotMode
            case {'overlapped', 'staggered'}
                % Change the figure title
                if ~strcmpi(figTitleThis, 'suppress')
                    title(figTitleThis);
                end

                % Change the x-axis limits
                xlim(xLimitsThis);
            case 'parallel'
                for iPlot = 1:nPlots
                    % Go to the subplot
                    subplot(subPlots(iPlot));

                    % Create a title for the first subplot
                    if ~strcmpi(figTitleThis, 'suppress') && ...
                        nColumns == 1 && iPlot == 1
                        title(figTitleThis);
                    end

                    % Change x-axis limits
                    xlim(xLimitsThis);
                end

                % Create an overarching title
                if ~strcmpi(figTitleThis, 'suppress') && nColumns > 1
                    suptitle(figTitleThis);
                end
            end

            % Extract the file extension
            % TODO: Make a function append_suffix_to_filename.m
            fileExt = extract_fileparts(figName, 'extension');

            % Construct a file suffix
            suffixThis = sprintf('_%s%s', intervalStrThis, fileExt);

            % Create a new figure name
            figNameThis = regexprep(figName, [fileExt, '$'], [suffixThis, '$']);

            % Save the new figure
            save_all_figtypes(fig, figNameThis, figTypes);
        end
    else
        % Save the new figure
        save_all_figtypes(fig, figName, figTypes);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [nRows, nColumns] = ...
                decide_on_subplot_placement (subplotOrder, nPlots, ...
                                            colorMap, maxRowsWithOneOnly)
%% Decide on the subplot order
% TODO: Pull out

% Set default subplot order if not provided
if strcmpi(subplotOrder, 'auto') || ...
        strcmpi(subplotOrder, 'bycolor') && isempty(colorMap)
    if nPlots <= maxRowsWithOneOnly
        subplotOrder = 'list';
    else
        subplotOrder = 'square';
    end
end

% Compute number of rows
switch subplotOrder
    case 'bycolor'
        if iscell(colorMap)
            nRows = numel(colorMap);
        else
            nRows = size(colorMap, 1);
        end
    case 'square'
        nRows = ceil(sqrt(nPlots));
    case 'list'
        nRows = nPlots;
    otherwise
        error('subplotOrder unrecognized!');
end

% Compute number of columns
nColumns = ceil(nPlots / nRows);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function colorThis = decide_on_this_color (colorMode, colorMap, ...
                                            iPlot, nColumns)
%% Decides on the color for a plot

switch colorMode
    case {'byPlot', 'byRow', 'byColumn'}
        % Decide on iColor
        switch colorMode
            case 'byPlot'
                % Use the plot number
                iColor = iPlot;
            case 'byRow'
                % Use the current row number
                iColor = ceil(iPlot / nColumns);
            case 'byColumn'
                % Use the current column number
                iColor = mod((iPlot - 1)/nColumns) + 1;
        end

        % Get the color map
        if iscell(colorMap)
            colorThis = colorMap{iColor};
        else
            colorThis = colorMap(iColor, :);
        end
    case 'byTraceInPlot'
        if iscell(colorMap)
            colorThis = colorMap{iPlot};
        else
            colorThis = colorMap;
        end
    otherwise
        error('colorMode unrecognized!');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{ 
OLD CODE:

function fig = plot_traces(tVec, data, xLimits, xLabel, yLabel, ...
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
close(fig);

saveas(fig, figName, 'png');

fig = figure(figNum);
set(fig, 'Visible', 'Off');

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

subplot(nPlots, 1, iPlot);

if ~iscell(yLabel)
    yLabel = {yLabel};
end
if iscell(yLabel)
    if numel(yLabel) > nPlots
        fprintf('Too many y labels! Only some will be used!\n');
    elseif numel(yLabel) < nPlots
        fprintf('Not enough y labels!!\n');
        return;
    end
end

nPlots = size(data, 2);

xLimits = cellfun(@(x), [min(x), max(x)], tVecs, 'UniformOutput', false);

minY = min(min(data));
maxY = max(max(data));

yLabel = cell(1, nPlots);
parfor iPlot = 1:nPlots
    yLabel{iPlot} = ['Trace #', num2str(iPlot)];
end

traceLabels = cell(1, nPlots);
parfor iPlot = 1:nPlots
    traceLabels{iPlot} = ['Trace #', num2str(iPlot)];
end

% Hold on if more than one trace
if nPlots > 1
    hold on
end
% Hold off if more than one trace
if nPlots > 1
    hold off
end

% Force as column cell arrays
yLabel = force_column_cell(yLabel);

% Match up to nPlots elements
yLabel = match_dimensions(yLabel, [nPlots, 1]);

% Force data vectors as column cell arrays of column vectors
[tVecs, data, dataToCompare] = ...
    argfun(@force_column_cell, tVecs, data, dataToCompare);

% Match the number of vectors between data and dataToCompare
[data, dataToCompare] = match_array_counts(data, dataToCompare);

% Match the dimensions of tVecs to data
tVecs = match_dimensions(tVecs, size(data));

%       cd/argfun.m
%       cd/force_column_cell.m
%       cd/match_dimensions.m
%       cd/match_array_counts.m

% Hold off
hold off

% Hold off
hold off

if ~strcmpi(xLimitsThis, 'suppress')
end

% Create a new figure number
if ~isempty(figNumber)
    figNumberThis = figNumber + rand(1) * 1000;
else
    figNumberThis = [];
end

yLabel = arrayfun(@(x) ['Trace #', num2str(x)], ...
                    transpose(1:nPlots), 'UniformOutput', false);
traceLabels = arrayfun(@(x) ['Trace #', num2str(x)], ...
                        transpose(1:nPlots), 'UniformOutput', false);

% Compute minimum and maximum time values
minT = min(cellfun(@min, tVecs));
maxT = max(cellfun(@max, tVecs));

% Compute x limits
xLimits = [minT, maxT];

yLimits = [minY - 0.2 * rangeY, maxY + 0.2 * rangeY];

if ~isempty(figName)
    % Create an invisible figure and clear it
    if ~isempty(figNumber)
        fig = figure(figNumber);
        set(fig, 'Visible', 'off');
    else
        fig = figure('Visible', 'off');
    end
    clf(fig);
else
    % Get the current figure
    fig = gcf;
end

set(fig, 'Visible', 'off');

axes(subPlots(iPlot));

    @(x) validateattributes(x, {'numeric'}, {'scalar', 'positive', 'integer'}));

minY = min([cellfun(@min, data), cellfun(@min, dataToCompare)]);
maxY = max([cellfun(@max, data), cellfun(@max, dataToCompare)]);

if isempty(yLimits) && ~strcmpi(plotMode, 'parallel') && rangeY ~= 0
rangeY = maxY - minY;

if isempty(yLimits) && ~strcmpi(plotMode, 'parallel')

%       cd/compute_xlimits.m
%       cd/compute_ylimits.m

if iscell(tVecs)
    tVec = tVecs{1};
else
    tVec = tVecs;
end

xLimits = compute_xlimits(tVec, 'Coverage', 100);

% Put all data together
allData = [data; dataToCompare];

% Compute minimum and maximum Y values
minY = apply_iteratively(@min, allData);
maxY = apply_iteratively(@max, allData);

% Compute the y limits
yLimits = compute_ylimits(minY, maxY, 'Coverage', 80);

% Put all data together
allData = [data{iPlot}; dataToCompare{iPlot}];

% Compute minimum and maximum Y values
minY = apply_iteratively(@min, allData);
maxY = apply_iteratively(@max, allData);

% Compute the y limits for this subplot
yLimitsThis = compute_axis_limits(minY, maxY, 'Coverage', 80);

% If all time vectors are the same, compress
if numel(unique(tVecs)) == 1
    tVec = tVecs{1};
end

% Construct a file suffix
suffixThis = sprintf('_%s.png', intervalStrThis);

% Create a new figure name
figNameThis = replace(figName, '.png', suffixThis);

%                   - 'ColorMap': a color map that also groups traces
%                                   each set of traces will be on the same row
%                                   if plot mode is 'parallel'

if nPlots <= maxRowsWithOneOnly
    colorMap = create_colormap(nPlots);
else
    colorMap = create_colormap(floor(sqrt(nPlots)));
end

% Plot the data using the color map
p = plot(tVecs{iPlot}, data{iPlot}, ...
            'Color', colorThis, otherArguments);

title(figTitle, 'Interpreter', 'none');
title(figTitleThis, 'Interpreter', 'none');
title(figTitle, 'Interpreter', 'none');

set(ax.XAxis, 'Visible', 'off');
set(ax.YAxis, 'Visible', 'off');

%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
