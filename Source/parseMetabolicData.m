function text_data = parseMetabolicData(filename, frame)
% Read calorimetry data.

    id = fopen(filename);
    
    % Disregard the header, comprising the first 3 frames.
    for i=1:frame
        fgetl(id);
    end
    
    % Get the labels.
    labels = strsplit(fgetl(id), '\t');
    n_cols = length(labels);
    
    % Disregard the next line.
    fgetl(id);
    
    % A different way.
    cell_values = textscan(id, ['%s' repmat('%f', 1, n_cols - 1)]);
    A = cellfun(@convertTime, cell_values{1});
    
    function time_in_seconds = convertTime(str)
        
        split = strsplit(str, ':');
        
        if length(split) ~= 3
            error('Hard coded to more than an hour this time - this is incase this doesn''t hold in future.');
        end
       
        time_in_seconds = str2double(split{1}) * 3600 + str2double(split{2}) * 60 + str2double(split{3});
        
    end
    
    while true
        for i=2:length(A)
            if A(i) < A(i-1)
                A(i:end) = A(i:end) + 60*60;
                break;
            end
        end
        break;
    end
    cell_values{1} = A;
    
    values = cell2mat(cell_values);
    
    % Close the file.
    fclose(id);
    
    % Create new labels.
    labels{1} = 'Time';
    
    % Create emg data.
    text_data = TXTData(values, {}, labels);

end