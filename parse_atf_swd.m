function [swdManualTable, swdManualCsvFile] = ...
                parse_atf_swd (originalEventFile, varargin)
%% Parse spike-wave-discharge (SWD) event info from .atf file or converted .csv file
% Usage: [swdManualTable, swdManualCsvFile] = ...
%               parse_atf_swd (originalEventFile, varargin)
% Explanation:
%       TODO
%
% Example(s):
%       swdManualTable = parse_atf_swd('WAGS04_30_2018_cage3_Manual_SWDs.atf');
%
% Outputs:
%       swdManualTable      - a table of spike-wave discharge event info
%                           specified as a 2D table
%
% Arguments:
%       originalEventFile   - original event file, could be .atf or 
%                               converted .csv
%                           must be a string scalar or a character vector
%       varargin    - 'TraceFileName': Name of the corresponding trace file(s)
%                   must be empty, a characeter vector, a string array 
%                       or a cell array of character arrays
%                   default == extracted from the .atf file
%                   - 'OutFolder': directory to output swd table file, 
%                                   e.g. 'output'
%                   must be a string scalar or a character vector
%                   default == same as location of originalEventFile
%                   - 'SheetType': sheet type;
%                       e.g., 'xlsx', 'csv', etc.
%                   could be anything recognised by the readtable() function 
%                   (see issheettype.m under Adams_Functions)
%                   default == 'csv'
%
% Requires:
%       cd/argfun.m
%       cd/atf2sheet.m
%       cd/construct_and_check_fullpath.m
%       cd/create_error_for_nargin.m
%       cd/extract_fileparts.m
%       cd/force_column_cell.m
%       cd/issheettype.m
%       cd/match_dimensions.m
%
% Used by:
%       cd/parse_all_swds.m
%       cd/plot_traces_EEG.m

% File History:
% 2018-11-21 Created by Adam Lu
% 2018-12-26 Added 'SheetType' as an optional argument
% 2019-09-08 Now uses the trace file name as the basis 
%               for constructing sheet file name
% 

%% Hard-coded constants
MS_PER_S = 1000;

%% Hard-coded parameters
varNames = {'startTime', 'endTime', 'duration', 'tracePath', 'pathExists'};

%% Default values for optional arguments
traceFileNameDefault = '';      % set later
outFolderDefault = '';          % set later
sheetTypeDefault = 'csv';       % default spreadsheet type

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Deal with arguments
% Check number of required arguments
if nargin < 1
    error(create_error_for_nargin(mfilename));
end

% Set up Input Parser Scheme
iP = inputParser;
iP.FunctionName = mfilename;

% Add required inputs to the Input Parser
addRequired(iP, 'originalEventFile', ...
    @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));

% Add parameter-value pairs to the Input Parser
addParameter(iP, 'TraceFileName', traceFileNameDefault, ...
    @(x) isempty(x) || ischar(x) || iscellstr(x) || isstring(x));
addParameter(iP, 'OutFolder', outFolderDefault, ...
    @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
addParameter(iP, 'SheetType', sheetTypeDefault, ...
    @(x) all(issheettype(x, 'ValidateMode', true)));

% Read from the Input Parser
parse(iP, originalEventFile, varargin{:});
traceFileName = iP.Results.TraceFileName;
outFolder = iP.Results.OutFolder;
[~, sheetType] = issheettype(iP.Results.SheetType, 'ValidateMode', true);

%% Preparation
% Decide what file type the first input is
if regexpi(originalEventFile, '.atf$')
    atfFile = originalEventFile;
    atfCsvFile = '';
elseif regexpi(originalEventFile, '_atf.csv$')
    atfFile = '';
    atfCsvFile = originalEventFile;
else
    atfFile = '';
    atfCsvFile = '';
end

% Get the fileDir and fileBase
[fileDir, fileBase, ~] = fileparts(originalEventFile);

% Decide on the output folder
if isempty(outFolder)
    outFolder = fileDir;
end

%% Do the job
% Read the table from the file
if ~isfile(atfFile) && ~isfile(atfCsvFile)
    % Do nothing
    swdManualTable = [];
    swdManualCsvFile = '';
    return
elseif isfile(atfCsvFile)
    % Display warning if atf file also provided
    if isfile(atfFile)
        fprintf(['Table with be read from the csv file ', ...
                'instead of the atf file!\n']);
    end

    % Read in the SWD manual table from the converted csv file
    atfTable = readtable(atfCsvFile);
elseif isfile(atfFile)
    % Read in the SWD manual table and print to a csv file
    [atfTable, atfCsvFile] = atf2sheet(atfFile, 'SheetType', sheetType);
end

% Make sure there is an event recorded
if height(atfTable) == 0
    % Do nothing
    atfTable = [];
    return
end

% Get the first channel name
firstSignalName = atfTable{1, 'Signal'};

% Check whether each row is the same as firstSignalName
isFirstSignal = strcmp(atfTable.Signal, firstSignalName);

% Restrict to the entries for the first channel only
swdManualTableOfInterest = atfTable(isFirstSignal, :);

% Get the start and end times in ms
startTimesMs = swdManualTableOfInterest.Time1_ms_;
endTimesMs = swdManualTableOfInterest.Time2_ms_;

% Convert to seconds
startTime = startTimesMs / MS_PER_S;
endTime = endTimesMs / MS_PER_S;

% Compute duration
duration = endTime - startTime;

% If not provided, read in the trace file names
if isempty(traceFileName)
    % Get the .abf file name for each SWD
    traceFileName = swdManualTableOfInterest.FileName;
end

% Construct full path to original data file
[tracePath, pathExists] = construct_and_check_fullpath(traceFileName);

% Force as a column cell array
tracePath = force_column_cell(tracePath);

% Make sure the dimensions match up
[tracePath, pathExists] = ...
    argfun(@(x) match_dimensions(x, size(startTime)), ...
            tracePath, pathExists);

% Extract the file base of the trace file
traceFileBase = extract_fileparts(traceFileName{1}, 'base');

% Extract the file extension of the trace file
traceFileExt = extract_fileparts(traceFileName{1}, 'ext');

% Construct manual SWD table csv file
swdManualCsvFile = ...
    fullfile(outFolder, [traceFileBase, '_Manual_SWDs.', sheetType]);

%% Correct the start and end times if the data comes from an ATF file
if strcmpi(traceFileExt, 'atf')
    if 
        traceStartTime = 
    end
    startTime = 
    endTime = 
end

%% Output results
% Create a table for the parsed SWDs
swdManualTable = table(startTime, endTime, duration, ...
                        tracePath, pathExists, 'VariableNames', varNames);

% Write the table to a file
writetable(swdManualTable, swdManualCsvFile);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
OLD CODE:

%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%