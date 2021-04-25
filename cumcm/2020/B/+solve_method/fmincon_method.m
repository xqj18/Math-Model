classdef fmincon_method < util.abstract_strategory
    properties
        tree
    end
    methods
        function obj = fmincon_method(tree)
            obj.tree = tree;
        end
    end
    methods
        function best_sol = actions(obj, solve_obj, road)
            sp = road(1:end-1);
            ep = road(2:end);
            go_day = sum(obj.tree.G(sub2ind(size(obj.tree.G), sp, ep)))+1;
            wd_locals = nnz(ismember(road,obj.tree.ks_idx));
            rest_days = obj.tree.days - go_day;
            for i = 1 : wd_locals*3
                wd0 = unifrnd(1,rest_days,1,wd_locals);
                [x{i},fvl(i)] = fmincon(@(wd)-solve_method.fmincon_method.obj_fun(wd, road, solve_obj.data),wd0,...
                 ones(1,wd_locals), rest_days, [],[],1+zeros(1,wd_locals),rest_days+zeros(1,wd_locals));
            end
            [~,min_dx] = min(fvl);
            e_road = common_tool. solve_help.expand_route(road,...
                solve_obj.data, round(x{min_dx}));
            [best_sol.fvl, best_sol.tbl, best_sol.bys, best_sol.byf, best_sol.isw] = common_tool.Help.compute_best_solution(e_road, solve_obj.data);            
            solve_obj.best_sol = best_sol;
        end
    end
    methods(Static)
        function fvl = obj_fun(wd, road, data)
            wd = round(wd);
            e_road = common_tool. solve_help.expand_route(road,...
                data, wd);
            if length(e_road) > data.m
                fvl = 0;
            else
                fvl = common_tool.Help.compute_best_solution(e_road, data);
            end
        end
    end
end