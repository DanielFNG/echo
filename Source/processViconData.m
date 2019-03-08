function processViconData(trial)

    timeout = 30;

    vicon = ViconNexus();
    
    vicon.OpenTrial(trial, 30);

    vicon.RunPipeline('Reconstruct And Label', '', timeout);

    vicon.RunPipeline('Fill Small Gaps', '', timeout);
    vicon.RunPipeline('Fill Medium Gaps', '', timeout);
    vicon.RunPipeline('Fill Big Gaps', '', timeout);
    
    vicon.RunPipeline('Filter', '', timeout);

    vicon.RunPipeline('Make TRC', '', timeout);
    vicon.SaveTrial(timeout);
    
    moveAndClick(60, 50);
    pause(2);
    moveAndClick(1220, 260);
    moveAndClick(1245, 260);

end


