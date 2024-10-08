% 该函数初始化搜索代理的初始种群
function Positions=initialization(SearchAgents_no,dim,ub,lb)

Boundary_no= size(ub,1); % 边界数量

% 如果所有变量的边界相等且用户输入单个值作为ub和lb
if Boundary_no==1
    Positions=rand(SearchAgents_no,dim).*(ub-lb)+lb;
end

% 如果每个变量有不同的lb和ub
if Boundary_no>1
    for i=1:dim
        ub_i=ub(i);
        lb_i=lb(i);
        Positions(:,i)=rand(SearchAgents_no,1).*(ub_i-lb_i)+lb_i;
    end
end
