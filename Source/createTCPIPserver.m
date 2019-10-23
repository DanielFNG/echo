function t = createTCPIPserver()

    % Creates an active TCP-IP server for use during ECHO experiments. 
    %
    % This script is designed to be run BEFORE starting the APO control
    % software, and BEFORE running either the online or offline policy
    % controller. 

    % Open a TCP/IP server & wait for connection.
    fprintf(['Opening server connection. Please start the APO control software now. '...
        'You may need to start, stop then restart APO software.\n']);
    t = tcpip('0.0.0.0', 10003, 'NetworkRole', 'server');
    fopen(t);
    fprintf('Connected to APO.\n')
    
end