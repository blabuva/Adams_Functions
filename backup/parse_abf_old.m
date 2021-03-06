function [parsedParams, data, tVec, vVecs, iVecs, gVecs, dataReordered] = ...
                parse_abf(fileName, varargin)
%% Loads and parses an abf file
% Usage: [parsedParams, data, tVec, vVecs, iVecs, gVecs, dataReordered] = ...
%               parse_abf(fileName, varargin)
% Explanation:
%   This function does the following:
%       1. Construct the full path to the abf file
%       2. Load the abf file using either abf2load or abfload, 
%           whichever's available
%       3. Identify the appropriate time units and construct a time vector
%       4. Identify whether each channel is voltage, current or conductance
%           and extract them into vVecs, iVecs and gVecs
% Examples:
%       [parsedParams, data, tVec, vVecs, iVecs, gVecs] = ...
%           parse_abf('20180914C_0001');
% Outputs:
%       parsedParams   - a structure containing the following fields:
%                       siUs
%                       siMs
%                       siSeconds
%                       siPlot
%                       timeUnits
%                       channelTypes
%                       channelUnits
%                       channelLabels
%                       nDimensions
%                       nSamples
%                       nChannels
%                       nSweeps
%       data        - full data
%       tVec        - a constructed time vector with units given by 'TimeUnits'
%       vVecs       - any identified voltage vector(s) 
%                       (Note: 2nd dimension: sweep; 
%                               optional 3rd dimension: channel)
%       iVecs       - any identified current vector(s)
%                       (Note: 2nd dimension: sweep; 
%                               optional 3rd dimension: channel)
%       gVecs       - any identified conductance vector(s)
%                       (Note: 2nd dimension: sweep; 
%                               optional 3rd dimension: channel)
%       dataReordered - data reordered so that the 2nd dimension is sweep
%                       and 3rd dimension is channel
%
% Arguments:
%       fileName    - file name could be either the full path or 
%                       a relative path in current directory
%                       .abf is not needed (e.g. 'B20160908_0004')
%                   must be a string scalar or a character vector
%       varargin    - 'Verbose': whether to output parsed results
%                   must be numeric/logical 1 (true) or 0 (false)
%                   default == true
%                   - 'UseOriginal': whether to use original 
%                           channel labels and units over identify_channels()
%                   must be numeric/logical 1 (true) or 0 (false)
%                   default == false
%                   - 'ExpMode': experiment mode
%                   must be an unambiguous, case-insensitive match to one of: 
%                       'EEG'   - EEG data; x axis in seconds; y-axis in uV
%                       'patch' - patch data; x axis in ms; y-axis in mV
%                   default == 'EEG' for 2d data 'patch' for 3d data
%                   - 'TimeUnits': units for time
%                   must be a string scalar or a character vector
%                   default == 's' for 2-data data and 'ms' for 3-data data
%                   - 'ChannelTypes': the channel types
%                   must be a cellstr with nChannels elements
%                       each being one of the following:
%                           'Voltage'
%                           'Current'
%                           'Conductance'
%                           'Undefined'
%                   default == detected with identify_channels()
%                   - 'ChannelUnits': the channel units
%                   must be a cellstr with nChannels elements
%                   default == detected with identify_channels()
%                   - 'ChannelLabels': the channel labels
%                   must be a cellstr with nChannels elements
%                   default == detected with identify_channels()
%                   - 'IdentifyProtocols': whether to identify protocols
%                   must be numeric/logical 1 (true) or 0 (false)
%                   default == false

%
% Requires:
%       cd/construct_abffilename.m
%       cd/identify_eLFP.m
%       /home/Matlab/Downloaded_Functions/abf2load.m or abfload.m
%       /home/Matlab/Brians_Functions/identify_channels.m
%       /home/Matlab/Brians_Functions/identify_CI.m
%
% Used by:
%       cd/parse_all_abfs.m
%       cd/plot_traces_abf.m
%       cd/compute_and_plot_evoked_LFP.m
%       cd/identify_eLFP.m
%       /home/Matlab/Brians_Functions/identify_CI.m

% File history: 
% 2018-09-17 - Moved from plot_traces_abf.m
% 2018-09-17 - Added 'Verbose' as a parameter
% 2018-09-17 - Added tVec, vVecs, iVecs, gVecs as outputs
% 2018-09-18 - Added expMode and now sets timeUnits according to expMode
% 2018-09-20 - Made 'useOriginal' an optional argument and 
%                   implement it (uses information in fileInfo)
% 2018-09-22 - Made 'ChannelTypes', 'ChannelUnits' and 'ChannelLabels' 
%                   optional arguments and gave it priority over original labels
% 2018-10-03 - Renamed abfParams -> parsedParams
%               and placed all other outputs in a structure called parsedData

%% Hard-coded constants
US_PER_MS = 1e3;            % number of microseconds per millisecond
US_PER_S = 1e6;             % number of microseconds per second

%% Hard-coded parameters
validExpModes = {'EEG', 'patch', ''};
validChannelTypes = {'Voltage', 'Current', 'Conductance', 'Undefined'};

%% Default values for optional arguments
verboseDefault = true;              % print to standard output by default
useOriginalDefault = false;         % use identify_channels.m instead
                                    % of the original channel labels by default
expModeDefault = '';                % set later
timeUnitsDefault = '';              % set later
channelTypesDefault = {};           % set later
channelUnitsDefault = {};           % set later
channelLabelsDefault = {};          % set later
identifyProtocolsDefault = false;   % don't identify protocols by default

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Add directories to search path for required functions
if ~isdeployed
    if exist('/home/Matlab/', 'dir') == 7
        functionsdirectory = '/home/Matlab/';
    elseif exist('/scratch/al4ng/Matlab/', 'dir') == 7
        functionsdirectory = '/scratch/al4ng/Matlab/';
    else
        error('Valid functionsdirectory does not exist!');
    end
    addpath_custom(fullfile(functionsdirectory, '/Downloaded_Functions/'));
                                            % for abf2load.m or abfload.m
    addpath_custom(fullfile(functionsdirectory, '/Brians_Functions/'));
                                            % for identify_channels.m
                                            %   and identify_CI.m
end

%% Deal with arguments
% Check number of required arguments
if nargin < 1
    error(['Not enough input arguments, ', ...
            'type ''help %s'' for usage'], mfilename);
end

% Set up Input Parser Scheme
iP = inputParser;
iP.FunctionName = mfilename;

% Add required inputs to the Input Parser
addRequired(iP, 'fileName', ...
    @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
                                                % introduced after R2016b

% Add parameter-value pairs to the Input Parser
addParameter(iP, 'Verbose', verboseDefault, ...
    @(x) validateattributes(x, {'logical', 'numeric'}, {'binary'}));
addParameter(iP, 'UseOriginal', useOriginalDefault, ...
    @(x) validateattributes(x, {'logical', 'numeric'}, {'binary'}));
addParameter(iP, 'ExpMode', expModeDefault, ...
    @(x) isempty(x) || any(validatestring(x, validExpModes)));
addParameter(iP, 'TimeUnits', timeUnitsDefault, ...
    @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
addParameter(iP, 'ChannelTypes', channelTypesDefault, ...
    @(x) isempty(x) || iscellstr(x) || isstring(x));
addParameter(iP, 'ChannelUnits', channelUnitsDefault, ...
    @(x) isempty(x) || iscellstr(x) || isstring(x));
addParameter(iP, 'ChannelLabels', channelLabelsDefault, ...
    @(x) isempty(x) || iscellstr(x) || isstring(x));
addParameter(iP, 'IdentifyProtocols', identifyProtocolsDefault, ...
    @(x) validateattributes(x, {'logical', 'numeric'}, {'binary'}));

% Read from the Input Parser
parse(iP, fileName, varargin{:});
verbose = iP.Results.Verbose;
useOriginal = iP.Results.UseOriginal;
expMode = validatestring(iP.Results.ExpMode, validExpModes);
timeUnits = iP.Results.TimeUnits;
channelTypes = iP.Results.ChannelTypes;
channelUnits = iP.Results.ChannelUnits;
channelLabels = iP.Results.ChannelLabels;
identifyProtocols = iP.Results.IdentifyProtocols;

% Validate channel types
if ~isempty(channelTypes)
    channelTypes = cellfun(@(x) validatestring(x, validChannelTypes), ...
                            channelTypes, 'UniformOutput', false);
end

%% Do the job
% Create the full path to .abf file robustly
abfFullFileName = construct_abffilename(fileName);

% Check if the file exists
if exist(abfFullFileName, 'file') ~= 2
    fprintf('The file %s does not exist!!\n', abfFullFileName);
    return;
end

% Load abf file, si is in us
if exist('abf2load', 'file') == 2
    try
        [data, siUs, fileInfo] = abf2load(abfFullFileName);
    catch ME
        try
            [data, siUs, fileInfo] = abfload(abfFullFileName);
        catch ME
            fprintf('The file %s cannot be read!\n', abfFullFileName);
            rethrow(ME)    
        end
    end
elseif exist('abfload', 'file') == 2
    [data, siUs, fileInfo] = abfload(abfFullFileName);
end

% Find data dimensions and make sure it is <= 3
nDimensions = ndims(data);        % number of dimensions in data
if nDimensions > 3
    error('Cannot parse data with more than 3 dimensions!\n');
end

% Set experiment mode (if not provided) based on data dimensions
if isempty(expMode)
    switch nDimensions
    case 2
        expMode = 'EEG';
    case 3
        expMode = 'patch';
    otherwise
        error('nDimensions unrecognize!');
    end
end

% Set time units (if not provided) based on experiment mode
if isempty(timeUnits)
    switch expMode
    case 'EEG'
        timeUnits = 's';
    case 'patch'
        timeUnits = 'ms';
    otherwise
        error('expMode unrecognize!');
    end
end

% Query data dimensions
nSamples = size(data, 1);          % number of samples
nChannels = size(data, 2);         % number of channels
if nDimensions == 3
    nSweeps = size(data, 3);       % number of sweeps
else
    nSweeps = 1;
end

%% Identify proper channel types, units and labels
% First, automatically identify channels
if useOriginal
    % Use the original channel units and labels that came with
    %   the .abf file
    channelNamesAuto = (fileInfo.recChNames)';
    channelUnitsAuto = (fileInfo.recChUnits)';

    % Construct channel labels
    channelLabelsAuto = cellfun(@(x, y) [x , ' (', y, ')'], ...
                            channelNamesAuto, channelUnitsAuto, ...
                            'UniformOutput', false);

    % Determine the appropriate channel types from the channel units
    channelTypesAuto = units2types(channelUnitsAuto);
else
    % Identify channels using the data value ranges 
    %   and absolute values means, etc.
    [channelTypesAuto, channelUnitsAuto, channelLabelsAuto] = ...
        identify_channels(data, 'ExpMode', expMode);
end

% Next, decide on the channel types, units and labels,
%   giving the user input the priority
if ~isempty(channelTypes) && ~isempty(channelUnits) && ~isempty(channelLabels)
    % Nothing to decide on; use user-defined types, units and labels
elseif isempty(channelTypes) && ~isempty(channelUnits) && ~isempty(channelLabels)
    % Determine the appropriate channel types from the channel units
    channelTypes = units2types(channelUnits);
elseif ~isempty(channelTypes) && isempty(channelUnits) && ~isempty(channelLabels)
    % Decide on channel units from channel types or channel labels, 
    %   giving priority to channel labels (override original units)
    channelUnits = choose_channelUnits(channelLabels, channelTypes, expMode, ...
                                        channelUnitsAuto, false);
elseif ~isempty(channelTypes) && ~isempty(channelUnits) && isempty(channelLabels)
    % Decide on channel labels
    channelLabels = choose_channelLabels(channelTypes, channelUnits, ...
                                        channelLabelsAuto, useOriginal);
elseif isempty(channelTypes) && isempty(channelUnits) && ~isempty(channelLabels)
    % Decide on channel units from channel labels, 
    %   giving priority to original labels
    channelUnits = choose_channelUnits(channelLabels, channelTypes, expMode, ...
                                        channelUnitsAuto, useOriginal);

    % Determine the appropriate channel types from the channel units
    channelTypes = units2types(channelUnits);
elseif isempty(channelTypes) && ~isempty(channelUnits) && isempty(channelLabels)
    % Determine the appropriate channel types from the channel units
    channelTypes = units2types(channelUnits);

    % Decide on channel labels
    channelLabels = choose_channelLabels(channelTypes, channelUnits, ...
                                        channelLabelsAuto, useOriginal);
elseif ~isempty(channelTypes) && isempty(channelUnits) && isempty(channelLabels)
    % Decide on channel units from channel types, 
    %   giving priority to original labels
    channelUnits = choose_channelUnits(channelLabels, channelTypes, expMode, ...
                                        channelUnitsAuto, useOriginal);
    
    % Decide on channel labels
    channelLabels = choose_channelLabels(channelTypes, channelUnits, ...
                                        channelLabelsAuto, useOriginal);
else
    % Non-provided; use auto-detection results
    channelTypes = channelTypesAuto;
    channelUnits = channelUnitsAuto;
    channelLabels = channelLabelsAuto;
end

% Convert to a single character vector for visualization
channelTypesStr = strjoin(channelTypes, ', ');
channelUnitsStr = strjoin(channelUnits, ', ');
channelLabelsStr = strjoin(channelLabels, ', ');

%% Time info
% Convert sampling interval to other units
siMs = siUs / US_PER_MS;
siSeconds = siUs / US_PER_S;

% Get the sampling interval for plotting
if strcmp(timeUnits, 'ms')
    % Use a sampling interval in ms
    siPlot = siMs;
elseif strcmp(timeUnits, 's')
    % Use a sampling interval in seconds
    siPlot = siSeconds;
end

% Construct a time vector for plotting
tVec = siPlot * (1:nSamples)';

%% Extract data vectors by type
indVoltage = find_in_strings('Voltage', channelTypes, ...
                                    'IgnoreCase', true);
indCurrent = find_in_strings('Current', channelTypes, ...
                                    'IgnoreCase', true);
indConductance = find_in_strings('Conductance', channelTypes, ...
                                    'IgnoreCase', true);

if nDimensions == 2
    % Extract voltage vectors if any
    vVecs = data(:, indVoltage);

    % Extract current vectors if any
    iVecs = data(:, indCurrent);

    % Extract conductance vectors if any
    gVecs = data(:, indConductance);

    % The data doesn't have to be reordered in this case
    dataReordered = data;
elseif nDimensions == 3
    % Reorder data so that the 2nd dimension is sweep 
    %   and the 3rd dimension is channel
    dataReordered = permute(data, [1, 3, 2]);

    % Extract voltage vectors if any
    vVecs = squeeze(dataReordered(:, :, indVoltage));

    % Extract current vectors if any
    iVecs = squeeze(dataReordered(:, :, indCurrent));

    % Extract conductance vectors if any
    gVecs = squeeze(dataReordered(:, :, indConductance));
end

%% Identify protocols
if identifyProtocols
    % Identify whether this is a current injection protocol
    isCI = identify_CI(iVecs, siUs);

    % Identify whether this is an evoked LFP protocol
    isEvokedLfp = identify_eLFP(iVecs);
end

%% Return and/or print results
% Store in parsedParams
parsedParams.abfFullFileName = abfFullFileName;
parsedParams.expMode = expMode;
parsedParams.nDimensions = nDimensions;
parsedParams.nSamples = nSamples;
parsedParams.nChannels = nChannels;
parsedParams.nSweeps = nSweeps;
parsedParams.siUs = siUs;
parsedParams.siMs = siMs;
parsedParams.siSeconds = siSeconds;
parsedParams.siPlot = siPlot;
parsedParams.timeUnits = timeUnits;
parsedParams.channelTypesStr = channelTypesStr;
parsedParams.channelUnitsStr = channelUnitsStr;
parsedParams.channelLabelsStr = channelLabelsStr;
if identifyProtocols
    parsedParams.isCI = isCI;
    parsedParams.isEvokedLfp = isEvokedLfp;
end
parsedParams.channelTypes = channelTypes;
parsedParams.channelUnits = channelUnits;
parsedParams.channelLabels = channelLabels;
parsedParams.fileInfo = fileInfo;

% Write results to standard output
if verbose
    fprintf('The full path is: %s\n', abfFullFileName);
    fprintf('The experiment mode is: %s\n', expMode);
    fprintf('Number of data dimensions = %d\n', nDimensions);
    fprintf('Number of samples = %d\n', nSamples);
    fprintf('Number of channels = %d\n', nChannels);
    fprintf('Number of sweeps = %d\n', nSweeps);
    fprintf('Sampling Interval for plotting = %g %s\n', siPlot, timeUnits);
    fprintf('Channel Types = %s\n', channelTypesStr);
    fprintf('Channel Units = %s\n', channelUnitsStr);
    fprintf('Channel Labels = %s\n', channelLabelsStr);
    if identifyProtocols
        fprintf('Is a current injection protocol = %s\n', num2str(isCI));
        fprintf('Is an evoked LFP protocol = %s\n', num2str(isEvokedLfp));
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function channelUnits = types2units(channelTypes, expMode)
%% Decide on channel units based on channel type and experimental mode

nChannels = numel(channelTypes);

channelUnits = cell(size(channelTypes));
parfor iChannel = 1:nChannels
    % Set default channel units
    switch channelTypes{iChannel}
    case 'Voltage'
        if strcmpi(expMode, 'patch')
            channelUnits{iChannel} = 'mV';
        elseif strcmpi(expMode, 'EEG')
            channelUnits{iChannel} = 'uV';
        end
    case 'Current'
        channelUnits{iChannel} = 'pA';
    case 'Conductance'
        channelUnits{iChannel} = 'nS';
    otherwise
        error('channelTypes unrecognized!');
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function channelTypes = units2types(channelUnits)
%% Decide on channel type based on channel units

%% Hard-coded parameters
validVoltageUnits = {'pV', 'nV', 'mV', 'V'};
validCurrentUnits = {'pA', 'nA', 'mA', 'A'};
validConductanceUnits = {'pS', 'nS', 'mS', 'S'};

nChannels = numel(channelUnits);

channelTypes = cell(size(channelUnits));
parfor iChannel = 1:nChannels
    % Get the units for this channel
    units = channelUnits{iChannel};

    % Decide on channel type based on channel units
    if any(strcmpi(units, validVoltageUnits))
        channelTypes{iChannel} = 'Voltage';
    elseif any(strcmpi(units, validCurrentUnits))
        channelTypes{iChannel} = 'Current';
    elseif any(strcmpi(units, validConductanceUnits))
        channelTypes{iChannel} = 'Conductance';
    else
        % The channel unit is not recognized
        channelTypes{iChannel} = 'Undefined';
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [channelNames, channelUnits] = extract_from_labels(channelLabels)
%% Extract channel names and units based on channel label(s)

nChannels = numel(channelLabels);

channelNames = cell(size(channelLabels));
channelUnits = cell(size(channelLabels));
parfor iChannel = 1:nChannels
    % Get the label for this channel
    label = channelLabels{iChannel};

    % Split into name and units
    tempCell1 = strsplit(label, '(');
    channelNames{iChannel} = tempCell1{1};
    if numel(tempCell1) > 1
        tempCell2 = strsplit(tempCell1{2}, ')');
        channelUnits{iChannel} = tempCell2{1};
    else
        channelUnits{iChannel} = '';
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function channelLabels = construct_channelLabels(channelTypes, channelUnits)
%% Construct channel labels

channelLabels = cellfun(@(x, y) [x , ' (', y, ')'], ...
                        channelTypes, channelUnits, ...
                        'UniformOutput', false);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function channelLabels = choose_channelLabels(channelTypes, channelUnits, ...
                                        channelLabelsAuto, useOriginal)
%% Decide on channel labels

if useOriginal
    % Use original labels
    channelLabels = channelLabelsAuto;
else
    % Construct channel labels
    channelLabels = construct_channelLabels(channelTypes, channelUnits);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function channelUnits = choose_channelUnits(channelLabels, channelTypes, ...
                                expMode, channelUnitsAuto, useOriginal)
%% Decide on channel units

if useOriginal
    % Use original units
    channelUnits = channelUnitsAuto;
else
    % If possible, decide on channel units based on 
    %   channel types and experimental mode
    if ~isempty(channelTypes)
        channelUnitsFromTypes = types2units(channelTypes, expMode);
    end

    % If possible, extract channel units from channel labels
    if ~isempty(channelLabels)
        [~, channelUnitsFromLabels] = extract_from_labels(channelLabels);
    end

    % Decide on the channel units
    if isempty(channelTypes)
        % Only the channel labels are available
        channelUnits = channelUnitsFromLabels;
    elseif isempty(channelLabels)
        % Only the channel types are available
        channelUnits = channelUnitsFromTypes;
    else
        % Give priority to using channel labels
        channelUnits = cell(size(channelLabels));
        nChannels = numel(channelUnits);
        parfor iChannel = 1:nChannels
            if ~isempty(channelUnitsFromLabels{iChannel})
                channelUnits{iChannel} = channelUnitsFromLabels{iChannel};
            else
                channelUnits{iChannel} = channelUnitsFromTypes{iChannel};
            end
        end
    end

    % If any of the units are still empty, use automatically detected results
    nChannels = numel(channelUnits);
    parfor iChannel = 1:nChannels
        if isempty(channelUnits{iChannel})
            channelUnits{iChannel} = channelUnitsAuto{iChannel};
        end 
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
OLD CODE:

% All are voltage vectors
vVecs = data;
iVecs = [];
gVecs = [];

if isempty(timeUnits)
    switch nDimensions
    case 2
        timeUnits = 's';
    case 3
        timeUnits = 'ms';
    otherwise
        error('nDimensions unrecognize!');
    end
end

channelLabels{iChannel} = [channelTypes{iChannel}, ' (', ...
                            channelUnits{iChannel}, ')'];

%       vVecs       - any identified voltage vector(s) (each column is a sweep)
%                       or a cell array of voltage vector(s)
%       iVecs       - any identified current vector(s) (each column is a sweep)
%                       or a cell array of current vector(s)
%       gVecs       - any identified conductance vector(s) (each column is a sweep)
%                       or a cell array of conductance vector(s)
% Extract voltage vectors if any
vVecs = squeeze(data(:, indVoltage, :));

% Extract current vectors if any
iVecs = squeeze(data(:, indCurrent, :));

% Extract conductance vectors if any
gVecs = squeeze(data(:, indConductance, :));

labelPattern = '[\w\s]*([\w\s]*)';

nChannels = numel(channelLabels);

channelNames = cell(size(channelLabels));
channelUnits = cell(size(channelLabels));
%parfor iChannel = 1:nChannels
for iChannel = 1:nChannels
    % Get the label for this channel
    label = channelLabels{iChannel};

    % Split into name and units
    tempCell = regexpi(label, labelPattern, 'match');
    channelNames{iChannel} = tempCell{1};
    channelUnits{iChannel} = tempCell{2};
end

function [parsedParams, data, tVec, vVecs, iVecs, gVecs, dataReordered] = ...
                parse_abf(fileName, varargin)

%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
