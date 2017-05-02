classdef Branches
    properties
        current_state;
        state_1;
        state_1_c;
        state_1_m;
        state_2;
        state_2_c;
        state_2_m;
    end
    methods
        function obj = Branches(current_state, state_1, state_2)
            %States in cell array in format
            % {memory contents, c, m}
            obj.current_state = current_state;
            obj.state_1 = state_1{1};
            obj.state_1_c = state_1{2};
            obj.state_1_m = state_1{3};
            obj.state_2 = state_2{1};
            obj.state_2_c = state_2{2};
            obj.state_2_m = state_2{3};           
        end
        
        function bool = doesConnect(obj, state)
            if (obj.state_1 == state || obj.state_2 == state)
                bool = true;
                return 
            end
            bool = false;
            return
        end
        
        function branch_state = getState(obj, state)
            if (obj.state_1 == state)
                branch_state = {obj.state_1, obj.state_1_c, obj.state_1_m};
                return
            elseif(obj.state_2 == state)   
                branch_state = {obj.state_2, obj.state_2_c, obj.state_2_m};
                return
            end
            branch_state = {};
            return          
        end
        
%         Inputs
%             c =  codeword vector of size 2 or 3 (depending on constellation)
%             constellation =  constellation used to modulate
%         Outputs
%             Branch Metrics for both states in form
%             {memory contents, m, branch metric} 
%             Where memory contents = state
%             m = either 1 bit or 2 bits of message (depending on constellation
%             branch metric = hamming distance between recieved c and state
%             transition c         
        function [branchMetric1, branchMetric2] = computeBranchMetric(obj, c, constellation)
            if constellation.constBitSize == 3
                uncheckedMsgBit = c(1);
                c_remain = c(2:end);
                %Compute branch 1 first
                branchMetricState1 = sum(xor(c_remain, obj.state_1_c));
                %Compute branch 2 first
                branchMetricState2 = sum(xor(c_remain, obj.state_2_c));           
                %States in cell array in format
                % {memory contents, m, branch metric} 
                branchMetric1 = {obj.state_1, [uncheckedMsgBit obj.state_1_m], branchMetricState1};
                branchMetric2 = {obj.state_2, [uncheckedMsgBit obj.state_2_m], branchMetricState2};
                return 
            else
                %Compute branch 1 first
                branchMetricState1 = sum(xor(c, obj.state_1_c));
                %Compute branch 2 first
                branchMetricState2 = sum(xor(c, obj.state_2_c));           
                %States in cell array in format
                % {memory contents, m, branch metric} 
                branchMetric1 = {obj.state_1, obj.state_1_m, branchMetricState1};
                branchMetric2 = {obj.state_2, obj.state_2_m, branchMetricState2};
                return 
            end
        end
%         Inputs
%             symb =  constellation symbol in complex number format
%             constellation =  constellation used to modulate
%         Outputs
%             Branch Metrics for both states in form
%             {memory contents, m, branch metric} 
%             Where memory contents = state
%             m = either 1 bit or 2 bits of message (depending on constellation
%             branch metric = symbol distance between recieved c and state
%             transition c          
        function [branchMetric1, branchMetric2] = computeBranchMetricSymb(obj, symb, constellation)
            decState1 = bi2de(obj.state_1_c,'left-msb');
            decState2 = bi2de(obj.state_2_c,'left-msb');
            compState1 = constellation.bitKeyMapping(decState1);
            compState2 = constellation.bitKeyMapping(decState2);
            branchMetricState1 = (abs(compState1 - symb))^2;
            branchMetricState2 = (abs(compState2 - symb))^2;
            if constellation.constBitSize == 3
                %States in cell array in format
                % {memory contents, m, branch metric} 
                branchMetric1 = {obj.state_1, [obj.state_1_c(1) obj.state_1_m], branchMetricState1};
                branchMetric2 = {obj.state_2, [obj.state_2_c(1) obj.state_2_m], branchMetricState2};                
            else
                %States in cell array in format
                % {memory contents, m, branch metric} 
                branchMetric1 = {obj.state_1, obj.state_1_m, branchMetricState1};
                branchMetric2 = {obj.state_2, obj.state_2_m, branchMetricState2};
                return 
            end
        end
    end
end