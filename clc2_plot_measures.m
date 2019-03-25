% clc2_plot_measures.m
%% Plots all measures of interest across slices

% Requires:
%       cd/combine_variables_across_tables.m
%       cd/extract_fileparts.m
%       cd/plot_table.m

% File History:
% 2019-03-15 Created by Adam Lu
% 2019-03-25 Now colors by phase number
% 

%% Hard-coded parameters
% Protocol parameters
sweepLengthSec = 60;

% Analysis parameters
nSweepsToAverage = 10;

% File patterns
sliceFilePattern = '.*slice.*';
outFolder = pwd;
timeLabel = 'Time';

% Must be consistent with parse_multiunit.m
varsToPlot = {'oscIndex1'; 'oscIndex2'; 'oscIndex3'; 'oscIndex4'; ...
                    'oscPeriod1Ms'; 'oscPeriod2Ms'; ...
                    'oscDurationSec'; ...
                    'nSpikesTotal'; 'nSpikesIn10s'; 'nSpikesInOsc'; ...
                    'nBurstsTotal'; 'nBurstsIn10s'; 'nBurstsInOsc'; ...
                    'nSpikesPerBurst'; 'nSpikesPerBurstIn10s'; ...
                    'nSpikesPerBurstInOsc'};
varLabels = {'Oscillatory Index 1'; 'Oscillatory Index 2'; ...
                'Oscillatory Index 3'; 'Oscillatory Index 4'; ...
                'Oscillation Period 1 (ms)'; 'Oscillation Period 2 (ms)'; ...
                'Oscillation Duration (s)'; ...
                'Total Spike Count'; 'Number of Spikes in First 10 s'; 
                'Number of Spikes in Oscillation'; ...
                'Total Number of Bursts'; 'Number of Bursts in First 10 s'; ...
                'Number of Bursts in Oscillation'; ...
                'Number of Spikes Per Burst'; ...
                'Number of Spikes Per Burst in First 10 s'; ...
                'Number of Spikes Per Burst in Oscillation'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Preparation
% Find all files with the pattern *slice*_params in the file name
[~, sliceParamSheets] = all_files('Keyword', 'slice', 'Suffix', 'params');

% Extract the common prefix
prefix = extract_fileparts(sliceParamSheets, 'commonprefix');

% Extract the distinct parts of the file names
fileLabels = extract_fileparts(sliceParamSheets, 'distinct');

% Create table labels
tableLabels = strcat(prefix, {': '}, varLabels);

% Create figure names
figNames = fullfile(outFolder, strcat(prefix, '_', varsToPlot, '.png'));
figNamesByPhase = fullfile(outFolder, ...
                        strcat(prefix, '_', varsToPlot, '_byphase.png'));
figNamesChevron = fullfile(outFolder, ...
                        strcat(prefix, '_', varsToPlot, '_chevron.png'));

% Read all slice parameter spreadsheets
sliceParamsTables = cellfun(@readtable, sliceParamSheets, ...
                            'UniformOutput', false);

% Create a time column (time in minutes since drug on)
sliceParamsTables = ...
    cellfun(@(x) create_time_rel_to_drugon(x, sweepLengthSec), ...
                sliceParamsTables, 'UniformOutput', false);

% Combine with phase number information
varsToCombine = [varsToPlot, repmat({'phaseNumber'}, size(varsToPlot))];

% Create the phaseNumber variables for the combined tables
phaseVars = strcat('phaseNumber_', fileLabels);

% Combine variables across tables
measureTables = combine_variables_across_tables(sliceParamsTables, ...
                'Keys', 'Time', 'VariableNames', varsToCombine, ...
                'InputNames', fileLabels, 'OmitVarName', false, ...
                'OutFolder', outFolder, 'Prefix', prefix, 'SaveFlag', true);

% Average over the last 10 sweeps
chevronTables = cellfun(@(x) average_last_of_each_phase(x, nSweepsToAverage), ...
                        measureTables, 'UniformOutput', false);

%% Do the job
% Convert to timetables
measureTimeTables = cellfun(@table2timetable, ...
                            measureTables, 'UniformOutput', false);

% Plot all columns together
figs = cellfun(@(x, y, z, w, v) plot_table(x, 'PlotSeparately', false, ...
                                'VariableNames', strcat(y, '_', fileLabels), ...
                                'ReadoutLabel', z, 'TableLabel', w, ...
                                'XLabel', timeLabel, 'FigName', v, ...
                                'RemoveOutliers', true), ...
                measureTimeTables, varsToPlot, varLabels, tableLabels, figNames);

close all;

% Plot all columns together colored by phase
figs = cellfun(@(x, y, z, w, v) plot_table(x, 'PlotSeparately', false, ...
                                'VariableNames', strcat(y, '_', fileLabels), ...
                                'PhaseVariables', phaseVars, ...
                                'ReadoutLabel', z, 'TableLabel', w, ...
                                'XLabel', timeLabel, 'FigName', v, ...
                                'RemoveOutliers', true), ...
        measureTimeTables, varsToPlot, varLabels, tableLabels, figNamesByPhase);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function myTable = create_time_rel_to_drugon(myTable, sweepLengthSec)
%% Creates a time column in minutes since drug onset

% Count the number of rows
nRows = height(myTable);

% Get the phase numbers
phaseNum = myTable.phaseNumber;

% Get the first row that is drug on
%   Note: this is set #2
rowDrugOn = find(phaseNum == 2, 1, 'first');

% Compute time in sweeps relative to drug on
timeSwps = transpose(1:nRows) - rowDrugOn;

% Convert to minutes
timeMin = timeSwps / (sweepLengthSec / 60);

% Convert to a duration vector
Time = minutes(timeMin);

% Add a time column to the table
myTable = addvars(myTable, Time, 'Before', 1);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function outTable = average_last_of_each_phase(inTable, nSweepsToAverage)
%% Averages over the last nSweepsToAverage sweeps of each phase
% Note: all distinct identifiers must have a matching phase variable column

% Get all variable names
allVarNames = inTable.Properties.VariableNames;

% Remove the Time column if exists
% TODO FOR UNDERGRAD: is_variable_of_table.m
if ismember('Time', allVarNames)
    inTable = removevars(inTable, 'Time');
end

% Get all variable names that are left
allVarNames = inTable.Properties.VariableNames;

% Find the phase variable names
[~, phaseVars] = find_in_strings('phase.*', allVarNames, 'SearchMode', 'reg');

% Collect the rest of the variable names
readoutVars = setdiff(allVarNames, phaseVars);

% Extract the unique identifiers
uniqueIds = extract_distinct_fileparts(readoutVars, 'Delimiter', '_');

% Count the number of unique identifiers
nUniqueIds = numel(uniqueIds);

% Find matching phase variables for each unique identifiers
[~, phaseVars] = ...
    cellfun(@(x) find_in_strings(x, phaseVars, 'SearchMode', 'substrings'), ...
            uniqueIds, 'UniformOutput', false);

% Find the row indices for the last nSweepsToAverage sweeps for each phase,
%   for each unique phase ID
indToAvg = cellfun(@(x) find_last_ind_each_phase(inTable.x, nSweepsToAverage), ...
                    phaseVars, 'UniformOutput', false);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function indLastEachPhase = find_last_ind_each_phase(phaseVec, nLastIndices)
%% Find the last nLastIndices indices for each phase in the phaseVec

% Get the unique phases
% TODO: use unique_custom.m
phaseVecNoNaN = phaseVec(~isnan(phaseVec));
uniquePhases = unique(phaseVecNoNaN, 'stable');

% Count the number of unique phases
nPhases = numel(uniquePhases);

% Find the last index for each phase
lastIndexEachPhase = cellfun(@(x) find(ismatch(phaseVec, x), 1, 'last'), ...
                                uniquePhases);

% Construct the last nLastIndices indices
indLastEachPhase = cellfun(@(x) , ...
                                lastIndexEachPhase, 'UniformOutput', false);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
OLD CODE:

%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%