types = {'t1', 't2', 't3a', 't3b', 't4'};

x_f = @(x,y)(x(ceil(size(x,1)*.75),1));
% y_f = @(x,y)(x(ceil(size(x,1)*.25),1));

% 
% 
% types = {'t1', 't2'};
% 
% x_f = @(x,y)(x(ceil(size(x,1)*.75))-x(ceil(size(x,1)*.25)));
% y_f = @(x,y)(x(ceil(size(x,1)*.25),1));



% types = {'t3a', 't3b'};

% x_f = @(x,y)(x(ceil(size(x,1)*.1),1));
% x_f = @(x,y)(y.hull_area);
% x_f = @(x,y)(y.V*16.5*16.5*25/10^9);



num_types = length(types);

C = get_constants;

x_data = zeros(1000,1);
figure; hold on

counter = 0;
for k = 1:length(types)
    num_cells = length(C.type.(types{k}));    
    
    for ck = 1:num_cells
        c = C.type.(types{k})(ck);
        cell_dat = cell_data(c);
        p = cell_dat.get_surface;
        d = sort(C.f(p(:,1)));
        d(d<0) = [];

        counter = counter+1;
        x_data(counter) = x_f(d,cell_dat);
        
    end

    
end

x_data = x_data(1:counter);

step = 1.5;

histx = floor(min(x_data)/step)*step:step:ceil(max(x_data)/step+1)*step;
% figure;
close all
hist(x_data, histx);


% plot(histx, histy, 'LineWidth', 2);

prep_figure(gcf,gca)