%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Autor: André Pacheco
% Email: pacheco.comp@gmail.com
% Essa função implementa o algoritmo genético (GA). Para setar a função objetivo edite o arquivo
% FuncaoObjetivo.m; Além disso, este código considera como critério de parada apenas o número de 
% iteração. Para verificar o um erro mínimo, basta adicionar um if-break no loop principal.
% 
% Entradas: 
%	dim = dimensão do problema
% 	nPop = tamanho da população
% 	vInit = Intervalado de inicialização: [-32 32] por exemplo
% 	nIter = numero de iterações
%       
%
% Saída:
%   melhor = Melhor valor encontrado da otimização
%   pos_   = Individuos que geraram o melhor valor 
%   todos_melhores = Histórico da otimização
%
%
%   Este código é aberto para fins acadêmicos, mas lembre-se, caso utilize:
%   dê crédito a quem merece crédito. Qualquer erro encontrado, por favor, 
%   reporte via e-mail para que possa corrigi-lo.
%   Faça bom uso =)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [melhor pos_ todos_melhores] = GA (dim,nPop,vInit,nInt)
	% Setando as constantes
	taxa_crossover = 0.65;
	taxa_mutacao = 0.1;
	mi = 0;
	sigma = 1;

	populacao = randi ([vInit(1) vInit(2)],nPop,dim+1); % a última posição contém o valor de fitness
	todos_melhores = zeros(nInt,1);	
	
	melhor = funcaoObjetivo (populacao(1,:)); % somente para inicialização
	pos = 1;
	
	for i=1:nInt	
		[melhor pos populacao] = fitness (populacao,nPop,dim,melhor,pos);
		populacao_intermed = selecao (populacao,nPop,dim);
		populacao = crossover (populacao_intermed,dim,nPop,taxa_crossover,mi,sigma);
		populacao = mutacao (populacao,dim,nPop,taxa_mutacao,mi,sigma);
		todos_melhores (i) = melhor;
	end %for
	
	pos_ = populacao(pos,1:dim);
	plot(todos_melhores);

end %function

function [melhor pos populacao] = fitness (populacao,nPop,dim,melhor,pos)
	for i=1:nPop
		fit = funcaoObjetivo (populacao(i,:));
		if (fit < melhor)
			melhor = fit;
			pos = i;
		end%if
		populacao(i,dim+1) = fit;
	end %for	
end %fitness

function populacao2 = selecao (populacao,nPop,dim)
	populacao2 = zeros (nPop,dim+1);
	for i=1:nPop
		nAlet1 = randi([1 nPop]);
		nAlet2 = randi([1 nPop]);
		if (populacao(nAlet1,dim+1) < populacao(nAlet2,dim+1))
			populacao2(i,:) = populacao(nAlet1,:);
		else
			populacao2(i,:) = populacao(nAlet2,:);
		end %if		
	end%for	
end %selecao

function populacao2 = crossover (populacao,dim,nPop,taxa_crossover,mi,sigma)
	populacao2 = zeros (nPop,dim+1);
	for i=1:nPop
		prob = rand();
		n1 = randi([1 nPop]);
		n2 = randi([1 nPop]);		
		Beta = normrnd(mi,sigma);
		if (prob <= taxa_crossover)
			populacao2(i,:) = Beta*(populacao(n1,:)) + (1-Beta)*(populacao(n2,:));
			populacao2(i+1,:) = (1-Beta)*(populacao(n1,:)) + Beta*(populacao(n2,:));
		else
			populacao2(i,:) = populacao(n1);
			populacao2(i+1) = populacao(n2);
		end %if		
	end %for i	
end %crossover

function populacao = mutacao (populacao,dim,nPop,taxa_mutacao,mi,sigma)
	for i=1:nPop
		prob = rand();
		if (prob <= taxa_mutacao)
			Beta = normrnd(mi,sigma);
			populacao(i,:) = populacao(i,:)*Beta;			
		end %if		
	end %for i	
end %mutacao



