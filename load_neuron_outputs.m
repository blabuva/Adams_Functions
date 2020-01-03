function [outputs, fullPaths] = load_neuron_outputs (varargin)
%% Loads .out files created by NEURON into a cell array
% Usage: [outputs, fullPaths] = load_neuron_outputs (varargin)
% Explanation:
%       TODO
% Example(s):
%       TODO
% Outputs:
%       outputs     - a cell array of outputs
%                   specified as a cell array
% Arguments:
%       varargin    - 'Directories': the name of the directory(ies) containing 
%                                   the .out files, e.g. '20161216'
%                   must be a characeter vector, a string array 
%                       or a cell array of character arrays
%                   default == pwd
%                   - 'FileNames': names of .out files to load
%                   must be empty, a characeter vector, a string array 
%                       or a cell array of character arrays
%                   default == detect from pwd
%                   - 'Verbose': whether to output parsed results
%                   must be numeric/logical 1 (true) or 0 (false)
%                   default == false
%                   - 'RemoveAfterLoad': whether to remove .out files 
%                                           after loading
%                   must be numeric/logical 1 (true) or 0 (false)
%                   default == false
%                   - 'tVecs': time vectors to match
%                   must be a numeric array or a cell array of numeric arrays
%                   default == [] (none provided)
%
% Requires:
%       cd/array_fun.m
%       cd/construct_and_check_fullpath.m
%       cd/is_in_parallel.m
%       cd/match_format_vector_sets.m
%       cd/match_time_points.m
%
% Used by:    
%       cd/m3ha_neuron_run_and_analyze.m
%       cd/m3ha_plot_simulated_traces.m
%       cd/m3ha_simulate_population.m

% File History:
% 2018-10-23 Adapted from code in run_neuron_once_4compgabab.m
% 2018-10-31 Went back to using parfor for loading
% 2018-11-16 Fixed directories and allowed it to be a cell array TODO: fix all_files?
% 2020-01-01 Now uses array_fun.m

%% Hard-coded parameters
outputExtension = '.out';

%% Default values for optional arguments
directoriesDefault = '';            % set later
fileNamesDefault = {};              % detect from pwd by default
verboseDefault = false;             % print to standard output by default
removeAfterLoadDefault = false;     % don't remove .out files by default
tVecsDefault = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Deal with arguments
% Set up Input Parser Scheme
iP = inputParser;
iP.FunctionName = mfilename;

% Add parameter-value pairs to the Input Parser
addParameter(iP, 'Directories', directoriesDefault, ...
    @(x) isempty(x) || ischar(x) || iscellstr(x) || isstring(x));
addParameter(iP, 'FileNames', fileNamesDefault, ...
    @(x) isempty(x) || ischar(x) || iscellstr(x) || isstring(x));
addParameter(iP, 'Verbose', verboseDefault, ...
    @(x) validateattributes(x, {'logical', 'numeric'}, {'binary'}));
addParameter(iP, 'RemoveAfterLoad', removeAfterLoadDefault, ...
    @(x) validateattributes(x, {'logical', 'numeric'}, {'binary'}));
addParameter(iP, 'tVecs', tVecsDefault, ...
    @(x) assert(isempty(x) || isnumeric(x) || iscellnumeric(x), ...
                ['tVecs must be either a numeric array', ...
                    'or a cell array of numeric arrays!']));

% Read from the Input Parser
parse(iP, varargin{:});
directories = iP.Results.Directories;
fileNames = iP.Results.FileNames;
verbose = iP.Results.Verbose;
removeAfterLoad = iP.Results.RemoveAfterLoad;
tVecs = iP.Results.tVecs;

%% Preparation
% Decide on the files to use
if isempty(fileNames)
    % Find all .out files in the directories
    [~, fileNames] = all_files('Directory', directories, ...
                                'Extension', outputExtension, ...
                                'Verbose', verbose);

    % Return usage message if no .out files found
    if isempty(fileNames)
        fprintf('Type ''help %s'' for usage\n', mfilename);
        outputs = {};
        fullPaths = {};
        return
    end
elseif ischar(fileNames)
    % Place in cell array
    fileNames = {fileNames};
end

% Construct full paths and check whether the files exist
%   TODO: Expand to accept optional Suffix', etc.
[fullPaths, pathExists] = ...
    construct_and_check_fullpath(fileNames, 'Directory', directories);

% Return if not all paths exist
if ~all(pathExists)
    fprintf('Some of the output paths do not exist!\n');
    outputs = {};
    fullPaths = {};
    return
end

%% Load files
% Load the data saved by NEURON to a .out file into a cell array
outputs = array_fun(@load, fullPaths, 'UniformOutput', false);

% If tVecs not empty, interpolate simulated data to match the time points
if ~isempty(tVecs)
    % Match the number of time vectors and simulated outputs
    [tVecs, outputs] = match_format_vector_sets(tVecs, outputs);

    % Interpolated simulated data
    outputs = array_fun(@(x, y) match_time_points(x, y), ...
                        outputs, tVecs, 'UniformOutput', false);
end

%% Remove files
% Remove .out files created by NEURON if not to be saved
%   Note: Never use parfor here, so don't use array_fun 
if removeAfterLoad
    cellfun(@delete, fullPaths, 'UniformOutput', false);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
OLD CODE:

% Count the number of output files
nFiles = numel(fullPaths);

simDataNeuron = cell(nFiles, 1);
parfor iFile = 1:nFiles
    simDataNeuron{iFile} = load(fullPaths{iFile});
end

parfor iFile = 1:nFiles
    delete(fullPaths{iFile});
end

% 2018-11-01 The following is slower than parfor for large files
% Load the data saved by NEURON to a .out file into a cell array
outputs = cellfun(@load, fullPaths, 'UniformOutput', false);

%}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
