function [ robot, BeliefMaps ] = clearMemory(robot, MapParameters, DKnowledge)
%clears the robot's internal maps and beliefs

%clear robot memory
robot.visibility = zeros(MapParameters.xsize, MapParameters.ysize);
robot.visibilityNIR = zeros(MapParameters.xsize, MapParameters.ysize);
robot.visibilityNSS = zeros(MapParameters.xsize, MapParameters.ysize);

%initialise beliefs
BeliefMaps.Terain = cell(MapParameters.xsize,MapParameters.ysize);
BeliefMaps.Water = cell(MapParameters.xsize,MapParameters.ysize);

%BeliefMaps.theta = initialise Dirichlet based on DK hyperparameters

%use initial estimate of theta to set prior for water distribution
%priorWater = DomainKnowledge.theta_rl*priorLoc';

%initialise terrain and water belief maps
for i = 1:numel(BeliefMaps.Terrain)
    BeliefMaps.Terrain(i) = {DKnowledge.pTerrain};
    BeliefMaps.Water(i)   = {DKnowledge.pWater};
end

end

