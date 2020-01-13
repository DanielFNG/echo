function stop = saveHistory(results, state)

    global x_at_min_objective_trace

    stop = false;
    
    switch state
        case 'initial' 
        case 'done'
        case 'iteration'
            x_at_min_objective_trace = [x_at_min_objective_trace; ...
                results.XAtMinEstimatedObjective];
    end
    

end