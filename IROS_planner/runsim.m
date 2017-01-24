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
    % TODO: Load different maps based on the simulation run.
    [MapParameters,DKnowledge,sim_world] = init('map_data.mat');
    
    %set start positions
    robot.xpos = 1;
    robot.ypos = 1;
    robot.sensor_type = 1;
    
    [robot, BeliefMaps] = clearMemory(robot, MapParameters, DKnowledge);
    
    robot.rem_budget = robot.sensing_budget;
    
    %keep iterating until the budget is zero
    while (robot.rem_budget > 0)
        %get observation- query simulator
        [Z_new] = querySim(sim_world,robot.xpos, robot.ypos, robot.sensor_type,DKnowledge);
        
        %update beliefs
        [BeliefMaps] = updateBelief(robot, BeliefMaps, Z_new, DKnowledge,MapParameters);
        
        %update remaining budget
        if robot.sensor_type == 1
            robot.rem_budget = robot.rem_budget - robot.cost_mov;
        elseif robot.sensor_type == 2
            robot.rem_budget = robot.rem_budget - robot.cost_NIR;
        else
            robot.rem_budget = robot.rem_budget - robot.cost_NSS;
        end
        
        %get best action
        [best_action, best_reward] = planner1(robot, BeliefMaps, MapParameters);
        
        %execute action and update robot position
        robot.xpos = best_action(1);
        robot.ypos = best_action(2);
        robot.sensor_type = best_action(3);
        
        disp('Best action is:')
        disp([robot.xpos, robot.ypos])
        disp('Best reward:')
        disp(best_reward);
        

        
    end
    
    
    
    
end
