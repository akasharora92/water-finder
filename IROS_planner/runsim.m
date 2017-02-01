%this script runs multiple runs of the simulation and plots results]

sim_runs = 1;

robot.sensing_budget = 100;
robot.cost_mov = 1;
robot.cost_NIR = 5;
robot.cost_NSS = 5;
robot.rem_budget = 0;

robot.goal_x = 10;
robot.goal_y = 10;


for k = 1:length(sim_runs)
    %for each simulation run, clear belief spaces
    % TODO: Load different maps based on the simulation run.
    [MapParameters,DKnowledge,sim_world] = init('map_data.mat');
    trajectory = [];
    actions = [];
    total_reward = 0;
    
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
        [BeliefMaps, robot, ~] = updateBelief(robot, BeliefMaps, Z_new, DKnowledge,MapParameters);
        
        %update remaining budget
        if robot.sensor_type == 1
            robot.rem_budget = robot.rem_budget - robot.cost_mov;
        elseif robot.sensor_type == 2
            robot.rem_budget = robot.rem_budget - robot.cost_NIR;
        else
            robot.rem_budget = robot.rem_budget - robot.cost_NSS;
        end
        
        trajectory = [trajectory; [robot.xpos,robot.ypos, robot.sensor_type]];
        
        %get best action
        %[best_action, best_reward] = planner1(robot, BeliefMaps, MapParameters, DKnowledge);
        
        %get best action using MCTS default planner- fix inputs and outputs
        max_iterations = 50;
        [ solution, root, list_of_all_nodes, best_action ] = mcts_default(max_iterations, robot, MapParameters, BeliefMaps, DKnowledge, trajectory);
        
        %%debugging
        %disp(winner);
        %disp(solution);
        
        %execute action and update robot position
        if ~isempty(best_action)
            robot.xpos = best_action(1);
            robot.ypos = best_action(2);
            robot.sensor_type = best_action(3);
            
            disp('Best action is:')
            disp([robot.xpos, robot.ypos])

            actions = [actions;robot.sensor_type];
        else
            disp('No best action');
            disp('robot pose is: ');
            disp([robot.xpos,robot.ypos]);
            actions = [actions;0];
            if robot.xpos == robot.goal_x && robot.ypos == robot.goal_y
                disp('At goal!')
                break;
            end
        end
        
    end
    
    
    
    figure();
    scatter(trajectory(:,1),trajectory(:,2));

    disp(actions);
    
    terrain_img = zeros(MapParameters.xsize, MapParameters.ysize, 3);
    water_img = zeros(MapParameters.xsize, MapParameters.ysize, 3);
  
    for i = 1:MapParameters.xsize
        for j=1:MapParameters.ysize
            terrain_img(i,j,:) = BeliefMaps.Terrain{i,j};
            water_img(i,j,:) = BeliefMaps.Water{i,j};
        end
    end


    figure;
    subplot(2,2,1), image(terrain_img), title('Terrain belief');
    subplot(2,2,2), imagesc(water_img), title('Water belief');  
    subplot(2,2,3),imagesc(robot.visibility), title('Robot visibility');   
    subplot(2,2,4), imagesc(robot.visibilityNIR), title('Robot NIR visibility');
    
    pause(0.1);
    
    
end
