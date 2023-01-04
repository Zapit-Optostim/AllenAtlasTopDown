function structureTreeTable = return_structure_tree(fName)
    % Load and format structure tree and return as a table
    %
    % function structureTreeTable = return_structure_tree(fName)
    %
    % Purpose
    % Return the Allen structure tree as a table. 
    %
    % Inputs
    % fName - optional. If not supplied, the .csv file is searched for in the path.
    %
    % Note. This file is a modified version of one originally obtained from 
    % cortex-lab/allenCCF/Browsing Functions
    %
    % Rob Campbell - SWC 2023



    if nargin<1
        fName = which('structure_tree_safe_2017.csv');

    end

    fid = fopen(fName, 'r');


    titles = textscan(fid, repmat('%s', 1, 21), 1, 'delimiter', ',');
    titles = cellfun(@(x)x{1}, titles, 'uni', false);
        
    data = textscan(fid, ['%d%d%s%s'... % 'id'    'atlas_id'    'name'    'acronym'
                          '%s%d%d%d'... % 'st_level'    'ontology_id'    'hemisphere_id'    'weight'
                          '%d%d%d%d'... % 'parent_structure_id'    'depth'    'graph_id'     'graph_order'
                          '%s%s%d%s'... % 'structure_id_path'    'color_hex_triplet' neuro_name_structure_id neuro_name_structure_id_path
                          '%s%d%d%d'... % 'failed'    'sphinx_id' structure_name_facet failed_facet
                          '%s'], 'delimiter', ','); % safe_name
    
    titles = ['index' titles];
    data = [[0:numel(data{1})-1]' data];    

    fclose(fid);

    structureTreeTable = table(data{:}, 'VariableNames', titles);

end
