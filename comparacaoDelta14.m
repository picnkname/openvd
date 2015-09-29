%% Compara��o - DELTA = 14 graus
% Este script mostra o desempenho dos ve�culos para um �ngulo de
% ester�amento de 14 graus e condi��es iniciais nulas.
%
%% Vai ser o n�mero de figuras
veiculoModeloVet = [1 2 3];
veiculoModeloTxt = char(' Linear 2 GDL',' N�o linear 2 GDL',' N�o linear 3 GDL');
%veiculoModeloTitulo4 = 'veiculoNaoLinear3gdlExtendido';

veiculoDados = 2;

% Vai ser o n�mero de curvas em cada figura
pneuModeloVet = [1 2 3]; % Modelos 1-Linear; 2-Sadri; 3-Pacejka
pneuModeloTxt = char('Linar','Sadri','Pacejka');
pneuModeloCor = char('r','g','b');
pneuModeloMarcador = char('o','s','d');
pneuDadosVet = [1 2 3];

for i = 1:length(veiculoModeloVet)
	for j = 1:length(pneuModeloVet)
		
		veiculoModelo = veiculoModeloVet(i);

		pneuModelo = pneuModeloVet(j);
		pneuDados = pneuDadosVet(j);
		
		%% Dados b�sicos da integra��o (integrador � chamado mais abaixo)
		% 
		T = 3; % Tempo total de simula��o
		TSPAN = 0:T/40:T; % Vetor de tempo de an�lise

		r0 = 0; % velocidade angular [rad/s]
		vy0 = 0; % velocidade lateral [m/s]
		v = 20; % velocidade longitudinal [m/s] -> ATEN��O: Tem que estar de acordo com os dados dos ve�culos com 2 gdl
		ALPHAT0 = asin(vy0/v); % convers�o de vy0 para ALPHAT
		x0 = [r0 ; ALPHAT0]; % Condi��o inicial dos estados
		x0 = [x0 ; 0]; % Condi��o da orientacao
		x0 = [x0 ; 0 ; 0]; % Condi��o inicial da trajet�ria
		if veiculoModelo == 3
			% Para que o integrador consiga rodar no modelo com 3 gdl � necess�rio acrescentar uma
			% condi��o inicial referente ao estado velocidade "v".
			% Ou seja, a velocidade que era prescrita antes agora � condi��o inicial
			x0 = [x0 ; v]; % Condi��o inicial da velocidade
		end

		[pneuFun,veiculoFun,pneuDadosFrente,pneuDadosTras,veiculoDadosVet,pneuTxt,veiculoTxt] = seletor(pneuModelo,pneuDados,veiculoModelo,veiculoDados);

		[TOUT,XOUT] = ode45(@(t,x) veiculoFun(t,x,pneuFun,pneuDadosFrente,pneuDadosTras,veiculoDadosVet),TSPAN,x0); 

		figure(i)
		hold on
		H1 = plot(TOUT,XOUT(:,1)*180/pi,pneuModeloCor(j));
		set(H1,'Marker',pneuModeloMarcador(j),'MarkerFaceColor',pneuModeloCor(j),'MarkerSize',7)
		title('Velocidade angular X Tempo')
		title(strcat('Vel. angular - Ester�amento: 14 graus - Ve�culo: ',veiculoModeloTxt(i,:)));
		ylabel('dPSI [grau/s]')
		xlabel('Tempo [s]')
		if j == length(pneuModeloVet)
		legend(pneuModeloTxt(1,:),pneuModeloTxt(2,:),pneuModeloTxt(3,:),'Location','SouthEast')
		end

		figure(i + 10);
		hold on
		axis equal
		H1 = plot(XOUT(:,4),XOUT(:,5),pneuModeloCor(j));
		set(H1,'Marker',pneuModeloMarcador(j),'MarkerFaceColor',pneuModeloCor(j),'MarkerSize',7)
		title(strcat('Trajet�ria - Ester�amento: 14 graus - Ve�culo: ',veiculoModeloTxt(i,:)));
		ylabel('Dist�ncia [m]')
		if j == length(pneuModeloVet)
		legend(pneuModeloTxt(1,:),pneuModeloTxt(2,:),pneuModeloTxt(3,:),'Location','SouthEast')
		end

	end
end

%% Ver tamb�m
%
% <inicio.html In�cio> | <veiculoDoc.html Modelo ve�culo>
%