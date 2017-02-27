%This function creates a sequence of actions using a random policy until
%the budget is exhausted

%INPUTS: Current robot position, its children, budget
%OUTPUTS: Sequence of states and actions taken while adherring to budget

function [state_sequence] = rollout_Informed(current_node, MapParameters, robot, BeliefMaps)

%budget = budget left in the mission from the root node

robot.xpos = current_node.x_pos;
robot.ypos = current_node.y_pos;
robot.rem_budget = current_node.budget;

%get maximum number of times the NSS can be used
min_budget = getGoalCost([robot.xpos, robot.ypos], robot);
max_NSS = floor((robot.rem_budget - min_budget)/robot.cost_NSS);

%sample a number from 0 to max number
NSS_count = randi([0,max_NSS],1);

%calculate budget available for exploration
exp_budget = robot.rem_budget - NSS_count*robot.cost_NSS;

path_size = exp_budget + NSS_count;
state_sequence = zeros(path_size, 3);

%get occupancy map- convert to integer for speed
occ_map = int8(robot.visibility);
search_radius = 1;

%state_sequence = [];

%plan robot path which meets goal and exploratory budget constraints

loop_counter = 1;
while true
    %get reachable actions if budget constraints & goal position constraint
    %is to be followed
    [action_space] = getActionSpace_movement(robot, MapParameters, exp_budget);
    
    if isempty(action_space)
        %we can't take any more actions under the budget and goal position constraints
        %exit
        break;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%
    %biased weights
    weights = zeros(size(action_space, 1),1);
    %get action weights
    for i = 1:size(action_space,1)
        %get occupancy grid in robot's neighbourhood
        occ_map_xrange = action_space(i,1) - (search_radius):action_space(i,1) + (search_radius);
        occ_map_xrange(occ_map_xrange < 1) = [];
        occ_map_xrange(occ_map_xrange > MapParameters.xsize) = [];
        
        occ_map_yrange = action_space(i,2) - (search_radius):action_space(i,2) + (search_radius);
        occ_map_yrange(occ_map_yrange < 1) = [];
        occ_map_yrange(occ_map_yrange > MapParameters.ysize) = [];
        
        %drive robot away from areas it has already seen
        occ_neighbourhood = occ_map(occ_map_xrange, occ_map_yrange);
        weights(i) = numel(occ_neighbourhood(occ_neighbourhood < 1)) + 0.1*numel(occ_neighbourhood(occ_neighbourhood == 1)); 
        weights(i) = weights(i) - 2*occ_map(action_space(i,1), action_space(i,2));     
        
        %prevent zero or negative weights
        if weights(i) <= 0 
            weights(i) = 0.1;
        end
        
    end
    
    %normalise weights to get probabilities
    weights = weights./sum(weights);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    %uniform weights
    %weights = [1/3 1/3 1/3];
    
    %select an action by sampling from the weights distribution
    chosen_action_idx = find(mnrnd(1,weights) == 1); 
    new_child = action_space(chosen_action_idx, :);
    
    
    
    %for overall cost purposes
    %sequence = [sequence, new_child(3)];
    
    %add node to sequence
    state_sequence(loop_counter,:) = new_child;
    
    %update values for next loop iteration
    exp_budget = exp_budget - 1;
    robot.xpos = new_child(1);
    robot.ypos = new_child(2);
    occ_map(robot.xpos, robot.ypos) = int8(1);
    
    loop_counter = loop_counter + 1;
end


state_sequence(state_sequence(:,1) == 0,:) = [];

%state_sequence = [state_sequence; robotPath];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%sample a map
seedNum = 10;

x_ind = randi([1,MapParameters.xsize], [seedNum,1]);
y_ind = randi([1,MapParameters.ysize], [seedNum,1]);

seed_index = [x_ind, y_ind];

%assign terrain label to these seeds
seed_labels = ones(seedNum,1);
for i=1:seedNum
   p_dist = BeliefMaps.Terrain{seed_index(i,1), seed_index(i,2)};
   seed_labels(i) = find(mnrnd(1, p_dist) == 1);
end

[terrain_map] = createVoronoi(seed_index, seed_labels, MapParameters);
%figure; imagesc(terrain_map);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%deduce what terrain types were seen on the path
%tic
%terrain_counts = zeros(3,1);
%for i = 1:size(robotPath,1)
%    count = zeros(3,1);
%    count(terrain_map(robotPath(i,1), robotPath(i,2))) = 1;
%    terrain_counts = terrain_counts + count;
%end
%toc

terrain_counts = terrain_map(sub2ind(size(terrain_map), state_sequence(:,1), state_sequence(:,2)));
terrain_counts_comp = zeros(3,1);
terrain_counts_comp(1) = numel(terrain_counts(terrain_counts == 1));
terrain_counts_comp(2) = numel(terrain_counts(terrain_counts == 2));
terrain_counts_comp(3) = numel(terrain_counts(terrain_counts == 3));


%get water correlation entropy
theta_dist = BeliefMaps.theta;
theta_ent = zeros(size(theta_dist,1),1);

for i=1:size(theta_dist,1)
    theta_ent(i) = -theta_dist(i,:)*log(theta_dist(i,:)');
end

%get terrain values- how valuable is it to take NSS reading in a terrain
t_values = terrain_counts_comp.*theta_ent;

%how many times NSS has been used already in simulation
nss_assignments = zeros(3,1);

%plan NSS locations
for i=1:NSS_count
    %get weights of each terrain
    t_weights = t_values.*exp(-nss_assignments./NSS_count);
    
    %normalise
    t_weights = t_weights./sum(t_weights);
    
    %sample a terrain and assign nss
    chosen_terrain = find(mnrnd(1,t_weights) == 1);
    nss_assignments(chosen_terrain) = nss_assignments(chosen_terrain) + 1;   
    
    %add to robot path
    %get indices of parts in the path where chosen terrain was sensed
    t_idx = find(terrain_counts == chosen_terrain);
    
    %gets a random part of the path where chosen terrain was sent
    chosen_idx = t_idx(randi([1,length(t_idx)], 1));
    
    %insert NSS into robot_path
    new_obs = [state_sequence(chosen_idx,1), state_sequence(chosen_idx,2), 2]; 
    state_sequence = [state_sequence(1:chosen_idx,:); new_obs; state_sequence(chosen_idx+1:end,:)];
    
    %update terrain counts vector
    new_obs = terrain_counts(chosen_idx);
    terrain_counts = [terrain_counts(1:chosen_idx,:); new_obs; terrain_counts(chosen_idx+1:end,:)];
    
end


end
