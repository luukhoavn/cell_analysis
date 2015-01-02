close all

C = get_constants;

[quartile_data bins full_x full_data] = get_stratification_by_dist(C.type.on_sac, [0 0], 7:4:71, [.25 .5 .75], true, true,.05);

quart_diff = [quartile_data(1,:); quartile_data(3,:)-quartile_data(1,:)];

bin_cutoff = 5;

is_in = bins>=bin_cutoff;
quart_diff = quart_diff(:,is_in);
quartile_data = quartile_data(:,is_in);
bins = bins(is_in);

cmap = [1, .75, 0]'*[1 1 0];
cmap(:,3) = 1;


fig_h = figure; ax_h = gca; hold all;
area_h = area(bins, quart_diff', 'LineStyle', 'none');

for n = 1:2
    set(area_h(n), 'FaceColor', cmap(n,:));
end





% for n = 1:6
%     area_h(n) = area(bins, quart_diff(n,:)','LineStyle', 'none', 'FaceColor', cmap(n,:));
% end


line_h = plot(bins, quartile_data(2,:), 'Color', cmap(end,:));
% colormap(cmap);

legend([area_h(2) line_h], {'25-75th percentiles', 'Median depth'});
ylabel('IPL depth (%)');
xlabel('Distance from soma (% Cell Length)');

title('Stratification of off-SACs');

set(ax_h, 'XLim', [6 71]);
set(ax_h, 'FontSize', 16);
set(ax_h, 'box', 'off');
set(ax_h, 'YDir', 'reverse');
set(fig_h, 'Position', [0 0 1000 1000]);

% saveas(fig_h, 'sac_stratXdist.eps');
