function [dataType, allDataFiles, nDataFiles, message] = ...
                all_data_files (dataTypeUser, dataDirectory, ...
                                possibleDataTypes, varargin)
%% Looks for data files in a dataDirectory according to either dataTypeUser or going through a list of possibleDataTypes
% Usage: [dataType, allDataFiles, nDataFiles, message] = ...
%               all_data_files (dataTypeUser, dataDirectory, ...
%                               possibleDataTypes, varargin)
%
% Arguments:
%       TODO    
%       varargin    - 'FileIdentifier': data file identifier (may be empty)
%                   must be a string scalar or a character vector
%                   default == ''
%                   - 'ExcludedStrings': excluded strings from the filename
%                   must be a cell array of character vectors
%                   default == {}
%
% Requires:
%       cd/isemptycell.m
%
% Used by:
%       cd/minEASE.m
%       cd/combine_sweeps.m
%
% File History:
%   2018-01-29 Moved from cd/minEASE.m
%   2018-01-29 Added the case where dataTypeUser is not recognized 
%   2018-01-29 Added FileIdentifier as an optional argument
%   2018-02-14 Added ExcludedStrings as an optional argument
%   TODO: Make possibleDataTypes an optional argument? Default?
%   TODO: Use all_files.m?
%

%% Default values for optional arguments
fileIdentifierDefault = '';     % no file identifier by default
excludedStringsDefault = {};    % no excluded strings by default

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Deal with arguments
% Check number of required arguments
if nargin < 3
    error(create_error_for_nargin(mfilename));
end

% Set up Input Parser Scheme
iP = inputParser;         
iP.FunctionName = mfilename;

% Add parameter-value pairs to the Input Parser
addParameter(iP, 'FileIdentifier', fileIdentifierDefault, ...
    @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
addParameter(iP, 'ExcludedStrings', excludedStringsDefault, @iscellstr);

% Read from the Input Parser
parse(iP, varargin{:});
fileIdentifier = iP.Results.FileIdentifier;
excludedStrings = iP.Results.ExcludedStrings;

%% Perform job
% Extract the number of possible data types
nDataTypes = numel(possibleDataTypes);

% Find data files according to data type
switch dataTypeUser
case possibleDataTypes              % if user provided a possible data type
    dataType = dataTypeUser;
    allDataFiles = find_valid_files(dataDirectory, fileIdentifier, ...
                                    dataTypeUser, excludedStrings);
    nDataFiles = length(allDataFiles);  % # of files in data subdirectory
    if nDataFiles == 0
        message = {sprintf('There are no .%s files in this directory:', ...
                            dataTypeUser), sprintf('%s', dataDirectory)};
    else
        message = {sprintf(['The .%s files in this directory ', ...
                            'will be used as data:'], dataType), ...
                    sprintf('%s', dataDirectory)};
    end
case 'auto'                         % if automatically detecting data types
    % Iterate through possibleDataTypes to look for possible data type
    for iDataType = 1:nDataTypes
        tempType = possibleDataTypes{iDataType};
        allDataFiles = find_valid_files(dataDirectory, fileIdentifier, ...
                                        tempType, excludedStrings);
        nDataFiles = length(allDataFiles);% # of files in data subdirectory
        if nDataFiles > 0
            dataType = tempType;
            message = {sprintf(['The .%s files in this directory ', ...
                                'will be used as data:'], dataType), ...
                        sprintf('%s', dataDirectory)};
            break;
        end
    end
    if nDataFiles == 0
        dataType = '';
        message = {'There are no acceptable data files in this directory:', ...
                        sprintf('%s', dataDirectory)};
    end
otherwise
    dataType = '';
    allDataFiles = [];
    nDataFiles = 0;

    % Start message
    message = {sprintf('The data type %s is not recognized!', dataTypeUser), ...
                sprintf('The possible data types are: %s'), ...
                        strjoin(possibleDataTypes, ', ')};                     
  
    % End message
    message = [message, 'You could also say ''auto''.\n'];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function allDataFiles = find_valid_files (dataDirectory, fileIdentifier, ...
                                            fileType, excludedStrings)

% Find all files with the given name
allDataFiles = dir(fullfile(dataDirectory, [fileIdentifier, '*.', fileType]));

% Exclude invalid entries by testing the date field
allDataFiles = allDataFiles(~isemptycell({allDataFiles.date}));

% Exclude entries with an excluded string in the name
for iString = 1:numel(excludedStrings)
    if ~isempty(allDataFiles)       % if allDataFiles not already empty
        % Get this excluded string
        string = excludedStrings{iString};
        
        % Get all the data file names as a cell array
        allNames = {allDataFiles.name};
        
        % Determine for each file whether you cannot find the string in the name
        doesNotContainString = isemptycell(strfind(allNames, string));
        
        % Restrict to those files 
        allDataFiles = allDataFiles(doesNotContainString);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
OLD CODE:

message = [message, sprintf('%s', possibleDataTypes{iDataType})];
if iDataType < nDataTypes
    message = [message, ', '];
else
    message = [message, '\n'];
end

% Print possible data types in a line
for iDataType = 1:nDataTypes
    message = [message, sprintf('%s', possibleDataTypes{iDataType})];
    if iDataType < nDataTypes
        message = [message, ', '];
    else
        message = [message, '\n'];
    end
end

    allDataFiles = dir(fullfile(dataDirectory, ...
                    [fileIdentifier, '*.', dataTypeUser]));
        allDataFiles = dir(fullfile(dataDirectory, ...
                        [fileIdentifier, '*.', tempType]));
%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
