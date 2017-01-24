classdef simulation < handle
	properties
		terrain_map;
        current_pos;
    end
    methods
        function obj=simulation(map_name)
            obj.terrain_map = load(map_name);
            obj.current_pos = [1,1];
        end
        
        function [x_bounds,y_bounds] = get_bounds(obj)
            dim_size = size(obj.terrain_map);
            x_bounds = [1,dim_size(2)];
            y_bounds = [1,dim_size(1)];
        end
        
        function [cost,t] = move_to(obj,x,y)
            cost = sqrt(obj.current_pos(2)-x)^2 + (obj.current_pos(1)-y)^2);
            t = corrupt(obj.terrain_map{1}{x,y});
            obj.current_pos = [x,y];
        end 
        
        function w = sample(obj,x,y,sensor)
            assert(x==obj.current_pos(1) && x > 0);
            assert(y==obj.current_pos(2) && x > 0);
            w = obj.terrain_map{sensor}{x,y};
        end
    end
end


