:-use_module(arestas).
:-use_module(pontosRecolha).

:- set_prolog_flag(stack_limit, 4_000_000_000).



%definição do ponto em que a garagem se situa
garagem(15805).

%definicao do ponto onde está o local de deposicao
deposito(15886).

numero_pontos_a_visitar(1).

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

bfsS(Orig,Dest,Cam):-bfsS2(Dest,[[Orig]],Cam).

bfsS2(Dest,[[Dest|T]|_],Cam):-reverse([Dest|T],Cam).

bfsS2(Dest,[LA|Outros],Cam):-LA=[Act|_],
                        findall([X|LA],(Dest\==Act,aresta(Act,X,_),
                        \+member(X,LA)),Novos),
                        append(Outros,Novos,Todos),
                        bfsS2(Dest,Todos,Cam).



bfs(Orig,Dest,Cam,Custo):-bfs2(Dest,[[Orig]],Cam,Custo).

bfs2(Dest,[[Dest|T]|_],Cam,Custo):-reverse([Dest|T],Cam),getCustoCaminho(Cam,Custo).

bfs2(Dest,[LA|Outros],Cam,Custo):-LA=[Act|_],
                        findall([X|LA],(Dest\==Act,aresta(Act,X,_),
                        \+member(X,LA)),Novos),
                        append(Outros,Novos,Todos),
                        bfs2(Dest,Todos,Cam,Custo).


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


gulosa(Partida, Destino,Caminho,Custo) :-
    %statistics(runtime,[Start|_]),
    estimativa(Partida,Destino ,Estimativa),
    gulosa2([[Partida]/0/Estimativa],Destino,InvCaminho/Custo/_),
    reverse(InvCaminho, Caminho).
    %,
    %statistics(runtime,[Stop|_]),
    %Runtime is Stop-Start,
    %write("Tempo: "),write(Runtime).

gulosa2(Caminhos, Destino ,Caminho) :-
    melhorCaminhoGul(Caminhos, Caminho),
    Caminho = [Nodo|_]/_/_,
    Nodo == Destino.

gulosa2(Caminhos, Destino ,SolucaoCaminho) :-
    melhorCaminhoGul(Caminhos,MelhorCaminho),
    seleciona(MelhorCaminho, Caminhos, OutrosCaminhos),
    findall(NovoCaminho, adjacenteGul(MelhorCaminho,NovoCaminho,Destino), ExpCaminhos),
    append(OutrosCaminhos, ExpCaminhos, NovoCaminhos),
    gulosa2(NovoCaminhos,Destino ,SolucaoCaminho).

melhorCaminhoGul([Caminho], Caminho) :- !.

melhorCaminhoGul([Caminho1/Custo1/Est1,_/_/Est2|Caminhos], MelhorCaminho) :-
    Est1 =< Est2, !,
    melhorCaminhoGul([Caminho1/Custo1/Est1|Caminhos], MelhorCaminho).

melhorCaminhoGul([_|Caminhos], MelhorCaminho) :-
    melhorCaminhoGul(Caminhos, MelhorCaminho).

adjacenteGul([Nodo|Caminho]/Custo/_, [ProxNodo,Nodo|Caminho]/NovoCusto/Est,Destino) :-
    adjacentes(Nodo, ProxNodo, PassoCusto),\+ member(ProxNodo, Caminho),
    NovoCusto is Custo + PassoCusto,
    estimativa(ProxNodo,Destino ,Est).

seleciona(E, [E|Xs], Xs).
seleciona(E, [X|Xs], [X|Ys]) :- seleciona(E, Xs, Ys).



%Gerar os circuitos de recolha tanto indiferenciada como seletiva, caso existam, que
%cubram um determinado território;

gerarCircuitoDF2([H,P],Solucao,Custo):-dfs(H,P,S1,C1),
                                      deposito(D),
                                      dfs(P,D,S2,C2),
                                      garagem(G),
                                      dfs(D,G,S3,C3),
                                      append(S1,S2,S4),
                                      append(S4,S3,Solucao),
                                      Custo is C1+C2+C3.


gerarCircuitoDF2([H,P|T],Solucao,Custo):-
                        dfs(H,P,S1,C1),
                        gerarCircuitoDF2([P|T],S2,C2),
                        append(S1,S2,Solucao),
                        Custo is C1+C2.



gerarCircuitoDF([H,P|T],Solucao,Custo):-garagem(G),dfs(G,H,S1,C1),
                                        gerarCircuitoDF2([H,P|T],S2,C2),
                                        append(S1,S2,Solucao),
                                        Custo is C1+C2.


gerarCircuitoBF2([H,P],Solucao,Custo):-bfs(H,P,S1,C1),
                                      deposito(D),
                                      bfs(P,D,S2,C2),
                                      garagem(G),
                                      bfs(D,G,S3,C3),
                                      append(S1,S2,S4),
                                      append(S4,S3,Solucao),
                                      Custo is C1+C2+C3.



gerarCircuitoBF2([H,P|T],Solucao,Custo):-
                        bfs(H,P,S1,C1),
                        gerarCircuitoBF2([P|T],S2,C2),
                        append(S1,S2,Solucao),
                        Custo is C1+C2.



gerarCircuitoBF([H,P|T],Solucao,Custo):-garagem(G),bfs(G,H,S1,C1),
                                        gerarCircuitoBestFS2([H,P|T],S2,C2),
                                        append(S1,S2,Solucao),
                                        Custo is C1+C2.

gerarCircuitoBestFS2([H,P],Solucao,Custo):-bestfs(H,P,S1,C1),
                                      deposito(D),
                                      bestfs(P,D,S2,C2),
                                      garagem(G),
                                      bestfs(D,G,S3,C3),
                                      append(S1,S2,S4),
                                      append(S4,S3,Solucao),
                                      Custo is C1+C2+C3.



gerarCircuitoBestFS2([H,P|T],Solucao,Custo):-
                        bestfs(H,P,S1,C1),
                        gerarCircuitoBestFS2([P|T],S2,C2),
                        append(S1,S2,Solucao),
                        Custo is C1+C2.



gerarCircuitoBestFS([H,P|T],Solucao,Custo):-garagem(G),bfs(G,H,S1,C1),
                                        gerarCircuitoBestFS2([H,P|T],S2,C2),
                                        append(S1,S2,Solucao),
                                        Custo is C1+C2.



gerarCircuitoBNB2([H,P],Solucao,Custo):-bnb(H,P,S1,C1),
                                      deposito(D),
                                      bnb(P,D,S2,C2),
                                      garagem(G),
                                      bnb(D,G,S3,C3),
                                      append(S1,S2,S4),
                                      append(S4,S3,Solucao),
                                      Custo is C1+C2+C3.



gerarCircuitoBNB2([H,P|T],Solucao,Custo):-
                        bnb(H,P,S1,C1),
                        gerarCircuitoBNB2([P|T],S2,C2),
                        append(S1,S2,Solucao),
                        Custo is C1+C2.



gerarCircuitoBNB([H,P|T],Solucao,Custo):-garagem(G),bnb(G,H,S1,C1),
                                        gerarCircuitoBNB2([H,P|T],S2,C2),
                                        append(S1,S2,Solucao),
                                        Custo is C1+C2.



gerarCircuitoASTAR2([H,P],Solucao,Custo):-aStar(H,P,S1,C1),
                                      deposito(D),
                                      aStar(P,D,S2,C2),
                                      garagem(G),
                                      aStar(D,G,S3,C3),
                                      append(S1,S2,S4),
                                      append(S4,S3,Solucao),
                                      Custo is C1+C2+C3.



gerarCircuitoASTAR2([H,P|T],Solucao,Custo):-
                        aStar(H,P,S1,C1),
                        gerarCircuitoASTAR2([P|T],S2,C2),
                        append(S1,S2,Solucao),
                        Custo is C1+C2.



gerarCircuitoASTAR([H,P|T],Solucao,Custo):-garagem(G),aStar(G,H,S1,C1),
                                        gerarCircuitoASTAR2([H,P|T],S2,C2),
                                        append(S1,S2,Solucao),
                                        Custo is C1+C2.


gerarCircuitoGulosa2([H,P],Solucao,Custo):-gulosa(H,P,S1,C1),
                                      deposito(D),
                                      gulosa(P,D,S2,C2),
                                      garagem(G),
                                      gulosa(D,G,S3,C3),
                                      append(S1,S2,S4),
                                      append(S4,S3,Solucao),
                                      Custo is C1+C2+C3.



gerarCircuitoGulosa2([H,P|T],Solucao,Custo):-
                        gulosa(H,P,S1,C1),
                        gerarCircuitoGulosa2([P|T],S2,C2),
                        append(S1,S2,Solucao),
                        Custo is C1+C2.



gerarCircuitoGulosa([H,P|T],Solucao,Custo):-garagem(G),gulosa(G,H,S1,C1),
                                        gerarCircuitoGulosa2([H,P|T],S2,C2),
                                        append(S1,S2,Solucao),
                                        Custo is C1+C2.



gerarTodosCircuitosDF(Lista,Solucoes):-findall((X,Y),gerarCircuitoDF(Lista,X,Y),Solucoes).

gerarCircuitoBF([H,P],Solucao):-bfsS(H,P,Solucao).
gerarCircuitoBF([H,P|T],Solucao):-bfsS(H,P,Solucao1),gerarCircuitoBF([P|T],Solucao2),append(Solucao2,Solucao1,Solucao).

gerarTodosCircuitosBF(Lista,Solucoes):-findall(X,gerarCircuitoBF(Lista,X),Solucoes).


gerarCircuitoMaisRapidoDF(Solucao,Custo):-garagem(G),
           pontoMaisProximo([],G,R,_),dfs(G,R,S1,C1),
           gerarCircuitoMaisRapidoDF2(S2,C2,R,[R]),
           append(S1,S2,Solucao),Custo is C1+C2.

gerarCircuitoMaisRapidoDF2(Solucao,Custo,Atual,Visitados):-
                                       tamanho(Visitados,L2),
                                       numero_pontos_a_visitar(M),
                                       L2>M,
                                       deposito(D),dfs(Atual,D,S1,C1),
                                       garagem(G),dfs(D,G,S2,C2),
                                       append(S1,S2,Solucao),Custo is C1+C2.

gerarCircuitoMaisRapidoDF2(Solucao,Custo,Atual,Visitados):-
                                  pontoMaisProximo(Visitados,Atual,R,C),
                                  dfs(Atual,R,S1,C1),
                                  append([R],Visitados,V),
                                  gerarCircuitoMaisRapidoDF2(S2,C2,R,V),
                                  append(S1,S2,Solucao),Custo is C1+C2.


gerarCircuitoMaisPontosDF(Solucao,Custo,Tipo):-garagem(G),
           pontoMenosLixo([],Tipo,R,_),dfs(G,R,S1,C1),
           gerarCircuitoMaisPontosDF2(S2,C2,R,Tipo,[R]),
           append(S1,S2,Solucao),Custo is C1+C2.

gerarCircuitoMaisPontosDF2(Solucao,Custo,Atual,_,Visitados):-
                                       tamanho(Visitados,L2),
                                       numero_pontos_a_visitar(M),
                                       L2>M,
                                       deposito(D),dfs(Atual,D,S1,C1),
                                       garagem(G),dfs(D,G,S2,C2),
                                       append(S1,S2,Solucao),Custo is C1+C2.

gerarCircuitoMaisPontosDF2(Solucao,Custo,Atual,Tipo,Visitados):-
                                  pontoMenosLixo(Visitados,Tipo,R,_),
                                  dfs(Atual,R,S1,C1),
                                  append([R],Visitados,V),
                                  gerarCircuitoMaisPontosDF2(S2,C2,R,Tipo,V),
                                  append(S1,S2,Solucao),Custo is C1+C2.


gerarCircuitoMaisRapidoBF(Solucao,Custo):-garagem(G),
           pontoMaisProximo([],G,R,_),bfs(G,R,S1,C1),
           gerarCircuitoMaisRapidoBF2(S2,C2,R,[R]),
           append(S1,S2,Solucao),Custo is C1+C2.

gerarCircuitoMaisRapidoBF2(Solucao,Custo,Atual,Visitados):-
                                       tamanho(Visitados,L2),
                                       numero_pontos_a_visitar(M),
                                       L2>M,
                                       deposito(D),bfs(Atual,D,S1,C1),
                                       garagem(G),bfs(D,G,S2,C2),
                                       append(S1,S2,Solucao),Custo is C1+C2.

gerarCircuitoMaisRapidoBF2(Solucao,Custo,Atual,Visitados):-
                                  pontoMaisProximo(Visitados,Atual,R,C),
                                  bfs(Atual,R,S1,C1),
                                  append([R],Visitados,V),
                                  gerarCircuitoMaisRapidoBF2(S2,C2,R,V),
                                  append(S1,S2,Solucao),Custo is C1+C2.


gerarCircuitoMaisPontosBF(Solucao,Custo,Tipo):-garagem(G),
           pontoMenosLixo([],Tipo,R,_),bfs(G,R,S1,C1),
           gerarCircuitoMaisPontosBF2(S2,C2,R,Tipo,[R]),
           append(S1,S2,Solucao),Custo is C1+C2.

gerarCircuitoMaisPontosBF2(Solucao,Custo,Atual,_,Visitados):-
                                       tamanho(Visitados,L2),
                                       numero_pontos_a_visitar(M),
                                       L2>M,
                                       deposito(D),bfs(Atual,D,S1,C1),
                                       garagem(G),bfs(D,G,S2,C2),
                                       append(S1,S2,Solucao),Custo is C1+C2.

gerarCircuitoMaisPontosBF2(Solucao,Custo,Atual,Tipo,Visitados):-
                                  pontoMenosLixo(Visitados,Tipo,R,_),
                                  bfs(Atual,R,S1,C1),
                                  append([R],Visitados,V),
                                  gerarCircuitoMaisPontosBF2(S2,C2,R,Tipo,V),
                                  append(S1,S2,Solucao),Custo is C1+C2.


gerarCircuitoMaisRapidoBestFS(Solucao,Custo):-garagem(G),
           pontoMaisProximo([],G,R,_),bestfs(G,R,S1,C1),
           gerarCircuitoMaisRapidoBestFS2(S2,C2,R,[R]),
           append(S1,S2,Solucao),Custo is C1+C2.

gerarCircuitoMaisRapidoBestFS2(Solucao,Custo,Atual,Visitados):-
                                       tamanho(Visitados,L2),
                                       numero_pontos_a_visitar(M),
                                       L2>M,
                                       deposito(D),bestfs(Atual,D,S1,C1),
                                       garagem(G),bestfs(D,G,S2,C2),
                                       append(S1,S2,Solucao),Custo is C1+C2.

gerarCircuitoMaisRapidoBestFS2(Solucao,Custo,Atual,Visitados):-
                                  pontoMaisProximo(Visitados,Atual,R,C),
                                  bestfs(Atual,R,S1,C1),
                                  append([R],Visitados,V),
                                  gerarCircuitoMaisRapidoBestFS2(S2,C2,R,V),
                                  append(S1,S2,Solucao),Custo is C1+C2.


gerarCircuitoMaisPontosBestFS(Solucao,Custo,Tipo):-garagem(G),
           pontoMenosLixo([],Tipo,R,_),bestfs(G,R,S1,C1),
           gerarCircuitoMaisPontosBestFS2(S2,C2,R,Tipo,[R]),
           append(S1,S2,Solucao),Custo is C1+C2.

gerarCircuitoMaisPontosBestFS2(Solucao,Custo,Atual,_,Visitados):-
                                       tamanho(Visitados,L2),
                                       numero_pontos_a_visitar(M),
                                       L2>M,
                                       deposito(D),bestfs(Atual,D,S1,C1),
                                       garagem(G),bestfs(D,G,S2,C2),
                                       append(S1,S2,Solucao),Custo is C1+C2.

gerarCircuitoMaisPontosBestFS2(Solucao,Custo,Atual,Tipo,Visitados):-
                                  pontoMenosLixo(Visitados,Tipo,R,_),
                                  bestfs(Atual,R,S1,C1),
                                  append([R],Visitados,V),
                                  gerarCircuitoMaisPontosBestFS2(S2,C2,R,Tipo,V),
                                  append(S1,S2,Solucao),Custo is C1+C2.

gerarCircuitoMaisRapidoBNB(Solucao,Custo):-garagem(G),
           pontoMaisProximo([],G,R,_),bnb(G,R,S1,C1),
           gerarCircuitoMaisRapidoBNB2(S2,C2,R,[R]),
           append(S1,S2,Solucao),Custo is C1+C2.

gerarCircuitoMaisRapidoBNB2(Solucao,Custo,Atual,Visitados):-
                                       tamanho(Visitados,L2),
                                       numero_pontos_a_visitar(M),
                                       L2>M,
                                       deposito(D),bnb(Atual,D,S1,C1),
                                       garagem(G),bnb(D,G,S2,C2),
                                       append(S1,S2,Solucao),Custo is C1+C2.

gerarCircuitoMaisRapidoBNB2(Solucao,Custo,Atual,Visitados):-
                                  pontoMaisProximo(Visitados,Atual,R,C),
                                  bnb(Atual,R,S1,C1),
                                  append([R],Visitados,V),
                                  gerarCircuitoMaisRapidoBNB2(S2,C2,R,V),
                                  append(S1,S2,Solucao),Custo is C1+C2.


gerarCircuitoMaisPontosBNB(Solucao,Custo,Tipo):-garagem(G),
           pontoMenosLixo([],Tipo,R,_),bnb(G,R,S1,C1),
           gerarCircuitoMaisPontosBNB2(S2,C2,R,Tipo,[R]),
           append(S1,S2,Solucao),Custo is C1+C2.

gerarCircuitoMaisPontosBNB2(Solucao,Custo,Atual,_,Visitados):-
                                       tamanho(Visitados,L2),
                                       numero_pontos_a_visitar(M),
                                       L2>M,
                                       deposito(D),bnb(Atual,D,S1,C1),
                                       garagem(G),bnb(D,G,S2,C2),
                                       append(S1,S2,Solucao),Custo is C1+C2.

gerarCircuitoMaisPontosBNB2(Solucao,Custo,Atual,Tipo,Visitados):-
                                  pontoMenosLixo(Visitados,Tipo,R,_),
                                  bnb(Atual,R,S1,C1),
                                  append([R],Visitados,V),
                                  gerarCircuitoMaisPontosBNB2(S2,C2,R,Tipo,V),
                                  append(S1,S2,Solucao),Custo is C1+C2.


gerarCircuitoMaisRapidoAStar(Solucao,Custo):-garagem(G),
           pontoMaisProximo([],G,R,_),aStar(G,R,S1,C1),
           gerarCircuitoMaisRapidoAStar2(S2,C2,R,[R]),
           append(S1,S2,Solucao),Custo is C1+C2.

gerarCircuitoMaisRapidoAStar2(Solucao,Custo,Atual,Visitados):-
                                       tamanho(Visitados,L2),
                                       numero_pontos_a_visitar(M),
                                       L2>M,
                                       deposito(D),aStar(Atual,D,S1,C1),
                                       garagem(G),aStar(D,G,S2,C2),
                                       append(S1,S2,Solucao),Custo is C1+C2.

gerarCircuitoMaisRapidoAStar2(Solucao,Custo,Atual,Visitados):-
                                  pontoMaisProximo(Visitados,Atual,R,C),
                                  aStar(Atual,R,S1,C1),
                                  append([R],Visitados,V),
                                  gerarCircuitoMaisRapidoAStar2(S2,C2,R,V),
                                  append(S1,S2,Solucao),Custo is C1+C2.


gerarCircuitoMaisPontosAStar(Solucao,Custo,Tipo):-garagem(G),
           pontoMenosLixo([],Tipo,R,_),aStar(G,R,S1,C1),
           gerarCircuitoMaisPontosAStar2(S2,C2,R,Tipo,[R]),
           append(S1,S2,Solucao),Custo is C1+C2.

gerarCircuitoMaisPontosAStar2(Solucao,Custo,Atual,_,Visitados):-
                                       tamanho(Visitados,L2),
                                       numero_pontos_a_visitar(M),
                                       L2>M,
                                       deposito(D),aStar(Atual,D,S1,C1),
                                       garagem(G),aStar(D,G,S2,C2),
                                       append(S1,S2,Solucao),Custo is C1+C2.

gerarCircuitoMaisPontosAStar2(Solucao,Custo,Atual,Tipo,Visitados):-
                                  pontoMenosLixo(Visitados,Tipo,R,_),
                                  aStar(Atual,R,S1,C1),
                                  append([R],Visitados,V),
                                  gerarCircuitoMaisPontosAStar2(S2,C2,R,Tipo,V),
                                  append(S1,S2,Solucao),Custo is C1+C2.

gerarCircuitoMaisRapidoGulosa(Solucao,Custo):-garagem(G),
           pontoMaisProximo([],G,R,_),gulosa(G,R,S1,C1),
           gerarCircuitoMaisRapidoGulosa2(S2,C2,R,[R]),
           append(S1,S2,Solucao),Custo is C1+C2.

gerarCircuitoMaisRapidoGulosa2(Solucao,Custo,Atual,Visitados):-
                                       tamanho(Visitados,L2),
                                       numero_pontos_a_visitar(M),
                                       L2>M,
                                       deposito(D),gulosa(Atual,D,S1,C1),
                                       garagem(G),gulosa(D,G,S2,C2),
                                       append(S1,S2,Solucao),Custo is C1+C2.

gerarCircuitoMaisRapidoGulosa2(Solucao,Custo,Atual,Visitados):-
                                  pontoMaisProximo(Visitados,Atual,R,C),
                                  gulosa(Atual,R,S1,C1),
                                  append([R],Visitados,V),
                                  gerarCircuitoMaisRapidoGulosa2(S2,C2,R,V),
                                  append(S1,S2,Solucao),Custo is C1+C2.


gerarCircuitoMaisPontosGulosa(Solucao,Custo,Tipo):-garagem(G),
           pontoMenosLixo([],Tipo,R,_),gulosa(G,R,S1,C1),
           gerarCircuitoMaisPontosGulosa2(S2,C2,R,Tipo,[R]),
           append(S1,S2,Solucao),Custo is C1+C2.

gerarCircuitoMaisPontosGulosa2(Solucao,Custo,Atual,_,Visitados):-
                                       tamanho(Visitados,L2),
                                       numero_pontos_a_visitar(M),
                                       L2>M,
                                       deposito(D),gulosa(Atual,D,S1,C1),
                                       garagem(G),gulosa(D,G,S2,C2),
                                       append(S1,S2,Solucao),Custo is C1+C2.

gerarCircuitoMaisPontosGulosa2(Solucao,Custo,Atual,Tipo,Visitados):-
                                  pontoMenosLixo(Visitados,Tipo,R,_),
                                  gulosa(Atual,R,S1,C1),
                                  append([R],Visitados,V),
                                  gerarCircuitoMaisPontosGulosa2(S2,C2,R,Tipo,V),
                                  append(S1,S2,Solucao),Custo is C1+C2.



%predicados auxiliares
%
tamanho([]     , 0 ).
tamanho([_|Xs] , L ) :- tamanho(Xs,N) , L is N+1 .

nao( Questao ) :-
    Questao, !, fail.
nao( Questao ).

membro(X, [X|_]).
membro(X, [_|Xs]):-
	membro(X, Xs).

inverso([],Z,Z).

inverso([H|T],Z,Acc) :- inverso(T,Z,[H|Acc]).




