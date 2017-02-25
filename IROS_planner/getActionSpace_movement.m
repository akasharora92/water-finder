function [action_space] = getActionSpace_movement(robot, MapParameters, exp_budget)
%this function takes in the current mission status and returns the robot's
%action space in terms of where it can move

robot_pos = [robot.xpos, robot.ypos];

%action space without constraints. Up, down, left, right
action_space_orig(2,:) = [robot_pos(1), robot_pos(2) + 1, 1];
action_space_orig(3,:) = [robot_pos(1) + 1, robot_pos(2), 1];
action_space_orig(4,:) = [robot_pos(1), robot_pos(2) - 1, 1];
action_space_orig(5,:) = [robot_pos(1) - 1, robot_pos(2), 1];

%initialise action space
action_space = [];

for i=1:size(action_space_orig,1)
    safeAction = 1;
    
    new_rem = exp_budget - robot.cost_mov;
    
    %check if position lies within the map
    robot_pos = action_space_orig(i,1:2);
    if ((robot_pos(1) < 1) || (robot_pos(1) > MapParameters.xsize))
        safeAction = 0;
    elseif ((robot_pos(2) < 1) || (robot_pos(2) > MapParameters.ysize))
        safeAction = 0;
    %check if sensing action is within budget if goal is to be reached
    elseif new_rem < getGoalCost(robot_pos, robot)
        safeAction = 0;
    end
    
    if safeAction == 1
       action_space = [action_space; action_space_orig(i,:)]; 
    end
    
end

end



