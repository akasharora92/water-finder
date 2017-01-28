%initialise simulation parameters and structures
function [MapParameters,DKnowledge,sim_world] = init(map_data_filename)

sim_world = simulation(map_data_filename);

[x_bounds,y_bounds] = sim_world.get_bounds();

%Simulation map parameters
MapParameters.xsize = x_bounds(2);
MapParameters.ysize = y_bounds(2);
MapParameters.gaussianstd = 1;


%Domain Knowledge
%initialisation of priors
DKnowledge.pTerrain = [1/3; 1/3; 1/3];
DKnowledge.thetaprior = [1 1 1;1 1 1;1 1 1];

%initialisation of sensors models
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
DKnowledge.NIR = [0.9 0.05 0.05; 0.05 0.9 0.05; 0.05 0.05 0.9]';


%P(Z_NSS|W)
%NSS conditional probability table
  %%%%%%%%%%%%%%%%%
%           W      %
%       | 1 | 2 | 3 |
%     1 |
% NSS 2 |
%     3 |
DKnowledge.NSS_TYPE = 3;
DKnowledge.NSS   = [0.8 0.1 0.1; 0.1 0.8 0.1; 0.1 0.1 0.8]';

end