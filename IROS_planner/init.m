%initialise simulation parameters and structures

%Simulation map parameters
MapParameters.xsize = 10;
MapParameters.ysize = 10;
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

DKnowledge.NIR = [0.8 0.1 0.1; 0.1 0.8 0.1; 0.1 0.1 0.8]';


%P(Z_NSS|W)
%NSS conditional probability table
  %%%%%%%%%%%%%%%%%
%           W      %
%       | 1 | 2 | 3 |
%     1 |
% NSS 2 |
%     3 |
DKnowledge.NSS   = [0.8 0.1 0.1; 0.1 0.8 0.1; 0.1 0.1 0.8]';



