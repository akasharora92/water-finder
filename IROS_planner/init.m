%initialise simulation parameters and structures
function [MapParameters,DKnowledge,sim_world] = init()

%Domain Knowledge
%initialisation of priors
DKnowledge.pTerrain = [1/3; 1/3; 1/3];
DKnowledge.thetaprior = [1 1 1;1 1 1;1 1 1];

%initialisation of sensors models

%P(Z_T|T)
%Terrain observation conditional probability table
  %%%%%%%%%%%%%%%%%
%             T      %
%       | 1 | 2 | 3 |
%     1 |
% Z_T 2 |
%     3 |

DKnowledge.TNoise = [0.9 0.05 0.05; 0.05 0.9 0.05; 0.05 0.05 0.9]';

%P(Z_NIR|W)
%NIR conditional probability table
  %%%%%%%%%%%%%%%%%
%           W      %
%       | 1 | 2 | 3 |
%     1 |
% NIR 2 |
%     3 |

DKnowledge.NIR_TYPE = 2;
%DKnowledge.NIR = [0.8 0.1 0.1; 0.1 0.8 0.1; 0.1 0.1 0.8]';
%DKnowledge.NIR = [0.9 0.05 0.05; 0.05 0.9 0.05; 0.05 0.05 0.9]';
DKnowledge.NIR = [0.95 0.025 0.025; 0.025 0.95 0.025; 0.025 0.025 0.95];

%P(Z_NSS|W)
%NSS conditional probability table
  %%%%%%%%%%%%%%%%%
%           W      %
%       | 1 | 2 | 3 |
%     1 |
% NSS 2 |
%     3 |
DKnowledge.NSS_TYPE = 3;
DKnowledge.NSS = DKnowledge.NIR;

%Unknown to the robot beforehand
MapParameters.TWCorrelation = [1 1 18; 2 17 1; 17 2 1];

MapParameters.num_seeds = 20;
out_data = make_map(MapParameters, DKnowledge);

sim_world = simulation('map_data.mat');

[x_bounds,y_bounds] = sim_world.get_bounds();

%Simulation map parameters
MapParameters.xsize = x_bounds(2);
MapParameters.ysize = y_bounds(2);
MapParameters.gaussianstd = 0.2;

end