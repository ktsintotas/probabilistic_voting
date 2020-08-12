% 

% Copyright 2020, Konstantinos A. Tsintotas
% ktsintot@pme.duth.gr
%
% This file is part of BoTW-LCD framework for visual loop closure detection
%
% BoTW-LCD framework is free software: you can redistribute 
% it and/or modify it under the terms of the MIT License as 
% published by the corresponding authors.
%  
% BoTW-LCD pipeline is distributed in the hope that it will be 
% useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% MIT License for more details. <https://opensource.org/licenses/MIT>

dataPath = ('images path\'); 
dataFormat = '*.png'; % e.g., for png input data

% parameters' definitions
params = parametersDefinition();

% extraction of visual sensory information
[visualData, timer] = incomingVisualData(params, dataPath, dataFormat);

% dataset's frame rate definition
visualData.frameRate = %; 

% the query procedure
[matches, timer] = queryingDatabase(params, visualData);

% load the ground truth data for the corresponding dataset
groundTruthMatrix = %;

% evaluate the results
results = methodEvaluation(params, matches, groundTruthMatrix);
