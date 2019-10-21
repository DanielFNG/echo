function t = createViconServer()

    % Creates an active TCP-IP server for use during ECHO experiments.

    % Open a TCP/IP server & wait for connection.
    disp('Trying to connect...')
    t = tcpip('0.0.0.0', 3091, 'NetworkRole', 'server');
    fopen(t);
    disp('Connected to Optimisation PC.')

end