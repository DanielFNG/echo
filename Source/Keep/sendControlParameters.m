function sendControlParameters(server, pext, rise, pflex, fall)

    % This doesn't handle inputs of size 3 e.g. 100.

    % Construct the array of data to send.
    array = sprintf('%02i', pext, rise, pflex, fall);
    fwrite(server, array, 'uchar');

end