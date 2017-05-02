classdef ViterbiDecode
    properties
        states;
        start_states;
        constellation;
        decodeType;
        encoder;
    end
    
    methods
% Inputs
%     lengthOfFilter = number of delays + 1 (total number of inputs to filter)
%     fhEncode = function handler to the encoding function used
%     constellation = constellation object used
%     decodeType = 'soft' or 'hard'
        function obj = ViterbiDecode(encoder, constellation, decodeType)
            obj.encoder = encoder;
            obj.states = computeStateMachine(encoder);
            obj.start_states = obj.states;
            obj.constellation = constellation;
            if strcmp(decodeType,'Soft')
                obj.decodeType = 1;
            elseif strcmp(decodeType,'Hard')
                obj.decodeType = 0;
            end
        end
% Inputs:
%     r = a vector of either demodulated bits or complex numbers
% Outputs:
%     decodedMessage = a vector of message bits
        function decodedMessage = decodeMsg(obj, r)
            if obj.decodeType == 0
                decodedMessage = obj.decodeBitMessage(r);
            elseif obj.decodeType == 1
                decodedMessage = obj.decodeSymbMessage(r);
            else
                error('Incorrect decode type')
            end
            return
        end
            
        function decodedMessage = decodeBitMessage(obj, r)
            %For each pair of bits in m recieved
            computedMetrics = containers.Map(1:length(obj.states), cell(1,length(obj.states)));
            %Converting the recieved vector into per time transition cell
            % arrays
            if mod(length(r), obj.constellation.constBitSize) ~= 0 
                r = [r 0];
            end
            
            numberOfC = length(r) / obj.encoder.outLength;
            cs = transpose(reshape(r, [], numberOfC));
            for row = 1:size(cs,1)
                c = cs(row, :);
                clearBranchMetricMap(computedMetrics);
                %For each state at time = t in the trellis
                for state = obj.states
                    if state.reached
                       [pathMetric1, pathMetric2] = state.computePathMetric(c, obj.encoder);
                        % Path metric
                        % {memory contents, path, path metric} 
                        state_id = bi2de(pathMetric1{1},'left-msb') + 1;
                        currentMetric = computedMetrics(state_id);
                        if isempty(currentMetric) == 1
                            computedMetrics(state_id) = pathMetric1;
                        else
                            if currentMetric{3} >= pathMetric1{3}
                                 computedMetrics(state_id) = pathMetric1;
                            end
                        end
                        state_id = bi2de(pathMetric2{1},'left-msb') + 1;
                        currentMetric = computedMetrics(state_id);
                        if isempty(currentMetric) == 1
                            computedMetrics(state_id) = pathMetric2;
                        else
                            if currentMetric{3} >= pathMetric2{3}
                                 computedMetrics(state_id) = pathMetric2;
                            end
                        end  
                    end
                end
                %All Path metrics have been calculated and filtered
                %Need to apply changes
                
                for key = 1:length(obj.states)
                    pathMetric = computedMetrics(key);
                    % {memory contents, path, path metric}
                    if isempty(pathMetric) == 0
                        state = obj.states(key);
                        updatedState = state.updatePath(pathMetric);
                        obj.states(key) = updatedState;
                    end
                end
            end
            decodedMessage = findMessage(obj.states);
            obj.states = obj.start_states;
            return
        end
        
        function decodedMessage = decodeSymbMessage(obj, r)
            %For each pair of bits in m recieved
            computedMetrics = containers.Map(1:length(obj.states), cell(1,length(obj.states)));
            for index = 1:length(r)
                symb = r(index);
                clearBranchMetricMap(computedMetrics);
                %For each state at time = t in the trellis
                for state = obj.states
                    if state.reached
                       [pathMetric1, pathMetric2] = state.computePathMetricSymb(symb, obj.encoder, obj.constellation);
                        % Path metric
                        % {memory contents, path, path metric} 
                        state_id = bi2de(pathMetric1{1},'left-msb') + 1;
                        currentMetric = computedMetrics(state_id);
                        if isempty(currentMetric) == 1
                            computedMetrics(state_id) = pathMetric1;
                        else
                            if currentMetric{3} >= pathMetric1{3}
                                 computedMetrics(state_id) = pathMetric1;
                            end
                        end
                        state_id = bi2de(pathMetric2{1},'left-msb') + 1;
                        currentMetric = computedMetrics(state_id);
                        if isempty(currentMetric) == 1
                            computedMetrics(state_id) = pathMetric2;
                        else
                            if currentMetric{3} >= pathMetric2{3}
                                 computedMetrics(state_id) = pathMetric2;
                            end
                        end  
                    end
                end
                %All Path metrics have been calculated and filtered
                %Need to apply changes
                
                for key = 1:length(obj.states)
                    pathMetric = computedMetrics(key);
                    % {memory contents, path, path metric}
                    if isempty(pathMetric) == 0
                        state = obj.states(key);
                        updatedState = state.updatePath(pathMetric);
                        obj.states(key) = updatedState;
                    end
                end
            end
            decodedMessage = findMessage(obj.states);
            obj.states = obj.start_states;
            return
        end
    end
end

function states = computeStateMachine(encoder)
    D = 0:2^(encoder.encoderLength) - 1;
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
        if encoder.msgLength == 1
            [output, output_state] = encoder.functionHandler(current_state, 0);
            state_1 = {output_state, output, 0};
        else
            [output, output_state] = encoder.functionHandler(current_state, [0 0]);
            state_1 = {output_state, output, 0};
        end
        current_state = int_B(i, 1:end);
        if encoder.msgLength == 1
            [output, output_state] = encoder.functionHandler(current_state, 1);
            state_2 = {output_state, output, 1};
        else
            [output, output_state] = encoder.functionHandler(current_state, [1 1]);
            state_2 = {output_state, output, 1};
        end
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


