:-use_module(arestas).
:-use_module(pontosRecolha).

%problema de estado unico, ambiente deterministico e totalmente
% observável (o estado inicial e final é a garagem)

%estados: ponto em que o camião se encontra

%estado inicial: garagem

%estado final: garagem

%operadores:
% movimentar de um ponto para o outro de acordo com a lista de
% adjacencias
%
%
%Teste objetivo: estado atual é a garagem e o camião já descarregou

%custo da solução: soma das distãncias dos caminhos percorridos ou
%quantidade de lixo que entregou


%---------------TO DO-------------------------
%caminho com mais pontos de recolha (pontos com menos lixo)
%caminho com mais curto
%caminho mais eficiente (mistura de tempo e lixo tratado)
%comparar caminhos em termos de tempo e lixo recolhido

%definição do ponto em que a garagem se situa
garagem(15805).

%definicao do ponto onde está o local de deposicao
deposito(15886).


adjacentes(PontoA,PontoB):-aresta(PontoA,PontoB,_).

adjacentes(PontoA,PontoB,Distancia):-aresta(PontoA,PontoB,Distancia).

getCusto(PontoA,PontoB,Custo):-adjacentes(PontoA,PontoB,Custo).

somaQuantidades([],0).
somaQuantidades([H|T],Res):-somaQuantidades(T,R2),Res is H + R2.

getContentores(Ponto,R):-pontoRecolha(Ponto,_,_,_,_,R).

getQuantidadeLixo(Ponto,Tipo,Res):-getContentores(Ponto,Contentores),findall(X,membro((Tipo,_,X),Contentores),Quantidades),somaQuantidades(Quantidades,Res).


getQuantidadeLixoCaminho([],_,0).
getQuantidadeLixoCaminho([H|T],Tipo,Res):-getQuantidadeLixo(H,Tipo,X),getQuantidadeLixoCaminho(T,Tipo,X2),Res is X+X2.

getCustoCaminho([P1,P2],A):-getCusto(P1,P2,A).
getCustoCaminho([P1,P2|C],Res):-getCusto(P1,P2,A),getCustoCaminho([P2|C],Custo2),Res is A+Custo2.
getCustoCaminho(_,_).

caminhoMaisRapido(Caminho1,Caminho2,R,Custo):-getCustoCaminho(Caminho1,Custo1),getCustoCaminho(Caminho2,Custo2),caminhoMaisRapido2(Caminho1,Caminho2,Custo1,Custo2,Custo,R).

caminhoMaisRapido2(_,C2,Custo1,Custo2,Custo2,C2):-Custo1>Custo2.
caminhoMaisRapido2(C1,_,Custo1,_,Custo1,C1).



caminhoMaisLixo(C1,C2,Tipo,Res,Qt):-getQuantidadeLixoCaminho(C1,Tipo,L1),getQuantidadeLixoCaminho(C2,Tipo,L2),caminhoMaisLixo2(C1,L1,C2,L2,Res,Qt).

caminhoMaisLixo2(C1,L1,_,L2,C1,L1):-L1>L2.
caminhoMaisLixo2(_,_,C2,L2,C2,L2).

pontosIguais(A,A).

% solve( Node, Solution):
%    Solution is an acyclic path (in reverse order) between Node and a goal

solveBF( Node, Objetivo ,Solution):-
  breadthfirst( [[Node]],Objetivo,  Solution).

solveDF(Node,Objetivo, Solution):-
  depthfirst( [], Node, Objetivo, Solution).

% depthfirst( Path, Node, Solution):
%   extending the path [Node | Path] to a goal gives Solution

depthfirst( Path, Node,Objetivo, [Node|Path] ):-pontosIguais(Node,Objetivo).

depthfirst( Path, Node,Objetivo, Sol)  :-
  adjacentes( Node, Node1),
  nao(membro( Node1, Path)),                % Prevent a cycle
  depthfirst( [Node | Path], Node1,Objetivo, Sol).

% breadthfirst( [ Path1, Path2, ...], Solution):
%   Solution is an extension to a goal of one of paths

breadthfirst( [ [Node | Path] | _],Objetivo, [Node | Path])  :-
  pontosIguais( Node,Objetivo).

breadthfirst( [Path | Paths],Objetivo, Solution)  :-
  extend( Path, NewPaths),
  append( Paths, NewPaths, Paths1),
  breadthfirst( Paths1,Objetivo, Solution).

extend( [Node | Path], NewPaths)  :-
  bagof( [NewNode, Node | Path],
         ( adjacentes( Node, NewNode), nao( membro( NewNode, [Node | Path] )) ),
         NewPaths),
  !.

extend( Path, [] ).



%Gerar os circuitos de recolha tanto indiferenciada como seletiva, caso existam, que
%cubram um determinado território;

gerarCircuitoDF([H,P],Solucao):-solveDF(H,P,Solucao).
gerarCircuitoDF([H,P|T],Solucao):-solveDF(H,P,Solucao1),gerarCircuitoDF([P|T],Solucao2),append(Solucao2,Solucao1,Solucao).

gerarTodosCircuitosDF(Lista,Solucoes):-findall(X,gerarCircuitoDF(Lista,X),Solucoes).

gerarCircuitoBF([H,P],Solucao):-solveBF(H,P,Solucao).
gerarCircuitoBF([H,P|T],Solucao):-solveBF(H,P,Solucao1),gerarCircuitoBF([P|T],Solucao2),append(Solucao2,Solucao1,Solucao).

gerarTodosCircuitosBF(Lista,Solucoes):-findall(X,gerarCircuitoBF(Lista,X),Solucoes).



%predicados auxiliares

nao( Questao ) :-
    Questao, !, fail.
nao( Questao ).

membro(X, [X|_]).
membro(X, [_|Xs]):-
	membro(X, Xs).

inverso([],Z,Z).

inverso([H|T],Z,Acc) :- inverso(T,Z,[H|Acc]).




