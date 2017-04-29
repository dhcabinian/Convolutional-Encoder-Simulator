classdef ViterbiDecode
    properties
        states;
        start_states;
    end
    
    methods
        function obj = ViterbiDecode(lengthOfFilter, fhEncode)
            obj.states = computeStateMachine(lengthOfFilter, fhEncode);
            obj.start_states = obj.states;
        end
      
%         function decodeC()
%             
%         end
        
        function decodedMessage = decodeMessage(obj, r)
            %For each pair of bits in m recieved
            computedMetrics = containers.Map(1:length(obj.states), cell(1,length(obj.states)));
            %Converting the recieved vector into per time transition cell
            % arrays
            if mod(length(r), 2) ~= 0 
                r = [r 0];
            end
            
            numberOfC = length(r) / 2;
            cs = transpose(reshape(r, [], numberOfC));
            for row = 1:size(cs,1)
                c = cs(row, :)
                clearBranchMetricMap(computedMetrics);
                %For each state at time = t in the trellis
                for state = obj.states
                    if state.reached
                       [pathMetric1, pathMetric2] = state.computePathMetric(c);
                        %States in cell array in format
                        % {memory contents, m, path metric} 
                        state_id = bi2de(pathMetric1{1},'left-msb') + 1;
                        currentMetric = computedMetrics(state_id);
                        if isempty(currentMetric)
                            computedMetrics(state_id) = pathMetric1;
                        else
                            if currentMetric{1} >= pathMetric1{1}
                                 computedMetrics(state_id) = pathMetric1;
                            end
                        end
                        state_id = bi2de(pathMetric2{1},'left-msb') + 1;
                        currentMetric = computedMetrics(state_id);
                        if isempty(currentMetric)
                            computedMetrics(state_id) = pathMetric2;
                        else
                            if currentMetric{1} >= pathMetric2{1}
                                 computedMetrics(state_id) = pathMetric2;
                            end
                        end  
                    end
                end
                %All Path metrics have been calculated and filtered
                %Need to apply changes
                
                for key = 1:length(obj.states)
                    pathMetric = computedMetrics(key);
                    % {memory contents, m, path metric}
                    if isempty(pathMetric) == 0
                        state = obj.states(key);
                        updatedState = state.updatePath(pathMetric);
                        obj.states(key) = updatedState;
                    end
                end
            end
            decodedMessage = findMessage(obj.states);
            return
        end
    end
end

function states = computeStateMachine(lengthOfFilter, fhEncode)
    D = 0:2^lengthOfFilter - 1;
    str_B = dec2bin(D);
    cols = size(str_B,1);
    rows = size(str_B,2);
    int_B = zeros(cols, rows);
    for i = 1:cols
        for j = 1:rows
            int_B(i,j) = str2double(str_B(i,j));
        end
    end

    states = [];

    for i = 1:cols
        current_state = int_B(i, 1:end);
        [output, output_state] = fhEncode(current_state, 0);
        state_1 = {output_state, output, 0};
        [output, output_state] = fhEncode(current_state, 1);
        state_2 = {output_state, output, 0};
        brancheObj = Branches(current_state, state_1, state_2);
        state = TrellisState(current_state, brancheObj);
        states = [states state];
    end

    return 
end

function clearBranchMetricMap(map)
    for key = map.keys()
        map(key{1}) = {};
    end
    return
end

function message = findMessage(states)
    minPathMetric = -1;
    minStatePath = {};
    for state = states
        if isempty(minStatePath) || state.path_metric < minPathMetric
            minPathMetric = state.path_metric;
            minStatePath = state.path;
        end
    end
    message = minStatePath;
    return
end
