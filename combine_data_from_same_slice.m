function allData = combine_data_from_same_slice (varargin)
%% Combines data across multiple .abf files for each slice in the input folder (or for a particular slice)
% Usage: allData = combine_data_from_same_slice (varargin)
% Explanation:
%       TODO
% Example(s):
%       allData = combine_data_from_same_slice;
%       allData = combine_data_from_same_slice('SliceBase', 'slice4');
% Outputs:
%       allData     - combined data for all slices (or for a particular slice)
%                   specified as a table (or struct)
% Arguments:
%       varargin    - 'Directory': working directory
%                   must be a string scalar or a character vector
%                   default == pwd
%                   - 'InFolder': directory to read files from
%                   must be a string scalar or a character vector
%                   default == same as directory
%                   - 'SliceBases': name of slice(s) to combine
%                   must be a character vector, a string vector 
%                       or a cell array of character vectors
%                   default == detected from inFolder
%                   - 'SaveMatFlag': whether to save combined data
%                   must be numeric/logical 1 (true) or 0 (false)
%                   default == true
%                   - 'VarsToSave': variables to save
%                   must be a cell array of strings
%                   default == {'sliceBase', 'vVecsSl', 'siMsSl', 'iVecsSl', ...
%                               'phaseBoundaries', 'phaseStrs'}
%                   - 'ForceTableOutput': whether to force output as a table
%                   must be numeric/logical 1 (true) or 0 (false)
%                   default == false
%
% Requires:
%       cd/all_files.m
%       cd/argfun.m
%       cd/create_error_for_nargin.m
%       cd/count_samples.m
%       cd/count_vectors.m
%       cd/extract_fileparts.m
%       cd/force_matrix.m
%       cd/istext.m
%       cd/parse_all_abfs.m
%
% Used by:
%       cd/parse_all_multiunit.m
%       cd/parse_multiunit.m

% File History:
% 2019-07-24 Moved from parse_all_multiunit.m
% 2019-07-24 Made 'Directory', 'InFolder', 'SaveMatFlag', 'VarsToSave'
%               optional arguments
% 2019-07-24 Added 'SliceName' as an optional argument

%% Default values for optional arguments
directoryDefault = pwd;
inFolderDefault = '';                   % set later
sliceBasesDefault = {};                 % set later
saveMatFlagDefault = true;
varsToSaveDefault = {'sliceBase', 'vVecsSl', 'siMsSl', 'iVecsSl', ...
                    'phaseBoundaries', 'phaseStrs'};
forceTableOutputDefault = false;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Deal with arguments
% Set up Input Parser Scheme
iP = inputParser;
iP.FunctionName = mfilename;

% Add parameter-value pairs to the Input Parser
addParameter(iP, 'Directory', directoryDefault, ...
    @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
addParameter(iP, 'InFolder', inFolderDefault, ...
    @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
addParameter(iP, 'SliceBases', sliceBasesDefault, ...
    @istext);
addParameter(iP, 'SaveMatFlag', saveMatFlagDefault, ...
    @(x) validateattributes(x, {'logical', 'numeric'}, {'binary'}));
addParameter(iP, 'VarsToSave', varsToSaveDefault, ...
    @iscellstr);
addParameter(iP, 'ForceTableOutput', forceTableOutputDefault, ...
    @(x) validateattributes(x, {'logical', 'numeric'}, {'binary'}));

% Read from the Input Parser
parse(iP, varargin{:});
directory = iP.Results.Directory;
inFolder = iP.Results.InFolder;
sliceBases = iP.Results.SliceBases;
saveMatFlag = iP.Results.SaveMatFlag;
varsToSave = iP.Results.VarsToSave;
forceTableOutput = iP.Results.ForceTableOutput;

%% Preparation
% Decide on the input directory
if isempty(inFolder)
    inFolder = directory;
end

% Decide on the unique slice bases
if isempty(sliceBases)
    sliceBases = all_slice_bases(inFolder);
end

% Make sure sliceBase is a cell array
% Note: The variable 'sliceBase' will be part of the table header
sliceBase = force_column_cell(sliceBases);

% Count the number of slices
nSlices = numel(sliceBase);

%% Do the job
if nSlices > 1 || forceTableOutput
    vVecsSl = cell(nSlices, 1);
    siMsSl = nan(nSlices, 1);
    iVecsSl = cell(nSlices, 1);
    phaseBoundaries = cell(nSlices, 1);
    phaseStrs = cell(nSlices, 1);
    parfor iSlice = 1:nSlices
    %for iSlice = 1:nSlices
        [vVecsSl{iSlice}, siMsSl(iSlice), iVecsSl{iSlice}, ...
            phaseBoundaries{iSlice}, phaseStrs{iSlice}] = ...
            combine_data_from_one_slice(inFolder, sliceBase{iSlice}, ...
                                        saveMatFlag, varsToSave);
    end

    % Return as a table
    allData = table(sliceBase, vVecsSl, siMsSl, ...
                        iVecsSl, phaseBoundaries, phaseStrs);
elseif nSlices == 1
    [vVecsSl, siMsSl, iVecsSl, phaseBoundaries, phaseStrs] = ...
        combine_data_from_one_slice(inFolder, sliceBase{1}, ...
                                    saveMatFlag, varsToSave);

    % Return as a struct
    allData.sliceBase = sliceBase{1};
    allData.vVecsSl = vVecsSl;
    allData.siMsSl = siMsSl;
    allData.iVecsSl = iVecsSl;
    allData.phaseBoundaries = phaseBoundaries;
    allData.phaseStrs = phaseStrs;
else
    % Return empty
    allData = [];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function sliceBases = all_slice_bases (directory)
%% Retrieves all slice bases from the .abf files in the directory

%% Hard-coded parameters
regexpSliceName = '.*slice[0-9]*';

% Get all the abf file names
[~, allAbfPaths] = ...
    all_files('Directory', directory, 'Extension', 'abf', ...
              'SortBy', 'date', 'ForceCellOutput', true);

% Extract all slice names
allSliceNames = extract_fileparts(allAbfPaths, 'base', ...
                                    'RegExp', regexpSliceName);

% Get unique slice bases
sliceBases = unique(allSliceNames);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [vVecsSl, siMsSl, iVecsSl, phaseBoundaries, phaseStrs] = ...
            combine_data_from_one_slice(inFolder, sliceBase, ...
                                        saveMatFlag, varsToSave)
%% Combines the data for one slice

%% Hard-coded parameters
regexpPhaseStr = 'phase[a-zA-Z0-9]*';

%% Count files and phases
% Get all .abf files for this slice ordered by time stamp
[~, allAbfPaths] = all_files('Directory', inFolder, 'Prefix', sliceBase, ...
                            'Extension', 'abf', 'SortBy', 'date');

% If no file found, return
if isempty(allAbfPaths)
    vVecsSl = [];
    siMsSl = NaN;
    iVecsSl = [];
    phaseBoundaries = [];
    phaseStrs = {};
    return
end

% Extract file names
allFileNames = extract_fileparts(allAbfPaths, 'name');

% Extract phase strings
allPhaseStrs = extract_fileparts(allFileNames, 'base', 'RegExp', regexpPhaseStr);

% Get the unique phase strings in original order
phaseStrs = unique(allPhaseStrs, 'stable');

% Count the number of phases
nPhases = numel(phaseStrs);

%% Extract data to combine
% Parse all multi-unit recordings for this slice
[allParams, allData] = ...
    parse_all_abfs('FileNames', allAbfPaths, ...
                    'ChannelTypes', {'voltage', 'current'}, ...
                    'ChannelUnits', {'uV', 'arb'}, ...
                    'SaveSheetFlag', false);

% Extract parameters, then clear unused parameters
siMs = allParams.siMs;
clear allParams;

% Extract data, then clear unused data
vVecs = allData.vVecs;
iVecs = allData.iVecs;
clear allData;

% Find the indices for each phase
indEachPhase = cellfun(@(x) find_in_strings(x, allFileNames), ...
                        phaseStrs, 'UniformOutput', false);

%% Order the data correctedly (may not be needed)
% Put them all together
sortOrder = vertcat(indEachPhase{:});

% Reorder data
[siMs, vVecs, iVecs] = argfun(@(x) x(sortOrder), siMs, vVecs, iVecs);

%% Combine the data
% Compute the new siMs
siMsSl = mean(siMs);

% Concatenate vectors
% TODO: Fix force_matrix
% [vVecsSl, iVecsSl] = argfun(@force_matrix, vVecs, iVecs);
[vVecsSl, iVecsSl] = argfun(@(x) horzcat(x{:}), vVecs, iVecs);

%% Create phase boundaries
% Count the number of phase boundaries
nBoundaries = nPhases - 1;

% Compute phase boundaries
if nBoundaries == 0
    phaseBoundaries = [];
else
    % Count the number of files for each phase
    nFilesEachPhase = cellfun(@count_samples, indEachPhase);

    % Get the index of the last file for each phase
    iFileLastEachPhase = cumsum(nFilesEachPhase);

    % Get the index of the first file for each phase
    iFileFirstEachPhase = iFileLastEachPhase - nFilesEachPhase + 1;

    % Count the number of sweeps in each file
    nSweepsEachFile = cellfun(@count_vectors, vVecs);

    % Count the number of sweeps in each phase
    nSweepsEachPhase = arrayfun(@(x, y) sum(nSweepsEachFile(x:y)), ...
                            iFileFirstEachPhase, iFileLastEachPhase);

    % Get the index of the last sweep for each phase
    iFileLastEachPhase = cumsum(nSweepsEachPhase);

    % Compute the phase boundaries
    phaseBoundaries = iFileLastEachPhase(1:nBoundaries) + 0.5;
end

%% Save to a matfile if requested
if saveMatFlag
    % Create a matfile path
    commonPrefix = extract_fileparts(allAbfPaths, 'commonprefix');
    commonDir = extract_fileparts(allAbfPaths, 'commondirectory');
    matPath = fullfile(commonDir, [commonPrefix, '.mat']);

    % Save data for this slice
    save(matPath, varsToSave{:}, '-v7.3');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
OLD CODE:

%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%