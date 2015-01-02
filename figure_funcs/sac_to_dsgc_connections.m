function sac_to_sac_connections
tic
C = get_constants;
dsgc_nums = C.type.oodsgc;

for c = dsgc_nums

info_struct = contact_info(c, C.type.sure_off_sac);

cell_midsb = info_struct.soma_loc(info_struct.cell_ids(:,2),2:3);

distb = sqrt((cell_midsb(:,1) - info_struct.contact_loc(:,2)).^2 + ...
    (cell_midsb(:,2) - info_struct.contact_loc(:,3)).^2);

angles = atan2(cell_midsb(:,2)-info_struct.contact_loc(:,2), ...
    cell_midsb(:,1)-info_struct.contact_loc(:,3));


x_bounds = [0 3.9*10^5];
y_bounds = [10^4 3.4*10^5];


rads = (1:360) / 180 * pi - pi;
ucircle = [cos(rads') sin(rads')];

deg_count = zeros(360,1);

for k = 1:size(angles,1)
    if mod(k, 10000) == 1
        disp(['working on contact #' num2str(k) ' of ' num2str(size(angles,1))]);
        toc
        tic
    end
    
    circbx = ucircle(:,1)*distb(k) + cell_midsb(k,1);
    circby = ucircle(:,2)*distb(k) + cell_midsb(k,2);
    
    is_inb = double(circbx > x_bounds(1) & circbx < x_bounds(2) & circby > y_bounds(1) & circby < y_bounds(2));
    
    deg_count = deg_count + is_inb;
end

hist_data = hist(angles, rads);
hist_denom = deg_count;
% 
% for x = 1:360
%     hist_denom(theta) = hist_denom(theta) + deg_count(x,y);
% end

% hist_denom = hist_denom+hist_denom(end:-1:1);
% hist_denom = hist_denom(1:length(hist_data));
figure; plot(rads, [hist_data'./hist_denom / max(hist_data'./hist_denom), hist_data'/max(hist_data), hist_denom/max(hist_denom)]); title(num2str(c));
end



