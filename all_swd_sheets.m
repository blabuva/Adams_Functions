function [swdSheetFiles, swdSheetPaths] = all_swd_sheets (varargin)
%% Returns all files ending with '_SWDs.csv' under a directory recursively
% Usage: [swdSheetFiles, swdSheetPaths] = all_swd_sheets (varargin)
% Explanation:
%       TODO
% Example(s):
%       TODO
% Outputs:
%       swdSheetFiles   - file structure(s) for the SWD spreadheet files
%                       specified as a structure array with fields:
%                           name
%                           folder
%                           date
%                           bytes
%                           isdir
%                           datenum
%       swdSheetPaths   - full path(s) to the SWD spreadheet files
%                       specified as a column cell array of character vectors
% Arguments:
%       varargin    - 'Suffix': suffix the file name must have
%                   must be a string scalar or a character vector
%                   default == '_SWDs'
%                   - 'SheetType': sheet type;
%                       e.g., 'xlsx', 'csv', etc.
%                   could be anything recognised by the readtable() function 
%                   (see issheettype.m under Adams_Functions)
%                   default == 'csv'
%                   - Any other parameter-value pair for all_files()
%                   
% Requires:
%       cd/all_files.m
%       cd/issheettype.m
%
% Used by:
%       cd/combine_swd_sheets.m
%       cd/read_swd_sheets.m

% File History:
% 2018-11-27 Moved from plot_swd_raster.m
% 2018-12-27 Added 'Suffix' as an optional argument
% 2019-10-04 Added 'Recursive' as an optional argument
% 2020-06-28 Moved printing message to all_files.m

%% Hard-coded parameters
swdStr = '_SWDs';               % string in file names for SWD spreadsheets

%% Default values for optional arguments
suffixDefault = '';             % set later
sheetTypeDefault = 'csv';       % default spreadsheet type

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Deal with arguments
% Set up Input Parser Scheme
iP = inputParser;
iP.FunctionName = mfilename;
iP.KeepUnmatched = true;                        % allow extraneous options

% Add parameter-value pairs to the Input Parser
addParameter(iP, 'Suffix', suffixDefault, ...
    @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
addParameter(iP, 'SheetType', sheetTypeDefault, ...
    @(x) all(issheettype(x, 'ValidateMode', true)));

% Read from the Input Parser
parse(iP, varargin{:});
suffix = iP.Results.Suffix;
[~, sheetType] = issheettype(iP.Results.SheetType, 'ValidateMode', true);

% Keep unmatched arguments for the all_files() function
otherArguments = iP.Unmatched;

%% Do the job
% Set default string to recognize SWD spreadsheets
if isempty(suffix)
    suffix = swdStr;
end

% Find all SWD spreadsheet files in the directory
[swdSheetFiles, swdSheetPaths] = ...
    all_files('Suffix', suffix, 'Extension', sheetType, ...
                otherArguments);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
OLD CODE:

%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
