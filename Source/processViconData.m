function processViconData(trial)

    timeout = 30;

    vicon = ViconNexus();
    
    pause(1);
    vicon.OpenTrial(trial, 30);

    vicon.RunPipeline('Reconstruct And Label', '', timeout);

    vicon.RunPipeline('HIL Small Gaps', '', timeout);
    vicon.RunPipeline('HIL Medium Gaps', '', timeout);
    vicon.RunPipeline('Fill Big Gaps', '', timeout);
    
    vicon.RunPipeline('Filter', '', timeout);

    vicon.RunPipeline('Export GRF Full Frames Only', '', timeout);
    vicon.RunPipeline('Export TRC Full Frames Only', '', timeout);
    vicon.SaveTrial(timeout);
    
    moveAndClick(70, 50);
    pause(2);
    moveAndClick(1220, 260);
    moveAndClick(1245, 260);

end


