classdef ConvEncode
    properties
        functionHandler;
        encoderLength;
        msgLength;
        inputState;
    end
    
    methods
        function obj = ConvEncode(type)
            if strcmp(type,'G1')
                obj.functionHandler = @G1Encode;
                obj.encoderLength = 3;
                obj.msgLength = 1;
                obj.inputState = zeros(1,obj.encoderLength);
            elseif strcmp(type,'G2')
                obj.functionHandler = @G2Encode;
                obj.encoderLength = 8;
                obj.msgLength = 1;
                obj.inputState = zeros(1,obj.encoderLength);                
            elseif strcmp(type,'G3')
                obj.functionHandler = @G2Encode;
                obj.encoderLength = 3;
                obj.msgLength = 2;
                obj.inputState = zeros(1,obj.encoderLength);               
            end
        end
        
        
        function encodedMsg = encodeMsg(obj, msg)
            state = obj.inputState;
            while mod(length(msg), obj.msgLength) ~= 0
                msg = [msg 0];
            end
            encodedMsg = [];
            numberOfMsgs = length(msg) / obj.msgLength;
            msgs = transpose(reshape(msg, [], numberOfMsgs));
            for row = 1:size(msgs,1)
                msg_bits = msgs(row, :);
                [codeword, state] = obj.functionHandler(state, msg_bits);
                encodedMsg = [encodedMsg codeword];
            end
            return
        end
        
        function [codeword, output_state] = encode(obj, input_state, msg_bits)
            [codeword, output_state] = obj.functionHandler(input_state, msg_bits);
            return
        end
    end
end

%Inputs:
%Single Message bit
%Input sate in form [m_i-1, m_i-2]
%Outputs:
%An array of [c_1 c_2]
%Output state in form [m_i-1, m_i-2]
function [output, output_state] = G1Encode(input_state, message_bit)
    %State in vector form [m_i-1, m_i-2]
    output_state = [message_bit input_state];
    c_1 = mod(output_state(1) + output_state(3),2);
    c_2 = mod(output_state(1) + output_state(2)+ output_state(3),2);
    output = [c_1 c_2];
    output_state = output_state(1:end-1);
    return
end

%Inputs:
%Single Message bit
%Input sate in form [m_i-1, m_i-2]
%Outputs:
%An array of [c_1 c_2]
%Output state in form [m_i-1, m_i-2]
function [output, output_state] = G2Encode(input_state, message_bit)
    %State in vector form [m_i-1, m_i-2]
    output_state = [message_bit input_state];
    c_1 = mod(output_state(1) + output_state(3)+ output_state(6) + output_state(7)+ output_state(8),2);
    c_2 = mod(output_state(1) + output_state(2)+ output_state(3)+ output_state(4) + output_state(5)+ output_state(8) ,2);
    output = [c_1 c_2];
    output_state = output_state(1:end-1);
    return
end

% Notes:
% First bit of codeword is unchecked in this encoder
% Inputs:
% Single Message bit
% Input sate in form [m_i-1, m_i-2]
% Outputs:
% An array of [c_1 c_2 c_3]
% Output state in form [m_i-1, m_i-2]
function [output, output_state] = G3Encode(input_state, message_bits)
    %State in vector form [m_i-1, m_i-2]
    output_state = [message_bits(2) input_state];
    c_1 = message_bits(1); % not certain if this is equivalent to unchecked (0)
    c_2 = mod(output_state(1) + output_state(3),2);
    c_3 = mod(output_state(2),2);
    output = [c_1 c_2 c_3];
    output_state = output_state(1:end-1);
    return
end





