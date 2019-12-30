## Adam's functions for sharing across projects

*Note*: This file is automatically generated.  Please do not edit manually.

Last Updated 2019-12-30 by Adam Lu

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
- [**align_subplots.m**](https://github.com/blabuva/Adams_Functions/blob/master/align_subplots.m): Aligns subplots in a figure
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
