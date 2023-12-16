%% 变量初始化
clear;                    %清变量
close all;                %清图
clc;                      %清屏
pop = 1000;              %种群数量
Ny = 8;                 
[rx]= avoid_repeat_initial(pop);   %种群初始化
[objv , restrain] = fitness(rx,pop); %获取目标函数值gain和约束
satisfy_loc = find(restrain < -13.3);
satisfy_rx = rx(satisfy_loc,:);
satisfy_restrain = restrain(satisfy_loc,1);

objv1 = objv(satisfy_loc);
satisfy_min = min(objv1)

best_rx = satisfy_rx(objv1 == satisfy_min,:);
% d2_draw_opti(f(1,:));