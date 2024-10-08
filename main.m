%%  ��ջ�������
warning off             % �رձ�����Ϣ
close all               % �رտ�����ͼ��
clear                   % ��ձ���
clc                     % ���������

%%  ��������
res = xlsread('����.xlsx');
num_samples = size(res, 1);                  % ��������
res = res(randperm(num_samples), :);         % �������ݼ�����ϣ������ʱ��ע�͸��У�
X =res(:,1:end-1);
Y =res(:,end);
%% ����Ҫ��ά����ע���¶δ���  
% KPCA��άά��
d=6;% ������ʵ������޸�

%% ���ݽ�ά����
Z=KPCA(X,d);   %KPCA��ά	


input=Z(:,1:end);
output=Y;
combined_data = [input, output];
res=combined_data;
%%  ����Ҫ��ά����ע���϶δ���  
%%  ����ѵ�����Ͳ��Լ�
data_num = 103; %���ݵ�����
train_ratio = 0.8; %ѵ��������


%temp = randperm(data_num);
temp = 1:data_num;

P_train = res(temp(1: floor(data_num*train_ratio)), 1: end-1)';
T_train = res(temp(1: floor(data_num*train_ratio)), end)';
M = size(P_train, 2);

P_test = res(temp(floor(data_num*train_ratio)+1: end), 1: end-1)';
T_test = res(temp(floor(data_num*train_ratio)+1: end), end)';
N = size(P_test, 2);

%%  ���ݹ�һ��
[p_train, ps_input] = mapminmax(P_train, 0, 1);
p_test = mapminmax('apply', P_test, ps_input);

[t_train, ps_output] = mapminmax(T_train, 0, 1);
t_test = mapminmax('apply', T_test, ps_output);

%%  ת������Ӧģ��
p_train = p_train'; p_test = p_test';
t_train = t_train'; t_test = t_test';

%%  ����ģ��
% c = 0.0329;    % �ͷ�����10 �Ż��õ��Ĳ���2.3984
% g = 0.9;    % �������������0.7 �Ż��õ��Ĳ���0.7668
%% ģ��ѵ����Ԥ��
SearchAgents_no=3; 
Max_iteration=10;
dim=2; 
lb=[0.001,0.001];%��������
ub=[450,0.9];%��������
type = 'function estimation';
%% c��gѰ��
[c,g]=GWO(SearchAgents_no,Max_iteration,lb,ub,dim,p_train,t_train,p_test,t_test);  %%�Ż��㷨

cmd = [' -t 2',' -c ',num2str(c),' -g ',num2str(g),' -s 3 -p 0.01'];
model = svmtrain(t_train, p_train, cmd);

%%  ����Ԥ��
[t_sim1, error_1] = svmpredict(t_train, p_train, model);
[t_sim2, error_2] = svmpredict(t_test , p_test , model);

%%  ���ݷ���һ��
T_sim1 = mapminmax('reverse', t_sim1, ps_output);
T_sim2 = mapminmax('reverse', t_sim2, ps_output);

%%  ���������
error1 = sqrt(sum((T_sim1' - T_train).^2) ./ M);
error2 = sqrt(sum((T_sim2' - T_test ).^2) ./ N);

%%  ��ͼ
figure
plot(1: M, T_train, 'r-*', 1: M, T_sim1, 'b-o', 'LineWidth', 1)
legend('��ʵֵ', 'Ԥ��ֵ')
xlabel('Ԥ������')
ylabel('Ԥ����')
string = {'ѵ����Ԥ�����Ա�'; ['RMSE=' num2str(error1)]};
title(string)
xlim([1, M])
grid

figure
plot(1: N, T_test, 'r-*', 1: N, T_sim2, 'b-o', 'LineWidth', 1)
legend('��ʵֵ', 'Ԥ��ֵ')
xlabel('Ԥ������')
ylabel('Ԥ����')
string = {'���Լ�Ԥ�����Ա�'; ['RMSE=' num2str(error2)]};
title(string)
xlim([1, N])
grid

%%  ���ָ�����
% R2
R1 = 1 - norm(T_train - T_sim1')^2 / norm(T_train - mean(T_train))^2;
R2 = 1 - norm(T_test  - T_sim2')^2 / norm(T_test  - mean(T_test ))^2;

disp(['ѵ�������ݵ�R2Ϊ��', num2str(R1)])
disp(['���Լ����ݵ�R2Ϊ��', num2str(R2)])

% MAE
mae1 = sum(abs(T_sim1' - T_train)) ./ M ;
mae2 = sum(abs(T_sim2' - T_test )) ./ N ;

disp(['ѵ�������ݵ�MAEΪ��', num2str(mae1)])
disp(['���Լ����ݵ�MAEΪ��', num2str(mae2)])

% MBE
mbe1 = sum(T_sim1' - T_train) ./ M ;
mbe2 = sum(T_sim2' - T_test ) ./ N ;

disp(['ѵ�������ݵ�MBEΪ��', num2str(mbe1)])
disp(['���Լ����ݵ�MBEΪ��', num2str(mbe2)])

%  RMSE
disp(['ѵ�������ݵ�RMSEΪ��', num2str(error1)])
disp(['���Լ����ݵ�RMSEΪ��', num2str(error2)])

%%  ����ɢ��ͼ����ʾ���ϵ��
sz = 25; % ��Ĵ�С
c = 'b'; % �����ɫ

% ����ѵ������ɢ��ͼ
figure
scatter(T_train, T_sim1, sz, c, 'filled')
hold on

% ��������
coefficients = polyfit(T_train, T_sim1, 1);
fittedX = linspace(min(T_train), max(T_train), 200);
fittedY = polyval(coefficients, fittedX);
plot(fittedX, fittedY, 'b-', 'LineWidth', 1)

% ���y=x��
plot([min(T_train), max(T_train)], [min(T_train), max(T_train)], '--k')

% ����ͼ���ǩ�ͱ���
xlabel('ѵ������ʵֵ')
ylabel('ѵ����Ԥ��ֵ')
xlim([min(T_train) max(T_train)])
ylim([min(T_sim1) max(T_sim1)])
title(['ѵ���� R=' num2str(R1,2)])

% ���ͼ��
legend('����', '���', 'Y=T')

hold off

% ���Ʋ��Լ���ɢ��ͼ
figure
scatter(T_test, T_sim2, sz, c, 'filled')
hold on

% ��������
coefficients = polyfit(T_test, T_sim2, 1);
fittedX = linspace(min(T_test), max(T_test), 200);
fittedY = polyval(coefficients, fittedX);
plot(fittedX, fittedY, 'b-', 'LineWidth', 1)

% ���y=x��
plot([min(T_test), max(T_test)], [min(T_test), max(T_test)], '--k')

% ����ͼ���ǩ�ͱ���
xlabel('���Լ���ʵֵ')
ylabel('���Լ�Ԥ��ֵ')
xlim([min(T_test) max(T_test)])
ylim([min(T_sim2) max(T_sim2)])
title(['���Լ� R=' num2str(R2,2)])

% ���ͼ��
legend('����', '���', 'Y=T')
hold off

%% ����ѵ����Ԥ��������ͼ
figure;
train_errors = T_sim1' - T_train; % ����ѵ����Ԥ�����
plot(1:M, train_errors, 'r-*', 'LineWidth', 1); % M is the number of training points
title(['ѵ����Ԥ��������ͼ R=' num2str(R1,2)]);
xlabel('�������');
ylabel('Ԥ�����');
xlim([1, M]); % ��ȷ����x��ķ�ΧΪѵ�����ݵ������
grid on;

%% ���Ʋ��Լ�Ԥ��������ͼ
figure;
test_errors = T_sim2' - T_test; % ������Լ�Ԥ�����
plot(1:N, test_errors, 'b-o', 'LineWidth', 1); % N is the number of testing points
title(['���Լ�Ԥ��������ͼ R=' num2str(R2,2)]);
xlabel('�������');
ylabel('Ԥ�����');
xlim([1, N]); % ��ȷ����x��ķ�ΧΪ�������ݵ������
grid on;