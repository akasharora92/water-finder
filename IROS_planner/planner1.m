function [best_action, max_reward] = planner1(robot, bel_space, MapParameters)
%calculates the best action to take within the robot's action space

%get action space
action_space = getActionSpace( robot, MapParameters);
reward_action = zeros(size(action_space,1),1);

%iterate through actions to find reward
for i = 1:size(action_space,1)
    reward_action(i) = getReward_1(action_space(i,:), robot, bel_space, MapParameters);
end

[max_reward, max_ind] = max(reward_action);

%select best action
best_action = action_space(max_ind,:);

end

