## Adam's functions for sharing across projects

*Note*: This file is automatically generated.  Please do not edit manually.

Last Updated 2019-01-16 by Adam Lu

***

- [**abf2mat.m**](https://github.com/blabuva/Adams_Functions/blob/master/abf2mat.m): Converts .abf files to .mat files with time vector (in ms) included
- [**addpath_custom.m**](https://github.com/blabuva/Adams_Functions/blob/master/addpath_custom.m): Add a folder to MATLAB path only if is not already on the path
- [**adjust_peaks.m**](https://github.com/blabuva/Adams_Functions/blob/master/adjust_peaks.m): Adjusts peak indices and values given approximate peak indices
- [**all_data_files.m**](https://github.com/blabuva/Adams_Functions/blob/master/all_data_files.m): Looks for data files in a dataDirectory according to either dataTypeUser or going through a list of possibleDataTypes
- [**all_filebases.m**](https://github.com/blabuva/Adams_Functions/blob/master/all_filebases.m): Returns all the file bases in a given directory (optionally recursive) that matches a prefix, keyword, suffix or extension
- [**all_files.m**](https://github.com/blabuva/Adams_Functions/blob/master/all_files.m): Returns all the files in a given directory (optionally recursive) that matches a prefix, keyword, suffix or extension
- [**all_ordered_pairs.m**](https://github.com/blabuva/Adams_Functions/blob/master/all_ordered_pairs.m): Generates a cell array of all ordered pairs of elements/indices, one from each vector
- [**all_subdirs.m**](https://github.com/blabuva/Adams_Functions/blob/master/all_subdirs.m): Returns all the subdirectories in a given directory
- [**all_swd_sheets.m**](https://github.com/blabuva/Adams_Functions/blob/master/all_swd_sheets.m): Returns all files ending with '_SWDs.csv' under a directory recursively
- [**analyze_adicht.m**](https://github.com/blabuva/Adams_Functions/blob/master/analyze_adicht.m): Read in the data from the .adicht file
- [**analyzeCI.m**](https://github.com/blabuva/Adams_Functions/blob/master/analyzeCI.m): function [alldata] = analyzeCI(date)	
- [**analyze_cobalt.m**](https://github.com/blabuva/Adams_Functions/blob/master/analyze_cobalt.m): Clear workspace
- [**annotation_in_plot.m**](https://github.com/blabuva/Adams_Functions/blob/master/annotation_in_plot.m): A wrapper function for the annotation() function that accepts x and y values normalized to the axes
- [**apply_iteratively.m**](https://github.com/blabuva/Adams_Functions/blob/master/apply_iteratively.m): Applies a function iteratively to an array until it becomes a non-cell array scalar
- [**apply_or_return.m**](https://github.com/blabuva/Adams_Functions/blob/master/apply_or_return.m): Applies a function if a condition is true, or return the original argument(s)
- [**argfun.m**](https://github.com/blabuva/Adams_Functions/blob/master/argfun.m): Applies a function to each input argument
- [**atf2sheet.m**](https://github.com/blabuva/Adams_Functions/blob/master/atf2sheet.m): Converts .atf text file(s) to a spreadsheet file(s) (type specified by the 'SheetType' argument)
- [**boltzmann.m**](https://github.com/blabuva/Adams_Functions/blob/master/boltzmann.m): Computes the sigmoidal Boltzmann function
- [**change_params.m**](https://github.com/blabuva/Adams_Functions/blob/master/change_params.m): Change parameter values
- [**check_and_collapse_identical_contents.m**](https://github.com/blabuva/Adams_Functions/blob/master/check_and_collapse_identical_contents.m): Checks if a cell array or array has identical contents and collapse it to one copy of the content
- [**check_dir.m**](https://github.com/blabuva/Adams_Functions/blob/master/check_dir.m): Checks if needed directory(ies) exist and creates them if not
- [**check_fullpath.m**](https://github.com/blabuva/Adams_Functions/blob/master/check_fullpath.m): Checks whether a path or paths exists and prints message if not
- [**check_membership.m**](https://github.com/blabuva/Adams_Functions/blob/master/check_membership.m): Checks whether all elements of the first set are elements of the second set and print the ones that aren't
- [**check_subdir.m**](https://github.com/blabuva/Adams_Functions/blob/master/check_subdir.m): Checks if needed subdirectory(ies) exist in parentDirectory
- [**check_within_bounds.m**](https://github.com/blabuva/Adams_Functions/blob/master/check_within_bounds.m): Checks whether all values are within bounds and print the ones that aren't
- [**choose_random_values.m**](https://github.com/blabuva/Adams_Functions/blob/master/choose_random_values.m): Chooses random values from bounds
- [**choose_stimulation_type.m**](https://github.com/blabuva/Adams_Functions/blob/master/choose_stimulation_type.m): Chooses the stimulation type based on the response type
- [**clcf.m**](https://github.com/blabuva/Adams_Functions/blob/master/clcf.m): clcf.m
- [**collapse_identical_vectors.m**](https://github.com/blabuva/Adams_Functions/blob/master/collapse_identical_vectors.m): Collapses identical vectors into a single one
- [**color_index.m**](https://github.com/blabuva/Adams_Functions/blob/master/color_index.m): Find the colormap index for a given value with boundaries set by edges
- [**combine_loopedparams.m**](https://github.com/blabuva/Adams_Functions/blob/master/combine_loopedparams.m): TODO
- [**combine_swd_sheets.m**](https://github.com/blabuva/Adams_Functions/blob/master/combine_swd_sheets.m): Combines all files ending with '_SWDs.csv' under a directory
- [**combine_sweeps.m**](https://github.com/blabuva/Adams_Functions/blob/master/combine_sweeps.m): Combines sweeps that begin with expLabel in dataDirectory under dataMode
- [**compute_all_pulse_responses.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_all_pulse_responses.m): Filter and extract all pulse response and compute features
- [**compute_and_plot_all_responses.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_and_plot_all_responses.m): Computes and plots all pulse responses with stimulus
- [**compute_and_plot_average_response.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_and_plot_average_response.m): Computes and plots an average pulse response with its stimulus
- [**compute_and_plot_concatenated_trace.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_and_plot_concatenated_trace.m): Computes and plots concatenated traces from parsed ABF file results
- [**compute_average_pulse_response.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_average_pulse_response.m): Computes an average pulse response as well as its features
- [**compute_average_trace.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_average_trace.m): Computes the average of traces that are not necessarily the same length
- [**compute_axis_limits.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_axis_limits.m): Computes x or y axis limits from data (works also for a range [min(data), max(data)])
- [**compute_baseline_noise.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_baseline_noise.m): Computes the baseline noise from a set of data vectors, time vectors and baseline windows
- [**compute_bins.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_bins.m): Computes bin counts and edges from a vector
- [**compute_centers_from_edges.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_centers_from_edges.m): Computes bin centers from bin edges
- [**compute_combined_data.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_combined_data.m): Average data according column numbers to average and to a grouping vector
- [**compute_combined_trace.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_combined_trace.m): Computes a combined trace from a set of traces
- [**compute_conductance.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_conductance.m): Compute theoretical conductance curve for the GABA_B IPSC used by dynamic clamp
- [**compute_default_sweep_info.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_default_sweep_info.m): Computes default windows, noise, weights and errors
- [**compute_elcurr.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_elcurr.m): Computes electrode current from conductance & voltage
- [**compute_eRev.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_eRev.m): Computes the reversal potential of a channel that passes monovalent ions using the GHK voltage equation
- [**compute_gpas.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_gpas.m): Computes the passive conductance (gpas, in S/cm^2) from input resistance and surface area
- [**compute_grouped_histcounts.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_grouped_histcounts.m): Computes bin counts and edges from grouped data
- [**compute_IMax_GHK.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_IMax_GHK.m): Computes the maximum current [mA/cm^2] using the GHK current equation
- [**compute_initial_slopes.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_initial_slopes.m): Computes the average initial slope from a current pulse response
- [**compute_maximum_trace.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_maximum_trace.m): Computes the maximum of traces that are not necessarily the same length
- [**compute_means.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_means.m): Computes the mean(s) of vector(s) possibly restricted by endpoint(s)
- [**compute_minimum_trace.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_minimum_trace.m): Computes the minimum of traces that are not necessarily the same length
- [**compute_peak_decay.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_peak_decay.m): Computes the peak decays
- [**compute_peak_halfwidth.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_peak_halfwidth.m): Computes the half widths for peaks
- [**compute_relative_time.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_relative_time.m): Computes time(s) relative to limits from indice(s)
- [**compute_relative_value.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_relative_value.m): Computes value(s) relative to limits
- [**compute_residuals.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_residuals.m): Computes residual vector(s) from simulated and recorded vectors
- [**compute_rms_error.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_rms_error.m): Computes the root mean squared error(s) given one or two sets of vectors
- [**compute_sampling_interval.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_sampling_interval.m): Computes sampling intervals from time vectors
- [**compute_single_neuron_errors.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_single_neuron_errors.m): Computes all errors for single neuron data
- [**compute_slope.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_slope.m): Computes the slope given two vectors and two indices
- [**compute_surface_area.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_surface_area.m): Computes the surface area of a cylindrical compartmental model cell based on lengths and diameters
- [**compute_sweep_errors.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_sweep_errors.m): Computes all errors for single neuron data
- [**compute_weighted_average.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_weighted_average.m): Computes a weighted average value (root-mean-square by default)
- [**construct_and_check_abfpath.m**](https://github.com/blabuva/Adams_Functions/blob/master/construct_and_check_abfpath.m): Constructs the full path to a .abf file and checks whether it exists
- [**construct_and_check_fullpath.m**](https://github.com/blabuva/Adams_Functions/blob/master/construct_and_check_fullpath.m): Constructs the full path to the file or directory and checks whether it exists
- [**construct_fullpath.m**](https://github.com/blabuva/Adams_Functions/blob/master/construct_fullpath.m): Constructs full path(s) based on file/directory name(s) and optional directory, suffices or extension
- [**construct_suffix.m**](https://github.com/blabuva/Adams_Functions/blob/master/construct_suffix.m): Constructs final suffix based on optional suffices and/or Name-Value pairs
- [**convert_sheettype.m**](https://github.com/blabuva/Adams_Functions/blob/master/convert_sheettype.m): Converts all spreadsheets to desired sheettype (all .xlsx and .xls files to .csv files by default)
- [**convert_to_char.m**](https://github.com/blabuva/Adams_Functions/blob/master/convert_to_char.m): Converts other data types to character arrays or a cell array of character arrays
- [**convert_to_rank.m**](https://github.com/blabuva/Adams_Functions/blob/master/convert_to_rank.m): Creates a positive integer array from an array showing the ranks of each element
- [**convert_to_samples.m**](https://github.com/blabuva/Adams_Functions/blob/master/convert_to_samples.m): Converts time(s) from a time unit to samples based on a sampling interval in the same time unit
- [**copyvars.m**](https://github.com/blabuva/Adams_Functions/blob/master/copyvars.m): Copies variable 1 of a table to variable 2 of the same table
- [**correct_unbalanced_bridge.m**](https://github.com/blabuva/Adams_Functions/blob/master/correct_unbalanced_bridge.m): Shifts a current pulse response to correct the unbalanced bridge
- [**count_samples.m**](https://github.com/blabuva/Adams_Functions/blob/master/count_samples.m): Counts the number of samples whether given an array or a cell array
- [**count_vectors.m**](https://github.com/blabuva/Adams_Functions/blob/master/count_vectors.m): Counts the number of vectors whether given an array or a cell array
- [**create_average_time_vector.m**](https://github.com/blabuva/Adams_Functions/blob/master/create_average_time_vector.m): Creates an average time vector from a set of time vectors
- [**create_colormap.m**](https://github.com/blabuva/Adams_Functions/blob/master/create_colormap.m): Returns colorMap based on the number of colors requested
- [**create_default_endpoints.m**](https://github.com/blabuva/Adams_Functions/blob/master/create_default_endpoints.m): Constructs default endpoints from number of samples
- [**create_default_grouping.m**](https://github.com/blabuva/Adams_Functions/blob/master/create_default_grouping.m): Creates numeric grouping vectors and grouping labels from data, counts or original non-numeric grouping vectors
- [**create_empty_match.m**](https://github.com/blabuva/Adams_Functions/blob/master/create_empty_match.m): Creates an empty array that matches a given array
- [**create_error_for_nargin.m**](https://github.com/blabuva/Adams_Functions/blob/master/create_error_for_nargin.m): Creates an error text for not having enough input arguments
- [**create_grouping_by_columns.m**](https://github.com/blabuva/Adams_Functions/blob/master/create_grouping_by_columns.m): Creates a grouping array using column numbers
- [**create_indices.m**](https://github.com/blabuva/Adams_Functions/blob/master/create_indices.m): Creates indices from endpoints (starting and ending indices)
- [**create_input_file.m**](https://github.com/blabuva/Adams_Functions/blob/master/create_input_file.m): Create an input spreadsheet file from data file names in a directory based on default parameters
- [**create_labels_from_numbers.m**](https://github.com/blabuva/Adams_Functions/blob/master/create_labels_from_numbers.m): Creates a cell array of labels from an array of numbers with an optional prefix or suffix
- [**create_latex_string.m**](https://github.com/blabuva/Adams_Functions/blob/master/create_latex_string.m): Creates a LaTeX string from an equation used for fitting
- [**create_pulse.m**](https://github.com/blabuva/Adams_Functions/blob/master/create_pulse.m): Creates a pulse vector
- [**create_pulse_train_series.m**](https://github.com/blabuva/Adams_Functions/blob/master/create_pulse_train_series.m): Creates a pulse train series (a theta burst stimulation by default)
- [**create_simulation_output_filenames.m**](https://github.com/blabuva/Adams_Functions/blob/master/create_simulation_output_filenames.m): Creates simulation output file names
- [**create_subdir_copy_files.m**](https://github.com/blabuva/Adams_Functions/blob/master/create_subdir_copy_files.m): Create subdirectory and copy figure files
- [**create_time_stamp.m**](https://github.com/blabuva/Adams_Functions/blob/master/create_time_stamp.m): Creates a time stamp (default format yyyymmddTHHMM)
- [**create_time_vectors.m**](https://github.com/blabuva/Adams_Functions/blob/master/create_time_vectors.m): Creates time vector(s) in seconds from number(s) of samples and other optional arguments
- [**create_waveform_train.m**](https://github.com/blabuva/Adams_Functions/blob/master/create_waveform_train.m): Creates a waveform train from a waveform, a frequency, and a total duration
- [**crosscorr_profile.m**](https://github.com/blabuva/Adams_Functions/blob/master/crosscorr_profile.m): data: each channel is a column
- [**csvwrite_with_header.m**](https://github.com/blabuva/Adams_Functions/blob/master/csvwrite_with_header.m): Write a comma-separated value file with given header
- [**distribute_balls_into_boxes.m**](https://github.com/blabuva/Adams_Functions/blob/master/distribute_balls_into_boxes.m): Returns the ways and number of ways to distribute identical/discrete balls into identical/discrete boxes
- [**draw_arrow.m**](https://github.com/blabuva/Adams_Functions/blob/master/draw_arrow.m): Draw an arrow from p1 to p2
- [**error_unrecognized.m**](https://github.com/blabuva/Adams_Functions/blob/master/error_unrecognized.m): Throws an error for unrecognized string
- [**estimate_passive_params.m**](https://github.com/blabuva/Adams_Functions/blob/master/estimate_passive_params.m): Estimates passive parameters from fitted coefficients, current pulse amplitude and some constants
- [**estimate_resting_potential.m**](https://github.com/blabuva/Adams_Functions/blob/master/estimate_resting_potential.m): Estimates the resting membrane potential (mV) and the input resistance (MOhm) from holding potentials and holding currents
- [**extract_channel.m**](https://github.com/blabuva/Adams_Functions/blob/master/extract_channel.m): Extracts vectors of a given type from a .abf file
- [**extract_columns.m**](https://github.com/blabuva/Adams_Functions/blob/master/extract_columns.m): Extracts columns from arrays or a cell array of arrays
- [**extract_common_directory.m**](https://github.com/blabuva/Adams_Functions/blob/master/extract_common_directory.m): Extracts the common parent directory of a cell array of file paths
- [**extract_common_prefix.m**](https://github.com/blabuva/Adams_Functions/blob/master/extract_common_prefix.m): Extracts the common prefix of a cell array of strings
- [**extract_common_suffix.m**](https://github.com/blabuva/Adams_Functions/blob/master/extract_common_suffix.m): Extracts the common suffix of a cell array of strings
- [**extract_distinct_fileparts.m**](https://github.com/blabuva/Adams_Functions/blob/master/extract_distinct_fileparts.m): Extracts distinct file parts (removes common parent directory and common suffix)
- [**extract_elements.m**](https://github.com/blabuva/Adams_Functions/blob/master/extract_elements.m): Extracts elements from vectors using a certain mode ('first', 'last', 'min', 'max')
- [**extract_fileparts.m**](https://github.com/blabuva/Adams_Functions/blob/master/extract_fileparts.m): Extracts directories, bases, extensions, distinct parts or the common directory from file paths, treating any path without an extension as a directory
- [**extract_fullpaths.m**](https://github.com/blabuva/Adams_Functions/blob/master/extract_fullpaths.m): Extracts full paths from a files structure array
- [**extract_subvectors.m**](https://github.com/blabuva/Adams_Functions/blob/master/extract_subvectors.m): Extracts subvectors from vectors, given either endpoints, value windows or a certain align mode ('leftAdjust', 'rightAdjust')
- [**files2contents.m**](https://github.com/blabuva/Adams_Functions/blob/master/files2contents.m): Replaces file names with file contents in a cell array of strings
- [**filter_and_extract_pulse_response.m**](https://github.com/blabuva/Adams_Functions/blob/master/filter_and_extract_pulse_response.m): Filters and extracts pulse response(s) from a .abf file
- [**find_custom.m**](https://github.com/blabuva/Adams_Functions/blob/master/find_custom.m): Same as find() but takes custom parameter-value pairs
- [**find_first_deviant.m**](https://github.com/blabuva/Adams_Functions/blob/master/find_first_deviant.m): Finds the index of the first deviant from preceding peers in a time series
- [**find_first_jump.m**](https://github.com/blabuva/Adams_Functions/blob/master/find_first_jump.m): Finds the index of the first jump in a time series
- [**find_first_match.m**](https://github.com/blabuva/Adams_Functions/blob/master/find_first_match.m): Returns the first matching index and match in an array for candidate(s)
- [**find_initial_slopes.m**](https://github.com/blabuva/Adams_Functions/blob/master/find_initial_slopes.m): Find all initial slopes from a set of current pulse responses
- [**find_in_list.m**](https://github.com/blabuva/Adams_Functions/blob/master/find_in_list.m): Returns all indices of a candidate in a list
- [**find_in_strings.m**](https://github.com/blabuva/Adams_Functions/blob/master/find_in_strings.m): Returns all indices of a particular string (could be represented by substrings) in a list of strings
- [**find_IPSC_peak.m**](https://github.com/blabuva/Adams_Functions/blob/master/find_IPSC_peak.m): Finds time of current peak from a an inhibitory current trace (must be negative current)
- [**find_istart.m**](https://github.com/blabuva/Adams_Functions/blob/master/find_istart.m): Finds time of current application from a series of current vectors
- [**find_istart_old.m**](https://github.com/blabuva/Adams_Functions/blob/master/find_istart_old.m): Finds time of current application from a series of current vectors
- [**find_LTS.m**](https://github.com/blabuva/Adams_Functions/blob/master/find_LTS.m): Find, plot and classify the most likely low-threshold spike (LTS) candidate in a voltage trace
- [**find_LTSs_many_sweeps.m**](https://github.com/blabuva/Adams_Functions/blob/master/find_LTSs_many_sweeps.m): Calls find_LTS.m for many voltage traces
- [**find_nearest_odd.m**](https://github.com/blabuva/Adams_Functions/blob/master/find_nearest_odd.m): Returns the nearest odd integer to real number(s)
- [**find_passive_params.m**](https://github.com/blabuva/Adams_Functions/blob/master/find_passive_params.m): Extract passive parameters from both the rising and falling phase of a current pulse response
- [**find_pulse_endpoints.m**](https://github.com/blabuva/Adams_Functions/blob/master/find_pulse_endpoints.m): Returns the start and end indices of the first pulse from vector(s)
- [**find_pulse_response_endpoints.m**](https://github.com/blabuva/Adams_Functions/blob/master/find_pulse_response_endpoints.m): Returns the start and end indices of the first pulse response (from pulse start to 20 ms after pulse ends by default) from vector(s)
- [**find_window_endpoints.m**](https://github.com/blabuva/Adams_Functions/blob/master/find_window_endpoints.m): Returns the start and end indices of a time window in a time vector
- [**fit_2exp.m**](https://github.com/blabuva/Adams_Functions/blob/master/fit_2exp.m): Fits a double exponential curve to data
- [**fit_and_estimate_passive_params.m**](https://github.com/blabuva/Adams_Functions/blob/master/fit_and_estimate_passive_params.m): Uses a given pulse width and amplitude to fit and estimate passive parameters from a current pulse response
- [**fitdist_initial_slopes.m**](https://github.com/blabuva/Adams_Functions/blob/master/fitdist_initial_slopes.m): Fits initial slope distributions
- [**fit_gaussians_and_refine_threshold.m**](https://github.com/blabuva/Adams_Functions/blob/master/fit_gaussians_and_refine_threshold.m): Fits data to Gaussian mixture models and finds the optimal number of components
- [**fit_IEI.m**](https://github.com/blabuva/Adams_Functions/blob/master/fit_IEI.m): Fit IEI data to curves
- [**fit_kernel.m**](https://github.com/blabuva/Adams_Functions/blob/master/fit_kernel.m): Fits a kernel distribution to a data vector and determine the two primary peaks, the threshold and the void and spacing parameters
- [**fit_logIEI.m**](https://github.com/blabuva/Adams_Functions/blob/master/fit_logIEI.m): Fit log(IEI) logData to curves
- [**fit_pulse_response.m**](https://github.com/blabuva/Adams_Functions/blob/master/fit_pulse_response.m): Estimate short and long pulse response parameters from a double exponential fit to the rising/falling phase of a pulse response
- [**fit_setup_2exp.m**](https://github.com/blabuva/Adams_Functions/blob/master/fit_setup_2exp.m): Constructs a fittype object and set initial conditions and bounds for a double exponential equation form
- [**force_column_cell.m**](https://github.com/blabuva/Adams_Functions/blob/master/force_column_cell.m): Transforms a row cell array or a non-cell array to a column cell array of non-cell vectors
- [**force_column_vector.m**](https://github.com/blabuva/Adams_Functions/blob/master/force_column_vector.m): Transform row vector(s) or array(s) to column vector(s)
- [**force_logical.m**](https://github.com/blabuva/Adams_Functions/blob/master/force_logical.m): Forces any numeric binary array to become a logical array
- [**force_matrix.m**](https://github.com/blabuva/Adams_Functions/blob/master/force_matrix.m): Forces vectors into a non-cell array matrix
- [**force_row_cell.m**](https://github.com/blabuva/Adams_Functions/blob/master/force_row_cell.m): Transforms a column cell array or a non-cell array to a row cell array of non-cell vectors
- [**force_row_vector.m**](https://github.com/blabuva/Adams_Functions/blob/master/force_row_vector.m): Transform column vector(s) or array(s) to row vector(s)
- [**force_string_end.m**](https://github.com/blabuva/Adams_Functions/blob/master/force_string_end.m): Force the string to end with a certain substring
- [**freqfilter.m**](https://github.com/blabuva/Adams_Functions/blob/master/freqfilter.m): Uses a Butterworth filter twice to filter data by a frequency band (each column is a vector of samples)
- [**get_idxEnd.m**](https://github.com/blabuva/Adams_Functions/blob/master/get_idxEnd.m): Get the index of the end of an event
- [**get_loopedparams.m**](https://github.com/blabuva/Adams_Functions/blob/master/get_loopedparams.m): Get parameters that were looped in the simulation from loopedparams.mat
- [**get_var_name.m**](https://github.com/blabuva/Adams_Functions/blob/master/get_var_name.m): Returns a variable's name as a string
- [**has_same_attributes.m**](https://github.com/blabuva/Adams_Functions/blob/master/has_same_attributes.m): Returns all row indices that have the same attributes (column values) combination as a given set of row names
- [**histg.m**](https://github.com/blabuva/Adams_Functions/blob/master/histg.m): HISTG    'Grouped' univariate histogram
- [**histproperties.m**](https://github.com/blabuva/Adams_Functions/blob/master/histproperties.m): Computes the area, edges of the histogram for given data array
- [**identify_channels.m**](https://github.com/blabuva/Adams_Functions/blob/master/identify_channels.m): Assigns voltage, current or conductance to each channel (2nd dim) in abfdata
- [**identify_CI_protocol.m**](https://github.com/blabuva/Adams_Functions/blob/master/identify_CI_protocol.m): Identifies whether a set of current vectors is a current injection protocol, and if so, what the range of the current injection is
- [**identify_eLFP_protocol.m**](https://github.com/blabuva/Adams_Functions/blob/master/identify_eLFP_protocol.m): Identifies whether a .abf file or a set of current vectors follows an eLFP protocol
- [**identify_gabab_protocol.m**](https://github.com/blabuva/Adams_Functions/blob/master/identify_gabab_protocol.m): Identifies whether a .abf file or a set of voltage vectors follows a GABA-B IPSC protocol
