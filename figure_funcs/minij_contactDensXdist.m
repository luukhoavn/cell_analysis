C = get_constants;

% types = {'t1', 't3a'};
types = {'t1', 't2', 'A2'};

% sac_nums = C.type.sure_off_sac;
sac_nums = C.type.minij;
num_sacs = length(sac_nums);
min_thresh = 10000;

bin_size = C.minij_bins(2)-C.minij_bins(1);

figure; main_ax = gca; hold all;
% figure; off_ax = gca; hold all

c = colormap('Lines');

for k = 1:length(types);
    
    cell_nums = C.type.(types{k});
    num_cells = length(cell_nums);
    cell_dist{k} = zeros(num_sacs,num_cells);    
    for s = 1:num_sacs
        s_dat = cell_data(sac_nums(s));
        soma_loc = s_dat.get_midpoint(true);
        for h = 1:num_cells
            h_dat = cell_data(cell_nums(h));
            mid_loc = h_dat.get_midpoint(false);
            
            for d = 2:3
                cell_dist{k}(s,h) = cell_dist{k}(s,h) + ...
                    (mid_loc(d)-soma_loc(d))*s_dat.dist_axis(d-1);
            end
            cell_dist{k}(s,h) = cell_dist{k}(s,h)/1000;
        end
    end
        
    
    [total_contact{k}, total_vox_in_hull{k}] = get_contact_density_whulls(sac_nums, cell_nums);
    
    is_valid = total_vox_in_hull{k} > min_thresh;
    
    total_contact{k} = total_contact{k}(is_valid(:));
    total_vox_in_hull{k} = total_vox_in_hull{k}(is_valid(:));
    cell_dist{k} = cell_dist{k}(is_valid(:));
    
    
    min_bin = 1;
    bin_num = ceil(cell_dist{k}/bin_size);
    density = total_contact{k}./total_vox_in_hull{k};
    
    
    num_bins = length(C.minij_bins);
    
    plot_data = zeros(num_bins,1);
    plot_ste =  zeros(num_bins,1);    
    prob_nonzero =  zeros(num_bins,1);
    plot_normfact =  zeros(num_bins,1);
    
    for n = 1:num_bins
        my_dens = density(bin_num==n);
        plot_data(n) = mean(my_dens);
        plot_ste(n) = std(my_dens)/sqrt(length(my_dens));
        plot_normfact(n) = mean(total_vox_in_hull{k}(bin_num==n));
        prob_nonzero(n) = mean(my_dens>0);
    end
    
%     errorbar(main_ax, bin_size*(1:max(bin_num))-bin_size/2,plot_data,plot_ste, 'LineWidth', 2);
    errorbar(main_ax, bin_size*((1:num_bins)-1/2 + min_bin - 1),plot_data*100,plot_ste*100, 'LineWidth', 2);
%     plot(off_ax, bin_size*(1:max(bin_num))-bin_size/2,plot_normfact,
%     'LineWidth', 2);
    
%     plot(main_ax, bin_size*(1:9)-bin_size/2,plot_data(1:9), 'LineWidth', 2, 'Color', c(k,:)); 
%     scatter(main_ax, bin_num*bin_size - bin_size/2 + k, density, '*', 'MarkerEdgeColor', c(k,:));
    
end



prep_figure(gcf,gca, 'YTick', 0:1:10, 'legend', {'BC1', 'BC2', 'BC3a', 'BC3b', 'BC4'}, ...
    'xlabel', 'Distance from soma (microns)', ...
    'ylabel', 'contact (%)');

set(gca,'YLim', [0 7]);
set(gca,'XLim', [0 C.minij_bins(end)+5]);

% 
% title('Bipolar to off-SAC contact density')
% % legend(types)
% 
% % legend({'type 1', 'type 3a'})
% legend({'type 1', 'type 2', 'type 3a', 'type 3b', 'type 4'})
% ylabel('Contact per SAC voxel')
% xlabel('Distance from soma (microns)')
% set(gcf, 'Position', [0 0 1000 1000]);
% set(gca, 'FontSize', 16);




