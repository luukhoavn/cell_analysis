% type = 't1';
c = colormap('Lines');
close all
C = get_constants;

cell_nums = C.type.(type);
num_cells = length(cell_nums);

hulls = cell(num_cells,1);
hull_area = zeros(num_cells,1);

for k = 1:num_cells;
    cell_dat = cell_data(cell_nums(k));
    [hulls{k}(:,1), hulls{k}(:,2)] = poly2cw(cell_dat.hull_2d(:,1), cell_dat.hull_2d(:,2));
    hull_area(k) = poly_area(hulls{k});
    
    t = [];
    if k == 1
        megahull = hulls{k};
    else
        [t(:,1), t(:,2)] = polybool('union', hulls{k}(:,1), hulls{k}(:,2), megahull(:,1), megahull(:,2));
        megahull = t;
    end
end


total_area = poly_area(megahull);

disp([type '- area: ' num2str(mean(hull_area)/10^6) '+-' num2str(std(hull_area)/10^6) ', overlap factor: ' num2str(sum(hull_area)/total_area) ', density: ', num2str(num_cells/total_area*10^12)]);