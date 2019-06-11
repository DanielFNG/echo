function refiltered = processEMGSignal(wave)

    % Delsys system sampling frequency.
    frequency = 1000;
    
    % Settings as used by MOToNMS toolbox.
    bp_lower_cutoff = 30;  
    bp_upper_cutoff = 300;  
    lp_cutoff = 6;
    order = 2;
    
    % Processing steps.
    filtered = ZeroLagButtFiltfilt((1/frequency), ...
        [bp_lower_cutoff, bp_upper_cutoff], order, 'bp', wave);
    rectified = abs(filtered);
    refiltered = ZeroLagButtFiltfilt(...
        (1/frequency), lp_cutoff, order, 'lp', rectified);
end