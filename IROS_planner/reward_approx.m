function [ infoGain_tot, robot_current ] = reward_approx(state_sequence, BeliefMaps, robot_startstate, DKnowledge, MapParameters)
%This function takes the robot position and action sequence and
%approximates the reward or information gain that might be gained without
%simulating belief updates

%for each sequence
%extract the robot position and sensor to use
%simulate belief update based on sensor choice
%repeat until the end of state sequence is reached and output the infogain
%(it can just be summed over the sequence)

robot_current = robot_startstate;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%sample a map
seedNum = 10;

x_ind = randi([1,MapParameters.xsize], [seedNum,1]);
y_ind = randi([1,MapParameters.ysize], [seedNum,1]);

seed_index = [x_ind, y_ind];

%assign terrain label to these seeds
seed_labels = ones(seedNum,1);
for i=1:seedNum
    p_dist = BeliefMaps.Terrain{seed_index(i,1), seed_index(i,2)};
    seed_labels(i) = find(mnrnd(1, p_dist) == 1);
end

[terrain_map] = createVoronoi(seed_index, seed_labels, MapParameters);

%decouple the NSS and terrain exploration
sensor_states = state_sequence(:,3);
%counts of terrains visited
t_idx = find(sensor_states == 1);
t_counts = terrain_map(sub2ind(size(terrain_map),state_sequence(t_idx,1)', state_sequence(t_idx,2)'));
t_vector = zeros(3,1);
for i = 1:length(t_vector)
    t_vector(i) = numel(find(t_counts == i));
end

%counts of nss in each terrain
nss_idx = find(sensor_states == 2);
nss_counts = terrain_map(sub2ind(size(terrain_map),state_sequence(nss_idx,1)', state_sequence(nss_idx,2)'));
%nss_counts = terrain_map(state_sequence(nss_idx,1), state_sequence(nss_idx,2));
nss_vector = zeros(3,1);
for i = 1:length(nss_vector)
    nss_vector(i) = numel(find(nss_counts == i));
end

%approximating the likelihoods of already seen terrains..
tot_Tprobs = zeros(3,1);
for i = 1:MapParameters.xsize
    for j=1:MapParameters.ysize
        prob_T = BeliefMaps.Terrain{i,j};
        tot_Tprobs = tot_Tprobs + prob_T;
    end
end

theta_init = BeliefMaps.theta;
ent_theta_init = -sum(theta_init.*(log(theta_init)),2);

uniform_dist = 1/3.*ones(3);
ent_theta_noinfo = -sum(uniform_dist.*(log(uniform_dist)),2);
info_stateinit = sum((ent_theta_noinfo - ent_theta_init).*tot_Tprobs);

%sample water observations that might be made and increment hyperparameters
for i = 1:length(nss_idx)
    %update Dirichlet distribution
    %get position where NSS was taken
    robot_xpos = state_sequence(nss_idx(i),1);
    robot_ypos = state_sequence(nss_idx(i),2);
    
    %get terrain label
    prob_T = zeros(3,1);
    prob_T(terrain_map(robot_xpos, robot_ypos)) = 1;
    
    %get water probability based on current beliefs
    prob_W = BeliefMaps.theta'*prob_T;
    
    %sample an observation obs
    p_obs = DKnowledge.NIR*prob_W;
    p_obs = p_obs./sum(p_obs);
    obs = find(mnrnd(1,p_obs)==1);
    s_likelihood = DKnowledge.NIR(obs,:);
    
    current_hypparameters = BeliefMaps.hyptheta;
    prior_theta = BeliefMaps.theta;
    
    %calculating new hyperparameters
    update_mat = zeros(3,3);
    for j=1:size(prior_theta,1)
        %Need to calculate P(T,W|Z)=n*P(NIR|W)*P(W|T)*P(T|Z)
        %P(NIR|T)..
        pNIRgivenW = s_likelihood;
        %P(T,W|Z)..
        if prob_T(j) > 0
            PTWgivenZ = pNIRgivenW.*prior_theta(j,:).*prob_T(j);
            PTWgivenZ = PTWgivenZ./sum(PTWgivenZ);
            update_mat(j, :) = PTWgivenZ;
        end
    end
    update_mat = update_mat./sum(sum(update_mat));
    current_hypparameters = current_hypparameters + update_mat;
    
    BeliefMaps.hyptheta = current_hypparameters;
    %sum of the hyperparameters in each row
    hyp_sum = sum(BeliefMaps.hyptheta,2);
    
    %update expectation matrix
    BeliefMaps.theta = BeliefMaps.hyptheta./[hyp_sum, hyp_sum, hyp_sum];
end
%calculate change in entropy of theta
theta_final = BeliefMaps.theta;
ent_theta_final = -sum(theta_final.*(log(theta_final)),2);
%infogain_theta = ent_theta_init - ent_theta_final;

%creating an occupancy map to represent area. This is an approximation of
%the new terrain information the rollout is getting
occ_map = zeros(MapParameters.xsize, MapParameters.ysize);
radius = 3;

for i = 1:size(state_sequence,1)
    %simulating a robot
    robot_current.xpos = state_sequence(i,1);
    robot_current.ypos = state_sequence(i,2);
    
    occ_map_xrange = (robot_current.xpos - radius):(robot_current.xpos + radius);
    occ_map_xrange(occ_map_xrange < 1) = [];
    occ_map_xrange(occ_map_xrange > MapParameters.xsize) = [];
    
    occ_map_yrange = (robot_current.ypos - radius):(robot_current.ypos + radius);
    occ_map_yrange(occ_map_yrange < 1) = [];
    occ_map_yrange(occ_map_yrange > MapParameters.ysize) = [];
    
    occ_map(occ_map_xrange, occ_map_yrange) = 1;
        
end

%get proportion of terrains expected to be seen according to occupancy map
tot_numcellsseen = numel(occ_map(occ_map == 1));
t_vector = tot_numcellsseen.*t_vector;

info_statefinal = sum((ent_theta_noinfo - ent_theta_final).*(tot_Tprobs+t_vector));

infoGain_tot = (info_statefinal - info_stateinit)/1000;
    
end
