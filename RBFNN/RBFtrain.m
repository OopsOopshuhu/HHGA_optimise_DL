
function optim
clc
clear all
close all;
%echo off;  % ��ֹ(������)����Ļ����ʾ������������off����ʾ��ֹ


tic, % ��ʼ��ʱ
% ������ʵ���Ƿ�ѵ�����Ͳ��Լ���ѵ������563�������Ի���6����һ��569������������������5���������Ϊ2��ÿ��������λ�úʹ�С
% load guiyiresult1
load noNormaldata
% load Normaldata
xtrain=shuru'; % ��ѵ�����ó�����ÿһ����һ������
ytrain = y1;     %��Ӧ��������ݣ�������ΪyΪ568*2
yout1=ytrain(:,1)';  %��ȷλ��---labal
yout2=ytrain(:,2)';  %��ȷ��С---labal
%pausetime=0.1;  %%????
mm=1;
x_size=size(xtrain); %%% (5*563) ��ʾÿ���������������563������
num_in=x_size(1);% �������������ά�ȣ�Ҳ�������Ļ���

%% �������ȿ������ڽ���
num_nod=200; % ����������������������ڵ����
PopSize=30; % ��Ⱥ���� ����������һ����Ⱥ�ж�����壬����������Ϊ�������������Ѿ�ȷ��������
G=10;
amp=1; % ���Ŀ�ĵķŴ���
%a=0.85;
a=0.85; % adaption func ������
b=0.05; % adaption func ������
d=3; % adaption func ������

%G=1;
Codel=num_nod;  % 200 ������ڵ������
% ΪʲôҪתΪcode1 ������ֱ����num_nod���㣿��

% Control ���ƻ���---���������飬ÿһλ����һ������ڵ㣬1 ��ʾ����ڵ㼤�0��ʾ���ߡ� ���ƻ����λ�� = ����ڵ����
% ������֪��ÿһ������ڵ㶼�ͻ���������һ�������������������һ���ڵ�Ҳ����5������
Control=round(rand(PopSize,Codel));   % Ϊ30*200�ľ���ֵΪ0����1��30����Ⱥ��ÿ����Ⱥ���кܶ�����Լ����ǵĿ��ƻ�����Ⱥ���� * �ڵ���� = 30����Ⱥ�ܵĻ���λ������
CodeL=num_in*num_nod;%1000 һ������5������һ���ڵ����5����������ͱ�ʾһ�������ܿ��Ƶ��ܻ�����
for i=1:PopSize % ��Ⱥѭ��
    select = xtrain(:,randperm(num_nod));  %��ʼ�����Ĳ����������ȡx��������randperm������ǰi�е�����Ԫ��---30����Ⱥ��ÿ����Ⱥ��ѵ���������200��������Ϊ������
    % 200��������Ӧ200����Ԫ��
    for j=1:CodeL
        % 200��������ÿ������5������һ��1000������һ����Ⱥ��1000������һ��30����Ⱥ
        Center(i,j)=select(j); %30*1000 select()Ϊѡ��select�����еĵ�j�����м��㣩��Ԫ�ؿ����Լ�ʵ��һ��---30����Ⱥ��ÿ����Ⱥ�����л�����ɾ��󡣰�����������ÿ�����һ������
    end
end

% ���û��
% rand(PopSize,num_nod) 30*200 0-1
% ��ʼ����ȣ�ampΪ�Ŵ���
Spread=amp*rand(PopSize,num_nod)+ones(PopSize,num_nod);%%Spread�����Ȳ���30*200��1��2֮�䣨�����ǳ�ʼ����Ⱦ���
%**********Start Running **********
for kg=1:1:G
    %**********Step1:Evaluate Best Fitness **********
    for i=1:1:PopSize
        NumNod(i)=length(find(Control(i,:))); % ͳ�Ƽ����������ĸ���
        for j=1:1:num_nod % 200����Ԫ
            for t=1:1:num_in % һ����Ԫ��Ӧ5����������ط��ǻ���ѭ��1-5
                C(t,j)=Control(i,j)*Center(i,(j-1)*num_in+t);  % Control(i,j)������Ԫ�ļ��������״̬
                % j=1 0*x1 0*x2 0*x3 0*x4 0*x5
                % j=2 1*x6 1*x7 1*x8 1*x9 1*x10
                %              .
                %              .
                %              .
                % C�����õ����ǣ��б�ʾ200����Ԫ��hang��ʾ5�����򣬲�������Ϊ0��ʾ����״̬������������ֳ��˿��ƻ��������
                % ����Ҫ�����ҵ���������������������������C��ÿһ�о������ĵ�����
            end
        end
        for j=1:1:num_nod
            % ����Control(i,j)��Ҫ֪����һ��ɸѡ�����˵����ߵ���Ԫ
            B(j)=Spread(i,j).*Control(i,j)';   %1*100����sigma��� ���˵����ߵ���Ԫ��Ӧ�Ŀ�ȣ����������
            if B(j)==0;B(j)=0.001;end % �õ���Ԫ����Ӧ�Ŀ�ȣ�ÿ����Ԫ����������򣬶�Ӧһ��������������Ԫ�Ŀ�Ⱦ��ǿ���������ȣ�����������Ⱦ��õ���
        end
        for k=1:1:x_size(2)   % ÿһ��������������
            for t=1:1:num_nod % ÿ��������ڵ��ó�����������
                % �������õ���ÿ��������ÿ����ڵ�
                % xtrain(:,k) ÿһ���Ǹ�����
                % ����1 ��Ԫ1 ��Ԫ2 ...
                % ����2 ��Ԫ1 ��Ԫ2 ...
                % ����Ĺ�ʽʹ���� newrb ��exact ���ʽ����ĸ�Ǵ�2�� ������������Ԫ����countpart
                % approximate ��Ԫ��̬��չ���������ݽ϶�
                H(k,t)=Control(i,t)*exp(-norm(xtrain(:,k)-C(:,t))^2/(2*B(t)^2));%�����������������������һ��Control(i,t)
                % �õ�ÿ������������������ֵ�����������������Ҫ����Ȩ����
            end
        end
        %a=pinv(H'*H)*(H'*yout');  % 200*1
        %b=Control(i,:)';             %200*1
        % H 563*200         pinv(H'*H) 200*200      H'*yout1' 200*1
        % H'��ÿһ�б�ʾ200��������һ����Ԫ���������Ϊ����Ҫ����Ȩ�أ��Ǹ���һ����Ԫ�����ȥ�����
        % A*W=Y   W=A-1*Y  W = (AT * A)-1 * AT * Y ---A ���� Y ���
        W1(:,i)=pinv(H'*H)*(H'*yout1').*Control(i,:)'; % λ��Ȩ---�����ѵ��������Ȩ
        W2(:,i)=pinv(H'*H)*(H'*yout2').*Control(i,:)'; % ��СȨ
        ymout1(i,:)=(H*W1(:,i))';                     %���*Ȩ�ؾ�������� ѵ��λ�����
        ymout2(i,:)=(H*W2(:,i))';                     %ѵ����С���
        error1(i,:)=sumsqr(yout1-ymout1(i,:));
        error2(i,:)=sumsqr(yout2-ymout2(i,:));
        BsJi(i)=(error1(i,:)+error2(i,:))/x_size(2);      %�������
        
        
        ff(i)=2*x_size(2)/((a+b*exp(NumNod(i)/(d*6)))*BsJi(i)); %% adaption func
        
        if BsJi(i)<0.00001
            kg=kg-1;break % ����Ѿ��ǳ�С�ˣ�ֱ��break�������Ⱥ�����ˣ�����������ֱ��ѡ��������Ⱥ��
        end
        %ff(i)=-(x_size(2)*log(BsJi(i))+4*NumNod(i))+5000;
        %ff(i)=1/(BsJi(i)+1+4*NumNod(i));
        % n = 6 why?
    end
    % ����---���������С
    [OderJi,IndexJi]=sort(BsJi);% ����С�����˳������BsJi��ֵ��OderJi����IndexJi����Ӧ����ţ�
    BestJ(kg)=OderJi(1);        % �õ���С������
    fi=ff; % ���ƻ�ԭ������Ӧ��
    [Oderfi,Indexfi]=sort(fi);
    Bestfi(kg)=Oderfi(PopSize); % �õ������Ӧ����Ⱥ
    BestS=Center(Indexfi(PopSize),:); % �õ������Ⱥ����������
    BestSpread=Spread(Indexfi(PopSize),:); % �õ������Ⱥ��������Ԫ
    BestControl=Control(Indexfi(PopSize),:); % �õ������Ⱥ�Ŀ��ƻ���
    BestW1=W1(:,Indexfi(PopSize)); % �����Ⱥ��λ��Ȩ
    BestW2=W2(:,Indexfi(PopSize)); % �����Ⱥ�Ĵ�СȨ
    FNumNod(kg)=length(find(BestControl)); % �����Ⱥ�ļ��������
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
            TempE(i+1,:)=(1-alfa)*Center(i+1,:)+alfa*Center(i,:);  %����������
            TempS(i,:)=alfa*Spread(i+1,:)+(1-alfa)*Spread(i,:);
            TempS(i+1,:)=(1-alfa)*Spread(i+1,:)+alfa*Spread(i,:);
        end
    end
    TempE(PopSize,:)=BestS;           %����
    TempC(PopSize,:)=BestControl;     %���ƻ���
    TempS(PopSize,:)=BestSpread;      %���
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



