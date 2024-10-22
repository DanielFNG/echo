function [new_model, markers, grfs] = createAdjustedModel(settings)

    % Some parameters
    marker_ext = '.trc';
    grf_ext = '.txt';
    p_grf_ext = '.mot';
    marker_folder = 'Markers';
    grf_folder = 'GRF';
    human_model = 'C:\OpenSim 4.1\Resources\Models\Gait2392_Simbody\gait2392_simbody.osim';
    adjustment = 'Adjustment';

    % Process the raw marker and grf data.
    raw_markers = [settings.base_dir filesep settings.initial_walk marker_ext];
    raw_grf = [settings.base_dir filesep settings.initial_walk grf_ext];
    processMotionData(settings.base_dir, settings.base_dir, raw_markers, ...
        raw_grf, settings.marker_system, settings.grf_system, ...
        settings.x_offset, settings.y_offset, settings.z_offset, ...
        settings.time_delay, settings.speed, settings.inclination, [], ...
        settings.feet, settings.seg_mode, marker_folder, grf_folder);
    
    % Use the processed data to adjust the scaled model.
    markers = [settings.base_dir filesep settings.feet{1} filesep ...
        marker_folder];
    grfs = [settings.base_dir filesep settings.feet{1} filesep grf_folder];
    [~, marker_files] = getFilePaths(markers, marker_ext);
    [~, grf_files] = getFilePaths(grfs, p_grf_ext);
    marker = marker_files{1};
    grf = grf_files{1};
    model_dir = [settings.base_dir filesep settings.model_folder];
    model = [model_dir filesep settings.model_name];
    new_model = [model_dir filesep settings.adjusted_model_name];
    adjustment_folder = [model_dir filesep adjustment];
    adjustModel(model, new_model, human_model, marker, grf, ...
        adjustment_folder);

end