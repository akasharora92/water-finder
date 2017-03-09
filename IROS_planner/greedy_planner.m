function [best_action, max_reward] = greedy_planner(robot, BeliefMaps, MapParameters, DKnowledge)
%calculates the best action to take within the robot's action space
best_action = [];
max_reward = 0;

%get action space
action_space = getActionSpace( robot, MapParameters);
reward_action = zeros(size(action_space,1),1);

if isempty(action_space)
   disp('empty') 
   return
end

%iterate through actions to find reward
for i = 1:size(action_space,1)
    reward_action(i) = greedy_reward(action_space(i,:), robot, BeliefMaps, MapParameters, DKnowledge);
end

[max_reward, max_ind] = max(reward_action);

%select best action
best_action = action_space(max_ind,:);

end

