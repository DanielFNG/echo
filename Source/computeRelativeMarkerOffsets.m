function relative_adjustment_offsets = computeRelativeMarkerOffsets(settings)

    marker_folder = [settings.base_dir filesep 'right' filesep 'Markers'];
    [n_files, marker_paths] = getFilePaths(marker_folder, '.trc');
    marker_names = settings.relative_adjustment_markers;
    base_name = settings.relative_adjustment_baseline;
    n_markers = length(marker_names);
    offset_x = zeros(n_files, n_markers);
    offset_z = offset_x;
    
    for i = 1:n_files
        marker_data = Data(marker_paths{i});
        base_mean_x = mean(marker_data.getColumn([base_name '_X']));
        base_mean_z = mean(marker_data.getColumn([base_name '_Z']));
        for j = 1:n_markers
            offset_x(i, j) = ...
                mean(marker_data.getColumn([marker_names{j} '_X'])) - base_mean_x;
            offset_z(i, j) = ...
                mean(marker_data.getColumn([marker_names{j} '_Z'])) - base_mean_z;
        end
    end

    relative_adjustment_offsets.x = mean(offset_x);
    relative_adjustment_offsets.z = mean(offset_z);
    
end