function info_list = contact_info(cell_numsa, cell_numsb)

num_a = length(cell_numsa);
num_b = length(cell_numsb);

num_cells = num_a + num_b;
num_pairs = num_a * num_b;

info_list = [];


cells = zeros(num_pairs,2);
contact_locs = cell(num_pairs,1);
contact_sizes = cell(num_pairs,1);

info_list.number = zeros(num_cells,1);
info_list.soma_loc = zeros(num_cells,3);



for c = 1:num_a
    c_d = cell_data(cell_numsa(c));
    info_list.number(c) = cell_numsa(c);
    info_list.soma_loc(c,:) = c_d.get_midpoint;
end

for c = 1:num_b
    
    c_d = cell_data(cell_numsb(c));
    info_list.number(c+num_a) = cell_numsb(c);
    info_list.soma_loc(c+num_a,:) = c_d.get_midpoint;
end




for cn = 1:num_a
    c = info_list.number(cn);
    c_d = cell_data(c);
    myconts = double(c_d.contacts);
    
    for dn = 1:num_b
        
        d = info_list.number(dn+num_a);
        
        pair_num = dn + (cn-1)*num_a;
        cells(pair_num,:) = [cn dn];
        
        is_me = myconts(1,:) == d;
        
        contact_locs{pair_num} = myconts(3:5,is_me)';
        contact_sizes{pair_num} = myconts(2,is_me)';
        
        
    end
end



num_conts = 0;
for n = 1:num_pairs
    num_conts = num_conts + length(contact_sizes{n});
end

info_list.cell_ids = zeros(num_conts,2);
info_list.contact_loc = zeros(num_conts,3);
info_list.contact_size = zeros(num_conts,1);

cn = 1;
for n = 1:num_pairs
    ind_range = cn:cn-1+length(contact_sizes{n});
    
    if ~isempty(ind_range)
        info_list.cell_ids(ind_range,:) = ones(length(ind_range),1)*cells(n,:);
        info_list.contact_loc(ind_range,:) = contact_locs{n};
        info_list.contact_size(ind_range) = contact_sizes{n};
        cn = cn + length(contact_sizes{n});
    end
end

end




