function [BeliefMaps] = updateBelief(robot, BeliefMaps, Z_new, DKnowledge)
%updates the belief over the terrain, water and theta based on the new
%observation

%Example structure: Z_new = [Observation, type of sensor used]
%Z_new = [1 1 x y] if only terrain was observed
%Z_new = [1 2 x y] if NIR was used
%Z_new = [1 3 x y] if NSS was used

%check type of observation
if Z_new(2) == 1
    %if a terrain observation- update belief on terrain directly
    %in the toy problem we directly observe terrain
    newupdate = zeros(3,1);
    newupdate(Z_new(1)) = 1;
    BeliefMaps.Terrain{x,y} = newupdate; 
    robot.visibility(x,y) = 1;
    
    %apply spatial update using gaussian kernel + Bayes update
    for i=1:MapParameters.xsize
        for j=1:MapParameter.ysize
            getweighting
            
        end
    end
    
    
    %apply spatial update to water distribution if it hasn't been seen
    %already
    BeliefMaps.Water
    
elseif Z_new(2) == 2
    %if a NIR observation- just update water type variable distribution
    %conditioned on the terrain
    
    %update Dirichlet distribution
    
else
    %if a NIR observation- just update water type variable distribution
    %conditioned on the terrain
    
    %update Dirichlet distribution
    
end

end

