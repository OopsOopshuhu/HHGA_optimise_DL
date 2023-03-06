function test2   %这里直接将优化程序中的权值带入就可以了！
clc;
clear all
%echo off;
% test     %内部矩阵名字为test1
% ytest    %内部矩阵名字为y12
% load guiyiresult1
load noNormaldata
% load Normaldata
x=test6';
%x=test1';
yout=y;  %on
yout1=yout(:,1);  %on
yout2=yout(:,2);  %on
load TrainResult2
x_size=size(x);
Newnumber=0;
for i=1:1:num_nod
    if BestControl(i)==1
        Newnumber=Newnumber+1;
        n(Newnumber)=i;
    end
end
for j=1:1:Newnumber
    for t=1:1:num_in
        C(t,j)=BestControl(n(j))*BestS((n(j)-1)*num_in+t);
    end
    B(j)=BestSpread(n(j));
    w1(j)=BestW1(n(j));
    w2(j)=BestW2(n(j));
end


for k=1:1:x_size(2)
    for t=1:1:Newnumber
        H1(k,t)=exp(-norm(x(:,k)-C(:,t))^2/(2*B(t)^2));
    end
end
Y1=H1*w1';
Y2=H1*w2';
Y=[Y1 Y2]
ratio2=100*(Y-y)./y

sse=sumsqr(yout-Y)
mse=sqrt(sumsqr(yout-Y)./x_size(2))
plot(yout-Y)
figure
plot(yout,'b-'),hold on,plot(Y,'r-');
legend('Original','Test value');

