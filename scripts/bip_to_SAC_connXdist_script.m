function [fig_handles line_handles x y] = bip_to_SAC_connXdist_script(cell_ids, fig_type, fig_handles)
% This script takes each contanct that the cells in cell_ids make onto
% off starburst amacrine cells, finds out how far they are from the soma of
% the appropriate SAC, and plots that distance by the surface area of the
% contact.
%
% the cell_ids variable can either be a vector of cell ids or a string
% 
% if cell_ids is a vector of cell ids, it will plot the stratification of those cells.
% 
% if cell_ids is a string, it will check if the string is 'j', 'off_sac', 't1', 
% 't2', 't3a', 't3b', or 't4'. If it is none of those, there will be an error.
% Otherwise, it will plot the cells that belong to that group. The list of 
% cell types can be seen in get_constants.m, and correspond to sebastian's recent designation



    if ~exist('fig_type', 'var') || isempty(fig_type)
        fig_type = 'line';
    end


    if iscell(cell_ids)
        if ~exist('fig_handles', 'var') || isempty(fig_handles);
            fig_handles = []; 
        end
        
        legend_entries = cell(length(cell_ids),1);
        line_handles = zeros(length(cell_ids),1);
        for k = 1:length(cell_ids)
            for f = 1:length(fig_handles)
                axes_h = get(fig_handles(f),'Children');
                hold(axes_h, 'all');
            end
        
            [fig_handles line_handles(k) x{k} y{k}] = bip_to_SAC_connXdist_script(cell_ids{k}, fig_type, fig_handles);
            
            if isnumeric(cell_ids{k})
                if length(cell_ids{k}) == 1
                    legend_entries{k} = num2str(cell_ids{k});
                else
                    legend_entries{k} = [num2str(cell_ids{k}) ' et al'];
                end
            else
                legend_entries{k} = cell_ids{k};
            end
        end
        legend(line_handles, legend_entries);
    else
        


        C = get_constants;

        conn_data = load(C.conn_loc);
        fns = fieldnames(conn_data);

        sacs = C.type.off_sac;

        if ~isnumeric(cell_ids);
            cell_nums = C.type.(cell_ids);
        else
            cell_nums = cell_ids;
        end

        for k = 1:length(sacs);
            [dist{k}, cont_area{k}] = get_mean_contact_by_distance(sacs(k), cell_nums, conn_data.(fns{1}), 'axis', 'contact');        
            
        end


        cell_dist = cell(length(cell_nums),1);
        cell_cont = cell(length(cell_nums),1);

        all_dist = [];
        all_cont = [];

        for n = 1:length(cell_nums);
            for k = 1:length(sacs);
                cell_dist{n} = [cell_dist{n}; dist{k}(n)];
                cell_cont{n} = [cell_cont{n}; cont_area{k}(n)];
            end

            [cell_dist{n} sort_ind] = sort(cell_dist{n});
            cell_cont{n} = cell_cont{n}(sort_ind);

            all_dist = [all_dist; cell_dist{n}];
            all_cont = [all_cont; cell_cont{n}];

        end
        [all_dist sort_ind] = sort(all_dist);
        all_cont = all_cont(sort_ind);
        all_cont = all_cont;
        

    %     plot(all_dist, all_cont);

        all_dist = all_dist/1000;

%         x = 1:C.dist_bin:ceil(max(all_dist)/C.dist_bin)*C.dist_bin;
        x = 1:C.dist_bin:101;
        y = zeros(size(x));
        ste_y = zeros(size(x));

        for k = 1:length(x)
    
            valid_dist = all_dist>=x(k) & all_dist<x(k)+C.dist_bin;
            if any(valid_dist)
                y(k) = mean(all_cont(valid_dist));
                ste_y(k) = std(all_cont(valid_dist)) / sqrt(sum(valid_dist)-1);                
            end
        end
        x = x + C.dist_bin/2;

        ste_y(isnan(ste_y)) = 0;


        if ~exist('fig_handles', 'var') || isempty(fig_handles);
            fig_handles(1) = figure; 
            axes_h = gca;
        else
            axes_h = get(fig_handles(1),'Children');
        end

        if strcmp(fig_type, 'ribbon')
            line_handles = plot_with_ste_area(x, y, ste_y, fig_handles(1));
        
        elseif strcmp(fig_type, 'bar')
            line_handles = bar(axes_h, x + C.dist_bin/2, y, 'hist');
            hold(axes_h, 'all')
        elseif strcmp(fig_type, 'error')
%             line_handles = plot(axes_h, x,y);                    
            line_handles = errorbar(axes_h, x, y, ste_y);
        else
           line_handles = plot(axes_h, x,y);        
        end
        
        
        title(axes_h, 'Connectivity of Bipolar Cells with Starburst Amacrine Cells')
        ylabel(axes_h, 'Observed connectivity (edges)')
        xlabel(axes_h, 'Distance from soma (microns)');

%         title(axes_h, 'smoothed contact area by distance from soma')
%         ylabel(axes_h, 'mean edges per bin per cell')
%         xlabel(axes_h, 'distance from SAC soma (microns)');


        if length(fig_handles) < 2;
            fig_handles(2) = figure; 
            axes_h = gca;
        else
            axes_h = get(fig_handles(2),'Children');
        end
        scatter(axes_h, all_dist, all_cont, '*');
        title(axes_h, 'contact area by distance from soma scatter')
        ylabel(axes_h, 'contact area (in edges)')
        xlabel(axes_h, 'distance from SAC soma (microns)');

%     
%     figure; hold all
%     
%     for n = 1:length(cell_nums);
%         plot(all_dist{n}, all_cont{n})
%     end
    end
    
end