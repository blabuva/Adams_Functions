## Adam's functions for sharing across projects

*Note*: This file is automatically generated.  Please do not edit manually.

Last Updated 2020-08-19 by Adam Lu

***

Instructions for syncing this directory to your local machine:
```bash
# Add this directory as a submodule:
git submodule add https://github.com/blabuva/Adams_Functions.git

# Update the submodule in the future
git submodule foreach git pull origin master
```

There are 2 MATLAB scripts in this directory: 
- [**abf2mat.m**](https://github.com/blabuva/Adams_Functions/blob/master/abf2mat.m): Converts .abf files to .mat files with time vector (in ms) included
- [**addpath_custom.m**](https://github.com/blabuva/Adams_Functions/blob/master/addpath_custom.m): Add a folder to MATLAB path only if is not already on the path
- [**addvar_as_rowname.m**](https://github.com/blabuva/Adams_Functions/blob/master/addvar_as_rowname.m): Adds a column to a table in the beginning and as row name
- [**addvars_custom.m**](https://github.com/blabuva/Adams_Functions/blob/master/addvars_custom.m): Adds a column to a table, matching rows if necessary 
- [**adjust_edges.m**](https://github.com/blabuva/Adams_Functions/blob/master/adjust_edges.m): Update histogram bin edges according to specific parameters
- [**adjust_peaks.m**](https://github.com/blabuva/Adams_Functions/blob/master/adjust_peaks.m): Adjusts peak indices and values given approximate peak indices
- [**adjust_window_to_bounds.m**](https://github.com/blabuva/Adams_Functions/blob/master/adjust_window_to_bounds.m): Adjusts a time window so that it is within specific bounds
- [**align_subplots.m**](https://github.com/blabuva/Adams_Functions/blob/master/align_subplots.m): Aligns subplots in a figure
- [**align_vectors_by_index.m**](https://github.com/blabuva/Adams_Functions/blob/master/align_vectors_by_index.m): Aligns vectors by an index from each vector
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
- [**append_str_to_varnames.m**](https://github.com/blabuva/Adams_Functions/blob/master/append_str_to_varnames.m): Appends a string to all variable names in a table
- [**apply_iteratively.m**](https://github.com/blabuva/Adams_Functions/blob/master/apply_iteratively.m): Applies a function iteratively to an array until it becomes a non-cell array result
- [**apply_or_return.m**](https://github.com/blabuva/Adams_Functions/blob/master/apply_or_return.m): Applies a function if a condition is true, or return the original argument(s)
- [**apply_over_cells.m**](https://github.com/blabuva/Adams_Functions/blob/master/apply_over_cells.m): Apply a function that usually takes two equivalent arguments over all contents of a cell array
- [**apply_to_all_cells.m**](https://github.com/blabuva/Adams_Functions/blob/master/apply_to_all_cells.m): Applies a function to inputs, separately to each cell if a inputs is a cell array
- [**apply_to_all_subdirs.m**](https://github.com/blabuva/Adams_Functions/blob/master/apply_to_all_subdirs.m): Apply the same function (must have 'Directory' as a parameter) to all subdirectories
- [**apply_to_nonnan_part.m**](https://github.com/blabuva/Adams_Functions/blob/master/apply_to_nonnan_part.m): Applies a function to just the non-NaN part of a vector
- [**archive_dependent_scripts.m**](https://github.com/blabuva/Adams_Functions/blob/master/archive_dependent_scripts.m): Archive all dependent scripts of a function
- [**argfun.m**](https://github.com/blabuva/Adams_Functions/blob/master/argfun.m): Applies a function to each input argument
- [**arglist2struct.m**](https://github.com/blabuva/Adams_Functions/blob/master/arglist2struct.m): Converts an argument list to a scalar structure
- [**array_fun.m**](https://github.com/blabuva/Adams_Functions/blob/master/array_fun.m): Applies cellfun or arrayfun based on the input type, or use parfor if not already in a parallel loop
- [**atf2sheet.m**](https://github.com/blabuva/Adams_Functions/blob/master/atf2sheet.m): Converts .atf text file(s) to a spreadsheet file(s) (type specified by the 'SheetType' argument)
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
- [**combine_param_tables.m**](https://github.com/blabuva/Adams_Functions/blob/master/combine_param_tables.m): Combine parameter tables with a 'Value' column and row names as parameters
- [**combine_phase_numbers.m**](https://github.com/blabuva/Adams_Functions/blob/master/combine_phase_numbers.m): Combines (possibly multiple) phase number vectors into a single vector
- [**combine_strings.m**](https://github.com/blabuva/Adams_Functions/blob/master/combine_strings.m): Constructs a final string based on optional substrings and/or Name-Value pairs
- [**combine_swd_sheets.m**](https://github.com/blabuva/Adams_Functions/blob/master/combine_swd_sheets.m): Combines all files ending with '_SWDs.csv' and with '_piece' in the name under a directory
- [**combine_sweeps.m**](https://github.com/blabuva/Adams_Functions/blob/master/combine_sweeps.m): Combines sweeps that begin with expLabel in dataDirectory under dataMode
- [**combine_variables_across_tables.m**](https://github.com/blabuva/Adams_Functions/blob/master/combine_variables_across_tables.m): Combines measures across different tables
- [**compare_events_pre_post_stim.m**](https://github.com/blabuva/Adams_Functions/blob/master/compare_events_pre_post_stim.m): Binary file /home/Matlab/Adams_Functions/compare_events_pre_post_stim.m matches
- [**compile_mod_files.m**](https://github.com/blabuva/Adams_Functions/blob/master/compile_mod_files.m): Compiles NEURON .mod files
- [**compute_activation_profile.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_activation_profile.m): Computes the percent of activated cells in the network over time
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
- [**compute_default_signal2noise.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_default_signal2noise.m): Computes a default signal-to-noise ratio
- [**compute_default_sweep_info.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_default_sweep_info.m): Computes default windows, noise, weights and errors
- [**compute_derivative_trace.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_derivative_trace.m): Computes the derivative trace dy/dx from x and y, using the midpoints of x as new x
- [**compute_elcurr.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_elcurr.m): Computes electrode current from conductance & voltage
- [**compute_eRev.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_eRev.m): Computes the reversal potential of a channel that passes monovalent ions using the GHK voltage equation
- [**compute_gabab_conductance.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_gabab_conductance.m): Computes a the conductance over time for a GABAB-IPSC
- [**compute_gpas.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_gpas.m): Computes the passive conductance (gpas, in S/cm^2) from input resistance and surface area
- [**compute_grouped_histcounts.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_grouped_histcounts.m): Computes bin counts and edges from grouped data
- [**compute_IMax_GHK.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_IMax_GHK.m): Computes the maximum current [mA/cm^2] using the GHK current equation
- [**compute_index_boundaries.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_index_boundaries.m): Computes boundary values for indices of different groups, assuming the groups are all consecutive in the array
- [**compute_initial_slopes.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_initial_slopes.m): Computes the average initial slope from a current pulse response
- [**compute_lts_errors.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_lts_errors.m): Computes low-threshold spike errors for single neuron data
- [**compute_maximum_numel.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_maximum_numel.m): Given a list of arrays, compute the maximum number of elements
- [**compute_maximum_trace.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_maximum_trace.m): Computes the maximum of traces that are not necessarily the same length
- [**compute_minimum_trace.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_minimum_trace.m): Computes the minimum of traces that are not necessarily the same length
- [**compute_oscillation_duration.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_oscillation_duration.m): Computes the oscillation duration in seconds from an interface recording abf file
- [**compute_pairwise_differences.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_pairwise_differences.m): Computes pairwise differences of vectors
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
- [**compute_running_windows.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_running_windows.m): Computes running windows based on time vectors
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
- [**compute_surface_area.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_surface_area.m): Computes the surface area(s) (cm^2) of cylindrical compartmental model cell(s) based on lengths (um) and diameters (um)
- [**compute_sweep_errors.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_sweep_errors.m): Computes all errors for single neuron data
- [**compute_time_constant.m**](https://github.com/blabuva/Adams_Functions/blob/master/compute_time_constant.m): Computes the time constant of vector(s) with a single peak
