function score = svm_fitness(x, p_train, t_train, p_test, t_test)
    c = x(1);
    g = x(2);
    cmd = ['-t 2 -c ', num2str(c), ' -g ', num2str(g), ' -s 3 -p 0.01'];
    model = svmtrain(t_train, p_train, cmd);
    [~, accuracy, ~] = svmpredict(t_test, p_test, model);
    score = -accuracy(1); % 负数，因为SSA是最小化算法
end
