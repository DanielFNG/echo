function sendControlParameters(server, rise, peak, fall)

    % Handle different sets of inputs (e.g. rise < 10, etc).

    % Construct the array of data to send.
    %array = [rise, peak, fall];
    array = [num2str(rise), num2str(peak), num2str(fall)];
    fwrite(server, array, 'uchar');

end