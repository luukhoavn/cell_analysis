function final_clusters = fix_mosaics(initial_clusters, improvement_threshold, beta)

    C = get_constants;

    num_clusters = length(initial_clusters);
    all_cell_nums = [];
    for k = 1:num_clusters
        all_cell_nums = [all_cell_nums initial_clusters{k}];
    end
    total_cells = length(all_cell_nums);

    perc10 = zeros(total_cells,1);
    cell_volume = zeros(total_cells,1);
    hulls = cell(total_cells,1);
    neighbors = cell(total_cells,1);
    centers = zeros(total_cells,2);    
    radii = zeros(total_cells,1);
    current_membership = zeros(total_cells,1);
    cell_area = zeros(total_cells,1);
    
    
    for c = 1:total_cells;
        cell_dat = cell_data(all_cell_nums(c));
        perc10(c) = find(cumsum(cell_dat.stratification) >= .10, 1, 'first') + C.strat_x(1) - 1;
        cell_volume(c) = cell_dat.V;
        [hulls{c}(:,1), hulls{c}(:,2)] = poly2cw(cell_dat.hull_2d(:,1), cell_dat.hull_2d(:,2));
        cm = cell_dat.get_midpoint(false);
        centers(c,:) = cm(2:3);
        radii(c) = max(sqrt((cm(2)-hulls{c}(:,1)).^2 + (cm(3)-hulls{c}(:,2)).^2));
        cell_area(c) = poly_area(hulls{c});
        
        for k = 1:num_clusters
            if any(all_cell_nums(c)==initial_clusters{k})
                current_membership(c) = k;
            end
        end
        
    end
    
    
    %perc10 then volume
    cluster_centers = [19, .95*10^6; 28 .63*10^6; 28 1.22 * 10^6];    
    
    %normalize
    cluster_centers(:,1) = (cluster_centers(:,1) - min(perc10)) / (max(perc10) - min(perc10));
    cluster_centers(:,2) = (cluster_centers(:,2) - min(cell_volume)) / (max(cell_volume) - min(cell_volume));
    perc10 = (perc10 - min(perc10)) / (max(perc10) - min(perc10));
    cell_volume = (cell_volume - min(cell_volume)) / (max(cell_volume) - min(cell_volume));

%     for k = 1:3;
%         cluster_centers(k,1) = mean(perc10(current_membership==k));
%         cluster_centers(k,2) = mean(cell_volume(current_membership==k));
%     end
    
    
    dist_to_cluster = zeros(total_cells,num_clusters);
    for c = 1:total_cells
        for k = 1:num_clusters
            dist_to_cluster(c,k) = sqrt((cluster_centers(k,1) - perc10(c)).^2 + (cluster_centers(k,2) - cell_volume(c)).^2);
        end
    end
    
    
    
    for c = 1:total_cells-1
        for d = c+1:total_cells
            if sqrt(sum((centers(c,:)-centers(d,:)).^2)) < radii(c) + radii(d)
                neighbors{c} = [neighbors{c} d];                
                neighbors{d} = [neighbors{d} c];
            end
        end
    end
        
    preimprovement = zeros(total_cells,length(initial_clusters));
    improvement = zeros(total_cells,length(initial_clusters));

    ol = zeros(length(initial_clusters),1);
    cov = zeros(length(initial_clusters),1);
    
    while 1
        for c = 1:total_cells
            
            for k = 1:length(initial_clusters)
                k_neighbors = neighbors{c}(current_membership(neighbors{c})==k);
                [ol(k) cov(k)] = get_ol_and_cov(hulls{c}, hulls(k_neighbors));
            
            end
            
            ck = current_membership(c);
            for k = 1:length(initial_clusters)
                preimprovement(c,k) = real(((beta*cov(k) - (1-beta)*ol(k)) - (beta*cov(ck) - (1-beta)*ol(ck)))/cell_area(c));
                improvement(c,k) = preimprovement(c,k) * dist_to_cluster(c,ck)/dist_to_cluster(c,k);
            end
            
        end
        
        [max_vals, best_cs] = max(real(improvement));
        [max_val, best_k] = max(max_vals);
        best_c = best_cs(best_k);
        
        if max_val > improvement_threshold
            disp(['moving ' num2str(all_cell_nums(best_c)) ' from ' num2str(current_membership(best_c)) ' to ' num2str(best_k) ' with improvement factor ' num2str(max_val) ' and preimprovement ' num2str(preimprovement(best_c, best_k))]);
            current_membership(best_c) = best_k;
        else
            break
        end
        
    end
    
    
    final_clusters = cell(length(initial_clusters),1);
    for k = 1:length(initial_clusters)
        final_clusters{k} = all_cell_nums(current_membership==k);
    end
    
    
end
    
function [current_overlap current_coverage] = get_ol_and_cov(my_hull, neighbor_hulls)    
    
    current_overlap = 0;
    non_overlap_hull = my_hull;
    for k = 1:length(neighbor_hulls)
        overlap_hull = [];
        
        a = polybool('intersection', my_hull(:,1), my_hull(:,2),neighbor_hulls{k}(:,1), neighbor_hulls{k}(:,2));
        if ~isempty(a)
            [overlap_hull(:,1), overlap_hull(:,2)] = polybool('intersection', my_hull(:,1), my_hull(:,2),neighbor_hulls{k}(:,1), neighbor_hulls{k}(:,2));
            current_overlap = current_overlap + poly_area(overlap_hull);

            temp_hull = [];
            a = polybool('-', my_hull(:,1), my_hull(:,2),neighbor_hulls{k}(:,1), neighbor_hulls{k}(:,2));
            if ~isempty(a)
                [temp_hull(:,1), temp_hull(:,2)] = polybool('-', my_hull(:,1), my_hull(:,2),neighbor_hulls{k}(:,1), neighbor_hulls{k}(:,2));
            end
            non_overlap_hull = temp_hull;
        end

    end
    current_coverage = poly_area(non_overlap_hull);

end