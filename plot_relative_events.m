function handles = plot_relative_events (varargin)
%% Plots events (such as SWDs) relative to stim (such as gas pulses) (unfinished)
% Usage: handles = plot_relative_events (varargin)
% Explanation:
%       TODO
%
% Example(s):
%       plot_relative_events('Directory', '/media/shareX/2019octoberR01/Figures/Figure1c')
%
% Outputs:
%       handles     - TODO: Description of handles
%                   specified as a TODO
%
% Arguments:
%       varargin    - 'PlotType': type of plot
%                   must be an unambiguous, case-insensitive match to one of: 
%                       'raster'    - event raster
%                       'psth'      - peri-stimulus time histogram
%                       'chevron'   - chevron plot
%                   default == 'raster'
%                   - 'FirstOnly': whether to take only the first window 
%                                   from each file
%                   must be numeric/logical 1 (true) or 0 (false)
%                   default == false
%                   - 'EventTableSuffix': Suffix for the event table
%                   must be a character vector or a string scalar 
%                   default == '_SWDs'
%                   - 'StimTableSuffix': Suffix for the stim table
%                   must be a character vector or a string scalar 
%                   default == '_pulses'
%                   - 'Directory': directory to look for event table
%                                   and stim table files
%                   must be a string scalar or a character vector
%                   default == pwd
%                   - 'RelativeTimeWindowMin': relative time window
%                   must be a 2-element numeric vector
%                   default == interStimInterval * 0.5 * [-1, 1]
%                   - 'StimDurationMin': stimulus duration for plotting
%                                       (stim always occur at 0)
%                   must be a positive scalar
%                   default == [] (not plotted)
%                   - 'FigTitle': title for the figure
%                   must be a string scalar or a character vector
%                   default == TODO
%                   - 'FigName': figure name for saving
%                   must be a string scalar or a character vector
%                   default == TODO
%                   - 'FigTypes': figure type(s) for saving; 
%                               e.g., 'png', 'fig', or {'png', 'fig'}, etc.
%                   could be anything recognised by 
%                       the built-in saveas() function
%                   (see isfigtype.m under Adams_Functions)
%                   default == {'png', 'epsc2'}
%                   - Any other parameter-value pair for plot_raster()
%
% Requires:
%       cd/all_files.m
%       cd/apply_iteratively.m
%       cd/compute_relative_event_times.m
%       cd/create_label_from_sequence.m
%       cd/extract_distinct_fileparts.m
%       cd/extract_elements.m
%       cd/extract_fileparts.m
%       cd/plot_raster.m
%
% Used by:
%       /home/Matlab/plethR01/plethR01_analyze.m

% File History:
% 2019-09-10 Created by Adam Lu
% 2019-09-11 Added 'PlotType' as an optional argument
% 2019-09-15 Added 'StimTableSuffix' and 'EventTableSuffix' 
%               as optional arguments
% TODO: Use load_matching_sheets.m
% 

%% Hard-coded parameters
SEC_PER_MIN = 60;
validPlotTypes = {'raster', 'psth', 'chevron'};

% TODO: Make optional arguments
pathBase = '';
sheetType = 'csv';
figSuffix = '';
labels = {};

%% Default values for optional arguments
plotTypeDefault = 'raster';
firstOnlyDefault = false;       % take all windows by default
eventTableSuffixDefault = '_SWDs';
stimTableSuffixDefault = '_pulses';
directoryDefault = '';          % set later
relativeTimeWindowMinDefault = [];
stimDurationMinDefault = [];
figTitleDefault = '';           % set later
figNameDefault = '';            % set later
figTypesDefault = {'png', 'epsc2'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Deal with arguments
% Set up Input Parser Scheme
iP = inputParser;
iP.FunctionName = mfilename;
iP.KeepUnmatched = true;                        % allow extraneous options

% Add parameter-value pairs to the Input Parser
addParameter(iP, 'PlotType', plotTypeDefault, ...
    @(x) any(validatestring(x, validPlotTypes)));
addParameter(iP, 'FirstOnly', firstOnlyDefault, ...
    @(x) validateattributes(x, {'logical', 'numeric'}, {'binary'}));
addParameter(iP, 'EventTableSuffix', eventTableSuffixDefault, ...
    @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
addParameter(iP, 'StimTableSuffix', stimTableSuffixDefault, ...
    @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
addParameter(iP, 'Directory', directoryDefault, ...
    @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
addParameter(iP, 'RelativeTimeWindowMin', relativeTimeWindowMinDefault, ...
    @(x) validateattributes(x, {'numeric'}, {'2d'}));
addParameter(iP, 'StimDurationMin', stimDurationMinDefault, ...
    @(x) validateattributes(x, {'numeric'}, {'2d'}));
addParameter(iP, 'FigTitle', figTitleDefault, ...
    @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
addParameter(iP, 'FigName', figNameDefault, ...
    @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
addParameter(iP, 'FigTypes', figTypesDefault, ...
    @(x) all(isfigtype(x, 'ValidateMode', true)));

% Read from the Input Parser
parse(iP, varargin{:});
plotType = validatestring(iP.Results.PlotType, validPlotTypes);
firstOnly = iP.Results.FirstOnly;
eventTableSuffix = iP.Results.EventTableSuffix;
stimTableSuffix = iP.Results.StimTableSuffix;
directory = iP.Results.Directory;
relTimeWindowMin = iP.Results.RelativeTimeWindowMin;
stimDurationMin = iP.Results.StimDurationMin;
figTitle = iP.Results.FigTitle;
figName = iP.Results.FigName;
[~, figTypes] = isfigtype(iP.Results.FigTypes, 'ValidateMode', true);

% Keep unmatched arguments for the plot_raster() function
otherArguments = iP.Unmatched;

%% Preparation
% Set default figure suffix
if isempty(figSuffix)
    if firstOnly
        figSuffix = 'first_windows';
    else
        figSuffix = 'all_windows';
    end
end

% Set default figure name
if isempty(figName)
    % Extract the directory base
    dirBase = extract_fileparts(directory, 'dirbase');

    if ~isempty(relTimeWindowMin)
        % Create a sequence for create_label_from_sequence
        relTimeWindowSeq = linspace(relTimeWindowMin(1), ...
                                    relTimeWindowMin(2), 2);

        % Create a figure name
        figName = fullfile(directory, [dirBase, '_', ...
                            create_label_from_sequence(relTimeWindowSeq), ...
                            '_', figSuffix]);
    else
        % Create a figure name
        figName = fullfile(directory, [dirBase, '_', figSuffix]);
    end
end

% Set default figure title
if isempty(figTitle)
    if firstOnly
        figTitle = '# of SWDs around first stimulus starts';
    else
        figTitle = '# of SWDs around all stimulus starts';
    end
end

%% Get relative event times
% TODO: Use load_matching_sheets;
% Get all stim pulse files
[~, stimPaths] = ...
    all_files('Directory', directory, 'Keyword', pathBase, ...
                'Suffix', stimTableSuffix, 'Extension', sheetType, ...
                'ForceCellOutput', true);

% Extract distinct prefixes
distinctPrefixes = extract_distinct_fileparts(stimPaths);

% Look for corresponding SWD spreadsheet files
[~, swdPaths] = ...
    cellfun(@(x) all_files('Prefix', x, 'Directory', directory, ...
                    'Suffix', eventTableSuffix, 'Extension', sheetType), ...
            distinctPrefixes, 'UniformOutput', false);

% Read all tables
[stimTables, swdTables] = ...
    argfun(@(x) cellfun(@readtable, x, 'UniformOutput', false), ...
            stimPaths, swdPaths);

% Set default labels for each raster
if isempty(labels)
    labels = strrep(distinctPrefixes, '_', '\_');
end

% Extract all start times in seconds
[stimStartTimesSec, swdStartTimesSec] = ...
    argfun(@(x) cellfun(@(y) y.startTime, x, 'UniformOutput', false), ...
            stimTables, swdTables);

% Extract stim durations in seconds
stimDurationsSec = cellfun(@(y) y.duration, stimTables, ...
                            'UniformOutput', false);

% Restrict to the first events only if requested
if firstOnly
    % Note: TODO: Use extract_elements.m with 'UniformOutput', false
    stimStartTimesSec = cellfun(@(x) x(1), stimStartTimesSec, ...
                                'UniformOutput', false);
    stimDurationsSec = cellfun(@(x) x(1), stimDurationsSec, ...
                                'UniformOutput', false);
end

% Convert to minutes
[stimStartTimesMin, stimDurationsMin, swdStartTimesMin] = ...
    argfun(@(x) cellfun(@(y) y / SEC_PER_MIN, x, 'UniformOutput', false), ...
            stimStartTimesSec, stimDurationsSec, swdStartTimesSec);

% Compute default stimulation duration in minutes
if isempty(stimDurationMin)
    % Find the minimum and maximum stimulation duration in minutes
    minStimDurationMin = apply_iteratively(@min, stimDurationsMin);
    maxStimDurationMin = apply_iteratively(@max, stimDurationsMin);

    % If they don't agree within 1%, plot stimulus duration as 0
    if (maxStimDurationMin - minStimDurationMin) / minStimDurationMin > 0.01
        fprintf(['Maximum stimulus duration %g and ' , ...
                    'minimum stimulus duration %g ', ...
                    'are more than 1%% apart, ', ...
                    'so stimulus duration will be plotted as 0!\n'], ...
                    maxStimDurationMin, minStimDurationMin);
        stimDurationMin = 0;
    else
        stimDurationMin = mean([maxStimDurationMin, minStimDurationMin]);
    end
end

%% Compute relative event times for each set
switch plotType
    case {'raster', 'chevron'}
        % Compute the relative event times
        %   Note: this should return a cell array of cell arrays
        [relEventTimesCellCell, relTimeWindowMin] = ...
            compute_relative_event_times(swdStartTimesMin, stimStartTimesMin, ...
                                    'RelativeTimeWindow', relTimeWindowMin);

        % Restrict to just the first event times
        if firstOnly
            %   Note: this should return a cell array of numeric vectors
            relEventTimes = cellfun(@extract_first_element, ...
                                relEventTimesCellCell, 'UniformOutput', false);
        else
            error('Not implemented yet!');
        end
    case 'psth'
        % Relative event times computed in plot_psth.m
    otherwise
        error('plotType unrecognized!');
end

%% Plot event times
switch plotType
case 'raster'
    %% Plot the raster
    if firstOnly
        handles = plot_raster(relEventTimes, 'Labels', labels, ...
                                'XLabel', 'Time (min)', ...
                                'XLimits', relTimeWindowMin, otherArguments);
        plot_vertical_line(0, 'LineWidth', 2, 'Color', 'k');
        save_all_figtypes(gcf, figName, figTypes);
    else
        error('Not implemented yet!');
    end
case 'psth'
    %% Plot the peri-stimulus time histogram
    handles = plot_psth('EventTimes', swdStartTimesMin, ...
                        'StimTimes', stimStartTimesMin, ...
                        'XLabel', 'Time (min)', ...
                        'RelativeTimeWindow', relTimeWindowMin, ...
                        'StimDuration', stimDurationMin, ...
                        'FigTitle', figTitle, ...
                        'FigName', figName, 'FigTypes', figTypes, ...
                        otherArguments);
case 'chevron'
    %% Plot a Chevron plot
    % TODO: Move this to its own function
    if firstOnly
        % Compute the number of events before and after
        %   TODO: Always cell arrays?
        nEventsBefore = cellfun(@(x) numel(x(x < 0)), relEventTimes);
        nEventsAfter = cellfun(@(x) numel(x(x >= 0)), relEventTimes);

        % Force as column vectors
        %   TODO: may not be necessary
        [nEventsBefore, nEventsAfter] = ...
            argfun(@force_column_vector, nEventsBefore, nEventsAfter);

        % Generate the data for the Chevron plot
        chevronData = transpose([nEventsBefore, nEventsAfter]);

        % TODO: plot_chevron.m
        [lowBefore, lowAfter] = ...
            argfun(@(x) compute_stats(x, 'lower95'), nEventsBefore, nEventsAfter);
        [highBefore, highAfter] = ...
            argfun(@(x) compute_stats(x, 'upper95'), nEventsBefore, nEventsAfter);

        [meanBefore, meanAfter] = ...
            argfun(@(x) compute_stats(x, 'mean'), nEventsBefore, nEventsAfter);
        pValue = [1, 2];

        % Plot a tuning curve
        plot_tuning_curve(pValue, chevronData, 'PLimits', [0.75, 2.25], ...
                            'PTicks', pValue, 'PTickLabels', {'Before', 'After'}, ...
                            'PLabel', 'suppress', 'ReadoutLabel', '# of events', ...
                            'FigTitle', figTitle, ...
                            'RunTTest', true, 'RunRankTest', true, ...
                            'Marker', 'o', 'MarkerFaceColor', [0, 0, 0], ...
                            'MarkerSize', 4, 'ColorMap', [0, 0, 0], ...
                            'LegendLocation', 'suppress', otherArguments);
        hold on 
        plot(pValue, [meanBefore, meanAfter], 'ro', ...
            'LineWidth', 2, 'MarkerSize', 6, 'MarkerFaceColor', 'r');
        plot_error_bar(pValue, [lowBefore, lowAfter], [highBefore, highAfter], ...
            'Color', 'r', 'LineWidth', 2);
        yLimits = get(gca, 'YLim');
        plot(mean(pValue), yLimits(1) + 0.8 * (yLimits(2) - yLimits(1)), 'k*');
        save_all_figtypes(gcf, figName, figTypes);
    else
        error('Not implemented yet!');
    end
otherwise
    error('plotType unrecognized!');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function first = extract_first_element (vec)
%% Take the first element or return empty
% TODO: Merge with extract_elements

if numel(vec) >= 1
    if iscell(vec)
        first = vec{1};
    else
        first = vec(1);
    end
else
    first = [];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
OLD CODE:

%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
