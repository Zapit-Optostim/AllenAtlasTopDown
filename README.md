# Allen Atlas Top-Down Viewer
[![View AllenAtlasTopDown on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://uk.mathworks.com/matlabcentral/fileexchange/122877-allenatlastopdown)

This package provides code to generate a top-down view of the [Allen Atlas from the full Common Coordinate Framework](https://mouse.brain-map.org/static/atlas) (CCF) and visualize it interactively in stereotaxic coordinates expressed in mm with respect to bregma.
There are two functions for plotting the view as well as all code needed to generate the plots from scratch using the CCF.

<img src="./images/area_highlighter.jpg">

## Installation
The easiest way to to install and stay up to date is directly via MATLAB: Go to "APPS" in the ribbon then select "Get More Apps" and search for AllenAtlasTopDown to install.
Alternatively you can download the Zip archive or clone the repo then add the `code` directory to your MATLAB path.
No need to "Add with Subfolders". 
This package requires the [Image Processing Toolbox](https://www.mathworks.com/help/images/index.html).

## Usage
To launch an interactive top-down viewer:
```matlab
aratopdown.area_highlighter
```

To show a static image with labels:
```matlab
aratopdown.draw_top_down_ccf
```

## To modify details of the plotted areas
The area borders are generated from the full CCF volume.
Following installation of the requirements described below, the borders can be re-generated as follows.
```matlab

>> t = aratopdown.atlas.build_topdown

t = 

  struct with fields:

                 bregma: [540 44 570]
     dorsal_brain_areas: [43×1 struct]
            whole_brain: [1×1 struct]
             plot_areas: [50×1 uint16]
    top_down_annotation: [1×1 struct]

% Then plotted as above
>> aratopdown.draw_top_down_ccf(t);
>> aratopdown.area_highlighter(t)
```

## Requirements for building the top-down view from the Allen CCF volume
These requirements are for re-building the area borders and are not needed for running the two
visualisation functions.
To build the top-down view you should download the Allen CCF mouse atlas from http://data.cortexlab.net/allenCCF/. 
You will need the files `structure_tree_safe_2017.csv` and `annotation_volume_10um_by_index.npy`
These files are a re-formatted version of [the original atlas](http://download.alleninstitute.org/informatics-archive/current-release/mouse_ccf/annotation/ccf_2017/), which has been [processed with this script](https://github.com/cortex-lab/allenCCF/blob/master/setup_utils.m))
Place the files somewhere in your MATLAB path. 

Download/clone [npy-matlab](https://github.com/kwikteam/npy-matlab) and add to your MATLAB path. 

### Mouse CCF scaling, rotation, and bregma notes
Bregma has been approximated in AP by matching the Paxinos atlas slice at AP=0 to the CCF, the ML position is the midline, and the DV position is a very rough approximation from matching an MRI image (this DV coordinate shouldn't be used - all actual coordinates should be measured from the brain surface for better accuracy)

The CCF is slightly stretched in the DV axis (because it's based on a single mouse with an unusually tall brain), currently estimated here as 94.3%.
This stretch has not been taken into account in this package.

The CCF AP rotation is arbitrary with reference to the skull.
It is estimated that this angle is 5 degrees nose-down (from https://www.biorxiv.org/content/10.1101/2022.05.09.491042v3).
Since this will have negligable impact on the top-down view, the brain is not un-tilted.

## Acknowledgements 
This code is derived from work done by Andy Peters in his [neuropixels_trajectory_explorer](https://github.com/petersaj/neuropixels_trajectory_explorer). 
Furthermore, Andy kindly provided an additional script that demonstrated how to elegantly get the top-down ARA view in coordinates with respect to bregma.
Some text from this README is taken from the neuropixels_trajectory_explorer README.

## More info
[https://community.brain-map.org/t/how-to-transform-ccf-x-y-z-coordinates-into-stereotactic-coordinates/1858](https://community.brain-map.org/t/how-to-transform-ccf-x-y-z-coordinates-into-stereotactic-coordinates/1858)

## Changelog
* 2023-01-05: Initial commit. Minor bugfixes and improvements.
