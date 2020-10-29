clear all; close all; clc;

ldiv=8;
%caminho do pc-J_ou_S

%opcao = input('Escolha a opca. 1 para Javier ou 2 para Sergio: ');
opcao = 1;
%opções da elipse para concentrações de tensões
x0=0; % x0,y0 centro de coordenadas da elps
y0=0;

rTuboi = '0.02';% RAIO DO TUBO INTERIOR
rTubof = '0.01';% RAIO DO TUBO INTERIOR
espessura = 0.01;%espessura da pa
blade = 'shapeUirrapuru.txt';

coord='e423Perfil.txt';          %AIRFOIL COORDINATES [X,Y]
blade_shape=load(blade); %SHAPE [R,C,B]
r = blade_shape(:,1);          %radial position (m)
c = blade_shape(:,2);          %chord (m)
b = blade_shape(:,3);          %twist (degree)

%% Propriedas do fluido para  o calculo de forças atuantes
%Foil-comandos
ITRMAX = 10;
iterxfoil=100;%xfoil
TOL    = 1e-3;
Nr=30;
R0=0.1592;
R=1.5923;
v0opt = 6;                         %fluid velocity

B=3;
omega=250*2*pi/60; %rad/s
vsound=340; %340m/s air         % velocity of sound for calculate Mach for xfoil
rho = 1.205;%air 20ºC           %fluid density (Kg/m^3)
ni  = 15.111e-6;%air 20ºC       %fluid Kinematic Viscosity (m^2/s)

alpha=8; %degree              %degree AOA optimized
AOAs =10;  %degree              %Angle of Atack STALL
CCd = 0.01;                    %inicial value of cd
cl = 1.0;                    %inicial value
%%



elementosNumeroPorLinha= size(c);
elementosNumerPerfis = size(r);
eLinhasMatrizPrincipal=elementosNumerPerfis(1,1);%QUANTIDADE DE PERFIS
eColunaMatrizPrincipal=elementosNumeroPorLinha(1,1);%QUANTIDADE DE Kpoint em cada perfil

MatrixNervuras = [2,3,5,7,9,15];
MatrixNervurasSemLong =[16,17];
LinhaColunasNervuras = size(MatrixNervuras);
NumeroDeNervuras = LinhaColunasNervuras(1,2);

kmTubo = [];%matriz com os kpoits do tubo interno

fid = fopen('ForCFX\ComandosAnsys.txt','wt');
fKp = fopen('ForCFX\Kpoints.txt','wt');
fprintf(fid,'FINISH\n');
fprintf(fid,'/CLEAR\n');
fprintf(fid,'/PREP7\n');


figure(1)
[X,Y]=plot_shape3D(coord,r',c',b'*pi/180);  %X = x;Y=y and r =Z

contador=0;

%%
%Criando Matriz com kp e suas coordenadas
MkpCoord = [];
GeoCoord = [];
contador2 = 0;
for n=1:1:eLinhasMatrizPrincipal  
      
      
    for k=1:1:eColunaMatrizPrincipal
        contador2=contador2+1;
        
        MkpCoord(contador2,1)=contador2;%Numero do kp
        MkpCoord(contador2,2)=X(n,k);%COORD X do kp
        GeoCoord(contador2,1)=X(n,k);%COORD X do kp
        
        MkpCoord(contador2,3)=Y(n,k);%COORD Y do kp
        GeoCoord(contador2,2)=Y(n,k);%COORD Y do kp
        
        MkpCoord(contador2,4)=r(n,1);%COORD Z do kp
        GeoCoord(contador2,3)=r(n,1);%COORD Z do kp
        
                
    end
end


tmnKP=abs((MkpCoord(1,4))-(MkpCoord(size(MkpCoord),4)));%tamanho da pa
espace=tmnKP/(eLinhasMatrizPrincipal-1);%espaçamento entre cada perfil


%Criando os k points
Mkpoint = [];
fprintf(fKp,'K\t\t X\t\t\t Y\t\t\t Z\n');
for n=1:1:eLinhasMatrizPrincipal
      
    for k=1:1:eColunaMatrizPrincipal
        contador=contador+1;
        fprintf(fid,'K,%s,%s,%s,%s\n',num2str(contador),X(n,k),Y(n,k), num2str(r(n,1))); 
        fprintf(fKp,'%s\t\t %s\t\t %s\t\t %d\n',num2str(contador),X(n,k),Y(n,k), r(n,1)); 
             
        
        
        %k =  Linha, n = Coluna
        Mkpoint(n,k)=contador;
    end
    fprintf(fid,'CM,grupok%s,KP\n',num2str(n));
    fprintf(fid,'KSEL,U,,,all\n');   
end


fprintf(fid,'/PREP7\n'); 
fprintf(fid,'KSEL,ALL\n'); 

%%
%criando as linhas de perfil
for Linha=1:1:eLinhasMatrizPrincipal
    for Coluna=1:1:eColunaMatrizPrincipal
        
        if mod(Mkpoint(Linha,Coluna),eColunaMatrizPrincipal) == 0
        
           fprintf(fid,'L,%s,%s,%s\n',num2str(Mkpoint(Linha,Coluna)),num2str(Mkpoint(Linha,Coluna)-(eColunaMatrizPrincipal-1)),num2str(ldiv));
        
        else
             fprintf(fid,'L,%s,%s,%s\n',num2str(Mkpoint(Linha,Coluna)),num2str(Mkpoint(Linha,Coluna)+1),num2str(ldiv)); 
        end 

        
    end
    fprintf(fid,'CM,grupoLsection%s,Line\n',num2str(Linha));
    fprintf(fid,'LSEL,U,,,all\n');
    
end





%criando as linhas 'lATERAIS'
   CntLimite = (eLinhasMatrizPrincipal - 1);
   
for Linha=1:1:eLinhasMatrizPrincipal
   for Coluna=1:1:eColunaMatrizPrincipal
      fprintf(fid,'L,%s,%s,%s\n',num2str(Mkpoint(Linha,Coluna)),num2str((Mkpoint(Linha,Coluna)+eColunaMatrizPrincipal)),num2str(ldiv));        
   end       
   fprintf(fid,'CM,grupoLLaterais%s,Line\n',num2str(Linha));
   fprintf(fid,'LSEL,U,,,all\n');
        
   if Linha == CntLimite            
    break  
   else
            
   end
end
   
   fprintf(fid,'KSEL,ALL\n'); 
   
   fprintf(fid,'LSEL,ALL\n'); 
   
   %%
    %criando as areas'
    xa = 1;
    LimiteWhile = (eLinhasMatrizPrincipal*eColunaMatrizPrincipal)-eColunaMatrizPrincipal;
   while xa<=(LimiteWhile),
       
       if mod(xa,eColunaMatrizPrincipal)==0;
        
           fprintf(fid,'AL,%s,%s,%s,%s\n',num2str(xa),num2str((xa+(LimiteWhile+1))),num2str((xa+eColunaMatrizPrincipal)),num2str((xa+(eLinhasMatrizPrincipal*eColunaMatrizPrincipal))));
        
        else
             fprintf(fid,'AL,%s,%s,%s,%s\n',num2str(xa),num2str((xa+((eLinhasMatrizPrincipal*eColunaMatrizPrincipal)+1))),num2str((xa+eColunaMatrizPrincipal)),num2str((xa+(eLinhasMatrizPrincipal*eColunaMatrizPrincipal)))); 
        end 
 
       xa=xa+1;
       
   end
   fprintf(fid,'CM,CASCA,AREA\n');
   fprintf(fid,'LSEL,ALL\n');
   fprintf(fid,'ASEL,U,,,all\n');
   
%Nervuras sEM LONGARINA
fprintf(fid,'AL,grupoLsection%s\n',num2str(eLinhasMatrizPrincipal));
fprintf(fid,'KSEL,U,,,all\n');

%%
%para concentração de tensões: 
fprintf(fid,'KSEL,U,,,all\n');
numKp = (eLinhasMatrizPrincipal*eColunaMatrizPrincipal)+1;%numeração do keypoint 
posZ=MkpCoord(1,4)-espace/2;%posição do primeiro circulo
zc = posZ;
Mc = [];%matriz dos novos kpoints
cnt10= 1;
rc = 0.0900685002;
a=0.1700000;%raiohorizontaltical
b=0.0500000;%raio vertical
cnt11 = eLinhasMatrizPrincipal+1;
for cnt9 = 1:1:2;    
     for t = (5*pi)/2:-(2*pi)/20:((pi/2)+(2*pi/20));
        yc = b*cos(t);
        xc = a*sin(t);
        
        Mc(cnt10,1) = cnt10;    
        Mc(cnt10,2) = xc;
        Mc(cnt10,3) = yc;
        Mc(cnt10,4) = zc(1,1);
        cnt10=cnt10+1;
        fprintf(fid,'K,%s,%s,%s,%s\n',num2str(numKp),num2str(xc),num2str(yc), num2str(zc(1,1)));
        fprintf(fKp,'%s\t\t %s\t\t %s\t\t %d\n',num2str(numKp),num2str(xc),num2str(yc), num2str(zc(1,1)));
        numKp = numKp+1;
        
     end   
        fprintf(fid,'CM,kpconcent%s,KP\n',num2str(cnt9));
        fprintf(fid,'KSEL,U,,,all\n');


        cnt11 = cnt11+1;
        zc = zc-(espace)/2;
        a = a-0.01;
        b = b-0.01;
    
end
 

%ligando lateralmente
fprintf(fid,'LSEL,U,,,all\n'); 
cnt13=((eLinhasMatrizPrincipal*eColunaMatrizPrincipal)+1);
for cnt14=1:1:2    
   for Coluna=1:1:19
        
    fprintf(fid,'SPLINE,%s,%s\n',num2str(cnt13),num2str(cnt13+1)); 
    cnt13=cnt13+1;       
   end
   fprintf(fid,'SPLINE,%s,%s\n',num2str(cnt13),num2str(cnt13-19));
   cnt13=cnt13+1;
   fprintf(fid,'CM,concentLine%s,Line\n',num2str(cnt14));
   fprintf(fid,'LSEL,U,,,all\n');   
end

%verticalmente
cnt14 = ((eLinhasMatrizPrincipal*eColunaMatrizPrincipal)+1);

   for cnt15=1:1:20
      fprintf(fid,'SPLINE,%s,%s\n',num2str(cnt14),num2str(cnt14+20)); 
      cnt14=cnt14+1;
      
   end       
  

   
   
   
   
   fprintf(fid,'allsel,all\n');
   priLinha = ((eLinhasMatrizPrincipal*eColunaMatrizPrincipal)+(eLinhasMatrizPrincipal*(eColunaMatrizPrincipal-1))+1);
   adicionar = 40;
   
   for cnt16=1:1:19
        fprintf(fid,'AL,%s,%s,%s,%s\n',num2str(priLinha),num2str(priLinha+20),num2str(priLinha+adicionar),num2str(priLinha+adicionar+1));
        
        priLinha=priLinha+1;
   end
        fprintf(fid,'AL,%s,%s,%s,%s\n',num2str(priLinha),num2str(priLinha+20),num2str(priLinha+40),num2str(priLinha+21));
   
        
%%        
%ligando a figura com a concentração de tensões
   numKp = (eLinhasMatrizPrincipal*eColunaMatrizPrincipal)+1;
   fprintf(fid,'LSEL,U,,,all\n');
   for Coluna=1:1:eColunaMatrizPrincipal
      fprintf(fid,'L,%s,%s,1\n',num2str(Mkpoint(1,Coluna)),num2str(numKp));
      numKp = numKp+1;
   end       
   fprintf(fid,'CM,ligante,Line\n');
   fprintf(fid,'LSEL,U,,,all\n');
    fprintf(fid,'allsel,all\n');
    
    
priLinha = ((eLinhasMatrizPrincipal*eColunaMatrizPrincipal)+(eLinhasMatrizPrincipal*(eColunaMatrizPrincipal-1))+1);   
priLinhaDois = ((eLinhasMatrizPrincipal*eColunaMatrizPrincipal)+(eLinhasMatrizPrincipal*(eColunaMatrizPrincipal-1))+1);
   for Coluna=1:1:(eColunaMatrizPrincipal-1)
        fprintf(fid,'AL,%s,%s,%s,%s\n',num2str(Coluna),num2str(priLinha),num2str(priLinha+(3*eColunaMatrizPrincipal)),num2str(priLinha+(3*eColunaMatrizPrincipal)+1));
        priLinha=priLinha+1   ;     
   end
        fprintf(fid,'AL,%s,%s,%s,%s\n',num2str(eColunaMatrizPrincipal),num2str(priLinha),num2str(priLinhaDois+(3*eColunaMatrizPrincipal)),num2str(priLinhaDois+(3*eColunaMatrizPrincipal)+(eColunaMatrizPrincipal-1)));
    
fprintf(fid,'AL,concentLine2\n');

fprintf(fid,'ALLSEl,ALL\n');   
fprintf(fid,'IGESOUT,IGESGNew,iges,,0\n');

% 
% fprintf(fid,'CMSEL,S,GRUPOK1\n');
% fprintf(fid,'DK,ALL,All,0.0\n');

fprintf(fid,'SAVE,filetwo,db,,all');
fclose(fKp);
fclose(fid);


%Executar ansys


 
if(opcao==1)
   fcaminho = fopen('javier.txt','r');
   textoCaminho = fscanf(fcaminho,'%c');
else
   fcaminho = fopen('sergio.txt','r');
   textoCaminho = fscanf(fcaminho,'%c');
end
oldpath=cd;
cd 'ForCFX'
dos(textoCaminho);
cd(oldpath)


