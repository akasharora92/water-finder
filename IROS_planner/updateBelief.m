function [BeliefMaps, robot, entropy_W] = updateBelief(robot, BeliefMaps, Z_new, DKnowledge,MapParameters)
%updates the belief over the terrain, water and theta based on the new
%observation

%Example structure: Z_new = [Observation, type of sensor used, x location of sense, y location of sense]
%Z_new = [1 1 x y] if only terrain was observed
%Z_new = [1 2 x y] if NIR was used
%Z_new = [1 3 x y] if NSS was used
sense_choice = Z_new(2);
obs_x = Z_new(3);
obs_y = Z_new(4);


%Theta array conditional probability table
%%%%%%%%%%%%%%%%%
%           W      %
%     | 1 | 2 | 3 |
%   1 |
% T 2 |
%   3 |

entropy_W = 0;

%check type of observation
if sense_choice == 1
    %if a terrain observation- update belief on terrain directly
    
    %check if cell has already been seen- only update if it hasn't been
    %seen before..
    if robot.visibility(obs_x, obs_y) == 0
        robot.visibility(obs_x,obs_y) = 1;
        
        prior_T = BeliefMaps.Terrain{obs_x,obs_y};
        
        %grab corresponding row from the DK
        t_likelihood = DKnowledge.TNoise(Z_new(1),:)';
        
        %bayes update
        posterior_T = prior_T.*t_likelihood;
        posterior_T = (1/sum(posterior_T)).*posterior_T;
        
        %stop probabilities from hitting 0.
        for i=1:length(posterior_T)
            if posterior_T(i) < 0.01
                posterior_T(i) = 0.01;
            end
        end
        
        posterior_T = (1/sum(posterior_T)).*posterior_T;
        BeliefMaps.Terrain{obs_x,obs_y} = posterior_T;
        
        
        %apply spatial update using gaussian kernel + Bayes update
        for i=1:MapParameters.xsize
            for j=1:MapParameters.ysize
                %get influence of observation on a cell
                weighting = getweighting([obs_x, obs_y], [i,j],MapParameters);
                
                %we just updated this cell
                if weighting == 1
                    continue
                end
                %for speed, only update if weighting is significant
                if weighting > 0.1
                    new_update = weighting*t_likelihood + (1-weighting)*[1/3; 1/3; 1/3];
                    prior_T = BeliefMaps.Terrain{i,j};
                    posterior_T = prior_T.*new_update;
                    posterior_T = (1/sum(posterior_T)).*posterior_T;
                    %stop probabilities from hitting 0.
                    for b=1:length(posterior_T)
                        if posterior_T(b) < 0.01
                            posterior_T(b) = 0.01;
                        end
                    end
                    posterior_T = (1/sum(posterior_T)).*posterior_T;
                    BeliefMaps.Terrain{i,j} = posterior_T;
                end
                
            end
        end
    end
    
elseif sense_choice == 2
    if robot.visibility(obs_x, obs_y) == 0
        disp('Error!!')
        return
        
    elseif robot.visibilityNIR(obs_x, obs_y) == 0
        robot.visibilityNIR(obs_x, obs_y) = 1;
        %if a NIR observation- just update water type variable distribution
        prior_W = BeliefMaps.Water{obs_x,obs_y};
        
        %grab corresponding row from the DK
        s_likelihood = DKnowledge.NIR(Z_new(1),:);
        
        %bayes update
        posterior_W = prior_W.*s_likelihood';
        posterior_W = (1/sum(posterior_W)).*posterior_W;
        BeliefMaps.Water{obs_x,obs_y} = posterior_W;
        
        %update Dirichlet distribution
        prior_dist = BeliefMaps.hyptheta;
        prior_theta = BeliefMaps.theta;
        
        prob_T = BeliefMaps.Terrain{obs_x, obs_y};
        %calculating new hyperparameters
        update_mat = zeros(3,3);
        for i=1:size(prior_theta,1)
            %Need to calculate P(T,W|Z)=n*P(NIR|W)*P(W|T)*P(T|Z)
            %P(NIR|T)..
            pNIRgivenW = s_likelihood;
            %P(T,W|Z)..
            if prob_T(i) > 0
                PTWgivenZ = pNIRgivenW.*prior_theta(i,:).*prob_T(i);
                %PTWgivenZ = PTWgivenZ./sum(PTWgivenZ);
                update_mat(i, :) = PTWgivenZ;
            end
        end
        update_mat = update_mat./sum(sum(update_mat));
        BeliefMaps.hyptheta = prior_dist + update_mat;
        
        %sum of the hyperparameters in each row
        hyp_sum = sum(BeliefMaps.hyptheta,2);
        
        %update expectation matrix
        BeliefMaps.theta = BeliefMaps.hyptheta./[hyp_sum, hyp_sum, hyp_sum];
    end
    
else
    if robot.visibilityNSS(obs_x, obs_y) == 0
        robot.visibilityNSS(obs_x, obs_y) = 1;
        %if a NSS observation- just update water type variable distribution
        prior_W = BeliefMaps.Water{obs_x,obs_y};
        
        %grab corresponding row from the DK
        s_likelihood = DKnowledge.NSS(Z_new(1),:);
        
        %bayes update
        posterior_W = prior_W.*s_likelihood';
        posterior_W = (1/sum(posterior_W)).*posterior_W;
        BeliefMaps.Water{obs_x,obs_y} = posterior_W;
        
        %update Dirichlet distribution
        prior_dist = BeliefMaps.hyptheta;
        
        %calculating new hyperparameters
        update_mat = zeros(3,3);
        T_type = BeliefMaps.Terrain{obs_x, obs_y} == 1;
        update_mat(T_type, :) = posterior_W';
        BeliefMaps.hyptheta = prior_dist + update_mat;
        
        %sum of the hyperparameters in each row
        hyp_sum = sum(BeliefMaps.hyptheta,2);
        
        %update expectation matrix
        BeliefMaps.theta = BeliefMaps.hyptheta./[hyp_sum, hyp_sum, hyp_sum];
    end
end


%update water distribution in unseen cells based on new theta
for i=1:MapParameters.xsize
    for j=1:MapParameters.ysize
        prob_T = BeliefMaps.Terrain{i,j};
        
        %update water distribution if it hasn't been seen
        %by the NSS or NIR already
        if ((robot.visibilityNIR(i,j) == 0) && (robot.visibilityNSS(i,j) == 0))
            BeliefMaps.Water{i,j} = BeliefMaps.theta'*prob_T;
        end
        
        prob_W = BeliefMaps.Water{i,j};
        entropy_W = entropy_W - dot(prob_W, log(prob_W));
    end
end


end

