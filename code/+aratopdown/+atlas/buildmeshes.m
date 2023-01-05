function [X,Y] = buildmeshes(pltData)
    % Build X and Y meshgrids to plot the annotations in stereotax space
    %
    % function [X,Y] = aratopdown.atlas.buildmeshes(pltData)
    %
    % Purpose
    % These meshes are needed to plot the ARA image in stereotax space but they are
    % quite large so (2 MB or so). Therefore in the cached structure in this repo we don't save
    % them and rebuild as needed. This makes the cached structure only about 200kb.
    %
    % Inputs
    % pltData - the output of aratopdown.build_topdown
    %
    % Outputs
    % X and Y -- the X and Y meshgrids.
    %
    % Example
    % pltData - the output of aratopdown.build_topdown;
    % [X,Y] = aratopdown.atlas.buildmeshes(pltData);
    % pltData.X = X;
    % pltData.Y = Y;
    %
    % Now the meshgrids are in the stucture. This operation is carried out internally
    % by the plotting functions if needed.

    S = size(pltData.top_down_annotation.data);
    [X,Y]=meshgrid(1:S(2), 1:S(1));

    X = (X-pltData.bregma(3))/100;
    Y = (pltData.bregma(1)-Y)/100;

