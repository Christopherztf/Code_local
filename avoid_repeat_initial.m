
function [rx_2d] = avoid_repeat_initial(pop)
 tx = [0	6	10	11	13	14	16	17	18];  %tx
rx_2d = zeros(pop,8);
for gen =1:pop
    a0=0;%rx

    c=10.5;    
    rx = a0;
  
    for i =1:1:7 
        virtual1 = kron(rx,ones(1,length(tx)))+kron(ones(1,length(rx)),tx);
        diff1 = kron(virtual1,ones(1,length(tx)))-kron(ones(1,length(virtual1)),tx);
        except_a1 = rx(end)+(1:0.5:c);
        selected_a1 = setdiff(except_a1,diff1);
        if isempty(selected_a1) == 1
            a1 = except_a1(randperm(length(except_a1),1));
        else
            a1 = selected_a1(randperm(length(selected_a1),1));
        end
        rx = cat(2,rx,a1);
      
    end
     rx_2d(gen,:)=rx;
end
% delete1 = all(tx_real==0,2);
% delete2 = all(rx_2d==0,2);
% tx_real(delete1,:)=[];
% rx_2d(delete2,:)=[];
end

