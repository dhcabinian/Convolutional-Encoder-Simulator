classdef TrellisState
    properties
        id;
        state;
        path;
        path_metric;
        branches;
        reached;
    end
    
    methods
%         Inputs:
%             Branches = Branch object containing the 2 attached states from the state machine implementation
        function obj = TrellisState(state, branches)
            if (nargin > 0)
                obj.id = bi2de(state,'left-msb') + 1;
                if (bi2de(state,'left-msb') == 0)
                    obj.reached = true;
                else
                    obj.reached = false;
                end
                obj.state = state;
                obj.branches = branches;
                obj.path_metric = 0;
                obj.path = [];
            end
        end
%         Inputs
%             c =  codeword vector of size 2 or 3 (depending on constellation)
%             constellation =  constellation used to modulate
%         Outputs
%             Path Metrics for both states in form
%             {memory contents, m, path metric} 
%             Where memory contents = state
%             m = either 1 bit or 2 bits of message (depending on constellation
%             path metric = sum (hamming distance between recieved c and
%             state transition c )   
        function [pathMetric1, pathMetric2] = computePathMetric(obj, c, constellation)
            % Branch metric
            % {memory contents, m, branch metric} 
            % Path metric
            % {memory contents, path, path metric} 
            [branchMetric1, branchMetric2] = obj.branches.computeBranchMetric(c, constellation);
            pathMetric1 = branchMetric1;
            pathMetric1{3} = pathMetric1{3} + obj.path_metric;
            pathMetric1{2} = [obj.path branchMetric1{2}];
            pathMetric2 = branchMetric2;
            pathMetric2{3} = pathMetric2{3} + obj.path_metric;     
            pathMetric2{2} = [obj.path branchMetric2{2}];
            return
        end
        
        
%         Inputs
%             symb =  complex number representing symbol (depending on constellation)
%             constellation =  constellation used to modulate
%         Outputs
%             Path Metrics for both states in form
%             {memory contents, m, path metric} 
%             Where memory contents = state
%             m = either 1 bit or 2 bits of message (depending on constellation
%             path metric = sum (distance between recieved symbol and
%             actual constellation symbol)   
        function [pathMetric1, pathMetric2] = computePathMetricSymb(obj, symb, constellation)
            % Branch metric
            % {memory contents, m, branch metric} 
            % Path metric
            % {memory contents, path, path metric} 
            [branchMetric1, branchMetric2] = obj.branches.computeBranchMetricSymb(symb, constellation);
            pathMetric1 = branchMetric1;
            pathMetric1{3} = pathMetric1{3} + obj.path_metric;
            pathMetric1{2} = [obj.path branchMetric1{2}];
            pathMetric2 = branchMetric2;
            pathMetric2{3} = pathMetric2{3} + obj.path_metric;     
            pathMetric2{2} = [obj.path branchMetric2{2}];
            return
        end
        
        function obj = updatePath(obj, pathMetric)
            % Path metric
            % {memory contents, m, path metric} 
            if isequal(pathMetric{1}, obj.state)
                obj.path_metric = pathMetric{3};
                obj.path = pathMetric{2};
                obj.reached = true;
            else
                error('Error occured in TrellisState/updatePath')
                
            end
        end

    end
end
