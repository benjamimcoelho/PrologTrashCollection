:-use_module(arestas).
:-use_module(pontosRecolha).

%problema de estado unico, ambiente deterministico e totalmente
% observ�vel (o estado inicial e final � a garagem)

%estados: ponto em que o cami�o se encontra

%estado inicial: garagem

%estado final: garagem

%operadores:
% movimentar de um ponto para o outro de acordo com a lista de
% adjacencias
%
%
%Teste objetivo: estado atual � a garagem e o cami�o j� descarregou

%custo da solu��o: soma das dist�ncias dos caminhos percorridos ou
%quantidade de lixo que entregou


%---------------TO DO-------------------------
%caminho com mais pontos de recolha (pontos com menos lixo)
%caminho com mais curto
%caminho mais eficiente (mistura de tempo e lixo tratado)
%comparar caminhos em termos de tempo e lixo recolhido

%defini��o do ponto em que a garagem se situa
garagem(15805).

%definicao do ponto onde est� o local de deposicao
deposito(15886).

adjacentes(PontoA,PontoB):-aresta(PontoA,PontoB,_).

adjacentes(PontoA,PontoB,Distancia):-aresta(PontoA,PontoB,Distancia).

getCusto(PontoA,PontoB,Custo):-adjacentes(PontoA,PontoB,Custo).


getCustoCaminho([P1,P2],A):-getCusto(P1,P2,A).
getCustoCaminho([P1,P2|C],A+Custo2):-getCusto(P1,P2,A),getCustoCaminho([P2|C],Custo2).
getCustoCaminho(_,_).

caminhoMaisRapido(Caminho1,Caminho2,R,Custo):-getCustoCaminho(Caminho1,Custo1),getCustoCaminho(Caminho2,Custo2),caminhoMaisRapido2(Caminho1,Caminho2,Custo1,Custo2,Custo,R).

caminhoMaisRapido2(_,C2,Custo1,Custo2,Custo2,C2):-Custo1>Custo2.
caminhoMaisRapido2(C1,_,Custo1,_,Custo1,C1).

caminhoMaisLixo(Caminho1,Caminho2).

% solve( Node, Solution):
%    Solution is an acyclic path (in reverse order) between Node and a goal

solveBF( Node, Solution)  :-
  breadthfirst( [[Node]],  Solution).

solveDF(Node, Solution):-
  depthfirst( [], Node, Solution).

% depthfirst( Path, Node, Solution):
%   extending the path [Node | Path] to a goal gives Solution

depthfirst( Path, Node, [Node|Path] )  :-
   deposito( Node).

depthfirst( Path, Node, Sol)  :-
  adjacentes( Node, Node1),
  nao(membro( Node1, Path)),                % Prevent a cycle
  depthfirst( [Node | Path], Node1, Sol).

% breadthfirst( [ Path1, Path2, ...], Solution):
%   Solution is an extension to a goal of one of paths

breadthfirst( [ [Node | Path] | _], [Node | Path])  :-
  deposito( Node).

breadthfirst( [Path | Paths], Solution)  :-
  extend( Path, NewPaths),
  append( Paths, NewPaths, Paths1),
  breadthfirst( Paths1, Solution).

extend( [Node | Path], NewPaths)  :-
  bagof( [NewNode, Node | Path],
         ( adjacentes( Node, NewNode), nao( membro( NewNode, [Node | Path] )) ),
         NewPaths),
  !.

extend( Path, [] ).

%predicados auxiliares

nao( Questao ) :-
    Questao, !, fail.
nao( Questao ).

membro(X, [X|_]).
membro(X, [_|Xs]):-
	membro(X, Xs).

inverso([],Z,Z).

inverso([H|T],Z,Acc) :- inverso(T,Z,[H|Acc]).



