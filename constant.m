function [result] = constant(ca1,ca2,cz,cb,ggg)
%调用写好的主程序
% save('transfer2.mat','ca1','ca2','cz','cb','ggg');
% %   此处显示详细说明
% %%
% %本程序是计算结构的等延�?�谱
% %本程序用的显示Newmark算法
% clear all
% format long
% close all
% clc;
% tic
% load('transfer2.mat');
%%
global K1

%%
Newmark1=1/2;
Newmark2=1/6;
N_ear=1;%时间步长相对于地震间隔的几分之一
N_frequen=25;%时间步长相对于周期的几分之一
%%
%结构特�?�参�?
m=1; %质量
ksi=0.05; %阻尼�?
Tmin=0.2; %�?小周�?
Tmax=3; %�?大周�?    
Rmax=10; %�?大强度比
number_T=14; %周期被分成的份数
number_R=100; %强度比被分成的份�? 
nu_target=1:0.5:10;%目标延�??
alpha1=ca1; %二期刚度系数 
alpha2=ca2; %三期刚度系数
zeta=cz; %第二屈服点和第一屈服点的比�?? 
be=cb; %能量系数
ee=1e-3; %计算延�?�的误差控制
Nmax=100;%隐式计算的最大迭�?
%%x  
%地震波的读入8
aT=30;%延长计算的时�?5www
Wave_N=22;%波数
gama=1; %地震波放大系�?
% file_name='earthrecord.xlsx';%地震文件�? b88
% sheet_name='sheet1'; %地震�?在Sheet
% ggg=xlsread(file_name);
% Excel=actxserver('Excel.Application');
% Workbooks=Excel.Workbooks;
% Workbook=invoke(Workbooks,'Open',[cd,'\',file_name,'.xlsx']);
%%
[l1 number_nu]=size(nu_target);
Rall_matrix=zeros(number_T+1,number_nu);
R_matrix=zeros(number_T+1,number_nu,Wave_N); %强度比矩阵，横坐标为目标延�?�，纵坐标为周期
E2_matrix=zeros(number_T+1,number_nu,Wave_N);
E2all_matrix=zeros(number_T+1,number_nu);
E_matrix=zeros(number_T+1,number_nu,Wave_N);
Eall_matrix=zeros(number_T+1,number_nu);
Dyall_matrix=zeros(number_T+1,number_nu);
dr_matrix=zeros(number_T+1,number_nu,Wave_N);
drall_matrix=zeros(number_T+1,number_nu);
T=linspace(Tmin,Tmax,number_T+1); %周期向量
R=linspace(1,Rmax,number_R+1); %强度比向�?
Nu=zeros(1,number_R+1); %延�?�向�?
%%
for SP=1:1:22
fprintf('process:earthquake-%d is calculating\n',SP);
% read_excel=ddeinit('Excel',[file_name,'.xlsx:',sheet_name]); %链接Excel�?
% N=ddereq(read_excel,['R1C',num2str(2*SP-1)]); %读取Excel表的数据
% DT_earth=ddereq(read_excel,['R1C',num2str(2*SP)]);
 N=ggg(1,2*SP-1);
 DT_earth=ggg(1,2*SP);
%%
% C1='A'; %时间�?在列
% C2='C'; %加�?�度�?在列
% Start=2; %�?始的行号
% wb=waitbar(0,['正在读取�?',num2str(SP),'条波数据，请稍等...']);
% fid=winopen([file_name,'.xlsx']);
%T_earthe=xlsread(fid,sheet_name,[C1,num2str(Start),':',C1,num2str(Start+N-1)]); %读取地震加�?�度相应的时间，默认�?始的时间�?0
% T_earthe=ddereq(read_excel,['R2C',num2str(2*SP-1),':R',num2str(N+1),'C',num2str(2*SP-1)]);
T_earthe=ggg(2:N+1,2*SP-1);
% waitbar(0.5,wb,['读取�?',num2str(SP),'条波数据已完�?',num2str(50),'%']);
%G=xlsread(fid,sheet_name,[C2,num2str(Start),':',C2,num2str(Start+N-1)]); %读取地震加�?�度，默认开始的时间�?0
% G=ddereq(read_excel,['R2C',num2str(2*SP),':R',num2str(N+1),'C',num2str(2*SP)]);
G=ggg(2:N+1,2*SP);
% waitbar(1,wb,['读取�?',num2str(SP),'条波数据已完�?',num2str(100),'%']);
% close(wb);

%%
% wb=waitbar(0,['正在对第',num2str(SP),'条波进行计算，请稍等...']);
R(1)=1;
Nu(1)=1;
for i=1:number_T+1
%%
    %地震参数计算
    dt1=DT_earth/N_ear;
    dt2=T(i)/N_frequen;
    dt=min(dt1,dt2);
    T1=T_earthe(N)+aT; %地震结束的时�?
    Nub=ceil(T1/dt); %地震作用时间被分成的时间步长份数
    Tim=[0:dt:(Nub-1)*dt]'; %计算的时间向�?
    a=zeros(Nub,1); %加�?�度向量
    v=zeros(Nub,1); %速度向量
    x=zeros(Nub,1); %位移速度向量
    P=zeros(Nub,1); %地震力向�?
    F=zeros(Nub,1); %弹塑性力向量
    flag=1;
    P(1)=-gama*m*G(1);
    nber=Nub-N;
    TT=[T_earthe;transpose(linspace(T_earthe(N)+dt,max(Tim),nber))];
    GG=[G;zeros(nber,1)];
    if dt==dt1
        P=-gama*m*GG;
    else
        P=-gama*m*interp1(TT,GG,Tim);
    end
%%
%计算弹�?�力
    c=4*pi*ksi*m/T(i); %阻尼
    K1=4*pi^2*m/T(i)^2;
    a(1)=-gama*G(1);
    v(1)=0;
    x(1)=0;
    A=(m+Newmark1*c*dt)/Newmark2/dt^2;
    B=(0.5*m+(0.5*Newmark1-Newmark2)*c*dt)/Newmark2;
% 
%     inputArg=[T(i),DT_earth,SP,N,Newmark1,Newmark2];
%     dlmwrite('inputArg.txt',inputArg,'delimiter','\n');
%     system('C:\PhDzhumin\opensees\Cductility\OpenSees.exe < maxdisp.tcl');
%     outputArg=dlmread('outputArg.txt');                        
%     maxDisp=outputArg(1);
      xe=50000;
      [x v a F]=SelfCenteringMaterialVri(Nub,K1,a,Nmax,P,A,B,ee,alpha1,alpha2,Newmark1,Newmark2,dt,zeta,be,xe);
      De=max(abs(x));
%%
    for j=2:number_R+1
        xe=De/R(j);
        [x v a F]=SelfCenteringMaterialVri(Nub,K1,a,Nmax,P,A,B,ee,alpha1,alpha2,Newmark1,Newmark2,dt,zeta,be,xe);
        Dm=max(abs(x));
        Nu(j)=Dm/De*R(j);
    end
    for j=1:number_nu
        for l=2:number_R+1
            if (Nu(l)-nu_target(j))*(Nu(l-1)-nu_target(j))<=0
                R1=R(l-1);
                R2=R(l);
                Nu1=Nu(l-1);
                Nu2=Nu(l);
                break;
            end
        end
        for o=1:Nmax
            if o<=5
                R3=(R1+R2)/2;
            else
                R3=((Nu2-nu_target(j))*R1-(Nu1-nu_target(j))*R2)/(Nu2-Nu1);
            end
         xe=De/R3;  
         [x v a F]=SelfCenteringMaterialVri(Nub,K1,a,Nmax,P,A,B,ee,alpha1,alpha2,Newmark1,Newmark2,dt,zeta,be,xe);
            Dm=max(abs(x));
            Nu3=Dm/De*R3;
            if abs((R3-R2)/R3)<=ee
                break;
            else
                if o<=5
                    if (Nu1-nu_target(j))*(Nu3-nu_target(j))>0
                        R1=R2;Nu1=Nu2;R2=R3;Nu2=Nu3;
                    else
                        R2=R3;Nu2=Nu3;
                    end
                else
                    R1=R2;R2=R3;Nu1=Nu2;Nu2=Nu3;
                end
            end
            %             s=((i-1)*number_nu*1000+(j-1)*1000+o)/((number_T+1)*number_nu*1000);
            %             waitbar(s,wb,['�?',num2str(SP),'条波计算已完�?',num2str(round(s*1000)/10),'%']);
        end
        if o>Nmax
            error('达到�?大迭代次数，请检查！')
        else
           
 %%
            xx1=x(1:end-1);
            xx2=x(2:end);
            FF1=F(1:end-1);
            FF2=F(2:end);
            kkk(:,1)=(FF2-FF1)./(xx2-xx1);    
            kkk(:,2)=(xx2-xx1)./xx2;
            kkk(:,3)=(FF2-FF1);
            kkkk=sortrows(kkk,1);
           
            if (kkkk(1,1)< -10*K1 && kkkk(1,2)>0.001) || R3> Rmax || R1<1 || R2<1|| R3<1
            fprintf('process:earthquake-%d is error\n',SP);    
            s3=sprintf('C:/Users/Min ZHU/Desktop/ms/peer/22/mainafter_true/data/error/K-a1_%.1f-a2_%.2f-b_%.1f-z_%.1f-t_%.1f-g_%d-u_%.1f.mat',alpha1, alpha2, be,zeta,T(i),SP, nu_target(j));
            save([s3],'xx1','FF1','R3');  
            dr=200;
            R3=constant_1(alpha1, alpha2, be,zeta,ggg,T(i),SP, nu_target,number_R,dr);
            end
            
            kkk=[];       
             R_matrix(i,j,SP)=R3;
            
            if nu_target(j)> zeta
            E2_matrix(i,j,SP)=(2*nu_target(j)-1+alpha1*(2*nu_target(j)-zeta-1)*(zeta-1)+alpha2*(nu_target(j)-zeta)*(nu_target(j)-zeta))/R3^2;
            else
            E2_matrix(i,j,SP)=(2*nu_target(j)-1+alpha1*(nu_target(j)-1)*(nu_target(j)-1))/R3^2;
            end

            E_matrix(i,j,SP)=0.5*transpose(FF1+FF2)*(xx2-xx1)-F(end)^2/2/K1;
            Dy_matrix(i,j,SP)=De/R3;
            dr_matrix(i,j,SP)=abs(x(end))/abs(De);
            De_matrix(i,j,SP)=De;
            
            

%%
     end

%        -sum((FF1+FF2).^2)/2/K1
%             s=((i-1)*number_nu*1000+(j-1)*1000+o)/((number_T+1)*number_nu*1000);
%             waitbar(s,wb,['�?',num2str(SP),'条波计算已完�?',num2str(round(s*1000)/10),'%']);

%         R_matrix(i,j,SP)=R3;
    end
%     waitbar(i/(number_T+1),wb,['�?',num2str(SP),'条波计算已完�?',num2str(round(i/(number_T+1)*100)),'%']);
end
% Rall_matrix=R_matrix(:,:,SP)+Rall_matrix;
% E2all_matrix=E2_matrix(:,:,SP)+E2all_matrix;
% Eall_matrix=E_matrix(:,:,SP)+Eall_matrix;
% Dyall_matrix=Dy_matrix(:,:,SP)+Dyall_matrix;
% drall_matrix=dr_matrix(:,:,SP)+drall_matrix;
% close(wb);
fprintf('process:earthquake-%d is completed\n',SP);
end
%%
% invoke(Excel,'Quit');
% delete(Excel);
% Rall_matrix=Rall_matrix/Wave_N;
% E2all_matrix=E2all_matrix/Wave_N;
% Eall_matrix=Eall_matrix/Wave_N;
% drall_matrix=drall_matrix/Wave_N;
% % Dyall_matrix=Dyall_matrix/Wave_N;
% E2all_cov=permute(std(permute(E2_matrix,[3,1,2]),1),[2,3,1])./E2all_matrix;
%%
% figure(2)
% plot(xx1,FF1)
% % hold on
% for i=1:number_nu
% %     plot(T,Eall_matrix(:,i))
% plot(T,drall_matrix(:,i))
%     hold on
% end
% hold off
% s1=sprintf('C:/Users/Min ZHU/Desktop/residual drift/data/%.1f', alpha1);


s2=sprintf('a1_%.1f-a2_%.2f-b_%.1f-z_%.1f.mat',alpha1, alpha2, be,zeta);
% save all
save([s2],'E_matrix','Dy_matrix','dr_matrix','De_matrix','R_matrix','E2_matrix');
result=1;
end

