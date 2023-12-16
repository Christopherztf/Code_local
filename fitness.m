function [gain , restrain] = fitness(rx,pop)
%FITNESS 此处显示有关此函数的摘要
%   此处显示详细说明

restrain = zeros(pop,1);
gain = zeros(pop,1);
%发射天线
 y_tx = [0	6	10	11	13	14	16	17	18];  %tx;
for i = 1 : pop
    y_rx2 = rx(i,:);   %2d接收天线
   
    y_vx=kron(y_tx, ones(1, length(y_rx2))) + kron(ones(1, length(y_tx)), y_rx2);
    y_array = sort(unique((y_vx)));                     %去重
    Adjust_loc = 1 - min(y_array);                                    %调整位置，使天线位置从1开始
    loc_Y_Array = 2*(y_array + Adjust_loc) - 1;
    binary_Y_Array = zeros(1 , 2*(max(y_array)-min(y_array)) + 1);      %1为有天线，0为没有天线

    binary_Y_Array(loc_Y_Array) = 1;
    N_fft = 2.^14;                                              %fft点数
    theta0 = 0;                                                 %方向图指向角
    A_theta0 = ones(size(theta0));
    full_dy = 0.5;                                              %满阵天线间距
    per_dy = full_dy*(0 : length(binary_Y_Array) - 1).*binary_Y_Array;    %满阵天线到第一根距离

    f_y = A_theta0*exp(1j*2*pi*sind(theta0)*per_dy).*binary_Y_Array;    %接收信号函数

    k_y = linspace(-1,1,N_fft+1);
    k_y = k_y(1 : end-1);
    theta_fft =asind(k_y/(2*full_dy));
    F_theta_fft = 20*log10(abs(fftshift(fft(f_y, N_fft)/length(y_array))));

    %%
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
    res_2d = theta_fft((left_side+1+max(main_side_cut_azi))) - theta_fft(left_side+(min(main_side_cut_azi)));
    %计算3dazi旁瓣
    pks_2d1 = sort(pks_2d);
    sidebeam_2d = pks_2d1(1 : end -1);
    max_sidebeam_2d = max(sidebeam_2d);
    %% 适应度
    gain(i,1) = 1*res_2d+0*max_sidebeam_2d;
    restrain(i,1) = max_sidebeam_2d;
    if F_theta_fft(1)>-14
       gain(i,1) = gain(i,1)+10; 
    end
end
end 

