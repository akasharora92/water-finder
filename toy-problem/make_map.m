function out_data = make_map(MapParameters, DKnowledge)

    %rand_seed = 1209371812;
    %rng(rand_seed);

    
    out_data = cell(3,1); % 1 = truth, 2 = noisy terrain, 3 = noisy water observation.
    
    num_terrain_types = 3;
    num_water_types = 3;
    
    num_seeds = MapParameters.num_seeds;

    map_dim = 20;

    map_data = zeros(map_dim,map_dim);
	water_map = zeros(map_dim,map_dim);
    noisy_terrain_map = zeros(map_dim,map_dim);
	noisy_nss_map = zeros(map_dim,map_dim);

    seeds = randi(map_dim,num_seeds,2);
    labels = randi(num_terrain_types,num_seeds,1);

    terrain_to_water = MapParameters.TWCorrelation;
	
    nss_noise_model = DKnowledge.NIR;
    %nss_noise_model = [0.95 0.025 0.025; 0.025 0.95 0.025; 0.025 0.025 0.95];
    
    terrain_noise_model = DKnowledge.TNoise;
    %terrain_noise_model = [0.9 0.05 0.05; 0.05 0.9 0.05; 0.05 0.05 0.9];
   
    for y=1:map_dim
        for x=1:map_dim
            %create voronoi map
            x_diff = seeds(:,1) - x;
            y_diff = seeds(:,2) - y;
            dist = x_diff.*x_diff + y_diff.*y_diff;
            [v,idx] = min(dist);
            
            %assigning label to the terrain map
            map_data(x,y) = labels(idx);
            
            %add noise to the terrain labels
            terrain_hist = zeros(1,num_terrain_types);
            terrain_hist(labels(idx)) = 1;          
            
            %uses dirichlet to corrupt map
            %noisy_terrain_map(x,y) = sample_multinomial(corrupt(terrain_hist));
            
            %samples from multinomial to corrupt map
            noisy_terrain_map(x,y) = sample_multinomial(terrain_noise_model(map_data(x,y),:));
            
           	water_val =  sample_multinomial(terrain_to_water(map_data(x,y),:));
            water_map(x,y) = water_val;
			noisy_nss_map(x,y) = sample_multinomial(nss_noise_model(water_map(x,y),:));
        end
    end
    
    out_data{1} = map_data;
    out_data{2} = noisy_terrain_map;
    out_data{3} = water_map;
    out_data{4} = noisy_nss_map;
   
%     figure();
%     image(map_data,'CDataMapping','scaled');
%     figure();
%     image(noisy_terrain_map,'CDataMapping','scaled');
%     figure();
%     image(water_map,'CDataMapping','scaled')
%     figure();
%     image(noisy_nss_map,'CDataMapping','scaled')
%     colorbar
    
    save('map_data.mat','out_data');
end 

function new_hist = corrupt(terrain_hist)
    % sample from dirichlet distribution to get this.
		a = zeros([length(terrain_hist),length(terrain_hist)]);
		for i=1:length(terrain_hist)
			a(i,i) = 8;
			others = setdiff(1:length(terrain_hist),i);
			a(i,others) = 2/(length(terrain_hist)-1);
		end
		[v,idx] = max(terrain_hist);
    new_hist = dirichlet(a(idx,:));
end

function val = sample_multinomial(dist)
	u = rand();
	sensor_cdf = cumsum(dist/sum(dist)); %Hack put in, incase dist not normalized
	val = find(sensor_cdf > u,1);
end
