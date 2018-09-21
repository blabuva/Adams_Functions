function [abfParams, data, tVec, vVecs, iVecs, gVecs] = ...
                parse_abf(fileName, varargin)
%% Loads and parses an abf file
% Usage: [abfParams, data, tVec, vVecs, iVecs, gVecs] = ...
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
%       [abfParams, data, tVec, vVecs, iVecs, gVecs] = ...
%           parse_abf('20180914C_0001');
% Outputs:
%       abfParams   - a structure containing the following fields:
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
%       iVecs       - any identified current vector(s)
%       gVecs       - any identified conductance vector(s)
%
% Arguments:
%       fileName    - file name could be either the full path or 
%                       a relative path in current directory
%                       .abf is not needed (e.g. 'B20160908_0004')
%                   must be a string scalar or a character vector
%       varargin    - 'Verbose': whether to output parsed results
%                   must be numeric/logical 1 (true) or 0 (false)
%                   default == true
%                   - TODO: 'UseOriginalLabels': whether to use original 
%                           channel labels instead of identify_channels()
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
%                   default == detected with identify_channels()
%
% Requires:
%       cd/construct_abffilename.m
%       /home/Matlab/Downloaded_Functions/abf2load.m or abfload.m
%       /home/Matlab/Brians_Functions/identify_channels.m
%
% Used by:
%       cd/plot_traces_abf.m
%       cd/compute_and_plot_evoked_LFP.m
%       cd/identify_eLFP.m

% File history: 
% 2018-09-17 - Moved from plot_traces_abf.m
% 2018-09-17 - Added 'Verbose' as a parameter
% 2018-09-17 - Added tVec, vVecs, iVecs, gVecs as outputs
% 2018-09-18 - Added expMode and now sets timeUnits according to expMode
% 2018-09-20 - Made 'UseOriginalLabels' an optional argument and 
%                   implement it (uses information in fileInfo)
% TODO: Make 'ChannelTypes' an optional argument

%% Hard-coded constants
US_PER_MS = 1e3;            % number of microseconds per millisecond
US_PER_S = 1e6;             % number of microseconds per second

%% Hard-coded parameters
validExpModes = {'EEG', 'patch', ''};
validVoltageUnits = {'pV', 'nV', 'mV', 'V'};
validCurrentUnits = {'pA', 'nA', 'mA', 'A'};
validConductanceUnits = {'pS', 'nS', 'mS', 'S'};

%% Default values for optional arguments
verboseDefault = true;              % print to standard output by default
useOriginalLabelsDefault = false;   % use identify_channels.m instead
                                    % of the original channel labels by default
expModeDefault = '';                % set later
timeUnitsDefault = '';              % set later
channelTypesDefault = {};           % set later

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
    addpath(fullfile(functionsdirectory, '/Downloaded_Functions/'));
                                            % for abf2load.m or abfload.m
    addpath(fullfile(functionsdirectory, '/Brians_Functions/'));
                                            % for identify_channels.m
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
addParameter(iP, 'UseOriginalLabels', useOriginalLabelsDefault, ...
    @(x) validateattributes(x, {'logical', 'numeric'}, {'binary'}));
addParameter(iP, 'ExpMode', expModeDefault, ...
    @(x) any(validatestring(x, validExpModes)));
addParameter(iP, 'TimeUnits', timeUnitsDefault, ...
    @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
addParameter(iP, 'ChannelTypes', channelTypesDefault, ...
    @(x) iscell(x));

% Read from the Input Parser
parse(iP, fileName, varargin{:});
verbose = iP.Results.Verbose;
useOriginalLabels = iP.Results.UseOriginalLabels;
expMode = validatestring(iP.Results.ExpMode, validExpModes);
timeUnits = iP.Results.TimeUnits;
channelTypes = iP.Results.ChannelTypes;

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
        fprintf('The file %s cannot be read!\n', abfFullFileName);
        rethrow(ME)
        return
    end
elseif exist('abfload', 'file') == 2
    [data, siUs, fileInfo] = abfload(abfFullFileName);
end

% Find data dimensions and make sure it is <= 3
nDimensions = ndims(data);        % number of dimensions in data
if nDimensions > 3
    error('Cannot parse data with more than 3 dimensions!');
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
if ~isempty(channelTypes)
    % Decide on channel units based on channel type
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

    % Construct channel labels
    channelLabels = cellfun(@(x, y) [x , ' (', y, ')'], ...
                            channelTypes, channelUnits, ...
                            'UniformOutput', false);
else
    if useOriginalLabels
        % Use the original channel units and labels that came with
        %   the .abf file
        channelNames = (fileInfo.recChNames)';
        channelUnits = (fileInfo.recChUnits)';

        % Construct channel labels
        channelLabels = cellfun(@(x, y) [x , ' (', y, ')'], ...
                                channelNames, channelUnits, ...
                                'UniformOutput', false);

        % Determine the appropriate channel type from the channel units
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
    else
        % Identify channels using the data value ranges and absolute values
        %   of means, etc.
        [channelTypes, channelUnits, channelLabels] = ...
            identify_channels(data, 'ExpMode', expMode);
    end
end

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
indVoltage = find_ind_str_in_cell('Voltage', channelTypes, ...
                                    'IgnoreCase', true);
indCurrent = find_ind_str_in_cell('Current', channelTypes, ...
                                    'IgnoreCase', true);
indConductance = find_ind_str_in_cell('Conductance', channelTypes, ...
                                    'IgnoreCase', true);
if nDimensions == 2
    % Extract voltage vectors if any
    vVecs = data(:, indVoltage);

    % Extract current vectors if any
    iVecs = data(:, indCurrent);

    % Extract conductance vectors if any
    gVecs = data(:, indConductance);
elseif nDimensions == 3
    % Extract voltage vectors if any
    vVecs = squeeze(data(:, indVoltage, :));

    % Extract current vectors if any
    iVecs = squeeze(data(:, indCurrent, :));

    % Extract conductance vectors if any
    gVecs = squeeze(data(:, indConductance, :));
end

%% Return and/or print results
% Store in abfParams
abfParams.abfFullFileName = abfFullFileName;
abfParams.expMode = expMode;
abfParams.siUs = siUs;
abfParams.siMs = siMs;
abfParams.siSeconds = siSeconds;
abfParams.siPlot = siPlot;
abfParams.timeUnits = timeUnits;
abfParams.channelTypes = channelTypes;
abfParams.channelUnits = channelUnits;
abfParams.channelLabels = channelLabels;
abfParams.nDimensions = nDimensions;
abfParams.nSamples = nSamples;
abfParams.nChannels = nChannels;
abfParams.nSweeps = nSweeps;
abfParams.fileInfo = fileInfo;

% Write results to standard output
if verbose
    fprintf('The full path is: %s\n', abfFullFileName);
    fprintf('The experiment mode is: %s\n', expMode);
    fprintf('Number of data dimensions = %d\n', nDimensions);
    fprintf('Number of samples = %d\n', nSamples);
    fprintf('Number of channels = %d\n', nChannels);
    fprintf('Number of sweeps = %d\n', nSweeps);
    fprintf('Sampling Interval for plotting = %g %s\n', siPlot, timeUnits);
    fprintf('Channel Types = %s\n', strjoin(channelTypes, ', '));
    fprintf('Channel Units = %s\n', strjoin(channelUnits, ', '));
    fprintf('Channel Labels = %s\n', strjoin(channelLabels, ', '));
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

%}

