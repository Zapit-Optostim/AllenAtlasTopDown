function template_volume = return_template(fName)
    % Load the Allen Atlas template volume
    %
    % function template_volume = return_template(fName)
    %
    % Purpose
    % Return the Allen Atlas template volume.
    %
    % Inputs
    % fName - optional. If not supplied, the .npy file is searched for in the path.
    %
    % Rob Campbell - SWC 2023


    if nargin<1
        fName = which('template_volume_10um.npy');
    end
    
    template_volume = readNPY(fName);
