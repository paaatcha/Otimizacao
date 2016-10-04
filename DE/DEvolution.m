%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Autor: André Pacheco
% Email: pacheco.comp@gmail.com
% Essa função implementa o algoritmo Differential Evolution. % 
% 
% Entradas: 
%   nPop - tamanho da população
%   dim - dimensão do problema
%   opt - Struct com as seguintes opções:
%       opt.CR = taxa de cruzamento (Default = 0.85)
%       opt.F = fator de mutação (Default = 0.5+0.3*randn())
%       opt.erroMin = erro mínimo para parar a as iterações (Default = 0)
%       opt.maxIter = número máximo de iterações Default = 2000)
%       opt.intervalInit = vetor com intervalo de inicialização da população.
%           Ex: [-10 10]. (Default: [0 1])
%       
%
% Saída:
%   difEv - Struct com os seguintes atributos
%       difEv.nPop = tamanho da população
%       difEv.dim = dimensão dos individuos (genes)
%       difEv.opt = a estrutura opt com todas as opções
%       difEv.popC
%           difEv.popC.values = toda população corrente
%           difEv.popC.erros = todas as fitness de cada individuo da popC
%       difEv.popMut
%           difEv.popMut.values = toda população mutada 
%       difEv.popCross
%           difEv.popCross.values = toda população cruzada
%           difEv.popCross.erros = todas as fitness de cada individuo da
%                                  popCross
%       difEv.nextPop
%           difEv.nextPop.values = próxima geração
%           difEv.nextPop.erros = todas as fitness da próxima geração
%       difEv.bestInd
%               difEv.bestInd.value = melhor indivíduo da geração
%               difEv.bestInd.erro = valor da fitness para o melhor
%       difEv.allBestErro = todos os valores de fitness para os melhores
%                           individuos de cada geração
%
%
%   Este código é aberto para fins acadêmicos, mas lembre-se, caso utilize:
%   dê crédito a quem merece crédito. Qualquer erro encontrado, por favor, 
%   reporte via e-mail para que possa corrigi-lo.
%   Faça bom uso =)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function difEv = DEvolution(nPop,dim,varargin)
    
    % Se existe alguma opção setada, ele mantem as que estão e coloca os
    % defaults. Caso nem seja passado as opções, a struct opt é criada com
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
 
    % Preechendo a estrutura de saída
    difEv.nPop = nPop;
    difEv.dim = dim;
    difEv.opt = opt;    
        
    % Inicializando a população
    pop.values = initPop (difEv);    
    difEv.popC = pop;
    
    for k=1:difEv.opt.maxIter
        
        % Realizando a mutação
        difEv = mutation (difEv);

        % Realizando o crossover
        difEv = crossover (difEv);

        % Realizando a seleção. Após a mesma, a população corrente se torna a
        % população dos mais aptos, dos melhores    
        difEv = selection (difEv);
        difEv.popC = difEv.nextPop;

        % Selecionando o melhor indivíduo
        difEv = getBest (difEv);

        % Armazenando todos os melhores de cada iteração para controle de
        % convergência do erro
        difEv.allBestsErro(k) = difEv.bestInd.erro;
        
        %Colocando critério de parada se atingir o erro desejado. Caso não
        %queira verificação de erro, basta comentar esse if
        if (difEv.bestInd.erro == difEv.opt.erroMin)
            break;
        end % if
        
    end % for        
    
    difEv.nIterExec = k;
    
end % difEv

% Função que inicializa a população do DE
function pop = initPop (difEv)
    if (difEv.opt.intervalInit == [0 1])
        pop = rand(difEv.nPop,difEv.dim);        
    else        
        pop = randi(difEv.opt.intervalInit,difEv.nPop,difEv.dim);
    end% if 
end % initPop

% Função que verifica os atributos opcionais e seta os Defaults
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

% Essa função seleciona o melhor individuo dentre a população dos melhores
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

% Função que realiza a mutação entre os indivíduos
function difEv = mutation (difEv)
    % Essa é a população que vai sofrer mutação
    difEv.popMut.values = zeros (difEv.nPop,difEv.dim);
    
    for i=1:difEv.nPop
        
        % Verificando se os indices aleatorios escolhidos são diferentes
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

% Função que realiza o cruzamento entre os individuos
function difEv = crossover (difEv)
    % Essa é a população que vai sofrer crossover
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

% Função que realiza a seleção dos melhores indivíduos
function difEv = selection (difEv)
    difEv.nextPop.values = zeros (difEv.nPop,difEv.dim);
        
    for i=1:difEv.nPop
        % A função de fitness é definida em um .m externo para facilitar a
        % sua alteração. Você deve verificar como é o formato de dados que
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
