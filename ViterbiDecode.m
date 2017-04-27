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
      
        function decodeC()
            
        end
        
        function decodeMessage()
            
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
            int_B(i,j) = str2double(B(i,j));
        end
    end

    states = [];

    for i = 1:cols
        current_state = int_B(i, 1:end);
        output, output_state = fhEncode(current_state, 0);
        state_1 = {output_state, output, 0};
        output, output_state = fhEncode(current_state, 1);
        state_2 = {output_state, output, 0};
        branches = branches(current_state, state_1, state_2);
        state = trellis_state(current_state, branches);
        states = [states state];
    end

    return 
end