function [initParamTables, initParamFiles, otherParams] = ...
                m3ha_neuron_create_initial_params (varargin)
%% Creates initial NEURON parameters for each cell recorded in dynamic clamp experiments
% Usage: [initParamTables, initParamFiles, otherParams] = ...
%               m3ha_neuron_create_initial_params (varargin)
% Explanation:
%       Initial parameters table created through the following steps:
%           1. All cells start out with the default from Destexhe et al 1998a
%           2. Replace geometric parameters and gpas with curve-fitted values
%                   if requested
%           3. Replace ParamsToReplace by custom values if provided
%           4. Make active channel conductances minimal if requested
%
% Example(s):
%       m3ha_neuron_create_initial_params;
%
% Outputs:
%       initParamTables - initial NEURON parameters table for each cell
%                       specified as a cell array of tables
%       initParamFiles  - initial NEURON parameters file for each cell
%                       specified as a cell array of character arrays
%
% Arguments:
%       varargin    - 'PassiveFileName': the name of passive parameters file
%                   must be a string scalar or a character vector
%                   default == /media/adamX/m3ha/data_dclamp/take4/
%                               dclampPassiveParams_byCells_tofit.xlsx
%                   - 'CellNames': cell names to create initial parameters for
%                   must be a string vector or a cell array of character vectors
%                   default == all cells in passive file
%                   - 'OutFolder': directory to place NEURON parameters files
%                   must be a string scalar or a character vector
%                   default == fullfile(pwd, 'initial_params')
%                   - 'OutPrefix': prefix for output file
%                   must be a string scalar or a character vector
%                   default == 'initial_params_'
%                   - 'OutSuffix': suffix for output file
%                   must be a string scalar or a character vector
%                   default == ''
%                   - 'UseCurveFitParams': whether to use curve-fitted params
%                   must be numeric/logical 1 (true) or 0 (false)
%                   default == false
%                   - 'ParamsToReplace': parameter names to replace from 
%                                       custom tables or files or from
%                                       PassiveFileName
%                   must be a string vector or a cell array of character vectors
%                   default == all parameters provided
%                   - 'CustomInitNames': custom initial parameter names
%                                           that replaces default for each cell
%                   must be a cell array of character vectors 
%                       or a cell array of cell arrays of character vectors
%                   default == none provided
%                   - 'CustomInitValues': custom initial parameter values
%                                           that replaces default for each cell
%                   must be a numeric vector or a cell array of numeric vectors
%                   default == none provided
%                   - 'CustomInitTables': custom tables with initial parameter 
%                                           values that replaces default
%                   must be a cell array of tables
%                   default == none provided
%                   - 'CustomInitFiles': custom spreadsheet files with initial 
%                                       parameter values that replaces default
%                   must be a string vector or a cell array of character vectors
%                   default == none provided
%                   - 'CustomInitDirectory': custom directory containing
%                                       spreadsheet files with initial 
%                                       parameter values that replaces default
%                   must be a string scalar or a character vector
%                   default == none provided
%                   - 'MinimalActiveChannels': whether to set all 
%                                           active channels to the minimum value
%                   must be numeric/logical 1 (true) or 0 (false)
%                   default == false
%
% Requires:
%       cd/all_files.m
%       cd/argfun.m
%       cd/check_dir.m
%       cd/compute_gpas.m
%       cd/compute_surface_area.m
%       cd/construct_fullpath.m
%       cd/copyvars.m
%       cd/count_samples.m
%       cd/extract_fileparts.m
%       cd/m3ha_extract_cell_name.m
%       cd/force_column_vector.m
%       cd/istext.m
%       cd/load_params.m
%       cd/m3ha_locate_homedir.m
%       cd/print_cellstr.m
%       cd/save_params.m
%       cd/struct2arglist.m
%       cd/update_param_values.m
%
% Used by:    
%       ~/mh3a/optimizer4gabab/singleneuronfitting42.m and beyond

% File History:
% 2018-10-31 Created by Adam Lu
% 2018-12-11 Added the 'InitValue' column
% 2018-12-11 Made binary arrays logical arrays
% 2019-11-12 Removed T & h channels from passive fit
% 2019-11-19 Added 'ParamsToReplace' as an optional parameter
% 2019-11-19 Added 'CustomInitValues' as an optional parameter
% 2019-11-19 Added 'CustomInitTables' as an optional parameter
% 2019-11-19 Added 'CustomInitFiles' as an optional parameter
% 2019-11-19 Added 'CellNames' as an optional parameter
% 2019-12-19 No longer updates epas from passiveParamsPath
% 2019-12-19 No longer fits epas by default
% TODO: 'MinimalIT', 'MinimalIA', etc.
% 

%% Hard-coded parameters
initialParamsFolderName = 'initial_params';
defaultPassiveFileDir = fullfile('data_dclamp', 'take4');
defaultPassiveFileName = 'dclampPassiveParams_byCells_tofit.xlsx';
curveFitParamNames = {'diamSoma', 'LDend', 'diamDend', 'gpas'};

% Must be consistent with find_passive_params.m
% Default parameter values (most from Destexhe & Neubig 1997)
cmInit = 0.88;          % specific membrane capacitance [uF/cm^2]
RaInit = 173;           % axial resistivity [Ohm-cm]
corrDInit = 1;          % dendritic surface area correction factor
                        %   set to 1 so that curve-fitted parameters
                        %   from find_passive_params.m may be applied directly
                        % Destexhe et al 1998a used 7.954,
                        %   which was estimated by fitting 
                        %   voltage-clamp traces in Destexhe et al 1998a

% Column names for the parameters table
columnNames = {'Value', 'InitValue', 'LowerBound', 'UpperBound', 'Class', ...
                'IsLog', 'IsPassive', 'UseAcrossTrials', 'UseAcrossCells'};

% Default parameter values if initial parameters not provided
neuronParamsDefault = [ ...
    38.42, 84.67, 8.50, ...
    cmInit, RaInit, corrDInit, 2e-5, -70, ...
    .2e-3, .2e-3, .2e-3, ...
    1, 1, 1, 1, ...
    2.2e-5, 2.2e-5, 2.2e-5, -28, 0, ...
    2.0e-5, 2.0e-5, 2.0e-5, ...
    5.5e-3, 5.5e-3, 5.5e-3, ...
    5.5e-6, 5.5e-6, 5.5e-6, ...
    ];

% Names for each parameter
neuronParamNames = { ...
    'diamSoma', 'LDend', 'diamDend', ...
    'cm', 'Ra', 'corrD', 'gpas', 'epas', ...
    'pcabarITSoma', 'pcabarITDend1', 'pcabarITDend2', ...
    'shiftmIT', 'shifthIT', 'slopemIT', 'slopehIT', ...
    'ghbarIhSoma', 'ghbarIhDend1', 'ghbarIhDend2', 'ehIh', 'shiftmIh', ...
    'gkbarIKirSoma', 'gkbarIKirDend1', 'gkbarIKirDend2', ...
    'gkbarIASoma', 'gkbarIADend1', 'gkbarIADend2', ...
    'gnabarINaPSoma', 'gnabarINaPDend1', 'gnabarINaPDend2', ...
    };

% Lower bounds for each parameter
neuronParamsLowerBound = [ ...
    8, 5, 3, ...
    cmInit, RaInit, corrDInit, 1.0e-8, -95, ...
    1.0e-9, 1.0e-9, 1.0e-9, ...
    -30, -30, 0.1, 0.1, ...
    1.0e-9, 1.0e-9, 1.0e-9, -32, -30, ...
    1.0e-9, 1.0e-9, 1.0e-9, ...
    1.0e-9, 1.0e-9, 1.0e-9, ...
    1.0e-9, 1.0e-9, 1.0e-9, ...
    ];

% Upper bounds for each parameter
neuronParamsUpperBound = [ ...
    250, 150, 30, ...
    cmInit, RaInit, corrDInit, 1.0, -45, ...
    1.0e-2, 1.0e-2, 1.0e-2, ...
    30, 30, 10, 10, ...
    1.0e-2, 1.0e-2, 1.0e-2, -24, 30, ...
    1.0e-2, 1.0e-2, 1.0e-2, ...
    1.0e-2, 1.0e-2, 1.0e-2, ...
    1.0e-2, 1.0e-2, 1.0e-2, ...
    ];

% Parameter class for each parameter
neuronParamsClass = [ ...
    1, 1, 1, ...
    2, 2, 2, 3, 3, ...
    4, 4, 4, ...
    4, 4, 4, 4, ...
    5, 5, 5, 5, 5, ...
    6, 6, 6, ...
    7, 7, 7, ...
    8, 8, 8, ...
    ];

% Whether each parameter will be varied log-scaled
neuronParamsIsLog = logical([ ...
    0, 0, 0, ...
    1, 1, 0, 1, 0, ...
    1, 1, 1, ...
    0, 0, 1, 1, ...
    1, 1, 1, 0, 0, ...
    1, 1, 1, ...
    1, 1, 1, ...
    1, 1, 1, ...
    ]);

% Whether the parameter is considered a 'passive' parameter
%   Note: must be consistent with TC3.tem and m3ha_neuron_create_sim_commands.m
neuronParamsIsPassive = logical([ ...
    1, 1, 1, ...
    1, 1, 1, 1, 1, ...
    0, 0, 0, ...
    0, 0, 0, 0, ...
    0, 0, 0, 0, 0, ...
    0, 0, 0, ...
    0, 0, 0, ...
    0, 0, 0, ...
    ]);

% Whether the parameter is varied when fitting across trials for each cell
%   Note: All passive parameters and all active conductance densities
neuronParamsUseAcrossTrials = logical([ ...
    1, 1, 1, ...
    0, 0, 0, 1, 0, ...
    1, 1, 1, ...
    0, 0, 0, 0, ...
    1, 1, 1, 0, 0, ...
    1, 1, 1, ...
    1, 1, 1, ...
    1, 1, 1, ...
    ]);

% Whether the parameter is varied when fitting across cells
%   Note: All active conductance kinetics
neuronParamsUseAcrossCells = logical([ ...
    0, 0, 0, ...
    0, 0, 0, 0, 0, ...
    0, 0, 0, ...
    1, 1, 1, 1, ...
    0, 0, 0, 1, 1, ...
    0, 0, 0, ...
    0, 0, 0, ...
    0, 0, 0, ...
    ]);

%% Default values for optional arguments
passiveFileNameDefault = ['/media/adamX/m3ha/data_dclamp/take4/', ...
                            'dclampPassiveParams_byCells_tofit.xlsx'];
                            % default passive parameters file name
cellNamesDefault = {};              % set later
outFolderDefault = '';              % set later
outPrefixDefault = 'initial_params_';
outSuffixDefault = '';
useCurveFitParamsDefault = true;    % use curve-fitted parameters by default
paramsToReplaceDefault = {};        % set later
customInitNamesDefault = {};        % set later
customInitValuesDefault = {};       % set later
customInitTablesDefault = {};       % set later
customInitFilesDefault = {};        % set later
customInitDirectoryDefault = '';    % set later
minimalActiveChannelsDefault = false;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Deal with arguments
% Set up Input Parser Scheme
iP = inputParser;
iP.FunctionName = mfilename;

% Add parameter-value pairs to the Input Parser
addParameter(iP, 'PassiveFileName', passiveFileNameDefault, ...
    @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
                                                % introduced after R2016b
addParameter(iP, 'CellNames', cellNamesDefault, ...
    @(x) assert(iscellstr(x) || isstring(x), ...
                ['CellNames must be a cell array of character arrays ', ...
                'or a string array!']));
addParameter(iP, 'OutFolder', outFolderDefault, ...
    @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));    
addParameter(iP, 'OutPrefix', outPrefixDefault, ...
    @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));    
addParameter(iP, 'OutSuffix', outSuffixDefault, ...
    @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));    
addParameter(iP, 'UseCurveFitParams', useCurveFitParamsDefault, ...
    @(x) validateattributes(x, {'logical', 'numeric'}, {'binary'}));
addParameter(iP, 'ParamsToReplace', paramsToReplaceDefault, ...
    @(x) assert(iscellstr(x) || isstring(x), ...
                ['ParamsToReplace must be a cell array of character arrays ', ...
                'or a string array!']));
addParameter(iP, 'CustomInitNames', customInitNamesDefault, ...
    @(x) assert(iscellstr(x) || isstring(x) || iscell(x), ...
                ['CustomInitNames must be a cell array of character arrays ', ...
                'or a string array!']));
addParameter(iP, 'CustomInitValues', customInitValuesDefault, ...
    @(x) validateattributes(x, {'cell', 'numeric'}, {'2d'}));    
addParameter(iP, 'CustomInitTables', customInitTablesDefault, ...
    @(x) validateattributes(x, {'cell'}, {'2d'}));    
addParameter(iP, 'CustomInitFiles', customInitFilesDefault, ...
    @(x) assert(iscellstr(x) || isstring(x), ...
                ['CustomInitFiles must be a cell array of character arrays ', ...
                'or a string array!']));
addParameter(iP, 'CustomInitDirectory', customInitDirectoryDefault, ...
    @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));    
addParameter(iP, 'MinimalActiveChannels', minimalActiveChannelsDefault, ...
    @(x) validateattributes(x, {'logical', 'numeric'}, {'binary'}));

% Read from the Input Parser
parse(iP, varargin{:});
passiveFileName = iP.Results.PassiveFileName;
cellNames = iP.Results.CellNames;
outFolder = iP.Results.OutFolder;
outPrefix = iP.Results.OutPrefix;
outSuffix = iP.Results.OutSuffix;
useCurveFitParams = iP.Results.UseCurveFitParams;
paramsToReplace = iP.Results.ParamsToReplace;
customInitNames = iP.Results.CustomInitNames;
customInitValues = iP.Results.CustomInitValues;
customInitTables = iP.Results.CustomInitTables;
customInitFiles = iP.Results.CustomInitFiles;
customInitDirectory = iP.Results.CustomInitDirectory;
minimalActiveChannels = iP.Results.MinimalActiveChannels;

%% Preparation
% Set default output folder
if isempty(outFolder)
    outFolder = fullfile(pwd, initialParamsFolderName);
end

% Set default passive file
if isempty(passiveFileName)
    passiveFileName = fullfile(m3ha_locate_homedir, ...
                        defaultPassiveFileDir, defaultPassiveFileName);
end

% Check if the output folder exists
check_dir(outFolder);

% Determine whether it's necessary to detect custom files
toDetectFiles = ~isempty(customInitDirectory) && isempty(customInitFiles) && ...
                    (isempty(cellNames) || isempty(customInitTables) && ...
                    (isempty(customInitValues) || isempty(customInitNames)));

% Detect custom files if needed
if toDetectFiles
    [~, customInitFiles] = all_files('Directory', customInitDirectory, ...
                                        'Extension', 'csv');
end

% Extract just the file bases
customInitFileBases = extract_fileparts(customInitFiles, 'base');

% Extract the cell names
customCellNames = m3ha_extract_cell_name(customInitFileBases);

% Make sure the custom cell names are all unique
if numel(customCellNames) ~= numel(unique(customCellNames))
    error('Cell names provided are not all unique!')
end

% Determine whether it's necessary to load the parameters tables
toLoadTables = ~isempty(customInitFiles) && isempty(customInitTables) && ...
                (isempty(customInitValues) || isempty(customInitNames));

% Load the parameters tables from the custom files if needed
if toLoadTables
    customInitTables = load_params(customInitFiles);
end

% Determine whether it's necessary to read in parameter names and values
toReadInitValues = ~isempty(customInitTables) && isempty(customInitValues);
toReadInitNames = ~isempty(customInitTables) && isempty(customInitNames);

% Read in custom initial names and values if needed
if toReadInitValues
    % Use the 'Value' column from the custom table
    customInitValues = cellfun(@(x) x.Value, customInitTables, ...
                                'UniformOutput', false);
end
if toReadInitNames
    % Use the row names from the custom tables
    customInitNames = cellfun(@(x) x.Properties.RowNames, customInitTables, ...
                                'UniformOutput', false);
end

% Can't read in parameter names without values
if ~isempty(customInitNames) && isempty(customInitValues)
    error('Custom parameter values must be provided!');
end

% Set default custom initial names if still empty
if isempty(customInitNames) && ~isempty(customInitValues)
    % Count the number of initial values
    nCustomInitValues = count_samples(customInitValues);

    % This number can't be different across cells
    uniqueNInitValues = unique(nCustomInitValues);
    if numel(uniqueNInitValues) > 1
        error('Custom initial parameter names must be provided!');
    end

    % Assume that all NEURON parameters are provided
    % If the number of parameters provided is different, display error
    if numel(neuronParamNames) ~= numel(uniqueNInitValues)
        error('What parameters correspond to the initial values?');
    else
        customInitNames = neuronParamNames;
    end
end

% Set default parameters to replace to be all those provided for the first cell
if isempty(paramsToReplace) && ~isempty(customInitValues)
    if iscell(customInitNames) && istext(customInitNames{1})
        paramsToReplace = customInitNames{1};
    else
        paramsToReplace = customInitNames;
    end
end

% Determine whether to update custom parameters
useCustom = ~isempty(paramsToReplace);

% Display warning if custom parameters contain curve fitted parameters
if useCustom && useCurveFitParams && ...
        any(ismember(curveFitParamNames, paramsToReplace))
    fprintf(['Warning: Some custom parameters will replace ', ...
            'curve-fitted parameters!\n']);
end

% Determine whether to read in passive parameters table
toReadPassive = useCurveFitParams || ...
                    isempty(cellNames) && isempty(customInitFiles);

% Read in the passive parameters table if requested
if toReadPassive
    passiveTable = readtable(passiveFileName);
end

% Decide on cell names
if isempty(cellNames) && ~isempty(customInitFiles)
    % Use the cell names from the custom files
    cellNames = customCellNames;
elseif isempty(cellNames) && isempty(customInitFiles)
    % Extract the cell names from the passive table
    cellNames = passiveTable.cellName;
elseif ~isempty(cellNames) && ~isempty(customInitFiles)
    % Force as a cell array
    if ischar(cellNames)
        cellNames = {cellNames};
    end

    % Restrict to cell names provided
    iCellInCustom = cellfun(@(x) find_in_strings(x, customCellNames, ...
                            'MaxNum', 1, 'ReturnNan', true), cellNames);

    % Check if custom providers for all cells requested are provided
    if any(isnan(iCellInCustom))
        % Get names of all cells without custom values
        cellNamesMissing = cellNames(isnan(iCellInCustom));

        % Display error
        error('These cells are missing custom values: %s', ...
                print_cellstr(cellNamesMissing, 'ToPrint', false));
    end

    % Reorder customInitNames and customInitValues
    %   to match requested cell names
    % customInitFiles = customInitFiles(iCellInCustom);
    % customInitTables = customInitTables(iCellInCustom);
    customInitNames = customInitNames(iCellInCustom);
    customInitValues = customInitValues(iCellInCustom);
else
    % Do nothing
end

% Make sure the cell names are all unique
if numel(cellNames) ~= numel(unique(cellNames))
    error('Cell names provided are not all unique!')
end

% Count the number of cells
nCells = numel(cellNames);

% Match the number of custom initial parameters if provided
if ~isempty(customInitNames) && istext(customInitNames)
    customInitNames = repmat({customInitNames}, [nCells, 1]);
end
if ~isempty(customInitValues) && isnumeric(customInitNames)
    customInitValues = repmat({customInitValues}, [nCells, 1]);
end

%% Create initial parameters table
% Force as column vectors
[neuronParamsDefault, neuronParamsLowerBound, ...
    neuronParamsUpperBound, neuronParamsClass, ...
    neuronParamsIsLog, neuronParamsIsPassive, ...
    neuronParamsUseAcrossTrials, neuronParamsUseAcrossCells] = ...
    argfun(@force_column_vector, ...
            neuronParamsDefault, neuronParamsLowerBound, ...
            neuronParamsUpperBound, neuronParamsClass, ...
            neuronParamsIsLog, neuronParamsIsPassive, ...
            neuronParamsUseAcrossTrials, neuronParamsUseAcrossCells);

% Create the default table
defaultTable = table(neuronParamsDefault, neuronParamsDefault, ...
                neuronParamsLowerBound, neuronParamsUpperBound, ...
                neuronParamsClass, neuronParamsIsLog, neuronParamsIsPassive, ...
                neuronParamsUseAcrossTrials, neuronParamsUseAcrossCells, ...
                'RowNames', neuronParamNames, 'VariableNames', columnNames);

% Repeat for all cells
initParamTables = arrayfun(@(x) defaultTable, transpose(1:nCells), ...
                            'UniformOutput', false);

%% Update passive parameters if needed
if useCurveFitParams
    % Display message
    fprintf('Using curve-fitted passive parameters from %s ... \n', ...
            passiveFileName);

    % Extract the cell names
    cellNameAllCells = passiveTable.cellName;

    % Extract the passive parameters needed
    %   Note: Must be consistent with m3ha_neuron_create_sim_commands.m
    radiusSomaAllCells = passiveTable.radiusSoma;
    diamDendAllCells = passiveTable.diameterDendrite;
    LDendAllCells = passiveTable.lengthDendrite;
    RinAllCells = passiveTable.Rinput;

    % Find the cells of interest in all cell names
    iCellOfInterest = cellfun(@(x) find_in_strings(x, cellNameAllCells, ...
                                'MaxNum', 1), cellNames);

    % Reorder by the cells of interest
    [radiusSoma, diamDend, LDend, Rin] = ...
        argfun(@(x) x(iCellOfInterest), ...
            radiusSomaAllCells, diamDendAllCells, LDendAllCells, RinAllCells);

    % Compute the diameter of the somas
    diamSoma = 2 * radiusSoma;

    % Force as column vectors
    [diamSoma, LDend, diamDend] = ...
        argfun(@force_column_vector, diamSoma, LDend, diamDend);

    % Compute the surface area for each cell
    surfaceArea = compute_surface_area([diamSoma, LDend], ...
                                        [diamSoma, diamDend]);

    % Estimate the passive conductances from the input resistances
    gpas = compute_gpas(Rin, surfaceArea);

    % Create name value pairs for geometric parameters
    nameValuePairsGeom = ...
        arrayfun(@(a, b, c, d) {'diamSoma', a, 'LDend', b, ...
                                    'diamDend', c, 'gpas', d}, ...
                diamSoma, LDend, diamDend, gpas, ...
                'UniformOutput', false);

    % Update the initial parameters table
    initParamTables = ...
        cellfun(@(x, y) update_param_values(x, y{:}), ...
                initParamTables, nameValuePairsGeom, 'UniformOutput', false);
end

%% Update other parameters
if useCustom
    % Display message
    fprintf('Using custom NEURON parameters for all cells ... \n');

    % Create name value pairs for the custom parameters to replace
    nameValuePairsCustom = ...
        cellfun(@(x, y) create_name_value_pairs(x, y, paramsToReplace), ...
                customInitNames, customInitValues, 'UniformOutput', false);

    % Update the initial parameters table
    initParamTables = ...
        cellfun(@(x, y) update_param_values(x, y{:}), ...
                initParamTables, nameValuePairsCustom, 'UniformOutput', false);
end

%% Set all active channel conductances to minimum if requested
if minimalActiveChannels
    % Display message
    fprintf('Setting all active conductances to minimal values ... \n');

    % Create name value pairs for active channel parameters
    nameValuePairsActiveExample = ...
        {'pcabarITSoma', 1e-9, 'pcabarITDend1', 1e-9, 'pcabarITDend2', 1e-9, ...
        'ghbarIhSoma', 1e-9, 'ghbarIhDend1', 1e-9, 'ghbarIhDend2', 1e-9, ...
        'gkbarIKirSoma', 1e-9, 'gkbarIKirDend1', 1e-9, 'gkbarIKirDend2', 1e-9, ...
        'gkbarIASoma', 1e-9, 'gkbarIADend1', 1e-9, 'gkbarIADend2', 1e-9, ...
        'gnabarINaPSoma', 1e-9, 'gnabarINaPDend1', 1e-9, 'gnabarINaPDend2', 1e-9};
    nameValuePairsActive = ...
        repmat({nameValuePairsActiveExample}, size(initParamTables));

    % Update the initial parameters table
    initParamTables = ...
        cellfun(@(x, y) update_param_values(x, y{:}), ...
                initParamTables, nameValuePairsActive, 'UniformOutput', false);    
end

%% Update the initValue column with the value column
valueStr = columnNames{1};
initValueStr = columnNames{2};
initParamTables = cellfun(@(x) copyvars(x, valueStr, initValueStr), ...
                            initParamTables, 'UniformOutput', false);

%% Save outputs
% Construct full paths
initFilePaths = construct_fullpath(cellNames, 'Directory', outFolder, ...
                                    'Prefixes', outPrefix, 'Suffixes', outSuffix, ...
                                    'Extension', 'csv');

% Save as parameter files
initParamFiles = cellfun(@(x, y) save_params(x, 'FileName', y), ...
                            initParamTables, initFilePaths, ...
                            'UniformOutput', false);

%% Return outputs
% Save the passive parameters file name
otherParams.passiveFileName = passiveFileName;
otherParams.defaultTable = defaultTable;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function nameValuePairs = create_name_value_pairs (allNames, allValues, ...
                                                    namesOfInterest)
%% Create name value pairs
% TODO: Pull out to a function create_name_value_pairs.m

% Put allValues in a cell array
valuesCell = num2cell(allValues);

% Combine into a single-row table
tempTable = table(valuesCell{:}, 'VariableNames', allNames);

% Restrict to namesOfInterest
tempTable = tempTable(:, namesOfInterest);

% Transform to structure arrays
tempStruct = table2struct(tempTable);

% Update the parameters to replace 
nameValuePairs = struct2arglist(tempStruct);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
OLD CODE:

%}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
