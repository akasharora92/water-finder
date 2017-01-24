classdef simulation < handle
	properties
		map_data;
        current_pos;
        true_terrain;
        terrain_map;
        water_map;
    end
    methods
        function obj=simulation(map_name)
            data_struct = load(map_name);
            obj.map_data = data_struct.out_data;
            obj.current_pos = [1,1];
            obj.true_terrain = 1;
            obj.terrain_map = 2;
            obj.water_map = 3;
        end
        
        function [x_bounds,y_bounds] = get_bounds(obj)
            dim_size = size(obj.map_data);
            x_bounds = [1,dim_size(2)];
            y_bounds = [1,dim_size(1)];
        end
        
        function [cost,t] = move_to(obj,x,y)
            cost = sqrt((obj.current_pos(1)-x)^2 + (obj.current_pos(2)-y)^2);
            t = obj.map_data{obj.true_terrain}(y,x);
            obj.current_pos = [x,y];
        end 
        
        function w = sample(obj,x,y,sensor)
            assert(x==obj.current_pos(1) && x > 0);
            assert(y==obj.current_pos(2) && x > 0);
            w = obj.map_data{obj.water_map}(y,x,:);
            w = reshape(w,1,3);
        end
    end
end