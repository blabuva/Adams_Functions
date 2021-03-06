function varargout = all_dependent_files (mScriptName, varargin)
%% Prints all dependent files used by a given MATLAB script/function
% Usage: [fTableOrList, pTableOrList] = all_dependent_files (mScriptName, varargin)
% Explanation:
%       TODO
% Example(s):
%       all_dependent_files('parse_pulse')
%       all_dependent_files('parse_pulse.m')
%       [fTable, pTable] = all_dependent_files('parse_pulse')
%       [fList, pList] = all_dependent_files('parse_pulse', 'OriginalOutput', true)
%
% Outputs:
%       fTableOrList    - a table or cell array of function paths
%                       specified as a table or cell
%       pTableOrList    - a table or structure of MATLAB products
%                       specified as a table or struct
%
% Arguments:
%       mScriptName - .m script name
%                   must be a string scalar or a character vector
%       varargin    - 'TopOnly': display only the files used directly 
%                                   by the given script/function
%                   must be numeric/logical 1 (true) or 0 (false)
%                   default == false
%                   - 'OriginalOutput': whether to return a cell array
%                                       and a structure instead
%                   must be numeric/logical 1 (true) or 0 (false)
%                   default == false
%                   - 'SaveFlag': whether to save spreadsheets
%                   must be numeric/logical 1 (true) or 0 (false)
%                   default == true
%                   - 'PrintFlag': whether to print to standard output
%                   must be numeric/logical 1 (true) or 0 (false)
%                   default == true
%                   - 'OutFolder': directory to save spreadsheets
%                   must be a string scalar or a character vector
%                   default == pwd
%
% Requires:
%       cd/create_error_for_nargin.m
%       cd/extract_common_directory.m
%       cd/extract_fileparts.m
%       cd/force_column_cell.m
%
% Used by:
%       cd/archive_dependent_scripts.m
%       cd/compile_script.m

% File History:
% 2019-08-09 Created by Adam Lu
% 2019-08-12 Added 'OutFolder' as an optional argument
% 2019-08-12 Added 'OriginalOutput' as an optional argument
% 2019-08-12 Added 'SaveFlag' as an optional argument
% 2019-08-12 Added 'PrintFlag' as an optional argument
% TODO: Add 'fileListPath' as an optional argument
% TODO: Add 'MatlabProductListPath' as an optional argument
% TODO: Add 'SheetType' as an optional argument
% TODO: Allow processing of multiple files 

%% Hard-coded parameters
fileListSuffix = 'function_list';
matlabProductListSuffix = 'matlab_product_list';

% TODO: Make these optional arguments
fileListPath = [];
matlabProductListPath = [];
sheetType = 'csv';

%% Default values for optional arguments
topOnlyDefault = false;
originalOutputDefault = false;
saveFlagDefault = true;
printFlagDefault = true;
outFolderDefault = pwd;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Deal with arguments
% Check number of required arguments
if nargin < 1
    error(create_error_for_nargin(mScriptName));
end

% Set up Input Parser Scheme
iP = inputParser;
iP.FunctionName = mScriptName;

% Add required inputs to the Input Parser
addRequired(iP, 'mScriptName', ...
    @(x) assert(ischar(x) || iscellstr(x) || isstring(x), ...
        ['mScriptName must be a character array or a string array ', ...
            'or cell array of character arrays!']));

% Add parameter-value pairs to the Input Parser
addParameter(iP, 'TopOnly', topOnlyDefault, ...
    @(x) validateattributes(x, {'logical', 'numeric'}, {'binary'}));
addParameter(iP, 'OriginalOutput', originalOutputDefault, ...
    @(x) validateattributes(x, {'logical', 'numeric'}, {'binary'}));
addParameter(iP, 'SaveFlag', saveFlagDefault, ...
    @(x) validateattributes(x, {'logical', 'numeric'}, {'binary'}));
addParameter(iP, 'PrintFlag', printFlagDefault, ...
    @(x) validateattributes(x, {'logical', 'numeric'}, {'binary'}));
addParameter(iP, 'OutFolder', outFolderDefault, ...
    @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));

% Read from the Input Parser
parse(iP, mScriptName, varargin{:});
topOnly = iP.Results.TopOnly;
originalOutput = iP.Results.OriginalOutput;
saveFlag = iP.Results.SaveFlag;
printFlag = iP.Results.PrintFlag;
outFolder = iP.Results.OutFolder;

%% Preparation 
% Extract just the file name without '.m'
if regexp(mScriptName, '.m$')
    mFileBase = extractBefore(mScriptName, '.m');
else
    mFileBase = mScriptName;
end

% Set default function list path
if isempty(fileListPath)
    fileListPath = fullfile(outFolder, ...
                    [mFileBase, '_', fileListSuffix, '.', sheetType]);
end

% Set default MATLAB product list path
if isempty(matlabProductListPath)
    matlabProductListPath = fullfile(outFolder, ...
                    [mFileBase, '_', matlabProductListSuffix, '.', sheetType]);
end

%% Do the job
% Retrieve dependent files and MATLAB products
%   Note: Introduced in R2014a
if topOnly
    [fileList, matlabProductList] = ...
        matlab.codetools.requiredFilesAndProducts(mScriptName, 'toponly');
else
    [fileList, matlabProductList] = ...
        matlab.codetools.requiredFilesAndProducts(mScriptName);
end

if originalOutput
    varargout{1} = fileList;
    varargout{2} = matlabProductList;
    return
end

% Rename as fullPath and force as a column cell array
fullPath = force_column_cell(fileList);

% Extract just the function name
fileName = extract_fileparts(fullPath, 'name');

% Extract the containing directory
directory = extract_fileparts(fullPath, 'directory');

% Extract the common directory for all dependent files
commonDirectory = extract_common_directory(fileList);

% Add the file separater
parentDirectoryWithFileSep = [commonDirectory, filesep];

% Extract relative paths
relativePath = extractAfter(fullPath, parentDirectoryWithFileSep);

%% Convert to tables
% Expand commonDirectory as cell array
commonDirectory = repmat({commonDirectory}, size(fullPath));

% Convert to tables
fileListTable = table(fileName, directory, commonDirectory, relativePath, fullPath);
matlabProductListTable = struct2table(matlabProductList);

%% Save tables
if saveFlag
    writetable(fileListTable, fileListPath);
    writetable(matlabProductListTable, matlabProductListPath);
end

%% Display results
if printFlag
    display(fileListTable);
    display(matlabProductListTable);
end

%% Output results
varargout{1} = fileListTable;
varargout{2} = matlabProductListTable;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
OLD CODE:

%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
