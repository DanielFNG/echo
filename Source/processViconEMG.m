function processViconEMG(trial)

    timeout = 30;

    vicon = ViconNexus();
    
    pause(1);
    vicon.OpenTrial(trial, 30);

    vicon.RunPipeline('Export EMG', '', timeout);
    vicon.RunPipeline('Export GRF', '', timeout);
    vicon.SaveTrial(timeout);
    
    moveAndClick(70, 50);
    pause(2);
    moveAndClick(1220, 260);
    moveAndClick(1245, 260);

end