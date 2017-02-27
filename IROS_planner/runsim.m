%this script runs multiple runs of the simulation and plots results]

sim_runs = 20;

robot.sensing_budget = 100;
robot.cost_mov = 1;
robot.cost_NIR = 5;
robot.cost_NSS = 5;
robot.rem_budget = 0;

robot.goal_x = 20;
robot.goal_y = 20;

time_stamprecord = zeros(robot.sensing_budget, sim_runs);
brier_scores = zeros(robot.sensing_budget, sim_runs);
water_ent = zeros(robot.sensing_budget, sim_runs);
robot_budgetrecord = zeros(robot.sensing_budget, sim_runs);

for k = 1:sim_runs
    %for each simulation run, clear belief spaces
    % TODO: Load different maps based on the simulation run.
    
    %generate random map
    out_data = make_map();
    [MapParameters,DKnowledge,sim_world] = init('map_data.mat');
    
    true_watermap = sim_world.map_data{3,1};
    
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
    loop_counter = 1;
    while (robot.rem_budget > 0)
        %get observation- query simulator
        [Z_new] = querySim(sim_world,robot.xpos, robot.ypos, robot.sensor_type,DKnowledge);
        
        %update beliefs
        [BeliefMaps, robot, ent_W] = updateBelief(robot, BeliefMaps, Z_new, DKnowledge,MapParameters);
        
        %update remaining budget
        if robot.sensor_type == 1
            robot.rem_budget = robot.rem_budget - robot.cost_mov;
        elseif robot.sensor_type == 2
            robot.rem_budget = robot.rem_budget - robot.cost_NIR;
        else
            robot.rem_budget = robot.rem_budget - robot.cost_NSS;
        end
        
        
        %get brier score 1/N sum(p_W - t_W)^2
        tot_score = 0;
        for i=1:size(true_watermap,1)
            for j=1:size(true_watermap,2)
                prob_W = BeliefMaps.Water{i,j};
                true_W = zeros(3,1);
                true_W(true_watermap(i,j)) = 1;
                
                B_score = mean((prob_W - true_W).^2);
                tot_score = tot_score + B_score;
            end
        end
        
        robot_budgetrecord(loop_counter, k) = robot.rem_budget;
        brier_scores(loop_counter, k) = tot_score;
        water_ent(loop_counter,k) = ent_W;
        
        trajectory = [trajectory; [robot.xpos,robot.ypos, robot.sensor_type]];
       
        
        %get best action
        %[best_action, best_reward] = planner1(robot, BeliefMaps, MapParameters, DKnowledge);
        
        %get best action using MCTS default planner- fix inputs and outputs
        tic
        max_iterations = 50;
        %[ solution, root, list_of_all_nodes, best_action ] = mcts_default(max_iterations, robot, MapParameters, BeliefMaps, DKnowledge, trajectory);
        
        %[ solution, root, list_of_all_nodes, best_action, winner ] = mcts_Informed(max_iterations, robot, MapParameters, BeliefMaps, DKnowledge, trajectory);
        [ solution, root, list_of_all_nodes, best_action, winner ] = mcts_InformedFastReward(max_iterations, robot, MapParameters, BeliefMaps, DKnowledge);
        time_it = toc;
        time_stamprecord(loop_counter,k) = time_it;
        
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
                robot.rem_budget = 0;
                %break;
            end
        end
        loop_counter = loop_counter + 1;
    end
    
    
    %plotting final results
   % figure();
   % scatter(trajectory(:,1),trajectory(:,2));

   % disp(actions);
    
    terrain_img = zeros(MapParameters.xsize, MapParameters.ysize, 3);
    water_img = zeros(MapParameters.xsize, MapParameters.ysize, 3);
  
    for i = 1:MapParameters.xsize
        for j=1:MapParameters.ysize
            terrain_img(i,j,:) = BeliefMaps.Terrain{i,j};
            water_img(i,j,:) = BeliefMaps.Water{i,j};
        end
    end


    figure;
    subplot(3,2,1), image(terrain_img), title('Terrain belief');
    subplot(3,2,2), imagesc(water_img), title('Water belief');  
    subplot(3,2,3),imagesc(robot.visibility), title('Robot visibility');   
    subplot(3,2,4), imagesc(robot.visibilityNIR), title('Robot NIR visibility');
    subplot(3,2,5), imagesc(sim_world.map_data{1,1}), title('True terrain');
    subplot(3,2,6), imagesc(sim_world.map_data{3,1}), title('True water map');
    pause(0.1);
    
    
end
