function [done, outparams, hfig] = m3ha_optimizer_4compgabab (outparams, hfig)
% OPTIMIZER  Passes parameters to NEURON (which runs simulations and saves
% data as .dat files), loads .dat file data, plots data and compares with
% experimental data. Save all this as well (timestamp for now)
%
% realData  Experimental data from OPTIMIZERGUI.m
% 
% outparams   GUI parameters from OPTIMIZERGUI.m
%   outparams.swpWeights : weights of sweeps
%   outparams.swpedges : left and right edges of sweep region to analyze
%   outparams.ltsWeights : weights of LTS parameters
%   outparams.modeselected : mode to run OPTIMIZER.m in (either
%       'modebutton_auto' or 'modebutton_manual')
%   outparams.neuronparams : values of parameters for NEURON 
%   outparams.neuronparamnames : names of parameters for NEURON (e.g. pcabar1,
%       actshift_itGHK, etc)
%   outparams.simplexParams : values of simplex parameters for
%   FMINSEARCH2.m
%   outparams.simplexParamNames : names of simplex parameters for
%   FMINSEARCH2.m
%   outparams.sortedswpnum : sweep numbers of sweeps called into
%   OPTIMIZER.m; use to figure out amplitude of current injected during CCIV
%   protocol
% 
% done (0 or 1)   Output to pass to OPTIMIZERGUI to signal end of
%                     NEURON and FMINSEARCH2 (if in auto mode)
%
% Requires:
%       cd/m3ha_compare_neuronparams2.m
%       ~/Downloaded_Functions/subplotsqueeze.m
%       ~/Adams_Functions/check_dir.m
%       ~/Adams_Functions/find_in_strings.m
%       ~/Adams_Functions/locate_functionsdir.m
%       ~/Adams_Functions/m3ha_fminsearch3.m
%       ~/Adams_Functions/m3ha_log_errors_params.m
%       ~/Adams_Functions/m3ha_neuron_create_new_initial_params.m
%       ~/Adams_Functions/m3ha_neuron_run_and_analyze.m
%       ~/Adams_Functions/set_fields_zero.m
%       ~/Adams_Functions/restore_fields.m
%       ~/Adams_Functions/structs2vecs.m
% Used by:
%       cd/singleneuronfitting42.m and later versions
%       cd/m3ha_optimizergui_4compgabab.m
% 
% By Christine Lee Kyuyoung 2011-01-16
% last modified by CLK 2014-04
% 2016-07-15 - Added MANUAL WITH JITTER
% 2016-07-19 - Changed cols{k} to cols(cgn, :)
% 2016-07-19 - Changed order of subplot(5,1,1) & subplot(5,1,2) in simtraces
% 2016-07-20 - Modified JITTER mode and added AUTO WITH JITTER
% 2016-07-20 - Changed npercg & ncg, simtraces axes
% 2016-10-03 - Added current pulse response
% 2016-10-06 - Reorganized code
% 2016-10-06 - Moved update_sliderposition to optimizergui_4compgabab.m
% 2016-10-06 - xlimits now uses outparams.fitreg instead of outparams.swpedges
% 2016-10-06 - Renamed lots of figures
% 2016-10-06 - Renamed figure handles so that they are now all in a structure 
%               hfig that is passed to and from functions
% 2016-10-07 - current pulse electrode current and responses are now graphed
% 2016-10-07 - Plot flags are now set to zero before optimization and 
%               set back afterwards
% 2017-01-17 - Modified runauto so that it will fit current pulse response
% 2017-01-25 - Randomize initial parameters and run simplex nInitConds times;
%               added generate_IC() & find_best_params()
% 2017-01-26 - Completed generate_IC()
% 2017-04-21 - Now uses m3ha_log_errors_params.m to generate 
%               errors_and_params_log_manual.csv
% 2017-04-21 - Added outFolderName to output file names
% 2017-05-02 - Now uses parfor to run through all initial conditions
% 2017-05-02 - Added 'Iteration #' to compare_params.csv
% 2017-05-02 - Changed simplex count to outparams.simplexNum and 
%               fixed the fact that it wasn't updated during active fitting
% 2017-05-12 - Now saves runauto_results in outfolder
% 2017-05-13 - Now updates outparams.runnumTotal here
% 2017-05-13 - Now returns errCpr & err in outparams
% 2017-05-13 - Now gets outFolderName from outparams
% 2017-05-13 - Now updates outparams.neuronparams to 
%               initCond.neuronparams in generate_IC()
% 2017-05-13 - Now initializes outparams0 within parfor loop
% 2017-05-15 - Now changes outparams.prefix so that '_cpr' is already 
%               incorporated before passive fitting
% 2017-05-15 - Now changes neuronparams_use before calling fminsearch3_4compgabab 
%               to reflect passive or active
% 2017-05-16 - Now runs NEURON with full plots both before and after fitting
% 2017-05-16 - parfor is now conditional on outparams.MaxNumWorkersIC
% 2017-05-17 - update_errorhistoryplot() now plots lts errors if computed
% 2017-05-17 - Added outparams.fitPassiveFlag & outparams.fitActiveFlag
% 2017-05-17 - Moved update_sweeps_figures() to m3ha_neuron_run_and_analyze.m
% 2017-05-19 - Fixed the fact that simplex.initError was used to select  
%               best simplex; simplex.error is now simplex.totalError
% 2017-05-22 - Changed line width and indentation
% 2017-05-22 - Added outparams.fitTogetherFlag
% 2017-05-23 - Removed modeselected from outparams and 
%               replaced with updated outparams.runmode
% 2017-05-23 - Added otherwise to all switch statements
% 2017-06-19 - Fixed runmode under runmanual
% 2017-07-29 - Now saves the best parameters under /pfiles/ if err improves
% 2017-08-10 - Now plots activation/inactivation & I-V curves after optimization
% 2018-01-24 - Added isdeployed
% 2018-03-08 - Changed compare_neuronparams() to compare_neuronparams2()
% 2018-04-24 - Now does not use parfor to run through all initial conditions
%               Some initial conditions take much longer than others
% 2018-08-08 - Now makes sure plotOverlappedFlag is false during fitting
% 2018-08-08 - Now forces constrains all initial conditions for 
%               epas and gpas according to epasEstimate and RinEstimate
% 2018-08-10 - Changed outparams.fitregCpr to use outparams.fitwinCpr
% 2018-08-16 - Now does not use parfor for active fitting
% 2018-12-10 - Updated placement of jitterFlag
% 2018-12-11 - Moved code to m3ha_neuron_create_new_initial_params.m

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% If not compiled, add directories to search path for required functions
if ~isdeployed
    % Locate the functions directory
    functionsDirectory = locate_functionsdir;

    % Add path for check_dir.m, etc.
    addpath(fullfile(functionsDirectory, 'Adams_Functions')); 

    % Add path for subplotsqueeze.m, etc.
    addpath(fullfile(functionsDirectory, 'Downloaded_Functions')); 
end

%% Preparation
% Change fitting flags if necessary
% TODO: Fix
%{
if outparams.fitPassiveFlag && ...
    ~any(neuronparamispas .* outparams.neuronparams_use)
    outparams.fitPassiveFlag = false;
    fprintf(['No passive parameter is fitted, ', ...
            'so passive fitting is turned OFF!\n\n']);
end
if outparams.fitActiveFlag && ...
    ~any(~neuronparamispas .* outparams.neuronparams_use)
    outparams.fitActiveFlag = false;
    fprintf(['No active parameter is fitted, ', ...
            'so active fitting is turned OFF!\n\n']);
end
%}

% Initialize the prefix as the date-time-cell stamp
outparams.prefix = outparams.dateTimeCellStamp;

% If in jitter mode and if parameter is checked, add jitter
if outparams.runmode == 3
    outparams.jitterFlag = true;
else
    outparams.jitterFlag = false;
end

%% Run based on manual or auto mode
switch outparams.runmode
case {1, 3}
    [~, ~, outparams, hfig] = runmanual(outparams, hfig);
case 2
    %% Save old NEURON parameters
    oldNeuronParams = outparams.neuronParamsTable.Value;

    %% Run NEURON with baseline parameters with full plots
    prefixOrig = outparams.prefix;                         % save original prefix
    outparams.prefix = [outparams.prefix, '_bef'];          % change prefix for "before fitting"
    [~, ~, outparams, hfig] = runmanual(outparams, hfig);
    outparams.prefix = prefixOrig;                         % restore original prefix
    drawnow

    %% Optimize parameters
    [~, ~, outparams, hfig] = runauto(outparams, hfig);
    drawnow

    %% Run NEURON with best parameters again with full plots
    prefixOrig = outparams.prefix;                         % save original prefix
    outparams.prefix = [outparams.prefix, '_aft'];          % change prefix for "after fitting"
    [~, ~, outparams, hfig] = runmanual(outparams, hfig);
    outparams.prefix = prefixOrig;                         % restore original prefix
    drawnow

    %% If error improved, save best parameters as 
    %   bestparams_[cellName].p under /pfiles/
%{
    if outparams.fitActiveFlag && ...
        outparams.err{outparams.runnumTotal}.totalError < outparams.err{1}.totalError && ...
        ~outparams.debugFlag
        copyfile(fullfile(outparams.outFolderName, ...
                            [outparams.prefix, '_aft.p']), ...
                            outparams.bestparamsPFile);
        fprintf('Best parameters copied for %s!\n\n', outparams.prefix);
    end
%}    

    %% Compare NEURON parameters before and after 
    %   by plotting activation/inactivation & I-V curves
    newNeuronParams = outparams.neuronParamsTable.Value;
    neuronParamNames = outparams.neuronParamsTable.Properties.RowNames;
    bothParamValues = {oldNeuronParams, newNeuronParams};
    bothParamNames = {neuronParamNames, neuronParamNames};
    suffices = {['_', outparams.prefix, '_bef'], ...
                ['_', outparams.prefix, '_aft']};
% TODO: Fix
%     m3ha_compare_neuronparams2(bothParamValues, bothParamNames, suffices, ...
%                         'OutFolder', outparams.outFolderName);

case 4                                       %%% TODO: Unfinished
    [~, ~, outparams, hfig] = ...
        runauto_w_jitter(outparams, hfig);
otherwise
    outparams.runmode = 1;
    fprintf('Warning: run mode out of range, changed to 1!\n\n');
end

%% Make all figures visible and update
if outparams.showSweepsFlag
    figs = fieldnames(hfig);
    for k = 1:numel(figs)
        set(hfig.(figs{k}), 'Visible', 'on');
        drawnow
    end
end

%% Used for runbutton_toggle in m3ha_optimizergui_4compgabab.m
done = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [errCpr, err, outparams, hfig] = runmanual(outparams, hfig)
%% MANUAL or JITTER modes: Simulate each sweep once and compare with real data

% Update run counts
switch outparams.runmode
case {1, 2}         % manual mode is also run before and after auto mode
    outparams.runnumManual = outparams.runnumManual + 1;
case 3
    outparams.runnumJitter = outparams.runnumJitter + 1;
otherwise
    error('runmode should be 1 or 3!\n');
end
outparams.runnumTotal = outparams.runnumTotal + 1;

% Simulate current pulse response only if outparams.fitPassiveFlag is true
if outparams.fitPassiveFlag         % if fitting passive parameters
    %%%%%% 
    %%%%%%%%%%%%%
    % Set sim mode
    outparams.simMode = 'passive';

    % Save original prefix
    prefixOrig = outparams.prefix;

    % Change prefix for passive-parameters-fitting
    outparams.prefix = [outparams.prefix, '_cpr'];

    % Run all simulations once
    [errCpr, outparams.hfig] = ...
        m3ha_neuron_run_and_analyze(outparams.neuronParamsTable, ...
            'HFig', outparams.hfig, ...
            'SimMode', outparams.simMode, 'DebugFlag', outparams.debugFlag, ...
            'Prefix', outparams.prefix, 'OutFolder', outparams.outFolderName, ...
            'CustomHoldCurrentFlag', outparams.customHoldCurrentFlag, ...
            'OnHpcFlag', outparams.onHpcFlag, ...
            'GenerateDataFlag', outparams.generateDataFlag, ...
            'AverageCprFlag', outparams.averageCprFlag, ...
            'BootstrapCprFlag', outparams.bootstrapCprFlag, ...
            'Normalize2InitErrFlag', outparams.normalize2InitErrFlag, ...
            'SaveSimCmdsFlag', outparams.saveSimCmdsFlag, ...
            'SaveStdOutFlag', outparams.saveStdOutFlag, ...
            'SaveSimOutFlag', outparams.saveSimOutFlag, ...
            'SaveParamsFlag',outparams.saveParamsFlag, ...
            'PlotIndividualFlag', outparams.plotIndividualFlag, ...
            'PlotResidualsFlag', outparams.plotResidualsFlag, ...
            'PlotOverlappedFlag', outparams.plotOverlappedFlag, ...
            'PlotConductanceFlag', outparams.plotConductanceFlag, ...
            'PlotCurrentFlag', outparams.plotCurrentFlag, ...
            'PlotIpeakFlag', outparams.plotIpeakFlag, ...
            'PlotLtsFlag', outparams.plotLtsFlag, ...
            'PlotStatisticsFlag', outparams.plotStatisticsFlag, ...
            'PlotSwpWeightsFlag', outparams.plotSwpWeightsFlag, ...
            'PlotMarkFlag', outparams.plotMarkFlag, ...
            'ShowSweepsFlag', outparams.showSweepsFlag, ...
            'JitterFlag', outparams.jitterFlag, ...
            'Grouping', outparams.vhold, ...
            'CprWindow', outparams.cprWindow, ...
            'IpscrWindow', outparams.ipscrWindow, ...
            'RealDataIpscr', outparams.realDataIpscr, ...
            'RealDataCpr', outparams.realDataCpr, ...
            'HoldPotentialIpscr', outparams.holdPotentialIpscr, ...
            'HoldPotentialCpr', outparams.holdPotentialCpr, ...
            'CurrentPulseAmplitudeIpscr', outparams.currentPulseAmplitudeIpscr, ...
            'CurrentPulseAmplitudeCpr', outparams.currentPulseAmplitudeCpr, ...
            'GababAmp', outparams.gababAmp, ...
            'GababTrise', outparams.gababTrise, ...
            'GababTfallFast', outparams.gababTfallFast, ...
            'GababTfallSlow', outparams.gababTfallSlow, ...
            'GababWeight', outparams.gababWeight, ...
            'CustomHoldCurrentFlag', outparams.customHoldCurrentFlag, ...
            'HoldCurrentIpscr', outparams.holdCurrentIpscr, ...
            'HoldCurrentCpr', outparams.holdCurrentCpr, ...
            'HoldCurrentNoiseIpscr', outparams.holdCurrentNoiseIpscr, ...
            'HoldCurrentNoiseCpr', outparams.holdCurrentNoiseCpr, ...
            'RowConditionsIpscr', outparams.rowConditionsIpscr, ...
            'RowConditionsCpr', outparams.rowConditionsCpr, ...
            'FitWindowCpr', outparams.fitWindowCpr, ...
            'FitWindowIpscr', outparams.fitWindowIpscr, ...
            'BaseWindowCpr', outparams.baseWindowCpr, ...
            'BaseWindowIpscr', outparams.baseWindowIpscr, ...
            'BaseNoiseCpr', outparams.baseNoiseCpr, ...
            'BaseNoiseIpscr', outparams.baseNoiseIpscr, ...
            'SweepWeightsCpr', outparams.sweepWeightsCpr, ...
            'SweepWeightsIpscr', outparams.sweepWeightsIpscr);   

    % Change prefix back
    outparams.prefix = prefixOrig;
    %%%%%%%%%%%%%
    %%%%%% 

    % Log errors and parameters and save parameters as .p file
    logFileName = [outparams.dateTimeCellStamp, ...
                '_errors_and_params_log_manual.csv'];
    m3ha_log_errors_params(logFileName, outparams, errCpr);
else
    if outparams.runnumTotal > 1    % if this is not the first run
        % Use errCpr from last run
        errCpr = outparams.errCpr{outparams.runnumTotal-1};   
    else                            % if this is the first run
        % Use empty structure
        errCpr = struct;
    end
end
outparams.errCpr{outparams.runnumTotal} = errCpr;         % store error structure in outparams

% Simulate GABAB IPSC response only if outparams.fitActiveFlag is true
if outparams.fitActiveFlag
    %%%%%% 
    %%%%%%%%%%%%%
    % Set sim mode
    outparams.simMode = 'active';

    % Run all simulations once
    [err, outparams.hfig] = ...
        m3ha_neuron_run_and_analyze(outparams.neuronParamsTable, ...
            'Hfig', outparams.hfig, ...
            'SimMode', outparams.simMode, 'DebugFlag', outparams.debugFlag, ...
            'Prefix', outparams.prefix, 'OutFolder', outparams.outFolderName, ...
            'CustomHoldCurrentFlag', outparams.customHoldCurrentFlag, ...
            'OnHpcFlag', outparams.onHpcFlag, ...
            'AverageCprFlag', outparams.averageCprFlag, ...
            'BootstrapCprFlag', outparams.bootstrapCprFlag, ...
            'Normalize2InitErrFlag', outparams.normalize2InitErrFlag, ...
            'SaveSimCmdsFlag', outparams.saveSimCmdsFlag, ...
            'SaveStdOutFlag', outparams.saveStdOutFlag, ...
            'SaveSimOutFlag', outparams.saveSimOutFlag, ...
            'SaveParamsFlag',outparams.saveParamsFlag, ...
            'PlotIndividualFlag', outparams.plotIndividualFlag, ...
            'PlotResidualsFlag', outparams.plotResidualsFlag, ...
            'PlotOverlappedFlag', outparams.plotOverlappedFlag, ...
            'PlotConductanceFlag', outparams.plotConductanceFlag, ...
            'PlotCurrentFlag', outparams.plotCurrentFlag, ...
            'PlotIpeakFlag', outparams.plotIpeakFlag, ...
            'PlotLtsFlag', outparams.plotLtsFlag, ...
            'PlotStatisticsFlag', outparams.plotStatisticsFlag, ...
            'PlotSwpWeightsFlag', outparams.plotSwpWeightsFlag, ...
            'PlotMarkFlag', outparams.plotMarkFlag, ...
            'ShowSweepsFlag', outparams.showSweepsFlag, ...
            'JitterFlag', outparams.jitterFlag, ...
            'CprWindow', outparams.cprWindow, ...
            'IpscrWindow', outparams.ipscrWindow, ...
            'RealDataIpscr', outparams.realDataIpscr, ...
            'RealDataCpr', outparams.realDataCpr, ...
            'HoldPotentialIpscr', outparams.holdPotentialIpscr, ...
            'HoldPotentialCpr', outparams.holdPotentialCpr, ...
            'CurrentPulseAmplitudeIpscr', outparams.currentPulseAmplitudeIpscr, ...
            'CurrentPulseAmplitudeCpr', outparams.currentPulseAmplitudeCpr, ...
            'GababAmp', outparams.gababAmp, ...
            'GababTrise', outparams.gababTrise, ...
            'GababTfallFast', outparams.gababTfallFast, ...
            'GababTfallSlow', outparams.gababTfallSlow, ...
            'GababWeight', outparams.gababWeight, ...
            'CustomHoldCurrentFlag', outparams.customHoldCurrentFlag, ...
            'HoldCurrentIpscr', outparams.holdCurrentIpscr, ...
            'HoldCurrentCpr', outparams.holdCurrentCpr, ...
            'HoldCurrentNoiseIpscr', outparams.holdCurrentNoiseIpscr, ...
            'HoldCurrentNoiseCpr', outparams.holdCurrentNoiseCpr, ...
            'RowConditionsIpscr', outparams.rowConditionsIpscr, ...
            'RowConditionsCpr', outparams.rowConditionsCpr, ...
            'FitWindowCpr', outparams.fitWindowCpr, ...
            'FitWindowIpscr', outparams.fitWindowIpscr, ...
            'BaseWindowCpr', outparams.baseWindowCpr, ...
            'BaseWindowIpscr', outparams.baseWindowIpscr, ...
            'BaseNoiseCpr', outparams.baseNoiseCpr, ...
            'BaseNoiseIpscr', outparams.baseNoiseIpscr, ...
            'SweepWeightsCpr', outparams.sweepWeightsCpr, ...
            'SweepWeightsIpscr', outparams.sweepWeightsIpscr);   
    %%%%%%%%%%%%%
    %%%%%% 

    % Log errors and parameters and save parameters as .p file
    logFileName = [outparams.dateTimeCellStamp, ...
                '_errors_and_params_log_manual.csv'];
    m3ha_log_errors_params(logFileName, outparams, err);
else
    if outparams.runnumTotal > 1    % if this is not the first run
        % Use errCpr from last run
        err = outparams.err{outparams.runnumTotal-1};   
    else                            % if this is the first run
        % Use empty structure
        err = struct;
    end
end
outparams.err{outparams.runnumTotal} = err;                 % store error structure in outparams

% Update error history plot
% TODO: Fix
% update_errorhistoryplot(hfig, outparams);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [errCpr, err, outparams, hfig] = runauto(outparams, hfig)
%% AUTO mode: Find best parameters with m3ha_fminsearch3.m

% Update run counts
outparams.runnumAuto = outparams.runnumAuto + 1;
outparams.runnumTotal = outparams.runnumTotal + 1;

% Extract constants from outparams
cellName = outparams.cellName;
oldOutFolderName = outparams.outFolderName;

% Extract number of initial conditions
idxNInitConds = find_in_strings('nInitConds', outparams.autoParamNames);
nInitConds = outparams.autoParams(idxNInitConds);

% Turn off all flags for stats and plots for fminsearch
[outparams] = ...
    set_fields_zero(outparams, ...
        'ltsBurstStatsFlag', 'saveLtsInfoFlag', 'saveLtsStatsFlag', ...
        'saveSimCmdsFlag', 'saveStdOutFlag', 'saveSimOutFlag', ...
        'plotIndividualFlag', 'plotOverlappedFlag', 'plotResidualsFlag', ...
        'plotConductanceFlag', 'plotCurrentFlag', ...
        'plotIpeakFlag', 'plotLtsFlag', 'plotStatisticsFlag', ...
        'plotSwpWeightsFlag');

% Fit parameters
if outparams.fitTogetherFlag        % passive and active fitting done together from single initCond
    % Prepare for fitting
    fprintf('Fitting all parameters for cell %s ... \n', cellName);
    tstartAllFit = tic();          % tracks time for all-parameters-fitting
    fprintf('\n');

    % Fit all parameters
    cprInitialConditionsAll = cell(1, nInitConds);            % stores the initial parameters for each passive simplex run
    cprSimplexOutAll = cell(1, nInitConds);    % stores the simplex outputs for each passive simplex run
    cprExitFlagAll = zeros(1, nInitConds);     % stores the exitflags for each passive simplex run
    initialConditionsAll = cell(1, nInitConds);                % stores the initial parameters for each active simplex run
    simplexOutAll = cell(1, nInitConds);        % stores the simplex outputs for each active simplex run
    exitFlagAll = zeros(1, nInitConds);         % stores the exitflags for each active simplex run
    parfor iInitCond = 1:nInitConds
%    for iInitCond = 1:nInitConds
        % Initialize outparams0 for parfor
        outparams0 = outparams;

        % Store the old simplex count
        oldSimplexCt = outparams.simplexNum;

        % Prepare outparams0 for passive fit
        [outparams0, prefixOrig, neuronParamsUseOrig] = ...
            prepare_outparams_passive(outparams0);

        % Prepare outparams0 for simplex
        [outparams0] = ...
            prepare_outparams_simplex(outparams0, oldOutFolderName, oldSimplexCt, iInitCond);

        % Generate initial parameters for this run
        [cprInitialConditionsAll{iInitCond}, outparams0] = ...
            generate_IC(outparams0, iInitCond);

        % Run fminsearch for current pulse response
        %%%%%%
        %%%%%%%%%%%%%
        [cprSimplexOutAll{iInitCond}, cprExitFlagAll(iInitCond)] = ...
            m3ha_fminsearch3(outparams0);
        %%%%%%%%%%%%%
        %%%%%%

        % Restore outparams0 after passive fitting
        [outparams0] = ...
            restore_outparams_passive(outparams0, prefixOrig, neuronParamsUseOrig);

        % Use the optimized parameters
        outparams0.neuronParamsTable = cprSimplexOutAll{iInitCond}.neuronParamsTable;

        % Prepare outparams0 for active fit
        [outparams0, neuronParamsUseOrig] = ...
            prepare_outparams_active(outparams0);

        % Prepare outparams0 for simplex
        [outparams0] = ...
            prepare_outparams_simplex(outparams0, oldOutFolderName, ...
                                        oldSimplexCt + nInitConds, iInitCond);

        % Generate initial parameters for this run
        [initialConditionsAll{iInitCond}, outparams0] = ...
            generate_IC(outparams0, iInitCond);

        % Run fminsearch for GABAB IPSC response
        %%%%%%
        %%%%%%%%%%%%%
        [simplexOutAll{iInitCond}, exitFlagAll(iInitCond)] = ...
            m3ha_fminsearch3(realDataIpscr, outparams0);
        %%%%%%%%%%%%%
        %%%%%%

        % Restore outparams0 after active fit
        outparams0 = restore_outparams_active(outparams0, neuronParamsUseOrig);
    end

    % Update # of simplex runs and # of simplex steps
    outparams.simplexNum = outparams.simplexNum + nInitConds * 2;
    outparams.simplexIterCount = ...
        outparams.simplexIterCount + ...
        sum(cellfun(@(x) x.ctIterations, cprSimplexOutAll)) + ...
        sum(cellfun(@(x) x.ctIterations, simplexOutAll));

    % Find best of the optimized parameters
    cprCompareparamsfile = fullfile(oldOutFolderName, ...
                                    [outparams.prefix, '_cpr_compare_params_IC_', ...
                                    num2str(outparams.simplexNum - nInitConds * 2 + 1), ...
                                    'to', num2str(outparams.simplexNum - nInitConds), '.csv']);
    [cprSimplexOutBest, errCpr] = ...
        find_best_params(cprSimplexOutAll, cprInitialConditionsAll, cprCompareparamsfile);
    compareparamsfile = fullfile(oldOutFolderName, ...
                                [outparams.prefix, '_compare_params_IC_', ...
                                num2str(outparams.simplexNum - nInitConds + 1), ...
                                'to', num2str(outparams.simplexNum), '.csv']);
    [simplexOutBest, err] = ...
        find_best_params(simplexOutAll, initialConditionsAll, compareparamsfile);

    % Update outparams.neuronParamsTable to the best of the optimized parameters
    outparams.neuronParamsTable = simplexOutBest.neuronParamsTable;

    % Save outputs in matfile
    if outparams.saveMatFileFlag
        save(fullfile(oldOutFolderName, ...
                        [outparams.prefix, '_runauto_results_IC_', ...
                        num2str(outparams.simplexNum - nInitConds + 1), ...
                        'to', num2str(outparams.simplexNum), '.mat']), ...
            'cprInitialConditionsAll', 'cprSimplexOutAll', 'cprExitFlagAll', ...
            'initialConditionsAll', 'simplexOutAll', 'exitFlagAll', ...
            'outparams', '-v7.3');
    end


    % Print time elapsed
    time_taken_allfit = toc(tstartAllFit);
    fprintf('It took %g seconds to run the simplex method on %d initial conditions!!\n', ...
            time_taken_allfit, nInitConds);
    fprintf('\n');

else                                % do passive fitting, find best params, then do active fitting

    % Fit passive parameters
    if outparams.fitPassiveFlag && ~outparams.fitTogetherFlag
        % Prepare for passive-parameters-fitting
        fprintf('Fitting passive parameters for cell %s ... \n', cellName);
        tStartPassiveFit = tic();      % tracks time for passive-parameters-fitting
        fprintf('\n');

        % Prepare outparams for passive fit
        [outparams, prefixOrig, neuronParamsUseOrig] = ...
            prepare_outparams_passive(outparams);
        
        % Optimize passive parameters by fitting to current pulse response
        cprInitialConditionsAll = cell(1, nInitConds);            % stores the initial parameters for each simplex run
        cprSimplexOutAll = cell(1, nInitConds);    % stores the simplex outputs for each simplex run
        cprExitFlagAll = zeros(1, nInitConds);     % stores the exitflags for each simplex run
%        parfor iInitCond = 1:nInitConds
        for iInitCond = 1:nInitConds
            % Initialize outparams0 for parfor
            outparams0 = outparams;

            % Store the old simplex count
            oldSimplexCt = outparams.simplexNum;

            % Prepare outparams0 for simplex
            [outparams0] = ...
                prepare_outparams_simplex(outparams0, oldOutFolderName, oldSimplexCt, iInitCond);

            % Generate initial parameters for this run
            [cprInitialConditionsAll{iInitCond}, outparams0] = generate_IC(outparams0, iInitCond);

            % Run fminsearch for current pulse response
            %%%%%%
            %%%%%%%%%%%%%
            [cprSimplexOutAll{iInitCond}, cprExitFlagAll(iInitCond)] = ...
                m3ha_fminsearch3(outparams0);
            %%%%%%%%%%%%%
            %%%%%%
        end

        % Restore outparams after passive fit
        [outparams] = ...
            restore_outparams_passive(outparams, prefixOrig, neuronParamsUseOrig);

        % Update # of simplex runs and # of simplex steps
        outparams.simplexNum = outparams.simplexNum + nInitConds;    
        outparams.simplexIterCount = outparams.simplexIterCount + ...
                                        sum(cellfun(@(x) x.ctIterations, cprSimplexOutAll));

        % Find best of the optimized parameters
        cprCompareparamsfile = fullfile(oldOutFolderName, ...
                                        [outparams.prefix, '_compare_params_IC_', ...
                                        num2str(outparams.simplexNum - nInitConds + 1), ...
                                        'to', num2str(outparams.simplexNum), '.csv']);
        [cprSimplexOutBest, errCpr] = ...
            find_best_params(cprSimplexOutAll, cprInitialConditionsAll, cprCompareparamsfile);

        % Update outparams.neuronParamsTable to the best of the optimized parameters
        outparams.neuronParamsTable = cprSimplexOutBest.neuronParamsTable;

        % Save outputs in matfile
        if outparams.saveMatFileFlag
            save(fullfile(oldOutFolderName, ...
                            [outparams.prefix, '_runauto_results_IC_', ...
                            num2str(outparams.simplexNum - nInitConds + 1), ...
                            'to', num2str(outparams.simplexNum), '.mat']), ...
                'cprInitialConditionsAll', 'cprSimplexOutAll', ...
                'cprExitFlagAll', 'cprSimplexOutBest', 'errCpr', ...
                'outparams', '-v7.3');
        end

        % Print time elapsed
        timeTakenPassiveFit = toc(tStartPassiveFit);
        fprintf('It took %g seconds to run the simplex method on %d initial conditions!!\n', ...
                timeTakenPassiveFit, nInitConds);
        fprintf('\n');
    else
        if outparams.runnumTotal > 1    % if this is not the first run
            errCpr = outparams.errCpr{outparams.runnumTotal-1};       % use errCpr from last run    
        else                            % if this is the first run
            errCpr = struct;                                           % empty structure
        end
    end

    % Fit active parameters
    if outparams.fitActiveFlag && ~outparams.fitTogetherFlag
        % Prepare for active-parameters-fitting
        fprintf('Performing active-parameters-fitting for cell %s ... \n', cellName);
        tStartActiveFit = tic();                % tracks time for active-parameters-fitting

        % Prepare outparams for active fit
        [outparams, neuronParamsUseOrig] = prepare_outparams_active(outparams);

        % Optimize active parameters by fitting to IPSC response
        initialConditionsAll = cell(1, nInitConds);                % stores the initial parameters for each simplex run
        simplexOutAll = cell(1, nInitConds);        % stores the simplex outputs for each simplex run
        exitFlagAll = zeros(1, nInitConds);         % stores the exitflags for each simplex run
%        parfor iInitCond = 1:nInitConds
        for iInitCond = 1:nInitConds
            % Initialize outparams0 for parfor
            outparams0 = outparams;

            % Store the old simplex count
            oldSimplexCt = outparams.simplexNum;

            % Prepare outparams0 for simplex
            [outparams0] = ...
                prepare_outparams_simplex(outparams0, oldOutFolderName, oldSimplexCt, iInitCond);

            % Generate initial parameters for this run
            [initialConditionsAll{iInitCond}, outparams0] = ...
                generate_IC(outparams0, iInitCond);

            % Run fminsearch for GABAB IPSC response
            %%%%%%
            %%%%%%%%%%%%%
            [simplexOutAll{iInitCond}, exitFlagAll(iInitCond)] = ...
                m3ha_fminsearch3(realDataIpscr, outparams0);
            %%%%%%%%%%%%%
            %%%%%%
        end

        % Restore outparams after active fit
        outparams = restore_outparams_active(outparams, neuronParamsUseOrig);

        % Update # of simplex runs and # of simplex steps
        outparams.simplexNum = outparams.simplexNum + nInitConds;
        outparams.simplexIterCount = ...
            outparams.simplexIterCount + ...
            sum(cellfun(@(x) x.ctIterations, simplexOutAll));

        % Find best of the optimized parameters
        compareparamsfile = fullfile(oldOutFolderName, ...
                                    [outparams.prefix, '_compare_params_IC_', ...
                                    num2str(outparams.simplexNum - nInitConds + 1), ...
                                    'to', num2str(outparams.simplexNum), '.csv']);
        [simplexOutBest, err] = ...
            find_best_params(simplexOutAll, initialConditionsAll, compareparamsfile);

        % Update outparams.neuronParamsTable to the best of the optimized parameters
        outparams.neuronParamsTable = simplexOutBest.neuronParamsTable;

        % Save outputs in matfile
        if outparams.saveMatFileFlag
            save(fullfile(oldOutFolderName, ...
                            [outparams.prefix, '_runauto_results_IC_', ...
                            num2str(outparams.simplexNum - nInitConds + 1), ...
                            'to', num2str(outparams.simplexNum), '.mat']), ...
                'initialConditionsAll', 'simplexOutAll', 'exitFlagAll', ...
                'simplexOutBest', 'err', ...
                'outparams', '-v7.3');
        end

        % Print time elapsed
        timeTakenActiveFit = toc(tStartActiveFit);
        fprintf('It took %g seconds to run the simplex method on %d initial conditions!!\n', ...
                    timeTakenActiveFit, nInitConds);
        fprintf('\n');
    else
        if outparams.runnumTotal > 1    % if this is not the first run
            % Use err from last run
            err = outparams.err{outparams.runnumTotal - 1};
        else                            % if this is the first run
            % Use empty structure
            err = struct;
        end
    end
end

% Store error structure in outparams
outparams.errCpr{outparams.runnumTotal} = errCpr;
outparams.err{outparams.runnumTotal} = err;        

% Restore flags for stats and plots and parameter usage
[outparams] = ...
    restore_fields(outparams, ...
        'ltsBurstStatsFlag', 'saveLtsInfoFlag', 'saveLtsStatsFlag', ...
        'saveSimCmdsFlag', 'saveStdOutFlag', 'saveSimOutFlag', ...
        'plotIndividualFlag', 'plotOverlappedFlag', 'plotResidualsFlag', ...
        'plotConductanceFlag', 'plotCurrentFlag', ...
        'plotIpeakFlag', 'plotLtsFlag', 'plotStatisticsFlag', ...
        'plotSwpWeightsFlag');

% Update error history plot
update_errorhistoryplot(hfig, outparams);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [errCpr, err, outparams, hfig] = runauto_w_jitter (outparams, hfig)
%% AUTO WITH JITTER mode: TODO

% Update run counts
outparams.runnumAutoWithJitter = outparams.runnumAutoWithJitter + 1;
outparams.runnumTotal = outparams.runnumTotal + 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [outparams, prefixOrig, neuronParamsUseOrig] = prepare_outparams_passive (outparams)
%% Prepare outparams for passive fit

% Turn flag for passive-parameters-fitting on
outparams.simMode = 'passive';          

% Change prefix for passive-parameters-fitting
prefixOrig = outparams.prefix;
outparams.prefix = [outparams.prefix, '_cpr'];

% Save original parameter usage
neuronParamsUseOrig = outparams.neuronParamsTable{:, 'InUse'};

% Look for all active parameters
indParamsIsActive = find(~outparams.neuronParamsTable.IsPassive);

% Turn off active parameters
outparams.neuronParamsTable{indParamsIsActive, 'InUse'} = ...
    zeros(length(indParamsIsActive), 1);

% Set simplexParams to the passive ones
outparams.simplexParams = outparams.simplexParamsPassive;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [outparams] = restore_outparams_passive (outparams, prefixOrig, neuronParamsUseOrig)
%% Restore outparams after passive fit

% Turn flag for passive-parameters-fitting off
outparams.simMode = 'active';

% Restore prefix
outparams.prefix = prefixOrig;

% Restore original parameter usage
outparams.neuronParamsTable{:, 'InUse'} = neuronParamsUseOrig;

% Reset outparams.simplexParams for safety
outparams.simplexParams = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [outparams, neuronParamsUseOrig] = prepare_outparams_active (outparams)
%% Prepare outparams for active fit

% Save original parameter usage
neuronParamsUseOrig = outparams.neuronParamsTable.InUse;

% Look for all passive parameters
indParamsIsPassive = find(outparams.neuronParamsTable.IsPassive);

% Turn off passive parameters
outparams.neuronParamsTable{indParamsIsPassive, 'InUse'} = ...
    zeros(length(indParamsIsPassive), 1);

%Set simplexParams to the active ones
outparams.simplexParams = outparams.simplexParamsActive;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function outparams = restore_outparams_active (outparams, neuronParamsUseOrig)
%% Restore outparams after active fit

% Restore original parameter usage
outparams.neuronParamsTable{:, 'InUse'} = neuronParamsUseOrig;

% Reset outparams.simplexParams for safety
outparams.simplexParams = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function outparams = prepare_outparams_simplex (outparams, oldOutFolderName, ...
                                                oldSimplexCt, initCondNum)
% Prepare outparams for simplex

% Update simplex number
outparams.simplexNum = oldSimplexCt + initCondNum;

% Create a subfolder for simplex outputs and update outFolderName
outparams.outFolderName = ...
    fullfile(oldOutFolderName, ['simplex_', num2str(outparams.simplexNum)]);

% Make sure the directory exists
check_dir(outparams.outFolderName);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [initCond, outparams] = generate_IC (outparams, initCondNum)
%% Generate randomized initial conditions, except for the first run

% Retrieve from outparams
prevNeuronParamsTable = outparams.neuronParamsTable;
simplexNum = outparams.simplexNum;
% RinEstimate = outparams.RinEstimate;

% Set up initial parameters for this initial condition
if initCondNum == 1
    % Just use the previous set of parameters in the first run
    newNeuronParamsTable = prevNeuronParamsTable;
else
    % Create a unique seed for this set of simplex runs
    rng(simplexNum, 'twister');

    % Randomize parameters for the rest of runs
    newNeuronParamsTable = ...
        m3ha_neuron_create_new_initial_params(prevNeuronParamsTable);
end

%% Generate new parameter names for the initCond structure
% TODO: Might not be necessary
% Determine whether each parameter need to be changed
isInUse = newNeuronParamsTable{:, 'InUse'};

% Get the names of all parameters in use
paramsInUseNames = newNeuronParamsTable.Properties.RowNames(isInUse);

% Modify parameter names for storage
paramsInUseNames = cellfun(@(x) strcat(x, '_0'), paramsInUseNames, ...
                            'UniformOutput', false);

% Get the values of all parameters in use
paramsInUseNewValue = newNeuronParamsTable{isInUse, 'InitValue'};

%% Update outparams structure
% Update outparams to these initial parameters
outparams.neuronParamsTable = newNeuronParamsTable;

%% Store in initCond structure
% Store the seed of the random number generator
initCond.randomSeed = rng;

% Store everything else
initCond.initCondNum = initCondNum;
initCond.simplexNum = simplexNum;
initCond.paramsInUseNames = paramsInUseNames;
initCond.paramsInUseValues = paramsInUseNewValue;
initCond.neuronParamsTable = newNeuronParamsTable;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [simplexOutBest, errBest] = ...
        find_best_params(simplexOutAll, initialConditionsAll, compareparamsfile)
%% Find best parameters

% Count the number of initial conditions
nInitConds = numel(simplexOutAll);                    % # of simplex runs

% Count the number of parameters in use
nInUse = length(simplexOutAll{1}.paramsInUseValues);   % # of parameters in use

% Print parameters for all simplex runs in output csv file
fid = fopen(compareparamsfile, 'w');    % open csv file for writing
fprintf(fid, '%s, %s, %s, ', ...
        'Iteration #', 'Final total error', 'Initial total error');
fprintf(fid, repmat('%s, ', 1, nInUse), simplexOutAll{1}.paramsInUseNames{:});
fprintf(fid, repmat('%s, ', 1, nInUse), initialConditionsAll{1}.paramsInUseNames{:});
fprintf(fid, '%s, %s, %s, %s, %s, %s, %s, ', ...
        'Final error change', 'Error tolerance', ...
        'Final parameter change', 'Parameter change tolerance', ...
        'Total iterations', 'Total function evaluations', ...
        'Last simplex step');
fprintf(fid, '%s, %s, ', ...
        'First error change', 'First parameter change');
fprintf(fid, '%s, %s\n', 'Maximum iterations', 'Maximum function evaluations');
fprintf('\n');
for iInitCond = 1:nInitConds
    fprintf(fid, '%d, %g, %g, ', ...
            iInitCond, simplexOutAll{iInitCond}.totalError, simplexOutAll{iInitCond}.initError);
    fprintf(fid, repmat('%g, ', 1, nInUse), simplexOutAll{iInitCond}.paramsInUseValues);
    fprintf(fid, repmat('%g, ', 1, nInUse), initialConditionsAll{iInitCond}.paramsInUseValues);
    fprintf(fid, '%g, %g, %g, %g, %d, %d, %s, ', ...
            simplexOutAll{iInitCond}.maxErrorChange, simplexOutAll{iInitCond}.relativeErrorTolerance, ...
            simplexOutAll{iInitCond}.maxParamChange, simplexOutAll{iInitCond}.relativeParamTolerance, ...
            simplexOutAll{iInitCond}.ctIterations, simplexOutAll{iInitCond}.ctEvals, ...
            simplexOutAll{iInitCond}.lastHow);
    fprintf(fid, '%g, %g, ', ...
            simplexOutAll{iInitCond}.firstMaxErrorChange, ...
            simplexOutAll{iInitCond}.firstMaxParamChange);
    fprintf(fid, '%d, %d\n', ...
            simplexOutAll{iInitCond}.maxIterations, simplexOutAll{iInitCond}.maxFunctionEvaluations);
end
fclose(fid);                            % close csv file

% Convert simplexOutAll to a cell array of row vectors
[simplexOutVecs, vecNames] = structs2vecs(simplexOutAll); 

% Find the index of the total error vector
idxTotalError = find_in_strings('totalError', vecNames, ...
                                    'Searchmode', 'exact');

% Extract the total error vector
simplexOutTotalErrors = simplexOutVecs{idxTotalError};

% Find index of run with smallest final total error
[~, best] = min(simplexOutTotalErrors);    

% Output the best parameters and the associated simplex outputs
simplexOutBest = simplexOutAll{best};
errBest = simplexOutBest.err;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function update_errorhistoryplot(hfig, outparams)
%% Shows and updates Error History figure

rn = outparams.runnumTotal;     % current run number
if outparams.fitActiveFlag
    err = outparams.err{rn};        % current error structure
elseif outparams.fitPassiveFlag
    err = outparams.errCpr{rn};
end

% Make the plot the current figure
if outparams.fitActiveFlag
    set(0, 'CurrentFigure', hfig.errorhistory);
elseif outparams.fitPassiveFlag
    set(0, 'CurrentFigure', hfig.cprerrorhistory);
end

% Plot the error

if ~isempty(err)
    if outparams.fitActiveFlag && outparams.ltsErrorFlag
%{
        % Plot the total error
        subplot(3, 2, 1);
        update_subplot(rn, err.totalError, [], 'total error', 'o', 'b');

        % Plot the average sweep error
        subplot(3, 2, 2);
        update_subplot(rn, err.avgSwpError, [], 'sweep error', 'o', 'b');

        % Plot the average LTS error
        subplot(3, 2, 3);
        update_subplot(rn, err.avgLtsError, [], 'LTS error', 'o', 'b');

        % Plot the average LTS amp error
        subplot(3, 2, 4);
        update_subplot(rn, err.avgLtsAmpError, [], 'amp error', 'o', 'b');

        % Plot the average LTS time error
        subplot(3, 2, 5);
        update_subplot(rn, err.avgLtsDelayError, [], 'time error', 'o', 'b');

        % Plot the average LTS slope error
        subplot(3, 2, 6);
        update_subplot(rn, err.avgLtsSlopeError, [], 'slope error', 'o', 'b');
%}
    else                % if no lts error
        % Just plot the total error
        update_subplot(rn, err.totalError, 'run number', 'total error', 'o', 'b');
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function update_subplot(x, y, x_label, y_label, markerstyle, color)
% Update subplot

% Plot new marker
plot(x, y, 'Marker', markerstyle, 'Color', color, 'MarkerFaceColor', 'auto');

% Adjust y limits
if x == 1
    hold on;
    initymax = y * 1.1;             % initial ymax
    ylim([0 initymax]);
    if ~isempty(x_label)
        xlabel(x_label); 
    end
    if ~isempty(y_label)
        ylabel(y_label);
    end
else
    ylimits = get(gca, 'YLim');
    if ylimits(2) < y               % rescale axes if error is greater than axis limit
        ylim([0, y * 1.1]);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
%% OLD CODE

%[outparams.neuronparams, simplexout] = fminsearch3_4compgabab(realData, outparams, outFolderName);

for p = 1:nInUse
    if p ~= nInUse
        fprintf(fid, '%s, ', simplexout{iInitCond}.paramnames{p});
    else
        fprintf(fid, '%s\n', simplexout{iInitCond}.paramnames{p});
    end
end
    for p = 1:nInUse
        if p ~= nInUse
            fprintf(fid, '%g, ', simplexout{iInitCond}.params(p));
        else
            fprintf(fid, '%g\n', simplexout{iInitCond}.params(p));
        end
    end

[outparams.neuronparams, simplexout] = fminsearch3_4compgabab(realDataCpr, outparams, outFolderName);
% outparams.simplexIterCount = outparams.simplexIterCount + simplexout.ctIterations;        % TO USE FOR ACTIVE FITTING

%% Used for runbutton_toggle in m3ha_optimizergui_4compgabab.m
done = 0;

realData = d;

%initparams = outparams;  % save initial params, probably useful for auto mode

% Previously always gives square
% npercg = ceil(sqrt(idxFitEnd));
% ncg = ceil(numswps/npercg);

% save data in folder with name from timestamp
%%%%% TO DO: CHANGE TO MEANINGFUL NAME e.g. ACTUAL DATA FILE NAME (e.g. B102810_0002.abf)...

% Already checked in m3ha_optimizer_4compgabab
%if exist(outFolderName, 'dir') ~= 7
%    mkdir(outFolderName);
%end

%close(98); % mw20140616 for simplification
%close(99); % mw20140616 for simplification

%paramval = update_slidertext(k,sliderval);
    %val = update_slidertext(k,outparams.neuronparams(k));

% fprintf(fid, repmat('%2.2g, ', 1, numswps), 0); %outparams.sortedswpnum); %n

%runflag!!

% outparams.neuronparams_min = parammin;
% outparams.neuronparams_max = parammax;

% Pass stuff to FMINSEARCH3.m, which will use run_neuron_once_3comp.m as well..

% set(gcf,'Position',[2063 277 843 734]);
% set(hfig,'Position',[100,100,800,700]);
%    realData{k} = d{k}(2:end,:);

    if outparams.pfflag_old == 1
    else
        %         if k == 12
        %             legend([p2,p3,p1],'real data','model-dend','model-soma')
        %         end
    end
    %ylim([-120 20]);

%[3000 4500 -120 20 ]); % mw changed from [150 1000 -120 20]

for k = 1:numswps
    realData{k}(1, :) = [];
%    hfig.alltraces_zoom_subplot(k) = subplot(ncg, npercg, k); hold on;
    subplot(hfig.alltraces_zoom_subplot(k));
end

    %    line([outparams.swpedges(k,1)*1000 outparams.swpedges(k,1)*1000],[-100 0],...
    %        'LineStyle','--','Color','g'); hold off;
    %    line([outparams.swpedges(k,2)*1000 outparams.swpedges(k,2)*1000],[-100 0],...
    %        'LineStyle','--','Color','g'); hold off;
    %    xlim([outparams.swpedges(k,1)*1000*0.999 outparams.swpedges(k,2)*1000*1.001])
    %ylim([-100 0]);
    %title(['sweep ',num2str(outparams.sortedswpnum(k)),': error = ',num2str(err.swperr(k),'%6.3f')]);

% mw commented this out set(gcf,'OuterPosition',[1679         476         589         485]);
%set(gcf,'Position',[1300 120 1200 740]); %mw added Position property and values
set(gcf,'Position',[2063 277 843 734]); %ck 201405

    % axis([xlimits(k, 1) xlimits(k, 2) -110 -30]);

[outparams] = close_active_channels(outparams);        % close active channels for passive fit
[outparams] = restore_active_channels(outparams);    % restore active channels
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\
function [outparams] = close_active_channels(outparams)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [outparams] = restore_active_channels(outparams)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

outparams.autorunnumber = outparams.autorunnumber + 1;                    %%% TO EXAMINE

% fprintf(fid, '%s, ', outparams.experimentname);                    %%% TO EXAMINE: might be useful

if outparams.pfflag_old == 1                            %%% TO EXAMINE
    leghandle = legend([p1, p2, p3], 'data', 'model soma', 'model dend1[0]');
    set(leghandle, 'OuterPosition', [0.6101, 0.2357, 0.2513, 0.1702]);
end

%    outparams.neuronparams;        %% TO EXAMINE

    outparams.neuronparams = cprInitialConditionsAll{iInitCond}.neuronparams;    % set initial parameters for this run
    outparams.neuronparams = initialConditionsAll{iInitCond}.neuronparams;    % set initial parameters for this run

% The following stores the PREVIOUS seed instead of new seed
initCond.s = rng('shuffle');                % based seed on timestamp

% Update total number of times RUN was pressed since the creation of GUI
outparams.runnumTotal = outparams.runnumAuto + outparams.runnumManual ...
            + outparams.runnumJitter + outparams.runnumAutoWithJitter;

% Store error structures in outparams and update plot        %%% TODO: Examine
outparams.errCpr{outparams.runnumTotal} = errCpr;
outparams.err{outparams.runnumTotal} = err;
update_errorhistoryplot(hfig, outparams);

% outparams.rsquaredtrack_window(outparams.runnumTotal,:) = reshape(err.rsquared_window,1, []);
% outparams.rsquaredtrack_swp(outparams.runnumTotal,:) = reshape(err.rsquared_swp,1, []);
% outparams.rsquaredtrack_lts(outparams.runnumTotal,:) = reshape(err.rsquared_lts,1, []);

if outparams.simMode == 1
    figname = fullfile(outparams.outFolderName, [outparams.prefix, '_cpr_overlapped_traces.png']);
else
end
if outparams.simMode == 1
    figname = fullfile(outparams.outFolderName, [outparams.prefix, '_cpr_GABABi_comparison.png']);
else
end
if outparams.simMode == 1
    figname = fullfile(outparams.outFolderName, [outparams.prefix, '_cpr_GABABg_comparison.png']);
else
end
if outparams.simMode == 1
    figname = fullfile(outparams.outFolderName, [outparams.prefix, '_cpr_alltraces_zoom.png']);
else
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                                %%% TO EXAMINE
% mw20140616 for simplification
% figure of traces to update
% hfig.traces = figure(99);
% set(hfig.traces,'Name','Sweep data');
% %set(hfig,'Position',[100,100,800,700]);
% for k = 1:numswps
%     realData{k}(1,:) = [];
%     hfig.traces_subplot(k) = subplot(ncg,npercg,k);
% %    realData{k} = d{k}(2:end,:);
% end

figure(hfig.traces);
numswps = numel(realData);
for k = 1:numswps   
    subplot(hfig.traces_subplot(k));
    
        plot(realData{k}(:,1),realData{k}(:,2),'k'); hold on;
        %plot(simdata{k}(:,1),simdata{k}(:,3),'color',[0.9 0.4 0.8]) %prox dend
        plot(simdata{k}(:,1),simdata{k}(:,3),'color',[0.4 0.3 0.8]) %dist dend
        plot(simdata{k}(:,1),simdata{k}(:,2),'r'); 
        if k == 12
            legend('real data','model-dend','model-soma')
        end
        if outparams.swpw(k) ~= 0
            text('Units','normalized','Position',[0.1 0.9],'String','\color{green} \bf ON');
        end
    line([outparams.swpedges(k,1)*1000 outparams.swpedges(k,1)*1000],[-120 100],...
        'LineStyle','--','Color','g'); hold off;
    line([outparams.swpedges(k,2)*1000 outparams.swpedges(k,2)*1000],[-120 100],...
        'LineStyle','--','Color','g'); hold off;
    %ylim([-120 0]);
    %title(['sweep ',num2str(outparams.sortedswpnum(k)),': error = ',num2str(err.swperr(k),'%6.3f')]);
    title(['sweep ',num2str(k),': error = ',num2str(err.swperr(k),'%6.3f')]);
    
end
%set(gcf,'OuterPosition',[824   476   546   485])

function [hfig] = update_lts_figure (outparams, err, hfig)                    %%% TO EXAMINE
% figure of LTS parameters v. injected current amplitude
% hfig.lts = figure(98);
% set(hfig.lts,'Name','LTS params');
% 

% figure(hfig.lts);
% injcurr = -0.2 + (outparams.sortedswpnum-1) * 0.025; % current injected (nA)
% if numel(injcurr) == 1
%     xlims = [injcurr*1.5 injcurr*0.5];
% else
%     xlims = [min(injcurr)-(max(injcurr)-min(injcurr))*0.1 max(injcurr)+(max(injcurr)-min(injcurr))*0.1];
% end
% subplot(1,3,1);
% plot(injcurr,err.real_lts_maxamp_val,'k.-',injcurr,err.sim_lts_maxamp_val,'r.-');
% xlabel('inj curr (nA)'); ylabel('V_{max} (mV)'); xlim([xlims])
% subplot(1,3,2);
% plot(injcurr,err.real_lts_maxamp_time,'k.-',injcurr,err.sim_lts_maxamp_time,'r.-');
% xlabel('inj curr (nA)'); ylabel('time of V_{max} (ms)'); xlim([xlims])
% subplot(1,3,3); 
% plot(injcurr,err.real_lts_maxdiffamp_val,'k.-',injcurr,err.sim_lts_maxdiffamp_val,'r.-');
% xlabel('inj curr (nA)'); ylabel('dV/dt_{max} (mV)'); xlim([xlims]); legend('real','model'); 
% set(gcf,'OuterPosition',[1679          52         592         423])

% update_rsquared_figure(hfig);  % disabled 20131219 for faster fitting %%% TODO: Examine
% update_rsquared_figure(hfig);  % disabled 20131219 for faster fitting %%% TODO: Examine

function update_rsquared_figure(hfig, outparams)
%%% NEW 2011-07-08  %%%% disabled in 20131219 for faster fitting
% TODO: FIGURE OUT WHAT THIS DOES

figure(hfig.rsqerrorhistory);
set(hfig.rsqerrorhistory, 'Visible', 'on');
rn = outparams.runnumTotal;
subplot(3,1,1); hold on;
plot(1:rn, outparams.rsquaredtrack_window, 'Color', [0.5 0.5 0.5]); ylabel('WINDOW Rsq');
plot(1:rn,min(outparams.rsquaredtrack_window, [],2), 'k', 'LineWidth',2)
plot(1:rn,max(outparams.rsquaredtrack_window, [],2), 'k', 'LineWidth',2)
plot(1:rn,mean(outparams.rsquaredtrack_window,2), 'g-o', 'LineWidth',2)
title(num2str(outparams.rsquaredtrack_window(rn,:)))%, ' (mean: ', num2str(mean(outparams.rsquaredtrack_window,2)), ')'])
subplot(3,1,2); hold on;
plot(1:rn, outparams.rsquaredtrack_swp, 'Color', [0.5 0.5 0.5]); ylabel('SWEEP Rsq');
plot(1:rn,min(outparams.rsquaredtrack_swp, [],2), 'k', 'LineWidth',2)
plot(1:rn,max(outparams.rsquaredtrack_swp, [],2), 'k', 'LineWidth',2)
plot(1:rn,mean(outparams.rsquaredtrack_swp,2), 'b-o', 'LineWidth',2)
title(num2str(outparams.rsquaredtrack_swp(rn,:)))%, ' (mean: ', num2str(mean(outparams.rsquaredtrack_swp,2)), ')'])
subplot(3,1,3); hold on;
plot(1:rn, outparams.rsquaredtrack_lts, 'Color', [0.5 0.5 0.5]); ylabel('LTS Rsq');
plot(1:rn,min(outparams.rsquaredtrack_lts, [],2), 'k', 'LineWidth',2)
plot(1:rn,max(outparams.rsquaredtrack_lts, [],2), 'k', 'LineWidth',2)
plot(1:rn,mean(outparams.rsquaredtrack_lts,2), 'r-o', 'LineWidth',2)
title(num2str(outparams.rsquaredtrack_lts(rn,:)))%, ' (mean: ', num2str(mean(outparams.rsquaredtrack_lts,2)), ')'])
xlabel('run number');
ti = ['Window Rsq mean: ', num2str(mean(outparams.rsquaredtrack_window(rn,:),2),3), ', Sweep Rsq mean: ', ...
    num2str(mean(outparams.rsquaredtrack_swp(rn,:),2),3), ', LTS Rsq mean: ', ...
    num2str(mean(outparams.rsquaredtrack_lts(rn,:),2),3)];
suptitle(ti)
% err.rsquared_swp = 1-(sse_sweep./sst_sweep);
% err.rsquared_window = 1-(sse_window./sst_window);
% err.rsquared_lts = 1-(sse_lts./sst_lts);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[outparams] = set_fields_zero(outparams, 'findLtsFlag', 'ltsBurstStatsFlag', ...
            'plotsweepsflag', 'plotIpeakFlag', 'plotLTSflag', 'plotStatisticsFlag');
        % [hfig] = update_lts_figure(outparams, err, hfig);                        %%% TO EXAMINE
    % [hfig] = update_lts_figure(outparams, err, hfig);                        %%% TO EXAMINE

    % Update sweep figures    
    if outparams.plotsweepsflag
        [hfig] = update_sweeps_figures(realDataCpr, simdata_cpr, outparams, errCpr, hfig);
    end

% Initialize labels after the first plot
if rn == 1
    if outparams.ltsErrorFlag
        % Plot the total error
        subplot(3, 2, 1);
        ylabel('total error');
        ylim([0, err.totalError * 1.1]);

        % Plot the average sweep error
        subplot(3, 2, 2);
        ylabel('sweep error');
        ylim([0, err.avgSwpError * 1.1]);

        % Plot the average LTS error
        subplot(3, 2, 3);
        ylabel('LTS error');
        ylim([0, err.avgLtsError * 1.1]);

        % Plot the average LTS amp error
        subplot(3, 2, 4);
        ylabel('amp error');
        ylim([0, err.avgLtsAmpError * 1.1]);

        % Plot the average LTS time error
        subplot(3, 2, 5);
        ylabel('time error');
        ylim([0, err.avgLtsDelayError * 1.1]);

        % Plot the average LTS slope error
        subplot(3, 2, 6);
        ylabel('slope error');
        ylim([0, err.avgLtsSlopeError * 1.1]);

    else                % if no lts error
        % Just plot the total error
        ylabel('Total error');
        ylim([0, err.totalError * 1.1]);
        xlabel('Run number'); 
    end
else
    for k = 1:6
        subplot(3, 2, k);
        ylimits = get(gca, 'YLim');
        if ylimits(2) < y        % rescale axes if error is greater than axis limit
            ylim([0, y * 1.1]);
        end
    end
end

idxTotalError = find_in_strings('error', vecNames);        % find the index of the error vector

if strcmp(outparams.modeselected, 'modebutton_manual') == 1 ...
    || strcmp(outparams.modeselected, 'modebutton_jitter') == 1
elseif strcmp(outparams.modeselected, 'modebutton_auto') == 1
elseif strcmp(outparams.modeselected, 'modebutton_auto_w_jitter') == 1            %%% TODO: Unfinished
end

figure(hfig.errorhistory);
set(hfig.errorhistory, 'Visible', 'on');

%    parfor (iInitCond = 1:nInitConds, outparams.MaxNumWorkersIC)
%        parfor (iInitCond = 1:nInitConds, outparams.MaxNumWorkersIC)
%        parfor (iInitCond = 1:nInitConds, outparams.MaxNumWorkersIC)

outparams.fitregCpr = repmat(outparams.cprwin, numswps, 1);
                        % fit the entire current pulse response

outparams.fitregCpr = outparams.fitwinCpr * 1000;
                        % fit the entire current pulse response
outparams.fitreg = outparams.fitwin * 1000;
                        % set by leftinit & rightinit in m3ha_optimizer_4compgabab.m

% Constrain epas to be the same as epasEstimate
idxEpas = find_in_strings('epas', outparams.neuronparamnames);
if outparams.neuronparams_use(idxEpas)
    % Make sure the epas estimate is within range
    if outparams.epasEstimate < outparams.neuronparams_min(idxEpas) || ...
        outparams.epasEstimate > outparams.neuronparams_max(idxEpas)
        fprintf('Estimated epas %s is out of range!', outparams.epasEstimate);
    else
        initCond.neuronparams(idxEpas) = outparams.epasEstimate;
    end
end

% Constrain gpas to match RinEstimate
idxGpas = find_in_strings('gpas', outparams.neuronparamnames);
idxDiamSoma = find_in_strings('diamSoma', outparams.neuronparamnames);
idxLDend1 = find_in_strings('LDend1', outparams.neuronparamnames);
idxLDend2 = find_in_strings('LDend2', outparams.neuronparamnames);
if outparams.neuronparams_use(idxGpas) && outparams.RinEstimate > 0
    % Compute the area of the model cell in cm^2
    diamSoma = initCond.neuronparams(idxDiamSoma);
    diamDend1 = 0.5* diamSoma;
    diamDend2 = 0.3* diamSoma;
    LDend1 = initCond.neuronparams(idxLDend1);
    LDend2 = initCond.neuronparams(idxLDend2);
    areaModelCell = pi * (diamSoma^2 + diamDend1 * LDend1 + ...
                            diamDend2 * LDend2) * 1e-8;

    % Compute the matching gpas (S/cm^2)
    gpasEstimate = 1/(outparams.RinEstimate * 1e6 * areaModelCell);

    % Make sure the gpas estimate is within range
    if gpasEstimate < outparams.neuronparams_min(idxGpas) || ...
        gpasEstimate > outparams.neuronparams_max(idxGpas)
        fprintf('Estimated gpas %s is out of range!', gpasEstimate);
    else
        initCond.neuronparams(idxGpas) = gpasEstimate;
    end
end

%% Add directories to search path for required functions
if exist('/home/Matlab/', 'dir') == 7
    functionsdirectory = '/home/Matlab/';
elseif exist('/scratch/al4ng/Matlab/', 'dir') == 7
    functionsdirectory = '/scratch/al4ng/Matlab/';
else
    error('Valid functionsdirectory does not exist!\n');
end
if ~isdeployed
    addpath(fullfile(functionsdirectory, '/Adams_Functions/'));        
                                % for set_fields_zero.m, restore_fields.m,
                                %       find_in_strings.m, check_subdir.m
                                %       structs2vecs.m
    addpath(fullfile(functionsdirectory, '/Downloaded_Functions/'));        
                                % for subplotsqueeze.m
end

oldNeuronParams = outparams.neuronparams;

% Package neuron parameters into a table
neuronParamNames = outparams.neuronparamnames;
Value = outparams.neuronparams;
LowerBound = outparams.neuronparams_min;
UpperBound = outparams.neuronparams_max;
JitterPercentage = outparams.neuronparams_jit;
IsLog = outparams.neuronparamislog;
neuronParamsTable = table(Value, LowerBound, UpperBound, ...
                            JitterPercentage, IsLog, ...
                            'RowNames', neuronParamNames);

% Turn off active parameters
neuronParamsUseOrig = outparams.neuronparams_use;     % save original parameter usage
for p = 1:outparams.numparams                       
    if ~outparams.neuronparamispas(p)
        outparams.neuronparams_use(p) = 0;
    end
end

outparams.neuronparams_use = neuronParamsUseOrig;     % restore original parameter usage

% Restore original parameter usage
outparams.neuronparams_use = neuronParamsUseOrig;

% Turn off passive parameters
neuronParamsUseOrig = outparams.neuronparams_use;     % save original parameter usage
for p = 1:outparams.numparams                       
    if outparams.neuronparamispas(p)
        outparams.neuronparams_use(p) = 0;
    end
end

indInUse = find(outparams.neuronparams_use);    % the indices of params in use

outparams0.neuronparams = cprSimplexOutAll{iInitCond}.neuronparams;

% Update outparams.neuronparams to the best of the optimized parameters
outparams.neuronparams = simplexOutBest.neuronparams;

% Update outparams.neuronparams to the best of the optimized parameters
outparams.neuronparams = cprSimplexOutBest.neuronparams;

% Update outparams.neuronparams to the best of the optimized parameters
outparams.neuronparams = simplexOutBest.neuronparams;

initCond.neuronparams = outparams.neuronparams;

numparams = length(outparams.neuronparams);     % number of parameters

%       ~/Adams_Functions/check_subdir.m
check_subdir(oldOutFolderName, simplexDir);

initCond.s = rng;

idxGpas = find_in_strings('gpas', outparams.neuronparamnames);
idxDiamSoma = find_in_strings('diamSoma', outparams.neuronparamnames);
idxLDend = find_in_strings('LDend', outparams.neuronparamnames);
idxDiamDend = find_in_strings('diamDend', outparams.neuronparamnames);
if outparams.neuronparams_use(idxGpas) && RinEstimate > 0
    % Compute the area of the model cell in cm^2
    diamSoma = outparams.neuronparams(idxDiamSoma);
    diamDend1 = outparams.neuronparams(idxDiamDend);
    diamDend2 = outparams.neuronparams(idxDiamDend);
    LDend1 = outparams.neuronparams(idxLDend) * 0.5;
    LDend2 = outparams.neuronparams(idxLDend) * 0.5;
    areaModelCell = pi * (diamSoma^2 + diamDend1 * LDend1 + ...
                            diamDend2 * LDend2) * 1e-8;

    % Compute the matching gpas (S/cm^2)
    gpasEstimate = 1/(outparams.RinEstimate * 1e6 * areaModelCell);

    % Make sure the gpas estimate is within range
    if gpasEstimate < outparams.neuronparams_min(idxGpas) || ...
        gpasEstimate > outparams.neuronparams_minidxGpas)
        fprintf('Estimated gpas %s is out of range!', gpasEstimate);
    else
        initCond.neuronparams(idxGpas) = gpasEstimate;
    end
end

outparams.neuronparams = initCond.neuronparams;

% Prepare outparams0 for simplex
[outparams0] = ...
    prepare_outparams_simplex(outparams0, outFolderName, oldSimplexCt + nInitConds, iInitCond);

% Randomize parameters for the rest of runs
initCond.neuronparams = zeros(1, nParams);
for k = 1:nParams
    if outparams.neuronparams_use(k)        % parameter used for fitting
        LB = outparams.neuronparams_min(k);
        UB = outparams.neuronparams_max(k);
        if outparams.neuronparamislog(k)
            initCond.neuronparams(k) = exp(log(LB) + rand() * (log(UB) - log(LB)));
        else
            initCond.neuronparams(k) = LB + rand() * (UB - LB);
        end
    else                                    % parameter not used for fitting
        initCond.neuronparams(k) = outparams.neuronparams(k);
    end
end

% Record those parameters that are changed separately
initCond.paramsInUseNames = outparams.neuronparamnames(indInUse);
initCond.paramsInUseValues = initCond.neuronparams(indInUse);

% Modify parameter names
for i = 1:numel(paramsInUseNames)
    paramsInUseNames{i} = strcat(paramsInUseNames{i}, '_0');
end

outparams.logconcisefilename = strrep(outparams.logfilename, ...
                    '.csv', '_concise.csv');
outparams.logconcisefilename = strrep(outparams.logfilename, ...
                    '.csv', '_concise.csv');

fminsearch3_4compgabab(realDataIpscr, outparams0, ...
                        'OnHpcFlag', outparams.onHpcFlag);

% Count the number of sweeps
numswpsCpr = numel(realDataCpr);
numswpsIpscr = numel(realDataIpscr);

% Store in outparams
outparams.numswpsIpscr = numswpsIpscr;
outparams.numswpsCpr = numswpsCpr;

newNeuronParamsTable = ...
    m3ha_neuron_create_new_initial_params(prevNeuronParamsTable, ...
                                    'UsePrevParams', true);

% Count the number of NEURON parameters
nParams = height(prevNeuronParamsTable);

%}