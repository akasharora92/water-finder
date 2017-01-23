%this script runs multiple runs of the simulation and plots results]

sim_runs = 1;

MapParameters.sensing_budget = 50;
MapParameters.cost_mov = 1;
MapParameters.cost_NIR = 5;
MapParameters.cost_NSS = 5;
MapParameters.goal_x = 10;
MapParameters.goal_y = 10;

for i = 1:length(sim_runs)
    %for each simulation run, clear belief spaces
    
    %set start positions
    current_x = 1;
    current_y = 1;
    
    rem_budget = MapParameters.sensing_budget;
    %keep iterating until the budget is zero
    while (remainingBudget > 0)
        
        %get best action
        [best_action] = planner1([current_x, current_y], rem_budget, bel_space, MapParameters);
        
        %execute action and update robot position
        current_x = best_action.x;
        current_y = best_action.y;
        
        %get observation- query simulator
        [Z_new] = querySim(best_action.x, best_action.y, best_action.mode);
        
        %update beliefs
        [bel_space] = updateBelief(bel_space, Z_new);
        
        %update remaining budget
        if best_action.mode == 1
           rem_budget = rem_budget - MapParameters.cost_mov; 
        elseif best_action.mode == 2
            rem_budget = rem_budget - MapParameters.cost_NIR; 
        else
            rem_budget = rem_budget - MapParameters.cost_NSS; 
        end
             
    end
    
    
    
    
end
