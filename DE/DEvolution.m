%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Autor: Andr� Pacheco
% Email: pacheco.comp@gmail.com
% Essa fun��o implementa o algoritmo Differential Evolution. % 
% 
% Entradas: 
%   nPop - tamanho da popula��o
%   dim - dimens�o do problema
%   opt - Struct com as seguintes op��es:
%       opt.CR = taxa de cruzamento (Default = 0.85)
%       opt.F = fator de muta��o (Default = 0.5+0.3*randn())
%       opt.erroMin = erro m�nimo para parar a as itera��es (Default = 0)
%       opt.maxIter = n�mero m�ximo de itera��es Default = 2000)
%       opt.intervalInit = vetor com intervalo de inicializa��o da popula��o.
%           Ex: [-10 10]. (Default: [0 1])
%       
%
% Sa�da:
%   difEv - Struct com os seguintes atributos
%       difEv.nPop = tamanho da popula��o
%       difEv.dim = dimens�o dos individuos (genes)
%       difEv.opt = a estrutura opt com todas as op��es
%       difEv.popC
%           difEv.popC.values = toda popula��o corrente
%           difEv.popC.erros = todas as fitness de cada individuo da popC
%       difEv.popMut
%           difEv.popMut.values = toda popula��o mutada 
%       difEv.popCross
%           difEv.popCross.values = toda popula��o cruzada
%           difEv.popCross.erros = todas as fitness de cada individuo da
%                                  popCross
%       difEv.nextPop
%           difEv.nextPop.values = pr�xima gera��o
%           difEv.nextPop.erros = todas as fitness da pr�xima gera��o
%       difEv.bestInd
%               difEv.bestInd.value = melhor indiv�duo da gera��o
%               difEv.bestInd.erro = valor da fitness para o melhor
%       difEv.allBestErro = todos os valores de fitness para os melhores
%                           individuos de cada gera��o
%
%
%   Este c�digo � aberto para fins acad�micos, mas lembre-se, caso utilize:
%   d� cr�dito a quem merece cr�dito. Qualquer erro encontrado, por favor, 
%   reporte via e-mail para que possa corrigi-lo.
%   Fa�a bom uso =)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function difEv = DEvolution(nPop,dim,varargin)
    
    % Se existe alguma op��o setada, ele mantem as que est�o e coloca os
    % defaults. Caso nem seja passado as op��es, a struct opt � criada com
    % todo os defaults
    if (nargin == 3)
       opt = loadOpt (varargin{1}); 
    else
        opt.CR = 0.85;
        opt.F = 0.5+0.3*randn();
        opt.erroMin = 0;
        opt.maxIter = 2000;
        opt.intervalInit = [0 1];         
    end
 
    % Preechendo a estrutura de sa�da
    difEv.nPop = nPop;
    difEv.dim = dim;
    difEv.opt = opt;    
        
    % Inicializando a popula��o
    pop.values = initPop (difEv);    
    difEv.popC = pop;
    
    for k=1:difEv.opt.maxIter
        
        % Realizando a muta��o
        difEv = mutation (difEv);

        % Realizando o crossover
        difEv = crossover (difEv);

        % Realizando a sele��o. Ap�s a mesma, a popula��o corrente se torna a
        % popula��o dos mais aptos, dos melhores    
        difEv = selection (difEv);
        difEv.popC = difEv.nextPop;

        % Selecionando o melhor indiv�duo
        difEv = getBest (difEv);

        % Armazenando todos os melhores de cada itera��o para controle de
        % converg�ncia do erro
        difEv.allBestsErro(k) = difEv.bestInd.erro;
        
        %Colocando crit�rio de parada se atingir o erro desejado. Caso n�o
        %queira verifica��o de erro, basta comentar esse if
        if (difEv.bestInd.erro == difEv.opt.erroMin)
            break;
        end % if
        
    end % for        
    
    difEv.nIterExec = k;
    
end % difEv

% Fun��o que inicializa a popula��o do DE
function pop = initPop (difEv)
    if (difEv.opt.intervalInit == [0 1])
        pop = rand(difEv.nPop,difEv.dim);        
    else        
        pop = randi(difEv.opt.intervalInit,difEv.nPop,difEv.dim);
    end% if 
end % initPop

% Fun��o que verifica os atributos opcionais e seta os Defaults
function opt = loadOpt (opt)   

    if( isfield(opt,'CR') == 0 )
        opt.CR = 0.85;
    end

    if( isfield(opt,'F') == 0 )
        opt.F = 0.5+0.3*randn();
    end

    if( isfield(opt,'erroMin') == 0 )
        opt.erroMin = 0;
    end

    if( isfield(opt,'maxIter') == 0 )
        opt.maxIter = 2000;
    end

    if( isfield(opt,'intervalInit') == 0 )
        opt.intervalInit = [0 1];
    end
    
end % loadOpt

% Essa fun��o seleciona o melhor individuo dentre a popula��o dos melhores
function difEv = getBest (difEv)
    best = difEv.popC.erros(1);
    bestInd = difEv.popC.values(1,:);
    
    for i=1:difEv.nPop
        if (difEv.popC.erros(i) < best)
            best = difEv.popC.erros(i);
            bestInd = difEv.popC.values(i,:);
        end % if
    end % for
    
    difEv.bestInd.value = bestInd;
    difEv.bestInd.erro = best;    
end

% Fun��o que realiza a muta��o entre os indiv�duos
function difEv = mutation (difEv)
    % Essa � a popula��o que vai sofrer muta��o
    difEv.popMut.values = zeros (difEv.nPop,difEv.dim);
    
    for i=1:difEv.nPop
        
        % Verificando se os indices aleatorios escolhidos s�o diferentes
        while(true)
            alpha = randi([1 difEv.nPop]);  
            betha = randi([1 difEv.nPop]);
            gama = randi([1 difEv.nPop]);
            
            if (alpha ~= betha && gama ~= alpha && gama ~= betha)
                break;
            end % if
            
        end % while       
        
        for j=1:difEv.dim
            difEv.popMut.values(i,j) = difEv.popC.values(alpha,j) + difEv.opt.F*(difEv.popC.values(betha,j) - difEv.popC.values(gama,j));            
        end % for           
    end % for    
end % mutacao

% Fun��o que realiza o cruzamento entre os individuos
function difEv = crossover (difEv)
    % Essa � a popula��o que vai sofrer crossover
    difEv.popCross.values = zeros (difEv.nPop,difEv.dim);
    
    for i=1:difEv.nPop
        k = randi([1 difEv.dim]);
        
        for j=1:difEv.dim
            prob = rand();
            
            if (prob <= difEv.opt.CR || i == k)
               difEv.popCross.values(i,j) = difEv.popMut.values(i,j);               
            else
                difEv.popCross.values(i,j) = difEv.popC.values(i,j);                
            end % if            
        end % for           
    end % for    
end % cruzamento

% Fun��o que realiza a sele��o dos melhores indiv�duos
function difEv = selection (difEv)
    difEv.nextPop.values = zeros (difEv.nPop,difEv.dim);
        
    for i=1:difEv.nPop
        % A fun��o de fitness � definida em um .m externo para facilitar a
        % sua altera��o. Voc� deve verificar como � o formato de dados que
        % a mesma deve receber
        difEv.popC.erros(i) = Fitness (difEv.popC.values(i,:));
        difEv.popCross.erros(i) = Fitness (difEv.popCross.values(i,:));
                
        if (difEv.popC.erros(i) <= difEv.popCross.erros(i))
            difEv.nextPop.values(i,:) = difEv.popC.values(i,:);
            difEv.nextPop.erros(i) = difEv.popC.erros(i);            
        else
            difEv.nextPop.values(i,:) = difEv.popCross.values(i,:);
            difEv.nextPop.erros(i) = difEv.popCross.erros(i);            
        end              
        
    end % for

end % selection
