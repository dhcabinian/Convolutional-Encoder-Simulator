classdef TrellisState
    properties
        id;
        state;
        pathToThisPoint;
        path_metric=0;
        branches;
    end
    
    methods
        function obj = TrellisState(state, branches)
            if (nargin > 0)
                obj.id = bi2de(state) + 1;
                obj.state = state;
                obj.branches = branches;
                obj.path_metric = 0;
                obj.pathToThisPoint = [];
            end
        end

        
        function new_path_metric = compute_hard_path_metric(s)
            
            
        end
        
        function new_path_metric = compute_soft_path_metric(r)
            sigma = ?
            r = ?
            alpha= ?
            new_path_metric = log(1/(sqrt(2*pi)*sigma))*exp(-1*((mag(r-s))^2)/(2*sigma^2))*alpha-((mag(r-s))^2);
        end
    end
end
