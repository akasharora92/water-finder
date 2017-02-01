function [ infoGain_tot, robot_current ] = reward_sequence(state_sequence, BeliefMaps, robot_startstate, DKnowledge, MapParameters, action_path, init_waterent)
%This function takes the robot position and action sequence and simulates
%belief updates. The output is total information gained

%for each sequence
%extract the robot position and sensor to use
%simulate belief update based on sensor choice
%repeat until the end of state sequence is reached and output the infogain
%(it can just be summed over the sequence)

repeatflag = 0;
robot_current = robot_startstate;

ent_W = 1000;
for i = 1:size(state_sequence,1)
    %simulating a robot
    robot_current.xpos = state_sequence(i,1);
    robot_current.ypos = state_sequence(i,2);
    sensing_mode = state_sequence(i,3);
    
    %check if actions have been repeated before
    for j = 1:size(action_path,1)
        if action_path(j,1) == 0 %we have exhausted the previous actions
            repeatflag = 0;
            break
        elseif action_path(j,:) == state_sequence(i,:) %current state matches the previous actions
            repeatflag = 1;
            break
        end
    end
    
    if repeatflag == 0 %if the action hasn't been done before- update belief space
        
        %initialise observation vector
        Z_new = [0, sensing_mode, robot_current.xpos, robot_current.ypos];
        
        if sensing_mode == 1
            %standard sensor
            %get predicted observation
            p_Terrain = BeliefMaps.Terrain{state_sequence(i,1), state_sequence(i,2)};
            sample_obs = mnrnd(1, p_Terrain);
            Z_new(1) = find(sample_obs == 1);
            
            
        elseif sensing_mode == 2
            %NIR
            %get predicted observation
            %P(Z_NIR|W)
            %NIR conditional probability table
            %%%%%%%%%%%%%%%%%
            %           W      %
            %       | 1 | 2 | 3 |
            %     1 |
            % NIR 2 |
            %     3 |
            prob_Water = BeliefMaps.Water{state_sequence(i,1), state_sequence(i,2)};
            p_NIR = DKnowledge.NIR*prob_Water;
            sample_obs = mnrnd(1, p_NIR);
            Z_new(1) = find(sample_obs == 1);
            
        else
            %NSS
            prob_Water = BeliefMaps.Water{state_sequence(i,1), state_sequence(i,2)};
            p_NSS = DKnowledge.NSS*prob_Water;
            sample_obs = mnrnd(1, p_NSS);
            Z_new(1) = find(sample_obs == 1);
            
        end
        
        
        %update belief
        [BeliefMaps, robot_current, ent_W] = updateBelief(robot_current, BeliefMaps, Z_new, DKnowledge,MapParameters);
        
    end
    
end


%the total information gained from the policy normalised
infoGain_tot = (init_waterent - ent_W)/init_waterent;


end

