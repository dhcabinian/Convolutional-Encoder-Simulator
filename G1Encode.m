function [output, output_state] = G1Encode(input_state, message_bit)
    %State in vector form [m_i, m_i-1, m_i-2]
    output_state = [message_bit input_state(1:end-1)];
    c_1 = mod(output_state(1) + output_state(3),2);
    c_2 = mod(output_state(1) + output_state(2)+ output_state(3),2);
    output = [c_1 c_2];
    return
end





