function plotControlColours(parameters, value_matrix)
% Plot, with a colour map according to a value matrix, the assistance 
% trajectories assosciated with given control parameters.

    figure;
    hold on;
    peak_force = 10.0;
    n_points = 1000;
    
    cmap = colormap;
    min_val = min(min(min(value_matrix(value_matrix ~= 100))));
    max_val = max(max(max(value_matrix(value_matrix ~= 100))));
    color_map = round(1+(size(cmap,1)-1)*...
        (value_matrix - min_val)/(max_val-min_val));
    
    for rise = parameters.rise
        for peak = parameters.peak
            for fall = parameters.fall
                x = parameters.rise == rise;
                y = parameters.peak == peak;
                z = parameters.fall == fall;
                if value_matrix(x, y, z) ~= 100
                    colour = color_map(x, y, z);
                    plot(generateAssistiveProfile(n_points, peak_force, ...
                        rise, peak, fall), ...
                        'LineWidth', 1.0, 'Color', cmap(colour, :));
                end
            end
        end
    end
        
    colorbar;

end