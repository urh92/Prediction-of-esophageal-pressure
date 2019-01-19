function featNormalized = featureNormalization(featureMat)
%featureNormalization - Normalizes input feature matrix 
%
% Syntax:  featNormalized = featureNormalization(featureMat)
% 
% Inputs: 
%    featureMat - The input feature matrix
%
% Outputs: 
%    featNormalized  - The normalized feature matrix
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% Author: Umaer Hanif
% April 2017; Last revision: 15-June-2017

%------------------------------ BEGIN CODE --------------------------------

% Compute the 95th and 5th percentiles of each column in the feature matrix
pseudoMax = prctile(featureMat, 95);   
pseudoMin = prctile(featureMat, 5);     

% Reshape vectors of percentiles to match size of feature matrix
pseudoMax = repmat(pseudoMax, length(featureMat), 1);
pseudoMin = repmat(pseudoMin, length(featureMat), 1);

% Normalize entire feature matrix
featNormalized = (featureMat - pseudoMin)./(pseudoMax - pseudoMin);

% Set values above 1 to 1 and values below 0 to 0
above = featNormalized > 1;
below = featNormalized < 0;
featNormalized(above) = 1;
featNormalized(below) = 0;

end

%------------------------------ END OF CODE -------------------------------