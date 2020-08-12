function t = createViconServer()

    % Creates an active TCP-IP server for use during ECHO experiments.

    % Open a TCP/IP server & wait for connection.
    fprintf('Trying to connect to Optimisation PC.\n')
    t = tcpip('0.0.0.0', 3091, 'NetworkRole', 'server');
    fopen(t);
    fprintf('Connected to Optimisation PC.\nProceed on Optimisation PC now.\n');

end