function prob_plot = predict_connectivity(dend_type, axon_types, varargin)
    
    C = get_constants;

    p = inputParser;    
    p.addRequired('dend_type', @ischar);
    p.addRequired('axon_types', @iscell);    
    p.addOptional('is_symmetric', true, @islogical);
    p.addOptional('bin_size', C.dist_bin, @isnumeric);
    p.addOptional('size_sim_grid', 1000, @isnumeric);
    
    p.parse(dend_type, axon_types, varargin{:});
    s = p.Results;
    
    
    num_types = length(axon_types);
    
    dend_d = combine_densities(C.type.(dend_type));
    axon_d = cell(num_types,1);
    
    
    for r = 1:size(dend_d,2);
        dend_d(:,r,:) = dend_d(:,r,:) / pi / (r^2 - (r-1)^2) * (2*pi/C.angle_step);
    end

    
    num_steps = ceil(size(dend_d,1)/s.bin_size);

    if s.is_symmetric
        dend_d = sum(dend_d,3);
    else
        [max_val, dom_angle] = max(squeeze(sum(sum(dend_d,2),1)));
        dend_d = dend_d(:,:,[dom_angle+1:end 1:dom_angle]);
%         dend_d = dend_d(:,:,[dom_angle:end 1:dom_angle-1])
    end
        
    
    prob_plot = zeros(num_steps, num_types);
    for k = 1:num_types
        axon_d{k} = combine_densities(C.type.(axon_types{k}));
        axon_d{k} = sum(axon_d{k},3);
        
        for r = 1:size(axon_d{k},2);
            axon_d{k}(:,r) = axon_d{k}(:,r) / pi / (r^2 - (r-1)^2);
        end
        
        for t = 1:num_steps
            x = t*s.bin_size;
            
            if s.is_symmetric
                A = get_annulus_matrix([0 0], [0 x], size(dend_d,2), size(axon_d{k},2));
            else
                A = simulate_annulus_matrix(x, size(dend_d,2), size(axon_d{k},2), s.size_sim_grid);                
            end
        
            for d = 1:min(size(dend_d,1), size(axon_d{k},1));
                prob_at_d = sum(sum(A.*(squeeze(dend_d(d,:))*squeeze(axon_d{k}(d,:)))));
                prob_plot(t,k) = prob_plot(t,k) + prob_at_d;
            end
        end    
    end
    
end

function A = simulate_annulus_matrix(dist, r1, r2, size_sim_grid)
    %A is i by j, j is the annulus of cell 2, i is annulus of cell 1 and angle 
    A = zeros(r1*ceil((2*pi/C.angle_step)),r2);
    
    [x y] = meshgrid((0:1/size_sim_grid:1)*r2*2 - r2, (0:1/size_sim_grid:1)*r2*2 - r2);
    xd = x-dist;
    
    r = ceil(sqrt(x(:).^2+y(:).^2));
    angle = ceil(atan2(xd(:),y(:))/C.angle_step);
    rd = ceil(sqrt(xd(:).^2 + y(:).^2));
    
    is_valid = r<=r2 & rd<=r1;
    
    r = r(is_valid);
    rd = rd(is_valid);
    angle = angle(is_valid);
    
    for k = 1:length(r)
        A(rd+r2*angle, r) = A(rd+r2*angle, r)+1;
    end
end
    
    
    
    

        