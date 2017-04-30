function [output, output_state] = G3Encode(input_state, message_bit)
    %State in vector form [m_i, m_i-1, m_i-2]
    output_state = [message_bit input_state(1:end-1)];
    c_1 = message_bit; % not certain if this is equivalent to unchecked (0)
    c_2 = mod(output_state(2),2);
    c_3 = mod(output_state(2) + output_state(3),2);
    output = [c_1 c_2 c_3];
    return
end





