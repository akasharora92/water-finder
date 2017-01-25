function reward = getReward_1(action_current, robot, bel_space, MapParameters)
%this function takes in the mission state as well as the robot's belief
%returns the reward for taking a particular action

sense_type = action_current(3);

if sense_type == 1
    cost_a = robot.cost_mov;
elseif sense_type == 2  
    cost_a = robot.cost_NIR;
else
    cost_a = robot.cost_NSS;
end

dist_x = action_current(1) - robot.goal_x;
dist_y = action_current(2) - robot.goal_y;

%simple distance to goal vs cost incurred reward
reward = -sqrt(dist_x^2 + dist_y^2)/cost_a;

end

