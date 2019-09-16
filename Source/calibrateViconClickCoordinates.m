function settings = calibrateViconClickCoordinates(settings)

    input(['Position your mouse at the VERY top of the Vicon screen, ' ...
        'then press enter.']);
    vec = get(groot, 'PointerLocation');
    top = vec(2);

    input(['Position your mouse over the Vicon ''Go Live'' button, ' ...
        'then press enter.']);
    vec = get(groot, 'PointerLocation');
    settings.live_x = vec(1); 
    settings.live_y = top - vec(2);
    
    input(['Position your mouse over the Vicon ''Arm'' button, ' ...
        'then press enter.']);
    vec = get(groot, 'PointerLocation');
    settings.arm_x = vec(1);
    settings.arm_y = top - vec(2);
    
    input(['Position your mouse over the Vicon ''Lock'' button, ' ...
        'then press enter.']);
    vec = get(groot, 'PointerLocation');
    settings.lock_x = vec(1);
    settings.lock_y = top - vec(2);

end