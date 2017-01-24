function [ robot, BeliefMaps ] = clearMemory(robot, MapParameters, DKnowledge)
%clears the robot's internal maps and beliefs

%clear robot memory
robot.visibility = zeros(MapParameters.xsize, MapParameters.ysize);
robot.visibilityNIR = zeros(MapParameters.xsize, MapParameters.ysize);
robot.visibilityNSS = zeros(MapParameters.xsize, MapParameters.ysize);

%initialise beliefs
BeliefMaps.Terrain = cell(MapParameters.xsize,MapParameters.ysize);
BeliefMaps.Water = cell(MapParameters.xsize,MapParameters.ysize);

BeliefMaps.hyptheta = DKnowledge.thetaprior;

%sum of the hyperparameters in each row
hyp_sum = sum(BeliefMaps.hyptheta,2);

BeliefMaps.theta = BeliefMaps.hyptheta./[hyp_sum, hyp_sum, hyp_sum];

%Theta array conditional probability table
  %%%%%%%%%%%%%%%%%
%           W      %
%     | 1 | 2 | 3 |
%   1 |
% T 2 |
%   3 |

%use initial estimate of theta to set prior for water distribution
priorWater = BeliefMaps.theta'*DKnowledge.pTerrain;

%initialise terrain and water belief maps
for i = 1:numel(BeliefMaps.Terrain)
    BeliefMaps.Terrain(i) = {DKnowledge.pTerrain};
    BeliefMaps.Water(i)   = {priorWater};
end

end

