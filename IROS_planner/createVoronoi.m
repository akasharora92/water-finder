function [ terrain_map ] = createVoronoi( seed_dist, seed_labels, MapParameters )
%generate voronoi maps

terrain_map = zeros(MapParameters.xsize, MapParameters.ysize);

for x=1:MapParameters.xsize
    for y=1:MapParameters.ysize
        %create voronoi map
        x_diff = seed_dist(:,1) - x;
        y_diff = seed_dist(:,2) - y;
        dist = x_diff.*x_diff + y_diff.*y_diff;
        [~,idx] = min(dist);
        
        %assigning label to the terrain map
        terrain_map(x,y) = seed_labels(idx);
        
    end
end

end

