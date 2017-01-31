%This function creates a sequence of actions using a random policy until
%the budget is exhausted

%INPUTS: Current robot position, its children, budget
%OUTPUTS: Sequence of states and actions taken while adherring to budget

function [state_sequence] = rollout_randompolicy(current_node, budget, MapParameters, state_sequence_init, robot)

%budget = budget left in the mission from the root node

robot.xpos = current_node.x_pos;
robot.ypos = current_node.y_pos;
robot.rem_budget = current_node.budget;

% pick random actions until budget is exhausted
sequence = current_node.sequence;

state_sequence = state_sequence_init;

%while cost(sequence, robot) < budget
while true
    %get reachable actions if budget constraints & goal position constraint
    %is to be followed
    [unpicked_children] = getActionSpace(robot, MapParameters);
    
    if isempty(unpicked_children)
        %we can't take any more actions under the budget and goal position constraints
        %exit
        break;
    end
    
    %selecting a random child
    index = randi(size(unpicked_children,1));
    new_child = [unpicked_children(index,:)];
    
    %update sensing sequence
    sequence = [sequence, new_child(3)];
    state_sequence = [state_sequence; new_child];
    
    %update values for next loop iteration
    robot.rem_budget = budget - cost(sequence, robot);       
    robot.xpos = new_child(1);
    robot.ypos = new_child(2);
    
end

end

