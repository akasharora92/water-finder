function [best_action] = random_planner(robot, MapParameters)
%calculates the best action to take within the robot's action space

best_action = [];

%get action space
action_space = getActionSpace( robot, MapParameters);


if isempty(action_space)
   disp('empty') 
   return
end

%select random action
action_idx = randi([1,size(action_space,1)],1);
best_action = action_space(action_idx,:);

end



