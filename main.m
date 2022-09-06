clc
clear all
format long
close all
tic
ma1=0.1:0.1:0.6; % 0.1-0.6;
la1=length(ma1);
ma2=0:0.05:0.2; %0-0.2;
la2=length(ma2);
mz=2:0.5:4; %2-9
lz=length(mz);
mb=0.1:0.2:0.9;%0-1
lb=length(mb);
file_name='ma22_earthquakes.xlsx';%地震文件名 b88
sheet_name='sheet1'; %地震所在Sheet
ggg=xlsread(file_name);

    for ah1_ii=1:1:la1
        for ah2_ii=1:1:la2
            if ma1(ah1_ii)>ma2(ah2_ii)   
            for z_ii=1:1:lz
%                 ss=sprintf('a1_%.1f-a2_%.2f-b_%.1f-z_%.1f.mat',ma1(ah1_ii), ma2(ah2_ii), mb(1),mz(z_ii));
%                    if exist(ss)
%                        fprintf('alpha_h1=%.2f_alpha_h2=%.2f_zeta=%.2f_beta=%.2f.mat have exist\n',ma1(ah1_ii),ma2(ah2_ii),mz(z_ii),mb(1));   
%                        continue
%                    end
                   save('transfer1.mat','ma1','ma2','mz','mb','ggg','ah1_ii','ah2_ii','z_ii','la1','la2','lz','lb');
                   
                   parfor bb=1:1:lb
                   a1=constant(ma1(ah1_ii),ma2(ah2_ii),mz(z_ii),mb(bb),ggg);
                   fprintf('process:alpha_h1=%.2f_alpha_h2=%.2f_zeta=%.2f_beta=%.2f over\n',ma1(ah1_ii),ma2(ah2_ii),mz(z_ii),mb(bb));
                   end
                   clear all
                   format long
                   close all
                   load('transfer1.mat');
               end
            end
        end
    end