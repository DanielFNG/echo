function cost = computeInstantaneousModelledCost(f_inst)

    min_val = min(f_inst);
    max_val = max(f_inst);
    range = min_val:0.1:max_val;
    L = length(range);
    hold_sq = zeros(1, L);
    hold_val = zeros(1, L);

    start = 1;
    for val = range
        hold_sq(start) = sum((f_inst - val).^2);
        hold_val(start) = val;
        start = start + 1;
    end
    
    [~, ind] = min(hold_sq);
    cost = hold_val(ind);
    
end