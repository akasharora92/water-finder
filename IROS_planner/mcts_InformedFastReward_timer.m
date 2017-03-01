function [ solution, root, list_of_all_nodes, best_action, winner ] = mcts_InformedFastReward_timer(max_iterations, robot, MapParameters, BeliefMaps, DomainKnowledge, max_time)
%this version of MCTS has an informed rollout policy and evaluates rewards by
%sampling observations, updating beliefs and calculating information gain

%root node initialisation
robot_xpos = robot.xpos;
robot_ypos = robot.ypos;

start_sequence = [];

%get list of children nodes
unpicked_children = getActionSpace(robot, MapParameters);



%%nodes have a x,y position and choice of sensor

sense_mode = 0;
root = tree_node([], start_sequence, 0, unpicked_children, robot_xpos, robot_ypos, sense_mode);

% for debugging only - store all nodes in a list
list_of_all_nodes(1) = root;

budget = robot.rem_budget;

if isempty(unpicked_children)
    best_action = [];
    solution = 0;
    winner = root;
    return
end



%get initial water entropy
entropy_W = 0;
for i=1:MapParameters.xsize
    for j=1:MapParameters.ysize
        prob_W = BeliefMaps.Water{i,j};
        entropy_W = entropy_W - dot(prob_W, log(prob_W));
    end
end

current_time = 0;
tic

% Main loop
for iter = 1:max_iterations
    
    %disp(['iteration ', num2str(iter)]);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % SELECTION and EXPANSION
    % a new node will get added to the tree
    % current = this new node
    current = root;
    
    %initialise state sequence
    state_sequence_init = [];
    
    while true
        % check if there are any children to be added
        if ~isempty(current.unpicked_children)
            % pick one of the children that haven't been added
            
            % just pick the first one but can make this more intelligent in
            % the future
            %child_index = 1;
            
            %pick random child index
            child_index = randi(size(current.unpicked_children,1),1);
            
            child_vertex = current.unpicked_children(child_index,:);
            
            % remove this child from the unpicked list
            list1 = current.unpicked_children(1:child_index-1, :);
            list2 = current.unpicked_children(child_index+1:end,:);
            
            current.unpicked_children = [list1;list2];
            
            % set up new child node
            
            %sequence of sensor measurements made
            new_sequence = [current.sequence, child_vertex(3)];
            
            robot.rem_budget = budget - cost(new_sequence, robot);
            robot.xpos = child_vertex(1);
            robot.ypos = child_vertex(2);
            sense_mode = child_vertex(3);
            
            new_unpicked_children = getActionSpace(robot, MapParameters);
            
            % add this child node to the tree
            new_child_node = tree_node(current, new_sequence, robot.rem_budget, new_unpicked_children, robot.xpos, robot.ypos, sense_mode);
            current.children(end+1) = new_child_node;
            current = new_child_node;
            
            %add state to sequence. This is a sequence of nodes traversed
            %in the tree search
            state_sequence_init = [state_sequence_init; child_vertex];
            
            % for debugging only - add new node to list
            list_of_all_nodes(end+1) = new_child_node;
            
            break;
            
        else
            % all children have been added, therefore pick one to
            % recurse using UCT policy
            
            if(isempty(current.children))
                % there are no more nodes that can be expanded
                break;
            end
            
            % get the UCB score for all children
            child_f_score = zeros(length(current.children),1);
            for i = 1:length(child_f_score)
                % upper confidence bounds
                expl_const = 1;
                child_f_score(i) = current.children(i).average_evaluation_score + expl_const*sqrt((2 * log( current.num_updates ) ) / ( current.children(i).num_updates ) );
            end
            
            % choose the child that maximises the UCB
            [~, child_chosen_idx] = max(child_f_score);
            current = current.children(child_chosen_idx);
            
            %keeps track of all selected nodes from the root node
            state_sequence_init = [state_sequence_init; [current.x_pos, current.y_pos,current.sense_mode]] ;
            
            
            
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % ROLLOUT
    % do a rollout from new node to the budget
    % and evaluate the reward
    %state_sequence_new = [state_sequence_init];
    [state_sequence] = rollout_Informed(current,  MapParameters, robot, BeliefMaps);
    state_sequence_new = [state_sequence_init; state_sequence];
    
    %disp('Rollout time for random:');
    %tic
    %[state_sequence_new] = rollout_randompolicy(current, budget, MapParameters, state_sequence_init, robot);
    %toc
    
    %calculate reward by sampling observations and simulating a belief
    %space update- needs to be fast!
    %[rollout_reward, robot_endstate] = reward_sequence(state_sequence_new, BeliefMaps, robot, DomainKnowledge, MapParameters, action_path, entropy_W);
    [ rollout_reward, ~ ] = reward_approx(state_sequence_new, BeliefMaps, robot, DomainKnowledge, MapParameters);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % BACK-PROPAGATE
    % update stats of all nodes from current back to root node
    parent = current;
    while ~isempty(parent)
        % incremental update to the average
        parent.average_evaluation_score = (parent.average_evaluation_score * parent.num_updates + rollout_reward)/(parent.num_updates + 1);
        
        % keep track of number of visits
        parent.num_updates = parent.num_updates + 1;
        
        % recurse up the tree
        parent = parent.parent;
    end
    current_time = toc;
    if current_time > max_time
        break
    end
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SOLUTION
% calculate best solution so far
% could be selected in many possible ways...
% recursively select child with highest average reward
current = root;

%check if there are any children that can be expanded

% get the average reward for all children
child_reward = zeros(length(current.children),1);
for i = 1:length(child_reward)
    % upper confidence bounds
    child_reward(i) = current.children(i).average_evaluation_score;
end

% choose child with max reward
[~, child_chosen_idx] = max(child_reward);
current = current.children(child_chosen_idx);

winner_score = current.average_evaluation_score;
winner_UCB = sqrt( (2 * log( current.num_updates ) ) / ( current.parent.num_updates ) );



%disp(winner_score)
%disp(winner_UCB)
solution = current.sequence;
winner = current;

best_action(1) = winner.x_pos;
best_action(2) = winner.y_pos;
best_action(3) = winner.sense_mode;


end






