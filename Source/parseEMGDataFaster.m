function emg = parseEMGDataFaster(filename)
% Read raw EMG data from Vicon and produce a TXTData object.

    id = fopen(filename);
    
    % Disregard the header, comprising the first 3 frames.
    for i=1:3
        fgetl(id);
    end
    
    % Get the labels.
    labels = strsplit(fgetl(id), ',');
    n_cols = length(labels);
    
    % Disregard the next line.
    fgetl(id);
    
    % A different way.
    format = '%f,%f,%f,%f';
    values = cell2mat(textscan(id, format));
    
    % Close the file.
    fclose(id);
    
    % Convert values.
    n_rows = size(values, 1);
    
    % Create new labels.
    labels{1} = 'Time';
    labels{2} = 'Frame';
    
    % Re-assign the time/frame values.
    values(:, 2) = 1:n_rows;
    values(:, 1) = 0.001*values(:, 2) - 0.001;
    
    % Create emg data.
    emg = TXTData(values, {}, labels);

end