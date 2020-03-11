function t = connectToViconServer()

    % Creates a active TCP-IP client to be connected to the Vicon PC 
    % server.

    % Create TCP/IP client - prompt user to create server for listening.
    t = tcpip('192.168.10.3', 3091, 'NetworkRole', 'client');
    fopen(t);
    fprintf('Connected to Vicon server.\n');
    
end