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


    % Now get the annotation from the atlas at that point. The annotation tells us the brain area
    [xx,yy] = meshgrid(1:size(top_down_depth,2), 1:size(top_down_depth,1));
    top_down_annotation = reshape(atlas_volume(sub2ind(size(atlas_volume),yy(:),top_down_depth(:),xx(:))), size(atlas_volume,1), size(atlas_volume,3));



    % The brain areas present in the annotation (so we search only these)
    used_areas = unique(top_down_annotation(:));

    % Restrict to only cortical areas
    structure_id_path = cellfun(@(x) textscan(x(2:end),'%d', 'delimiter',{'/'}),structure_tree.structure_id_path);

    ctx_path = [997,8,567,688,695,315];
    ctx_idx = find(cellfun(@(id) length(id) > length(ctx_path) & ...
        all(id(min(length(id),length(ctx_path))) == ctx_path(min(length(id),length(ctx_path)))),structure_id_path));

    plot_areas = intersect(used_areas,ctx_idx);




    % Get outlines and names of all cortical areas visible from top-down
    dorsal_cortical_areas = struct(...
            'boundaries', cell(size(plot_areas)), ...
            'names',cell(size(plot_areas)), ...
            'area_index', [] ...
            );

    % Tidy names
    for curr_area_idx = 1:length(plot_areas)
        dorsal_cortical_areas(curr_area_idx).boundaries = ...
            bwboundaries(top_down_annotation == plot_areas(curr_area_idx));

        t_name = structure_tree.safe_name(plot_areas(curr_area_idx));

        % (dorsal areas are all "layer 1" - remove that)
        t_name = regexprep(t_name, '..ayer 1', '');

        % Remove the term "area", as it's obvious and makes the names long
        t_name = regexprep(t_name, 'area', '');
        t_name = regexprep(t_name, '  ', ' ');

        % Replace "Primary" with 1' and "Secondary" with 2'
        t_name = regexprep(t_name, 'Primary', '1''');
        t_name = regexprep(t_name, 'Secondary', '2''');

        dorsal_cortical_areas(curr_area_idx).names  = t_name;
        dorsal_cortical_areas(curr_area_idx).area_index = plot_areas(curr_area_idx);
    end
    


    % Convert boundary units to stereotaxic coordinates in mm
    bregma = [540,44,570];

    boundaries_stereotax = cellfun(@(area) cellfun(@(outline) ...
        [bregma(1)-outline(:,1),outline(:,2)-bregma(3)]/100,area,'uni',false), ...
        {dorsal_cortical_areas.boundaries},'uni',false);

    [dorsal_cortical_areas.boundaries_stereotax] = boundaries_stereotax{:};

    % Make meshes to allow the annotation map to be plotted in mm also
    [X,Y]=meshgrid(1:size(top_down_annotation,2),1:size(top_down_annotation,1));

    X = (X-bregma(3))/100;
    Y = (bregma(1)-Y)/100;


    % Make the output structure
    % NOTE! The X and Y matrices are largish so if space is an issue you can delete and re-make as needed using the above three lines
    td_data.dorsal_cortical_areas = dorsal_cortical_areas;
    td_data.plot_areas = plot_areas;
    td_data.top_down_annotation = top_down_annotation;
    td_data.X = X;
    td_data.Y = Y;
    td_data.bregma = bregma;

