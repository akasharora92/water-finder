function cost_goal = getGoalCost(robot_pos, robot)
%This function gets the cost from the current position to the goal through
%a PRM

cost_goal = abs(robot_pos(1) - robot.goal_x) + abs(robot_pos(2) - robot.goal_y);

end

