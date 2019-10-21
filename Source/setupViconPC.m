function settings = setupViconPC()

    % Calibrate the Vicon click information. 
    settings = calibrateViconClickCoordinates();
    
    % Create the APO server.
    settings.apo_server = createTCPIserver();
    
    % Create the Vicon server. 
    settings.vicon_server = createViconServer();

end