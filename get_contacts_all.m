function density = get_contacts_all(cell_num, contact_cells, varargin)
    %compute density of cell by depth, angle, and distance.
    %If use_soma == true, uses the soma as the reference center. Otherwise
    %uses arbor mean
    
    p = inputParser;    
    p.addRequired('cell_num', @isnumeric);
    p.addRequired('contact_cells', @isnumeric);
    p.addOptional('use_soma', check_to_use_soma(cell_num), @islogical);
    
    p.parse(cell_num, contact_cells, varargin{:});    
    s = p.Results;
    
    C = get_constants;
    
    mean_point = get_mean_point(s.cell_num, s.use_soma); 
    
    load(C.conn_loc);
    
    sub_conns = double(pick_conns(conns, s.cell_num, s.contact_cells, false));
    
    
    
        num_points = size(sub_conns,2);


        dist = sqrt(sum((sub_conns(5:6,:) - mean_point(2:3)'*ones(1,num_points)).^2,1));
        depth = C.f(sub_conns(4,:));
        angle = atan2(sub_conns(5,:) - mean_point(2), sub_conns(6,:) - mean_point(3));

        depth = round(depth) - C.strat_x(1) + 1;
        dist = ceil(dist/1000);
        angle = ceil((angle+pi)/C.angle_step);


        is_bad = (depth > C.strat_x(end) - C.strat_x(1) + 1) | depth <= 0;

        depth(is_bad) = [];
        dist(is_bad) =  [];
        angle(is_bad) = [];
        
        density = zeros(C.strat_x(end) - C.strat_x(1) + 1, max(dist), ceil(2*pi/C.angle_step));
    
        num_points = length(depth);

        for k = 1:num_points
            density(depth(k), dist(k), angle(k)) = density(depth(k), dist(k), angle(k))+sub_conns(3,k);
        end    
    
    
end
    
