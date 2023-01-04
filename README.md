# Allen Atlas Top-Down Viewer
This package provides code to generate a top-down view of the Allen Atlas from the full Common Coordinate Framework (CCF) and visualize it interactively in coordinates expressed in mm with respect to bregma.
The top-down view can be exported in a concise format that is easy to include in other projects.

## Installation
If installing from a Zip archive or cloned from GiHub, simply add the `code` directory to your path. 
No need to "Add with Subfolders". 

## Example
```matlab

>> t = aratopdown.build_topdown

t = 

  struct with fields:

    dorsal_cortical_areas: [34×1 struct]
               plot_areas: [34×1 uint16]
      top_down_annotation: [1320×1140 uint16]
                        X: [1320×1140 double]
                        Y: [1320×1140 double]
                   bregma: [540 44 570]

>> aratopdown.draw_top_down_ccf(t); %Makes the plot
```

## Requirements for building the top-down view from the Allen CCF volume
To build the top-down view you should download the Allen CCF mouse atlas from http://data.cortexlab.net/allenCCF/. 
You will need the files `structure_tree_safe_2017.csv` and `annotation_volume_10um_by_index.npy`
These files are a re-formatted version of [the original atlas](http://download.alleninstitute.org/informatics-archive/current-release/mouse_ccf/annotation/ccf_2017/), which has been [processed with this script](https://github.com/cortex-lab/allenCCF/blob/master/setup_utils.m))
Place the files somewhere in your MATLAB path. 

Download/clone [npy-matlab](https://github.com/kwikteam/npy-matlab) and add to your MATLAB path. 

### Mouse CCF scaling, rotation, and bregma notes
* The CCF is slightly stretched in the DV axis (because it's based on a single mouse with an unusually tall brain), currently estimated here as 94.3%
* The CCF AP rotation is arbitrary with reference to the skull, and this angle has been estimated as 5 degrees (from https://www.biorxiv.org/content/10.1101/2022.05.09.491042v3). This is implemented here, with the CCF being tilted nose-down by 5 degrees.
* Bregma has been approximated in AP by matching the Paxinos atlas slice at AP=0 to the CCF, the ML position is the midline, and the DV position is a very rough approximation from matching an MRI image (this DV coordinate shouldn't be used - all actual coordinates should be measured from the brain surface for better accuracy)

## Acknowledgements 
This code is derived from work done by Andy Peters in his [neuropixels_trajectory_explorer](https://github.com/petersaj/neuropixels_trajectory_explorer). 
Furthermore, Andy kindly provided a further script that demonstrated how to elegantly get the top-down ARA view in coordinates with respect to bregma.
Neuropixels trajectory explorer with the Allen CCF mouse atlas or Waxholm rat atlas. See changelog below for history of updates.
Some text from this README is taken from the neuropixels_trajectory_explorer README.

## Changelog
* 2023-01-05: Initial work.