clc;clear;close all
%3d接收天线
% y_rx3=15*ones(1,8);
% z_rx3=0:2.05:14.35;
%2d接收天线
% y_rx2=[0 3.5 9 12.5 16 20.5 31 35.5];
% y_rx2 = [0 1.5 3 4.5 12 13.5 15 16.5];
% y_rx2 = [0	3.5	6.5	13.5	16.5	18	23	28];
 % y_rx2 = [0	2.5	8	15	20	23.5	24.5	26.5];
 y_rx2 = [0 1.5 12 13.5 24 25.5 36 37.5];
z_rx2=1.923*ones(1,8);
%发射天线

% y_tx=[0	6	10	11	13	14	16	17	18];
% y_tx = [0 2 4 6 8 10];
% y_tx =[0	2	4	11	20	26];
% y_tx =[0 4	14	17	23	30];
y_tx = [0 1 2 3 4 5 6 7 8 9 10 11];
z_tx=zeros(1,12);

%天线位置图
figure(1)
plot(y_rx2,z_rx2,'bo',y_tx,z_tx,'r+');
grid on;
xlabel('Y[lambda]');
ylabel('Z[lambda]');
legend('2d rx','tx');
title('实际天线排布');
set(gca,'YDir','reverse');
set(gca,'XDir','reverse');
axis square;

%3d测角虚拟孔径
% y_vrx=kron(y_tx, ones(1, length(y_rx3))) + kron(ones(1, length(y_tx)), y_rx3);
% z_vrx=kron(z_tx, ones(1, length(z_rx3))) + kron(ones(1, length(z_tx)), z_rx3);
%2d测角虚拟孔径
y_vx=kron(y_tx, ones(1, length(y_rx2))) + kron(ones(1, length(y_tx)), y_rx2);
z_vx=kron(z_tx, ones(1, length(z_rx2))) + kron(ones(1, length(z_tx)), z_rx2);

%3d测角虚拟孔径画图
figure(2)
plot(y_vx,z_vx,'ko');
xlabel('Y[lambda]')
ylabel('Z[lambda]')
ylim([1.8,2])
title('2D Virtual Array');
grid on;
axis square;

y_array = sort(unique((y_vx)));
num_antenna = length(y_array)
Adjust_loc = 1 - min(y_array);                                    %调整位置，使天线位置从1开始
loc_Y_Array = 2*(y_array + Adjust_loc) - 1;                     
binary_Y_Array = zeros(1 , 2*(max(y_array)-min(y_array)) + 1);      %1为有天线，0为没有天线
binary_Y_Array(loc_Y_Array) = 1;
% binary_Y_Array = fliplr(binary_Y_Array);
N_fft = 2.^16;                                              %fft点数
theta0 = 0;                                                 %方向图指向角
full_dy = 0.5;                                              %满阵天线间距
A_theta0=1;
per_dy = full_dy*(0 : length(binary_Y_Array) - 1).*binary_Y_Array;    %满阵天线到第一根距离
per_dy1 = full_dy*(0 : length(binary_Y_Array) - 1);
f_y = A_theta0*exp(1j*2*pi*sind(theta0)*per_dy).*binary_Y_Array;    %接收信号函数
full_f_y = A_theta0*exp(1j*2*pi*sind(theta0)*per_dy1);
k_y = linspace(-1,1,N_fft+1);
k_y = k_y(1 : end-1);
theta_fft =asind(k_y/(2*full_dy));
F_theta_fft = 20*log10(abs(fftshift(fft(f_y, N_fft)/length(y_array))));
full_F_theta_fft = 20*log10(abs(fftshift(fft(full_f_y, N_fft)/length(binary_Y_Array))));



%% 满阵虚拟阵列
right_boundary = max(y_array) - min(y_array);
full_virtual_y = min(y_array) : 0.5 : right_boundary;
full_virtual_z = 1.923*ones(1,length(full_virtual_y));
figure 
plot(full_virtual_y,full_virtual_z,'o')
hold on
plot(y_vx,z_vx,'ko')
title('满阵和稀疏阵')
xlabel('Y[lambda]')
ylabel('Z[lambda]')
legend('满阵','稀疏阵')
ylim([0,2])
%% 2d指标
[pks_2d,locs] = findpeaks(F_theta_fft);
%计算2d分辨率
main_peak = max(pks_2d);
left_side = locs(find(pks_2d == main_peak)-1);
right_side = locs(find(pks_2d == main_peak)+1);
if(length(left_side)>1)
    left_side = left_side(round(length(left_side/2)));
    right_side = right_side(round(length(right_side/2)));
end
main_side_cut_azi = find(F_theta_fft(left_side:right_side)>= -3 );
res_2d = theta_fft((left_side+1+max(main_side_cut_azi))) - theta_fft(left_side+(min(main_side_cut_azi)))
%计算3dazi旁瓣
pks_2d1 = sort(pks_2d);
sidebeam_2d = pks_2d1(1 : end -1);
max_sidebeam_2d = max(sidebeam_2d)
%%
gain=10*log10(num_antenna);
[full_pks_2d,locs] = findpeaks(full_F_theta_fft);
main_peak = max(full_pks_2d);
left_side = locs(find(full_pks_2d == main_peak)-1);
right_side = locs(find(full_pks_2d == main_peak)+1);
if(length(left_side)>1)
    left_side = left_side(round(length(left_side/2)));
    right_side = right_side(round(length(right_side/2)));
end
main_side_cut_azi = find(full_F_theta_fft(left_side:right_side)>= -3 );
full_res_2d = theta_fft((left_side+1+max(main_side_cut_azi))) - theta_fft(left_side+(min(main_side_cut_azi)));
%% 画图
figure;
plot(theta_fft, F_theta_fft);
hold on
plot(theta_fft,full_F_theta_fft);
ylim([-50,0]);
title('满阵',[sprintf('%dArray，', ...
    length(full_virtual_y)),sprintf('  满阵分辨率为%2.2f°',full_res_2d)],'FontSize',14)
xlabel('\theta/(°)')
ylabel('增益/dB')
legend('稀疏阵','满阵')

%% 画图
figure;
plot(theta_fft, F_theta_fft);
title('2d patern',[sprintf('分辨率 d=%1.2f°，',res_2d),sprintf(' 最大旁瓣为 %6.2fdB，',max_sidebeam_2d), ...
     sprintf(' gain=%d=%2.2fdB',num_antenna,gain)],'FontSize',14)
xlabel('\theta/(°)')
ylabel('增益/dB')
ylim([-40,0]);

