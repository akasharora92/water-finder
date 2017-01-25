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
        if ~isempty(best_action)
            robot.xpos = best_action(1);
            robot.ypos = best_action(2);
            robot.sensor_type = best_action(3);
            
            disp('Best action is:')
            disp([robot.xpos, robot.ypos])
            disp('Best reward:')
            disp(best_reward);
            total_reward = total_reward + best_reward;
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
        trajectory = [trajectory; [robot.xpos,robot.ypos]];
    end
    figure();
    scatter(trajectory(:,1),trajectory(:,2));
    disp(total_reward);
    
    terrain_img = zeros(MapParameters.xsize,MapParameters.ysize,3);
    water_img = zeros(MapParameters.xsize,MapParameters.ysize,3);
    for i = 1:MapParameters.xsize
        for j=1:MapParameters.ysize
            terrain_img(i,j,:) = reshape(BeliefMaps.Terrain{i,j},1,3);
            water_img(i,j,:) = reshape(BeliefMaps.Water{i,j},1,3);
        end
    end
    
    disp(actions);
    
    figure();
    [V,I] = max(terrain_img,[],3);
    image(I,'CDataMapping','scaled');
    colorbar
    figure();
    image(water_img,'CDataMapping','scaled');
    colorbar
end
