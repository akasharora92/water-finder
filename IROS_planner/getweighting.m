function weighting = getweighting(obs_loc, current_loc, MapParameters)
%returns an influence weighting

dist = sqrt((obs_loc(1) - current_loc(1))^2 + (obs_loc(2) - current_loc(2))^2);

weighting = exp(-MapParameters.gaussianstd.*(dist.^2));

end

