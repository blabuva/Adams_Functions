function varargout = all_files (varargin)
%% Returns all the files in a given directory (optionally recursive) that matches a prefix, keyword, suffix or extension
% Usage: [files, fullPaths] = all_files (varargin)
% Explanation:
%       TODO
%
% Example(s):
%       [files, fullPaths] = all_files;
%       [files, fullPaths] = all_files('SortBy', 'date');
%       [files, fullPaths] = all_files('Recursive', true);
%
% Outputs:
%       files       - file structure(s) for the files
%                   specified as a structure array with fields:
%                       name
%                       folder
%                       date
%                       bytes
%                       isdir
%                       datenum
%       fullPaths   - full path(s) to the files
%                   specified as a column cell array of character vectors
% Arguments:
%       varargin    - 'Verbose': whether to write to standard output
%                   must be numeric/logical 1 (true) or 0 (false)
%                   default == false
%                   - 'WarnFlag': whether to warn if no files found
%                   must be numeric/logical 1 (true) or 0 (false)
%                   default == true
%                   - 'Recursive': whether to search recursively
%                   must be numeric/logical 1 (true) or 0 (false)
%                   default == false
%                   - 'ForceCellOutput': whether to force output as a cell array
%                   must be numeric/logical 1 (true) or 0 (false)
%                   default == false
%                   - 'Directory': the directory to search in
%                   must be a string scalar or a character vector
%                   default == pwd
%                   - 'Prefix': prefix the file name must have
%                   must be a string scalar or a character vector
%                   default == no limits
%                   - 'Keyword': keyword the file name must contain
%                   must be a string scalar or a character vector
%                   default == no limits
%                   - 'Suffix': suffix the file name must have
%                   must be a string scalar or a character vector
%                   default == no limits
%                   - 'Extension': file extension to limit to
%                   must be a string scalar or a character vector
%                   default == no limits
%                   - 'RegExp': regular expression to limit to
%                   must be a string scalar or a character vector
%                   default == no limits
%                   - 'SortBy': how to sort the files
%                   must be an unambiguous, case-insensitive match to one of: 
%                       'name'  - by file name
%                       'date'  - by modification date
%                       'bytes' - by file size in bytes
%                   default == 'name'
%
% Requires:
%       cd/construct_and_check_fullpath.m
%       cd/extract_fullpaths.m
%
% Used by: 
%       cd/all_swd_sheets.m
%       cd/atf2sheet.m
%       cd/combine_data_from_same_slice.m
%       cd/m3ha_pfiles2csv.m
%       cd/parse_all_abfs.m
%       cd/parse_all_multiunit.m
%       cd/parse_all_swds.m
%       cd/plot_all_abfs.m
%       cd/plot_protocols.m
%       cd/plot_traces_EEG.m
%       /home/Matlab/plethRO1/spike2loader.m
%       

% File History:
% 2018-10-04 Modified from all_subdirs.m
% 2018-11-21 Added 'Prefix', 'Keyword', 'Suffix', 'RegExp' as optional arguments
% 2018-11-26 Added 'Recursive' as an optional flag
% 2018-12-26 Added 'ForceCellOutput' as an optional argument
% 2019-03-15 Fixed the case when extension is not provided
% 2019-05-16 Added 'WarnFlag' as an optional flag
% 2019-05-21 Added 'SortBy' as an optional argument
% TODO: Add 'MaxNum' as an optional argument
% TODO: use force_string_start.m to make sure extension starts with a dot
% TODO: Fix bug when a dot is in the folder name

%% Hard-coded parameters
validSortBys = {'name', 'date', 'bytes'};

%% Default values for optional arguments
verboseDefault = false;         % don't print to standard output by default
warnFlagDefault = true;         % warn if no files found by default
recursiveDefault = false;       % don't search recursively by default
forceCellOutputDefault = false; % don't force output as a cell array by default
directoryDefault = '';          % construct_and_check_fullpath('') == pwd
prefixDefault = '';             % set later
keywordDefault = '';            % set later
suffixDefault = '';             % set later
extensionDefault = '';          % set later
regExpDefault = '';             % set later
sortByDefault = 'name';         % sort by name by default

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Deal with arguments
% Set up Input Parser Scheme
iP = inputParser;
iP.FunctionName = mfilename;

% Add parameter-value pairs to the Input Parser
addParameter(iP, 'Verbose', verboseDefault, ...
    @(x) validateattributes(x, {'logical', 'numeric'}, {'binary'}));
addParameter(iP, 'WarnFlag', warnFlagDefault, ...
    @(x) validateattributes(x, {'logical', 'numeric'}, {'binary'}));
addParameter(iP, 'Recursive', recursiveDefault, ...
    @(x) validateattributes(x, {'logical', 'numeric'}, {'binary'}));
addParameter(iP, 'ForceCellOutput', forceCellOutputDefault, ...
    @(x) validateattributes(x, {'logical', 'numeric'}, {'binary'}));
addParameter(iP, 'Directory', directoryDefault, ...
    @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
addParameter(iP, 'Prefix', prefixDefault, ...
    @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
addParameter(iP, 'Keyword', keywordDefault, ...
    @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
addParameter(iP, 'Suffix', suffixDefault, ...
    @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
addParameter(iP, 'Extension', extensionDefault, ...
    @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
addParameter(iP, 'RegExp', regExpDefault, ...
    @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
addParameter(iP, 'SortBy', sortByDefault, ...
    @(x) any(validatestring(x, validSortBys)));

% Read from the Input Parser
parse(iP, varargin{:});
verbose = iP.Results.Verbose;
warnFlag = iP.Results.WarnFlag;
recursive = iP.Results.Recursive;
forceCellOutput = iP.Results.ForceCellOutput;
directory = iP.Results.Directory;
prefix = iP.Results.Prefix;
keyword = iP.Results.Keyword;
suffix = iP.Results.Suffix;
extension = iP.Results.Extension;
regExp = iP.Results.RegExp;
sortBy = validatestring(iP.Results.SortBy, validSortBys);

% Make sure the directory is an existing full path
[directory, dirExists] = construct_and_check_fullpath(directory);
if ~dirExists
    varargout{1} = [];
    varargout{2} = {};
    return
end

%% Find files
% Get or check the regular expression to match
if isempty(regExp)
    if ~isempty(extension)
        % Match the prefix, keyword, suffix and extension
        regExp = sprintf('%s.*%s.*%s%s$', prefix, keyword, suffix, extension);
    else
        % Match the prefix, keyword, suffix
        regExp = sprintf('%s.*%s.*%s[.].*$', prefix, keyword, suffix);
    end
else
    % Display warning if an extension is provided
    if ~isempty(prefix)
        fprintf('Warning: A regular expression will override the prefix!\n');
    end
    if ~isempty(keyword)
        fprintf('Warning: A regular expression will override the keyword!\n');
    end
    if ~isempty(suffix)
        fprintf('Warning: A regular expression will override the suffix!\n');
    end
    if ~isempty(extension)
        fprintf('Warning: A regular expression will override the extension!\n');
    end
end

if recursive
    % Get a list of all files and subdirectories in this directory 
    %   and all subdirectories
    filesOrDirs = dir(fullfile(directory, '**'));
else
    % Get a list of all files and subdirectories in this directory only
    filesOrDirs = dir(directory);
end

% Get a logical vector that tells which entries are directories
isDir = transpose([filesOrDirs.isdir]);

% Get a logical vector that tells which entries matches the regular expression
if ~isempty(regExp)
    % Get all file or directory names
    names = transpose({filesOrDirs.name});

    % Test whether each matches the regular expression
    isMatch = cellfun(@any, regexpi(names, regExp));
else
    % All files will be considered matched
    isMatch = true(size(filesOrDirs));
end

% Keep only those that are not directories and 
%   are matches to the regular expression
files = filesOrDirs(~isDir & isMatch);

% Sort by date or bytes if requested
if ~strcmpi(sortBy, 'name')
    % Convert the struct array to a table
    filesTable = struct2table(files);

    % Sort the table by the requested field
    filesTableSorted = sortrows(filesTable, sortBy); 

    % Change it back to a struct array
    files = table2struct(filesTableSorted);
end

% Get first output
varargout{1} = files;

% Extract the full paths
if nargout >= 2
    varargout{2} = extract_fullpaths(files, 'ForceCellOutput', forceCellOutput);
end

%% Print to standard output
% Count the number of files
nFiles = numel(files);

% Print appropriate message
if nFiles == 0 && warnFlag
    fprintf('No files with pattern %s found in %s!!\n', regExp, directory);
elseif verbose
    fprintf('%d files with pattern %s found in %s!\n', ...
            nFiles, regExp, directory);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
OLD CODE:



%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%