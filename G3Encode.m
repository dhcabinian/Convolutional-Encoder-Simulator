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





