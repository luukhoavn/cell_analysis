function clean_point_script(cell_num, graph_rad)

    cell_dat = cell_data(cell_num);
    
    p = cell_dat.get_surface;
    p = round(p(:,[2 3])/graph_rad);
    
    pmin = min(p);
    p(:,1) = p(:,1)-pmin(1)+1;
    p(:,2) = p(:,2)-pmin(2)+1;
    num_points = size(p,1);
    maxp = max(p);
    
    proj_p = zeros(maxp);
    
    for n = 1:num_points
        
        proj_p(p(n,1), p(n,2)) = 1;
    end    
    
    
    out_struct = bwconncomp(proj_p);
    num_comps = length(out_struct.PixelIdxList);
    
    if num_comps>1
        disp([num2str(num_comps-1) ' extra components found in cell ' num2str(cell_num)]);
        num_pix = zeros(num_comps,1);
        for n = 1:num_comps
            num_pix(n) = length(out_struct.PixelIdxList{n});
            disp([num2str(num_pix(n)) ' pixels found in component ' num2str(n)]);
        end
        
        [dummy, max_comp] = max(num_pix);
        
        for n = 1:num_comps
            if n ~= max_comp
                proj_p(out_struct.PixelIdxList{n}) = 2;
            end
        end
            
        figure; imagesc(proj_p);
        
        title(num2str(cell_num))
        
        while 1
            comp_to_kill = input('Remove component? type component number: ');
        
            if isempty(comp_to_kill) || comp_to_kill <= 0
               break 
            end
            p_to_kill = [];
            [p_to_kill(:,1) p_to_kill(:,2)] = ind2sub(maxp, out_struct.PixelIdxList{comp_to_kill});
                        
            if ~exist('inds_to_kill','var')
                inds_to_kill = false(num_points,1);
            end
            
            for n = 1:length(p_to_kill);
                inds_to_kill = inds_to_kill | (p_to_kill(n,1)-p(:,1)).^2 + (p_to_kill(n,2)-p(:,2)).^2 <= 2;
            end    
        end
        
        if exist('inds_to_kill','var')
            
            proj_p = zeros(maxp);
    
            for n = 1:num_points
                if ~inds_to_kill(n)                    
                    proj_p(p(n,1), p(n,2)) = 1;
                end
            end
                
            figure; imagesc(proj_p);
            confirm_str = input('confirm point removal? [y/n]: ', 's');
            if strcmp(confirm_str,'y')
                surface_points = cell_dat.get_surface;

                surface_points = surface_points(~inds_to_kill,:);


                C = get_constants;
                save([C.point_dir 'cell_' num2str(cell_num) '_surface.mat'], 'surface_points');



            end

            
        
        end
        
        
        
    end
    
    close all
end
    