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

function [matches, timer] = queryingDatabase(params, visualData)

    if params.queryingDatabase.load == true && exist('results/queryingDatabase.mat', 'file')
        load('results/queryingDatabase.mat');  
        
    else
                
        % memory allocation for system's outputs
        matches = matchesInitialization(visualData);
        % memory allocation for timer
        timer = zeros(visualData.imagesLoaded, 1);
        
        for It = 1 : visualData.imagesLoaded 
        
            disp(It);
            
            % SEARCHING THE DATABASE
            % excluding the vocabulary area which would be avoided              
            lastDatabaseLocation = It - ceil(40 * visualData.frameRate);

            if lastDatabaseLocation > 0
                databaseIndexTemp = find(visualData.index <= lastDatabaseLocation);                
                if ~isempty(databaseIndexTemp)                    
                    databaseIndexTemp = databaseIndexTemp(end);
                    % visual vocabulary to be searched
                    database = visualData.database(1 : databaseIndexTemp, :);                     
                else
                     database = single([]);
                end
            else
                database = single([]);
            end

            % vote aggregation
            if ~isempty(database) && size(visualData.features{It}, 1) > params.queryingDatabase.inliersTheshold
               
                tic 
                % k-NN search using  the GPU         
                queryIdxNN = knnsearch(database, visualData.queryFeatures{It}, 'K', 1, 'NSMethod', 'exhaustive');
                %queryIdxNN = gather(knnsearch(gpuArray(database), visualData.queryFeatures{It}, 'K', 1));
                timer(It, 1) = toc;
                
                % votes distribution through the Nearest Neighbor procedure                
                votedLocations = zeros(1, lastDatabaseLocation);
                for v = 1 : length(queryIdxNN)
                    votedLocations(visualData.index(queryIdxNN(v))) = votedLocations(visualData.index(queryIdxNN(v)))+1;
                end
                
                matches.votesMatrix(It, 1 : lastDatabaseLocation) = votedLocations;
                                
                % NAVIGATION USING PROBABILISTIC SCORING
                % images which gather votes
                imagesForBinomial = find(votedLocations);
                % locations which pass the two conditions
                candidateLocationsObservation = zeros(1, lastDatabaseLocation);
                % number of Tracked Words within the searching area 
                LAMDA = databaseIndexTemp;
                % number of query’s Tracked Points (number of points after the guided feature-detection)
                N = size(visualData.queryFeatures{It}, 1);                
                % number of accumulated votes of database location l
                xl = votedLocations(imagesForBinomial);
                % number of TWs members in l over the size of the BoTW list (without the rejected locations)
                p = visualData.lamda(imagesForBinomial) / LAMDA;
                % distribution’s expected value 
                expectedValue = N*p;
                % probability computation for the selected images in the database
                locationProbability = binopdf(xl, N , p);
                % binomial Matrix completion
                
                matches.binomialMatrix(It, imagesForBinomial) = locationProbability;
                % the binomial expected value on each location has to
                % satisfy two conditions, (1) loop closure threshold and (2) over expected value xl(t) > E [Xi(t)]
                Condition2Locations = find(xl > expectedValue);                
                % locations which satisfy condition 2 and condition 1 - observation 3
                if ~isempty(Condition2Locations) ... 
                        && ~isempty(find(locationProbability(Condition2Locations) < params.queryingDatabase.observationThreshold, 1))
                    candidateLocations = imagesForBinomial(Condition2Locations(locationProbability(Condition2Locations) < params.queryingDatabase.observationThreshold));
                    candidateLocationsObservation(candidateLocations) = matches.binomialMatrix(It, candidateLocations);
                end
                
                % MATCHING PROCEDURE       
                % filtering the binomial through Bayes estimation
               
                % define the appropriate loop closing image for the image which gathers the most votes
                if sum(candidateLocationsObservation) ~= 0
                    [probability, ~] = min(candidateLocationsObservation(candidateLocationsObservation>0));
                    candidates = find(candidateLocationsObservation == probability, 1);
                                   
                    [properImage, inliersTotal] = geometricalCheck(It, params, candidates, visualData); 
                                    
                    if properImage ~= 0
                        matches.loopClosureMatrix(It, properImage) = true; 
                        matches.matches(It, 1) = properImage;
                        matches.matches(It, 2) = probability; 
                        matches.inliers(It) = inliersTotal;
                    end
                end               
            end
        end
        
        if params.queryingDatabase.save
            % save variables
            save('results/queryingDatabase', 'matches', 'timer');
        end
        
    end    
end
