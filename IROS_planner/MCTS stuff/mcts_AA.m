function [ solution, root, list_of_all_nodes, winner ] = mcts_AA(budget, max_iterations, robot, MapParameters, BeliefMaps, sensor, DomainKnowledge, action_path)

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

% Main loop
for iter = 1:max_iterations
    
    disp(['iteration ', num2str(iter)]);
    
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
            
            robot_new.rem_budget = budget - cost(new_sequence, robot);          
            robot_new.xpos = child_vertex(1);
            robot_new.ypos = child_vertex(2);
            sense_mode = child_vertex(3);
            
            new_unpicked_children = getActionSpace(robot_new, MapParameters);
            
            % add this child node to the tree
            new_child_node = tree_node(current, new_sequence, robot_new.rem_budget, new_unpicked_children, robot_new.xpos, robot_new.ypos, sense_mode);
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
                expl_const = 0.1;
                child_f_score(i) = current.children(i).average_evaluation_score + expl_const*sqrt((2 * log( current.num_updates ) ) / ( current.children(i).num_updates ) );
            end
            
            % choose the child that maximises the UCB
            [~, child_chosen_idx] = max(child_f_score);
            current = current.children(child_chosen_idx);
            
            state_sequence_init = [state_sequence_init; child_vertex];
            
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % ROLLOUT
    % do a rollout from new node to the budget
    % and evaluate the reward
    [state_sequence] = rollout_randompolicy(current, budget, MapParameters, state_sequence_init, robot);
    
    %calculate reward by sampling observations and simulating a belief
    %space update- needs to be fast!
    [rollout_reward, robot_end] = reward_sequence(state_sequence, BeliefMaps, robot, sensor, DomainKnowledge, MapParameters, action_path);
    
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
    
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SOLUTION
% calculate best solution so far
% could be selected in many possible ways...
% recursively select child with highest average reward
current = root;
%while ~isempty(current.children)

% get the average reward for all children
child_reward = zeros(length(current.children),1);
for i = 1:length(child_reward)
    % upper confidence bounds
    child_reward(i) = current.children(i).average_evaluation_score;
end

% choose child with max reward
[~, child_chosen_idx] = max(child_reward);
current = current.children(child_chosen_idx);
%end

winner_score = current.average_evaluation_score;
winner_UCB = sqrt( (2 * log( current.num_updates ) ) / ( current.parent.num_updates ) );

disp(winner_score)
disp(winner_UCB)
solution = current.sequence;
winner = current;

end


