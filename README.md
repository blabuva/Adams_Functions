## Adam's functions for sharing across projects

*Note*: This file is automatically generated.  Please do not edit manually.

Last Updated 2019-09-15 by Adam Lu

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
- [**all_data_files.m**](https://github.com/blabuva/Adams_Functions/blob/master/all_data_files.m): Looks for data files in a dataDirectory according to either dataTypeUser or going through a list of possibleDataTypes
- [**all_dependent_functions.m**](https://github.com/blabuva/Adams_Functions/blob/master/all_dependent_functions.m): Prints all dependent files used by a given MATLAB script/function
- [**all_fields.m**](https://github.com/blabuva/Adams_Functions/blob/master/all_fields.m): Get all field values and names of a structure that satisfies specific conditions in cell arrays
- [**all_file_bases.m**](https://github.com/blabuva/Adams_Functions/blob/master/all_file_bases.m): Returns all the file bases in a given directory (optionally recursive) that matches a prefix, keyword, suffix or extension
- [**all_files.m**](https://github.com/blabuva/Adams_Functions/blob/master/all_files.m): Returns all the files in a given directory (optionally recursive) that matches a prefix, keyword, suffix or extension
- [**all_ordered_pairs.m**](https://github.com/blabuva/Adams_Functions/blob/master/all_ordered_pairs.m): Generates a cell array of all ordered pairs of elements/indices, one from each vector
- [**all_slice_bases.m**](https://github.com/blabuva/Adams_Functions/blob/master/all_slice_bases.m): Retrieves all unique slice bases from the .abf files in the directory
