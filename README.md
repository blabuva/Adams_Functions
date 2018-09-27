## Adam's functions for sharing across projects

*Note*: This file is automatically generated.  Please do not edit manually.

Last Updated 2018-09-27 by Adam Lu

***

- [**abf2mat.m**](https://github.com/blabuva/Adams_Functions/blob/master/abf2mat.m): Converts .abf files to .mat files with time vector (in ms) included
- [**adjust_peaks.m**](https://github.com/blabuva/Adams_Functions/blob/master/adjust_peaks.m): Adjusts peak indices and values given approximate peak indices
- [**all_ordered_pairs.m**](https://github.com/blabuva/Adams_Functions/blob/master/all_ordered_pairs.m): Generates a cell array of all ordered pairs of elements/indices, one from each vector
- [**analyze_adicht.m**](https://github.com/blabuva/Adams_Functions/blob/master/analyze_adicht.m): Read in the data from the .adicht file
- [**analyzeCI.m**](https://github.com/blabuva/Adams_Functions/blob/master/analyzeCI.m): function [alldata] = analyzeCI(date)	
- [**analyze_cobalt.m**](https://github.com/blabuva/Adams_Functions/blob/master/analyze_cobalt.m): Clear workspace
- [**atf2sheet.m**](https://github.com/blabuva/Adams_Functions/blob/master/atf2sheet.m): Converts .atf text file(s) to a spreadsheet file(s) (type specified by the 'SheetType' argument)
- [**bar_w_CI.m**](https://github.com/blabuva/Adams_Functions/blob/master/bar_w_CI.m): Plot bar graph (esp. grouped) with confidence intervals
- [**boltzmann.m**](https://github.com/blabuva/Adams_Functions/blob/master/boltzmann.m): the sigmoidal Boltzmann function
- [**change_params.m**](https://github.com/blabuva/Adams_Functions/blob/master/change_params.m): Change parameter values
- [**check_and_collapse_identical_contents.m**](https://github.com/blabuva/Adams_Functions/blob/master/check_and_collapse_identical_contents.m): Checks if a cell array or array has identical contents and collapse it to one copy of the content
- [**check_dir.m**](https://github.com/blabuva/Adams_Functions/blob/master/check_dir.m): Checks if needed directory(ies) exist and creates them if not
- [**check_subdir.m**](https://github.com/blabuva/Adams_Functions/blob/master/check_subdir.m): Checks if needed subdirectory(ies) exist in parentDirectory
- [**clcf.m**](https://github.com/blabuva/Adams_Functions/blob/master/clcf.m): clcf.m
- [**color_index.m**](https://github.com/blabuva/Adams_Functions/blob/master/color_index.m): Find the colormap index for a given value with boundaries set by edges
- [**combine_loopedparams.m**](https://github.com/blabuva/Adams_Functions/blob/master/combine_loopedparams.m): TODO
- [**combine_sweeps.m**](https://github.com/blabuva/Adams_Functions/blob/master/combine_sweeps.m): Combines sweeps that begin with expLabel in dataDirectory under dataMode
- [**compute_and_plot_concatenated_trace.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_and_plot_concatenated_trace.m): Computes and plots concatenated traces from parsed ABF file results
- [**compute_and_plot_evoked_LFP.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_and_plot_evoked_LFP.m): Computes and plots an evoked local field potential with its stimulus
- [**compute_average_initial_slopes.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_average_initial_slopes.m): Computes the average initial slope from a current pulse response
- [**compute_conductance.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_conductance.m): Compute theoretical conductance curve for the GABA_B IPSC used by dynamic clamp
- [**compute_elcurr.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_elcurr.m): Computes electrode current from conductance & voltage
- [**compute_eRev.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_eRev.m): Computes the reversal potential of a channel that passes monovalent ions using the GHK voltage equation
- [**compute_IMax_GHK.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_IMax_GHK.m): Computes the maximum current [mA/cm^2] using the GHK current equation
- [**compute_rms_error.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_rms_error.m): Computes the root mean squared error given two vectors
- [**compute_slope.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_slope.m): Computes the slope given two vectors and two indices
- [**construct_abffilename.m**](https://github.com/blabuva/Adams_Functions/blob/master/construct_abffilename.m): Constructs the full file name to an abf file robustly based on filename and display message if doesn't exist
- [**construct_fullfilename.m**](https://github.com/blabuva/Adams_Functions/blob/master/construct_fullfilename.m): Constructs full file name based on filename and an optional full directory path with optional suffices and/or Name-Value pairs
- [**construct_suffix.m**](https://github.com/blabuva/Adams_Functions/blob/master/construct_suffix.m): Constructs final suffix based on optional suffices and/or Name-Value pairs
- [**correct_unbalanced_bridge.m**](https://github.com/blabuva/Adams_Functions/blob/master/correct_unbalanced_bridge.m): Shifts a current pulse response to correct the unbalanced bridge
- [**create_input_file.m**](https://github.com/blabuva/Adams_Functions/blob/master/create_input_file.m): Create an input spreadsheet file from data file names in a directory based on default parameters
- [**create_pulse_train_series.m**](https://github.com/blabuva/Adams_Functions/blob/master/create_pulse_train_series.m): Creates a pulse train series (a theta burst stimulation by default)
- [**create_subdir_copy_files.m**](https://github.com/blabuva/Adams_Functions/blob/master/create_subdir_copy_files.m): Create subdirectory and copy figure files
- [**create_waveform_train.m**](https://github.com/blabuva/Adams_Functions/blob/master/create_waveform_train.m): Creates a waveform train from a waveform, a frequency, and a total duration
- [**crosscorr_profile.m**](https://github.com/blabuva/Adams_Functions/blob/master/crosscorr_profile.m): data: each channel is a column
- [**csvwrite_with_header.m**](https://github.com/blabuva/Adams_Functions/blob/master/csvwrite_with_header.m): Write a comma-separated value file with given header
- [**distribute_balls_into_boxes.m**](https://github.com/blabuva/Adams_Functions/blob/master/distribute_balls_into_boxes.m): Returns the ways and number of ways to distribute identical/discrete balls into identical/discrete boxes
- [**draw_arrow.m**](https://github.com/blabuva/Adams_Functions/blob/master/draw_arrow.m): Draw an arrow from p1 to p2
- [**find_custom.m**](https://github.com/blabuva/Adams_Functions/blob/master/find_custom.m): Same as find() but takes custom parameter-value pairs
- [**find_data_files.m**](https://github.com/blabuva/Adams_Functions/blob/master/find_data_files.m): Looks for data files in a dataDirectory according to either dataTypeUser or going through a list of possibleDataTypes
- [**find_filebases.m**](https://github.com/blabuva/Adams_Functions/blob/master/find_filebases.m): Finds base names for files in infolder/subdir and return as a cell array of cell arrays of strings
- [**find_first_deviant.m**](https://github.com/blabuva/Adams_Functions/blob/master/find_first_deviant.m): Finds the index of the first deviant from preceding peers in a time series
- [**find_first_jump.m**](https://github.com/blabuva/Adams_Functions/blob/master/find_first_jump.m): Finds the index of the first jump in a time series
- [**find_ind_str_in_cell.m**](https://github.com/blabuva/Adams_Functions/blob/master/find_ind_str_in_cell.m): Find all indices of a particular string in a cell array
- [**find_initial_slopes.m**](https://github.com/blabuva/Adams_Functions/blob/master/find_initial_slopes.m): Find all initial slopes from a current pulse response
- [**find_IPSC_peak.m**](https://github.com/blabuva/Adams_Functions/blob/master/find_IPSC_peak.m): Finds time of current peak from a an inhibitory current trace (must be negative current)
- [**find_istart.m**](https://github.com/blabuva/Adams_Functions/blob/master/find_istart.m): Finds time of current application from a series of current vectors
- [**find_istart_old.m**](https://github.com/blabuva/Adams_Functions/blob/master/find_istart_old.m): Finds time of current application from a series of current vectors
- [**find_LTS.m**](https://github.com/blabuva/Adams_Functions/blob/master/find_LTS.m): Find, plot and classify the most likely low-threshold spike (LTS) candidate in a voltage trace
- [**find_LTSs_many_sweeps.m**](https://github.com/blabuva/Adams_Functions/blob/master/find_LTSs_many_sweeps.m): Calls find_LTS.m for many voltage traces
- [**find_passive_params.m**](https://github.com/blabuva/Adams_Functions/blob/master/find_passive_params.m): Extract passive parameters from both the rising and falling phase of the current pulse response
- [**find_pulse_endpoints.m**](https://github.com/blabuva/Adams_Functions/blob/master/find_pulse_endpoints.m): Finds the indices of a current pulse's start and end
- [**find_pulse_response_endpoints.m**](https://github.com/blabuva/Adams_Functions/blob/master/find_pulse_response_endpoints.m): Computes the average initial slope from a current pulse response
- [**fitdist_initial_slopes.m**](https://github.com/blabuva/Adams_Functions/blob/master/fitdist_initial_slopes.m): Fits initial slope distributions
- [**fit_gaussians_and_refine_threshold.m**](https://github.com/blabuva/Adams_Functions/blob/master/fit_gaussians_and_refine_threshold.m): Fits data to Gaussian mixture models and finds the optimal number of components
- [**fit_IEI.m**](https://github.com/blabuva/Adams_Functions/blob/master/fit_IEI.m): Fit IEI data to curves
- [**fit_kernel.m**](https://github.com/blabuva/Adams_Functions/blob/master/fit_kernel.m): Fits a kernel distribution to a data vector and determine the two primary peaks, the threshold and the void and spacing parameters
- [**fit_logIEI.m**](https://github.com/blabuva/Adams_Functions/blob/master/fit_logIEI.m): Fit log(IEI) logData to curves
- [**freqfilter.m**](https://github.com/blabuva/Adams_Functions/blob/master/freqfilter.m): Uses a Butterworth filter twice to filter data by a frequency band (each column is a vector of samples)
- [**get_idxEnd.m**](https://github.com/blabuva/Adams_Functions/blob/master/get_idxEnd.m): Get the index of the end of an event
- [**get_loopedparams.m**](https://github.com/blabuva/Adams_Functions/blob/master/get_loopedparams.m): Get parameters that were looped in the simulation from loopedparams.mat
- [**histg.m**](https://github.com/blabuva/Adams_Functions/blob/master/histg.m): HISTG    'Grouped' univariate histogram
- [**histogram_include_outofrange.m**](https://github.com/blabuva/Adams_Functions/blob/master/histogram_include_outofrange.m): Plots a histogram including out of range values
- [**histproperties.m**](https://github.com/blabuva/Adams_Functions/blob/master/histproperties.m): Computes the area, edges of the histogram for given data array
- [**identify_eLFP.m**](https://github.com/blabuva/Adams_Functions/blob/master/identify_eLFP.m): Identifies whether an abf file follows an eLFP protocol
- [**increment_editbox.m**](https://github.com/blabuva/Adams_Functions/blob/master/increment_editbox.m): Increment or decrement editbox value based on direction
- [**intersect_over_cells.m**](https://github.com/blabuva/Adams_Functions/blob/master/intersect_over_cells.m): Apply the intersect function over all contents of a cell array
- [**isfigtype.m**](https://github.com/blabuva/Adams_Functions/blob/master/isfigtype.m): Check whether a string or each string in a cell array is a valid figure type accepted by saveas()
- [**islinestyle.m**](https://github.com/blabuva/Adams_Functions/blob/master/islinestyle.m): Check whether a string or each string in a cell array is a valid line style accepted by plot() or line()
- [**issheettype.m**](https://github.com/blabuva/Adams_Functions/blob/master/issheettype.m): Check whether a string or each string in a cell array is a valid spreadsheet type accepted by readtable()
- [**istype.m**](https://github.com/blabuva/Adams_Functions/blob/master/istype.m): Check whether a string or each string in a cell array is a valid type specified by validTypes
- [**load_examples.m**](https://github.com/blabuva/Adams_Functions/blob/master/load_examples.m): load_examples.m
- [**load_matfiles_part.m**](https://github.com/blabuva/Adams_Functions/blob/master/load_matfiles_part.m): Load set of matfiles and return relevant info
- [**log_arraytext.m**](https://github.com/blabuva/Adams_Functions/blob/master/log_arraytext.m): Create a text file that logs the array information
- [**log_matfile.m**](https://github.com/blabuva/Adams_Functions/blob/master/log_matfile.m): Print variables in a MATfile to a comma-separated-value file
- [**make_loopedparams.m**](https://github.com/blabuva/Adams_Functions/blob/master/make_loopedparams.m): Construct parameters to change for each trial from loopmode, pnames, pislog, pmin, pmax, pinc 
- [**mat2sheet.m**](https://github.com/blabuva/Adams_Functions/blob/master/mat2sheet.m): Converts .mat files to a spreadsheet file(s) (type specified by the 'SheetType' argument)
- [**match_time_points.m**](https://github.com/blabuva/Adams_Functions/blob/master/match_time_points.m): Interpolates data (containing a time column) to match the time points of a new time vector
- [**my_closereq.m**](https://github.com/blabuva/Adams_Functions/blob/master/my_closereq.m): Close request function that displays a question dialog box
- [**nanstderr.m**](https://github.com/blabuva/Adams_Functions/blob/master/nanstderr.m): Calculate the standard error of the mean excluding NaN values
- [**parse_abf.m**](https://github.com/blabuva/Adams_Functions/blob/master/parse_abf.m): Loads and parses an abf file
- [**parse_all_abfs.m**](https://github.com/blabuva/Adams_Functions/blob/master/parse_all_abfs.m): Parses all abf files in the directory
- [**piecelinspace.m**](https://github.com/blabuva/Adams_Functions/blob/master/piecelinspace.m): Generates a piece-wise linear row vector from nodes and number of points
- [**plot_all_abfs.m**](https://github.com/blabuva/Adams_Functions/blob/master/plot_all_abfs.m): Plots all abf files in a directory
- [**plot_and_save_boxplot.m**](https://github.com/blabuva/Adams_Functions/blob/master/plot_and_save_boxplot.m): Plots a box plot from a grouped vector according to group
- [**plot_and_save_histogram.m**](https://github.com/blabuva/Adams_Functions/blob/master/plot_and_save_histogram.m): Plots and saves a stacked histogram for a vector and color code according to class
- [**plot_ellipse.m**](https://github.com/blabuva/Adams_Functions/blob/master/plot_ellipse.m): Plot an ellipse that may be oblique
- [**plot_fields.m**](https://github.com/blabuva/Adams_Functions/blob/master/plot_fields.m): Plot all fields from a structure array as tuning curves
- [**plot_FI.m**](https://github.com/blabuva/Adams_Functions/blob/master/plot_FI.m): From a current injection protocol, detect spikes for each sweep and make an F-I plot
- [**plot_grouped_histogram.m**](https://github.com/blabuva/Adams_Functions/blob/master/plot_grouped_histogram.m): Plot a grouped histogram
- [**plot_grouped_scatter.m**](https://github.com/blabuva/Adams_Functions/blob/master/plot_grouped_scatter.m): Plot and save a grouped scatter plot with 95% confidence ellipses
- [**plot_pdf.m**](https://github.com/blabuva/Adams_Functions/blob/master/plot_pdf.m): Plots scaled pdf fit of data X and return vectors for the plots
- [**plot_raster.m**](https://github.com/blabuva/Adams_Functions/blob/master/plot_raster.m): Make a raster plot from a cell array of event time arrays
- [**plot_signals.m**](https://github.com/blabuva/Adams_Functions/blob/master/plot_signals.m): Default values for optional arguments
- [**plot_traces_abf.m**](https://github.com/blabuva/Adams_Functions/blob/master/plot_traces_abf.m): Takes an abf file and plots all traces
- [**plot_traces.m**](https://github.com/blabuva/Adams_Functions/blob/master/plot_traces.m): Plots traces all in one place, overlapped or in parallel
- [**plot_traces_mat.m**](https://github.com/blabuva/Adams_Functions/blob/master/plot_traces_mat.m): Plot traces from mat file
- [**plot_tuning_curve.m**](https://github.com/blabuva/Adams_Functions/blob/master/plot_tuning_curve.m): Plot a 1-dimensional tuning curve
- [**plot_tuning_map.m**](https://github.com/blabuva/Adams_Functions/blob/master/plot_tuning_map.m): Plot a 2-dimensional tuning map
- [**print_and_show_message.m**](https://github.com/blabuva/Adams_Functions/blob/master/print_and_show_message.m): Print to standard output and show message box at the same time
- [**print_next_in_csv.m**](https://github.com/blabuva/Adams_Functions/blob/master/print_next_in_csv.m): What to print next in a csv file
- [**print_or_show_message.m**](https://github.com/blabuva/Adams_Functions/blob/master/print_or_show_message.m): Either print a message in standard output or show a message box
- [**print_structure.m**](https://github.com/blabuva/Adams_Functions/blob/master/print_structure.m): Display all fields of a structure recursively
- [**read_adicht.m**](https://github.com/blabuva/Adams_Functions/blob/master/read_adicht.m): fileName = 'C:\Users\Pinn Analysis\Desktop\Shinnosuke\data\cobalt multi 07192018.adicht';
- [**remove_outliers.m**](https://github.com/blabuva/Adams_Functions/blob/master/remove_outliers.m): Removes outliers from a data matrix and return a new matrix
- [**rescale_vec.m**](https://github.com/blabuva/Adams_Functions/blob/master/rescale_vec.m): Rescale a vector (vec1) to be in the same ballpark as another vector (vec2),
- [**restore_fields.m**](https://github.com/blabuva/Adams_Functions/blob/master/restore_fields.m): Set each field specified in varargin to previous values from the field strcat(field, '_prev')
- [**save_all_figtypes.m**](https://github.com/blabuva/Adams_Functions/blob/master/save_all_figtypes.m): Save figures using all figure types provided
- [**set_fields_zero.m**](https://github.com/blabuva/Adams_Functions/blob/master/set_fields_zero.m): Set each field specified in varargin to zero and store previous values in a new field strcat(field, '_prev')
- [**sigfig.m**](https://github.com/blabuva/Adams_Functions/blob/master/sigfig.m): Get the number of significant figures from a number (numeric or string)
- [**sscanf_full.m**](https://github.com/blabuva/Adams_Functions/blob/master/sscanf_full.m): Same as sscanf but treats unmatched parts as whitespace (does not stop until end of string)
- [**stderr.m**](https://github.com/blabuva/Adams_Functions/blob/master/stderr.m): Calculate the standard error of the mean
- [**struct2mat.m**](https://github.com/blabuva/Adams_Functions/blob/master/struct2mat.m): Saves each variable in a structure as a variable in a MAT-file and create a logHeader and a logVariables
- [**structs2vecs.m**](https://github.com/blabuva/Adams_Functions/blob/master/structs2vecs.m): Converts a cell array of structs with equal numbers of fields to a column cell array of row vectors or cell arrays
- [**suptitle.m**](https://github.com/blabuva/Adams_Functions/blob/master/suptitle.m): SUPTITLE puts a title above all subplots.
- [**test.m**](https://github.com/blabuva/Adams_Functions/blob/master/test.m): 
- [**union_over_cells.m**](https://github.com/blabuva/Adams_Functions/blob/master/union_over_cells.m): Apply the union function over all contents of a cell array
- [**update_params.m**](https://github.com/blabuva/Adams_Functions/blob/master/update_params.m): Update dependent parameters for particular experiments
- [**validate_string.m**](https://github.com/blabuva/Adams_Functions/blob/master/validate_string.m): Validate whether a string is an element of a cell array of valid strings
- [**vec2array.m**](https://github.com/blabuva/Adams_Functions/blob/master/vec2array.m): Convert a vector to an array with dimensions given by dims using linear indexing
- [**vec2cell.m**](https://github.com/blabuva/Adams_Functions/blob/master/vec2cell.m): Reorganize a vector or array into a cell array of partial vectors/arrays according to class
- [**vertcat_spreadsheets.m**](https://github.com/blabuva/Adams_Functions/blob/master/vertcat_spreadsheets.m): Combine spreadsheets using readtable, vertcat, then writetable
- [**ZG_compute_IEI_thresholds.m**](https://github.com/blabuva/Adams_Functions/blob/master/ZG_compute_IEI_thresholds.m): Compute all possible inter-event interval thresholds from the data within an all_output directory
- [**ZG_extract_all_data.m**](https://github.com/blabuva/Adams_Functions/blob/master/ZG_extract_all_data.m): Extract each cell and concatenate sweeps into a single file under a subdirectory of its own
- [**ZG_extract_all_IEIs.m**](https://github.com/blabuva/Adams_Functions/blob/master/ZG_extract_all_IEIs.m): Extract all the inter-event intervals from a directory containing multiple minEASE output subdirectories
- [**ZG_extract_IEI_thresholds.m**](https://github.com/blabuva/Adams_Functions/blob/master/ZG_extract_IEI_thresholds.m): Extract/compute inter-event-interval distribution thresholds, separating events from spikes
- [**ZG_fit_IEI_distributions.m**](https://github.com/blabuva/Adams_Functions/blob/master/ZG_fit_IEI_distributions.m): Fit inter-event-interval distributions and log distributions
