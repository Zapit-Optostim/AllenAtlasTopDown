function td_data = build_topdown(atlas_volume, structure_tree)
    % Process the atlas volume to generate data for top-down plots
    % 
    % function td_data = aratopdown.build_topdown(atlas_volume, structure_tree)
    %
    % Purpose
    % Generating and processing the data for making the top-down plots is 
    % fairly time consuming so this function pre-computes the data, allowing
    % them to be saved for re-use. In addition, the pre-computed data are 
    % much smaller than the original and can be cached easily for re-loading 
    % with minimal footprint
    %
    % Example function calls
    % tdd = aratopdown.build_topdown;
    %
    % atlas_volume = aratopdown.atlas.return_atlas;
    % tdd = aratopdown.build_topdown(atlas_volume)
    %
    % 
    % Using the code:
    % To plot brain area boundaries and labels:
    % aratopdown.draw_top_down_ccf(tdd)
    %
    % Or to plot the annotations in ARA coords:
    % imagesc(tdd.X(:),tdd.Y(:),tdd.top_down_annotation)
    % grid on
    %
    % Andy Peters - Oxford DPAG
    % Rob Campbell - SWC 2023


    % TODO -- option to return cortex only or not
    % TODO -- clean up so that very small regions are not appearing
    % TODO -- once all is good could add to the zapit repo



    if nargin < 1 || isempty(atlas_volume)
        atlas_volume = aratopdown.atlas.return_atlas;
    end

    if nargin < 2 || isempty(structure_tree)
        structure_tree = aratopdown.atlas.return_structure_tree;
    end




    % Get first brain pixel from top-down
    [~,top_down_depth] = max(atlas_volume>1, [], 2);
    top_down_depth = squeeze(top_down_depth);


    % Now get the annotation from the atlas at that point. The annotation tells us the brain area.
    [xx,yy] = meshgrid(1:size(top_down_depth,2), 1:size(top_down_depth,1));
    top_down_annotation = atlas_volume(sub2ind(size(atlas_volume),yy(:),top_down_depth(:),xx(:)));
    top_down_annotation = reshape(top_down_annotation, size(atlas_volume,[1,3]));



    % The brain areas present in the annotation (so we search only these)
    used_areas = unique(top_down_annotation(:));



    % Restrict to only cortical areas

    % Get the path through the structure tree for each unique brain area in the whole structure
    % tree and return as a list of integers that is a cell in the array structure_id_path.
    structure_id_path = cellfun(@(x) textscan(x(2:end),'%d', 'delimiter',{'/'}),structure_tree.structure_id_path);

    % All areas that share the root described by ctx_path are regions in the cortex
    ctx_path = [997,8,567,688,695,315];

    % Use ctx_path to return the indexes of all areas that are cortical areas

    % It's a cortical area if it contains the above root defined by ctx_path:
    % So it must have a path that is at least as long as that and start with it.
    % (Can't get && to work so that makes the second half of the expression long)
    ctx_idx = find(...
        cellfun( @(id) length(id) > length(ctx_path) & ...
                    all( id(min(length(id),length(ctx_path))) == ctx_path(min(length(id),length(ctx_path))) ), ...
            structure_id_path));


    % Same again for the cerebellum
    cerebellar_path = [997,8,512];
    cerebellar_idx = find(...
        cellfun( @(id) length(id) > length(cerebellar_path) & ...
                    all( id(min(length(id),length(cerebellar_path))) == cerebellar_path(min(length(id),length(cerebellar_path))) ), ...
            structure_id_path));

    % Same again for the midbrain
    mbrain_path = [99,8,343];
    mbrain_idx = find(...
        cellfun( @(id) length(id) > length(mbrain_path) & ...
                    all( id(min(length(id),length(mbrain_path))) == mbrain_path(min(length(id),length(mbrain_path))) ), ...
            structure_id_path));



    % The intersection of the areas visible from the top (used_areas) and all cortical areas (ctx_idx)
    % are the areas we will plot. This works because the atlas volume seems to have been re-coded so
    % the values in the volume match the rows.
    all_idx = unique([ctx_idx;cerebellar_idx;mbrain_idx]); %It should already be unique, but just in case
    plot_areas = intersect(used_areas,all_idx);




    % Get outlines and names of all cortical areas visible from top-down
    dorsal_brain_areas = struct(...
            'boundaries', cell(size(plot_areas)), ...
            'names',cell(size(plot_areas)), ...
            'area_index', [] ...
            );

    % Tidy names
    for curr_area_idx = 1:length(plot_areas)
        t_boundaries = bwboundaries(top_down_annotation == plot_areas(curr_area_idx));

        % Remove any really small areas
        f = find(cellfun(@(x) length(x)>100, t_boundaries));
        if isempty(f)
            continue
        end
        dorsal_brain_areas(curr_area_idx).boundaries = t_boundaries(f);

        t_name = structure_tree.safe_name(plot_areas(curr_area_idx));

        % (dorsal areas are all "layer 1" - remove that)
        t_name = regexprep(t_name, '..ayer 1', '');

        % Remove the term "area", as it's obvious and makes the names long
        t_name = regexprep(t_name, 'area', '');
        t_name = regexprep(t_name, '  ', ' ');

        % Replace "Primary" with 1' and "Secondary" with 2'
        t_name = regexprep(t_name, 'Primary', '1''');
        t_name = regexprep(t_name, 'Secondary', '2''');

        dorsal_brain_areas(curr_area_idx).names  = t_name;
        dorsal_brain_areas(curr_area_idx).area_index = plot_areas(curr_area_idx);
    end
    
    % Remove empty areas
    f = find(cellfun(@(x) isempty(x),{dorsal_brain_areas.names}));
    dorsal_brain_areas(f) = [];


    % Convert cortical boundary units to stereotaxic coordinates in mm
    boundaries_stereotax = boundaries2stereotax({dorsal_brain_areas.boundaries});
    [dorsal_brain_areas.boundaries_stereotax] = boundaries_stereotax{:};

    % Get the boundary of the whole brain from the top
    whole_brain.boundaries = bwboundaries(top_down_annotation > 1,'noholes');
    boundaries_stereotax = boundaries2stereotax({whole_brain.boundaries});
    [whole_brain.boundaries_stereotax] = boundaries_stereotax{:};

    % Generate the X and Y axis scales. These are, for example, the data we would feed to imagesc
    % as the XData and YData input args to get a properly scaled image. They are also used by
    % the areahighlighter function to produce the interactive mouse-over effects.
    bregma = aratopdown.atlas.bregma;
    xData = ((1:size(top_down_annotation,2)) - bregma(3))/100;
    yData = (bregma(1) - (1:size(top_down_annotation,1)))/100;

    % Make the output structure
    % NOTE! The X and Y matrices are largish so if space is an issue you can delete and re-make as needed using the above three lines
    td_data.bregma = bregma;
    td_data.dorsal_brain_areas = dorsal_brain_areas;
    td_data.whole_brain = whole_brain;
    td_data.plot_areas = plot_areas;
    td_data.top_down_annotation.data = top_down_annotation;
    td_data.top_down_annotation.xData = xData;
    td_data.top_down_annotation.yData = yData;



function boundaries_stereotax = boundaries2stereotax(boundaries)
    % Convert bounrdaries to stereotax coords (WRT to bregma)
    bregma = aratopdown.atlas.bregma;
    boundaries_stereotax = cellfun(@(area) cellfun(@(outline) ...
        [bregma(1)-outline(:,1),outline(:,2)-bregma(3)]/100,area,'uni',false), ...
        boundaries,'uni',false);
