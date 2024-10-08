function [c,g]=GWO(SearchAgents_no,Max_iter,lb,ub,dim,inputn_train,outputn_train,inputn_test,outputn_test)
fobj=@(x)svm_fitness(x,inputn_train,outputn_train,inputn_test,outputn_test);
% 初始化alpha, beta和delta的位置
Alpha_pos=zeros(1,dim);
Alpha_score=inf; % 对于最大化问题，将此值改为-inf

Beta_pos=zeros(1,dim);
Beta_score=inf; % 对于最大化问题，将此值改为-inf

Delta_pos=zeros(1,dim);
Delta_score=inf; % 对于最大化问题，将此值改为-inf

% 初始化搜索代理的位置
Positions=initialization(SearchAgents_no,dim,ub,lb);

Convergence_curve=zeros(1,Max_iter);

l=0;% 循环计数器

% 主循环
while l<Max_iter
    for i=1:size(Positions,1)  
        
       % 返回超出搜索空间边界的搜索代理
        Flag4ub=Positions(i,:)>ub;
        Flag4lb=Positions(i,:)<lb;
        Positions(i,:)=(Positions(i,:).*(~(Flag4ub+Flag4lb)))+ub.*Flag4ub+lb.*Flag4lb;               
        
        % 计算每个搜索代理的目标函数值
        fitness=fobj(Positions(i,:));
        
        % 更新Alpha, Beta和Delta
        if fitness<Alpha_score 
            Alpha_score=fitness; % 更新alpha
            Alpha_pos=Positions(i,:);
        end
        
        if fitness>Alpha_score && fitness<Beta_score 
            Beta_score=fitness; % 更新beta
            Beta_pos=Positions(i,:);
        end
        
        if fitness>Alpha_score && fitness>Beta_score && fitness<Delta_score 
            Delta_score=fitness; % 更新delta
            Delta_pos=Positions(i,:);
        end
    end
    
    
    a=2-l*((2)/Max_iter); % a线性减少，从2到0
    
    % 更新搜索代理的位置，包括omega
    for i=1:size(Positions,1)
        for j=1:size(Positions,2)     
                       
            r1=rand(); % r1是[0,1]范围内的随机数
            r2=rand(); % r2是[0,1]范围内的随机数
            
            A1=2*a*r1-a; % 方程(3.3)
            C1=2*r2; % 方程(3.4)
            
            D_alpha=abs(C1*Alpha_pos(j)-Positions(i,j)); % 方程(3.5)-部分1
            X1=Alpha_pos(j)-A1*D_alpha; % 方程(3.6)-部分1
                       
            r1=rand();
            r2=rand();
            
            A2=2*a*r1-a; % 方程(3.3)
            C2=2*r2; % 方程(3.4)
            
            D_beta=abs(C2*Beta_pos(j)-Positions(i,j)); % 方程(3.5)-部分2
            X2=Beta_pos(j)-A2*D_beta; % 方程(3.6)-部分2       
            
            r1=rand();
            r2=rand(); 
            
            A3=2*a*r1-a; % 方程(3.3)
            C3=2*r2; % 方程(3.4)
            
            D_delta=abs(C3*Delta_pos(j)-Positions(i,j)); % 方程(3.5)-部分3
            X3=Delta_pos(j)-A3*D_delta; % 方程(3.5)-部分3             
            
            Positions(i,j)=(X1+X2+X3)/3; % 方程(3.7)
            
        end
    end
    l=l+1;    
    Convergence_curve(l)=Alpha_score;
end

bestX=Alpha_pos;
c=bestX(1);
g=bestX(2);
