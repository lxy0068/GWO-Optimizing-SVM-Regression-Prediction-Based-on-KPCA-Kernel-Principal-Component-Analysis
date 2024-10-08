%%  清空环境变量
warning off             % 关闭报警信息
close all               % 关闭开启的图窗
clear                   % 清空变量
clc                     % 清空命令行

%%  导入数据
res = xlsread('数据.xlsx');
num_samples = size(res, 1);                  % 样本个数
res = res(randperm(num_samples), :);         % 打乱数据集（不希望打乱时，注释该行）
X =res(:,1:end-1);
Y =res(:,end);
%% 不需要降维可以注释下段代码  
% KPCA降维维数
d=6;% 这块根据实际情况修改

%% 数据降维处理
Z=KPCA(X,d);   %KPCA降维	


input=Z(:,1:end);
output=Y;
combined_data = [input, output];
res=combined_data;
%%  不需要降维可以注释上段代码  
%%  划分训练集和测试集
data_num = 103; %数据点数量
train_ratio = 0.8; %训练集比例


%temp = randperm(data_num);
temp = 1:data_num;

P_train = res(temp(1: floor(data_num*train_ratio)), 1: end-1)';
T_train = res(temp(1: floor(data_num*train_ratio)), end)';
M = size(P_train, 2);

P_test = res(temp(floor(data_num*train_ratio)+1: end), 1: end-1)';
T_test = res(temp(floor(data_num*train_ratio)+1: end), end)';
N = size(P_test, 2);

%%  数据归一化
[p_train, ps_input] = mapminmax(P_train, 0, 1);
p_test = mapminmax('apply', P_test, ps_input);

[t_train, ps_output] = mapminmax(T_train, 0, 1);
t_test = mapminmax('apply', T_test, ps_output);

%%  转置以适应模型
p_train = p_train'; p_test = p_test';
t_train = t_train'; t_test = t_test';

%%  创建模型
% c = 0.0329;    % 惩罚因子10 优化得到的参数2.3984
% g = 0.9;    % 径向基函数参数0.7 优化得到的参数0.7668
%% 模型训练与预测
SearchAgents_no=3; 
Max_iteration=10;
dim=2; 
lb=[0.001,0.001];%参数下限
ub=[450,0.9];%参数上限
type = 'function estimation';
%% c和g寻优
[c,g]=GWO(SearchAgents_no,Max_iteration,lb,ub,dim,p_train,t_train,p_test,t_test);  %%优化算法

cmd = [' -t 2',' -c ',num2str(c),' -g ',num2str(g),' -s 3 -p 0.01'];
model = svmtrain(t_train, p_train, cmd);

%%  仿真预测
[t_sim1, error_1] = svmpredict(t_train, p_train, model);
[t_sim2, error_2] = svmpredict(t_test , p_test , model);

%%  数据反归一化
T_sim1 = mapminmax('reverse', t_sim1, ps_output);
T_sim2 = mapminmax('reverse', t_sim2, ps_output);

%%  均方根误差
error1 = sqrt(sum((T_sim1' - T_train).^2) ./ M);
error2 = sqrt(sum((T_sim2' - T_test ).^2) ./ N);

%%  绘图
figure
plot(1: M, T_train, 'r-*', 1: M, T_sim1, 'b-o', 'LineWidth', 1)
legend('真实值', '预测值')
xlabel('预测样本')
ylabel('预测结果')
string = {'训练集预测结果对比'; ['RMSE=' num2str(error1)]};
title(string)
xlim([1, M])
grid

figure
plot(1: N, T_test, 'r-*', 1: N, T_sim2, 'b-o', 'LineWidth', 1)
legend('真实值', '预测值')
xlabel('预测样本')
ylabel('预测结果')
string = {'测试集预测结果对比'; ['RMSE=' num2str(error2)]};
title(string)
xlim([1, N])
grid

%%  相关指标计算
% R2
R1 = 1 - norm(T_train - T_sim1')^2 / norm(T_train - mean(T_train))^2;
R2 = 1 - norm(T_test  - T_sim2')^2 / norm(T_test  - mean(T_test ))^2;

disp(['训练集数据的R2为：', num2str(R1)])
disp(['测试集数据的R2为：', num2str(R2)])

% MAE
mae1 = sum(abs(T_sim1' - T_train)) ./ M ;
mae2 = sum(abs(T_sim2' - T_test )) ./ N ;

disp(['训练集数据的MAE为：', num2str(mae1)])
disp(['测试集数据的MAE为：', num2str(mae2)])

% MBE
mbe1 = sum(T_sim1' - T_train) ./ M ;
mbe2 = sum(T_sim2' - T_test ) ./ N ;

disp(['训练集数据的MBE为：', num2str(mbe1)])
disp(['测试集数据的MBE为：', num2str(mbe2)])

%  RMSE
disp(['训练集数据的RMSE为：', num2str(error1)])
disp(['测试集数据的RMSE为：', num2str(error2)])

%%  绘制散点图并显示相关系数
sz = 25; % 点的大小
c = 'b'; % 点的颜色

% 绘制训练集的散点图
figure
scatter(T_train, T_sim1, sz, c, 'filled')
hold on

% 添加拟合线
coefficients = polyfit(T_train, T_sim1, 1);
fittedX = linspace(min(T_train), max(T_train), 200);
fittedY = polyval(coefficients, fittedX);
plot(fittedX, fittedY, 'b-', 'LineWidth', 1)

% 添加y=x线
plot([min(T_train), max(T_train)], [min(T_train), max(T_train)], '--k')

% 设置图表标签和标题
xlabel('训练集真实值')
ylabel('训练集预测值')
xlim([min(T_train) max(T_train)])
ylim([min(T_sim1) max(T_sim1)])
title(['训练集 R=' num2str(R1,2)])

% 添加图例
legend('数据', '拟合', 'Y=T')

hold off

% 绘制测试集的散点图
figure
scatter(T_test, T_sim2, sz, c, 'filled')
hold on

% 添加拟合线
coefficients = polyfit(T_test, T_sim2, 1);
fittedX = linspace(min(T_test), max(T_test), 200);
fittedY = polyval(coefficients, fittedX);
plot(fittedX, fittedY, 'b-', 'LineWidth', 1)

% 添加y=x线
plot([min(T_test), max(T_test)], [min(T_test), max(T_test)], '--k')

% 设置图表标签和标题
xlabel('测试集真实值')
ylabel('测试集预测值')
xlim([min(T_test) max(T_test)])
ylim([min(T_sim2) max(T_sim2)])
title(['测试集 R=' num2str(R2,2)])

% 添加图例
legend('数据', '拟合', 'Y=T')
hold off

%% 绘制训练集预测绝对误差图
figure;
train_errors = T_sim1' - T_train; % 计算训练集预测误差
plot(1:M, train_errors, 'r-*', 'LineWidth', 1); % M is the number of training points
title(['训练集预测绝对误差图 R=' num2str(R1,2)]);
xlabel('样本编号');
ylabel('预测误差');
xlim([1, M]); % 正确设置x轴的范围为训练数据点的数量
grid on;

%% 绘制测试集预测绝对误差图
figure;
test_errors = T_sim2' - T_test; % 计算测试集预测误差
plot(1:N, test_errors, 'b-o', 'LineWidth', 1); % N is the number of testing points
title(['测试集预测绝对误差图 R=' num2str(R2,2)]);
xlabel('样本编号');
ylabel('预测误差');
xlim([1, N]); % 正确设置x轴的范围为测试数据点的数量
grid on;