function make_map()

    rand_seed = 1209371812;
    rng(rand_seed);

    
    out_data = cell(3,1); % 1 = truth, 2 = noisy terrain, 3 = noisy water observation.
    
    num_terrain_types = 3;
    num_water_types = 3;
    num_seeds = 10;

    map_dim = 10;

    map_data = zeros(map_dim,map_dim);
	water_map = zeros(map_dim,map_dim,num_water_types);
    noisy_map = cell(map_dim,map_dim);

    seeds = randi(map_dim,num_seeds,2);
    labels = randi(num_terrain_types,num_seeds,1);

    terrain_to_water = [1 1 18; 2 17 1; 17 2 1];
   

    for y=1:map_dim
        for x=1:map_dim
            x_diff = seeds(:,1) - x;
            y_diff = seeds(:,2) - y;
            dist = x_diff.*x_diff + y_diff.*y_diff;
            [v,idx] = min(dist);
            map_data(y,x) = labels(idx);
            terrain_hist = zeros(1,num_terrain_types);
            terrain_hist(labels(idx)) = 1;
            noisy_map{y,x} = corrupt(terrain_hist);
            water_map(y,x,:) = dirichlet(terrain_to_water(labels(idx),:));
        end
    end
   
    figure(1);
    image(map_data,'CDataMapping','scaled');
    figure(2);
    image(water_map,'CDataMapping','scaled')
    colorbar
    
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
