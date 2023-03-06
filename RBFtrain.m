
function optim
clc
clear all
close all;
%echo off;  % 禁止(或允许)在屏幕上显示批处理命令行off：表示禁止


tic, % 开始计时
% 这里其实就是分训练集和测试集，训练集有563个，测试机有6个，一共569个样本，输入样本有5个基因，输出为2，每个样本的位置和大小
% load guiyiresult1
load noNormaldata
% load Normaldata
xtrain=shuru'; % 把训练集拿出来，每一列是一个样本
ytrain = y1;     %对应的输出数据，矩阵名为y为568*2
yout1=ytrain(:,1)';  %精确位置---labal
yout2=ytrain(:,2)';  %精确大小---labal
%pausetime=0.1;  %%????
mm=1;
x_size=size(xtrain); %%% (5*563) 表示每个样本有五个基因，563个样本
num_in=x_size(1);% 这个就是样本的维度，也是样本的基因

%% 这个下面等看程序在解释
num_nod=200; % 基函数个数，就是隐含层节点个数
PopSize=30; % 种群数量 个体数量，一个种群有多个个体，个体可以理解为样本，样本是已经确定下来的
G=10;
amp=1; % 中心宽的的放大倍数
%a=0.85;
a=0.85; % adaption func 超参数
b=0.05; % adaption func 超参数
d=3; % adaption func 超参数

%G=1;
Codel=num_nod;  % 200 隐含层节点个数，
% 为什么要转为code1 而不是直接拿num_nod计算？？

% Control 控制基因---二进制数组，每一位代表一个隐层节点，1 表示这个节点激活，0表示休眠。 控制基因的位数 = 隐层节点个数
% 而我们知道每一个隐层节点都和基因相连，一个样本有五个基因，所以一个节点也会连5个基因
Control=round(rand(PopSize,Codel));   % 为30*200的矩阵值为0或者1。30个种群，每个种群都有很多个体以及它们的控制基因。种群个数 * 节点个数 = 30个种群总的基因位数矩阵
CodeL=num_in*num_nod;%1000 一个样本5个基因，一个节点控制5个基因，这里就表示一个样本受控制的总基因数
for i=1:PopSize % 种群循环
    select = xtrain(:,randperm(num_nod));  %初始化中心参数这个命令取x的任意由randperm产生的前i列的所有元素---30个种群，每个种群从训练集随机拿200个样本作为个体数
    % 200个样本对应200个神经元数
    for j=1:CodeL
        % 200个样本，每个样本5个基因，一共1000个基因，一个种群有1000个基因，一共30个种群
        Center(i,j)=select(j); %30*1000 select()为选择select矩阵中的第j（按列计算）个元素可以自己实验一下---30个种群，每个种群的所有基因组成矩阵。按照五个五个来每五个是一个样本
    end
end

% 这个没懂
% rand(PopSize,num_nod) 30*200 0-1
% 初始化宽度，amp为放大倍数
Spread=amp*rand(PopSize,num_nod)+ones(PopSize,num_nod);%%Spread代表宽度参数30*200在1到2之间（这里是初始化宽度矩阵）
%**********Start Running **********
for kg=1:1:G
    %**********Step1:Evaluate Best Fitness **********
    for i=1:1:PopSize
        NumNod(i)=length(find(Control(i,:))); % 统计激活参数基因的个数
        for j=1:1:num_nod % 200个神经元
            for t=1:1:num_in % 一个神经元对应5个基因，这个地方是基因循环1-5
                C(t,j)=Control(i,j)*Center(i,(j-1)*num_in+t);  % Control(i,j)决定神经元的激活和休眠状态
                % j=1 0*x1 0*x2 0*x3 0*x4 0*x5
                % j=2 1*x6 1*x7 1*x8 1*x9 1*x10
                %              .
                %              .
                %              .
                % C最终拿到的是，列表示200个神经元，hang表示5个基因，参数基因为0表示休眠状态，，这里就体现出了控制基因的作用
                % 最重要的是找到了中心向量！！！！！！！，C的每一列就是中心的坐标
            end
        end
        for j=1:1:num_nod
            % 看到Control(i,j)就要知道是一个筛选，过滤掉休眠的神经元
            B(j)=Spread(i,j).*Control(i,j)';   %1*100代表sigma宽度 过滤掉休眠的神经元对应的宽度，不参与计算
            if B(j)==0;B(j)=0.001;end % 拿到神经元所对应的宽度，每个神经元控制五个基因，对应一个样本，控制神经元的宽度就是控制样本宽度，这样样本宽度就拿到了
        end
        for k=1:1:x_size(2)   % 每一个样本单独处理
            for t=1:1:num_nod % 每个隐含层节点拿出来单独处理
                % 这样就拿到了每个样本，每个层节点
                % xtrain(:,k) 每一列是个样本
                % 样本1 神经元1 神经元2 ...
                % 样本2 神经元1 神经元2 ...
                % 下面的公式使用了 newrb 的exact 表达式，分母是带2的 样本数等于神经元数。countpart
                % approximate 神经元动态扩展，适用数据较多
                H(k,t)=Control(i,t)*exp(-norm(xtrain(:,k)-C(:,t))^2/(2*B(t)^2));%径向基函数的输出，这里多了一个Control(i,t)
                % 拿到每个样本经过激活函数输出值，接下来不出意外就要考虑权重了
            end
        end
        %a=pinv(H'*H)*(H'*yout');  % 200*1
        %b=Control(i,:)';             %200*1
        % H 563*200         pinv(H'*H) 200*200      H'*yout1' 200*1
        % H'的每一行表示200个样本在一个神经元的输出，因为后面要计算权重，是根据一个神经元的输出去计算的
        % A*W=Y   W=A-1*Y  W = (AT * A)-1 * AT * Y ---A 输入 Y 输出
        W1(:,i)=pinv(H'*H)*(H'*yout1').*Control(i,:)'; % 位置权---这个是训练出来的权
        W2(:,i)=pinv(H'*H)*(H'*yout2').*Control(i,:)'; % 大小权
        ymout1(i,:)=(H*W1(:,i))';                     %结果*权重就是输出， 训练位置输出
        ymout2(i,:)=(H*W2(:,i))';                     %训练大小输出
        error1(i,:)=sumsqr(yout1-ymout1(i,:));
        error2(i,:)=sumsqr(yout2-ymout2(i,:));
        BsJi(i)=(error1(i,:)+error2(i,:))/x_size(2);      %均方误差
        
        
        ff(i)=2*x_size(2)/((a+b*exp(NumNod(i)/(d*6)))*BsJi(i)); %% adaption func
        
        if BsJi(i)<0.00001
            kg=kg-1;break % 误差已经非常小了，直接break？别的种群不管了？这个好像可以直接选出最优种群？
        end
        %ff(i)=-(x_size(2)*log(BsJi(i))+4*NumNod(i))+5000;
        %ff(i)=1/(BsJi(i)+1+4*NumNod(i));
        % n = 6 why?
    end
    % 最优---均方误差最小
    [OderJi,IndexJi]=sort(BsJi);% 按由小到大的顺序排列BsJi的值（OderJi），IndexJi是相应的序号；
    BestJ(kg)=OderJi(1);        % 得到最小均方差
    fi=ff; % 不破坏原本的适应度
    [Oderfi,Indexfi]=sort(fi);
    Bestfi(kg)=Oderfi(PopSize); % 得到最佳适应度种群
    BestS=Center(Indexfi(PopSize),:); % 得到最佳种群的所有样本
    BestSpread=Spread(Indexfi(PopSize),:); % 得到最佳种群的所有神经元
    BestControl=Control(Indexfi(PopSize),:); % 得到最佳种群的控制基因
    BestW1=W1(:,Indexfi(PopSize)); % 最佳种群的位置权
    BestW2=W2(:,Indexfi(PopSize)); % 最佳种群的大小权
    FNumNod(kg)=length(find(BestControl)); % 最佳种群的激活基因数
    %if kg==mm*5
    %    plot([yout1' ymout1(Indexfi(PopSize),:)']);
    %    plot([yout2' ymout2(Indexfi(PopSize),:)']);
    %    pause2(pausetime);mm=mm+1;
    %end
    %*********** Step2 : Select and Reproduct Operatin ***********
    FitSum=sum(fi);
    FitSize=(Oderfi/FitSum)*PopSize;
    AverFi=FitSum/PopSize;
    meanfi(kg)=AverFi;
    fi_S=round(FitSize);
    r=PopSize-sum(fi_S);
    if r==0,r=1;end
    Rest=FitSize-fi_S;
    [RestValue,Index]=sort(Rest);
    for i=PopSize:-1:PopSize-r
        fi_S(Index(i))=fi_S(Index(i))+1; %Adding rest to equal PopSize
    end
    k=1;
    for i=PopSize:-1:1
        for j=1:1:fi_S(i)
            TempE(k,:)=Center(Indexfi(i),:);  % Select and Reproduce
            TempC(k,:)=Control(Indexfi(i),:);
            TempS(k,:)=Spread(Indexfi(i),:);
            k=k+1;if k>PopSize,k=k-1;break,end  % k is sued to reproduce
        end
    end
    %*********** Step3 : Crossover Operatin ***********
    Pc1=0.9;Pc2=0.5;
    for i=1:2:(PopSize-1)
        fc=max(fi(i),fi(i+1));
        if fc>AverFi
            Pc=Pc1-(Pc1-Pc2)*(fc-AverFi)/(Bestfi(kg)-AverFi);
            % Pc=Pc1-(Pc1-Pc2)*(Bestfi(kg)-fc)/(Bestfi(kg)-AverFi);
        else
            Pc=Pc1;
        end
        temp=rand;
        if Pc>temp
            n=round((Codel-2)*rand)+1;
            for j=n:1:Codel
                TempC(i,j)=Control(i+1,j);
                TempC(i+1,j)=Control(i,j);
            end
            alfa=rand;
            TempE(i,:)=alfa*Center(i+1,:)+(1-alfa)*Center(i,:);
            TempE(i+1,:)=(1-alfa)*Center(i+1,:)+alfa*Center(i,:);  %可能有问题
            TempS(i,:)=alfa*Spread(i+1,:)+(1-alfa)*Spread(i,:);
            TempS(i+1,:)=(1-alfa)*Spread(i+1,:)+alfa*Spread(i,:);
        end
    end
    TempE(PopSize,:)=BestS;           %中心
    TempC(PopSize,:)=BestControl;     %控制基因
    TempS(PopSize,:)=BestSpread;      %宽度
    Control=TempC;
    Center=TempE;
    Spread=TempS;
    %*********** Step3 : Mutation Operatin ***********
    Pm1=0.1;Pm2=0.001;
    for i=1:1:PopSize
        fm=fi(i);
        if fm>AverFi
            Pm=Pm1-(Pm1-Pm2)*(Bestfi(kg)-fm)/(Bestfi(kg)-AverFi);
        else
            Pm=Pm1;
        end
        temp=rand;
        for n=1:1:Codel
            if Pm>temp
                if TempC(i,n)==0
                    TempC(i,n)=1;
                else
                    TempC(i,n)=0;
                end
            end
        end
        for j=1:1:CodeL
            if Pm>temp
                TempE(i,j)=min(min(xtrain))+rand*(max(max(xtrain))-min(min(xtrain)));
            end
        end
        for j=1:1:num_nod
            if Pm>temp
                TempS(i,j)=1+amp*rand;
            end
        end
    end
    TempE(PopSize,:)=BestS;
    TempC(PopSize,:)=BestControl;
    TempS(PopSize,:)=BestSpread;
    Control=TempC;
    Center=TempE;
    Spread=TempS;
    gen=kg
end
sse=BestJ(kg)*x_size(2)
mses=sqrt(BestJ(kg))
plot(yout1-ymout1(Indexfi(PopSize),:));
figure;plot(yout1),hold on,plot(ymout1(Indexfi(PopSize),:),'r--');
legend('Original','RBF out');
figure;plot(FNumNod);
figure;plot(Bestfi);hold on,plot(meanfi,'r--');
figure,plot(BestJ.*length(yout1));


save TrainResult2 BestS BestW1 BestW2 BestControl BestSpread num_nod num_in
biaozhi='finished'
toc;



