%stratification of j-cells with fewer bins
function individual_j_strats_fig
close all

step = 4;
strat_bounds = [-3 72];

C = get_constants;


ct = C.type.j;
nj = length(ct);

is_in_bounds = C.strat_x >= strat_bounds(1) & C.strat_x <= strat_bounds(2);

x = C.strat_x(is_in_bounds);
x = x(floor(step/2) + (0:4:end-1));
% strats = zeros(sum(is_in_bounds),nj);

for n = 1:nj
    cell_dat = cell_data(ct(n));
    
    my_strat = cell_dat.stratification;
    my_strat = my_strat(is_in_bounds);
    
    my_strat = reshape(my_strat,[step, length(my_strat)/step]);
    my_strat = squeeze(sum(my_strat));
    
    
    
    area_under_curve = 0;
    for k = 1:length(my_strat)-1
        area_under_curve = area_under_curve + step*(my_strat(k)/2+my_strat(k+1)/2);
    end
    my_strat = my_strat/area_under_curve;
    
    
    strats(:,n) = my_strat;
end


leg = cell(nj,1);
for n = 1:nj
    leg{n} = num2str(ct(n));
end

figure;
plot(x, strats, 'LineWidth', 2);
axes_h = gca;
set(axes_h, 'box', 'off')
set(axes_h, 'XTick', 0:20:80)
set(axes_h, 'YTick', [-10 100])
% {'X}, {'YTick', [-10 100]})

legend(leg);



end