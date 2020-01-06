% m3ha_plot_figure05.m
%% Plots Figure 05 for the GAT Blocker paper
%
% Requires:
%       cd/check_dir.m
%       cd/create_labels_from_numbers.m
%       cd/extract_fileparts.m
%       cd/find_matching_files.m
%       cd/m3ha_load_sweep_info.m
%       cd/m3ha_compute_gabab_ipsc.m
%       cd/m3ha_plot_simulated_traces.m
%       cd/plot_scale_bar.m
%       cd/save_all_figtypes.m
%       cd/set_figure_properties.m
%       cd/update_neuron_scripts.m
%       cd/update_figure_for_corel.m

% File History:
% 2019-12-29 Modified from m3ha_plot_figure03.m

%% Hard-coded parameters
% Flags
updateScripts = false; %true;
simulateIpscr = false; %true;
plotAllVoltages = false; %true;
plotAllTotalCurrents = false; %true;
plotAllComponentCurrents = false; %true;
plotDend2ITproperties = false; %true;
plotM2h = false; %true;
simulateTauhModes = false; %true;
computeIpscVariation = false; %true;
simulateIpscVariation = true;

% Directories
parentDirectory = fullfile('/media', 'adamX', 'm3ha');
figure02Dir = fullfile(parentDirectory, 'manuscript', 'figures', 'Figure02');
figure05Dir = fullfile(parentDirectory, 'manuscript', 'figures', 'Figure05');
fitDirectory = fullfile(parentDirectory, 'optimizer4gabab');

% Files
sweepInfoFile = 'dclampdatalog_take4.csv';
datalogPath = fullfile(figure02Dir, sweepInfoFile);
paramFileSuffix = 'params';

% Analysis settings
% exampleCellNames = {'D101310'; 'C101210'};
exampleCellNames = {'D101310'};
% exampleCellNames = {'C101210'};
gababIpscSheetBases = {'gababipsc_gat3_vary_amp', ...
                        'gababipsc_dual_vary_amp', ...
                        'gababipsc_gat3_vary_tau', ...
                        'gababipsc_dual_vary_tau', ...
                        'gababipsc_vary_dual_to_gat3_to_gat1', ...
                        'gababipsc_original'};

% Simulation settings
dataModeIpscr = 2;                  % data mode for IPSC response
                                    %   0 - all data
                                    %   1 - all of g incr = 100%, 200%, 400% 
                                    %   2 - same g incr but exclude 
                                    %       cell-pharm-g_incr sets 
                                    %       containing problematic sweeps
rowmodeIpscr = 1;                   % row mode for IPSC response
                                    %   1 - each row is a pharm condition
                                    %   2 - each row is a pharm, g incr pair
attemptNumberIpscr = 1;             % attempt number for IPSC response
                                    %   1 - Use 4 traces @ 200% gIncr 
                                    %           for this data mode
                                    %   2 - Use all traces @ 200% gIncr 
                                    %           for this data mode
                                    %   3 - Use all traces for this data mode
                                    %   4 - Use 1 trace for each pharm x gIncr 
                                    %           pair for this data mode
                                    %   5 - Use 4 traces @ 400% gIncr 
                                    %       for this data mode
% tauhModesAll = 4:5;
tauhModesAll = 1:5;

% Plot settings
overlappedFigWidth = 5.7;
overlappedFigHeightPerSubplot = 1.5;
overlappedXLimits = [2800, 4000];
overlappedYLimits = [];
m2hFigWidth = 5.7;
m2hFigHeight = 3;
m2hXLimits = [2800, 4000];
m2hYLimits = [];

figTypes = {'png', 'epsc2'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Make sure NEURON scripts are up to date in figure05Dir
if updateScripts
    update_neuron_scripts(fitDirectory, figure05Dir);
end

%% Load sweep info
% Read from datalogPath
swpInfo = m3ha_load_sweep_info('Directory', figure02Dir);

%% Find NEURON parameter tables
if simulateIpscr || plotAllVoltages || plotAllTotalCurrents || ...
        plotAllComponentCurrents || plotDend2ITproperties || plotM2h || ...
        simulateTauhModes || simulateIpscVariation
    % Find NEURON parameter tables
    [~, exampleParamPaths] = ...
        find_matching_files(exampleCellNames, 'Directory', figure05Dir, ...
                            'Suffix', paramFileSuffix, 'Extension', 'csv', ...
                            'Recursive', false, 'ForceCellOutput', true);

    % Extract file bases
    exampleParamFileBases = extract_fileparts(exampleParamPaths, 'base');

    % Extract example labels
    exampleLabels = extractBefore(exampleParamFileBases, ...
                                    ['_', paramFileSuffix]);


    % Create tauhMode suffixes
    tauhModeSuffixes = create_labels_from_numbers(tauhModesAll, ...
                                                    'Prefix', 'tauhmode');

    % Update labels for each type of simulation
    exampleLabelsIpscr = strcat(exampleLabels, '_ipscr');
    exampleLabelsModeAll = cellfun(@(x) strcat(exampleLabels, '_', x), ...
                                    tauhModeSuffixes, 'UniformOutput', false);
    exampleLabelsVaryAll = cellfun(@(x) strcat(exampleLabels, '_', x), ...
                                gababIpscSheetBases, 'UniformOutput', false);

    % Create output folder names
    outFoldersIpscr = fullfile(figure05Dir, exampleLabelsIpscr);
    outFoldersModeAll = cellfun(@(x) fullfile(figure05Dir, x), ...
                                exampleLabelsModeAll, 'UniformOutput', false);
    outFoldersVaryAll = cellfun(@(x) fullfile(figure05Dir, x), ...
                                exampleLabelsVaryAll, 'UniformOutput', false);
end

%% Simulate regular IPSC responses
if simulateIpscr
    check_dir(outFoldersIpscr);
    cellfun(@(x, y, z) simulate_ipscr(x, y, z, 0, dataModeIpscr, ...
                                    rowmodeIpscr, attemptNumberIpscr), ...
            exampleLabelsIpscr, exampleParamPaths, outFoldersIpscr);
end

%% Plot all voltages
if plotAllVoltages
    cellfun(@(x, y) plot_overlapped(x, y, 'allVoltages', ...
                    figure05Dir, figTypes, ...
                    overlappedFigWidth, 8 * overlappedFigHeightPerSubplot, ...
                    overlappedXLimits, overlappedYLimits), ...
            exampleLabelsIpscr, outFoldersIpscr);
end

%% Plot all currents
if plotAllTotalCurrents
    cellfun(@(x, y) plot_overlapped(x, y, 'allTotalCurrents', ...
                    figure05Dir, figTypes, ...
                    overlappedFigWidth, 7 * overlappedFigHeightPerSubplot, ...
                    overlappedXLimits, overlappedYLimits), ...
            exampleLabelsIpscr, outFoldersIpscr);
end

%% Plot component currents
if plotAllComponentCurrents
    cellfun(@(x, y) plot_overlapped(x, y, 'allComponentCurrents', ...
                    figure05Dir, figTypes, ...
                    overlappedFigWidth, 7 * overlappedFigHeightPerSubplot, ...
                    overlappedXLimits, overlappedYLimits), ...
            exampleLabelsIpscr, outFoldersIpscr);
end

%% Plot all T channel properties
if plotDend2ITproperties
    cellfun(@(x, y) plot_overlapped(x, y, 'dend2ITproperties', ...
                    figure05Dir, figTypes, ...
                    overlappedFigWidth, 5 * overlappedFigHeightPerSubplot, ...
                    overlappedXLimits, overlappedYLimits), ...
            exampleLabelsIpscr, outFoldersIpscr);
end

%% Plot m2h in dendrite 2 against its steady state
if plotM2h
    cellfun(@(x, y) plot_m2h(x, y, figure05Dir, figTypes, ...
                                m2hFigWidth, m2hFigHeight, ...
                                m2hXLimits, m2hYLimits), ...
            exampleLabelsIpscr, outFoldersIpscr);
end

%% Simulate tauhMode == 1, 2 and 3
if simulateTauhModes
    check_dir([outFoldersModeAll{:}]);
    for iMode = 1:numel(tauhModesAll)
        cellfun(@(x, y, z) simulate_ipscr(x, y, z, tauhModesAll(iMode), ...
                    dataModeIpscr, rowmodeIpscr, attemptNumberIpscr), ...
                exampleLabelsModeAll{iMode}, exampleParamPaths, ...
                outFoldersModeAll{iMode});
    end
end

%% Compute all GABAB IPSC parameters and plot them
if computeIpscVariation
    m3ha_compute_gabab_ipsc(figure05Dir);
end

%% Simulate IPSC variation
if simulateIpscVariation
    for iSheet = 1:numel(gababIpscSheetBases)
        % Read GABA-B IPSC parameters table
        gababTable = readtable([gababIpscSheetBases{iSheet}, '.csv']);

        % Convert to a scalar structure
        gababStruct = table2struct(gababTable, 'ToScalar', true);

        % Simulate for each cell
        cellfun(@(x, y, z) simulate_variation(x, y, z, gababStruct), ...
                exampleLabelsVaryAll{iSheet}, exampleParamPaths, ...
                outFoldersVaryAll{iSheet});
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function simulate_ipscr(label, neuronParamsFile, outFolder, ...
                        tauhMode, dataMode, rowmode, attemptNumber)

% Simulate
m3ha_neuron_run_and_analyze(neuronParamsFile, ...
                        'OutFolder', outFolder, 'Prefix', label, ...
                        'BuildMode', 'active', 'SimMode', 'active', ...
                        'TauhMode', tauhMode, 'DataMode', dataMode, ...
                        'ColumnMode', 1, 'Rowmode', rowmode, ...
                        'AttemptNumber', attemptNumber, ...
                        'PlotAllFlag', false, 'PlotIndividualFlag', true, ...
                        'SaveSimOutFlag', true);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function simulate_variation(label, neuronParamsFile, outFolder, gababParams)

% Simulate
m3ha_neuron_run_and_analyze(neuronParamsFile, ...
                        'OutFolder', outFolder, 'Prefix', label, ...
                        'BuildMode', 'active', 'SimMode', 'active', ...
                        'PlotAllFlag', false, 'PlotOverlappedFlag', true, ...
                        'SaveSimOutFlag', true, 'NoRealDataFlag', true, ...
                        gababParams);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plot_overlapped(expStr, directory, plotType, outFolder, figTypes, ...
                            figWidth, figHeight, xLimits, yLimits)

% Create figure names
figPathBaseOrig = fullfile(outFolder, [expStr, '_', plotType, '_orig']);
figPathBase = fullfile(outFolder, [expStr, '_', plotType]);

% Create the figure
fig = set_figure_properties('AlwaysNew', true);

% Plot traces
m3ha_plot_simulated_traces('Directory', directory, 'ExpStr', expStr, ...
                'PlotType', plotType, 'FigHandle', fig, ...
                'FigTitle', 'suppress', 'XLabel', 'suppress', ...
                'XLimits', xLimits, 'YLimits', yLimits);

% Save the figure
save_all_figtypes(fig, figPathBaseOrig, 'png');

% Plot a scale bar
hold on
plot_scale_bar('x', 'XBarUnits', 'ms', 'XBarLength', 200, ...
                'XPosNormalized', 0.1, 'YPosNormalized', 0.8);

% Update figure for CorelDraw
update_figure_for_corel(fig, 'Units', 'centimeters', ...
                'Width', figWidth, 'Height', figHeight, ...
                'AlignSubplots', true, ...
                'RemoveXTicks', true, 'RemoveXRulers', true);

% Save the figure
save_all_figtypes(fig, figPathBase, figTypes);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plot_m2h(expStr, directory, outFolder, figTypes, ...
                    figWidth, figHeight, xLimits, yLimits)

% Create a figure name
figPathBaseM2hOrig = fullfile(outFolder, [expStr, '_m2h_orig']);
figPathBaseM2h = fullfile(outFolder, [expStr, '_m2h']);

% Create the figure
figM2h = set_figure_properties('AlwaysNew', true);

% Plot traces
m3ha_plot_simulated_traces('Directory', directory, 'ExpStr', expStr, ...
                'PlotType', 'm2h', 'FigHandle', figM2h, ...
                'FigTitle', 'suppress', ...
                'XLimits', xLimits, 'YLimits', yLimits);

% Save the figure
save_all_figtypes(figM2h, figPathBaseM2hOrig, 'png');

% Plot a scale bar
hold on
plot_scale_bar('x', 'XBarUnits', 'ms', 'XBarLength', 200, ...
                'XPosNormalized', 0.1, 'YPosNormalized', 0.8);

% Update figure for CorelDraw
update_figure_for_corel(figM2h, 'Units', 'centimeters', ...
                'Width', figWidth, 'Height', figHeight, ...
                'AlignSubplots', true, ...
                'RemoveXTicks', true, 'RemoveXRulers', true);

% Save the figure
save_all_figtypes(figM2h, figPathBaseM2h, figTypes);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
OLD CODE:

%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
