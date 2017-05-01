function [output, output_state] = G2Encode(input_state, message_bit)
    %State in vector form [m_i-1, m_i-2]
    output_state = [message_bit input_state];
    c_1 = mod(output_state(1) + output_state(3)+ output_state(6) + output_state(7)+ output_state(8),2);
    c_2 = mod(output_state(1) + output_state(2)+ output_state(3)+ output_state(4) + output_state(5)+ output_state(8) ,2);
    output = [c_1 c_2];
    output_state = output_state(1:end-1);
    return
end