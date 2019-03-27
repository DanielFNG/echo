function sendControlParameters(server, rise, peak, fall)

    % Handle different sets of inputs (e.g. rise < 10, etc).

    % Construct the array of data to send.
    fwrite(server, [rise, peak, fall]);

end