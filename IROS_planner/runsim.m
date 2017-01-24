%this script runs multiple runs of the simulation and plots results]

sim_runs = 1;

robot.sensing_budget = 50;
robot.cost_mov = 1;
robot.cost_NIR = 5;
robot.cost_NSS = 5;
robot.rem_budget = 0;

robot.goal_x = 10;
robot.goal_y = 10;

for i = 1:length(sim_runs)
    %for each simulation run, clear belief spaces
    
    %set start positions
    robot.xpos = 1;
    robot.ypos = 1;
    
    [robot, BeliefMaps] = clearMemory(robot, MapParameters, DomainKnowledge);
    
    robot.rem_budget = robot.sensing_budget;
    
    %keep iterating until the budget is zero
    while (rem_budget > 0)
        
        %get best action
        [best_action] = planner1(robot, BeliefMaps, MapParameters);
        
        %execute action and update robot position
        robot.xpos = best_action.x;
        robot.ypos = best_action.y;
        
        %get observation- query simulator
        [Z_new] = querySim(best_action.x, best_action.y, best_action.mode);
        
        %update beliefs
        [BeliefMaps] = updateBelief(robot, BeliefMaps, Z_new, DKnowledge);
        
        %update remaining budget
        if best_action.mode == 1
           robot.rem_budget = robot.rem_budget - robot.cost_mov; 
        elseif best_action.mode == 2
            robot.rem_budget = robot.rem_budget - robot.cost_NIR; 
        else
            robot.rem_budget = robot.rem_budget - robot.cost_NSS; 
        end
             
    end
    
    
    
    
end
