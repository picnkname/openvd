%% Simula��o
% Este sript tem como objetivo simular o comportamento din�mico de um
% ve�culo simples escolhendo o modelo de pneu e o modelo bicicleta.
%
%% Op��es:
% Este script possibilita a escolha do modelo de pneu e o modelo de
% ve�culo. As op��es e o valor associado para escolha seguem abaixo:
%
% <pneuDoc.html Modelo de pneu>:
%
% # <pneuLinearFun.html Pneu linear>
% # <pneuSadriFun.html Pneu sadri>
% # <pneuPacejkaFun.html Pneu Pacejka>
% # <pneuPacejkaEstFun.html Pneu Pacejka Estendido>
%
% Dados do pneu escolhido:
%
% # <pneuLinearDados.html Dados para o pneu linear>
% # <pneuSadriDadosTaylor.html Dados para o pneu Sadri Taylor>
% # <pneuSadriDadosAjsute.html Dados para o pneu Sadri Ajuste>
% # <pneuPacejkaDados.html Dados para o pneu Pacejka>
%
% <veiculoDoc.html Modelo de ve�culo>:
%
% # <veiculoLinear2gdl.html Linear com 2 GDL>
% # <veiculoNaoLinear2gdl.html N�o linear com 2 GDL>
% # <veiculoNaoLinear3gdl.html N�o linear com 3 GDL>
%
% Dados do modelo de ve�culo escolhido:
%
% # <veiculoDadosScript.html Dados para o ve�culo 1>
% # <veiculoDadosScript14.html Dados para o ve�culo 2>
% # <veiculoDadosScript45.html Dados para o ve�culo 3>
%
%% Sele��o dos modelos e dados
% A sele��o dos modelos e dados � feita atribuindo o valor de escolha.
% Neste caso, o pneu escolhido foi o modelo de pacejka (3) e o ve�culo com 3
% GDL e tratamento do �ngulo de deriva (4). 

clear all

pneuModelo = 2; % Escolha do modelo de pneu
pneuDados = 3; % Escolha dos dados do pneu

veiculoModelo = 1; % Escolha do modelo de ve�culo
veiculoDados = 1; % Escolha dos dados do ve�culo

%% Seletor
% Definindo as constantes necess�rias para a integra��o. Ver <seletor.html
% Seletor>

[pneuFun,veiculoFun,pneuDadosFrente,pneuDadosTras,veiculoDadosVet,pneuTxt,veiculoTxt]...
    = seletor(pneuModelo,pneuDados,veiculoModelo,veiculoDados);

%% Dados b�sicos da integra��o (integrador � chamado mais abaixo)
% Dados para a integra��o num�rica:

T = 5;              % Tempo total de simula��o
TSPAN = 0:T/35:T;   % Vetor de tempo de an�lise

% M�dulo do vetor velocidade. Quando o modelo tem 2gdl � a velocidade
% prescrita. Quando o modelo tem 3gdl � a condi��o inicial.
v = veiculoDadosVet(5);

r0 = 3;         % velocidade angular inicial [rad/s]
ALPHAT0 = 0;    % �ngulo de deriva inicical [rad]

x0 = [r0 ; ALPHAT0];    % Condi��o inicial dos estados
x0 = [x0 ; 0];          % Condi��o da orientacao
x0 = [x0 ; 0 ; 0];      % Condi��o inicial da trajet�ria

if veiculoModelo == 3 || veiculoModelo == 4
	% Para que o integrador consiga rodar no modelo com 3 gdl � necess�rio
	% acrescentar uma condi��o inicial referente ao estado velocidade "v".
	% Ou seja, a velocidade que era prescrita antes agora � condi��o
	% inicial.
	x0 = [x0 ; v]; % Condi��o inicial da velocidade
end

%% Integrando
% Utilizando a ode45:

[TOUT,XOUT] = ode45(@(t,x) veiculoFun(t,x,pneuFun,pneuDadosFrente,...
                    pneuDadosTras,veiculoDadosVet),TSPAN,x0); 

%% Reconstru��o de vari�veis

dPSI = XOUT(:,1);
ALPHAT = XOUT(:,2);

a = veiculoDadosVet(3);
b = veiculoDadosVet(4);
DELTA = veiculoDadosVet(6);

if veiculoModelo == 1
	% �ngulos de deriva	
	ALPHAF = ALPHAT + a*dPSI/v - DELTA; % Dianteiro
	ALPHAR = ALPHAT - b*dPSI/v;         % Traseiro
	% M�dulo dos vetores velocidade
	VT = ones(length(dPSI),1)*v; % Centro de massa T

	% �ngulo de deriva para anima��o
	% Isso � feito pq para os modelos 3 e 4 a contagem do angulo � diferente da orienta��o do vetor para anima��o
	ALPHAFA = ALPHAF + DELTA; % Tem que somar o delta por que � o �ngulo do vetor vel F em rela��o ao plano longitudinal
	ALPHARA = ALPHAR; 
end

if veiculoModelo == 2
	% Angulos de deriva n�o linear
	ALPHAF = atan2((v*sin(ALPHAT) + a*dPSI),(v*cos(ALPHAT))) - DELTA; % Dianteiro
	ALPHAR = atan2((v*sin(ALPHAT) - b*dPSI),(v*cos(ALPHAT)));         % Traseiro
	% Vetor velocidade do centro de massa
	VT = ones(length(dPSI),1)*v; % Centro de massa T

	% �ngulo de deriva para anima��o
	% Isso � feito pq para os modelos 3 e 4 a contagem do angulo � diferente da orienta��o do vetor para anima��o
	ALPHAFA = ALPHAF + DELTA; 
	ALPHARA = ALPHAR; 
end

if veiculoModelo == 3
	% Vetor velocidade do centro de massa
	VT = XOUT(:,6);
	v = VT;
	% Angulos de deriva n�o linear
	ALPHAF = atan2((v.*sin(ALPHAT) + a*dPSI),(v.*cos(ALPHAT))) - DELTA; % Dianteiro
	ALPHAR = atan2((v.*sin(ALPHAT) - b*dPSI),(v.*cos(ALPHAT)));         % Traseiro
    
	% �ngulo de deriva para anima��o
	% Isso � feito pq para os modelos 3 e 4 a contagem do angulo � diferente da orienta��o do vetor para anima��o
	ALPHAFA = ALPHAF + DELTA; 
	ALPHARA = ALPHAR; 
end

% Modulo do vetor velocidade
VF = sqrt((VT.*sin(ALPHAT) + a*dPSI).^2 + (VT.*cos(ALPHAT)).^2); % Dianteiro
VR = sqrt((VT.*sin(ALPHAT) - b*dPSI).^2 + (VT.*cos(ALPHAT)).^2); % Traseiro

%% Resultados
% As figuras de resultados:
%

f1 = figure(1);
box on
% Plotar o gr�fico com eixo vertical na esquerda e direita
[AX,H1,H2] = plotyy(TOUT,XOUT(:,1)*180/pi,TOUT,XOUT(:,2)*180/pi); 
% Mudando as cores dos eixos (Padr�o vem com cores iguais aos eixos)
set(AX(1),'YColor',[0 0 0]);
set(AX(2),'YColor',[0 0 0]);
set(H1,'Color',[1 0 0],'Marker','o','MarkerFaceColor',[1 0 0],'MarkerSize',7)
set(H2,'Color',[0 1 0],'Marker','s','MarkerFaceColor',[0 1 0],'MarkerSize',7)
title(strcat('Estados X Tempo - Pneu: ',pneuTxt,';',' Ve�culo: ',veiculoTxt));
ylabel(AX(1),'dPSI [grau/s]')
ylabel(AX(2),'ALPHAT [grau]')
xlabel('Tempo [s]')
legend('dPSI','ALPHAT');

f2 = figure(2);
box on
H1 = plot(TOUT,XOUT(:,3)*180/pi,'r');
set(H1,'Color',[1 0 0],'Marker','o','MarkerFaceColor',[1 0 0],'MarkerSize',7)
title('Orienta��o X Tempo')
ylabel('PSI [grau]')
xlabel('Tempo [s]')

f3 = figure(3);
hold on
box on
H1 = plot(TOUT,ALPHAF*180/pi,'r');
H2 = plot(TOUT,ALPHAR*180/pi,'g');
set(H1,'Color',[1 0 0],'Marker','o','MarkerFaceColor',[1 0 0],'MarkerSize',7)
set(H2,'Color',[0 1 0],'Marker','s','MarkerFaceColor',[0 1 0],'MarkerSize',7)
title('�ngulos de deriva X Tempo')
ylabel('�ngulo [grau]')
xlabel('Tempo [s]')
legend('Frente','Tras')

f4 = figure(4);
hold on
box on
H1 = plot(TOUT,VT,'r');
set(H1,'Color',[1 0 0],'Marker','o','MarkerFaceColor',[1 0 0],'MarkerSize',7)
title('Velocidade longitudinal X Tempo ')
ylabel('Velocidade [m/s]')
xlabel('Tempo [s]')

f5 = figure(5);
hold on
box on
axis equal
H1 = plot(XOUT(:,2),XOUT(:,1));
set(H1,'Color',[1 0 0],'Marker','o','MarkerFaceColor',[1 0 0],'MarkerSize',7)
plot(0,0,'k+')
plot(pi,0,'k+')
plot(-pi,0,'k+')
title('Plano de fase')
ylabel('dPSI [grau/s]')
xlabel('ALPHAT [grau]')
legend('Trajet�ria','Ponto fixo')

f6 = figure(6);
box on
axis equal
H1 = plot(XOUT(:,4),XOUT(:,5),'r');
set(H1,'Color',[1 0 0],'Marker','o','MarkerFaceColor',[1 0 0],'MarkerSize',7)
title('Trajet�ria')
ylabel('Dist�ncia [m]')
xlabel('Dist�ncia [m]')

% %% Salvando as figuras
% print(f1,'resultados/simulacao/estados.pdf','-dpdf')
% print(f2,'resultados/simulacao/orientacao.pdf','-dpdf')
% print(f3,'resultados/simulacao/Trajetoria.pdf','-dpdf')
% print(f4,'resultados/simulacao/deriva.pdf','-dpdf')

frame(XOUT,TOUT,ALPHAFA,ALPHARA,VF,VR,VT,veiculoDadosVet,'r'); % Cor vermelha do carro

%% Anima��o
% Executando o script de anima��o

animacao(XOUT,TOUT,ALPHAFA,ALPHARA,VF,VR,VT,veiculoDadosVet);

%% Ver tamb�m
%
% <index.html In�cio> | <veiculoDoc.html Modelo ve�culo> | <frame.html
% Frame> | <seletor.html seletor>
%