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


menorPonto(P1,C1,_,C2,R,C):-C1<C2,R is P1, C is C1.
menorPonto(_,_,P2,C2,R,C):-R is P2, C is C2.

pontoMaisProximo(Visitados,Atual,R,C):-findall((X,Y),aresta(Atual,X,Y),Z),pontoMaisProximo2(Visitados,Z,R,C,1).


pontoMaisProximo2(Visitados,[(X,Y)|T],R,C,1):-nao(membro(X,Visitados)),pontoMaisProximo2(Visitados,T,R2,C2,0),menorPonto(X,Y,R2,C2,R,C).

pontoMaisProximo2(Visitados,[_|T],R,C,1):-pontoMaisProximo2(Visitados,T,R,C,1).

pontoMaisProximo2(Visitados,[(X,Y)|T],R,C,0):-nao(membro(X,Visitados)),pontoMaisProximo2(Visitados,T,R2,C2,0),menorPonto(X,Y,R2,C2,R,C).

pontoMaisProximo2(Visitados,[_|T],R,C,0):-pontoMaisProximo2(Visitados,T,R,C,0).

pontoMaisProximo2(_,[],9999,9999,_).


menorLixo(P1,L1,_,L2,R,L):-L1<L2,R is P1,L is L1.
menorLixo(_,_,P2,L2,R,L):-R is P2, L is L2.

pontoMenosLixo(Visitados,Tipo,R,L):-findall(X,pontoRecolha(X,_,_,_,_,_),Z),pontoMenosLixo2(Visitados,Tipo,Z,R,L).

pontoMenosLixo2(Visitados,Tipo,[H|T],R,L):-not(membro(H,Visitados)),getQuantidadeLixo(H,Tipo,L1),pontoMenosLixo2(Visitados,Tipo,T,R2,L2),menorLixo(H,L1,R2,L2,R,L).

pontoMenosLixo2(Visitados,Tipo,[_|T],R,L):-pontoMenosLixo2(Visitados,Tipo,T,R,L).

pontoMenosLixo2(_,_,[],9999,9999999).



dfs(Orig,Dest,Cam,Custo):-dfs(Orig,Dest,[Orig],Cam,Custo).

dfs(Dest,Dest,LA,Cam,0):-reverse(LA,Cam).

dfs(Act,Dest,LA,Cam,Custo):-aresta(Act,X,C1),
                     \+ member(X,LA),
                     dfs(X,Dest,[X|LA],Cam,C2),Custo is C1+C2.


bfs(Orig,Dest,Cam):-bfs2(Dest,[[Orig]],Cam).

bfs2(Dest,[[Dest|T]|_],Cam):-reverse([Dest|T],Cam).

bfs2(Dest,[LA|Outros],Cam):-LA=[Act|_],
                        findall([X|LA],(Dest\==Act,aresta(Act,X,_),
                        \+member(X,LA)),Novos),
                        append(Outros,Novos,Todos),
                        bfs2(Dest,Todos,Cam).


bestfs(Orig,Dest,Cam,Custo):-bestfs2(Dest,(0,[Orig]),Cam,Custo).

bestfs2(Dest,(Custo,[Dest|T]),Cam,Custo):-!,reverse([Dest|T],Cam).

bestfs2(Dest,(Ca,LA),Cam,Custo):-LA=[Act|_],findall((EstX,CaX,[X|LA]),
                 (aresta(Act,X,CX),\+member(X,LA),estimativa(X,Dest,EstX),
                  CaX is Ca+CX),Novos),
                  sort(Novos,NovosOrd),
                  NovosOrd = [(_,CM,Melhor)|_],
                  bestfs2(Dest,(CM,Melhor),Cam,Custo).


bnb(Orig,Dest,Cam,Custo):-bnb2(Dest,[(0,[Orig])],Cam,Custo).

bnb2(Dest,[(Custo,[Dest|T])|_],Cam,Custo):-reverse([Dest|T],Cam).

bnb2(Dest,[(Ca,LA)|Outros],Cam,Custo):-LA=[Act|_],
                      findall((CaX,[X|LA]),
                      (Dest\==Act,aresta(Act,X,CustoX),\+ member(X,LA),
                       CaX is CustoX + Ca),Novos),
                      append(Outros,Novos,Todos),
                      sort(Todos,TodosOrd),
                      bnb2(Dest,TodosOrd,Cam,Custo).


aStar(Orig,Dest,Cam,Custo):-aStar2(Dest,[(_,0,[Orig])],Cam,Custo).

aStar2(Dest,[(_,Custo,[Dest|T])|_],Cam,Custo):-reverse([Dest|T],Cam).

aStar2(Dest,[(_,Ca,LA)|Outros],Cam,Custo):-LA=[Act|_],findall((CEX,CaX,[X|LA]),
       (Dest\==Act,aresta(Act,X,CustoX),\+ member(X,LA),
        CaX is CustoX + Ca, estimativa(X,Dest,EstX),
        CEX is CaX +EstX),Novos),
        append(Outros,Novos,Todos),
        sort(Todos,TodosOrd),
        aStar2(Dest,TodosOrd,Cam,Custo).

estimativa(Nodo1,Nodo2,Estimativa):-
pontoRecolha(Nodo1,X1,Y1,_,_,_),
pontoRecolha(Nodo2,X2,Y2,_,_,_),
Estimativa is sqrt((X1-X2)^2+(Y1-Y2)^2).






%Gerar os circuitos de recolha tanto indiferenciada como seletiva, caso existam, que
%cubram um determinado território;

gerarCircuitoDF([H,P],Solucao):-solveDF(H,P,Solucao).
gerarCircuitoDF([H,P|T],Solucao):-solveDF(H,P,Solucao1),gerarCircuitoDF([P|T],Solucao2),append(Solucao2,Solucao1,Solucao).

gerarTodosCircuitosDF(Lista,Solucoes):-findall(X,gerarCircuitoDF(Lista,X),Solucoes).

gerarCircuitoBF([H,P],Solucao):-solveBF(H,P,Solucao).
gerarCircuitoBF([H,P|T],Solucao):-solveBF(H,P,Solucao1),gerarCircuitoBF([P|T],Solucao2),append(Solucao2,Solucao1,Solucao).

gerarTodosCircuitosBF(Lista,Solucoes):-findall(X,gerarCircuitoBF(Lista,X),Solucoes).


gerarCircuitoMaisRapidoDF(Solucao,Custo,Capacidade):-garagem(G),pontoMaisProximo([],G,R,C),dfs(G,R,S1,C1),getQuantidadeLixo(R,'Lixos',Capacidade),gerarCircuitoMaisRapidoDF2(S2,C2,R,[R],Capacidade),append(S1,S2,Solucao),Custo is C1+C2.

gerarCircuitoMaisRapidoDF2(Solucao,Custo,Atual,_,Capacidade):-Capacidade > 15000,deposito(D),dfs(Atual,D,S1,C1),garagem(G),dfs(D,G,S2,C2),append(S1,S2,Solucao),Custo is C1+C2.
gerarCircuitoMaisRapidoDF2(Solucao,Custo,Atual,Visitados,Capacidade):-pontoMaisProximo(Visitados,Atual,R,C),dfs(Atual,R,S1,C1),getQuantidadeLixo(R,'Lixos',Cap1),Capacidade is Capacidade + Cap1,gerarCircuitoDF2(S2,C2,R,R|Visitados,Capacidade),append(S1,S2,Solucao),Custo is C1+C2.



%predicados auxiliares

nao( Questao ) :-
    Questao, !, fail.
nao( Questao ).

membro(X, [X|_]).
membro(X, [_|Xs]):-
	membro(X, Xs).

inverso([],Z,Z).

inverso([H|T],Z,Acc) :- inverso(T,Z,[H|Acc]).




