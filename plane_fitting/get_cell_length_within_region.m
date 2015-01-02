function full_len = get_cell_length(cell_name, start_coords, end_coords)

    res = [16.5 16.5 25];

    [coords point_id] = get_coords_for_sac(cell_name);
    num_points = length(point_id);
    
    
    for k = 1:3
        coords(:,k) = coords(:,k)*res(k);
    end
    
    
    id2index = sparse(point_id, ones(num_points,1), 1:num_points, max(point_id),1);
    

    dir_path = ['./' cell_name '/'];
    
    fns = dir(dir_path);
    
    for n = 1:length(fns)
        if length(fns(n).name) > 5 && strcmp(fns(n).name(1:5),'e2198');
            fn = fns(n).name;
            break
        end
    end
    
    fid = fopen([dir_path fn], 'r');
    F = fread(fid, '*char' )';
    fclose(fid);
    
    edge_str = get_strings_starting_with('edge ', F, 80);
    
    full_len = 0;
    for n = 1:length(edge_str)
        relevant_string = edge_str{n};
        quote_loc = find(relevant_string=='"');

        src_edge = str2double(relevant_string(quote_loc(1)+1:quote_loc(2)-1));
        dest_edge = str2double(relevant_string(quote_loc(3)+1:quote_loc(4)-1));
       
        edge_coords = coords(id2index([src_edge; dest_edge]),:);
        
        edge_len = sqrt(sum((edge_coords(1,:)-edge_coords(2,:)).^2));
        
        %doing this the dumb way, much slower than smart way
        x = 0:edge_len;
        y = edge_coords(1,:)'*(x/edge_len) + edge_coords(2,:)'*(1 - x/edge_len);
        
        valid_y = y(1,:) >= start_coords(1) && y(1,:) <= end_coords(1) && ...
            y(2,:) >= start_coords(2) && y(2,:) <= end_coords(2) && ...
            y(3,:) >= start_coords(3) && y(3,:) <= end_coords(3);        
        
        full_len = full_len + sum(valid_y);
    
    end
    
end