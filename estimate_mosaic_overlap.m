function MOF = estimate_mosaic_overlap(cell_nums)

    C = get_constants;
    num_cells = length(cell_nums);

    total_area = 0;
    for n = 1:num_cells
        
        cell_dat = cell_data(cell_nums(n));
    
        if n == 1
            total_hull = cell_dat.hull_2d;
        else
            new_hull = [];
            [new_hull(:,1) new_hull(:,2)] = polybool('union', total_hull(:,1), total_hull(:,2), cell_dat.hull_2d(:,1), cell_dat.hull_2d(:,2));
            total_hull = new_hull;
        end
        
        total_area = total_area + poly_area(cell_dat.hull_2d);
        
    end
    
    union_area = poly_area(total_hull);
    MOF = total_area/union_area;
end
