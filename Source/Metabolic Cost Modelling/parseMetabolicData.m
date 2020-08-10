function result = parseMetabolicData(filename)
% This function is written assuming no header data is present as rows.

    % Read in the XML data
    xml_data = xmlread(filename);
    
    % Access all the rows of data, including labels
    rows = xml_data.getElementsByTagName('Row');
    
    % Interpret the labels
    n_labels = (rows.item(0).getChildNodes().getLength() - 1)/2;
    labels = cell(1, n_labels);
    labels{1} = 'Time';
    for i = 2:n_labels
        labels{i} = char(rows.item(0).item(2*i - 1).getTextContent());
    end

    % Interpret the data
    n_rows = rows.getLength() - 1;
    values = zeros(n_rows, n_labels);
    for i = 1:n_rows
        % Interpret time a little differently 
        datestr = char(rows.item(i).item(1).item(0).getTextContent());
        [~, ~, ~, hours, mins, seconds] = datevec(datestr);
        values(i, 1) = 3600*hours + 60*mins + seconds;
        
        % Interpret the remaining values
        for j = 2:n_labels
            values(i, j) = str2double(char(...
                rows.item(i).item(2*j - 1).item(0).getTextContent()));
        end
    end
    
    % Construct the data object
    result = TXTData(values, {}, labels);
end