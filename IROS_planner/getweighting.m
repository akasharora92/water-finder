function weighting = getweighting(obs_loc, current_loc)
%returns an influence weighting

dist = sqrt((obs_loc(1) - current_loc(1))^2 + (obs_loc(2) - current_loc(2))^2);

weighting = exp(-0.2.*(dist.^2));

end

