function pass = FESParameterConstraints(X, settings)

    rise_time = (X.rise*settings.time_multiplier)/1000;
    ext_time = (X.ext*settings.time_multiplier)/1000;
    fall_time = (X.fall*settings.time_multiplier)/1000;
    
    pass = (rise_time < settings.swing_time) & ...
        ((ext_time + fall_time) < settings.stance_time); 

end

