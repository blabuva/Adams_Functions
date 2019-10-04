function handles = plot_relative_events (varargin)
%% Plots events (such as SWDs) relative to stim (such as gas pulses) (unfinished)
% Usage: handles = plot_relative_events (varargin)
% Explanation:
%       TODO
%
% Example(s):
%       plot_relative_events('Directory', '/media/shareX/2019octoberR01/Figures/Figure1c')
%       plot_relative_events('RelativeTimeWindow', [-20, 20]);
%       plot_relative_events('PlotType', 'psth', 'Edges', -20:2:20);
%       plot_relative_events('RelativeTimeWindow', [-20, 20], 'PlotType', 'chevron');
%       plot_relative_events('RelativeTimeWindow', [-15, 15]);
%       plot_relative_events('PlotType', 'psth', 'Edges', -15:3:15, 'StimIndices', 'odd');
%       plot_relative_events('PlotType', 'psth', 'Edges', -15:3:15, 'StimIndices', 'even');
%       plot_relative_events('RelativeTimeWindow', [-15, 15], 'PlotType', 'chevron');
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
%                   - 'StimIndices': stimulation indices to restrict to
%                   must be a positive integer array or string recognized by
%                        the 'Pattern' option of extract_subvectors.m
%                           'odd'   - odd indices
%                           'even'  - even indices
%                   default == no restrictions
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
%                           or plot_chevron() or plot_psth() 
%
% Requires:
%       cd/argfun.m
%       cd/apply_iteratively.m
%       cd/compute_relative_event_times.m
%       cd/create_label_from_sequence.m
%       cd/create_subplots.m
%       cd/extract_subvectors.m
%       cd/extract_fileparts.m
%       cd/load_matching_sheets.m
%       cd/plot_chevron.m
%       cd/plot_psth.m
%       cd/plot_raster.m
%
% Used by:
%       /home/Matlab/plethR01/plethR01_analyze.m

% File History:
% 2019-09-10 Created by Adam Lu
% 2019-09-11 Added 'PlotType' as an optional argument
% 2019-09-15 Added 'StimTableSuffix' and 'EventTableSuffix' 
%               as optional arguments
% 2019-09-25 Finished the raster plot code
% 2019-09-30 Now uses load_matching_sheets.m
% 2019-10-04 Added 'StimIndices' as an optional arguments
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
stimIndicesDefault = [];        % take all stims by default
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
addParameter(iP, 'StimIndices', stimIndicesDefault, ...
    @(x) validateattributes(x, {'numeric', 'char'}, {'2d'}));
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
stimIndices = iP.Results.StimIndices;
eventTableSuffix = iP.Results.EventTableSuffix;
stimTableSuffix = iP.Results.StimTableSuffix;
directory = iP.Results.Directory;
relTimeWindowMin = iP.Results.RelativeTimeWindowMin;
stimDurationMin = iP.Results.StimDurationMin;
figTitle = iP.Results.FigTitle;
figName = iP.Results.FigName;
[~, figTypes] = isfigtype(iP.Results.FigTypes, 'ValidateMode', true);

% Keep unmatched arguments for the plot_raster() 
%                           or plot_chevron() or plot_psth() function
otherArguments = iP.Unmatched;

%% Preparation
% Set default directory
if isempty(directory)
    directory = pwd;
end

% Set default figure suffix
if isempty(figSuffix)
    if isempty(stimIndices)
        figSuffixAddition = 'all_stims';
    elseif isnumeric(stimIndices)
        figSuffixAddition = ['stim', create_label_from_sequence(stimIndices)];
    elseif ischar(stimIndices)
        figSuffixAddition = ['all_', stimIndices, '_stims'];
    else
        error('stimNumber unrecognized!');
    end

    figSuffix = [plotType, '_', figSuffixAddition];
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
    if isempty(stimIndices)
        figTitle = 'SWD count around all stims';
    elseif isnumeric(stimIndices)
        figTitle = ['SWD count around stims ', ...
                    create_label_from_sequence(stimIndices)];
    elseif ischar(stimIndices)
        figTitle = ['SWD count around ', stimIndices, ' stims'];
    end
end

%% Get relative event times
% Load matching stimulus and event tables
[stimTables, swdTables, distinctParts] = ...
    load_matching_sheets(stimTableSuffix, eventTableSuffix);

% Set default labels for each raster
if isempty(labels)
    labels = distinctParts;
end

% Extract all start times in seconds
[stimStartTimesSec, swdStartTimesSec] = ...
    argfun(@(x) cellfun(@(y) y.startTime, x, 'UniformOutput', false), ...
            stimTables, swdTables);

% Extract stim durations in seconds
stimDurationsSec = cellfun(@(y) y.duration, stimTables, 'UniformOutput', false);

% Restrict to certain events if requested
if isempty(stimIndices)
    % Do nothing
elseif isnumeric(stimIndices)
    [stimStartTimesSec, stimDurationsSec] = ...
        argfun(@(x) extract_subvectors(x, 'Indices', stimIndices), ...
                stimStartTimesSec, stimDurationsSec);
elseif ischar(stimIndices)
    [stimStartTimesSec, stimDurationsSec] = ...
        argfun(@(x) extract_subvectors(x, 'Pattern', stimIndices), ...
                stimStartTimesSec, stimDurationsSec);
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
    if (maxStimDurationMin - minStimDurationMin) / minStimDurationMin > 0.05
        fprintf(['Maximum stimulus duration %g and ' , ...
                    'minimum stimulus duration %g ', ...
                    'are more than 5%% apart, ', ...
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
        %   Note: this should return a cell array (files) of cell arrays (stims)
        [relEventTimesCellCell, relTimeWindowMin] = ...
            compute_relative_event_times(swdStartTimesMin, stimStartTimesMin, ...
                                    'RelativeTimeWindow', relTimeWindowMin);

        % Put the event time arrays in a cell matrix
        %   Note: Each column is a file
        %         Each row is a stim
        relEventTimes = force_matrix(relEventTimesCellCell, ...
                                    'TreatCellNumAsArray', true);

    case 'psth'
        % Relative event times computed in plot_psth.m
    otherwise
        error('plotType unrecognized!');
end

%% Plot event times
switch plotType
case 'raster'
    %% Plot rasters by stim #
    % Count the appropriate number of subplots
    nSubplots = size(relEventTimes, 1);

    % Create subplots
    [fig, ax] = create_subplots(1, nSubplots);

    % Plot the rasters
    for iAx = 1:numel(ax)
        % Use this subplot
        subplot(ax(iAx));

        % Create a figure title
        figTitle = ['Events around stim #', num2str(iAx)];

        % Plot raster
        handles = plot_raster(relEventTimes(iAx, :), 'Labels', labels, ...
                                'XLabel', 'Time (min)', ...
                                'XLimits', relTimeWindowMin, ...
                                'FigTitle', figTitle, ...
                                otherArguments);

        % Plot stim start line
        plot_vertical_line(0, 'LineWidth', 2, 'Color', 'k');
    end

    % Save figure
    save_all_figtypes(gcf, figName, figTypes);
case 'psth'
    %% Plot the peri-stimulus time histogram
    handles = plot_psth('EventTimes', swdStartTimesMin, ...
                        'StimTimes', stimStartTimesMin, ...
                        'GroupingLabels', labels, ...
                        'XLabel', 'Time (min)', ...
                        'RelativeTimeWindow', relTimeWindowMin, ...
                        'StimDuration', stimDurationMin, ...
                        'FigTitle', figTitle, ...
                        'FigName', figName, 'FigTypes', figTypes, ...
                        otherArguments);
case 'chevron'
    %% Plot two Chevron plots
    % Decide on p tick labels
    pTickLabels = {'Before', 'After'};

    % Modify the figure title for the normalized plot
    figTitleNormalize = ['% ', figTitle];

    % Decide on file names
    figPathBase = extract_fileparts(figName, 'pathbase');
    figNameNormalized = strcat(figPathBase, '_normalized');
    sheetPath = [figPathBase, '.csv'];
    sheetPathNormalized = [figPathBase, '_normalized', '.csv'];

    % Transpose so that each column is a stim
    relEventTimesTrans = transpose(relEventTimes);
    
    % Compute the number of events before and after, 
    %       summing across stims for each file
    %   Note: relEventTimes must be a cell array of numeric vectors
    nEventsBeforeEachStim = cellfun(@(x) numel(x(x < 0)), relEventTimesTrans);
    nEventsAfterEachStim = cellfun(@(x) numel(x(x >= 0)), relEventTimesTrans);
    [nEventsBefore, nEventsAfter] = ...
        argfun(@(x) sum(x, 2), nEventsBeforeEachStim, nEventsAfterEachStim);

    % Compute normalized data
    nEventsBeforeNormalized = 100 * nEventsBefore ./ nEventsBefore;
    nEventsAfterNormalized = 100 * nEventsAfter ./ nEventsBefore;

    % Save the data in tables
    chevronTable = table(nEventsBefore, nEventsAfter, ...
                        'RowNames', labels);
    writetable(chevronTable, sheetPath);

    % Save normalized data in a table
    normChevronTable = table(nEventsBeforeNormalized, ...
                            nEventsAfterNormalized, 'RowNames', labels);
    writetable(normChevronTable, sheetPathNormalized);

    % Plot Chevron plot and save figure
    fig1 = set_figure_properties('AlwaysNew', true);
    plot_chevron(chevronTable, 'FigTitle', figTitle, ...
                'ReadoutLabel', 'SWD count', 'PTickLabels', pTickLabels, ...
                otherArguments);
    save_all_figtypes(fig1, figName, figTypes);

    % Plot normalized Chevron plot and save figure
    fig2 = set_figure_properties('AlwaysNew', true);
    plot_chevron(normChevronTable, 'FigTitle', figTitleNormalize, ...
                'ReadoutLabel', '% SWD count', 'PTickLabels', pTickLabels, ...
                'ReadoutLimits', [0, Inf], ...
                otherArguments);
    save_all_figtypes(fig2, figNameNormalized, figTypes);
otherwise
    error('plotType unrecognized!');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
OLD CODE:

relEventTimes = extract_in_order(relEventTimesCellCell);

% Extract the relevant event times
if stimIndices
    % Restrict to just the first event times
    %   Note: this should return a cell array of numeric vectors
    relEventTimes = cellfun(@(x) extract_element_by_index(x, 1, ...
                                                            false), ...
                        relEventTimesCellCell, 'UniformOutput', false);
else
    relEventTimes = extract_in_order(relEventTimesCellCell);
end

if stimIndices
    % Create a figure title
    figTitle = ['Events around stim #', num2str(1)];

    % Plot raster
    handles = plot_raster(relEventTimes, 'Labels', labels, ...
                            'XLabel', 'Time (min)', ...
                            'FigTitle', figTitle, ...
                            'XLimits', relTimeWindowMin, otherArguments);

    % Plot stim start line
    plot_vertical_line(0, 'LineWidth', 2, 'Color', 'k');
else
end

% Count the appropriate number of subplots
nSubplots = numel(relEventTimes);

% Force as column vectors
[nEventsBefore, nEventsAfter] = ...
    argfun(@force_column_vector, nEventsBefore, nEventsAfter);

% Generate the data for the Chevron plot
chevronData = transpose([nEventsBefore, nEventsAfter]);

if isempty(labels)
    labels = replace(distinctParts, '_', '\_');
end

stimStartTimesSec = cellfun(@(x) x(stimIndices), stimStartTimesSec, ...
                            'UniformOutput', false);
stimDurationsSec = cellfun(@(x) x(stimIndices), stimDurationsSec, ...
                            'UniformOutput', false);

% Extract the relevant event times
% TODO: May not be necessary
if stimIndices
    relEventTimes = relEventTimes(1, :);
end

%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
