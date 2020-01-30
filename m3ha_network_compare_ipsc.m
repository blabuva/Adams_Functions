function handles = m3ha_network_compare_ipsc (varargin)
%% Compare an evoked IPSC against the recorded IPSC
% Usage: handles = m3ha_network_compare_ipsc (varargin)
% Explanation:
%       TODO
%
% Example(s):
%       TODO
%
% Outputs:
%       handles     - TODO: Description of output1
%                   specified as a TODO
%
% Arguments:
%       varargin    - 'InFolder': TODO: Description of param1
%                   must be a TODO
%                   default == TODO
%                   - 'AmpScaleFactor': amplitude scaling factor
%                   must be a numeric scalar
%                   default == 200%
%                   - 'OutFolder': TODO: Description of param1
%                   must be a TODO
%                   default == TODO
%                   - 'FigName': TODO: Description of param1
%                   must be a TODO
%                   default == TODO
%                   - 'SaveNewFlag': TODO: Description of param1
%                   must be a TODO
%                   default == TODO
%                   - Any other parameter-value pair for plot_traces()
%
% Requires:
%       cd/compute_gabab_conductance.m
%       cd/convert_units.m
%       cd/create_labels_from_numbers.m
%       cd/extract_columns.m
%       cd/extract_fileparts.m
%       cd/find_matching_files.m
%       cd/load_neuron_outputs.m
%       cd/m3ha_load_gabab_ipsc_params.m
%       cd/m3ha_network_compare_ipsc.m
%       cd/plot_traces.m
%       cd/set_figure_properties.m
%
% Used by:
%       cd/m3ha_plot_figure07.m

% File History:
% 2020-01-22 Created by Adam Lu
% 2020-01-30 Added input parser

%% Hard-coded parameters
spExtension = 'singsp';
spPrefix = 'TC[0]';
ipscStartMs = 3000;
ampUnits = 'nS';

% Column numbers for simulated data
%   Note: Must be consistent with m3ha_net.hoc
TIME_COL_SIM = 1;
VOLT_COL_SIM = 2;
INA_COL_SIM = 3;
IK_COL_SIM = 4;
ICA_COL_SIM = 5;
IGABAA_COL_SIM = 6;
IGABAB_COL_SIM = 7;
CAI_COL_SIM = 8;
GGABAB_COL_SIM = 9;

% Plot parameters
xLimits = [2000, 10000];
xLabel = 'Time (ms)';
pharmLabels = {'{\it s}-Control', '{\it s}-GAT1 Block', ...
                    '{\it s}-GAT3 Block', '{\it s}-Dual Block'};

% TODO: Make optional arguments
figTypes = 'png';

%% Default values for optional arguments
inFolderDefault = pwd;      % use current directory by default
ampScaleFactorDefault = 200;
outFolderDefault = '';      % set later
figNameDefault = [];        % no figure name by default
saveNewFlagDefault = true;  % create and save new figure by default

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Deal with arguments
% Set up Input Parser Scheme
iP = inputParser;
iP.FunctionName = mfilename;
iP.KeepUnmatched = true;                        % allow extraneous options

% Add parameter-value pairs to the Input Parser
addParameter(iP, 'InFolder', inFolderDefault);
addParameter(iP, 'AmpScaleFactor', ampScaleFactorDefault, ...
    @(x) assert(isempty(x) || isnumeric(x) && isscalar(x), ...
                ['AmpScaleFactor must be either empty ', ...
                    'or a numeric scalar!']));
addParameter(iP, 'OutFolder', outFolderDefault);
addParameter(iP, 'FigName', figNameDefault);
addParameter(iP, 'SaveNewFlag', saveNewFlagDefault);

% Read from the Input Parser
parse(iP, varargin{:});
inFolder = iP.Results.InFolder;
ampScaleFactor = iP.Results.AmpScaleFactor;
outFolder = iP.Results.OutFolder;
figName = iP.Results.FigName;
saveNewFlag = iP.Results.SaveNewFlag;

% Keep unmatched arguments for the plot_traces() function
otherArguments = iP.Unmatched;

%% Preparation
% Set default output folder
if isempty(outFolder)
    outFolder = inFolder;
end

% Find the appropriate network gIncr
ampScaleFactorNetwork = ampScaleFactor / 12;
spKeyword = ['gIncr_', num2str(ampScaleFactorNetwork)];

% Construct the pharm strings expected in file names
pharmStrs = create_labels_from_numbers(1:4, 'Prefix', 'pCond_');

% Locate the TC neuron data for each pharm condition
[~, dataPaths] = find_matching_files(pharmStrs, 'Directory', inFolder, ...
                            'Prefix', spPrefix, 'Keyword', spKeyword, ...
                            'Extension', spExtension);

% Decide on figure name
if isempty(figName) && saveNewFlag
    commonPrefix = extract_fileparts(dataPaths, 'commonprefix');
    commonSuffix = extract_fileparts(dataPaths, 'commonsuffix');
    figName = [commonPrefix, '_', commonSuffix, '_gabab_ipsc_comparison'];
end

% Decide on figure title
figTitle = ['GABA_B IPSC Comparison for ', commonPrefix, '_', commonSuffix];
figTitle = replace(figTitle, '_', '\_');

%% Do the job
% Load simulated data
simData = load_neuron_outputs('FileNames', dataPaths);

% Extract vectors from simulated data
[tVecsMs, gCmdSimUs] = extract_columns(simData, [TIME_COL_SIM, GGABAB_COL_SIM]);

% Convert to nS
gCmdSimNs = convert_units(gCmdSimUs, 'uS', 'nS');

% Load default GABAB IPSC parameters in nS
[ampOrig, tauRiseOrig, tauFallFastOrig, tauFallSlowOrig, weightOrig] = ...
    m3ha_load_gabab_ipsc_params('AmpScaleFactor', ampScaleFactor, ...
                                'AmpUnits', ampUnits);

% Compute original GABAB conductance vectors in nS
gVecsOrigNs = compute_gabab_conductance(tVecsMs, ipscStartMs, ...
                                ampOrig, tauRiseOrig, ...
                                tauFallFastOrig, tauFallSlowOrig, weightOrig);

% Clear simData to release memory
clear simData

% Create a figure
if saveNewFlag
    fig = set_figure_properties('AlwaysNew', true);
end

% Plot traces
handles = plot_traces(tVecsMs, gCmdSimNs, 'DataToCompare', gVecsOrigNs, ...
                        'PlotMode', 'parallel', 'XLimits', xLimits, ...
                        'XLabel', 'suppress', 'YLabel', pharmLabels, ...
                        'FigTitle', figTitle, 'LegendLocation', 'suppress', ...
                        'FigName', figName, 'FigTypes', figTypes, ...
                        otherArguments);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
OLD CODE:

%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%