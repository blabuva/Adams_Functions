function handles = m3ha_plot_simulated_traces (varargin)
%% Plots simulated traces from NEURON output files
% Usage: handles = m3ha_plot_simulated_traces (varargin)
% Explanation:
%       TODO
%
% Example(s):
%       TODO
%
% Outputs:
%       handles     - TODO: Description of handles
%                   specified as a TODO
%
% Arguments:
%       varargin    - 'PlotType': type of plot
%                   must be an unambiguous, case-insensitive match to one of: 
%                       'individual'    - voltage traces on separate subplots
%                       'residual'      - residual traces 
%                                               between simulated and recorded
%                       'overlapped'    - all traces of interest overlapped
%                       'm2h'           - m2h plot
%                   default == 'individual'
%                   - 'BuildMode': TC neuron build mode
%                   must be an unambiguous, case-insensitive match to one of: 
%                       'passive' - inserted leak channels only
%                       'active'  - inserted both passive and active channels
%                   default == detected
%                   - 'SimMode': simulation mode
%                   must be an unambiguous, case-insensitive match to one of: 
%                       'passive' - simulated a current pulse response
%                       'active'  - simulated an IPSC response
%                   default == detected
%                   - 'Directory': the directory to search in
%                   must be a string scalar or a character vector
%                   default == set in all_files.m
%                   - 'FileNames': paths to simulated data
%                   must be a string array or a cell array of character vectors
%                   default == detected from Directory
%                   - 'Extension': data file extension
%                   must be a string scalar or a character vector
%                   default == 'out'
%                   - 'ColorMap': color map
%                   must be TODO
%                   default == TODO
%                   - 'XLimits': limits of x axis
%                               suppress by setting value to 'suppress'
%                   must be 'suppress' or a 2-element increasing numeric vector
%                   default == no restrictions
%                   - 'OutFolder': the directory where outputs will be placed
%                   must be a string scalar or a character vector
%                   default == same as Directory
%                   - 'ExpStr': experiment string file names
%                   must be a character array
%                   default == extract_common_prefix(fileNames)
%                   - 'tVecs': time vectors to match
%                   must be a numeric array or a cell array of numeric arrays
%                   default == [] (none provided)
%                   - 'vVecsRec': recorded voltage vectors
%                   must be a numeric array or a cell array of numeric arrays
%                   default == [] (none provided)
%                   - 'iVecsRec': recorded current vectors
%                   must be a numeric array or a cell array of numeric arrays
%                   default == [] (none provided)
%                   - 'gVecsRec': recorded conductance vectors
%                   must be a numeric array or a cell array of numeric arrays
%                   default == [] (none provided)
%                   - 'Residuals': voltage residuals
%                   must be a numeric array or a cell array of numeric arrays
%                   default == [] (none provided)
%                   - 'LineWidth': line width of plots
%                   must be empty or a positive scalar
%                   default == TODO
%                   - Any other parameter-value pair for plot_traces()
%
% Requires:
%       cd/all_files.m
%       cd/argfun.m
%       cd/construct_fullpath.m
%       cd/decide_on_colormap.m
%       cd/extract_columns.m
%       cd/extract_common_prefix.m
%       cd/isemptycell.m
%       cd/read_neuron_outputs.m
%       cd/m3ha_extract_sweep_name.m
%       cd/m3ha_import_raw_traces.m
%       cd/plot_traces.m
%       cd/read_lines_from_file.m
%
% Used by:
%       cd/m3ha_plot_figure03.m
%       cd/m3ha_plot_figure05.m

% File History:
% 2019-10-14 Created by Adam Lu
% 2019-12-22 Added 'PlotType' as an optional argument
% 2019-12-29 Added 'allvoltages', 'allcurrents', 'allITproperties', 
%               and 'dend2ITproperties' 

%% Hard-coded parameters
validPlotTypes = {'individual', 'residual', 'overlapped', ...
                    'allvoltages', 'allcurrents', 'allITproperties', ...
                    'dend2ITproperties', 'm2h'};
validBuildModes = {'', 'active', 'passive'};
validSimModes = {'', 'active', 'passive'};
maxRowsWithOneOnly = 8;
lineWidthParallel = 1;
lineWidthIndividual = 0.5;

% Note: The following must be consistent with m3ha_neuron_run_and_analyze.m
importedSuffix = 'imported_files';

% Note: The following must be consistent with singleneuron4compgabab.hoc
timeToStabilize = 2000;         % padded time (ms) to make sure initial value 
                                %   of simulations are stabilized

%% Column numbers for recorded data
%   Note: Must be consistent with m3ha_resave_sweeps.m
TIME_COL_REC = 1;
VOLT_COL_REC = 2;
CURR_COL_REC = 3;
COND_COL_REC = 4;

% Column numbers for simulated data
%   Note: Must be consistent with singleneuron4compgabab.hoc
TIME_COL_SIM = 1;
VOLT_COL_SIM = 2;
DEND1_COL_SIM = 3;
DEND2_COL_SIM = 4;
IDCLAMP_COL_SIM = 5;
GGABAB_COL_SIM = 6;
iCP_COL_SIM = 7;
IEXT_COL_SIM = 8;

%% Default values for optional arguments
plotTypeDefault = 'individual';
buildModeDefault = '';          % set later
simModeDefault = '';            % set later
directoryDefault = '';          % set in all_files.m
fileNamesDefault = {};
extensionDefault = 'out';       % 
colorMapDefault = [];
xLimitsDefault = [];          % set later
outFolderDefault = '';          % set later
expStrDefault = '';             % set later
tVecsDefault = [];
vVecsRecDefault = [];
iVecsRecDefault = [];
gVecsRecDefault = [];
residualsDefault = [];
lineWidthDefault = [];      % set later

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Deal with arguments
% Set up Input Parser Scheme
iP = inputParser;
iP.FunctionName = mfilename;
iP.KeepUnmatched = true;                        % allow extraneous options

% Add parameter-value pairs to the Input Parser
addParameter(iP, 'PlotType', plotTypeDefault, ...
    @(x) any(validatestring(x, validPlotTypes)));
addParameter(iP, 'BuildMode', buildModeDefault, ...
    @(x) any(validatestring(x, validBuildModes)));
addParameter(iP, 'SimMode', simModeDefault, ...
    @(x) any(validatestring(x, validSimModes)));
addParameter(iP, 'Directory', directoryDefault, ...
    @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
addParameter(iP, 'FileNames', fileNamesDefault, ...
    @(x) assert(ischar(x) || iscellstr(x) || isstring(x), ...
        ['fileNames must be a character array or a string array ', ...
            'or cell array of character arrays!']));
addParameter(iP, 'Extension', extensionDefault, ...
    @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
addParameter(iP, 'ColorMap', colorMapDefault);
addParameter(iP, 'XLimits', xLimitsDefault, ...
    @(x) isempty(x) || iscell(x) || ischar(x) && strcmpi(x, 'suppress') || ...
        isnumeric(x) && isvector(x) && length(x) == 2);
addParameter(iP, 'OutFolder', outFolderDefault, ...
    @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
addParameter(iP, 'ExpStr', expStrDefault, ...
    @(x) validateattributes(x, {'char', 'string'}, {'scalartext'}));
addParameter(iP, 'tVecs', tVecsDefault, ...
    @(x) assert(isempty(x) || isnumeric(x) || iscellnumeric(x), ...
                ['tVecs must be either a numeric array', ...
                    'or a cell array of numeric arrays!']));
addParameter(iP, 'vVecsRec', vVecsRecDefault, ...
    @(x) assert(isempty(x) || isnumeric(x) || iscellnumeric(x), ...
                ['vVecsRec must be either a numeric array', ...
                    'or a cell array of numeric arrays!']));
addParameter(iP, 'iVecsRec', iVecsRecDefault, ...
    @(x) assert(isempty(x) || isnumeric(x) || iscellnumeric(x), ...
                ['iVecsRec must be either a numeric array', ...
                    'or a cell array of numeric arrays!']));
addParameter(iP, 'gVecsRec', gVecsRecDefault, ...
    @(x) assert(isempty(x) || isnumeric(x) || iscellnumeric(x), ...
                ['gVecsRec must be either a numeric array', ...
                    'or a cell array of numeric arrays!']));
addParameter(iP, 'Residuals', residualsDefault, ...
    @(x) assert(isempty(x) || isnumeric(x) || iscellnumeric(x), ...
                ['Residuals must be either a numeric array', ...
                    'or a cell array of numeric arrays!']));
addParameter(iP, 'LineWidth', lineWidthDefault, ...
    @(x) validateattributes(x, {'numeric'}, {'scalar', 'positive'}));

% Read from the Input Parser
parse(iP, varargin{:});
plotType = validatestring(iP.Results.PlotType, validPlotTypes);
buildMode = validatestring(iP.Results.BuildMode, validBuildModes);
simMode = validatestring(iP.Results.SimMode, validSimModes);
directory = iP.Results.Directory;
fileNames = iP.Results.FileNames;
extension = iP.Results.Extension;
colorMap = iP.Results.ColorMap;
xLimits = iP.Results.XLimits;
outFolder = iP.Results.OutFolder;
expStr = iP.Results.ExpStr;
tVecs = iP.Results.tVecs;
vVecsRec = iP.Results.vVecsRec;
iVecsRec = iP.Results.iVecsRec;
gVecsRec = iP.Results.gVecsRec;
residuals = iP.Results.Residuals;
lineWidth = iP.Results.LineWidth;

% Keep unmatched arguments for the plot_traces() function
otherArguments = iP.Unmatched;

%% Preparation
% Use the present working directory for both inputs and output by default
if isempty(directory)
    directory = pwd;
end

% Set default output directory
if isempty(outFolder)
    outFolder = directory;
end

% Decide on input paths
if isempty(fileNames)
    [~, fileNames] = ...
        all_files('Directory', directory, 'Extension', extensionDefault, ...
                    'Keyword', 'sim', 'ForceCellOutput', true);
else
    % Make sure they are full paths
    fileNames = construct_fullpath(fileNames, 'Directory', directory);
end

% Reorder the input paths correctly
fileNames = reorder_simulation_output_files(fileNames);

% Use the common expStr as the experiment string
if isempty(expStr)
    expStr = extract_common_prefix(fileNames);
end

% Decide on the build mode
% TODO: Detect from output structure instead
if isempty(buildMode)
    if all(contains(fileNames, 'cpr'))
        buildMode = 'passive';
    else
        buildMode = 'active';
    end
end

% Decide on the simulation mode
% TODO: Detect from output structure instead
if isempty(simMode)
    if all(contains(fileNames, 'cpr'))
        simMode = 'passive';
    else
        simMode = 'active';
    end
end

% Create an experiment identifier for title
expStrForTitle = replace(expStr, '_', '\_');

% Decide on xLimits
if isempty(xLimits)
    if strcmp(simMode, 'active')
        xLimits = [2800, 4500];
    else
        xLimits = [timeToStabilize, Inf];
    end
end

% Count the number of files
nFiles = numel(fileNames);

% Decide on nRows
nRows = decide_on_nrows(nFiles, simMode, maxRowsWithOneOnly);

% Decide on the color map if not provided
if isempty(colorMap)
    switch plotType
        case {'individual', 'residual'}
            % Decide on the color map for individual and residual plots
            colorMap = decide_on_colormap('r', nRows);
        case {'overlapped', 'allvoltages', 'allcurrents', ...
                'allITproperties', 'dend2ITproperties', 'm2h'}
            % Decide on the colors for parallel plots
            colorMap = decide_on_colormap([], 4);
            if nFiles > nRows
                nColumns = ceil(nFiles / nRows);
                nSlots = nColumns * nRows;
                colorMap = reshape(repmat(reshape(colorMap, 1, []), ...
                                    nColumns, 1), nSlots, 3);
            end
        otherwise
            % Decide on the colors for each row in the plots
            colorMap = decide_on_colormap(colorMap, nFiles);
    end
end

% Decide on the plot line width
if isempty(lineWidth)
    switch plotType
        case {'individual', 'residual'}
            lineWidth = lineWidthIndividual;
        case {'overlapped', 'allvoltages', 'allcurrents', ...
                'allITproperties', 'dend2ITproperties', 'm2h'}
            lineWidth = lineWidthParallel;
        otherwise
            error('plotType unrecognized!');
    end
end

%% Data
% Look for the imported files log
[~, importedPath] = all_files('Directory', directory, 'Prefix', expStr, ...
                                'Suffix', importedSuffix, 'MaxNum', 1);

% Look for matching recorded sweep names
if ~isempty(importedPath)
    % Extract sweep names
    sweepNames = read_lines_from_file(importedPath);

    % TODO: Reorder simulated fileNames to match recorded ones
else
    sweepNames = m3ha_extract_sweep_name(fileNames);
end

% Import and extract from recorded data
if ~all(isemptycell(sweepNames))
    % Import recorded traces
    realData = m3ha_import_raw_traces(sweepNames, 'ImportMode', simMode, ...
                                    'Verbose', true, 'OutFolder', outFolder);

    % Extract vectors from recorded data
    %   Note: these will be empty if realData not provided
    [tVecs, vVecsRec, iVecsRec, gVecsRec] = ...
        extract_columns(realData, [TIME_COL_REC, VOLT_COL_REC, ...
                                    CURR_COL_REC, COND_COL_REC]);
end

% Load simulated data
% If recorded data provided (tVecs not empty at this point),
%   interpolate simulated data to match the time points of recorded data
% Note: This is necessary because CVODE (variable time step method) 
%       is applied in NEURON
simData = read_neuron_outputs('FileNames', fileNames, 'tVecs', tVecs);

% Extract vectors from simulated data
[tVecs, vVecsSim, gCmdSim, iExtSim, vVecsDend1, vVecsDend2] = ...
    extract_columns(simData, [TIME_COL_SIM, VOLT_COL_SIM, ...
                    GGABAB_COL_SIM, IEXT_COL_SIM, ...
                    DEND1_COL_SIM, DEND2_COL_SIM]);

%% Plots
% Plot according to plot type
switch plotType
    case 'individual'
        handles = m3ha_plot_individual_traces(tVecs, vVecsSim, vVecsRec, ...
                                    simMode, xLimits, colorMap, lineWidth, ...
                                    expStr, expStrForTitle, otherArguments);
    case 'residual'
        handles = m3ha_plot_residual_traces(tVecs, vVecsSim, vVecsRec, ...
                                    residuals, xLimits, colorMap, lineWidth, ...
                                    expStr, expStrForTitle, otherArguments);
    case {'overlapped', 'allvoltages', 'allcurrents', ...
            'allITproperties', 'dend2ITproperties'}
        handles = m3ha_plot_overlapped_traces(simData, vVecsRec, ...
                                    plotType, buildMode, ...
                                    xLimits, colorMap, lineWidth, ...
                                    expStr, expStrForTitle, otherArguments);
    case 'm2h'
        handles = m3ha_plot_m2h(simData, buildMode, ...
                                    xLimits, colorMap, lineWidth, ...
                                    expStr, expStrForTitle, otherArguments);
    otherwise
        error('plotType unrecognized!');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function fileNames = reorder_simulation_output_files(fileNames)

% Return if there is only one file name
if ischar(fileNames) || numel(fileNames) == 1
    return
end

% Extract the simulation number strings with 'sim'
simStrs = extract_substrings(fileNames, 'Regexp', 'sim[\d]*');

% Extract the simulation numbers (still in string form)
simNumStrs = extractAfter(simStrs, 'sim');

% Convert numeric strings to numbers
simNums = str2double(simNumStrs);

% Sort the numbers
[~, origIndex] = sort(simNums);

% Reorder the file names
fileNames = fileNames(origIndex);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function nRows = decide_on_nrows(nFiles, simMode, maxRowsWithOneOnly)
%% Decide on the number of rows

% Decide on the number of rows
if mod(nFiles, 4) == 0 && strcmp(simMode, 'active')
    nRows = 4;
elseif nFiles <= 3 && strcmp(simMode, 'passive')
    nRows = 3;
elseif nFiles <= maxRowsWithOneOnly
    nRows = nFiles;
else
    nRows = floor(sqrt(nFiles));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function handles = m3ha_plot_individual_traces(tVecs, vVecsSim, vVecsRec, ...
                                    simMode, xLimits, colorMap, lineWidth, ...
                                    expStr, expStrForTitle, otherArguments)

% TODO
plotSwpWeightsFlag = false;

%% Preparation
% Decide on figure title
figTitle = sprintf('All traces for Experiment %s', expStrForTitle);

% Decide on the axes to be linked
if strcmp(simMode, 'passive')
    linkAxesOption = 'x';
else
    linkAxesOption = 'xy';
end

% Find the indices of the x-axis limit endpoints
endPointsForPlots = find_window_endpoints(xLimits, tVecs);

% Prepare vectors for plotting
[tVecs, vVecsSim, vVecsRec] = ...
    argfun(@(x) prepare_for_plotting(x, endPointsForPlots), ...
            tVecs, vVecsSim, vVecsRec);

%% Do the job
% Print to standard output
fprintf('Plotting figure of individual voltage traces for %s ...\n', expStr);

% Plot the individual traces
handles = plot_fitted_traces(tVecs, vVecsSim, 'ToAnnotate', false, ...
            'DataToCompare', vVecsRec, 'PlotMode', 'parallel', ...
            'SubplotOrder', 'bycolor', 'ColorMode', 'byRow', ...
            'ColorMap', colorMap, 'XLimits', xLimits, ...
            'LineWidth', lineWidth, 'LinkAxesOption', linkAxesOption, ...
            'FigTitle', figTitle, 'PlotSwpWeightsFlag', plotSwpWeightsFlag, ...
            otherArguments);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function handles = m3ha_plot_residual_traces(tVecs, vVecsSim, vVecsRec, ...
                                    residuals, xLimits, colorMap, lineWidth, ...
                                    expStr, expStrForTitle, otherArguments)

% TODO
plotSwpWeightsFlag = false;

%% Preparation
% Calculate voltage residuals (simulated - recorded) if necessary
if isempty(residuals) && ~isempty(vVecsRec)
    residuals = compute_residuals(vVecsSim, vVecsRec);
end

% Decide on figure title
figTitle = sprintf('Residuals for Experiment %s', expStrForTitle);

% Find the indices of the x-axis limit endpoints
endPointsForPlots = find_window_endpoints(xLimits, tVecs);

% Prepare vectors for plotting
[tVecs, residuals] = ...
    argfun(@(x) prepare_for_plotting(x, endPointsForPlots), ...
            tVecs, residuals);

%% Do the job
% Print to standard output
fprintf('Plotting figure of residual traces for %s ...\n', expStr);

% Plot the individual traces
handles = plot_fitted_traces(tVecs, residuals, 'ToAnnotate', false, ...
            'PlotMode', 'residuals', ...
            'SubplotOrder', 'bycolor', 'ColorMode', 'byRow', ...
            'ColorMap', colorMap, 'XLimits', xLimits, ...
            'LineWidth', lineWidth, 'LinkAxesOption', 'xy', ...
            'FigTitle', figTitle, 'PlotSwpWeightsFlag', plotSwpWeightsFlag, ...
            otherArguments);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function handles = m3ha_plot_overlapped_traces (simData, vVecsRec, ...
                                        plotType, buildMode, ...
                                        xLimits, colorMap, lineWidth, ...
                                        expStr, expStrForTitle, otherArguments)

%% Hard-coded parameters
% Column numbers for simulated data
%   Note: Must be consistent with singleneuron4compgabab.hoc
TIME_COL_SIM = 1;
VOLT_COL_SIM = 2;
DEND1_COL_SIM = 3;
DEND2_COL_SIM = 4;
IDCLAMP_COL_SIM = 5;
GGABAB_COL_SIM = 6;
iCP_COL_SIM = 7;
IEXT_COL_SIM = 8;

IT_SOMA = 9;
IT_M_SOMA = 10;
IT_MINF_SOMA = 11;
IT_H_SOMA = 12;
IT_HINF_SOMA = 13;
IH_SOMA = 14;
IH_M_SOMA = 15;
IA_SOMA = 16;
IA_M1_SOMA = 17;
IA_H1_SOMA = 18;
IA_M2_SOMA = 19;
IA_H2_SOMA = 20;
IKIR_SOMA = 21;
IKIR_M_SOMA = 22;
INAP_SOMA = 23;
INAP_M_SOMA = 24;
INAP_H_SOMA = 25;

IT_DEND1 = 26;
IT_M_DEND1 = 27;
IT_MINF_DEND1 = 28;
IT_H_DEND1 = 29;
IT_HINF_DEND1 = 30;
IH_DEND1 = 31;
IH_M_DEND1 = 32;
IA_DEND1 = 33;
IA_M1_DEND1 = 34;
IA_H1_DEND1 = 35;
IA_M2_DEND1 = 36;
IA_H2_DEND1 = 37;
IKIR_DEND1 = 38;
IKIR_M_DEND1 = 39;
INAP_DEND1 = 40;
INAP_M_DEND1 = 41;
INAP_H_DEND1 = 42;

IT_DEND2 = 43;
IT_M_DEND2 = 44;
IT_MINF_DEND2 = 45;
IT_H_DEND2 = 46;
IT_HINF_DEND2 = 47;
IH_DEND2 = 48;
IH_M_DEND2 = 49;
IA_DEND2 = 50;
IA_M1_DEND2 = 51;
IA_H1_DEND2 = 52;
IA_M2_DEND2 = 53;
IA_H2_DEND2 = 54;
IKIR_DEND2 = 55;
IKIR_M_DEND2 = 56;
INAP_DEND2 = 57;
INAP_M_DEND2 = 58;
INAP_H_DEND2 = 59;

%% Preparation
% Initialize handles
handles = struct;

% Extract vectors from simulated data
%   Note: these are arrays with 25 columns
if strcmpi(buildMode, 'passive')
    [tVecs, vVecsSim, iExtSim, vVecsDend1, vVecsDend2] = ...
        extract_columns(simData, [TIME_COL_SIM, VOLT_COL_SIM, ...
                        IEXT_COL_SIM, DEND1_COL_SIM, DEND2_COL_SIM]);
elseif strcmpi(buildMode, 'active')
    [tVecs, vVecsSim, vVecsDend1, ...
            vVecsDend2, gCmdSim, iExtSim, ...
            itSoma, itmSoma, itminfSoma, ithSoma, ithinfSoma, ...
            ihSoma, ihmSoma, ikirSoma, ikirmSoma, ...
            iaSoma, iam1Soma, iah1Soma, iam2Soma, iah2Soma, ...
            inapSoma, inapmSoma, inaphSoma, ...
            itDend1, itmDend1, itminfDend1, ithDend1, ithinfDend1, ...
            ihDend1, ihmDend1, ikirDend1, ikirmDend1, ...
            iaDend1, iam1Dend1, iah1Dend1, iam2Dend1, iah2Dend1, ...
            inapDend1, inapmDend1, inaphDend1, ...
            itDend2, itmDend2, itminfDend2, ithDend2, ithinfDend2, ...
            ihDend2, ihmDend2, ikirDend2, ikirmDend2, ...
            iaDend2, iam1Dend2, iah1Dend2, iam2Dend2, iah2Dend2, ...
            inapDend2, inapmDend2, inaphDend2] = ...
        extract_columns(simData, ...
            [TIME_COL_SIM, VOLT_COL_SIM, DEND1_COL_SIM, ...
            DEND2_COL_SIM, GGABAB_COL_SIM, IEXT_COL_SIM, ...
            IT_SOMA, IT_M_SOMA, IT_MINF_SOMA, IT_H_SOMA, IT_HINF_SOMA, ...
            IH_SOMA, IH_M_SOMA, IKIR_SOMA, IKIR_M_SOMA, ...
            IA_SOMA, IA_M1_SOMA, IA_H1_SOMA, IA_M2_SOMA, IA_H2_SOMA, ...
            INAP_SOMA, INAP_M_SOMA, INAP_H_SOMA, ...
            IT_DEND1, IT_M_DEND1, IT_MINF_DEND1, IT_H_DEND1, IT_HINF_DEND1, ...
            IH_DEND1, IH_M_DEND1, IKIR_DEND1, IKIR_M_DEND1, ...
            IA_DEND1, IA_M1_DEND1, IA_H1_DEND1, IA_M2_DEND1, IA_H2_DEND1, ...
            INAP_DEND1, INAP_M_DEND1, INAP_H_DEND1, ...
            IT_DEND2, IT_M_DEND2, IT_MINF_DEND2, IT_H_DEND2, IT_HINF_DEND2, ...
            IH_DEND2, IH_M_DEND2, IKIR_DEND2, IKIR_M_DEND2, ...
            IA_DEND2, IA_M1_DEND2, IA_H1_DEND2, IA_M2_DEND2, IA_H2_DEND2, ...
            INAP_DEND2, INAP_M_DEND2, INAP_H_DEND2]);
end

% Combine currents
sum_across_cells = ...
    @(x, y, z) cellfun(@(a, b, c) a + b + c, x, y, z, 'UniformOutput', false);
itTotal = sum_across_cells(itSoma, itDend1, itDend2);
ihTotal = sum_across_cells(ihSoma, ihDend1, ihDend2);
iaTotal = sum_across_cells(iaSoma, iaDend1, iaDend2);
ikirTotal = sum_across_cells(ikirSoma, ikirDend1, ikirDend2);
inapTotal = sum_across_cells(inapSoma, inapDend1, inapDend2);

iIntTotal = cellfun(@(a, b, c, d, e) a + b + c + d + e, ...
                itTotal, ihTotal, iaTotal, ikirTotal, inapTotal, ...
                'UniformOutput', false);

% Find the indices of the x-axis limit endpoints
endPointsForPlots = find_window_endpoints(xLimits, tVecs);

% Prepare vectors for plotting
if strcmpi(buildMode, 'passive')
    [tVecs, vVecsRec, vVecsSim, vVecsDend1, vVecsDend2, iExtSim] = ...
        argfun(@(x) prepare_for_plotting(x, endPointsForPlots), ...
                tVecs, vVecsRec, vVecsSim, vVecsDend1, vVecsDend2, iExtSim);
elseif strcmpi(buildMode, 'active')
    [tVecs, vVecsRec, vVecsSim, vVecsDend1, ...
            vVecsDend2, gCmdSim, iExtSim, iIntTotal, ...
            itTotal, ihTotal, iaTotal, ikirTotal, inapTotal, ...
            itSoma, itmSoma, itminfSoma, ithSoma, ithinfSoma, ...
            ihSoma, ihmSoma, ikirSoma, ikirmSoma, ...
            iaSoma, iam1Soma, iah1Soma, iam2Soma, iah2Soma, ...
            inapSoma, inapmSoma, inaphSoma, ...
            itDend1, itmDend1, itminfDend1, ithDend1, ithinfDend1, ...
            ihDend1, ihmDend1, ikirDend1, ikirmDend1, ...
            iaDend1, iam1Dend1, iah1Dend1, iam2Dend1, iah2Dend1, ...
            inapDend1, inapmDend1, inaphDend1, ...
            itDend2, itmDend2, itminfDend2, ithDend2, ithinfDend2, ...
            ihDend2, ihmDend2, ikirDend2, ikirmDend2, ...
            iaDend2, iam1Dend2, iah1Dend2, iam2Dend2, iah2Dend2, ...
            inapDend2, inapmDend2, inaphDend2] = ...
        argfun(@(x) prepare_for_plotting(x, endPointsForPlots), ...
                tVecs, vVecsRec, vVecsSim, vVecsDend1, ...
                vVecsDend2, gCmdSim, iExtSim, iIntTotal, ...
                itTotal, ihTotal, iaTotal, ikirTotal, inapTotal, ...
                itSoma, itmSoma, itminfSoma, ithSoma, ithinfSoma, ...
                ihSoma, ihmSoma, ikirSoma, ikirmSoma, ...
                iaSoma, iam1Soma, iah1Soma, iam2Soma, iah2Soma, ...
                inapSoma, inapmSoma, inaphSoma, ...
                itDend1, itmDend1, itminfDend1, ithDend1, ithinfDend1, ...
                ihDend1, ihmDend1, ikirDend1, ikirmDend1, ...
                iaDend1, iam1Dend1, iah1Dend1, iam2Dend1, iah2Dend1, ...
                inapDend1, inapmDend1, inaphDend1, ...
                itDend2, itmDend2, itminfDend2, ithDend2, ithinfDend2, ...
                ihDend2, ihmDend2, ikirDend2, ikirmDend2, ...
                iaDend2, iam1Dend2, iah1Dend2, iam2Dend2, iah2Dend2, ...
                inapDend2, inapmDend2, inaphDend2);
end

% List all possible items to plot
if strcmpi(buildMode, 'passive')
    vecsAll = {vVecsRec; vVecsSim; vVecsDend1; vVecsDend2; iExtSim}
else
    vecsAll = {vVecsRec; vVecsSim; vVecsDend1; ...
                vVecsDend2; iExtSim; gCmdSim; ...
                itTotal; ihTotal; iaTotal; ikirTotal; inapTotal; ...
                itSoma; itDend1; itDend2; ...
                itmSoma; itminfSoma; ithSoma; ithinfSoma; ...
                itmDend1; itminfDend1; ithDend1; ithinfDend1; ...
                itmDend2; itminfDend2; ithDend2; ithinfDend2};
end

% List corresponding labels
if strcmpi(buildMode, 'passive')
    labelsAll = {'V_{rec} (mV)'; 'V_{soma} (mV)'; 'V_{dend1} (mV)'; ...
                'V_{dend2} (mV)'; 'I_{stim} (nA)'};
else
    labelsAll = {'V_{rec} (mV)'; 'V_{soma} (mV)'; 'V_{dend1} (mV)'; ...
                'V_{dend2} (mV)'; 'I_{stim} (nA)'; 'g_{GABA_B} (uS)'; ...
                'I_{T} (mA/cm^2)'; 'I_{h} (mA/cm^2)'; 'I_{A} (mA/cm^2)'; ...
                'I_{Kir} (mA/cm^2)'; 'I_{NaP} (mA/cm^2)'; ...
                'I_{T,soma} (mA/cm^2)'; 'I_{T,dend1} (mA/cm^2)'; ...
                'I_{T,dend2} (mA/cm^2)'; ...
                'm_{T,soma}'; 'm_{\infty,T,soma}'; ...
                'h_{T,soma}'; 'h_{\infty,T,soma}'; ...
                'm_{T,dend1}'; 'm_{\infty,T,dend1}'; ...
                'h_{T,dend1}'; 'h_{\infty,T,dend1}'; ...
                'm_{T,dend2}'; 'm_{\infty,T,dend2}'; ...
                'h_{T,dend2}'; 'h_{\infty,T,dend2}'};
end

% Select data to plot
if strcmpi(buildMode, 'passive')
    switch plotType
        case {'overlapped', 'allvoltages'}
            if ~isempty(vVecsRec)
                indToPlot = 1:numel(vecsAll);
            else
                indToPlot = 2:numel(vecsAll);
            end
        case {'allcurrents', 'allITproperties', 'dend2ITproperties'}
            fprintf(['No currents or channel properties are ', ...
                        'saved in passive sim mode!\n']);
            return
        otherwise
            error('plotType unrecognized!');
    end
else
    switch plotType
        case 'overlapped'
            if ~isempty(vVecsRec)
                indToPlot = 1:numel(vecsAll);
            else
                indToPlot = 2:numel(vecsAll);
            end
        case 'allvoltages'
            if ~isempty(vVecsRec)
                indToPlot = 1:6;
            else
                indToPlot = 2:6;
            end
        case 'allcurrents'
            indToPlot = 7:14;
        case 'allITproperties'
            indToPlot = 15:26;
        case 'dend2ITproperties'
            indToPlot = 23:26;
        otherwise
            error('plotType unrecognized!');
    end
end

% Extract data to plot
[dataForOverlapped, yLabelsOverlapped] = ...
    argfun(@(x) x(indToPlot), vecsAll, labelsAll);

% Construct matching time vectors
tVecsForOverlapped = repmat({tVecs}, size(dataForOverlapped));

% Decide on figure title and file name
figTitle = sprintf('Simulated traces for Experiment %s', expStrForTitle);

%% Plots
% Print to standard output
fprintf('Plotting figure of overlapped traces for %s ...\n', expStr);

% Plot overlapped traces
handles = plot_traces(tVecsForOverlapped, dataForOverlapped, ...
                    'Verbose', false, 'PlotMode', 'parallel', ...
                    'SubplotOrder', 'list', 'ColorMode', 'byTraceInPlot', ...
                    'LegendLocation', 'suppress', ...
                    'ColorMap', colorMap, 'XLimits', xLimits, ...
                    'LinkAxesOption', 'x', 'XUnits', 'ms', ...
                    'YLabel', yLabelsOverlapped, ...
                    'FigTitle', figTitle, 'LineWidth', lineWidth, ...
                    otherArguments);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function handles = m3ha_plot_m2h (simData, buildMode, ...
                                    xLimits, colorMap, lineWidth, ...
                                    expStr, expStrForTitle, otherArguments)

%% Hard-coded parameters
% Column numbers for simulated data
%   Note: Must be consistent with singleneuron4compgabab.hoc
TIME_COL_SIM = 1;
% IT_M_SOMA = 10;
% IT_MINF_SOMA = 11;
% IT_H_SOMA = 12;
% IT_HINF_SOMA = 13;
IT_M_DEND2 = 44;
IT_MINF_DEND2 = 45;
IT_H_DEND2 = 46;
IT_HINF_DEND2 = 47;

% Only do this for active mode
if strcmpi(buildMode, 'passive')
    handles = struct;
    return
end

%% Process data
% Extract vectors from simulated data
%   Note: these are arrays with 25 columns
[tVecs, itmVecsSim, itminfVecsSim, ithVecsSim, ithinfVecsSim] = ...
    extract_columns(simData, [TIME_COL_SIM, IT_M_DEND2, IT_MINF_DEND2, ...
                    IT_H_DEND2, IT_HINF_DEND2]);
    % extract_columns(simData, [TIME_COL_SIM, IT_M_SOMA, IT_MINF_SOMA, ...
    %                 IT_H_SOMA, IT_HINF_SOMA]);

% Find the indices of the x-axis limit endpoints
endPointsForPlots = find_window_endpoints(xLimits, tVecs);

% Prepare vectors for plotting
[tVecs, itmVecsSim, itminfVecsSim, ithVecsSim, ithinfVecsSim] = ...
    argfun(@(x) prepare_for_plotting(x, endPointsForPlots), ...
            tVecs, itmVecsSim, itminfVecsSim, ithVecsSim, ithinfVecsSim);

% Compute m2h
itm2hVecsSim = (itmVecsSim .^ 2) .* ithVecsSim;
itminf2hinfVecsSim = (itminfVecsSim .^ 2) .* ithinfVecsSim;

% Decide on figure title and file name
figTitle = sprintf('m2h in dend2 for Experiment %s', expStrForTitle);

%% Plots
% Print to standard output
fprintf('Plotting figure of m2h for %s ...\n', expStr);

handlesInstantaneous = ...
    plot_traces(tVecs, itm2hVecsSim, ...
                'LineStyle', '-', 'LineWidth', lineWidth, ...
                'Verbose', false, 'PlotMode', 'overlapped', ...
                'LegendLocation', 'suppress', ...
                'ColorMap', colorMap, 'XLimits', xLimits, ...
                'LinkAxesOption', 'x', 'XUnits', 'ms', ...
                'YLabel', 'm^2h', 'FigTitle', figTitle, otherArguments);
hold on;
handlesSteadyState = ...
    plot_traces(tVecs, itminf2hinfVecsSim, 'PlotOnly', true, ...
                'LineStyle', '--', 'LineWidth', lineWidth, ...
                'Verbose', false, 'PlotMode', 'overlapped', ...
                'ColorMap', colorMap, 'XLimits', xLimits, otherArguments);

set(gca, 'YLim', [1e-6, 1]);
set(gca, 'YScale', 'log');

handles.handlesInstantaneous = handlesInstantaneous;
handles.handlesSteadyState = handlesSteadyState;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function vecs = prepare_for_plotting(vecs, endPointsForPlots)
%% Prepare vectors for plotting

% Restrict vectors to xLimits to save time on plotting
vecs = extract_subvectors(vecs, 'Endpoints', endPointsForPlots);

% Combine vectors into matrices
vecs = force_matrix(vecs, 'AlignMethod', 'leftAdjustPad');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
OLD CODE:

dataForOverlapped = {vVecsSim; gCmdSim; iExtSim; ...
        icaVecsSim; itm2hVecsSim; itminf2hinfVecsSim; ...
        itmVecsSim; itminfVecsSim; ithVecsSim; ithinfVecsSim; ...
        ihVecsSim; ihmVecsSim; ...
        ikaVecsSim; iam1VecsSim; iah1VecsSim; ...
        iam2VecsSim; iah2VecsSim; ikkirVecsSim; ikirmVecsSim; ...
        inapnaVecsSim; inapmVecsSim; inaphVecsSim};
yLabelsOverlapped = {'V_{soma} (mV)'; 'g_{GABA_B} (uS)'; ...
        'I_{stim} (nA)'; 'I_{Ca} (mA/cm^2)'; ...
        'm^2h_{T}'; 'm_{\infty}^2h_{\infty,T}'; ...
        'm_{T}'; 'm_{\infty,T}'; 'h_{T}'; 'h_{\infty,T}'; ...
        'I_{h} (mA/cm^2)'; 'm_{h}'; 'I_{A} (mA/cm^2)'; ...
        'm_{1,A}'; 'h_{1,A}'; 'm_{2,A}'; 'h_{2,A}'; ...
        'I_{Kir} (mA/cm^2)'; 'm_{\infty,Kir}'; ...
        'I_{NaP} (mA/cm^2)'; 'm_{\infty,NaP}'; 'h_{NaP}'};

figName = fullfile(outFolder, [expStr, '_simulated.png']);
% Count the number of subplots
nSubPlots = numel(yLabelsOverlapped);
% Create figure
figOverlapped = set_figure_properties('AlwaysNew', true, ...
                'FigExpansion', [1, nSubPlots/4]);
figM2h = set_figure_properties('AlwaysNew', true, ...
                'FigExpansion', [1, 1/2]);
figNameM2h = fullfile(outFolder, [expStr, '_simulated_m2h.png']);
save_all_figtypes(figM2h, figNameM2h, figTypes);
handles.handlesOverlapped = handlesOverlapped;
handles.handlesM2h = handlesM2h;

%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
