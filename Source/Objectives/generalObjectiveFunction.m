function result = generalObjectiveFunction(X)

% Collect global variables
global metric peak_force model_file baseline iteration;
global base_dir v_name d_name v_format d_format;

% Communicate with APO to apply correct torque pattern.

% Every 2s check for the existence of the trial data.
marker_file = ...
    [base_dir filesep v_name sprintf(v_format, iteration) '.trc'];
grf_file = ...
    [base_dir filesep d_name sprintf(d_format, iteration) '.txt'];
while true 
    if exist(grf_file, 'file') && exist(marker_file, 'file')
        pause(2);  % Give an additional 2s just for finishing file writing.
        break;
    else
        pause(2);
    end
end

% Construct the OpenSimTrial.

% Run appropriate OpenSim analyses.

% If required, calculate the relative baseline for this trial. 

% Use OpenSimResults to compute & report metric data. 

end

