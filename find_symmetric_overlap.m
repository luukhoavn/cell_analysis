function expected_overlap = find_symmetric_overlap(cell_numsA, cell_numsB)


    cells = cell(2,1);
    mid_points = cell(2,1);
    cells{1} = cell_numsA;
    cells{2} = cell_numsB;
    
    d = cell(2,1);
    
    for n = 1:2
        num_cells = length(cells{n});
        
        indi_dens = cell(num_cells,1);
        mid_points{n} = zeros(num_cells,2);        
        max_size = [0 0];
        
        for k = 1:num_cells
            indi_dens{k} = get_density_all(cells{n}(k));
            indi_dens{k} = sum(indi_dens{k},3);
            
            midpoint = get_mean_point(cells{n}(k), check_to_use_soma(cells{n}(k)));
            mid_points{n}(k,:) = midpoint(2:3);
            
            max_size = max([max_size; size(indi_dens{k})]);
        end
        
        d{n} = zeros(max_size);
        for k = 1:num_cells
            d{n}(1:size(indi_dens{k},1), 1:size(indi_dens{k},2)) = ...
                d{n}(1:size(indi_dens{k},1), 1:size(indi_dens{k},2)) + indi_dens{k};
        end
    end
    
    if size(d{1},1) > size(d{2},1)
        d{1} = d{1}(1:size(d{2},1),:);
    else
        d{2} = d{2}(1:size(d{1},1),:);
    end
    
    expected_overlap = zeros(length(cells{1}), length(cells{2}));
    
    total_ann_area = (1:max(size(d{1},2), size(d{2},2)));
    total_ann_area = pi*(total_ann_area.^2 - (total_ann_area-1).^2);
    
    for m = 1:length(cells{1})
        for n = 1:length(cells{2})
            
            A = get_annulus_matrix(mid_points{1}(m,:), mid_points{2}(n,:), size(d{1},2), size(d{2},2));
            
            if any(imag(A(:))~=0)
               A = A; 
            end
            
            for k = 1:size(A,1)
                for l = 1:size(A,2)
                    expected_overlap(m,n) = expected_overlap(m,n) + A(k,l)*sum( ...
                        d{1}(:,k)./total_ann_area(k) .* ...
                        d{2}(:,l)./total_ann_area(l));
                end
            end
        end
    end
        
end   
            
    
        