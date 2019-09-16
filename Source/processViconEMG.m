function processViconEMG(trial, settings)

    timeout = 30;

    vicon = ViconNexus();
    
    pause(1);
    vicon.OpenTrial(trial, 30);

    vicon.RunPipeline('Export EMG', '', timeout);
    vicon.RunPipeline('Export GRF', '', timeout);
    vicon.SaveTrial(timeout);
    
    moveAndClick(settings.live_x, settings.live_y);
    pause(2);
    moveAndClick(settings.arm_x, settings.arm_y);
    moveAndClick(settings.lock_x, settings.lock_y);

end