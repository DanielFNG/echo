function t = createTCPIPserver()

    % Creates an active TCP-IP server for use during ECHO experiments. 
    %
    % This script is designed to be run BEFORE starting the APO control
    % software, and BEFORE running either the online or offline policy
    % controller. 

    % Open a TCP/IP server & wait for connection.
    disp('Opening server connection. Please start the APO control software now.')
    t = tcpip('0.0.0.0', 10003, 'NetworkRole', 'server');
    t.InputBufferSize = 6; % 2 digits from each control parameter
    fopen(t);
    disp('Connected to APO.')
    
end