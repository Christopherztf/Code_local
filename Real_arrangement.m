clear;close all;clc;
y_rx3 =[5	3	2	1	5	1	1	2]+23;
z_rx3=0:2.05:14.35;

% 发射天线

y_tx=[0	6 10 11	13	14	16 17 18 0 8 9];
z_tx=[0, 0, 0, 0, 0, 0, 0, 0, 0, 8,8,8]*2.05;

% 2d接收天线
y_rx2=[0	3.5	9	12.5	16	20.5	31	35.5];
z_rx2=6.5*ones(1,8);

%3d测角虚拟孔径
y_vrx=kron(y_tx, ones(1, length(y_rx3))) + kron(ones(1, length(y_tx)), y_rx3);
z_vrx=kron(z_tx, ones(1, length(z_rx3))) + kron(ones(1, length(z_tx)), z_rx3);

%%
%天线位置图
figure
for i =1:12
rectangle("Position",[y_tx(i)-0.4125,z_tx(i)-3.125,0.825,6.25],"EdgeColor",'b')
end
hold on
for i =1:8
rectangle("Position",[y_rx2(i)-0.4125,z_rx2(i)-3.125,0.825,6.25],"EdgeColor",'r')
end
hold on
for i =1:8
rectangle("Position",[y_rx3(i)-2.1875,z_rx3(i)-0.975,4.375,1.95],"EdgeColor",'k')
end
xlabel('Y[lambda]');
ylabel('Z[lambda]');
title('实际天线排布');
% set(gca,'YDir','reverse');
% set(gca,'XDir','reverse');
% axis square;