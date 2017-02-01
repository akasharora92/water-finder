function [Z_new] = querySim(sim,xpos,ypos,sensor_type,DKnowledge)

% Z_new = [Observation, type of sensor used, xpos,ypos]
Z_new = [0,sensor_type,xpos,ypos];
obs = 0;


if sensor_type == 1
    [cost,t] = sim.move_to(xpos,ypos);
    obs = t;
else
    %get true value of water in the sim world
    pw_gt = sim.sample(xpos,ypos,sensor_type); %TODO: Deal with multiple sensor types.
    
    %add sensor noise to this
    obs = noise_up(pw_gt,sensor_type,DKnowledge);
end

Z_new(1) = obs;
end

function water_class = noise_up(w,sensor_type,DKnowledge)

prob = zeros(size(w));
if sensor_type == DKnowledge.NSS_TYPE
    prob = w*DKnowledge.NSS;
elseif sensor_type == DKnowledge.NIR_TYPE
    prob = w*DKnowledge.NIR;
end

%sampling from the multinomial distribution
u = rand();
sensor_cdf = cumsum(prob);
water_class = find(sensor_cdf > u,1);

end
