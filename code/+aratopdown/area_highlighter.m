function area_highlighter(atlas_data)
    % Highlight cortical area under mouse in top-down view. Coords in mm from bregma
    %
    % function area_highlighter(data)
    %
    % Purpose
    % Highlight cortical area under mouse in top-down view. Coords in mm from bregma.
    %
    % Inputs
    % data - The output of nte.utils.prep_data_for_top_down
    % from https://github.com/raacampbell/neuropixels_trajectory_explorer
    %
    %
    % Rob Campbell - SWC 2023
    %
    % Based on code kindly provided by Andy Peters (Oxford, DPAG)
    % See fork of Andy's projet here: https://github.com/raacampbell/neuropixels_trajectory_explorer
    
    if nargin<1
        load('atlas_data')
    end

    % Make meshes to allow the annotation map to be plotted in mm
    [X,Y] = aratopdown.atlas.buildmeshes(atlas_data);
    atlas_data.top_down_annotation.X = X;
    atlas_data.top_down_annotation.Y = Y;

    % Plot settings
    brain_color = 'k';
    grid_color = [0.5,0.5,0.5];
    bregma_color = 'b';
    grid_spacing = 0.5; % in mm


    % Make figure window
    fig = figure(10);
    clf(fig)
    fig.Color = 'w';
    fig.ToolBar = 'none';
    fig.MenuBar='none';
    fig.Name = 'Brain Area Highlighter';
    fig.WindowButtonMotionFcn = @pos_reporter;


    % Make axes
    ax = axes;
    ax.Toolbar.Visible = 'off';

    hold(ax,'on')
    axis equal
    grid on
    box on
    
    ax.GridColor = grid_color;

    xlabel('ML [mm from bregma]')
    ylabel('AP [mm from bregma]')

    xlim([-5.5,5.5])
    ylim([-8,4])

    xticks(ax, -5:grid_spacing:5);
    yticks(ax, -8:grid_spacing:5);

    t=title('Top Down ARA');

    % Draw cortical boundaries
    brain_areas = atlas_data.dorsal_brain_areas; % For ease
    cellfun(@(x) cellfun(@(x) plot(x(:,2),x(:,1),'color',brain_color),x,'uni',false), ...
        {brain_areas.boundaries_stereotax},'uni', false);


    % Plot bregma
    p_bregma = plot(0, 0, 'ok', 'MarkerFaceColor', bregma_color, 'MarkerSize', 10);

    % Plot ticks along axes that will move with mouse cursor
    p_ml_tick = plot([0,0],[-8,-7.5],'-r','LineWidth',3);
    p_ap_tick = plot([-5.5,-5],[0,0],'-r','LineWidth',3);
    p_ml_tick.Visible='off';
    p_ap_tick.Visible='off';


    function pos_reporter(~,~)
        % nested callback to report area under mouse cursor
        C = get (ax, 'CurrentPoint');
        X = C(1,1);
        Y = C(1,2);


        % Find brain area index
        [~,indX]=min(abs(atlas_data.top_down_annotation.X(1,:)-X));
        [~,indY]=min(abs(atlas_data.top_down_annotation.Y(:,1)-Y));
        t_ind = atlas_data.top_down_annotation.data(indY,indX);
        f =find([brain_areas.area_index]==t_ind);
        delete(findall(gca,'type','patch'))
        if isempty(f)
            area_name = '';
            fig.Pointer = 'arrow';
            p_ml_tick.Visible='off';
            p_ap_tick.Visible='off';
        else
            area_name = [', ',brain_areas(f).names{1}];
            b = brain_areas(f).boundaries_stereotax;

            if X<0 | length(b)==1
                b = b{1};
            else
                b = b{2};
            end

            p = patch(b(:,2),b(:,1),1,'FaceAlpha',0.15,'FaceColor','r','EdgeColor','r');
            fig.Pointer = 'cross';
            p_ml_tick.XData = [X,X];
            p_ap_tick.YData = [Y,Y];
            p_ml_tick.Visible='on';
            p_ap_tick.Visible='on';
        end

        t.String = sprintf('ML=%0.2f mm, AP=%0.2f mm%s\n', X, Y, area_name);
    end

end
