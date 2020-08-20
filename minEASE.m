function minEASE (varargin)
%% Detect synaptic events
% Usage: minEASE (varargin)
% Explanation:
%       This program reads parameters from an input Excel file and 
%           then reads from either .mat or .abf data files
%       Output event info and used parameters are saved as .csv files 
%   Note: Run mode specifications:
%   Mode        openGui    toPrompt    messageMode prevResultAction combineOutputs  verbose
%   'init'      'No'       'No'        'done'      'skip'       'No'            'No' 
%   'rerun'     'No'       'No'        'show'      'archive'    'No'            'No' 
%   'check'     'Yes'      'No'        'show'      'load'       'No'            'No' 
%   'modify'    'Yes'      'Yes'       'wait'      'load' (p)   'No'  (p)       'No' 
%   'debug'     'Yes'      'Yes'       'wait'      'archive'(p) 'Yes' (p)       'Yes'
%   Note: If the data files might be .mat files, 
%           they must not contain the string 'output' or 'param' in the name!
%
% Arguments:    
%       excelFile   - (opt) input Excel file containing:
%                   (1) input folder names 
%                   (2) parameters to use
%                   default == [] (let user select manually)
%       varargin    - 'FigTypes': figure type(s) for saving; 
%                       e.g., 'png', 'fig', or {'png', 'fig'}, etc.
%                   could be anything recognised by the saveas() function 
%                   (see isfigtype.m under Adams_Functions)
%                   default == 'png'
%                   - 'DataType': input data type
%                   must be an unambiguous, case-insensitive match to one of: 
%                       'abf'       - AXON binary files
%                       'mat'       - MATLAB data files
%                       'txt'       - test files
%                   default == to automatically detect what's available
%                   - 'SiMs': sampling interval in ms/sample for mat files,
%                               overridden by what's stored in abf file
%                   must be a numeric positive scalar
%                   default == 0.1 ms
%                   - 'RunMode': mode for running minEASE
%                   must be an unambiguous, case-insensitive match to one of: 
%                       'init'   - initial automatic run through data
%                       'rerun'  - rerun with changed input parameters
%                       'check'  - check results manually
%                       'modify' - modify results manually
%                       'debug'  - debug new version of program
%                   default == 'check'
%                   - 'OpenGui': whether to open GUI for manual checking
%                   must be an unambiguous, case-insensitive match to one of: 
%                       'yes'  - open GUI for checking
%                       'no'   - don't open GUI
%                       'auto' - let the program decide based on RunMode
%                   default == 'auto'
%                   - 'ToPrompt': whether to prompt user when decision is needed
%                   must be an unambiguous, case-insensitive match to one of: 
%                       'yes'  - prompt user with a dialog box
%                       'no'   - uses default actions
%                       'auto' - let the program decide based on RunMode
%                   default == 'auto'
%                   - 'MessageMode' - how message boxes are shown
%                   must be an unambiguous, case-insensitive match to one of: 
%                       'wait'  - stops program and waits for the user
%                                   to close the message box
%                       'show'  - does not stop program but still show the
%                                   message box
%                       'done'  - only show message box at termination
%                       'auto'  - let the program select the message mode 
%                                   based on RunMode
%                   default == 'auto'
%                   - 'PrevResultAction': action on previous results (if any)
%                   must be an unambiguous, case-insensitive match to one of: 
%                       'skip'    - skip the sweep
%                       'load'    - load previous result
%                       'archive' - archive and start new detection
%                       'auto'    - let the program decide based on RunMode
%                   default == 'auto'
%                   - 'CombineOutputs': whether to combine outputs of sweeps
%                   must be an unambiguous, case-insensitive match to one of: 
%                       'yes'  - combine outputs of all sweeps of each file
%                       'no'   - don't combine outputs
%                       'auto' - let the program decide based on RunMode
%                   default == 'auto'
%                   - 'Verbose': whether to use verbose mode TODO
%                   must be an unambiguous, case-insensitive match to one of: 
%                       'yes'  - use verbose mode
%                       'no'   - don't use verbose mode
%                       'auto' - let the program decide based on RunMode
%                   default == 'auto'
%                   - 'OutputClampfit': whether to output Clampfit files
%                   must be numeric/logical 1 (true) or 0 (false)
%                   default == false
%                   - 'MaxNumWorkers': maximum number of workers for 
%                                       parfor for initial conditions
%                                   set to 0 if parfor not to be used
%                                   set to Inf to use maximum number of workers
%                   must be a nonnegative integer or Inf
%                   default == 0
%
% Requires:
% Dependent files in the current directory:
%       local.settings              (through minEASE.m)
%       minEASE_combine_events.m         (through minEASE.m)
%       minEASE_compute_plot_average_psc.m  
%                                   (through minEASE_detect_gapfree_events.m)
%       minEASE_detect_gapfree_events.m     (through minEASE.m)
%       minEASE_examine_gapfree_events.m    (through minEASE.m)
%       minEASE_extract_from_output_filename.m
%                                   (through minEASE_combine_events.m)
%       minEASE_gui_examine_events.m        (through minEASE_examine_gapfree_events.m)
%       minEASE_plot_gapfree_events.m       (through minEASE_detect_gapfree_events.m,
%                                            minEASE_gui_examine_events.m)
%       minEASE_read_params.m               (through minEASE.m)
%
% Dependent files in /home/Matlab/Adams_Functions/:
%       compute_average_PSC_trace.m (through minEASE_compute_plot_average_psc.m)
%       find_directional_events.m   (through minEASE_detect_gapfree_events.m)
%       identify_bursts.m           (through minEASE_detect_gapfree_events.m)
%       compute_rms_Gaussian.m              (through minEASE_detect_gapfree_events.m, 
%                                            minEASE_examine_gapfree_events.m, 
%                                            find_directional_events.m,
%                                            minEASE_gui_examine_events.m)
%
% Dependent files in /home/Matlab/Adams_Functions/:
%       adjust_peaks.m              (through find_directional_events.m,
%                                            minEASE_gui_examine_events.m)
%       all_data_files.m            (through minEASE.m, combine_sweeps.m)
%       apply_iteratively.m         (through identify_channels.m)
%       apply_or_return.m           (through match_format_vector_sets.m)
%       argfun.m                    (through construct_fullpath.m,
%                                            match_format_vector_sets.m)
%       check_dir.m                 (through check_subdir.m)
%       check_subdir.m              (through minEASE.m)
%       combine_sweeps.m            (through minEASE.m)
%       compute_combined_trace.m    (through compute_maximum_trace.m, 
%                                            compute_minimum_trace.m, 
%                                            is_matching_string.m)
%       compute_maximum_trace.m     (through create_indices.m)
%       compute_minimum_trace.m     (through create_indices.m)
%       construct_fullpath.m        (through check_dir.m, locate_dir.m)
%       construct_suffix.m          (through construct_fullpath.m)
%       count_samples.m             (through extract_columns.m, create_indices.m)
%                                            compute_combined_trace.m)
%       count_vectors.m             (through extract_columns.m, extract_elements.m,
%                                            compute_combined_trace.m)
%       create_empty_match.m        (through compute_combined_trace.m)
%       create_error_for_nargin.m   (through many files)
%       create_indices.m            (through extract_columns.m)
%       dlmwrite_with_header.m      (through minEASE.m, 
%                                            minEASE_combine_events.m)
%       error_unrecognized.m        (through compute_combined_trace.m)
%       extract_columns.m           (through force_column_cell.m)
%       extract_elements.m          (through extract_columns.m, create_indices.m)
%       extract_subvectors.m        (through extract_columns.m, force_matrix.m)
%       find_custom.m               (through find_directional_events.m,
%                                            minEASE_gui_examine_events.m, ismatch.m, 
%                                            is_matching_string.m)
%       find_in_list.m              (through compute_combined_trace.m)
%       find_in_strings.m           (through minEASE.m, minEASE_combine_events.m, 
%                                      minEASE_extract_from_output_filename.m
%                                            minEASE_read_params.m, validate_string.m
%                                            find_in_list.m)
%       force_column_cell.m         (through construct_fullpath.m, 
%                                            create_indices.m,
%                                            extract_columns.m, 
%                                            force_column_vector.m,
%                                            match_format_vector_sets.m,
%                                            compute_combined_trace.m,
%                                            force_row_cell.m)
%       force_column_vector.m       (through force_column_cell.m,
%                                            extract_columns.m, force_matrix.m,
%                                            match_format_vectors.m, 
%                                            match_format_vector_sets.m,
%                                            count_samples.m, count_vectors.m,
%                                            compute_combined_trace.m)
%       force_matrix.m              (through force_column_vector.m,
%                                            extract_columns.m,
%                                            compute_combined_trace.m)
%       force_row_cell.m            (through compute_combined_trace.m)
%       force_string_end.m          (through match_format_vector_sets.m)
%       get_idxEnd.m                (through minEASE.m, minEASE_gui_examine_events.m)
%       get_var_name.m              (through compute_combined_trace.m)
%       identify_channels.m         (through minEASE.m, combine_sweeps.m)
%       increment_editbox.m         (through minEASE_gui_examine_events.m)
%       is_matching_string.m        (through ismatch.m)
%       isaninteger.m               (through ispositiveintegerarray.m,
%                                            ispositiveintegervector.m)
%       iscellnumeric.m             (through extract_columns.m, 
%                                            force_column_vector.m,
%                                            match_format_vector_sets.m)
%       iscellnumericvector.m       (through extract_columns.m, extract_elements.m,
%                                            count_samples.m, count_vectors.m,
%                                            compute_combined_trace.m)
%       isemptycell.m               (through all_data_files.m,
%                                            extract_columns.m)
%       isfigtype.m                 (through minEASE_compute_plot_average_psc.m, 
%                                            minEASE_detect_gapfree_events.m, 
%                                            save_all_figtypes.m)
%       ismatch.m                   (through find_in_strings.m)
%       isnum.m                     (through force_column_vector.m,
%                                            compute_combined_trace.m, 
%                                            isnumericvector.m, iscellnumeric.m)
%       isnumericvector.m           (through match_format_vector_sets.m,
%                                            extract_columns.m, extract_elements.m,
%                                            iscellnumericvector.m)
%       ispositiveintegerarray.m    (through extract_columns.m)
%       ispositiveintegervector.m   (through match_dimensions.m)
%       istext.m                    (through ismatch.m)
%       istype.m                    (through isfigtype.m)
%       locate_dir.m                (through locate_functionsdir.m)
%       locate_functionsdir.m       (through minEASE.m, combine_sweeps.m)
%       match_and_combine_vectors.m (through create_indices.m)
%       match_dimensions.m          (through extract_columns.m, extract_elements.m,
%                                            match_format_vector_sets.m)
%       match_format_vector_sets.m  (through construct_fullpath.m, extract_elements.m,
%                                            create_indices.m, 
%                                            match_and_combine_vectors.m)
%       match_format_vectors.m      (through match_format_vector_sets.m,
%                                            create_indices.m)
%       match_row_count.m           (through count_samples.m, match_format_vectors.m)
%       my_closereq.m               (through minEASE_gui_examine_events.m)
%       print_cellstr.m             (through print_or_show_message.m)
%       print_or_show_message.m     (through minEASE.m, minEASE_combine_events.m, 
%                                            minEASE_compute_plot_average_psc.m,
%                                            minEASE_detect_gapfree_events.m
%                                            compute_average_PSC_trace.m, 
%                                            combine_sweeps.m, check_dir.m)
%       restore_fields.m            (through minEASE.m)
%       save_all_figtypes.m         (through minEASE_compute_plot_average_psc.m, 
%                                            minEASE_detect_gapfree_events.m)
%       sscanf_full.m               (through minEASE_extract_from_output_filename.m)
%       set_fields_zero.m           (through minEASE.m)
%       validate_string.m           (through minEASE.m, minEASE_gui_examine_events.m,
%                                            isfigtype.m)
%
% Dependent files in /home/Matlab/Downloaded_Functions/:
%       abf2load.m                  (through minEASE.m, combine_sweeps.m)
%       rgb.m                       (through minEASE_plot_gapfree_events.m,
%                                            minEASE_gui_examine_events.m)
%
%
% File History:
% ---------- Created by Mark P Beenhakker
% 2017-04-25 AL - Added input parser and made 'excelFile' a parameter
% 2017-04-26 AL - Moved file location to /media/shareX/brianT/
% 2017-04-26 AL - Added homeDirectory and functionsDirectory
% 2017-04-26 AL - Renamed currentFile -> rowInfo, 
% 2017-04-26 AL - Renamed guiTOexcelConverter() -> minEASE_read_params()
% 2017-04-26 AL - Added xlHeader as an argument for minEASE_read_params.m
% 2017-04-27 AL - Changed strcmp to strcmpi
% 2017-04-27 AL - Changed si -> siUs, added nSamples
% 2017-06-06 AL - Removed usage of make_time_column.m and zof_mark.m
% 2017-06-06 AL - Removed runThru
% 2017-06-06 AL - Added directionPsc to sweepLabel 
% 2017-06-14 AL - Now deals with the case where there are 
%                   multiple sweeps in each file
% 2017-06-14 AL - Now outputs eventInfo, eventClass, Ischecked in
%                   three different formats
% 2017-06-15 AL - Moved output generation to minEASE_examine_gapfree_events.m
% 2017-06-15 AL - Force unit conversion to pA
% 2017-07-24 AL - Added allEventInfo, allEventClass, allIsChecked
% 2017-07-24 AL - Changed lastSweepDuration to prevSweepsDuration
% 2017-07-24 AL - Now changes indices to times and save in allEventInfo
% 2017-07-24 AL - Added outputCellHeader
% 2017-07-24 AL - Changed sweepLabel format so that EPSC/IPSC 
%                   comes before sweep number
% 2017-07-24 AL - Moved code to minEASE_combine_events.m; 
%                   now combines all saved eventInfo of the same experiment
% 2017-07-24 AL - Added ability to load unfinished work
% 2017-07-25 AL - Added figTypes, dataMode, dataDirectory
% 2017-08-01 AL - AddedNow reads .mat files that contain a data matrix. 
% 2017-07-31 AL - Added DataType (‘abf’ or ‘mat’) as 
%                   an optional parameter-value pair argument. 
%                   If no data type is provided, the program first searches 
%                   for ABF files in the data subdirectory, then searches 
%                   for MAT files if abf files don’t exist. 
% 2017-08-01 AL - Added SiMs (the sampling interval in ms) as an optional 
%                   parameter-value pair argument. The default SiMs for 
%                   mat files is 0.1 ms. If ABF files are read, 
%                   any user-defined SiMs is overridden by 
%                   what is stored in the file.
% 2017-08-03 AL - Added sweepsToAnalyze as an input parameter so that 
%                   the user can select the sweeps they want from an ABF file
% 2017-08-03 AL - Now makes a subdirectory in the output directory for 
%                   each file if there are multiple sweeps per file
% 2017-10-15 AL - Added SkipManual as a parameter-value pair argument
% 2017-10-15 AL - Moved saving events here
% 2017-10-16 AL - Now creates output files if events not detected
% 2018-01-24 AL - Modified fileIdentifier so that Katie's format is detected
% 2018-01-28 AL - Added .txt as possible data type
% 2018-01-28 AL - Added isdeployed
% 2018-01-29 AL - Moved code to all_data_files.m
% 2018-01-29 AL - Now has param.mat and output.mat for each sweep
% 2018-01-30 AL - Removed homeDirectory
% 2018-01-30 AL - Removed default Excel file and now allows user to select
% 2018-01-30 AL - Now places errors and messages in message boxes
% 2018-02-01 AL - Changed SiMs to SrkHz (sampling rate in kHz)
% 2018-02-02 AL - Read siMs from srkHz
% 2018-02-02 AL - Added an input dialog box to allow user to change the
%                   optional arguments if needed (necessary for standalone)
% 2018-02-02 AL - Added skipManual to subfunctions
% 2018-02-02 AL - Added display_error_to_exit to quit if user cancels a 
%                   dialog box
% 2018-02-06 AL - Added print_cellstr.m in the list to compile
% 2018-02-06 AL - Always display final message in box form
% 2018-02-07 MD - Changed usage of print_or_show_message()
% 2018-02-08 AL - Added showMessage to minEASE_detect_gapfree_events
% 2018-02-08 AL - Now saves time vector, raw trace and event groupings 
%                   as a csv file that can be opened by Clampfit or Excel
% 2018-02-08 AL - Now saves a params matfile upon every new automatic detection
% 2018-02-12 MD - Now saves standard output in a log text file
% 2018-02-13 AL - Fixed usage of dateStr and mfilename
% 2018-02-13 AL - Changed the Clampfit file to show peaks only
% 2018-02-13 AL - Fixed error of backing up output that does not exist
% 2018-02-13 AL - Added noMessages as an optional argument
% 2018-02-13 AL - Display warning message if skipManual is true 
%                   and noMessages is false
% 2018-02-13 AL - Now the default is to archive and redetect in skipmanual mode
%                   and to load previous result in regular mode
% 2018-02-13 AL - Added 'NoPrompts' as an optional argument to allow skipping
%                   of question dialogs and close request functions
% 2018-02-13 AL - Now omits seconds from the backup directory names
% 2018-02-13 AL - Now creates a temporary file for extracting fields from params
%                   the input parameters are saved later
% 2018-02-14 AL - Now excludes 'output' and 'param' from allowed data file names
%                   if the input data might be a mat file
% 2018-02-14 AL - Now checks whether the data files are numeric 
%                   and returns error if not
% 2018-02-14 AL - Added combine_outputs_if_needed() and now prompts user 
%                   whether to combine outputs whenever a set of files 
%                   is finished. Default is temporarily 'No' now 
%                   for performance sake
% 2018-02-14 AL - Changed the default action to 'Skip this Sweep' temporarily
%                   for performance sake
% 2018-02-14 AL - Changed halfRange and firstQuartile to range and minimum
% 2018-02-14 AL - Now removes the time column and saves sampling interval (ms) 
%                   in the Clampfit file name instead. This saves data space.
% 2018-02-14 AL - Now rounds the ranges and minimums and reduces the number of 
%                   significant figures to the maximum necessary. 
%                   This also saves data space.
% 2018-02-16 AL - Changed skewnessCutoff and kurtosisCutoff to 
%                   zSkewnessThres and zExcessKurtosisThres
% 2018-02-20 AL - Now checks all Excel inputs before starting the analyses
% 2018-02-22 AL - Now uses parfor if skipping GUI, no prompt, no messages
% 2018-02-23 AL - Now prints error messages and warn messages together 
%                   when using parfor
% 2018-02-23 AL - Now only save output Clampfit file if new detection
%                   or if eventInfo or eventClass is changed
% 2018-02-23 AL - Now only save output mat file and csv files if new detection 
%                   or if eventInfo or eventClass or isChecked is changed
% 2018-02-26 AL - Added 'OutputClampfit' and set the default to false
% 2018-02-26 AL - Modified usage of print_or_show_message:
%                   Now takes an argument 'MessageMode'
%                   which takes 'auto', 'wait', 'show', 'none' as possible values
%                   this is messageModeUser
% 2018-02-27 AL - Changed noMessages to messageMode, taking the possible values:
%                   'auto', 'wait', 'show', 'done'
% 2018-02-27 AL - Changed 'SkipManual' to 'OpenGui', taking the possible values:
%                   'auto', 'yes', 'no'
% 2018-02-27 AL - Changed 'NoPrompts' to 'ToPrompt', taking the possible values:
%                   'auto', 'yes', 'no'
% 2018-02-27 AL - Added 'RunMode', taking the possible values:
%                   'init', 'rerun', 'check', 'modify', 'debug'
% 2018-02-27 AL - Moved runMode-dependent arguments to second input dialog box
% 2018-02-27 AL - Added prevResultAction, combineOutputs and verbose
%                   and made them dependent on runMode
% 2018-02-27 AL - Added 'MaxNumWorkers' for parfor
% 2018-03-02 MD - Added outputClampfit in initial input prompt, verbose
%                   parameter to print_or_show_message, and put
%                   'Verbose', verbose pair in print_or_show_message()
% 2018-04-04 MD - Added foundation code for automatically generating an Excel
%                   file with default parameters and added pseudo-code for
%                   this action
% 2018-04-23 MD - Added progress bar when program is creating parallel pool,
%                   reading Excel file, and detecting sweeps
% 2018-05-16 AL - Added istype.m in the dependency list
% 2018-06-05 AL - Changed parpool('local') -> parpool
% 2018-08-03 AL - Renamed sweepLabel -> outputLabel
% 2018-08-03 AL - Now saves auto-detected results immediately upon new detection
% 2018-09-19 AL - Now uses the first channel that is identified to be current
%
% TODO: Change warn messages to 'show' and error messages to 'wait'?
% TODO: How to deal with EPSCs mixed in IPSCs
% TODO: Online detection
% TODO: Only update parts of an existing CSV file? In Linux only?
% 
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Flags
debugFlag = 0;      % Skip time-consuming operations under debug mode

%% Hard-coded parameters
formatDateString = 'yyyymmddTHHMMSS';
validRunModes = {'init', 'rerun', 'check', 'modify', 'debug'};
validMessageModes = {'wait', 'show', 'done'};
validPrevResultActions = {'skip', 'archive', 'load'};
validAnswers = {'yes', 'no'};
logo = 'minEASE_Logo_1.png';

%% Default files
excelFileDefault = '';          % no default excelFile, the program will
                                %   go through the possible data types
possibleDataTypes = {'abf', 'mat', 'txt'};     
                    % Precedence: .abf > .mat > .txt

%% Default for optional arguments
figTypesDefault = 'png';        % default figure type(s) for saving
dataTypeDefault = 'auto';       % to detect input data type 
                                %   from possibleDataTypes
srkHzDefault = 20;              % default sampling rate in kHz 
                                %   for .mat files and .txt files
                                % Paula's calcium imaging data are 20 Hz
                                %   Assume ms means s for simplicity
runModeDefault = 'check';       % default mode for running minEASE
maxNumWorkersDefault = Inf;     % default maximum number of workers for parfor
openGuiDefault = 'auto';        % let the program decide whether to open GUI 
                                %   based on RunMode by default
toPromptDefault = 'auto';       % let the program decide whether to prompt
                                %   user based on RunMode by default
messageModeDefault = 'auto';    % let the program select the message mode 
                                %   based on RunMode by default
prevResultActionDefault = 'auto';   % let the program select the action on 
                                %   previous results based on RunMode by default
combineOutputsDefault = 'auto'; % let the program select whether to combine 
                                %   outputs based on RunMode by default
verboseDefault = 'auto';        % let the program select whether to use verbose
                                %   mode based on RunMode by default
outputClampfitDefault = 'no';   % whether to output Clampfit files by default
roiPlotDefault = 'auto';        % program will determine best region of interest
                                %   if not defined by the user
%autoExcelFileDefault = 'no';   % whether to automatically generate an input
                                %   excel file for all subdirectories in a 
                                %   given directory with default parameters

%% Column assignments for eventInfo:
%   1 = index at event breakpoint
%   2 = index at event peak
%   3 = data value at event breakpoint
%   4 = data value at event peak
%   5 = amplitude of the event
%   6 = 0-100% rise time (samples)
%   7 = 10-90% rise time (samples)
%   8 = inter-event interval from this event peak 
%       to next event peak (samples)
%   9 = interstimulus interval from this event peak 
%       to next event breakpoint (samples)
%   10 = 50% decay time (samples)
%   11 = "full decay" time (samples):
%           time to return within noiseLevel 
%           of breakpoint value
outputCellHeader = {'Breakpoint Index', ...
                    'Peak Index', ...
                    'Breakpoint Value (pA)', ...
                    'Peak Value (pA)', ...
                    'Peak Amplitude (pA)', ...
                    '0-100% Rise Time (samples)', ...
                    '10-90% Rise Time (samples)', ...
                    'Peak to Peak Interval (samples)', ...
                    'Peak to Breakpoint Interval (samples)', ...
                    '50% Decay Time (samples)', ...
                    'Full Decay Time (samples)', ...
                    'Event Class', ...
                    'Whether Examined'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Add directories to search path for required functions
%   Note: Only needed if not a compiled program
if ~isdeployed
    % Locate the functions directory
    functionsDirectory = locate_functionsdir;

    % Add path containing dependent functions
    addpath(fullfile(functionsDirectory, '/Adams_Functions/'));
    addpath(fullfile(functionsDirectory, '/Downloaded_Functions/'));
end

%% Deal with arguments
% Set up Input Parser Scheme
iP = inputParser;         
iP.FunctionName = mfilename;

% Add optional inputs to the Input Parser
addOptional(iP, 'excelFile', excelFileDefault, @ischar);

% Add parameter-value pairs to the Input Parser
addParameter(iP, 'FigTypes', figTypesDefault, ...
    @(x) min(isfigtype(x, 'ValidateMode', true)));
addParameter(iP, 'DataType', dataTypeDefault, ...
    @(x) any(validatestring(x, possibleDataTypes)));
addParameter(iP, 'SamplingRate', srkHzDefault, ...
    @(x) validateattributes(x, {'numeric'}, {'scalar', 'positive'}));
addParameter(iP, 'RunMode', runModeDefault, ...
    @(x) any(validatestring(x, validRunModes)));
addParameter(iP, 'MaxNumWorkers', maxNumWorkersDefault, ...
    @(x) isnumeric(x) || isinf(x));
addParameter(iP, 'OpenGui', openGuiDefault, ...
    @(x) any(validatestring(x, validAnswers)));
addParameter(iP, 'ToPrompt', toPromptDefault, ...
    @(x) any(validatestring(x, validAnswers)));
addParameter(iP, 'MessageMode', messageModeDefault, ...
    @(x) any(validatestring(x, validMessageModes)));
addParameter(iP, 'PrevResultAction', prevResultActionDefault, ...
    @(x) any(validatestring(x, validPrevResultActions)));
addParameter(iP, 'CombineOutputs', combineOutputsDefault, ...
    @(x) any(validatestring(x, validAnswers)));
addParameter(iP, 'Verbose', verboseDefault, ...
    @(x) any(validatestring(x, validAnswers)));
addParameter(iP, 'OutputClampfit', outputClampfitDefault, ...
    @(x) any(validatestring(x, validAnswers)));
addParameter(iP, 'RoiPlot', roiPlotDefault,...
    @(x) isempty(x) || (isnumeric(x) && isvector(x) && all(x >= 0)...
         && diff(x) >= 0 && numel(x) == 2));
%{
addParameter(iP, 'AutoExcelFile', autoExcelFileDefault, ...
    @(x) any(validatestring(x, validAnswers)));
%}

% Read from the Input Parser
parse(iP, varargin{:});
excelFile           = iP.Results.excelFile;
[~, figTypes]       = isfigtype(iP.Results.FigTypes, 'ValidateMode', true);
dataTypeUser        = validatestring(iP.Results.DataType, ...
                        [possibleDataTypes, {'auto'}]);
srkHz               = iP.Results.SamplingRate;
runModeUser         = validatestring(iP.Results.RunMode, validRunModes);
maxNumWorkersUser   = iP.Results.MaxNumWorkers;
openGuiUser         = validatestring(iP.Results.OpenGui, ...
                        [validAnswers, {'auto'}]);
toPromptUser        = validatestring(iP.Results.ToPrompt, ...
                        [validAnswers, {'auto'}]);
messageModeUser     = validatestring(iP.Results.MessageMode, ...
                        [validMessageModes, {'auto'}]);
prevResultActionUser= validatestring(iP.Results.MessageMode, ...
                        [validPrevResultActions, {'auto'}]);
combineOutputsUser  = validatestring(iP.Results.MessageMode, ...
                        [validAnswers, {'auto'}]);
verboseUser         = validatestring(iP.Results.MessageMode, ...
                        [validAnswers, {'auto'}]);
outputClampfitUser  = validatestring(iP.Results.OutputClampfit, ...
                        [validAnswers, {'auto'}]);
roiPlotUser         = iP.Results.RoiPlot;
%{
autoExcelFileUser   = validatestring(iP.Results.AutoExcelFile, ...
                        [validAnswers, {'auto'}]);
%}

% Convert minEASE logo into defined color map
[icondata, iconcmap] = imread(logo);

%% Session preferences dialog boxes
% Prepare for session preferences dialog box #1
if iscellstr(figTypes)
    figTypesDisplay = strjoin(figTypes, ', ');
else
    figTypesDisplay = figTypes;
end
if strcmp(roiPlotUser, 'auto')
	roiPlotDisplay = roiPlotUser;
else
	roiPlotDisplay = ['[', num2str(roiPlotUser), ']'];
end
%{
            ['Or generate an input Excel file from this data directory ', ...
                '(''auto'' if to be selected, ', ...
                'none'' if to use input Excel file):'], ...
%}
prompt1 = {'Input Excel file (leave blank if to be selected):', ...
            'Figure type for saving (''png'', ''jpg'', ''gif'', etc.):', ...
            ['Data type (''', ...
                strjoin(possibleDataTypes, ''', '''), ''' or ''auto''):'], ...
            'Sampling rate (kHz) (ignored if ABF files used):', ...
            ['Run mode (''', strjoin(validRunModes, ''', '''), '''):'], ...
            ['Output Clampfit files: (''', ...
                strjoin(validAnswers, ''', '''), '''):'], ...
            ['Specify Region of Interest: (coordinate format [x y], ', ...
                'or ''auto''):']};
            %{
            ['Would you like to automatically generate an Excel file ', ...
            'with default parameters?: (Yes/No)']
            % Will need to make this the second option in prompt
            %}    
dialogTitle1 = 'Session preferences #1';
numLines1 = [1, 60; 1, 60; 1, 60; 1, 60; 1, 60; 1, 60; 1, 60];
defaultAns1 = {excelFile, figTypesDisplay, dataTypeUser, ...
                num2str(srkHz), runModeUser, outputClampfitUser, ...
                roiPlotDisplay};
% Open session preferences dialog box #1:
%   Prompt user to select runmode and 
%       change defaults for initial arguments if needed
%   Allow window to be modal, no interpreter, and resizable horizontally
%   Reopen dialog box if any of the inputs are not valid
inputs1Valid = false;           % always do this at least once
mTitle = 'Preference invalid';  % for a message box if needed
% TODO: implement icon: icon = imread('minEASE_Logo1.png');
while ~inputs1Valid
    % Open input dialog box
    inputs1 = inputdlg(prompt1, dialogTitle1, numLines1, defaultAns1, 'on');

    % If the user closes it, exit the program
    if isempty(inputs1)
        display_error_to_exit('Action cancelled ...', icondata, iconcmap);
        return;
    end

    % Read in user inputs
    excelFile = inputs1{1};
    [isFigType, figTypes] = isfigtype(strsplit(inputs1{2}));
    dataTypeEntered = validate_string(inputs1{3}, ...
                        [possibleDataTypes, {'auto'}]);
    srkHz = str2double(inputs1{4});
    runModeEntered = validate_string(inputs1{5}, validRunModes);
    outputClampfitEntered = validate_string(inputs1{6}, validAnswers);
    roiPlot = str2num(inputs1{7});
    %autoExcelFileEntered = validate_string(inputs1{8}, validAnswers);
        % need to make this the second option in the prompt

    % Update defaults shown in the new dialog box if unsuccessful
    defaultAns1 = inputs1;

    % Check the validity of inputs
    if ~isempty(excelFile) && exist(excelFile, 'file') ~= 2
                                % if input Excel file does not exist
        msg = {'Input Excel file does not exist!', ...
                'Leave it blank if you want to select it interactively.'};
    elseif ~all(isFigType)      % if a figure type is not valid
        msg = 'One of the entered figure types is not valid!';
    elseif isempty(dataTypeEntered) % if the data type is invalid
        msg = {'The data type must be one of the following: ', ...
                    ['''', strjoin(possibleDataTypes, ''', '''), ''''], ...
                    'Or type ''auto'' for automatic detection.'};
    elseif any(strcmp(dataTypeEntered, {'mat', 'txt'})) && isnan(srkHz)
                                % if no sampling rate provided
        msg = {['You must provide a sampling rate ', ...
                'if .mat or .txt files are used as data!']};
    elseif ~isempty(inputs1{4}) && (isnan(srkHz) || srkHz <= 0)
                                % if sampling rate (kHz) invalid
        msg = 'The sampling rate (kHz) must be a positive number!';
    elseif isempty(runModeEntered)
                                % if runModeEntered invalid
        msg = {'The run mode must be one of the following: ', ...
                    ['''', strjoin(validRunModes, ''', '''), '''']};
    elseif isempty(outputClampfitEntered)
                                % if outputClampfitEntered invalid
        msg = {['For whether to output Clampfit files, ', ...
                    'you must enter one of: '], ...
                ['''', strjoin(validAnswers, ''', '''), '''']};
    elseif isempty(roiPlot) && ~strcmp(inputs1{7}, 'auto') || ...
    	   ~isempty(roiPlot) && ~(isnumeric(roiPlot) && ...
    	   		isvector(roiPlot) && numel(roiPlot) == 2)
    	   						% if roiPlot is not valid
    	msg = {['The Region of Interest must be in the format of ', ...
    	 		'[x y] or ''auto''']};
    %{
    elseif isempty(autoExcelFileEntered) ...
           || ~strcmp(autoExcelFileEntered, validAnswers)
                                % if autoExcelFileEntered is invalid
        msg = {['You must specify if you would like to automatically ', ...
               'generate an Excel file with default parameters as ', ...
               'either ''Yes'' or ''No''!']}; 
    %}
    else                        % all inputs are valid
        msg = '';
    end

    % Check whether there was an invalid input
    if isempty(msg)
        % Exit while loop
        inputs1Valid = true;
    else
        % Show error message and wait for user to close it
        %   before reloading session preferences dialog box
        uiwait(msgbox(msg, mTitle, 'custom', [icondata, iconcmap], 'modal'));    
    end
end

% Update runMode-dependent arguments if set to 'auto'
if strcmp(openGuiUser, 'auto')
    switch runModeEntered
    case {'init', 'rerun'}
        openGuiUser = 'no';
    case {'check', 'modify', 'debug'}
        openGuiUser = 'yes';
    otherwise
        error('Error with code!');
    end
end
if strcmp(toPromptUser, 'auto')
    switch runModeEntered
    case {'init', 'rerun', 'check'}
        toPromptUser = 'no';
    case {'modify', 'debug'}
        toPromptUser = 'yes';
    otherwise
        error('Error with code!');
    end
end
if strcmp(messageModeUser, 'auto')
    switch runModeEntered
    case 'init'
        messageModeUser = 'done';
    case {'rerun', 'check'}
        messageModeUser = 'show';
    case {'modify', 'debug'}
        messageModeUser = 'wait';
    otherwise
        error('Error with code!');
    end
end
if strcmp(prevResultActionUser, 'auto')
    switch runModeEntered
    case 'init'
        prevResultActionUser = 'skip';
    case {'rerun', 'debug'}
        prevResultActionUser = 'archive';
    case {'check', 'modify'}
        prevResultActionUser = 'load';
    otherwise
        error('Error with code!');
    end
end
if strcmp(combineOutputsUser, 'auto')
    switch runModeEntered
    case {'init', 'rerun', 'check', 'modify'}
        combineOutputsUser = 'no';
    case 'debug'
        combineOutputsUser = 'yes';
    otherwise
        error('Error with code!');
    end
end
if strcmp(verboseUser, 'auto')
    switch runModeEntered
    case {'init', 'rerun', 'check', 'modify'}
        verboseUser = 'no';
    case 'debug'
        verboseUser = 'yes';
    otherwise
        error('Error with code!');
    end
end

% Prepare for session preferences dialog box #2
% TODO:
prompt2 = {['Would you like to open GUIs? (''', ...
                strjoin(validAnswers, ''', '''), '''):'], ...
            ['Would you like to prompt before decisions? (''', ...
                strjoin(validAnswers, ''', '''), '''):'], ...
            ['Would you like to show and wait for message boxes? (''', ...
                strjoin(validMessageModes, ''', '''), '''):'], ...
            ['What to do to previous results if any? (''', ...
                strjoin(validPrevResultActions, ''', '''), '''):'], ...
            ['Do you want to combine outputs across sweeps for each file? (''', ...
                strjoin(validAnswers, ''', '''), '''):'], ...
            ['Would you like to use the verbose mode (Under development)? (''', ...
                strjoin(validAnswers, ''', '''), '''):']};
dialogTitle2 = 'Session preferences #2';
numLines2 = [1, 50; 1, 50; 1, 50; 1, 50; 1, 50; 1, 50];
defaultAns2 = {openGuiUser, toPromptUser, messageModeUser, ...
                prevResultActionUser, combineOutputsUser, verboseUser};

% Open session preferences dialog box #2:
%   Allow user to change defaults for mode-dependent arguments if needed
%   Allow window to be modal, no interpreter, and resizable horizontally
%   Reopen dialog box if any of the inputs are not valid
inputs2Valid = false;           % always do this at least once
mTitle = 'Preference invalid';  % for a message box if needed
% TODO: implement icon
while ~inputs2Valid
    % Open input dialog box
    inputs2 = inputdlg(prompt2, dialogTitle2, numLines2, defaultAns2, 'on');

    % If the user closes it, exit the program
    if isempty(inputs2)
        display_error_to_exit('Action cancelled ...', icondata, iconcmap);
        return;
    end

    % Read in user inputs
    openGuiEntered = validate_string(inputs2{1}, validAnswers);
    toPromptEntered = validate_string(inputs2{2}, validAnswers);
    messageModeEntered = validate_string(inputs2{3}, validMessageModes);
    prevResultActionEntered = validate_string(inputs2{4}, validPrevResultActions);
    combineOutputsEntered = validate_string(inputs2{5}, validAnswers);
    verboseEntered = validate_string(inputs2{6}, validAnswers);

    % Update defaults shown in the new dialog box if unsuccessful
    defaultAns2 = inputs2;

    % Check the validity of inputs
    if isempty(openGuiEntered)
                                % if openGuiEntered invalid
        msg = {'For whether to open GUI, you must enter one of: ', ...
                ['''', strjoin(validAnswers, ''', '''), '''']};
    elseif isempty(toPromptEntered)
                                % if toPromptEntered invalid
        msg = {['For whether to prompt for decision, ', ...
                    'you must enter one of: '], ...
                ['''', strjoin(validAnswers, ''', '''), '''']};
    elseif isempty(messageModeEntered)
                                % if messageModeEntered invalid
        msg = {['For whether to show or wait for message boxes, ', ...
                    'you must enter one of: '], ...
                ['''', strjoin(validMessageModes, ''', '''), '''']};
    elseif isempty(prevResultActionEntered)
                                % if prevResultActionEntered invalid
        msg = {'For action on previous results, you must enter one of: ', ...
                ['''', strjoin(validPrevResultActions, ''', '''), '''']};
    elseif isempty(combineOutputsEntered)
                                % if combineOutputsEntered invalid
        msg = {'For whether to combine outputs, you must enter one of: ', ...
                ['''', strjoin(validAnswers, ''', '''), '''']};
    elseif isempty(verboseEntered)
                                % if verboseEntered invalid
        msg = {'For whether to use verbose mode, you must enter one of: ', ...
                ['''', strjoin(validAnswers, ''', '''), '''']};
    elseif strcmp(openGuiEntered, 'no') && strcmp(messageModeUser, 'wait')
                                % if user wants to wait for message boxes 
                                %   when not opening GUI
        qString = {'Are you sure you don''t want to suppress message boxes?', ...
                'You''ll have to continually press enter or click the mouse.'};
        qTitle = 'Check user intentions';
        choice1 = 'Yes. So be it!';
        choice2 = 'No, I change my mind!';
        choiceDefault = choice2;
        answer = questdlg(qString, qTitle, choice1, choice2, choiceDefault);
        if isempty(answer)
            display_error_to_exit('Action cancelled ...', icondata, iconcmap);
            return;
        end
        switch answer
        case choice1
            msg = '';
        case choice2
            msg = 'Please verify inputs again';
            defaultAns2{6} = 'yes';
        otherwise
            error('Something wrong with the code!');
        end
    else                        % all inputs are valid
        msg = '';
    end    

    % Check whether there was an invalid input
    if isempty(msg)
        % Exit while loop
        inputs2Valid = true;
    else
        % Show error message and wait for user to close it
        %   before reloading session preferences dialog box
        uiwait(msgbox(msg, mTitle, 'custom', [icondata, iconcmap],'modal'));    
    end
end

% If excelFile not provided of if provided excelFile does not exist,
%   allow user to select the file
if isempty(excelFile) || exist(excelFile, 'file') ~= 2
    % Display a dialog box for user to select input file
    filterSpec = {'*.xls;*.xlsx', 'EXCEL files (*.xls, *.xlsx)'; ...
                    '*.*',  'All Files (*.*)'};
    dialogTitle = 'Select an input Excel file';
    [excelName, excelPath] = uigetfile(filterSpec, dialogTitle);

    % Check if file is indeed an existing Excel file
    if (isnumeric(excelName) && excelName == 0) || ...
        exist(fullfile(excelPath, excelName), 'file') ~= 2
        % Display error and exit
        message = {'No valid input Excel file selected!', ...
                    'Exiting program ...'};
        mTitle = 'Excel file invalid';
        icon = 'error';
        print_or_show_message(message, 'MessageMode', 'wait', ...
                                'MTitle', mTitle, 'Icon', icon, ...
                                'Verbose', 1);
        return;
    else
        % Retrieve full file name of the Excel file
        excelFile = fullfile(excelPath, excelName);
    end
else
    [excelPath, ~, ~] = fileparts(excelFile);
    if isempty(excelPath)
        excelPath = pwd;
    end
end

% Determine whether to output Clampfit files
switch outputClampfitEntered
case 'yes'
    outputClampfit = true;
case 'no'
    outputClampfit = false;
otherwise
    error('error with code!!');
end

%{
% Determine whether to automatically generate an Excel file with default
%       parameters (use switch/case)
switch autoExcelFileEntered
case 'yes'
    autoExcelFile = true;
case 'no'
    autoExcelFile = false;
otherwise
    error('error with code!');
end
%}

% Determine whether to open GUI for manual checking
switch openGuiEntered
case 'yes'
    openGui = true;
case 'no'
    openGui = false;
otherwise
    error('error with code!!');
end

% Determine whether to prompt user for decision
%   or just use default actions
switch toPromptEntered
case 'yes'
    toPrompt = true;
case 'no'
    toPrompt = false;
otherwise
    error('error with code!!');
end

% Determine whether to show or wait for message boxes 
%   or just show output messages in the standard output instead
switch messageModeEntered
case {'wait', 'show'}
    messageMode = messageModeEntered;
case 'done'
    messageMode = 'none';
otherwise
    error('error with code!!');
end

% Determine whether to combine outputs across sweeps for each file
switch combineOutputsEntered
case 'yes'
    combineOutputs = true;
case 'no'
    combineOutputs = false;
otherwise
    error('error with code!!');
end

% Determine whether to use the verbose mode
switch verboseEntered
case 'yes'
    verbose = true;
case 'no'
    verbose = false;
otherwise
    error('error with code!!');
end

%{
% Initiate obtaining listings of subdirectories to automatically generate Excel file with
% default parameters if autoExcelFile = true
if autoExcelFile = true
    allFilesAndDirs = dir('minEASE')
end
% Am I using the minEASE as the directory here? Slightly confused on how to
%      make it not do this if autoExcelFile = false

% Finish obtaining listing of subdirectories
allDirs = allFilesAndDirs(cellfun(@(x) x == 1, {allFilesAndDirs.isdir})
allDirNames = {allDirs.name};

% Implement those listings using xlswrite
% Input default data into Excel file from default minEASE test files (ex.Paula)
% Adam: how do I make minEASE use this automatically generated file? I guess
%       make it an input variable like how the user can select which Excel
%       file they want read?
%}

% Determine maximum number of workers for parfor
if ~openGui && ~toPrompt && strcmp(messageMode, 'none')
    maxNumWorkers = maxNumWorkersUser;

    % Start progess bar
    progBar = waitbar(0.25, 'Establishing parallel processing route...');

    % Open a parallel pool using local.settings if it doesn't already exist
    %     if isunix && maxNumWorkers ~= 0
    if maxNumWorkers ~= 0
    % TODO: See if this fixes parpool in Windows
        setmcruserdata('ParallelProfile', 'local.settings');
        p = gcp('nocreate');
        if isempty(p)
            parpool;
        end
    end
    waitbar(0.75, progBar, 'Establishing parallel processing route...');
    waitbar(1, progBar, 'Parallel processing route complete!');
    pause(0.3);
    delete(progBar);
else
    maxNumWorkers = 0;
end

% Produce a text log of standard output
dateString = datestr(now, formatDateString);
logFileName = [mfilename, '_', dateString, '.log'];
diary(fullfile(excelPath, logFileName));

% Display warning message if user-defined sampling rate might be ignored
if strcmp(dataTypeEntered, 'abf') && ~isempty(srkHz)
    % User input for srkHz will be ignored, set to empty
    srkHz = [];
    message = 'ABF file used! User defined sampling rate ignored!';
    mTitle = 'Sampling rate ignored';
    icon = 'warn';
    print_or_show_message(message, 'MessageMode', messageMode, ...
                            'MTitle', mTitle, 'Icon', icon, 'Verbose', verbose);
end

% Timer start
tic;

%% Extract input data from Excel file
% First check if excelFile can be read
[status, ~, ~] = xlsfinfo(excelFile);
if ~isempty(status)       % if can be read
    % Place input data in a mixed cell array
    [~, ~, xlInfo] = xlsread(excelFile);    % cell array containing input data

    % Count the total number of rows (# of data subdirectories to analyze)
    nRows = size(xlInfo, 1);                % number of rows in the Excel file
    
    % Start a status bar
    progBar1 = waitbar(0.5, 'Processing selected Excel file...');

    % Extract information from the input Excel file
    [toBeAnalyzedAll, paramsAll, errormsg] = ...
        minEASE_read_params(xlInfo, 'MaxNumWorkers', maxNumWorkers);

    % TODO: Use this version in verbose mode
    %    message = sprintf(['Row #%d of the input Excel file ', ...
    %                        'is successfully read!'], row);
    waitbar(0.75, progBar1, 'Processing selected Excel file...');

    if isempty(errormsg)
        % Update progress bar status
        waitbar(1, progBar1, 'Processing complete!');
        pause(0.5);

        % Close progress bar after completion
        delete(progBar1);
        message = 'Input Excel file successfully read!';
        mTitle = 'Input params read';
        % TODO: load custom icon
        icon = 'none';
        print_or_show_message(message, 'MessageMode', messageMode, ...
                                'MTitle', mTitle, 'Icon', icon, ...
                                'Verbose', verbose);
    else
        % Close progress bar, display error and exit
        delete(progBar1);
        message = errormsg;
        display_error_to_exit(message, icondata, iconcmap);
        diary off;
        return;
    end
else
    message = {'Input Excel file cannot be read!', ...
                'Exiting program ...'};
    mTitle = 'Cannot read input file';
    icon = 'error';
    print_or_show_message(message, 'MessageMode', 'wait', ...
                            'MTitle', mTitle, 'Icon', icon, 'Verbose', verbose);
    diary off;
    return;
end

% If in debug mode, just analyze the first file, first sweep
if debugFlag
    paramsAll{1}.filesToAnalyze = 1;
end

% Timer end
toc;

%% Run through each row of the Excel file (each data subdirectory) in sequence
if maxNumWorkers == 0
    for row = 2:nRows
        % Extract whether to analyze and the input parameters for this row 
        %   (this data subdirectory)
        toBeAnalyzed = toBeAnalyzedAll{row - 1};
        params = paramsAll{row - 1};

        % Process this row
        [exitFlag, ~, ~, ~] = ...
                process_row(toBeAnalyzed, params, formatDateString, ...
                            possibleDataTypes, outputCellHeader, ...
                            dataTypeEntered, figTypes, srkHz, ...
                            openGui, toPrompt, messageMode, ...
                            prevResultActionEntered, combineOutputs, ...
                            verbose, outputClampfit, icondata, iconcmap);
        
        % Exit if exit flag is true
        if exitFlag
            diary off;
            return
        end
    end
else
    exitFlags = zeros(nRows, 1);
    errormsgs = cell(nRows, 1);
    warnFlags = zeros(nRows, 1);
    warnmsgs = cell(nRows, 1);
    parfor (row = 2:nRows, maxNumWorkers)
%    for row = 2:nRows
        % Extract whether to analyze and the input parameters for this row 
        %   (this data subdirectory)
        toBeAnalyzed = toBeAnalyzedAll{row - 1};
        params = paramsAll{row - 1};

        % Process this row
        [exitFlags(row), errormsgs{row}, warnFlags(row), warnmsgs{row}] = ...
                process_row(toBeAnalyzed, params, formatDateString, ...
                            possibleDataTypes, outputCellHeader, ...
                            dataTypeEntered, figTypes, srkHz, ...
                            openGui, toPrompt, messageMode, ...
                            prevResultActionEntered, combineOutputs, ...
                            verbose, outputClampfit, icondata, iconcmap);
        
        % Print message
        if exitFlags(row)
            fprintf('Row %d was processed with error!!\n\n', row);
        else
            fprintf('Row %d completed.\n\n', row);
        end
    end
end

% If using parfor and error(s) occur, display the error(s) together
if maxNumWorkers ~= 0 && any(exitFlags)
    finalMessage = {};
    for row = 1:nRows
        if exitFlags(row)
            % Append to final message
            finalMessage = [finalMessage, ...
                            {sprintf(['The following error occurred ', ...
                                        'at row #%d:'], row)}, ...
                            errormsgs{row}];
        end
    end
    mTitle = 'minEASE analysis INCOMPLETE';
    % TODO: load custom icon (Sad face)
    icon = 'error';
    print_or_show_message(finalMessage, 'MessageMode', 'wait', ...
                            'MTitle', mTitle, 'Icon', icon, 'Verbose', verbose);
    diary off;
    return
end

% If using parfor and warning(s) occur, display the warning(s)
if maxNumWorkers ~= 0 && any(warnFlags) 
    warnMessage = {};
    for row = 1:nRows
        if warnFlags(row)
            % Append to final message
            warnMessage = [warnMessage, ...
                            {sprintf(['The following warning(s) occurred ', ...
                                        'at row #%d:'], row)}, ...
                            warnmsgs{row}];
        end
    end
    mTitle = 'Warning messages';
    % TODO: load custom icon (Warning face)
    icon = 'warn';
    print_or_show_message(warnMessage, 'MessageMode', 'wait', ...
                            'MTitle', mTitle, 'Icon', icon, 'Verbose', verbose);
end

% Display encouraging message (always in box form)
message = {'minEASE analysis is COMPLETE!', 'Hip Hip, Hooray!'};
mTitle = 'minEASE success';
% TODO: load custom icon (Hooray)
icon = 'none';
print_or_show_message(message, 'MessageMode', 'wait', ...
                        'MTitle', mTitle, 'Icon', icon, 'Verbose', verbose);
diary off;
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [exitFlag, errormsg, warnFlag, warnmsg] = ...
                process_row(toBeAnalyzed, params, formatDateString, ...
                            possibleDataTypes, outputCellHeader, ...
                            dataTypeUser, figTypes, srkHz, openGui, ...
                            toPrompt, messageMode, prevResultActionEntered, ...
                            combineOutputs, verbose, outputClampfit, ...
                            icondata, iconcmap)

%% Conversion constants
US_PER_MS = 1e3;    % microseconds per millisecond
MS_PER_S = 1e3;     % milliseconds per second

%% Constants to be consistent with find_directional_events.m
IDXBREAK_COLNUM      = 1;
IDXPEAK_COLNUM       = 2;
VALBREAK_COLNUM      = 3;
VALPEAK_COLNUM       = 4;
EVENTAMP_COLNUM      = 5;
TOTALRISE_COLNUM     = 6;
TENNINETYRISE_COLNUM = 7;
IEI_COLNUM           = 8;
ISI_COLNUM           = 9;
HALFDECAY_COLNUM     = 10;
FULLDECAY_COLNUM     = 11;

%% Constants to be consistent with minEASE_detect_gapfree_events.m
TYPEONE_CLASSNUM    = 1;
TYPETWO_CLASSNUM    = 2;
TYPETHREE_CLASSNUM  = 3;
SLOWRISE_CLASSNUM   = 4;
WRONGDECAY_CLASSNUM = 5;
TOOSMALL_CLASSNUM   = 6;
INSEALTEST_CLASSNUM = 7;
REMOVED_CLASSNUM    = 8;

% Initialize exit flag and error message
exitFlag = false;
errormsg = '';
warnFlag = false;
warnmsg = {};

% Skip this row if toBeAnalyzed is 'No'
if strcmpi(toBeAnalyzed, 'No')
    warnmsg = 'This row was skipped!!';
    warnFlag = true;
    return
end

% Create output directory if not exist
if exist(params.outputDirectory, 'dir') ~= 7
	mkdir(params.outputDirectory);
    message = sprintf('New output directory is made: %s', ...
                        params.outputDirectory);
    mTitle = 'Output directory made';
    % TODO: load custom icon
    icon = 'none';
    print_or_show_message(message, 'MessageMode', messageMode, ...
                            'MTitle', mTitle, 'Icon', icon, 'Verbose', verbose);
end

% Extract all variables from params:
% Save fields of params as individual variables in a temporary matfile
tempFile = tempname;
save(tempFile, '-struct', 'params');

% Load all variables (fields of params) into workspace
%   NOTE: outputDirectory will be changed in some cases
load(tempFile);

% Construct direction label
switch directionPsc
case {'E', 'Excitatory'}
    directionLabel = 'EPSC';
case {'I', 'Inhibitory'}
    directionLabel = 'IPSC';
end

% Construct full path to data directory
dataDirectory = fullfile(dataHomeDirectory, dataSubdirectory);

% Determine data type, list all .abf, .mat or .txt files from 
%   data subdirectory and skip to next row if no abffiles available
%   Note: data files must not contain 'output' or 'param' in the name!
if strcmp(dataTypeUser, 'abf') || strcmp(dataTypeUser, 'txt')
    [dataType, allDataFiles, nDataFiles, message] = ...
        all_data_files (dataTypeUser, dataDirectory, possibleDataTypes);
else
    [dataType, allDataFiles, nDataFiles, message] = ...
        all_data_files (dataTypeUser, dataDirectory, possibleDataTypes, ...
                        'ExcludedStrings', {'output', 'param'});
end
% Display message
if nDataFiles == 0
    mTitle = 'Data type not found';
    icon = 'warn';
    print_or_show_message(message, 'MessageMode', messageMode, ...
                            'MTitle', mTitle, 'Icon', icon, 'Verbose', verbose);

    % Skip to next row of the input Excel file
    warnmsg = [warnmsg, message];
    warnFlag = true;
    return
else
    % TODO: Include this in verbose mode
    %{
    mTitle = 'Data files used';
    % TODO: load custom icon
    icon = 'none';
    print_or_show_message(message, 'MessageMode', messageMode, ...
                            'MTitle', mTitle, 'Icon', icon, 'Verbose', verbose);
    %}
end

% If filesToAnalyze set to 'all', convert it to 1:nDataFiles
if ischar(filesToAnalyze) && strcmpi(filesToAnalyze, 'all')
    if nDataFiles > 0
        filesToAnalyze = 1:nDataFiles;
    end
end

% If filesToAnalyze out of range, display error
if isnumeric(filesToAnalyze) && ...
    (min(filesToAnalyze) < 0 || max(filesToAnalyze) > nDataFiles)
    message = {'Files To Analyze out of range!', ...
                ' Consider changing to ''all''.'};
    errormsg = display_error_to_exit(message, icondata, iconcmap);
    exitFlag = true;
    return;
end

% Reset sweep durations here if there is only one sweep per file
prevSweepsDuration = 0;         % durations of previous sweeps 
                                %   for this experiment (ms)
sweepDuration = 0;              % current sweep duration (ms)
  
% Work through each file
for iFile = filesToAnalyze % for each file in allDataFiles(filesToAnalyze)
    % Timer start
    % tic;

    % Load data
    dataFileName = fullfile(dataDirectory, allDataFiles(iFile).name);
    switch dataType
    case 'abf'
        % Use abf2load.m to import data
        [allData, siUs] = abf2load(dataFileName);
        siMs = siUs/US_PER_MS;              % sampling interval in ms
    case {'mat', 'txt'}
        % Import data (the current vector must be one of the columns)
        %   Only one cell per file!
        allData = importdata(dataFileName);
        siMs = 1/srkHz;                     % sampling interval in ms
    otherwise
        try
            % Still try to import data anyway
            allData = importdata(dataFileName);
        catch
            message = sprintf('Data from %s cannot be imported!', ...
                                dataFileName);
            errormsg = display_error_to_exit(message, icondata, iconcmap);
            exitFlag = true;
            return
        end
    end

    % Check data
    if ~isnumeric(allData)
        message = sprintf('Data from %s is not a numeric array!', ...
                            dataFileName);
        errormsg = display_error_to_exit(message, icondata, iconcmap);
        exitFlag = true;
        return
    elseif length(size(allData)) > 3
        message = sprintf('Data from %s has more than 3 dimensions!', ...
                            dataFileName);
        errormsg = display_error_to_exit(message, icondata, iconcmap);
        exitFlag = true;
        return
    end

    % Get number of sweeps
    if length(size(allData)) <= 2       % if there is only one sweep
        nSwps = 1;                      % number of sweeps
        dataMode = '2d';
    elseif length(size(allData)) == 3   % if there are multiple sweeps
        nSwps = size(allData, 3);       % number of sweeps
        dataMode = '3d';
    end

    % Identify the current channel from allData
    %   To avoid confusion, place only one channel in allData
    channelTypes = identify_channels(allData, 'ExpMode', 'patch');
    if isempty(channelTypes{1})
        idxCurrent = 1;
    else
        idxCurrent = find_in_strings('Current', channelTypes, ...
                                            'MaxNum', 1);
    end

    % Create file identifier and experiment label
    %   if there is only one sweep per file, also create sweep label here
    [~, fileBase, ~] = fileparts(dataFileName); % get filebase
    switch dataMode
    case '2d'                        % if there is only one sweep
        % Create labels compatible with Katie's file names
        %   If file begin with the format Cyyyymmdd, 
        %   where C is a letter and yyyymmdd are numbers, 
        %   then take only this part of the filename;
        %   Otherwise, take the entire file base
        if isnan(str2double(fileBase(1))) && ...
            ~isnan(str2double(fileBase(2:9))) && ...
            str2double(fileBase(2:9)) > 10000000
            fileIdentifier = fileBase(1:9);
        else
            fileIdentifier = fileBase;
        end

        % Create output label
        outputLabel = [fileIdentifier, '_', directionLabel, ...
                        '_Swp', num2str(iFile)];   % output label
    case '3d'                        % if there are multiple sweeps
        % Create labels compatible with Peter's file names
        fileIdentifier = fileBase;
    otherwise
        % Create label
        fileIdentifier = fileBase;
    end
    expLabel = [fileIdentifier, '_', directionLabel];

    % Create output subdirectory if there are multiple sweeps per file
    if strcmpi(dataMode, '3d')
        % Save original output directory as output home directory
        outputHomeDirectory = params.outputDirectory;
        
        % Construct output subdirectory and check for existence
        outputDirectory = fullfile(outputHomeDirectory, fileIdentifier);
        if exist(outputDirectory, 'dir') ~= 7
	        mkdir(outputDirectory);
            message = sprintf('New output subdirectory is made: %s', ...
	                    outputDirectory);
            mTitle = 'Subdirectory made';
            % TODO: load custom icon
            icon = 'none';
            print_or_show_message(message, 'MessageMode', messageMode, ...
                                    'MTitle', mTitle, 'Icon', icon, ...
                                    'Verbose', verbose);
        end
    end

    % Timer end
    % toc;

    % Select which sweeps to analyze
    if strcmpi(dataMode, '3d')       % if there are multiple sweeps
        % Timer start
        % tic;

        % If sweepsToAnalyze set to 'all', convert it to 1:nDataFiles
        if ischar(sweepsToAnalyze) && strcmpi(sweepsToAnalyze, 'all')
            if nSwps > 0
                sweepsToAnalyze = 1:nSwps;
            else
                message = sprintf(['There are no sweeps in ', ...
                                    'the file %s to analyze!'], ...
                                    dataFileName);
                mTitle = 'File skipped';
                icon = 'warn';
                print_or_show_message(message, 'MessageMode', messageMode, ...
                                        'MTitle', mTitle, 'Icon', icon, ...
                                        'Verbose', verbose);
                warnmsg = [warnmsg, message];
                warnFlag = true;
                continue
            end
        end

        % If sweepsToAnalyze out of range, display error
        if isnumeric(sweepsToAnalyze) && ...
            (min(sweepsToAnalyze) < 0 || max(sweepsToAnalyze) > nSwps)
            errormsg = display_error_to_exit(...
                            {'Sweeps To Analyze out of range!', ...
                                'Consider changing to ''all''.'}, ...
                                icondata, iconcmap);
            exitFlag = true;
            return
        end
    else                                % if there is only one sweep
        sweepsToAnalyze = 1;
    end        

    % Reset sweep durations here if there are multiple sweeps per file
    if strcmpi(dataMode, '3d')       % if there are multiple sweeps
        prevSweepsDuration = (sweepsToAnalyze(1)-1) * ...
                                size(allData, 1) * siMs;
                                        % durations of previous sweeps 
                                        %   for this experiment (ms)
        sweepDuration = 0;              % current sweep duration (ms)
    end

    for iSwp = sweepsToAnalyze
        % Update durations of previous sweeps
        if sweepDuration > 0
            prevSweepsDuration = prevSweepsDuration + sweepDuration;  
                                        % durations of previous sweeps in ms
        end

        % Get the current vector (usually pA) for this file/sweep
        switch dataMode
        case '2d'                % if there is only one sweep
            current = allData(:, idxCurrent);
        case '3d'                % if there are multiple sweeps
            current = allData(:, idxCurrent, iSwp);
        otherwise
        end

        % Extract statistics from the current vector
        minData = min(current);     % minimum value for this trace
        maxData = max(current);     % maximum value for this trace
        rangeData = maxData - minData;          % range for this trace

        % Create output label here if there is only one sweep per file
        if strcmpi(dataMode, '3d')       % if there are multiple sweeps
            outputLabel = [fileIdentifier, '_', directionLabel, ...
                            '_Swp', num2str(iSwp)];   % output label
        end

        % Create output file names
        matFileName = fullfile(outputDirectory, ...
                               sprintf('%s_output.mat', outputLabel));
        csvFileName = fullfile(outputDirectory, ...
                               sprintf('%s_output.csv', outputLabel));
        csvFileNameWHeader = fullfile(outputDirectory, ...
                             sprintf('%s_output_w_header.csv', outputLabel));

        % TODO: Check units: force current to be in pA and voltage in mV
        if abs(maxData) < 1  % probably in nA  %TODO: this is probably not good enough
            % Convert to pA
            current = current * 1000;
        end

        % Get number of sample points
        nSamples = length(current);         % number of sample points

        % Compute sweep duration of current sweep
        sweepDuration = siMs * nSamples;    % sweep duration in ms

        % Place output label, prevSweepsDuration, 
        %   siMs, nSamples in params structure
        params.outputLabel = outputLabel;
        params.prevSweepsDuration = prevSweepsDuration;
        params.siMs = siMs;
        params.nSamples = nSamples;

        % Check for previously saved results 
        %   and prompt user what to do
        newdetection = [];
        if exist(matFileName, 'file') == 2
            % Previous result exists; prompt user for action
            qString = {['The output file ', matFileName, ...
                        ' already exists.'], ...
                       'What would you like to do?'};
            qTitle = 'Prompt to Deal With Previous Result';
            choice1 = 'Skip this sweep';
            choice2 = 'Load previous result';
            choice3 = 'Archive and start new detection';
            switch prevResultActionEntered
            case 'skip'
                choiceDefault = choice1;
            case 'load'
                choiceDefault = choice2;
            case 'archive'
                choiceDefault = choice3;
            otherwise
                error('error with code!!');
            end            
            if toPrompt
                answer = questdlg(qString, qTitle, ...
                                choice1, choice2, choice3, choiceDefault);
            else
                answer = choiceDefault;
            end
            if isempty(answer)
                errormsg = display_error_to_exit('Action cancelled ...', ...
                                                    icondata, iconcmap);
                exitFlag = true;
                return;
            end
            switch answer
            case choice1
                % Skip this sweep
                fprintf('Output file %s already exists. Skipped!\n', ...
                            matFileName);
                continue;
            case choice2
                % Load previous result
                newdetection = false;                    
            case choice3
                % Create backup directory
                backupDir = ['backup_', datestr(now, formatDateString), ...
                                '_', outputLabel];
                check_subdir(outputDirectory, backupDir);
                fullBackupDir = fullfile(outputDirectory, backupDir);

                % Archive previous results
                prevFiles = {fullfile(outputDirectory, ...
                                sprintf('*%s*output*.csv', outputLabel)), ...
                            fullfile(outputDirectory, ...
                                sprintf('*%s*trace*.csv', outputLabel)), ...
                            fullfile(outputDirectory, ...
                                sprintf('*%s*.png', outputLabel)), ...
                            fullfile(outputDirectory, ...
                                sprintf('*%s*output.mat', outputLabel)), ...
                            fullfile(outputDirectory, ...
                                sprintf('*%s*params.mat', outputLabel))};
                for iType = 1:numel(prevFiles)
                    if ~isempty(dir(prevFiles{iType}))
                        movefile(prevFiles{iType}, fullBackupDir);
                    end
                end

                % Perform new detection
                newdetection = true;
            otherwise
                error('Problem with code!');
            end
        else
            % No previous result exists; perform new detection
            newdetection = true;
        end

        % Timer end
        % toc;

        % Timer start
        % tic;

        % Decide on what eventInfo, eventClass, isChecked to use
        % Start status bar
        progBar2 = waitbar(0.1, 'Detecting and processing sweeps...');
        if newdetection
            % Construct params matfile for current sweep
            paramsFileThisSweep = fullfile(outputDirectory, ...
                                   sprintf('%s_params.mat', outputLabel));

            % Save fields of params as individual variables in a matfile
            save(paramsFileThisSweep, '-struct', 'params');

            % First automatically detect and 
            %   classify events on filtered trace
            [eventInfoAuto, eventClassAuto, ...
                currentLowpass, noiseLevel] = ...
                minEASE_detect_gapfree_events(current, siMs, directionPsc, ...
                                        params, 'MessageMode', messageMode);
            % Update progress bar status
            waitbar(0.5, progBar2, 'Detecting and processing sweeps...');

            % Check if events are detected
            if isempty(eventInfoAuto)
                message = {sprintf('No events are detected for %s!', ...
                                    outputLabel), ...
                        'Try decreasing the signal to noise threshold ...'};
                mTitle = 'No events detected';
                icon = 'warn';
                print_or_show_message(message, 'MessageMode', messageMode, ...
                                        'MTitle', mTitle, 'Icon', icon, ...
                                        'Verbose', verbose);
                warnmsg = [warnmsg, message];
                warnFlag = true;
            end

            % Initialize with automatically detected results
            eventInfo = eventInfoAuto;
            eventClass = eventClassAuto;

            % Reset isChecked
            isChecked = logical(zeros(size(eventInfoAuto, 1), 1));

            % Save these as last detected results
            %   for future comparison
            eventInfoLast = eventInfo;
            eventClassLast = eventClass;
            isCheckedLast = isChecked;

            % Save as a new v7.3 matfile
            save(matFileName, 'eventInfo', 'eventClass', 'isChecked', ...
                            'siMs', 'nSamples', 'prevSweepsDuration', ...
                            'outputLabel', '-v7.3');

            % Place all outputs in a big matrix
            outputMatrix = [eventInfo, eventClass, isChecked];

            % Save the output matrix as a csv file
            csvwrite(csvFileName, outputMatrix);

            % Save the output matrix with header as a csv file
            dlmwrite_with_header(csvFileNameWHeader, outputMatrix, ...
                                    'ColumnHeader', outputCellHeader);                   
        else
            % Just filter trace
            % TODO: Move the low-pass filtering code from minEASE_detect_gapfree_events
            %           to its own function and use it here, along with
            %           compute_rms_Gaussian (applying all the relevant parameters 
            %           from the params structure)
            params = set_fields_zero(params, 'plotEventDetectionFlag', ...
                                            'plotAverageTraceFlag');
            [~, ~, currentLowpass, noiseLevel] = ...
                minEASE_detect_gapfree_events(current, siMs, directionPsc, ...
                                        params, 'MessageMode', messageMode, ...
                                        'SkipDetection', true);
            params = restore_fields(params, 'plotEventDetectionFlag', ...
                                            'plotAverageTraceFlag');

            % Load previously saved results
            m = matfile(matFileName);
            eventInfoLast = m.eventInfo;
            eventClassLast = m.eventClass;
            isCheckedLast = m.isChecked;
        end

        % Update progress bar status
        waitbar(1, progBar2, 'Processing complete!');

        % Close progress bar after completion
        pause(0.3);
        delete(progBar2);

        % Close all figures generated by minEASE_detect_gapfree_events()
        close all

        % Timer end
        % toc;

        % Only refine if events are detected
        if isempty(eventInfoLast)
            eventInfo = [];
            eventClass = [];
            isChecked = [];
        else
            % Decide whether to open GUI
            if openGui
                % Open GUI
                toRedo = true;

                % Generate a shifted time column vector for current sweep in ms
                shiftedTimeColumn = prevSweepsDuration + (1:nSamples)' * siMs;

                if strcmpi(dataMode, '2d')       % if there is only one sweep
                    messageOpenGUI = sprintf('Loading GUI for file %d', iFile);
                elseif strcmpi(dataMode, '3d') % if there are multiple sweeps
                    messageOpenGUI = sprintf('Loading GUI for sweep %d', iSwp);
                end
                mTitle = 'Sweep to load GUI';
                % TODO: load custom icon
                icon = 'none';
            else
                % Don't open GUI
                toRedo = false;

                % Use previously saved results 
                %   OR automatically detected results
                eventInfo = eventInfoLast;
                eventClass = eventClassLast;
                isChecked = isCheckedLast;
            end

            % Create GUI to examine detection results
            toQuit = false;
            while toRedo && ~toQuit         % while redoing and not quitting
                if verbose
                    print_or_show_message(messageOpenGUI, ...
                                        'MessageMode', messageMode, ...
                                        'MTitle', mTitle, 'Icon', icon, ...
                                        'Verbose', verbose);
                end

                % Open GUI to examine or update detection results
                [toQuit, toRedo, eventInfo, eventClass, isChecked] = ...
                    minEASE_examine_gapfree_events(eventInfoLast, ...
                                    eventClassLast, isCheckedLast, ...
                                    current, currentLowpass, ...
                                    shiftedTimeColumn, outputDirectory, ...
                                    outputLabel, directionPsc, ...
                                    'ZoomWindowMs', traceLengthMs, ...
                                    'NoiseLevel', noiseLevel, ...
                                    'ToPrompt', toPrompt);
            end

            % If user quits, don't save, display message and exit
            if toQuit
                % Ask user whether to combine outputs after quitting
                qString = {'You quitted!! ><', ['Would you still like ', ...
                            'to combine outputs in the directory ', ...
                            outputDirectory, '?']};
                answer = combine_outputs_if_needed(combineOutputs, toPrompt, ...
                            messageMode, qString, outputDirectory, ...
                            expLabel, dataDirectory, dataMode, ...
                            plotAverageTraceFlag, traceLengthMs, ...
                            beforePeakMs, figTypes);
                if isempty(answer)
                    errormsg = display_error_to_exit('Action cancelled ...', ...
                                                        icondata, iconcmap);
                    exitFlag = true;
                    return
                end

                % Display discouraging message (always in box form)
                message = {['Awwww... you quitter!', ...
                            ' Last event info is not saved!'], ...
                            'Better work harder next time ...'};
                mTitle = 'You quit';
                % TODO: load custom icon (disparaging look)
                icon = 'none';
                print_or_show_message(message, 'MessageMode', 'wait', ...
                                     'MTitle', mTitle, 'Icon', icon, ...
                                     'Verbose', verbose);
                exitFlag = true;
                return;
            end
        end

        % Timer start
        % tic;

        % If updated, save eventInfo, eventClass, isChecked as a matfile
        %   and as a csv file
        %   Note: eventInfo might have NaN entries, so isequaln is necessary
        %   Note: xlswrite does not work on fishfish
        %   Note: csvwrite can only write numeric arrays
        if newdetection || ~isequal(isChecked, isCheckedLast) || ...
            ~isequal(eventClass, eventClassLast) || ...
            ~isequaln(eventInfo, eventInfoLast) 
            % Save matfile as v7.3 format and only updated the information
            %   that is changed
            if ~newdetection && exist(matFileName, 'file') == 2
                % Open the matfile for writing
                m = matfile(matFileName, 'Writable', true);

                % Update the matfile with new information
                if ~isequal(isChecked, isCheckedLast)
                    m.isChecked = isChecked;
                end
                if ~isequal(eventClass, eventClassLast)
                    m.eventClass = eventClass;
                end
                if ~isequal(eventInfo, eventInfoLast)
                    m.eventInfo = eventInfo;
                end
            else
                % Save as a new v7.3 matfile
                save(matFileName, 'eventInfo', 'eventClass', 'isChecked', ...
                                'siMs', 'nSamples', 'prevSweepsDuration', ...
                                'outputLabel', '-v7.3');
            end

            % Place all outputs in a big matrix
            outputMatrix = [eventInfo, eventClass, isChecked];

            % Save the output matrix as a csv file
            csvwrite(csvFileName, outputMatrix);

            % Save the output matrix with header as a csv file
            dlmwrite_with_header(csvFileNameWHeader, outputMatrix, ...
                                    'ColumnHeader', outputCellHeader);                   
        end

        % If eventInfo or eventClass updated, save or resave Clampfit csv file
        %   Note: This takes a lot of data space so is not outputed by default
        if outputClampfit && ...
            (newdetection || ~isequal(eventClass, eventClassLast) || ...
            ~isequaln(eventInfo, eventInfoLast))

            % TODO: only update parts of a csvfile in Linux
            % Compute Clampfit spike positions for each event class
            toSpike = zeros(nSamples, REMOVED_CLASSNUM);
            if ~isempty(eventInfo)      % only do this if events are detected
                for iClass = 1:REMOVED_CLASSNUM     % for each event class
                    % Mark the peak as one (a spike) if in this event class
                    toSpike(eventInfo(eventClass == iClass, IDXPEAK_COLNUM), ...
                            iClass) = 1;
                end
            end

            % Compute a rounded range for the Clampfit file
            %   Use one significant figure only to save data space
            rangeRounded = round(rangeData, 1, 'significant');

            % The number of decimal places to the right
            %   of the decimal point to round the minimum to 
            %   (see documentation for round()) is 
            %   the decimal place of rangeRounded
            placesToTheRight = -floor(log10(rangeRounded));

            % Compute a rounded minimum for the Clampfit file
            minRounded = round(minData, placesToTheRight);

            % Shift 0 and 1 to the minimum and maximum
            %   This is necessary to make the spikes in the same 
            %   y-axis range as the raw data. Rounded to save data space.
            toSpikeClampfit = minRounded + toSpike * rangeRounded;

            % Save raw trace and Clampfit spike positions as a csv file
            %   that can be opened by Clampfit for visualization
            % Create Clampfit file name with the sampling interval (us)
            clampfitFileName = fullfile(outputDirectory, ...
                                sprintf('%s_trace_si_%g.csv', ...
                                        outputLabel, siMs * US_PER_MS));
            fid = fopen(clampfitFileName, 'w');
            for iSample = 1:nSamples
                fprintf(fid, ['%g', repmat(', %g', 1, REMOVED_CLASSNUM), '\n'], ...
                                        current(iSample), ...
                                        toSpikeClampfit(iSample, :));
            end 
            fclose(fid);
        end

        % Timer end
        % toc;
    end
    if strcmp(dataMode, '3d')    % if there are multiple sweeps per file
        % Ask user whether to combine outputs from all sweeps 
        %   that are finished
        qString = {sprintf('Done with the data file %s!', dataFileName), ...
                    sprintf(['Would you like to combine outputs from ', ...
                    'all the sweeps in the output directory %s?'], ...
                    outputDirectory)};
        answer = combine_outputs_if_needed(combineOutputs, toPrompt, ...
                    messageMode, qString, outputDirectory, ...
                    expLabel, dataDirectory, dataMode, ...
                    plotAverageTraceFlag, traceLengthMs, ...
                    beforePeakMs, figTypes);
        if isempty(answer)
            errormsg = display_error_to_exit('Action cancelled ...', ...
                                                icondata, iconcmap);
            exitFlag = true;
            return;
        end
    end
end

if strcmp(dataMode, '2d')    % if there is one sweep per file
    % Ask user whether to combine outputs from all sweeps 
    %   that are finished
    qString = {sprintf('Done with the data directory %s!', ...
                dataDirectory), ...
                sprintf(['Would you like to combine outputs from ', ...
                'all the sweeps in the output directory %s?'], ...
                outputDirectory)};
    answer = combine_outputs_if_needed(combineOutputs, toPrompt, ...
                messageMode, qString, outputDirectory, ...
                expLabel, dataDirectory, dataMode, ...
                plotAverageTraceFlag, traceLengthMs, ...
                beforePeakMs, figTypes);
    if isempty(answer)
        errormsg = display_error_to_exit('Action cancelled ...', ...
                                            icondata, iconcmap);
        exitFlag = true;
        return;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function answer = combine_outputs_if_needed (combineOutputs, toPrompt, ...
                messageMode, qString, outputDirectory, expLabel, ...
                dataDirectory, dataMode, plotAverageTraceFlag, ...
                traceLengthMs, beforePeakMs, figTypes)
% Prompt to combine outputs

% Set up choices
% TODO: Change this to reCombineDefault, etc.
choice1 = 'Yes';
choice2 = 'No';
if combineOutputs
    choiceDefault = choice1;
else
    choiceDefault = choice2;
end

% Show prompt only if needed
if toPrompt
    qTitle = 'Prompt to Combine Outputs';
    answer = questdlg(qString, qTitle, ...
                        choice1, choice2, choiceDefault);
else
    answer = choiceDefault;
end

% Return if user cancels the prompt dialog
if isempty(answer)
    return;
end

% Perform action
switch answer
case choice1
    % Combine outputs from all sweeps that are finished
    combine_outputs(messageMode, outputDirectory, expLabel, ...
                    dataDirectory, dataMode, ...
                    plotAverageTraceFlag, ...
                    traceLengthMs, beforePeakMs, ...
                    figTypes);
case choice2
    % Do nothing
otherwise
    error('Problem with code!');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function combine_outputs (messageMode, outputDirectory, expLabel, ...
                        dataDirectory, dataMode, plotAverageTraceFlag, ...
                        traceLengthMs, beforePeakMs, figTypes)
% TODO: combine params files into ALL_params.mat

% Combine all eventInfo of sweeps from the current experiment
minEASE_combine_events('Folder', outputDirectory, 'ExpLabel', expLabel, ...
                        'TimeUnits', 'ms', ...
                        'MessageMode', messageMode);
[allEventInfo, allEventClass, ~, siMs] = ...
    minEASE_combine_events('Folder', outputDirectory, 'ExpLabel', expLabel, ...
                        'TimeUnits', 'samples', ...
                        'MessageMode', messageMode);
if isempty(allEventInfo)
    return;
end

% Find the number of output matfiles in this outputDirectory with this expLabel
files = dir(fullfile(outputDirectory, [expLabel, '_Swp*_output.mat']));
nSweeps = length(files);

% Get file identifier from expLabel
fileIdentifier = strrep(strrep(expLabel, '_IPSC', ''), '_EPSC', '');

% Combine the corresponding sweep data
allData = combine_sweeps('DataDirectory', dataDirectory, ...
                            'ExpLabel', expLabel, ...
                            'FileIdentifier', fileIdentifier, ...
                            'DataMode', dataMode, ...
                            'SweepNumbers', 1:nSweeps, ...
                            'MessageMode', messageMode);

% Find average PSC trace for the experiment
if plotAverageTraceFlag
    possibleDealWithTooShort = {'none', 'padboth', 'padright', 'omit'};
    nMethods = numel(possibleDealWithTooShort);
    for iMethod = 1:nMethods
        minEASE_compute_plot_average_psc(allEventInfo, allEventClass, ...
                                        allData, siMs, ...
                                        traceLengthMs, beforePeakMs, ...
                                        possibleDealWithTooShort{iMethod}, ...
                                        outputDirectory, expLabel, figTypes, ...
                                        'MessageMode', messageMode);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function errormsg = display_error_to_exit(message, icondata, iconcmap)

% Display error and exit
errormsg = [message, {'Exiting program ... '}];
mTitle = 'Exit Program';
uiwait(msgbox(errormsg, mTitle, 'custom', icondata, iconcmap, 'modal'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
OLD CODE:

%    t = datetime(Y,M,D,H,MI);
%    t = datetime('now','Format','yyyy-MM-dd''T''HH:mm:ss');

% pn = '/home/mark/tony/';
% pn = '/media/markX/old_chalkboard_home/mark/jony/tony/'

%% xl file
% [nums, text, bothXL] = xlsread(strcat(pn, 'tonicTonyFiles.xlsx'));

% for zzz = 2:size(xlInfo,1)
% [toAnalyze, gui_selections] = minEASE_read_params(xlInfo(zzz,:));

            clc

    tempSkip = 0; 

        %         for i = 1:size(allAbfFiles,1)

    clear data

ccc            % clear all + close all hidden + clc

    % Extract XL Variables within gui_selections (this is the result of
    % retrofitting code
    %         [windowsz, skewnesscutoff, kurtosiscutoff, butterFrequency, convolutionWindow,...
    %         find_seals, diff_thresh, minAmp, maxRise, maxDecay,...
    %         startDet, endDet, direction, dump, pn, ...
    %         single_fn]...
    %         = get_mini_guisXL(gui_selections) ;

    % EXTRACT GUI VARIABLES
    [windowsz, skewnesscutoff, kurtosiscutoff, butterFrequency, convolutionWindow,...
    find_seals, diff_thresh, minAmp, maxRise, maxDecay,...
    startDet, endDet, direction, dump, pn, ...
    folder, allAbfFiles, filesToAnalyze]...
    = get_mini_guisXL(gui_selections) ;

        current(:, i) = allData(:, 1);            % load current vector for this file
        voltage(:, i) = allData(:, 2);            % load voltage vector for this file    %TODO: what to do with this

    end
    for i = filesToAnalyze
        %         files = dir(strcat(pn, single_fn, '/*.abf'));
        %         load('/home/mark/matlab_temp_variables/minEASEcurrents')
        %         load(strcat(pn, 'matlab_data_files/',rowInfo{1},'_mFile')) 

        if toQuit == 0 
        end
        data = current(:, i);

        %             shiftedTimeColumn = (t.shiftedTimeColumn*60) + (10*(i-1)); % in sec
        %             eventsFilt = gapfree_analysis_101115_trunc(current, si, rowInfo{12}, rowInfo{13}, rowInfo{14}, rowInfo{15}, rowInfo{16}, rowInfo{17}, rowInfo{20});

        shiftedTimeColumn = (defaultTimeColumn * 1000) + (10000 * (i-1));

        eventsFilt = minEASE_detect_gapfree_events(current, siMs, ...
                    windowsz, skewnesscutoff, kurtosiscutoff, ...
                    butterFrequency, convolutionWindow, diff_thresh, ...
                    minAmp, maxDecay, maxRise, directio    combine_outputs(noMessages, outputDirectory, expLabel, ...
                    dataDirectory, dataMode, ...
                    plotAverageTraceFlag, ...
                    traceLengthMs, beforePeakMs, ...
                    figTypes);
n);

        cursorData = [];

        %             for i = startAnalysis:size(dataFILT,2)



        %     cursorData = peaksRaw;    [toBeAnalyzedAll, paramsAll, errormsg] = minEASE_read_params(xlInfo, xlHeader);


            %         [runThru, redo, UIrange, toQuit] = goldfinger_minis(current, dataFilt, shiftedTimeColumn, i, rowInfo{1}, runThru, redo, UIrange, rowInfo{20}, baseVals);%size(current,2))

            message = sprintf('Plotting Sweep %d', iFile); 
            disp(message)

        % identify real, unfiltered events based on filtered, detected
        % events
        
                    clc
                    
%       /home/Matlab/Marks_Functions/zof_mark.m
%% Butterworth Filter parameters
fc = 100;           % cutoff frequency (Hz) of lowpass filter
npoles = 2;         % order of lowpass filter, i.e.,
                    %     degree of denominator of transfer function
% Use a lowpass Butterworth filter twice to filter current data    
% TODO: Examine why dataFilt is not used in minEASE_detect_gapfree_events;
%   in fact, it's never used anywhere in the code
        dataFilt = zof_mark(current, fc, npoles, si);

        [pscInfo, eventInfoExpanded, eventInfoInBurst, ...
            eventInfoTooSmall, eventInfoIncomplete, ...
            eventInfoSlowRise, eventInfoSlowDecay] = ...
                minEASE_detect_gapfree_events(current, siMs, directionPsc, params);

        % Next, identify peak indices and values of the raw data corresponding
        %   to each detected PSC
        [peaksRaw, basesRaw] = getRealMinis(pscInfo, shiftedTimeColumn, current, sealTestWindowMs);
        [cursorData, baseVals] = getMiniPeaksVals(peaksRaw, basesRaw, shiftedTimeColumn, current);     
        save(fullfile(outputDirectory, '/matlab_temp_variables/autoMinis'), 'cursorData'); 
        save(fullfile(outputDirectory, '/matlab_temp_variables/detectedMinis'), 'cursorData');
        save(fullfile(outputDirectory, '/matlab_temp_variables/baselineMinis'), 'baseVals');

        pause(1)
        pause(1)

        tempTC = make_time_column(siUs, nSamples, 'interval');
        defaultTimeColumn = tempTC * MS_PER_S;      % time column in ms

            load(fullfile(outputDirectory, '/matlab_temp_variables/detectedMinisCorrect.mat'))
            load(fullfile(outputDirectory, '/matlab_temp_variables/baselineMinis.mat'))

        runThru = 0;                % TODO
                runThru = 0; 

        % Place file number (sweep number) in params
        params.fileNo = iFile;

        redo = 1;                   % TODO
        while redo
            if toQuit
                redo = 0;
            end
        end

       formatOut = 'yyyy-MM-ddTHH:mm:ss';
dateString = datestr(now, formatOut);
 % Reset variables
        toQuit = 0;               % quit button status
        cursorData = [];            % TODO
        correctCursorData = [];     % TODO

        if ~toQuit
            if size(baseVals, 1) ~= size(correctCursorData, 1)
                getBaselinesForAddedEvents(baseVals, correctCursorData, current, dataFilt, shiftedTimeColumn);
                    % TODO: This function currently does nothing
            end

            goodCursors = cat(2, baseVals, correctCursorData);

            if isempty(goodCursors) ==1
                allTHEpeaks{iFile, 1} = [];
            else
                allTHEpeaks{iFile, 1} = sortrows(goodCursors, 1);
            end
            allRangesForPeaks(iFile, 1) = UIrange;
            clear goodCursors
            redo = 1;
        end

        UIrange = 0.0015;
        pscInfo = eventInfo(eventClass == 1, :);    % TODO: Show all events on GUI

        outputCell = [outputCellHeader; mat2cell(outputMatrix)];

                outputTable = array2table(outputMatrix, ...
                                          'VariableNames', outputCellHeader);
                writetable(outputTable, csvFileNameWHeader);

            %   & voltage vector (usually mV) for this file/sweep
                voltage = allData(:, idxVoltage);    % TODO: what to do with this
                voltage = allData(:, 2, iSwp);

   lastSweepDuration = 0;          % last sweep duration (ms)
            lastSweepDuration = 0;          % last sweep duration (ms)
                lastSweepDuration = sweepDuration;  % last sweep duration in ms
                if length(size(allData)) == 2       % if there is only one sweep
                    shiftedTimeColumn = lastSweepDuration * (iFile - 1) + ...
                                        (1:nSamples)' * siMs;
                    fprintf('Plotting Sweep %d\n', iFile);
                elseif length(size(allData)) == 3 % if there are multiple sweeps
                    shiftedTimeColumn = lastSweepDuration * (iSwp - 1) + ...
                                        (1:nSamples)' * siMs;
                    fprintf('Plotting Sweep %d\n', iSwp);
                end

    % Initialize allEventInfo, allEventClass, allIsChecked for this row
    allEventInfo = [];
    allEventClass = [];
    allIsChecked = [];

                % Add to allEventInfo, allEventClass, allIsChecked
                allEventInfo = [allEventInfo; eventInfo];
                allEventClass = [allEventClass; eventClass];
                allIsChecked = [allIsChecked; isChecked];

                % Convert all 'indices' in eventInfo to actual time (ms) 
                %   over the entire experiment
                eventInfo(:, 1:2) = prevSweepsDuration + ...
                                        eventInfo(:, 1:2) * siMs;

                % Convert all 'times' in eventInfo to ms
                eventInfo(:, 6:11) = eventInfo(:, 6:11) * siMs;

        % Save and reset allEventInfo, allEventClass, allIsChecked here
        %    if there are multiple sweeps per file
        if length(size(allData)) == 3       % if there are             for iClass = 1:REMOVED_CLASSNUM     % for each class
                % Retrieve the breakpoint indices of this class
                idxBreaks = eventInfo(eventClass == iClass, IDXBREAK_COLNUM);

                % Retrieve the peak indices of this class
                idxPeaks = eventInfo(eventClass == iClass, IDXPEAK_COLNUM);

                % Retrieve the inter-stimulus intervals (samples) this class
                interStimulusIntervals = ...
                        eventInfo(eventClass == iClass, ISI_COLNUM);
                
                % Retrieve the full decay times (samples) of this class
                fullDecayTimes = ...
                        eventInfo(eventClass == iClass, FULLDECAY_COLNUM);

                % The ith column of isClass shows whether each data point
                %   lies in that class
                if ~isempty(idxBreaks)
                    for iEvent = 1:length(idxBreaks)
                        idxStart = idxBreaks(iEvent);
                        idxEnd = get_idxEnd(idxPeaks(iEvent), ...
                                            fullDecayTimes(iEvent), ...
                                            interStimulusIntervals(iEvent));
                        isClass(idxStart:idxEnd, iClass) = 1;
                    end
                end
            end
multiple sweeps
            % Save as a matfile
            matFileName = fullfile(outputDirectory, sprintf('%s_output.mat', ...
                                [fileIdentifier, '_', directionLabel]));
            save(matFileName, 'allEventInfo', 'allEventClass', ...
                                'allIsChecked', '-v7.3');

            % Save as a csv file
            %   Note: xlswrite does not work on fishfish
            %   Note: csvwrite can only write numeric arrays
            outputMatrix = [allEventInfo, allEventClass, allIsChecked];
            csvFileName = fullfile(outputDirectory, sprintf('%s_output.csv', ...
                                    [fileIdentifier, '_', directionLabel]));
            csvwrite(csvFileName, outputMatrix);

            % Save with header as a csv file
            csvFileNameWHeader = fullfile(outputDirectory, ...
                                    sprintf('%s_output_w_header.csv', ...
                                    [fileIdentifier, '_', directionLabel]));
            dlmwrite_with_header(csvFileNameWHeader, outputMatrix, ...
                                    outputCellHeader);

            % Reset matrices
            allEventInfo = [];
            allEventClass = [];
            allIsChecked = [];
        end

    % Save allEventInfo, allEventClass, allIsChecked for this row
    if ~isempty(allEventInfo)
        % Save as a matfile
        matFileName = fullfile(outputDirectory, sprintf('%s_output.mat', ...
                            [dataSubdirectory, '_', directionLabel]));
        save(matFileName, 'allEventInfo', 'allEventClass', ...
                            'allIsChecked', '-v7.3');
        
        % Save as a csv file
        %   Note: xlswrite does not work on fishfish
        %   Note: csvwrite can only write numeric arrays
        outputMatrix = [allEventInfo, allEventClass, allIsChecked];
        csvFileName = fullfile(outputDirectory, sprintf('%s_output.csv', ...
                                [dataSubdirectory, '_', directionLabel]));
        csvwrite(csvFileName, outputMatrix);

        % Save with header as a csv file
        csvFileNameWHeader = fullfile(outputDirectory, ...
                                sprintf('%s_output_w_header.csv', ...
                                [dataSubdirectory, '_', directionLabel]));
        dlmwrite_with_header(csvFileNameWHeader, outputMatrix, ...
                                outputCellHeader);
    end

                sweepLabel = [fileIdentifier, '_Swp', num2str(iSwp), ...
                                '_', directionLabel];   % sweep label

            si = siUs/(US_PER_MS * MS_PER_S);   % sampling interval in seconds

        if length(size(allData)) == 1       % if there is only one sweep
            nSwps = 1;                      % number of sweeps
            dataMode = 'Mark';
        else

            if exist(matFileName, 'file') == 2
            else
            end
                    movefile(fullfile(outputDirectory, ...
                            sprintf('%s_output.csv', sweepLabel)), ...
                            fullBackupDir);

%% Set folders for reading and saving files
% Find home directory
if exist('/media/shareX/share/minEASE/', 'dir') == 7
    homeDirectory = '/media/shareX/share/minEASE/';
elseif exist('/media/adamX/minEASE/', 'dir') == 7
    homeDirectory = '/media/adamX/minEASE/';
elseif exist('/scratch/al4ng/minEASE/', 'dir') == 7
    homeDirectory = '/scratch/al4ng/minEASE/';
else
    error('Valid homeDirectory does not exist!');
end

%                   default == /media/shareX/share/minEASE/test_files/miniTest.xlsx
excelFileDefault = '/media/shareX/share/minEASE/input_files/miniTest_Katie.xlsx';

    if strcmp(excelFile, excelFileDefault)
        error('Usage: minEASE (''excelFile'');');
    end

siMsDefault = 0.1;              % default sampling interval in ms/sample 
                                %   for mat files
addParameter(iP, 'SiMs', siMsDefault, ...
    @(x) validateattributes(x, {'numeric'}, {'scalar', 'positive'}));
siMs            = iP.Results.SiMs;

%    figTypesDisplay = print_cell(figTypes, 'omitNewline', true);
if iscell(figTypes)
    nElements = numel(figTypes);
    figTypesDisplay = '';
    for iElement = 1:nElements
        string = [string, figTypes{iElement}];
        if iElement < nElements
            string = [string, ', '];
        end
    end
else
    figTypesDisplay = figTypes;
end
% figtypes = read_cell(answer{2});

[excelFile, isFigType, figTypes, dataTypeUser, srkHz, skipManualEntered] = ...
    read_and_validate_inputs(inputs);
function [excelFile, isFigType, figTypes, dataTypeUser, srkHz, skipManualEntered] = read_and_validate_inputs(inputs)

            siMs = 0.1;         % 10 kHz
            siMs = 0.05;        % Paula's calcium imaging data are 20 Hz
                                %   Assume ms means s for simplicity
% numLines = [1, 50; 1, 3; 1, 3; 1, 3; 1, 3];

        case 'mat'              % need to be old version of matfile
            allData = importdata(dataFileName); %TODO: Need example           
            siMs = 1/srkHz;                     % sampling interval in ms

      formatOut = 'yyyy-MM-ddTHH:mm:ss';
dateString = datestr(now, formatOut);
      cformatOut = 'yyyy-MM-ddTHH:mm:ss';
dateString = datestr(now, formatOut);
lampfitOutput = [current, isClass];

mfilename = 'minEASE_';

formatOut = 'yyyy-MM-ddTHH:mm:ss';
dateString = datestr(now, formatOut);

            for iClass = 1:REMOVED_CLASSNUM     % for each class
                % Retrieve the breakpoint indices of this class
                idxBreaks = eventInfo(eventClass == iClass, IDXBREAK_COLNUM);

                % Retrieve the peak indices of this class
                idxPeaks = eventInfo(eventClass == iClass, IDXPEAK_COLNUM);

                % Retrieve the inter-stimulus intervals (samples) this class
                interStimulusIntervals = ...
                        eventInfo(eventClass == iClass, ISI_COLNUM);
                
                % Retrieve the full decay times (samples) of this class
                fullDecayTimes = ...
                        eventInfo(eventClass == iClass, FULLDECAY_COLNUM);

                % The ith column of isClass shows whether each data point
                %   lies in that class
                if ~isempty(idxBreaks)
                    for iEvent = 1:length(idxBreaks)
                        idxStart = idxBreaks(iEvent);
                        idxEnd = get_idxEnd(idxPeaks(iEvent), ...
                                            fullDecayTimes(iEvent), ...
                                            interStimulusIntervals(iEvent));
                        isClass(idxStart:idxEnd, iClass) = 1;
                    end
                end
            end

                    answer = questdlg(qString, qTitle, ...
                                        choice1, choice2, choice2);

                    backupDir = ['backup_', datestr(clock, 30), ...

        try
        catch
            idxCurrent = 1;
        end

    % Extract all variables from params:
    % Construct input params matfile name
    paramsFile = fullfile(params.outputDirectory, ...
                ['inputParams_row', num2str(row - 1), '.mat']);

    % Save fields of params as individual variables in a matfile
    save(paramsFile, '-struct', 'params');

    % Load all variables (fields of params) into workspace
    %   NOTE: outputDirectory will be changed in some cases
    load(paramsFile);

            % Combine outputs from all sweeps that are finished
            combine_outputs(outputDirectory, expLabel, ...
                                    dataDirectory, dataMode, ...
                                    plotAverageTraceFlag, traceLengthMs, ...
                                    beforePeakMs, figTypes, noMessages);

choiceDefault = 'Yes';

            isClassClampfit = firstQuartileData + isClass * halfRangeData;

            medianData = (maxData + minData) / 2;   % median for this trace
            halfRangeData = (maxData - minData) / 2;% half range for this trace
            firstQuartileData = medianData - halfRangeRounded/2;
                                        % first quartile for this trace

            % Compute a rounded half range for the Clampfit file
            %   Use one significant figure only to save data space
            halfRangeRounded = round(halfRangeData, 1, 'significant');
            placesToTheRight = -log10(halfRangeRounded);
            % Compute a rounded first quartile for the Clampfit file
            firstQuartileRounded = round(firstQuartileData, placesToTheRight);
            nSigFigMax = max(sigfig(halfRangeRounded), ...
                            sigfig(firstQuartileRounded));
            % Shift the 0's and 1's to the first and third quartiles
            toSpikeClampfit = firstQuartileRounded + toSpike * halfRangeRounded;
            % TODO: Removed time column from Clampfit file to save data space
            clampfitOutput = [shiftedTimeColumn, current, toSpikeClampfit];
            % Note: dlmwrite() uses ',' as the delimiter by default, 
            %   so if precision is not important (within 5 significant digits), 
            %   csvwrite() suffices. However, the time value often has more 
            %   than 5 significant digits, so dlmwrite() is necessary
            % Place a time column, the raw data and the Clampfit spike positions
            %   together in a matrix
            %   Since sampling rate may be up to 50 kHz, 
            %   at least 2 decimal places is necessary
            clampfitFileName = fullfile(outputDirectory, ...
                                sprintf('%s_trace.csv', sweepLabel));
            dlmwrite(clampfitFileName, clampfitOutput, ...
                        'precision', '%.2f');

            % Can't use dlmwrite to make different columns a different precision
            dlmwrite(clampfitFileName, clampfitOutput, ...
                        'precision', sprintf('%%.%dg', nSigFigMax));

            % Place the raw data and the Clampfit spike positions
            %   together in a matrix    [toBeAnalyzedAll, paramsAll, errormsg] = minEASE_read_params(xlInfo, xlHeader);

            clampfitOutput = [current, toSpikeClampfit];

                    mTitle = 'Sweep to plot';

    % Extract information for this data subdirectory to a params structure
    rowInfo = xlInfo(row, :);               % info for this data subdirectory
    [toBeAnalyzed, params, errormsg] = minEASE_read_params(rowInfo, xlHeader);

    [toBeAnalyzedAll, paramsAll, errormsg] = minEASE_read_params(rowInfo, xlHeader);

    % Extract the header
    xlHeader = xlInfo(1, :);                % a cell array containing the header
  
        message = sprintf(['Row #%d read!'], row);

%for row = 2:nRows

    % Skip this row if toBeAnalyzed is 'N'
    if strcmpi(toBeAnalyzed, 'N')
        continue;
    end
                continue
                continue;

    continue;
    
    % TODO: for DEBUG
%    for row = 2:nRows


            % TODO: Doesn't seem to be working well
            % Find the maximum number of significant figures necessary
            %   This saves data space
            % nSigFigMax = max(sigfig(minRounded), sigfig(rangeRounded));
%                fprintf(fid, ['%g', repmat(sprintf(', %%.%dg', nSigFigMax), ...
%   TODO: Doesn't seem to be working well


% Skip this row if toBeAnalyzed is 'N'
if strcmpi(toBeAnalyzed, 'No')

                % Skip this sweep
                fprintf(['Output file %s already exists. Skipped!\n'], ...
                            matFileName);
                return;

                message = {'No events are detected for this sweep!', ...
                        'Try decreasing the signal to noise threshold ...'};

    print_or_show_message(~skipManual, message, ...
                         'MTitle', mTitle, 'Icon', icon);

%                   - 'NoMessages': whether to suppress message boxes
%                   must be numeric/logical 1 (true) or 0 (false)
%                   default == false
noMessagesDefault = true;       % whether to suppress message boxes by default
addParameter(iP, 'NoMessages', noMessagesDefault, ...
    @(x) validateattributes(x, {'logical', 'numeric'}, {'binary'}));
noMessages      = iP.Results.NoMessages;
if noMessages
    noMessagesDisplay = 'yes';
else
    noMessagesDisplay = 'no';
end
            'Would you like to suppress message boxes? (''yes''/''no''):', ...
defaultAns = {excelFile, figTypesDisplay, dataTypeUser, ...
                num2str(srkHz), skipManualDisplay, ...
                noMessagesDisplay, noPromptsDisplay};
    noMessagesEntered = validate_string(inputs{6}, {'yes', 'no'});
    elseif isempty(noMessagesEntered)
                                % if noMessagesEntered invalid
        msg = ['You must enter ''yes'' or ''no'' ', ...
                'for whether to suppress message boxes'];
    elseif strcmp(skipManualEntered, 'yes') && strcmp(noMessagesEntered, 'no')
                                % if user wants to show message boxes 
                                %   in skip manual mode
switch noMessagesEntered
case 'yes'
    noMessages = true;
case 'no'
    noMessages = false;
end

    if noMessages
        print_or_show_message(message, 'MessageMode', 'none', ...
                                'MTitle', mTitle, 'Icon', icon);
    else
        print_or_show_message(message, 'MessageMode', 'wait', ...
                                'MTitle', mTitle, 'Icon', icon);
    end
                minEASE_detect_gapfree_events(current, siMs, directionPsc, ...
                                        params, 'ShowMessage', ~noMessages);
                answer = combine_outputs_if_needed(noPrompts, ...
                            noMessages, qString, outputDirectory, ...
                            expLabel, dataDirectory, dataMode, ...
                            plotAverageTraceFlag, traceLengthMs, ...
                            beforePeakMs, figTypes);
    combine_outputs(noMessages, outputDirectory, expLabel, ...
                    dataDirectory, dataMode, ...
                    plotAverageTraceFlag, ...
                    traceLengthMs, beforePeakMs, ...
                    figTypes);
minEASE_combine_events(outputDirectory, expLabel, 'ms', 'ShowMessage', ~noMessages);
[allEventInfo, allEventClass, ~, siMs] = ...
    minEASE_combine_events(outputDirectory, expLabel, 'samples', ...
                        'ShowMessage', ~noMessages);


        minEASE_compute_plot_average_psc(allEventInfo, allEventClass, ...
                                        allData, siMs, ...
                                        traceLengthMs, beforePeakMs, ...
                                        possibleDealWithTooShort{iMethod}, ...
                                        outputDirectory, expLabel, figTypes, ...
                                        'ShowMessage', ~noMessages);
allData = combine_sweeps(dataDirectory, expLabel, dataMode, ...
                            'SweepNumbers', 1:nSweeps, ...
                            'ShowMessage', ~noMessages);

%   Mode        openGui    toPrompt    messageMode outputExist combineOutputs   verbose
%   'init'      false      false       'done'      'skip'      'No'             false
%   'rerun'     false      false       'show'      'archive'   'No'             false
%   'check'     true       false       'wait'      'load'      'No'             false
%   'modify'    true       true        'wait'      'load' (p)  'No'  (p)        false
%   'debug'     true       true        'wait'      'archive'(p)'Yes' (p)        true

%                   - 'SkipManual': whether to skip manual checking of events
%                   must be numeric/logical 1 (true) or 0 (false)
%                   default == false
%                   - 'NoPrompts': whether to suppress prompts
%                   must be numeric/logical 1 (true) or 0 (false)
%                   default == false
skipManualDefault = false;      % whether to skip manual checking 
                                %   of events by default
noPromptsDefault = true;        % whether to suppress prompts by default
addParameter(iP, 'SkipManual', skipManualDefault, ...
    @(x) validateattributes(x, {'logical', 'numeric'}, {'binary'}));
addParameter(iP, 'NoPrompts', noPromptsDefault, ...
    @(x) validateattributes(x, {'logical', 'numeric'}, {'binary'}));
skipManual      = iP.Results.SkipManual;
noPrompts       = iP.Results.NoPrompts;

if skipManual
    skipManualDisplay = 'yes';
else
    skipManualDisplay = 'no';
end
if noPrompts
    noPromptsDisplay = 'yes';
else
    noPromptsDisplay = 'no';
end
    skipManualEntered = validate_string(inputs{5}, {'yes', 'no'});
    noPromptsEntered = validate_string(inputs{7}, {'yes', 'no'});
    elseif isempty(skipManualEntered)
                                % if skipManualEntered invalid
        msg = ['You must enter ''yes'' or ''no'' ', ...
                'for whether to skip manual mode'];
    elseif isempty(noPromptsEntered)
                                % if noPromptsEntered invalid
        msg = ['You must enter ''yes'' or ''no'' ', ...
                'for whether to suppress prompts'];
    elseif strcmp(skipManualEntered, 'yes') && strcmp(messageModeUser, 'wait')
                                % if user wants to wait for message boxes 
                                %   in skip manual mode
if skipManual && noPrompts && strcpm(messageMode, 'done')

%   In this case, output messages will be shown in the standard output 
%       instead of with message boxes

prompt1 = {'Input Excel file (leave blank if to be selected):', ...
            'Figure type for saving (''png'', ''jpg'', ''gif'', etc.):', ...
            ['Data type (''', ...
                strjoin(possibleDataTypes, ''', '''), ''' or ''auto''):'], ...
            'Sampling rate (kHz) (ignored if ABF files used):', ...
            ['Run mode (''', strjoin(validRunModes, ''', '''), '''):'], ...
            ['Would you like to open GUIs? (''', ...
                strjoin(validAnswers, ''', '''), ''' or ''auto''):'], ...
            ['Would you like to prompt before decisions? (''', ...
                strjoin(validAnswers, ''', '''), ''' or ''auto''):'], ...
            ['Would you like to show and wait for message boxes? (''', ...
                strjoin(validMessageModes, ''', '''), ''' or ''auto''):'], ...
            ['What to do to previous results if any? (''', ...
                strjoin(validPrevResultActions, ''', '''), ''' or ''auto''):'], ...
            ['Do you want to combine outputs across sweeps for each file? (''', ...
                strjoin(validAnswers, ''', '''), ''' or ''auto''):'], ...
            ['Would you like to use the verbose mode (Under development)? (''', ...
                strjoin(validAnswers, ''', '''), ''' or ''auto''):'], ...
            };
numLines = [1, 50; 1, 50; 1, 50; 1, 50; ...
            1, 50; 1, 50; 1, 50; 1, 50; ...
            1, 50; 1, 50; 1, 50];
defaultAns = {excelFile, figTypesDisplay, dataTypeUser, num2str(srkHz), ...
                runModeUser, openGuiUser, toPromptUser, messageModeUser, ...
                prevResultActionUser, combineOutputsUser, verboseUser};

    openGuiEntered1 = validate_string(inputs{6}, ...
                        [validAnswers, {'auto'}]);
    toPromptEntered1 = validate_string(inputs{7}, ...
                        [validAnswers, {'auto'}]);
    messageModeEntered1 = validate_string(inputs{8}, ...
                        [validMessageModes, {'auto'}]);
    prevResultActionEntered1 = validate_string(inputs{9}, ...
                        [validPrevResultActions, {'auto'}]);
    combineOutputsEntered1 = validate_string(inputs{10}, ...
                        [validAnswers, {'auto'}]);
    verboseEntered1 = validate_string(inputs{11}, ...
                        [validAnswers, {'auto'}]);

if strcmp(openGuiEntered1, 'auto')
    switch runModeEntered
    case {'init', 'rerun'}
        openGuiEntered2 = 'no';
    case {'check', 'modify', 'debug'}
        openGuiEntered2 = 'yes';
    otherwise
        error('Error with code!');
    end
end
if strcmp(toPromptEntered1, 'auto')
    switch runModeEntered
    case {'init', 'rerun', 'check'}
        toPromptEntered2 = 'no';
    case {'modify', 'debug'}
        toPromptEntered2 = 'yes';
    otherwise
        error('Error with code!');
    end
end
if strcmp(messageModeEntered1, 'auto')
    switch runModeEntered
    case 'init'
        messageModeEntered2 = 'done';
    case 'rerun'
        messageModeEntered2 = 'show';
    case {'check', 'modify', 'debug'}
        messageModeEntered2 = 'wait';
    otherwise
        error('Error with code!');
    end
end
if strcmp(prevResultActionEntered1, 'auto')
    switch runModeEntered
    case 'init'
        prevResultActionEntered2 = 'skip';
    case {'rerun', 'debug'}
        prevResultActionEntered2 = 'archive';
    case {'check', 'modify'}
        prevResultActionEntered2 = 'load';
    otherwise
        error('Error with code!');
    end
end
if strcmp(combineOutputsEntered1, 'auto')
    switch runModeEntered
    case {'init', 'check', 'modify', 'debug'}
        combineOutputsEntered2 = 'no';
    case 'debug'
        combineOutputsEntered2 = 'yes';
    otherwise
        error('Error with code!');
    end
end
if strcmp(verboseEntered1, 'auto')
    switch runModeEntered
    case {'init', 'check', 'modify', 'debug'}
        verboseEntered2 = 'no';
    case 'debug'
        verboseEntered2 = 'yes';
    otherwise
        error('Error with code!');
    end
end

            if openGui
                % The default is to load previous result
                %   when the user is checking results
                choiceDefault = choice2;
            else
                % The default is to archive and start new detection
                %   when the user is rerunning all files with new parameters
%                    choiceDefault = choice3;

                % The default is to skip sweeps that were already processed
                %   when the user is initially running all files
                choiceDefault = choice1;
            end

if ~openGui && ~toPrompt && strcmp(messageMode, 'done')
% Not sure why it's saying that the function definition is "improperly nested" here.
if strcmp(outputClampfitUser)
    switch outputClampEntered
    case 'false'
        outputClampfitUser = 'no';
    case 'true'
        outputClampfitUser = 'yes';
    otherwise
        error('Error with code!');
    end

        msg = {'Must specify either ''yes'' or ''no''', ...
                    'for whether to output Clampfit files'};

    openGuiEntered = validate_string(inputs2{1}, ...
                        [validAnswers, {'auto'}]);
    toPromptEntered = validate_string(inputs2{2}, ...
                        [validAnswers, {'auto'}]);
    messageModeEntered = validate_string(inputs2{3}, ...
                        [validMessageModes, {'auto'}]);
    prevResultActionEntered = validate_string(inputs2{4}, ...
                        [validPrevResultActions, {'auto'}]);
    combineOutputsEntered = validate_string(inputs2{5}, ...
                        [validAnswers, {'auto'}]);
    verboseEntered = validate_string(inputs2{6}, ...
                        [validAnswers, {'auto'}]);
    elseif isempty(roiPlot) && ~strcmp(inputs1{7}, 'auto') || ...
    	   ~(isnumeric(roiPlot) && isvector(roiPlot) && numel(roiPlot) == 2)

addOptional(iP, 'excelFile', excelFileDefault, @ischar);

For listing subdirectory names from a given directory

allFilesAndDirs = dir('...')
allDirs = allFilesAndDirs(cellfun(@(x) x == 1, {allFilesAndDirs.isdir})
allDirNames = {allDirs.name};

parpool('local');

% Initialize with automatically detected results
eventInfoLast = eventInfoAuto;
eventClassLast = eventClassAuto;

% Reset isChecked
isCheckedLast = logical(zeros(size(eventInfoLast, 1), 1));

idxCurrent = strcmpi('Current', channelTypes);

%       sigfig.m                    (through minEASE.m)

% TODO: implement custom exit icon
icon = 'none';

%}
