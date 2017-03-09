function reward = greedy_reward(action_current, robot, BeliefMaps, MapParameters, DKnowledge)
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%information gain on water

%get current entropy of the water distribution
entropy_init = 0;
for i = 1:MapParameters.xsize
    for j = 1:MapParameters.ysize
        prob_dist = BeliefMaps.Water{i,j};
        entropy = -dot(prob_dist, log(prob_dist));
        entropy_init = entropy_init + entropy;
    end
end

expected_entropy = 0;
%get conditional entropy wrt observations made
%sum over observation space

%get observation probability
if sense_type == 1 %Terrain
    prob_obs = BeliefMaps.Terrain{action_current(1), action_current(2)};
elseif sense_type == 2 %NIR
    prob_W = BeliefMaps.Water{action_current(1), action_current(2)};
    prob_obs = DKnowledge.NIR*prob_W;
else %NSS
    prob_W = BeliefMaps.Water{action_current(1), action_current(2)};
    prob_obs = DKnowledge.NSS*prob_W; 
end

%iterate over each possible observation
for i=1:length(prob_obs)
    current_obs = [i,sense_type,action_current(1), action_current(2)];
    [~, ~,entropy] = updateBelief(robot, BeliefMaps, current_obs, DKnowledge,MapParameters);   
    expected_entropy = expected_entropy + prob_obs(i)*entropy;
end

reward = (entropy_init - expected_entropy);

end




