C = get_constants;

for c = C.type.sure_off_sac
    
    cell_dat = cell_data(c);
    mp = cell_dat.get_midpoint(true);
    
    figure; title(num2str(c));
    
    plot_cells(c,1,.01,[0 0 0 ]);
    hold on
    scatter(mp(2),mp(3),'*r');
    
    a=1;
    close all
end