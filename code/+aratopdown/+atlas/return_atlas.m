function atlas_volume = return_atlas(fName)
    % Load the Allen Atlas CCF volume
    %
    % function atlas_volume = return_atlas(fName)
    %
    % Purpose
    % Return the Allen Atlas CCF volume.
    %
    % Inputs
    % fName - optional. If not supplied, the .npy file is searched for in the path.
    %
    % Rob Campbell - SWC 2023


    if nargin<1
        fName = which('annotation_volume_10um_by_index.npy');
    end
    
    atlas_volume = readNPY(fName); 
