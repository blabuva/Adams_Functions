function handles = m3ha_network_plot_essential (varargin)
%% Compare an evoked IPSC against the recorded IPSC
% Usage: handles = m3ha_network_plot_essential (varargin)
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
%                   - 'PharmCondition': pharmacological condition
%                   must be a numeric scalar
%                   default == 1
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
%       TODO:
%       cd/all_files.m
%       cd/argfun.m
%       cd/compute_total_current.m
%       cd/convert_units.m
%       cd/extract_columns.m
%       cd/extract_fileparts.m
%       cd/load_neuron_outputs.m
%       cd/plot_traces.m
%       cd/set_figure_properties.m
%
% Used by:
%       cd/m3ha_plot_figure07.m

% File History:
% 2020-01-30 Modified from m3ha_network_plot_gabab.m

%% Hard-coded parameters
spExtension = 'singsp';
spPrefixTC = 'TC[0]';
spPrefixRT = 'RT[0]';
ipscStartMs = 3000;

% Column numbers for simulated data
%   Note: Must be consistent with m3ha_net.hoc
RT_TIME = 1;
RT_VOLT = 2;
RT_INA = 3;
RT_IK = 4;
RT_ICA = 5;
RT_IAMPA = 6;
RT_IGABAA = 7;
RT_CAI = 8;
RT_CLI = 9;

TC_TIME = 1;
TC_VOLT = 2;
TC_IN = 3;
TC_IK = 4;
TC_ICA_SOMA = 5;
TC_IGABAA = 6;
TC_IGABAB = 7;
TC_CAI = 8;
TC_GGABAB = 9;
TC_IT_M_DEND2 = 10;
TC_IT_MINF_DEND2 = 11;
TC_IT_H_DEND2 = 12;
TC_IT_HINF_DEND2 = 13;
TC_ICA_DEND1 = 14;
TC_ICA_DEND2 = 15;

% Plot parameters
xLimits = [2000, 10000];
xLabel = 'Time (ms)';
pharmLabels = {'{\it s}-Control', '{\it s}-GAT1 Block', ...
                '{\it s}-GAT3 Block', '{\it s}-Dual Block'};

% TODO: Make optional arguments
figTypes = 'png';

%% Default values for optional arguments
inFolderDefault = pwd;      % use current directory by default
ampScaleFactorDefault = []; % set later
pharmConditionDefault = []; % set later
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
addParameter(iP, 'PharmCondition', pharmConditionDefault, ...
    @(x) assert(isempty(x) || isnumeric(x) && isscalar(x), ...
                ['PharmCondition must be either empty ', ...
                    'or a numeric scalar!']));
addParameter(iP, 'OutFolder', outFolderDefault);
addParameter(iP, 'FigName', figNameDefault);
addParameter(iP, 'SaveNewFlag', saveNewFlagDefault);

% Read from the Input Parser
parse(iP, varargin{:});
inFolder = iP.Results.InFolder;
ampScaleFactor = iP.Results.AmpScaleFactor;
pharmCondition = iP.Results.PharmCondition;
outFolder = iP.Results.OutFolder;
figName = iP.Results.FigName;
saveNewFlag = iP.Results.SaveNewFlag;

% Keep unmatched arguments for the plot_traces() function
otherArguments = iP.Unmatched;

%% Preparation
% Set default parameters
if isempty(ampScaleFactor)
    ampScaleFactor = 200;
end
if isempty(pharmCondition)
    pharmCondition = 1;
end

% Set default output folder
if isempty(outFolder)
    outFolder = inFolder;
end

% Find the appropriate file keyword
ampScaleFactorNetwork = ampScaleFactor / 12;
spKeyword = ['pCond_', num2str(pharmCondition), ...
            'gIncr_', num2str(ampScaleFactorNetwork)];

% Locate the RT neuron data
[~, dataPathRT] = all_files('Directory', inFolder, ...
                            'Prefix', spPrefixRT, 'Keyword', spKeyword, ...
                            'Extension', spExtension);

% Locate the TC neuron data
[~, dataPathTC] = all_files('Directory', inFolder, ...
                            'Prefix', spPrefixTC, 'Keyword', spKeyword, ...
                            'Extension', spExtension);

% Decide on figure name
if isempty(figName) && saveNewFlag
    commonPrefix = extract_fileparts({dataPathTC, dataPathRT}, 'commonprefix');
    commonSuffix = extract_fileparts({dataPathTC, dataPathRT}, 'commonsuffix');
    figName = [commonPrefix, '_', commonSuffix, '_essential'];
end

% Decide on figure title
figTitle = ['Essential traces for ', commonPrefix, '_', commonSuffix];
figTitle = replace(figTitle, '_', '\_');

%% Do the job
% Load simulated data
[simDataRT, simDataTC] = ...
    argfun(@(x) load_neuron_outputs('FileNames', x), dataPathRT, dataPathTC);

% Extract vectors from simulated data
[tVecsMs, vVecRT] = ...
    extract_columns(simDataRT, [RT_TIME, RT_VOLT]);
[vVecTC, gCmdTCUs, itSomaTC, itDend1TC, itDend2TC, ...
        itmDend2, itminfDend2, ithDend2, ithinfDend2] = ...
    extract_columns(simDataTC, [TC_VOLT, TC_GGABAB, ...
                                TC_ICA_SOMA, TC_ICA_DEND1, TC_ICA_DEND2, ...
                                TC_IT_M_DEND2, TC_IT_MINF_DEND2, ...
                                TC_IT_H_DEND2, TC_IT_HINF_DEND2]);

% Convert conductance from uS to nS
gCmdTCNs = convert_units(gCmdTCUs, 'uS', 'nS');

% Compute total T current
compute_total_current([itSomaTC, itDend1TC, itDend2TC], 'GeomParams', d)

% Compute m2h
itm2hDend2 = (itmDend2 .^ 2) .* ithDend2;
itminf2hinfDend2 = (itminfDend2 .^ 2) .* ithinfDend2;

% Clear simData to release memory
clear simDataRT simDataTC

% List all possible items to plot
vecsAll = {vVecRT; vVecTC; gCmdTCUs; ...
            vVecsDend2; iTotal; iExtSim; ...
            gCmdSimNs; iIntTotal; iPasTotal; ...
            itTotal; ihTotal; iaTotal; ikirTotal; inapTotal; itaTotal; ...
            itTotalSoma; itTotalDend1; itTotalDend2; ...
            iaTotalSoma; iaTotalDend1; iaTotalDend2; ...
            itmSoma; itminfSoma; ithSoma; ithinfSoma; ...
            itmDend1; itminfDend1; ithDend1; ithinfDend1; ...
            itmDend2; itminfDend2; ithDend2; ithinfDend2; ...
            itm2hDend2; itminf2hinfDend2};

% List corresponding labels
labelsAll = {'V_{rec} (mV)'; 'V_{soma} (mV)'; 'V_{dend1} (mV)'; ...
            'V_{dend2} (mV)'; 'I_{total} (nA)'; 'I_{stim} (nA)'; ...
            'g_{GABA_B} (nS)'; 'I_{int} (nA)'; 'I_{pas} (nA)'; ...
            'I_{T} (nA)'; 'I_{h} (nA)'; 'I_{A} (nA)'; ...
            'I_{Kir} (nA)'; 'I_{NaP} (nA)'; 'I_{T} + I_{A} (nA)'; ...
            'I_{T,soma} (nA)'; 'I_{T,dend1} (nA)'; 'I_{T,dend2} (nA)'; ...
            'I_{A,soma} (nA)'; 'I_{A,dend1} (nA)'; 'I_{A,dend2} (nA)'; ...
            'm_{T,soma}'; 'm_{\infty,T,soma}'; ...
            'h_{T,soma}'; 'h_{\infty,T,soma}'; ...
            'm_{T,dend1}'; 'm_{\infty,T,dend1}'; ...
            'h_{T,dend1}'; 'h_{\infty,T,dend1}'; ...
            'm_{T,dend2}'; 'm_{\infty,T,dend2}'; ...
            'h_{T,dend2}'; 'h_{\infty,T,dend2}'; ...
            'm_{T,dend2}^2h_{T,dend2}'; ...
            'm_{\infty,T,dend2}^2h_{\infty,T,dend2}'};

% Create a figure
if saveNewFlag
    fig = set_figure_properties('AlwaysNew', true);
end

% Plot traces
handles = plot_traces(tVecsMs, gCmdTCNs, ...
                        'PlotMode', 'parallel', 'XLimits', xLimits, ...
                        'XLabel', 'suppress', 'YLabel', yLabels, ...
                        'FigTitle', figTitle, 'LegendLocation', 'suppress', ...
                        'FigName', figName, 'FigTypes', figTypes, ...
                        otherArguments);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
OLD CODE:

%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
