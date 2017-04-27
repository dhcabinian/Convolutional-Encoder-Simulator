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
        
        
    end
end