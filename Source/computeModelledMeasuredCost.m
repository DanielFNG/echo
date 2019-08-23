function measurement = computeModelledMeasuredCost(tau, dt, prev_m, n, cost)

    measurement = zeros(n, 1);
    measurement(1) = prev_m;
    if n > 1
        measurement(2:n) = ((tau - dt)/tau).*measurement(1:n-1) + (dt/tau)*cost;
    end

end