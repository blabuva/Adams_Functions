## Adam's functions for sharing across projects

*Note*: This file is automatically generated.  Please do not edit manually.

Last Updated 2019-12-22 by Adam Lu

***

Instructions for syncing this directory to your local machine:
```bash
# Add this directory as a submodule:
git submodule add https://github.com/blabuva/Adams_Functions.git

# Update the submodule in the future
git submodule foreach git pull origin master
```

There are 1 MATLAB scripts in this directory: 
- [**abf2mat.m**](https://github.com/blabuva/Adams_Functions/blob/master/abf2mat.m): Converts .abf files to .mat files with time vector (in ms) included
- [**addpath_custom.m**](https://github.com/blabuva/Adams_Functions/blob/master/addpath_custom.m): Add a folder to MATLAB path only if is not already on the path
- [**adjust_edges.m**](https://github.com/blabuva/Adams_Functions/blob/master/adjust_edges.m): Update histogram bin edges according to specific parameters
- [**adjust_peaks.m**](https://github.com/blabuva/Adams_Functions/blob/master/adjust_peaks.m): Adjusts peak indices and values given approximate peak indices
- [**adjust_window_to_bounds.m**](https://github.com/blabuva/Adams_Functions/blob/master/adjust_window_to_bounds.m): Adjusts a time window so that it is within specific bounds
- [**all_data_files.m**](https://github.com/blabuva/Adams_Functions/blob/master/all_data_files.m): Looks for data files in a dataDirectory according to either dataTypeUser or going through a list of possibleDataTypes
- [**all_dependent_functions.m**](https://github.com/blabuva/Adams_Functions/blob/master/all_dependent_functions.m): Prints all dependent files used by a given MATLAB script/function
- [**all_fields.m**](https://github.com/blabuva/Adams_Functions/blob/master/all_fields.m): Get all field values and names of a structure that satisfies specific conditions in cell arrays
- [**all_file_bases.m**](https://github.com/blabuva/Adams_Functions/blob/master/all_file_bases.m): Returns all the file bases in a given directory (optionally recursive) that matches a prefix, keyword, suffix or extension
- [**all_files.m**](https://github.com/blabuva/Adams_Functions/blob/master/all_files.m): Returns all the files in a given directory (optionally recursive) that matches a prefix, keyword, suffix or extension
- [**all_ordered_pairs.m**](https://github.com/blabuva/Adams_Functions/blob/master/all_ordered_pairs.m): Generates a cell array of all ordered pairs of elements/indices, one from each vector
- [**all_slice_bases.m**](https://github.com/blabuva/Adams_Functions/blob/master/all_slice_bases.m): Retrieves all unique slice bases from the data files in the directory
- [**all_subdirs.m**](https://github.com/blabuva/Adams_Functions/blob/master/all_subdirs.m): Returns all the subdirectories in a given directory
- [**all_swd_sheets.m**](https://github.com/blabuva/Adams_Functions/blob/master/all_swd_sheets.m): Returns all files ending with '_SWDs.csv' under a directory recursively
- [**alternate_elements.m**](https://github.com/blabuva/Adams_Functions/blob/master/alternate_elements.m): Alternate elements between two vectors to create a single vector
- [**analyze_adicht.m**](https://github.com/blabuva/Adams_Functions/blob/master/analyze_adicht.m): Read in the data from the .adicht file
- [**analyzeCI.m**](https://github.com/blabuva/Adams_Functions/blob/master/analyzeCI.m): Analyzes current-injection protocols (legacy, please use parse_current_family.m instead)
- [**analyze_cobalt.m**](https://github.com/blabuva/Adams_Functions/blob/master/analyze_cobalt.m): Clear workspace
- [**annotation_in_plot.m**](https://github.com/blabuva/Adams_Functions/blob/master/annotation_in_plot.m): A wrapper function for the annotation() function that accepts x and y values normalized to the axes
- [**apply_iteratively.m**](https://github.com/blabuva/Adams_Functions/blob/master/apply_iteratively.m): Applies a function iteratively to an array until it becomes a non-cell array result
- [**apply_or_return.m**](https://github.com/blabuva/Adams_Functions/blob/master/apply_or_return.m): Applies a function if a condition is true, or return the original argument(s)
- [**apply_over_cells.m**](https://github.com/blabuva/Adams_Functions/blob/master/apply_over_cells.m): Apply a function that usually takes two equivalent arguments over all contents of a cell array
- [**apply_to_all_subdirs.m**](https://github.com/blabuva/Adams_Functions/blob/master/apply_to_all_subdirs.m): Apply the same function (must have 'Directory' as a parameter) to all subdirectories
- [**apply_to_nonnan_part.m**](https://github.com/blabuva/Adams_Functions/blob/master/apply_to_nonnan_part.m): Applies a function to just the non-NaN part of a vector
- [**archive_dependent_scripts.m**](https://github.com/blabuva/Adams_Functions/blob/master/archive_dependent_scripts.m): Archive all dependent scripts of a function
- [**argfun.m**](https://github.com/blabuva/Adams_Functions/blob/master/argfun.m): Applies a function to each input argument
- [**arglist2struct.m**](https://github.com/blabuva/Adams_Functions/blob/master/arglist2struct.m): Converts an argument list tp a scalar structure
- [**atf2sheet.m**](https://github.com/blabuva/Adams_Functions/blob/master/atf2sheet.m): Converts .atf text file(s) to a spreadsheet file(s) (type specified by the 'SheetType' argument)
- [**atfwrite.m**](https://github.com/blabuva/Adams_Functions/blob/master/atfwrite.m): Writes a data matrix to an Axon Text File formatted text file (.atf)
- [**boltzmann.m**](https://github.com/blabuva/Adams_Functions/blob/master/boltzmann.m): Computes the sigmoidal Boltzmann function
- [**cell2num.m**](https://github.com/blabuva/Adams_Functions/blob/master/cell2num.m): This is the reverse of num2cell, replacing empty entries with NaNs
- [**char2rgb.m**](https://github.com/blabuva/Adams_Functions/blob/master/char2rgb.m): Converts a color string to an rgb value
- [**check_and_collapse_identical_contents.m**](https://github.com/blabuva/Adams_Functions/blob/master/check_and_collapse_identical_contents.m): Checks if a cell array or array has identical contents and collapse it to one copy of the content
- [**check_dir.m**](https://github.com/blabuva/Adams_Functions/blob/master/check_dir.m): Checks if needed directory(ies) exist and creates them if not
- [**check_fullpath.m**](https://github.com/blabuva/Adams_Functions/blob/master/check_fullpath.m): Checks whether a path or paths exists and prints message if not
- [**check_subdir.m**](https://github.com/blabuva/Adams_Functions/blob/master/check_subdir.m): Checks if needed subdirectory(ies) exist in parentDirectory
- [**check_within_bounds.m**](https://github.com/blabuva/Adams_Functions/blob/master/check_within_bounds.m): Checks whether all values are within bounds and print the ones that aren't
- [**choose_random_values.m**](https://github.com/blabuva/Adams_Functions/blob/master/choose_random_values.m): Chooses random values from bounds
- [**choose_stimulation_type.m**](https://github.com/blabuva/Adams_Functions/blob/master/choose_stimulation_type.m): Chooses the stimulation type based on the response type
- [**clc2_analyze.m**](https://github.com/blabuva/Adams_Functions/blob/master/clc2_analyze.m): Analyzes all CLC2 data
- [**clcf.m**](https://github.com/blabuva/Adams_Functions/blob/master/clcf.m): clcf.m
- [**cleanup_parcluster.m**](https://github.com/blabuva/Adams_Functions/blob/master/cleanup_parcluster.m): Cleans up parallel cluster, removing all jobs that contain crash dump files
- [**collapse_identical_vectors.m**](https://github.com/blabuva/Adams_Functions/blob/master/collapse_identical_vectors.m): Collapses identical vectors into a single one
- [**color_index.m**](https://github.com/blabuva/Adams_Functions/blob/master/color_index.m): Find the colormap index for a given value with boundaries set by edges
- [**combine_abf_data.m**](https://github.com/blabuva/Adams_Functions/blob/master/combine_abf_data.m): Combine data from many .abf files and return a structure
- [**combine_data_from_same_slice.m**](https://github.com/blabuva/Adams_Functions/blob/master/combine_data_from_same_slice.m): Combines data across multiple .abf files for each slice in the input folder (or for a particular slice)
- [**combine_looped_params.m**](https://github.com/blabuva/Adams_Functions/blob/master/combine_looped_params.m): TODO
- [**combine_multiunit_data.m**](https://github.com/blabuva/Adams_Functions/blob/master/combine_multiunit_data.m): Combines data across multiple .abf files (using multiunit data defaults) for each slice in the input folder (or for a particular slice)
- [**combine_phase_numbers.m**](https://github.com/blabuva/Adams_Functions/blob/master/combine_phase_numbers.m): Combines (possibly multiple) phase number vectors into a single vector
- [**combine_strings.m**](https://github.com/blabuva/Adams_Functions/blob/master/combine_strings.m): Constructs a final string based on optional substrings and/or Name-Value pairs
- [**combine_swd_sheets.m**](https://github.com/blabuva/Adams_Functions/blob/master/combine_swd_sheets.m): Combines all files ending with '_SWDs.csv' under a directory
- [**combine_sweeps.m**](https://github.com/blabuva/Adams_Functions/blob/master/combine_sweeps.m): Combines sweeps that begin with expLabel in dataDirectory under dataMode
- [**combine_variables_across_tables.m**](https://github.com/blabuva/Adams_Functions/blob/master/combine_variables_across_tables.m): Combines measures across different tables
- [**compile_mod_files.m**](https://github.com/blabuva/Adams_Functions/blob/master/compile_mod_files.m): Compiles NEURON .mod files
- [**compute_all_pulse_responses.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_all_pulse_responses.m): Filter and extract all pulse response and compute features
- [**compute_and_plot_all_responses.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_and_plot_all_responses.m): Computes and plots all pulse responses with stimulus
- [**compute_and_plot_average_response.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_and_plot_average_response.m): Computes and plots an average pulse response with its stimulus
- [**compute_and_plot_concatenated_trace.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_and_plot_concatenated_trace.m): Computes and plots concatenated traces from parsed ABF file results
- [**compute_and_plot_values_online.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_and_plot_values_online.m): Computes and plots a value whenever a new .abf file is completed
- [**compute_autocorrelogram.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_autocorrelogram.m): Computes an autocorrelogram and compute the oscillatory index and period from an array of event times
- [**compute_average_pulse_response.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_average_pulse_response.m): Computes an average pulse response as well as its features
- [**compute_average_trace.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_average_trace.m): Computes the average of traces that are not necessarily the same length
- [**compute_axis_limits.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_axis_limits.m): Computes x or y axis limits from data (works also for a range [min(data), max(data)])
- [**compute_baseline_noise.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_baseline_noise.m): Computes the baseline noise from a set of data vectors, time vectors and baseline windows
- [**compute_bins.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_bins.m): Computes bin counts and edges from a vector
- [**compute_centers_from_edges.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_centers_from_edges.m): Computes bin centers from bin edges
- [**compute_combined_data.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_combined_data.m): Average data according column numbers to average and to a grouping vector
- [**compute_combined_trace.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_combined_trace.m): Computes a combined trace from a set of traces
- [**compute_conductance.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_conductance.m): Computes theoretical conductance curve for the GABA_B IPSC used by dynamic clamp
- [**compute_default_signal2noise.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_default_signal2noise.m): Computes a default signal-to-noise ratio
- [**compute_default_sweep_info.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_default_sweep_info.m): Computes default windows, noise, weights and errors
- [**compute_elcurr.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_elcurr.m): Computes electrode current from conductance & voltage
- [**compute_eRev.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_eRev.m): Computes the reversal potential of a channel that passes monovalent ions using the GHK voltage equation
- [**compute_gpas.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_gpas.m): Computes the passive conductance (gpas, in S/cm^2) from input resistance and surface area
- [**compute_grouped_histcounts.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_grouped_histcounts.m): Computes bin counts and edges from grouped data
- [**compute_IMax_GHK.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_IMax_GHK.m): Computes the maximum current [mA/cm^2] using the GHK current equation
- [**compute_index_boundaries.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_index_boundaries.m): Computes boundary values for indices of different groups, assuming the groups are all consecutive in the array
- [**compute_initial_slopes.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_initial_slopes.m): Computes the average initial slope from a current pulse response
- [**compute_lts_errors.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_lts_errors.m): Computes low-threshold spike errors for single neuron data
- [**compute_maximum_trace.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_maximum_trace.m): Computes the maximum of traces that are not necessarily the same length
- [**compute_minimum_trace.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_minimum_trace.m): Computes the minimum of traces that are not necessarily the same length
- [**compute_oscillation_duration.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_oscillation_duration.m): Computes the oscillation duration in seconds from an interface recording abf file
- [**compute_peak_decay.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_peak_decay.m): Computes the peak decays
- [**compute_peak_halfwidth.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_peak_halfwidth.m): Computes the half widths for peaks
- [**compute_phase_average.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_phase_average.m): Computes the average of values over the last of a phase
- [**compute_population_average.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_population_average.m): Computes the population mean and confidence intervals from a table or time table
- [**compute_psth.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_psth.m): Computes a peri-stimulus time histogram
- [**compute_relative_event_times.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_relative_event_times.m): Computes the relative event times from event times and stimulus times
- [**compute_relative_time.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_relative_time.m): Computes time(s) relative to limits from indice(s)
- [**compute_relative_value.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_relative_value.m): Computes value(s) relative to limits
- [**compute_residuals.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_residuals.m): Computes residual vector(s) from simulated and recorded vectors
- [**compute_rms_error.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_rms_error.m): Computes the root mean squared error(s) given one or two sets of vectors
- [**compute_sampling_interval.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_sampling_interval.m): Computes sampling intervals from time vectors
- [**compute_sampsizepwr.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_sampsizepwr.m): Computes the sample size needed, the statistical power or the alternative hypothesis parameter from either raw data or estimated parameters
- [**compute_sigfig.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_sigfig.m): Returns the number of significant figures from a number (numeric or string)
- [**compute_single_neuron_errors.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_single_neuron_errors.m): Computes the average total error for a single neuron
- [**compute_slope.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_slope.m): Computes the slope given two vectors and two indices
- [**compute_spectrogram.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_spectrogram.m): Computes a spectrogram
- [**compute_spike_density.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_spike_density.m): Computes the spike density from spike times and overlapping bins
- [**compute_spike_frequency.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_spike_frequency.m): Computes the spike frequency for sets of spike indices given a sampling interval
- [**compute_spike_histogram.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_spike_histogram.m): Computes a spike histogram, detect bursts and compute the oscillation duration
- [**compute_stats.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_stats.m): Computes a statistic of vector(s) possibly restricted by endpoint(s)
- [**compute_surface_area.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_surface_area.m): Computes the surface area of a cylindrical compartmental model cell based on lengths and diameters
- [**compute_sweep_errors.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_sweep_errors.m): Computes all errors for single neuron data
- [**compute_time_window.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_time_window.m): Computes time windows from time vectors and given time end points
- [**compute_value_boundaries.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_value_boundaries.m): Computes boundaries for values based on a grouping vector
- [**compute_weighted_average.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_weighted_average.m): Computes a weighted average value (root-mean-square by default)
- [**construct_and_check_abfpath.m**](https://github.com/blabuva/Adams_Functions/blob/master/construct_and_check_abfpath.m): Constructs the full path to a .abf file and checks whether it exists
- [**construct_and_check_fullpath.m**](https://github.com/blabuva/Adams_Functions/blob/master/construct_and_check_fullpath.m): Constructs the full path to the file or directory and checks whether it exists
- [**construct_fullpath.m**](https://github.com/blabuva/Adams_Functions/blob/master/construct_fullpath.m): Constructs full path(s) based on file/directory name(s) and optional directory, suffixes or extension
- [**convert_sheettype.m**](https://github.com/blabuva/Adams_Functions/blob/master/convert_sheettype.m): Converts all spreadsheets to desired sheettype (all .xlsx and .xls files to .csv files by default)
- [**convert_to_char.m**](https://github.com/blabuva/Adams_Functions/blob/master/convert_to_char.m): Converts other data types to character arrays or a cell array of character arrays
- [**convert_to_rank.m**](https://github.com/blabuva/Adams_Functions/blob/master/convert_to_rank.m): Creates a positive integer array from an array showing the ranks of each element
- [**convert_to_samples.m**](https://github.com/blabuva/Adams_Functions/blob/master/convert_to_samples.m): Converts time(s) from a time unit to samples based on a sampling interval in the same time unit
- [**copy_into.m**](https://github.com/blabuva/Adams_Functions/blob/master/copy_into.m): Copies source directories and files into a destination folder
- [**copyvars.m**](https://github.com/blabuva/Adams_Functions/blob/master/copyvars.m): Copies variable 1 of a table to variable 2 of the same table
- [**correct_unbalanced_bridge.m**](https://github.com/blabuva/Adams_Functions/blob/master/correct_unbalanced_bridge.m): Shifts a current pulse response to correct the unbalanced bridge
- [**count_A_each_C.m**](https://github.com/blabuva/Adams_Functions/blob/master/count_A_each_C.m): Counts the number of (A)s in each (C) based on the number of (A)s in each (B) and the number of (B)s in each (C)
- [**count_frames.m**](https://github.com/blabuva/Adams_Functions/blob/master/count_frames.m): Count the number of frames in a video file
- [**count_samples.m**](https://github.com/blabuva/Adams_Functions/blob/master/count_samples.m): Counts the number of samples whether given an array or a cell array
- [**count_vectors.m**](https://github.com/blabuva/Adams_Functions/blob/master/count_vectors.m): Counts the number of vectors whether given an array or a cell array
- [**create_average_time_vector.m**](https://github.com/blabuva/Adams_Functions/blob/master/create_average_time_vector.m): Creates an average time vector from a set of time vectors
- [**create_colormap.m**](https://github.com/blabuva/Adams_Functions/blob/master/create_colormap.m): Returns colorMap based on the number of colors requested
- [**create_default_endpoints.m**](https://github.com/blabuva/Adams_Functions/blob/master/create_default_endpoints.m): Constructs default endpoints from number of samples
- [**create_default_grouping.m**](https://github.com/blabuva/Adams_Functions/blob/master/create_default_grouping.m): Creates numeric grouping vectors and grouping labels from data, counts or original non-numeric grouping vectors
- [**create_empty_frames.m**](https://github.com/blabuva/Adams_Functions/blob/master/create_empty_frames.m): Creates an empty MATLAB movie frames
- [**create_empty_match.m**](https://github.com/blabuva/Adams_Functions/blob/master/create_empty_match.m): Creates an empty array that matches a given array
- [**create_error_for_nargin.m**](https://github.com/blabuva/Adams_Functions/blob/master/create_error_for_nargin.m): Creates an error text for not having enough input arguments
- [**create_grouping_by_vectors.m**](https://github.com/blabuva/Adams_Functions/blob/master/create_grouping_by_vectors.m): Creates a grouping array that matches input by putting all elements of a vector into the same group
- [**create_indices.m**](https://github.com/blabuva/Adams_Functions/blob/master/create_indices.m): Creates indices from endpoints (starting and ending indices)
- [**create_input_file.m**](https://github.com/blabuva/Adams_Functions/blob/master/create_input_file.m): Create an input spreadsheet file from data file names in a directory based on default parameters
- [**create_label_from_sequence.m**](https://github.com/blabuva/Adams_Functions/blob/master/create_label_from_sequence.m): Creates a single label from a sequence of integers with an optional prefix or suffix
- [**create_labels_from_numbers.m**](https://github.com/blabuva/Adams_Functions/blob/master/create_labels_from_numbers.m): Creates a cell array of labels from an array of numbers with an optional prefix or suffix
- [**create_latex_string.m**](https://github.com/blabuva/Adams_Functions/blob/master/create_latex_string.m): Creates a LaTeX string from an equation used for fitting
- [**create_logical_array.m**](https://github.com/blabuva/Adams_Functions/blob/master/create_logical_array.m): Creates a logical array from indices for true and dimensions
- [**create_looped_params.m**](https://github.com/blabuva/Adams_Functions/blob/master/create_looped_params.m): Construct parameters to change for each trial from loopMode, pNames, pIsLog, pMin, pMax, pInc 
- [**create_new_mscript.m**](https://github.com/blabuva/Adams_Functions/blob/master/create_new_mscript.m): Creates a new MATLAB script starting from a function template
- [**create_pleth_EEG_movies.m**](https://github.com/blabuva/Adams_Functions/blob/master/create_pleth_EEG_movies.m): Creates a synced movie from a .wmv file and a Spike2-exported .mat file in the current directory
- [**create_pulse.m**](https://github.com/blabuva/Adams_Functions/blob/master/create_pulse.m): Creates a pulse vector
- [**create_pulse_train_series.m**](https://github.com/blabuva/Adams_Functions/blob/master/create_pulse_train_series.m): Creates a pulse train series (a theta burst stimulation by default)
- [**create_row_labels.m**](https://github.com/blabuva/Adams_Functions/blob/master/create_row_labels.m): Creates row labels for table(s)
- [**create_simulation_output_filenames.m**](https://github.com/blabuva/Adams_Functions/blob/master/create_simulation_output_filenames.m): Creates simulation output file names
- [**create_subdir_copy_files.m**](https://github.com/blabuva/Adams_Functions/blob/master/create_subdir_copy_files.m): Creates subdirectories and copies figure files
- [**create_subplots.m**](https://github.com/blabuva/Adams_Functions/blob/master/create_subplots.m): Creates subplots with maximal fit
- [**create_synced_movie_trace_plot_movie.m**](https://github.com/blabuva/Adams_Functions/blob/master/create_synced_movie_trace_plot_movie.m): Creates a plot movie showing a movie and a trace in synchrony
- [**create_time_stamp.m**](https://github.com/blabuva/Adams_Functions/blob/master/create_time_stamp.m): Creates a time stamp (default format yyyymmddTHHMM)
- [**create_time_vectors.m**](https://github.com/blabuva/Adams_Functions/blob/master/create_time_vectors.m): Creates time vector(s) in seconds from number(s) of samples and other optional arguments
- [**create_waveform_train.m**](https://github.com/blabuva/Adams_Functions/blob/master/create_waveform_train.m): Creates a waveform train from a waveform, a frequency, and a total duration
- [**crosscorr_profile.m**](https://github.com/blabuva/Adams_Functions/blob/master/crosscorr_profile.m): data: each channel is a column
- [**decide_on_colormap.m**](https://github.com/blabuva/Adams_Functions/blob/master/decide_on_colormap.m): Decides on the color map to use
- [**decide_on_filebases.m**](https://github.com/blabuva/Adams_Functions/blob/master/decide_on_filebases.m): Create filebases if empty, or extract file bases
- [**decide_on_parpool.m**](https://github.com/blabuva/Adams_Functions/blob/master/decide_on_parpool.m): Creates or modifies a parallel pool object
- [**decide_on_video_object.m**](https://github.com/blabuva/Adams_Functions/blob/master/decide_on_video_object.m): Decide on the video object given path or object
- [**detect_spikes_current_clamp.m**](https://github.com/blabuva/Adams_Functions/blob/master/detect_spikes_current_clamp.m): Detects spikes from a current clamp recording
- [**detect_spikes_multiunit.m**](https://github.com/blabuva/Adams_Functions/blob/master/detect_spikes_multiunit.m): Detects spikes from a multiunit recording
- [**distribute_balls_into_boxes.m**](https://github.com/blabuva/Adams_Functions/blob/master/distribute_balls_into_boxes.m): Returns the ways and number of ways to distribute identical/discrete balls into identical/discrete boxes
- [**dlmwrite_with_header.m**](https://github.com/blabuva/Adams_Functions/blob/master/dlmwrite_with_header.m): Write a comma-separated value file with given header
- [**draw_arrow.m**](https://github.com/blabuva/Adams_Functions/blob/master/draw_arrow.m): Draw an arrow from p1 to p2
- [**error_unrecognized.m**](https://github.com/blabuva/Adams_Functions/blob/master/error_unrecognized.m): Throws an error for unrecognized string
- [**estimate_passive_params.m**](https://github.com/blabuva/Adams_Functions/blob/master/estimate_passive_params.m): Estimates passive parameters from fitted coefficients, current pulse amplitude and some constants
- [**estimate_resting_potential.m**](https://github.com/blabuva/Adams_Functions/blob/master/estimate_resting_potential.m): Estimates the resting membrane potential (mV) and the input resistance (MOhm) from holding potentials and holding currents
- [**examine_figure_objects.m**](https://github.com/blabuva/Adams_Functions/blob/master/examine_figure_objects.m): Examines figure objects
- [**extract_channel.m**](https://github.com/blabuva/Adams_Functions/blob/master/extract_channel.m): Extracts vectors of a given type from a .abf file
- [**extract_columns.m**](https://github.com/blabuva/Adams_Functions/blob/master/extract_columns.m): Extracts columns from arrays or a cell array of arrays
- [**extract_common_directory.m**](https://github.com/blabuva/Adams_Functions/blob/master/extract_common_directory.m): Extracts the common parent directory of a cell array of file paths
- [**extract_common_prefix.m**](https://github.com/blabuva/Adams_Functions/blob/master/extract_common_prefix.m): Extracts the common prefix of a cell array of strings
- [**extract_common_suffix.m**](https://github.com/blabuva/Adams_Functions/blob/master/extract_common_suffix.m): Extracts the common suffix of a cell array of strings
- [**extract_distinct_fileparts.m**](https://github.com/blabuva/Adams_Functions/blob/master/extract_distinct_fileparts.m): Extracts distinct file parts (removes common parent directory, common prefix and common suffix)
- [**extract_elements.m**](https://github.com/blabuva/Adams_Functions/blob/master/extract_elements.m): Extracts elements from vectors using a certain mode ('first', 'last', 'min', 'max')
- [**extract_fields.m**](https://github.com/blabuva/Adams_Functions/blob/master/extract_fields.m): Extracts field(s) from an array of structures or a cell array of structures
- [**extract_fileparts.m**](https://github.com/blabuva/Adams_Functions/blob/master/extract_fileparts.m): Extracts directories, bases, extensions, distinct parts or the common directory from file paths, treating any path without an extension as a directory
- [**extract_frame_times.m**](https://github.com/blabuva/Adams_Functions/blob/master/extract_frame_times.m): Extracts all the frame start times in a video file
- [**extract_fullpaths.m**](https://github.com/blabuva/Adams_Functions/blob/master/extract_fullpaths.m): Extracts full paths from a files structure array
- [**extract_in_order.m**](https://github.com/blabuva/Adams_Functions/blob/master/extract_in_order.m): Reorganizes a set of vectors by the first vectors, the second vectors, ... and so on
- [**extract_looped_params.m**](https://github.com/blabuva/Adams_Functions/blob/master/extract_looped_params.m): Extracts parameters that were looped in the simulation from loopedparams.mat
- [**extract_substrings.m**](https://github.com/blabuva/Adams_Functions/blob/master/extract_substrings.m): Extracts substring(s) from strings
- [**extract_subvectors.m**](https://github.com/blabuva/Adams_Functions/blob/master/extract_subvectors.m): Extracts subvectors from vectors, given either endpoints, value windows or a certain align mode ('leftAdjust', 'rightAdjust')
- [**extract_vars.m**](https://github.com/blabuva/Adams_Functions/blob/master/extract_vars.m): Extracts variable(s) (column(s)) from a table
- [**files2contents.m**](https://github.com/blabuva/Adams_Functions/blob/master/files2contents.m): Replaces file names with file contents in a cell array of strings
- [**fill_markers.m**](https://github.com/blabuva/Adams_Functions/blob/master/fill_markers.m): Fills markers if any for the current axes
- [**filter_and_extract_pulse_response.m**](https://github.com/blabuva/Adams_Functions/blob/master/filter_and_extract_pulse_response.m): Filters and extracts pulse response(s) from a .abf file
- [**find_closest.m**](https://github.com/blabuva/Adams_Functions/blob/master/find_closest.m): Finds the element(s) in monotonic numeric vector(s) closest to target(s)
- [**find_custom.m**](https://github.com/blabuva/Adams_Functions/blob/master/find_custom.m): Same as find() but takes custom parameter-value pairs
- [**find_first_deviant.m**](https://github.com/blabuva/Adams_Functions/blob/master/find_first_deviant.m): Finds the index of the first deviant from preceding peers in a time series
- [**find_first_jump.m**](https://github.com/blabuva/Adams_Functions/blob/master/find_first_jump.m): Finds the index of the first jump in a time series
- [**find_first_match.m**](https://github.com/blabuva/Adams_Functions/blob/master/find_first_match.m): Returns the first matching index and match in an array for candidate(s)
- [**find_initial_slopes.m**](https://github.com/blabuva/Adams_Functions/blob/master/find_initial_slopes.m): Find all initial slopes from a set of current pulse responses
- [**find_in_list.m**](https://github.com/blabuva/Adams_Functions/blob/master/find_in_list.m): Returns all indices of a candidate in a list
- [**find_in_strings.m**](https://github.com/blabuva/Adams_Functions/blob/master/find_in_strings.m): Returns all indices of a particular string (could be represented by substrings) in a list of strings
- [**find_matching_files.m**](https://github.com/blabuva/Adams_Functions/blob/master/find_matching_files.m): Finds matching files from file strings
- [**find_nearest_multiple.m**](https://github.com/blabuva/Adams_Functions/blob/master/find_nearest_multiple.m): Finds the nearest integer multiple of base to target and the distance to between it and target
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
- [**fit_setup_first_order_response.m**](https://github.com/blabuva/Adams_Functions/blob/master/fit_setup_first_order_response.m): Constructs a fittype object and set initial conditions and bounds for a first order response equation form
- [**force_column_cell.m**](https://github.com/blabuva/Adams_Functions/blob/master/force_column_cell.m): Transforms a row cell array or a non-cell array to a column cell array of non-cell vectors
- [**force_column_vector.m**](https://github.com/blabuva/Adams_Functions/blob/master/force_column_vector.m): Transform row vector(s) or array(s) to column vector(s)
- [**force_logical.m**](https://github.com/blabuva/Adams_Functions/blob/master/force_logical.m): Forces any numeric binary array to become a logical array
- [**force_matrix.m**](https://github.com/blabuva/Adams_Functions/blob/master/force_matrix.m): Forces vectors into a non-cell array matrix
- [**force_row_cell.m**](https://github.com/blabuva/Adams_Functions/blob/master/force_row_cell.m): Transforms a column cell array or a non-cell array to a row cell array of non-cell vectors
- [**force_row_vector.m**](https://github.com/blabuva/Adams_Functions/blob/master/force_row_vector.m): Transform column vector(s) or array(s) to row vector(s)
- [**force_string_end.m**](https://github.com/blabuva/Adams_Functions/blob/master/force_string_end.m): Force the string to end with a certain substring
- [**force_string_start.m**](https://github.com/blabuva/Adams_Functions/blob/master/force_string_start.m): Force the string to start with a certain substring
- [**freqfilter.m**](https://github.com/blabuva/Adams_Functions/blob/master/freqfilter.m): Uses a Butterworth filter twice to filter data by a frequency band (each column is a vector of samples)
- [**get_idxEnd.m**](https://github.com/blabuva/Adams_Functions/blob/master/get_idxEnd.m): Get the index of the end of an event
- [**get_var_name.m**](https://github.com/blabuva/Adams_Functions/blob/master/get_var_name.m): Returns a variable's name as a string
- [**Glucose_analyze.m**](https://github.com/blabuva/Adams_Functions/blob/master/Glucose_analyze.m): Analyzes all Glucose paper oscillations data
- [**has_same_attributes.m**](https://github.com/blabuva/Adams_Functions/blob/master/has_same_attributes.m): Returns all row indices that have the same attributes (column values) combination as a given set of row names
