function f_inst = computeInstantaneousMeasuredCost(tau, dt, cur_m, prev_m)

    f_inst = (tau*cur_m)./dt - ((tau - dt)./dt).*prev_m;

end