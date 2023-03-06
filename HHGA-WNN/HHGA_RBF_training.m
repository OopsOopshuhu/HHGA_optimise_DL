
function optim
clear all
close all;
%echo off;  % 禁止(或允许)在屏幕上显示批处理命令行off：表示禁止


 tic, % 开始计时   
 load guiyiresult1   %输入的数据，矩阵名为shuru为568*6
 x=shuru';
 yy123     %对应的输出数据，矩阵名为y为568*2
 yout1=y1(:,1)';  %位置
 yout2=y1(:,2)';  %大小
%pausetime=0.1;  %%????
mm=1;
x_size=size(x); %%% (6*568)
num_in=x_size(1);%6
amp=20;
num_nod=200;
PopSize=30;
G=30;
%G=1;
Codel=num_nod;  %=100
Control=round(rand(PopSize,Codel));   %%为30*100的矩阵值为0或者1(round就是将数据转化为整数，即将数据转化为最近的整数)
CodeL=num_in*num_nod;%600
for i=1:PopSize
    select=x(:,randperm(num_nod));  %初始化中心参数这个命令取x的任意由randperm产生的前i列的所有元素
    for j=1:CodeL
        Center(i,j)=select(j);      %30*600select()为选择select矩阵中的第j（按列计算）个元素可以自己实验一下
    end
end
Spread=amp*rand(PopSize,num_nod)+ones(PopSize,num_nod);%%Spread代表宽度参数30*100在1到4之间（这里是初始化宽度矩阵）
%**********Start Running **********
for kg=1:1:G
%**********Step1:Evaluate Best Fitness **********
for i=1:1:PopSize
    NumNod(i)=length(find(Control(i,:)));
    for j=1:1:num_nod
        for t=1:1:num_in
            C(t,j)=Control(i,j)*Center(i,(j-1)*num_in+t);  %6*100这里当控制基因为0是和这条控制基因相连的所有的东西都无效
        end
    end
    for j=1:1:num_nod
        B(j)=Spread(i,j).*Control(i,j)';   %1*100代表sigma宽度　　　　
        if B(j)==0;B(j)=eps;end
    end
    for k=1:1:x_size(2)   %1到568
        for t=1:1:num_nod
            H(k,t)=Control(i,t)*(cos(1.75*norm(x(:,k)-C(:,t))/B(t))*exp(-norm(x(:,k)-C(:,t))^2/(2*B(t)^2)));%小波基函数的输出
            %H(k,t)=Control(i,t)*exp(-norm(x(:,k)-C(:,t))^2/(2*B(t)^2));
        end
    end
    %a=(pinv(H'*H)*(H'*yout'))';  % 2*100
    %b=Control(i,:)';             %100*1
    W1(:,i)=pinv(H'*H)*(H'*yout1').*Control(i,:)';%1123123用大小的重复一遍就可以得到和位置相应的权值
    W2(:,i)=pinv(H'*H)*(H'*yout2').*Control(i,:)';%1123123用大小的重复一遍就可以得到和大小相应的权值
    ymout1(i,:)=(H*W1(:,i))';                     %然后将两个权值结合得到最后的权值
    ymout2(i,:)=(H*W2(:,i))';                     %然后将两个权值结合得到最后的权值w1和w2结合可得最后的权值
    error1(i,:)=yout1-ymout1(i,:);
    error2(i,:)=yout2-ymout2(i,:);
    BsJi(i)=(sumsqr(error1(i,:))+sumsqr(error2(i,:)))/x_size(2);%均方误差
    %error(i,:)=abs(error1(i,:))+abs(error2(i,:));
    %BsJi(i)=sumsqr(error(i,:))/(1000*x_size(2));      
    if BsJi(i)<0.0001
        kg=kg-1;break
    end
    %ff(i)=(x_size(2)*log(BsJi(i))+4*NumNod(i))+32767;
    %ff(i)=1000/(BsJi(i));
    ff(i)=2*568/((0.95+0.05*exp(NumNod(i)/2))*BsJi(i));
end
[OderJi,IndexJi]=sort(BsJi);%按由小到大的顺序排列BsJi的值（OderJi），IndexJi是相应的序号；
BestJ(kg)=OderJi(1);        %得到最小的误差值
%plot(kg,BestJ(kg),'*');hold on;
fi=ff;
[Oderfi,Indexfi]=sort(fi);   %Arranging  fi  small to  bigger
Bestfi(kg)=Oderfi(PopSize);    %Let Bestfi=max(fi)
figure(2),plot(kg,Bestfi(kg),'.k');hold on;
BestS=Center(Indexfi(PopSize),:);
BestSpread=Spread(Indexfi(PopSize),:);
BestControl=Control(Indexfi(PopSize),:);
BestW1=W1(:,Indexfi(PopSize));
BestW2=W2(:,Indexfi(PopSize));
FNumNod(kg)=length(find(BestControl));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subBestS=Center(Indexfi(PopSize-1),:);
subBestSpread=Spread(Indexfi(PopSize-1),:);
subBestControl=Control(Indexfi(PopSize-1),:);
subBestW1=W1(:,Indexfi(PopSize-1));
subBestW2=W2(:,Indexfi(PopSize-1));
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
Rest=FitSize-fi_S;%-1h和1之间的数
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
Pc2=0.6;%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i=1:2:(PopSize-1)
    fc=max(fi(i),fi(i+1));
    if fc>AverFi
        Pc=Pc1-(Pc1-Pc2)*(Bestfi(kg)-fc)/(Bestfi(kg)-AverFi);
    else
        Pc=Pc1;
    end
    if Pc>rand;
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
%{
TempE(PopSize,:)=BestS;           %中心
TempC(PopSize,:)=BestControl;     %控制基因
TempS(PopSize,:)=BestSpread;      %宽度
Control=TempC;
Center=TempE;
Spread=TempS;
%}
%*********** Step3 : Mutation Operatin ***********
Pm1=0.1;Pm2=0.001;
Pm1=0.5;Pm2=0.1;%%%%%%%%%%%%%%%%%%%%%%%%%%5
for i=1:1:PopSize
    fm=fi(i);
    if fm>AverFi
        Pm=Pm1-(Pm1-Pm2)*(Bestfi(kg)-fm)/(Bestfi(kg)-AverFi);
    else
        Pm=1;
    end
    for n=1:1:Codel
        if Pm>rand;%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if TempC(i,n)==0
                TempC(i,n)=1;
            else
                TempC(i,n)=0;
            end
        end
    end
    for n=1:1:CodeL
        if Pm>rand;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
           TempE(i,j)=min(min(x))+rand*(max(max(x))-min(min(x)));
        end
    end
    for j=1:1:num_nod
        if Pm>rand;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            TempS(i,j)=1+amp*rand;
        end
    end
end
TempE(PopSize,:)=BestS;
TempC(PopSize,:)=BestControl;
TempS(PopSize,:)=BestSpread;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TempE(PopSize-1,:)=subBestS;
TempC(PopSize-1,:)=subBestControl;
TempS(PopSize-1,:)=subBestSpread;
Control=TempC;
Center=TempE;
Spread=TempS;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gen=kg
end
sse=BestJ(kg)*x_size(2)
mses=sqrt(BestJ(kg))
%plot(yout-ymout(Indexfi(PopSize),:));
%figure;plot(yout),hold on,plot(ymout(Indexfi(PopSize),:),'r--');
%legend('Original','RBF out',0);
figure(3),plot(FNumNod,'o');
figure(2),plot(Bestfi,'.k');hold on,plot(meanfi,'r--');
%figure,plot(BestJ.*length(yout));


save TrainResult2 BestS BestW1 BestW2 BestControl BestSpread num_nod num_in
biaozhi='finished'
toc;
        
        
    



        
        

        
        