function [x_bounds,y_bounds] = get_bounds(world)
	(rows,cols) = size(world{1});
	x_bounds = [0,cols]
	y_bounds = [0,rows]
end
