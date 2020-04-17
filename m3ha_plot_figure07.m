% m3ha_plot_figure07.m
%% Plots Figure 07 for the GAT Blocker paper
%
% Requires:
%       cd/addvars_custom.m
%       cd/all_files.m
%       cd/all_subdirs.m
%       cd/apply_over_cells.m
%       cd/archive_dependent_scripts.m
%       cd/argfun.m
%       cd/array_fun.m
%       cd/compute_combined_trace.m
%       cd/create_labels_from_numbers.m
%       cd/create_label_from_sequence.m
%       cd/decide_on_colormap.m
%       cd/extract_fileparts.m
%       cd/extract_substrings.m
%       cd/find_matching_files.m
%       cd/force_column_cell.m
%       cd/force_matrix.m
%       cd/lower_first_char.m
%       cd/m3ha_network_analyze_spikes.m
%       cd/m3ha_network_plot_gabab.m
%       cd/m3ha_network_plot_essential.m
%       cd/m3ha_plot_violin.m
%       cd/match_positions.m
%       cd/plot_grouped_jitter.m
%       cd/plot_scale_bar.m
%       cd/plot_tuning_curve.m
%       cd/save_all_figtypes.m
%       cd/set_figure_properties.m
%       cd/sscanf_full.m
%       cd/update_figure_for_corel.m

% File History:
% 2020-01-30 Modified from m3ha_plot_figure05.m
% 2020-02-06 Added plot200CellExamples and plot2CellM2h
% 2020-03-10 Updated pharm labels
% 2020-04-09 Added combineActivationProfiles

%% Hard-coded parameters
% Flags
plotIpscComparison = false; %true;
plot2CellEssential = false; %true;
plot2CellM2h = false; %true;

analyze2CellSpikes = false; %true;
plotAnalysis2Cell = false; %true;
backupPrevious2Cell = false; %true;
combine2CellPopulation = false; %true;
plot2CellViolins = false; %true;

plot200CellExamples = false; %true;

analyze200CellSpikes = false; %true;
plotAnalysis200Cell = false;
backupPrevious200Cell = false;
combineActivationProfiles = false; %true;
combine200CellPopulation = false; %true;
plot200CellViolins = false; %true;
plot200CellGroupByCellJitters = false; %true;
combineEach200CellNetwork = true;

archiveScriptsFlag = true;

% Directories
parentDirectory = fullfile('/media', 'adamX', 'm3ha');
figure07Dir = fullfile(parentDirectory, 'manuscript', 'figures', 'Figure07');
figure08Dir = fullfile(parentDirectory, 'manuscript', 'figures', 'Figure08');
networkDirectory = fullfile(parentDirectory, 'network_model');

% exampleIterName2Cell = '20200131T1345_using_bestparams_20200126_singleneuronfitting101';  % 20200131
% exampleIterName2Cell = '20200205T1353_using_bestparams_20200203_manual_singleneuronfitting0-102_2cell_examples';
% popIterName2Cell = '20200204T1042_using_bestparams_20200203_manual_singleneuronfitting0-102_vtraub_-65_2cell_spikes';
% exampleIterName200Cell = '20200204T1239_using_bestparams_20200203_manual_singleneuronfitting0-102_200cell_spikes';
% popIterName200Cell = exampleIterName200Cell;
% rankNumsToUse = [2, 4, 5, 7, 9, 10, 12, 13, 16, 20, 21, 23, 25, 29];
% popIterName2Cell = '20200208T1230_using_bestparams_20200203_manual_singleneuronfitting0-102_2cell_spikes';
% popIterName2Cell = '20200305T2334_using_bestparams_20200203_manual_singleneuronfitting0-102_2cell_REgpas_varied';
% popIterName2Cell = '20200306T1724_using_bestparams_20200203_manual_singleneuronfitting0-102_2cell_gpas_varied';
% popIterName2Cell = '20200308T2306_using_bestparams_20200203_manual_singleneuronfitting0-102_2cell_TCepas_varied';
% popIterName200Cell = exampleIterName200Cell;
% popIterName200Cell = '20200309T1346_using_bestparams_20200203_manual_singleneuronfitting0-102_200cell_TCepas_varied';
% popIterName2Cell = '20200309T0013_using_bestparams_20200203_manual_singleneuronfitting0-102_2cell_TCepas_varied';

exampleIterName2Cell = '20200207T1554_using_bestparams_20200203_manual_singleneuronfitting0-102_REena88_TCena88_2cell_examples';
popIterName2Cell = '20200311T2144_using_bestparams_20200203_manual_singleneuronfitting0-102_2cell_TCepas_varied';
exampleIterName200Cell = '20200208T1429_using_bestparams_20200203_manual_singleneuronfitting0-102_200cell_spikes';
% popIterName200Cell = '20200312T0130_using_bestparams_20200203_manual_singleneuronfitting0-102_200cell_TCepas_varied';
popIterName200Cell = '20200408_using_bestparams_20200203_manual_singleneuronfitting0-102';
candCellSheetName = 'candidate_cells.csv';
oscParamsSuffix = 'oscillation_params';

% Well-fitted, good 2-cell network response
rankNumsToUse = [2:4, 6, 8:11, 14, 18, 19, 21, 23];

% Files

% Analysis settings
% Should be consistent with m3ha_plot_figure03.m & m3ha_plot_figure07.m
exampleCellNames = {'D101310'; 'G101310'};

gIncr = 200;                % Original dynamic clamp gIncr value
pharmConditions = (1:4)';   % Pharmacological conditions
                            %   1 - Control
                            %   2 - GAT 1 Block
                            %   3 - GAT 3 Block
                            %   4 - Dual Block
measuresOfInterest = {'oscillationProbability'; 'meanOscPeriod2Ms'; ...
                        'meanOscIndex4'; 'meanPercentActive'; ...
                        'meanOscDurationSec'; 'meanPercentActiveTC'; ...
                        'meanHalfActiveLatencyMsTC'};
measureTitles = {'Oscillation Probability'; 'Oscillation Period (ms)'; ...
                    'Oscillatory Index'; 'Active Cells (%)'; ...
                    'Oscillation Duration (sec)'; 'Active TC Cells (%)'; ...
                    'Half Activation Time (ms)'};
measuresOfInterestJitter = {'oscPeriod2Ms'; ...
                        'oscIndex4'; 'percentActive'; ...
                        'oscDurationSec'; 'percentActiveTC'; ...
                        'halfActiveLatencyMsTC'};
measureTitlesJitter = measureTitles(2:end);

% Plot settings
ipscFigWidth = 8.5;
ipscFigHeight = 6;
xLimits2Cell = [2800, 4800];
yLimitsGabab = [-1, 15];
% yLimitsEssential = {[], [], [], [], [], []};
yLimitsEssential = {[-100, 100], [-100, 100], [-1, 12], [-15, 5], ...
                    [1e-10, 1], [1e-10, 1]};
yLimitsM2h = [1e-10, 1];
essential2CellFigWidth = 8.5;
essential2CellFigHeight = 1 * 6;
m2h2CellFigWidth = 8.5;
m2h2CellFigHeight = 1;
example200CellFigWidth = 8.5;
example200CellFigHeight = 3;
pharmLabelsShort = {'{\it s}Con', '{\it s}GAT1', ...
                    '{\it s}GAT3', '{\it s}Dual'};

% epasToPlot = [];
epasToPlot = [-74; -70; -66; -62];
candidateLabels = {};
% candidateLabels = {'candidateIDs_2,14,32,35', 'candidateIDs_2', ...
                % 'candidateIDs_14', 'candidateIDs_32', 'candidateIDs_35'};
% candidateLabels = {'candidateIDs_2,14,20,29-30,32,35-36'};
networkNamesToUse = {'D101310', 'hetero4', 'hetero8'};

figTypes = {'png', 'epsc'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Preparation
% Find the directory for this iteration
exampleIterDir2Cell = fullfile(networkDirectory, exampleIterName2Cell);
exampleIterDir200Cell = fullfile(networkDirectory, exampleIterName200Cell);
popIterDir2Cell = fullfile(networkDirectory, popIterName2Cell);
popIterDir200Cell = fullfile(networkDirectory, popIterName200Cell);

% Construct the full path to the candidate cell spreadsheet
candCellSheetPath = fullfile(networkDirectory, candCellSheetName);

% Create a rank string
rankStr = ['rank', create_label_from_sequence(rankNumsToUse)];

% Create a condition label
[conditionLabel2Cell, conditionLabel200Cell] = ...
    argfun(@(x) [x, '_', rankStr, '_gIncr', num2str(gIncr)], ...
            popIterName2Cell, popIterName200Cell);

% Create a population data spreadsheet name
popDataSheetName2Cell = [popIterName2Cell, '_', rankStr, '_', ...
                            oscParamsSuffix, '.csv'];
popDataSheetName200Cell = [popIterName200Cell, '_', rankStr, '_', ...
                            oscParamsSuffix, '.csv'];

% Create a network data spreadsheet names
networkSheetNames = strcat(popIterName200Cell, '_', networkNamesToUse, '_', ...
                            oscParamsSuffix, '.csv');

% Contruct the full path to the population data spreadsheet
popDataPath2Cell = fullfile(figure07Dir, popDataSheetName2Cell);
popDataPath200Cell = fullfile(figure08Dir, popDataSheetName200Cell);
networkDataPaths = fullfile(figure08Dir, networkSheetNames);

% Create color maps
colorMapPharm = decide_on_colormap([], 4);
colorMapPharmCell = arrayfun(@(x) colorMapPharm(x, :), ...
                            transpose(1:4), 'UniformOutput', false);


%% Find example files and directories
if plotIpscComparison || plot2CellEssential || plot2CellM2h
    % Find example network directories
    [~, exampleDirs2Cell] = ...
        cellfun(@(x) all_subdirs('Directory', exampleIterDir2Cell, ...
                                'Keyword', x), ...
                exampleCellNames, 'UniformOutput', false);
end
if plot200CellExamples
    % Find example network directories
    [~, exampleDirs200Cell] = ...
        cellfun(@(x) all_subdirs('Directory', exampleIterDir200Cell, ...
                                'Keyword', x), ...
                exampleCellNames, 'UniformOutput', false);
end

%% Plots figures for comparing dynamic clamp ipsc
if plotIpscComparison
    cellfun(@(x, y) plot_ipsc_comparison(x, exampleIterName2Cell, gIncr, y, ...
                                        figure07Dir, figTypes, ...
                                        ipscFigWidth, ipscFigHeight, ...
                                        xLimits2Cell, yLimitsGabab), ...
            exampleCellNames, exampleDirs2Cell);
end

%% Plots example 2-cell networks
if plot2CellEssential
    cellfun(@(a, b) ...
        cellfun(@(x, y) plot_2cell_examples(x, exampleIterName2Cell, ...
                            gIncr, a, y, figure07Dir, figTypes, ...
                            essential2CellFigWidth, essential2CellFigHeight, ...
                            xLimits2Cell, yLimitsEssential, ...
                            'essential', b), ...
                exampleCellNames, exampleDirs2Cell), ...
        num2cell(pharmConditions), colorMapPharmCell);
end

%% Plots m2h of example 2-cell networks
if plot2CellM2h
    cellfun(@(a, b) ...
        cellfun(@(x, y) plot_2cell_examples(x, exampleIterName2Cell, ...
                            gIncr, a, y, figure07Dir, figTypes, ...
                            m2h2CellFigWidth, m2h2CellFigHeight, ...
                            xLimits2Cell, yLimitsM2h, ...
                            'm2h', b), ...
                exampleCellNames, exampleDirs2Cell), ...
        num2cell(pharmConditions), colorMapPharmCell);
end

%% Plots example 200-cell networks
if plot200CellExamples
    arrayfun(@(z) ...
        cellfun(@(x, y) plot_200cell_examples(x, exampleIterName200Cell, ...
                            gIncr, z, y, figure08Dir, figTypes, ...
                        example200CellFigWidth, example200CellFigHeight), ...
                exampleCellNames, exampleDirs200Cell), ...
        pharmConditions);
end

%% Analyzes spikes for all 2-cell networks
if analyze2CellSpikes
    reanalyze_network_spikes(popIterDir2Cell, backupPrevious2Cell, ...
                                plotAnalysis2Cell);
end

%% Combines quantification over all 2-cell networks
if combine2CellPopulation
    combine_osc_params(popIterDir2Cell, candCellSheetPath, ...
                            rankNumsToUse, popDataPath2Cell, []);
end

%% Analyzes spikes for all 200-cell networks
if analyze200CellSpikes
    reanalyze_network_spikes(popIterDir200Cell, backupPrevious200Cell, ...
                                plotAnalysis200Cell);
end

%% Combines quantification over all homogeneous 200-cell networks
if combine200CellPopulation
    combine_osc_params(popIterDir200Cell, candCellSheetPath, ...
                            rankNumsToUse, popDataPath200Cell, []);
end

%% Combines activation profiles over seed numbers for each 200-cell network
if combineActivationProfiles
    combine_activation_profiles(popIterDir200Cell, figure08Dir, ...
                                epasToPlot, candidateLabels);
end

%% Plots oscillation measures over pharm condition 
%       across all 2-cell networks
if plot2CellViolins
    % Construct stats table path
    stats2dPath2Cell = ...
        fullfile(figure07Dir, strcat(conditionLabel2Cell, '_stats.mat'));

    % Compute statistics if not done already
    if ~isfile(stats2dPath2Cell)
        % Compute statistics for all features
        disp('Computing statistics for violin plots ...');
        statsTable = m3ha_network_compute_statistics(popDataPath2Cell, ...
                                    gIncr, measuresOfInterest, measureTitles);

        % Generate labels
        conditionLabel = conditionLabel2Cell;
        pharmLabels = pharmLabelsShort;

        % Save stats table
        save(stats2dPath2Cell, 'statsTable', 'pharmLabels', ...
                            'conditionLabel', '-v7.3');
    end

    % Plot violin plots
    m3ha_plot_violin(stats2dPath2Cell, 'RowsToPlot', measuresOfInterest, ...
                    'OutFolder', figure07Dir);
end

%% Plots mean oscillation measures over pharm condition 
%       across all 200-cell networks
if plot200CellViolins
    % Construct stats table path
    stats2dPath200Cell = ...
        fullfile(figure08Dir, strcat(conditionLabel200Cell, '_stats.mat'));

    % Compute statistics if not done already
    if ~isfile(stats2dPath200Cell)
        % Compute statistics for all features
        disp('Computing statistics for violin plots ...');
        statsTable = m3ha_network_compute_statistics(popDataPath200Cell, ...
                                gIncr, measuresOfInterest, measureTitles, ...
                                'mean');

        % Generate labels
        conditionLabel = conditionLabel200Cell;
        pharmLabels = pharmLabelsShort;

        % Save stats table
        save(stats2dPath200Cell, 'statsTable', 'pharmLabels', ...
                            'conditionLabel', '-v7.3');
    end

    % Plot violin plots
    m3ha_plot_violin(stats2dPath200Cell, 'RowsToPlot', measuresOfInterest, ...
                    'OutFolder', figure08Dir);
end

%% Plots oscillation measures over pharm condition 
if plot200CellGroupByCellJitters
    % Construct stats table path
    statsGroupByCellPath200Cell = ...
        fullfile(figure08Dir, strcat(conditionLabel200Cell, ...
                    '_groupByCell_stats.mat'));

    % Compute statistics if not done already
    if ~isfile(statsGroupByCellPath200Cell)
        % Compute statistics for all features
        disp('Computing statistics for grouped jitter plots ...');
        statsTable = m3ha_network_compute_statistics(popDataPath200Cell, ...
                            gIncr, measuresOfInterestJitter, ...
                            measureTitlesJitter, 'groupByCell');

        % Generate labels
        conditionLabel = conditionLabel200Cell;
        pharmLabels = pharmLabelsShort;

        % Save stats table
        save(statsGroupByCellPath200Cell, 'statsTable', 'pharmLabels', ...
                            'conditionLabel', '-v7.3');
    end

    % Plot jitter plots
    m3ha_plot_grouped_jitter(statsGroupByCellPath200Cell, figure08Dir, ...
                                measuresOfInterestJitter);
end

%% Combines quantification over each 200-cell networks
if combineEach200CellNetwork
    cellfun(@(dataPath, networkName) ...
                combine_osc_params(popIterDir200Cell, candCellSheetPath, ...
                            rankNumsToUse, dataPath, networkName), ...
            networkDataPaths, networkNamesToUse, 'UniformOutput', false);
end

%% Archive all scripts for this run
if archiveScriptsFlag
    if plot200CellExamples || analyze200CellSpikes || plotAnalysis200Cell || ...
            backupPrevious200Cell || combineActivationProfiles || ...
            combine200CellPopulation || plot200CellViolins || ...
            plot200CellGroupByCellJitters || combineEach200CellNetwork
        archive_dependent_scripts(mfilename, 'OutFolder', figure08Dir);
    else
        archive_dependent_scripts(mfilename, 'OutFolder', figure07Dir);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plot_ipsc_comparison (cellName, popIterName2Cell, gIncr, ...
                                inFolder, outFolder, ...
                                figTypes, figWidth, figHeight, ...
                                xLimits, yLimits)
% Plot an IPSC comparison plot

% Create a gIncr string
gIncrStr = ['gIncr', num2str(gIncr)];

% Create figure names
figPathBase = fullfile(outFolder, [cellName, '_', popIterName2Cell, ...
                        '_', gIncrStr, '_gabab_ipsc_comparison']);
figPathBaseOrig = [figPathBase, '_orig'];

% Create the figure
fig = set_figure_properties('AlwaysNew', true);

% Plot comparison
m3ha_network_plot_gabab('SaveNewFlag', false, 'InFolder', inFolder, ...
                        'XLimits', xLimits, 'YLimits', yLimits, ...
                        'FigTitle', 'suppress', ...
                        'AmpScaleFactor', gIncr);

% Save original figure
drawnow;
save_all_figtypes(fig, figPathBaseOrig, 'png');

% Plot a scale bar
plot_scale_bar('x', 'XBarUnits', 'ms', 'XBarLength', 200, ...
                'XPosNormalized', 0.9, 'YPosNormalized', 0.9);

% Update figure for CorelDraw
update_figure_for_corel(fig, 'Units', 'centimeters', ...
                        'Width', figWidth, 'Height', figHeight, ...
                        'RemoveXRulers', true, 'AlignSubplots', true);

% Save the figure
drawnow;
save_all_figtypes(fig, figPathBase, figTypes);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plot_2cell_examples (cellName, iterName, gIncr, pharm, ...
                            inFolder, outFolder, figTypes, ...
                            figWidth, figHeight, xLimits, yLimits, ...
                            plotType, colorMap)
% Plot 2-cell network examples

% Create a gIncr string
gIncrStr = ['gIncr', num2str(gIncr)];
pharmStr = ['pharm', num2str(pharm)];

% Create figure names
figPathBase = fullfile(outFolder, [cellName, '_', iterName, ...
                        '_', gIncrStr, '_', pharmStr, '_2cell_', plotType]);
figPathBaseOrig = [figPathBase, '_orig'];

% Create the figure
fig = set_figure_properties('AlwaysNew', true);

% Plot example
handles = ...
    m3ha_network_plot_essential('SaveNewFlag', false, 'InFolder', inFolder, ...
                        'XLimits', xLimits, 'YLimits', yLimits, ...
                        'FigTitle', 'suppress', ...
                        'AmpScaleFactor', gIncr, 'PharmCondition', pharm, ...
                        'PlotType', plotType, 'Color', colorMap);

% Save original figure
drawnow;
save_all_figtypes(fig, figPathBaseOrig, 'png');

% Fine tune
switch plotType
case 'essential'
    % Get all subplots
    subPlots = handles.subPlots;

    % Change the y ticks for the first two subplots
    for i = 1:2
        subplot(subPlots(i));
        yticks([-75, 75]);
    end

    % Plot a scale bar in the first subplot
    subplot(subPlots(1));
    plot_scale_bar('x', 'XBarUnits', 'ms', 'XBarLength', 200, ...
                    'XPosNormalized', 0.9, 'YPosNormalized', 0.9);
case 'm2h'
    yticks([1e-8, 1e-2]);   
end

% Update figure for CorelDraw
update_figure_for_corel(fig, 'Units', 'centimeters', ...
                        'Width', figWidth, 'Height', figHeight, ...
                        'RemoveXRulers', true, 'AlignSubplots', true);

% Save the figure
drawnow;
save_all_figtypes(fig, figPathBase, figTypes);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plot_200cell_examples (cellName, iterName, gIncrDclamp, pharm, ...
                            inFolder, outFolder, figTypes, figWidth, figHeight)
% Plot 200-cell network examples

% Get the gIncr value for the network
gIncr = gIncrDclamp / 12;

% Create strings
gIncrStr = ['gIncr', num2str(gIncrDclamp)];
pharmStr = ['pharm', num2str(pharm)];

% Find the appropriate simulation number
simNumber = m3ha_network_find_sim_number(inFolder, pharm, gIncr);

% Create figure names
figPathBase = fullfile(outFolder, [cellName, '_', iterName, ...
                        '_', gIncrStr, '_', pharmStr, '_200cell_example']);
figPathBaseOrig = [figPathBase, '_orig'];

%% Full figure
% Create the figure
fig = set_figure_properties('AlwaysNew', true);

% Plot spike raster plot
m3ha_network_raster_plot(inFolder, 'OutFolder', outFolder, ...
                        'SingleTrialNum', simNumber, ...
                        'PlotSpikes', true, 'PlotTuning', false, ...
                        'PlotOnly', true);

% Save original figure
drawnow;
save_all_figtypes(fig, figPathBaseOrig, 'png');

% Update figure for CorelDraw
update_figure_for_corel(fig, 'RemoveXLabels', true, 'RemoveYLabels', true, ...
                        'RemoveTitles', true, 'RemoveXRulers', true);
update_figure_for_corel(fig, 'Units', 'centimeters', ...
                            'Width', figWidth, 'Height', figHeight);

% Plot a scale bar only for the Dual Blockade condition
if pharm == 4
    plot_scale_bar('x', 'XBarUnits', 'sec', 'XBarLength', 2, ...
                    'XPosNormalized', 0.6, 'YPosNormalized', 0.2);
end

% Save the figure
drawnow;
save_all_figtypes(fig, figPathBase, figTypes);

% Close all figures
close all

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function simNumber = m3ha_network_find_sim_number (inFolder, pharm, gIncr)
%% TODO: Move this to m3ha_network_raster_plot.m

% Create strings
paramsPrefix = 'sim_params';
pharmStr = ['pCond_', num2str(pharm)];
gIncrStr = ['gIncr_', num2str(gIncr)];

% Create the keyword
keyword = [pharmStr, '_', gIncrStr];

% Find the sim params file
[~, paramPath] = all_files('Directory', inFolder, 'Prefix', paramsPrefix, ...
                            'Keyword', keyword, 'MaxNum', 1);

% Find the corresponding simNumber
paramTable = readtable(paramPath, 'ReadRowNames', true);
simNumber = paramTable{'simNumber', 'Value'};

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function reanalyze_network_spikes(popIterDir, backupPrevious, plotAnalysis)
%% Re-analyzes spikes for all networks

%% Hard-coded parameters
oscParamsSuffix = 'oscillation_params';

if backupPrevious
    % Create a backup suffix
    oscParamsBackupSuffix = ['oscillation_params_backup_', create_time_stamp];

    % Locate all oscillation parameter paths
    [~, oscParamPaths] = ...
        all_files('Directory', popIterDir, ...
                    'Suffix', oscParamsSuffix, 'Extension', 'csv', ...
                    'Recursive', true, 'ForceCellOutput', true);
                
    % Create backup paths
    oscParamBackupPaths = ...
        replace(oscParamPaths, oscParamsSuffix, oscParamsBackupSuffix);

    % Backup parameters files
    cellfun(@(x, y) movefile(x, y), oscParamPaths, oscParamBackupPaths);
end

% Find all network subdirectories
[~, netSimDirs] = all_subdirs('Directory', popIterDir, 'Level', 2);

% Analyze spikes for all network subdirectories
array_fun(@(x) m3ha_network_analyze_spikes('Infolder', x, ...
                'PlotFlag', plotAnalysis), ...
            netSimDirs, 'UniformOutput', false);
% cellfun(@(x) m3ha_network_analyze_spikes('Infolder', x, ...
%                 'PlotFlag', plotAnalysis), ...
%         netSimDirs, 'UniformOutput', false);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function combinedTable = combine_osc_params (popIterDir, candCellSheetPath, ...
                                rankNumsToUse, combinedPath, networkNamesToUse)
% TODO: Add candidate IDs

%% Hard-coded parameters
rankNumStr = 'rankNum';
cellNameStr = 'cellName';
seedNumStr = 'seedNumber';
oscParamsSuffix = 'oscillation_params';

%% Do the job
% Read the candidate cell table
candCellTable = readtable(candCellSheetPath, 'ReadRowNames', true);

% Find the cell names to use from the table
if isempty(networkNamesToUse)
    % TODO: table_lookup.m
    % TODO: networkNamesToUse = table_lookup(candCellTable, cellNameStr, ...
    %                                       rankNumStr, rankNumsToUse)
    rankNumbersAll = candCellTable.(rankNumStr);
    cellNamesAll = candCellTable.(cellNameStr);
    networkNamesToUse = match_positions(cellNamesAll, ...
                                    rankNumbersAll, rankNumsToUse);
end

% Find all seed number subdirectories
[~, seedNumDirs] = all_subdirs('Directory', popIterDir, 'Recursive', false, ...
                                'Prefix', 'seedNumber');

% Extract all tables for each seed number
oscParamTablesCell = ...
    cellfun(@(seedNumDir) retrieve_osc_param_tables(seedNumDir, ...
                                        networkNamesToUse, oscParamsSuffix, ...
                                        seedNumStr, cellNameStr), ...
            seedNumDirs, 'UniformOutput', false);

% Vertically concatenate the cell arrays
oscParamTables = apply_over_cells(@vertcat, oscParamTablesCell);

% Vertically concatenate the tables
combinedTable = apply_over_cells(@vertcat, oscParamTables);

% Join the candidate cell info to the table
combinedTable = join(combinedTable, candCellTable, 'Keys', cellNameStr);

% Save the table
writetable(combinedTable, combinedPath);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function combine_activation_profiles (popIterDir, outFolder, epasToPlot, ...
                                        candidateLabels)

%% Hard-coded parameters
oscDataSuffix = 'oscillation_data';
candLabelRegExp = 'candidateIDs_[0-9,-]*';

% Find all oscillation data matfiles with this candidate label
[~, oscDataPaths] = ...
    all_files('Directory', popIterDir, 'Recursive', true, ...
                'Suffix', oscDataSuffix, 'Extension', 'mat');

% Extract all candidate label strings
candidateStrs = extract_substrings(oscDataPaths, 'RegExp', candLabelRegExp);

% Find all possible candidate labels
if isempty(candidateLabels)
    candidateLabels = unique(candidateStrs);
end

cellfun(@(c) combine_activation_profiles_helper(c, popIterDir, ...
                                                outFolder, epasToPlot), ...
        candidateLabels);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function combine_activation_profiles_helper (candidateLabel, popIterDir, ...
                                                outFolder, epasToPlot)

%% Hard-coded parameters
oscDataSuffix = 'oscillation_data';
seedNumStr = 'seedNumber';
seedNumLabelRegExp = [seedNumStr, '_[0-9]*'];
oscDataStr = 'oscData';
oscParamsStr = 'oscParams';

%% Do the job
% Find all oscillation data matfiles with this candidate label
[~, oscDataPaths] = ...
    all_files('Directory', popIterDir, 'Recursive', true, ...
                'Keyword', candidateLabel, 'Suffix', oscDataSuffix, ...
                'Extension', 'mat');

% Extract the seed number labels
seedNumLabels = extract_substrings(oscDataPaths, 'RegExp', seedNumLabelRegExp);

% Extract the base name
popIterDirName = extract_fileparts(popIterDir, 'base');

% Keep only oscillation data matfiles under a seed number directory
toKeep = ~isemptycell(seedNumLabels);
oscDataPaths = oscDataPaths(toKeep);
seedNumLabels = seedNumLabels(toKeep);

% Extract the seed numbers
seedNums = cellfun(@(x) sscanf_full(x, '%d'), seedNumLabels);

% Extract all data tables
oscDataMatFiles = cellfun(@matfile, oscDataPaths, 'UniformOutput', false);
oscDataTables = cellfun(@(m) m.(oscDataStr), ...
                        oscDataMatFiles, 'UniformOutput', false);

% Extract all condition strings from the first params table
oscParamsTable = oscDataMatFiles{1}.(oscParamsStr);
condStrs = oscParamsTable.Properties.RowNames;
nCells = oscParamsTable{:, 'nCells'};

% Create a figure path for each condition string
figPathBases = fullfile(outFolder, strcat(popIterDirName, '_', ...
                    candidateLabel, '_', condStrs, '_activation_profile'));
figTitleBases = replace(strcat(candidateLabel, '_', condStrs), '_', '\_');

% TEMP: TODO
condStrs = {1; 2; 3; 4};

% Plot mean activation profiles
cellfun(@(a, b, c, d) plot_mean_activation_profiles(a, b, c, d, ...
                        seedNums, oscDataTables, epasToPlot), ...
        figPathBases, figTitleBases, condStrs, num2cell(nCells));

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plot_mean_activation_profiles (figPathBase, figTitleBase, ...
                                        condStr, nCells, seedNums, ...
                                        oscDataTables, epasToPlot)

% Compute the corresponding TCepas value
TCepasValues = -75 + mod(seedNums, 16);

% Unique epas values
uniqueEpas = unique(TCepasValues);

% Restrict unique epas values
if ~isempty(epasToPlot)
    uniqueEpas = intersect(uniqueEpas, epasToPlot);
end

% Create epas labels
uniqueEpasLabels = create_labels_from_numbers(uniqueEpas, 'Prefix', 'epas = ');

% Count unique epas values
nEpas = numel(uniqueEpas);

% Extract the activation profiles for TC
[timeBinsSeconds, percentActivatedTC] = ...
    argfun(@(colStr) cellfun(@(x) x{condStr, colStr}{1}, ...
                        oscDataTables, 'UniformOutput', false), ...
            'timeBinsSeconds', 'percentActivatedTC');

% Group activation profiles by TCepas value
percentActivatedEachEpas = ...
    arrayfun(@(epas) percentActivatedTC(TCepasValues == epas), ...
            uniqueEpas, 'UniformOutput', false);

% Compute the combined trace for each TCepas value
[meanAct, lowerAct, upperAct] = ...
    argfun(@(method) ...
            cellfun(@(traces) compute_combined_trace(traces, method), ...
                    percentActivatedEachEpas, 'UniformOutput', false), ...
            'mean', 'lower95', 'upper95');

% Force as matrices
[meanAct, lowerAct, upperAct] = ...
    argfun(@force_matrix, meanAct, lowerAct, upperAct);

% Decide on colors
% TODO: 'ForceCellOutput' for decide_on_colormap.m
% colors = decide_on_colormap([], nEpas);
% colorsCell = arrayfun(@(i) colors(i, :), transpose(1:nEpas), ...
%                         'UniformOutput', false);

% Create a figure
fig = set_figure_properties('AlwaysNew', true);

% Hold on
hold on;

% Plot the mean activation profiles
handles = plot_tuning_curve(timeBinsSeconds{1}, meanAct, ...
                            'LowerCI', lowerAct, 'UpperCI', upperAct, ...
                            'ColumnLabels', uniqueEpasLabels, ...                            
                            'LineWidth', 1);

ylim([0, nCells]);
xlabel('Time (s)');
ylabel('Percent Activated (%)');
title(['Activation profile for ', figTitleBase]);
legend(handles.curves, 'location', 'northeast');

% Save the figure
save_all_figtypes(fig, [figPathBase, '_orig.png'], 'png');

% Update for CorelDraw
update_figure_for_corel(fig);

% Save the figure
save_all_figtypes(fig, [figPathBase, '.png'], {'png', 'epsc'});

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function oscParamTables = retrieve_osc_param_tables (seedNumDir, ...
                                        networkNamesToUse, oscParamsSuffix, ...
                                        seedNumStr, cellNameStr)

% Hard-coded parameters
TCepasStr = 'TCepas';

% Force as a column cell array
networkNamesToUse = force_column_cell(networkNamesToUse);

% Extract the seed number
seedNumber = sscanf_full(extract_fileparts(seedNumDir, 'base'), '%d');

% Compute the TC epas
TCepas = -75 + mod(seedNumber, 16);

% Locate corresponding oscillation parameter paths
[~, oscParamPaths] = ...
    find_matching_files(networkNamesToUse, 'Directory', seedNumDir, ...
                        'Suffix', oscParamsSuffix, 'Extension', 'csv', ...
                        'Recursive', true, 'ForceCellOutput', true);

% Read the oscillation parameter tables
oscParamTables = cellfun(@readtable, oscParamPaths, 'UniformOutput', false);

% Add the TC epas to the tables
oscParamTables = ...
    cellfun(@(x, y) addvars_custom(x, TCepas, ...
                            'NewVariableNames', TCepasStr, 'Before', 1), ...
            oscParamTables, 'UniformOutput', false);

% Add the seed number to the tables
oscParamTables = ...
    cellfun(@(x, y) addvars_custom(x, seedNumber, ...
                            'NewVariableNames', seedNumStr, 'Before', 1), ...
            oscParamTables, 'UniformOutput', false);

% Add the cell name to the tables
oscParamTables = ...
    cellfun(@(x, y) addvars_custom(x, {y}, 'NewVariableNames', cellNameStr, ...
                                    'Before', 1), ...
            oscParamTables, networkNamesToUse, 'UniformOutput', false);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function statsTable = m3ha_network_compute_statistics (popDataPath, gIncr, ...
                                            measureStr, measureTitle, method)
%% Computes all statistics for the 2-cell network

%% Hard-coded parameters
cellNameStr = 'cellName';
seedNumStr = 'seedNumber';
gIncrStr = 'gIncr';
pharmStr = 'pCond';
dclamp2NetworkAmpRatio = 12;

%% Do the job
% Read the data table
popDataTable = readtable(popDataPath);

% Restrict to the rows with given gIncr
rowsToUse = round(popDataTable.(gIncrStr) * dclamp2NetworkAmpRatio) == gIncr;

% Change the measure strings the original non-averaged strings
switch method
    case 'mean'
        measureStrNoMean = ...
            replace(measureStr, {'mean', 'oscillationProbability'}, ...
                                            {'', 'hasOscillation'});
        measureStrOrig = lower_first_char(measureStrNoMean);
    case 'groupByCell'
        measureStrOrig = measureStr;
    otherwise
        error('Not implemented yet!');
end

% Locate the columns of interest
colsOfInterest = [{cellNameStr}; {seedNumStr}; {pharmStr}; measureStrOrig];

% Extract the table of interest
popTableOfInterest = popDataTable(rowsToUse, colsOfInterest);

% Compute statistics for each measure of interest
[allValues, pharmCondition] = ...
    cellfun(@(x) m3ha_network_stats_helper(popTableOfInterest, seedNumStr, ...
                                        pharmStr, cellNameStr, x, method), ...
                    measureStrOrig, 'UniformOutput', false);

% Create the statistics table
statsTable = table(measureTitle, measureStr, pharmCondition, allValues, ...
                    'RowNames', measureStr);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [allValuesEachPharm, pharmCondition] = ...
                m3ha_network_stats_helper (popDataTable, seedNumStr, ...
                                    pharmStr, cellNameStr, measureStr, method)
%% Computes the statistics for one measure

%% Do the job
% Extract from table
pharmAll = popDataTable.(pharmStr);
cellNameAll = popDataTable.(cellNameStr);
seedNumberAll = popDataTable.(seedNumStr);

% Get all possible pharmacological conditions
pharmCondition = force_column_cell(num2cell(unique(pharmAll, 'sorted')));

% Get all cell names
uniqueCellNames = force_column_cell(unique(cellNameAll));

% Find corresponding row numbers
rowsEachCellEachPharm = ...
    cellfun(@(p) cellfun(@(c) pharmAll == p & strcmp(cellNameAll, c), ...
                        uniqueCellNames, 'UniformOutput', false), ...
            pharmCondition, 'UniformOutput', false);

% Get mean values across iterations for all cells
%    for each pharm condition, for this measure
switch method
    case 'mean'
        allValuesEachPharm = ...
            cellfun(@(a) ...
                    cellfun(@(b) nanmean(popDataTable{b, measureStr}), a), ... 
                rowsEachCellEachPharm, 'UniformOutput', false);
    case 'groupByCell'
        allValuesEachPharm = ...
            cellfun(@(a) ...
                    cellfun(@(b) popDataTable{b, measureStr}, ...
                            a, 'UniformOutput', false), ... 
                rowsEachCellEachPharm, 'UniformOutput', false);
    otherwise
        error('Not implemented yet!');
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function m3ha_plot_grouped_jitter (statsPath, outFolder, rowsToPlot)
% TODO: Pull out as its own function

%% Hard-coded parameters
figWidth = 3.4;
figHeight = 3;
figTypes = {'png', 'epsc'};
otherArguments = struct;

%% Preparation
% Set default output directory
if isempty(outFolder)
    outFolder = extract_fileparts(statsPath, 'directory');
end

% Load stats table
disp('Loading statistics for grouped jitter plots ...');
if isfile(statsPath)
    load(statsPath, 'statsTable', 'pharmLabels', 'conditionLabel');
else
    fprintf('%s does not exist!\n', statsPath);
    return;
end

% Restrict to measures to plot
if ~(ischar(rowsToPlot) && strcmp(rowsToPlot, 'all'))
    statsTable = statsTable(rowsToPlot, :);
end

% Extract variables
allMeasureTitles = statsTable.measureTitle;
allMeasureStrs = statsTable.measureStr;
allValues = statsTable.allValues;

% Create figure bases
allFigBases = combine_strings({allMeasureStrs, conditionLabel});

% Create full path bases
allFigPathBases = fullfile(outFolder, allFigBases);

%% Do the job
% Plot all grouped jitter plots
disp('Plotting grouped jitter plots ...');
handles = ...
    cellfun(@(a, b, c) m3ha_plot_jitter_helper(...
                            a, b, pharmLabels, c, ...
                            figHeight, figWidth, ...
                            figTypes, otherArguments), ...
            allValues, allMeasureTitles, allFigPathBases);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function handles = ...
            m3ha_plot_jitter_helper (allValues, measureTitle, pharmLabels, ...
                                        figPathBase, figHeight, figWidth, ...
                                        figTypes, otherArguments)

% Hard-coded parameters
xTickAngle = 320;

% Create figure
fig = set_figure_properties('AlwaysNew', true);

% Plot groups as a grouped jitter plot
jitters = plot_grouped_jitter(allValues, 'XTickLabels', pharmLabels, ...
                        'XTickAngle', xTickAngle, 'YLabel', measureTitle, ...
                        otherArguments);

% Save the figure
save_all_figtypes(fig, [figPathBase, '_orig'], 'png');

% Set y axis limits based on measureTitle
switch measureTitle
    case 'LTS probability'
        ylim([0, 1]);
    case 'LTS onset time (ms)'
        ylim([0, 2000]);
    case 'Spikes Per LTS'
        ylim([0, 6.5]);
    case 'LTS maximum slope (V/s)'
        ylim([0, 5]);
    case 'LTS amplitude (mV)'
        ylim([-75, -45]);
        yticks(-75:10:-45);
    otherwise
        % Do nothing
end

% Update figure for CorelDraw
update_figure_for_corel(fig, 'Units', 'centimeters', ...
                        'Height', figHeight, 'Width', figWidth, ...
                        'ScatterMarkerSize', 3);

% Save the figure
save_all_figtypes(fig, figPathBase, figTypes);

% Save in handles
handles.fig = fig;
handles.jitters = jitters;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
OLD CODE:

seedNumDirs = fullfile(popIterDir, create_labels_from_numbers(0:14, ...
                                    'Prefix', 'seedNumber_'));

%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
