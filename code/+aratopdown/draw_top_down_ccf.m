function  draw_top_down_ccf(atlas_data)
    % Draw a top-down view of the Allen Atlas in coords from bregma
    %
    % function nte.utils.draw_top_down_ccf(atlas_data)
    %
    % Inputs [Optional]
    % atlas_data - output of aratopdown.prep_data_for_top_down
    %
    % Supplying atlas_data will speed up appearance of the figure.
    %
    % Example function calls:
    % td_data = aratopdown.prep_data_for_top_down
    % aratopdown.draw_top_down_ccf(td_data) %allows for faster repeat calls
    %
    % aratopdown.draw_top_down_ccf
    %
    % Andy Peters - Oxford DPAG
    % Rob Campbell - SWC 2023

    if nargin<1
        load('atlas_data')
    end

    
    %% Draw top-down cortical areas (in mm)

    brain_color = 'k';
    grid_color = [0.5,0.5,0.5];
    bregma_color = 'r';
    grid_spacing = 1; % in mm

    fig = figure(89);
    clf(fig)

    ax = axes;
    hold(ax,'on')
    axis equal
    grid on
    box on
    
    ax.GridColor = grid_color;
    xticks(ax, -5:grid_spacing:5);
    yticks(ax, -5:grid_spacing:5);

    % Draw cortical boundaries

    % Whole brain
    cellfun(@(x) cellfun(@(x) plot(x(:,2),x(:,1), 'color', [0.5,0.5,0.5]),x,'uni',false), ...
        {atlas_data.whole_brain.boundaries_stereotax},'uni', false);

    % Cortical broundaries
    cellfun(@(x) cellfun(@(x) plot(x(:,2),x(:,1),'color',brain_color),x,'uni',false), ...
        {atlas_data.dorsal_brain_areas.boundaries_stereotax},'uni', false);

    % Write area labels (left hemisphere)
    cellfun(@(x,y) text('Position',fliplr(mean(x{1}+0.05,1)),'String',y, 'Color', [0,0,0.5]), ...
        {atlas_data.dorsal_brain_areas.boundaries_stereotax}, ...
        {atlas_data.dorsal_brain_areas.names});

    cellfun(@(x,y) plot(mean(x{1}(:,2)),mean(x{1}(:,1)),'.b', 'MarkerSize', 10), ...
        {atlas_data.dorsal_brain_areas.boundaries_stereotax});

    % Plot bregma
    plot(0, 0, 'or', 'MarkerFaceColor', bregma_color, 'MarkerSize', 10);






