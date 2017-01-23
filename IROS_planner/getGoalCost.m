function cost_goal = getGoalCost(robot_pos, MapParameters)
%This function gets the cost from the current position to the goal through
%a PRM

cost_goal = abs(robot_pos(1) - MapParameters.goal_x) + abs(robot_pos(2) - MapParameters.goal_y);

end

