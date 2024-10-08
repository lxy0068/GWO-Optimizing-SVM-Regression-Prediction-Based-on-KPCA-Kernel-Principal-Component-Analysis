    function Z=KPCA(X,N)
        data_get=X;
        data_get=data_get(:,1:end-1);
        [Xrow, Xcol] = size(data_get);    % Xrow：样本个数 Xcol：样本属性个数
        %%数据预处理
        Xmean = mean(data_get); % 求原始数据的均值
        Xstd = std(data_get); % 求原始数据的方差
        X0 = (data_get-ones(Xrow,1)*Xmean) ./ (ones(Xrow,1)*Xstd); % 标准阵X0,标准化为均值0，方差1;
        c = 14000; %此参数可调
        %%求核矩阵
        for i = 1 : Xrow
        for j = 1 : Xrow
        %k(i,j)=kernel(data(i,:),data(j,:),2,6);   
        K(i,j) = exp(-(norm(X0(i,:) - X0(j,:)))^2/c);%求核矩阵，采用径向基核函数，参数c
        end
        end
        %%中心化矩阵
        unit = (1/Xrow) * ones(Xrow, Xrow);
        Kp = K - unit*K - K*unit + unit*K*unit; % 中心化矩阵
        %%特征值分解
        [eigenvector, eigenvalue] = eig(Kp); % 求协方差矩阵的特征向量（eigenvector）和特征值（eigenvalue）
        %单位化特征向量
        for m =1 : Xrow
        for n =1 : Xrow
        Normvector(n,m) = eigenvector(n,m)/sum(eigenvector(:,m));
        end
        end
        eigenvalue_vec = real(diag(eigenvalue)); %将特征值矩阵转换为向量
        [eigenvalue_sort, index] = sort(eigenvalue_vec, 'descend'); % 特征值按降序排列，eigenvalue_sort是排列后的数组，index是序号
        pcIndex = []; % 记录主元所在特征值向量中的序号
        pcn = N;
        for k = 1 : pcn % 特征值个数
        pcIndex(k) = index(k); % 保存主元序号
        end
        for i = 1 : pcn
        pc_vector(i) = eigenvalue_vec(pcIndex(i)); % 主元向量
        P(:, i) = Normvector(:, pcIndex(i)); % 主元所对应的特征向量（负荷向量）
        end
        Z=P;
    end