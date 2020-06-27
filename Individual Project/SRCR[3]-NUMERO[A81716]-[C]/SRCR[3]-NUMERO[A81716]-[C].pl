%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% SIST. REPR. CONHECIMENTO E RACIOCIONIO - MiEI/3
%--------------------------------- - - - - - - - - - -  -  -  -  -   -
:- include(base_de_conhecimento).
% write('\33\[2J').

% SICStus PROLOG: Declaracoes iniciais
:- set_prolog_flag( discontiguous_warnings,off ).
:- set_prolog_flag( single_var_warnings,off ).
:- set_prolog_flag( unknown,fail ).
:- set_prolog_flag(toplevel_print_options, [quoted(true), portrayed(true), max_depth(0)]).

% Definições iniciais
:- op( 900,xfy,'::' ).

% Predicado solucoes:
% Termo, Predicado, Lista -> { V, F }
solucoes( T,P,L ) :- findall( T,P,L ).

% Predicado comprimento:
% Lista, Comprimento -> { V, F }
comprimento([],0).
comprimento([H|T],N) :-
	comprimento(T,S),
	N is S+1.

% Predicado pertence:
% Valor, Lista -> { V, F }
pertence( X,[X|L] ).
pertence( X,[Y|L] ) :- X \= Y, pertence( X,L ).

inverso(Xs, Ys):-
	inverso(Xs, [], Ys).

inverso([], Xs, Xs).
inverso([X|Xs],Ys, Zs):-
	inverso(Xs, [X|Ys], Zs).

seleciona(E, [E|Xs], Xs).
seleciona(E, [X|Xs], [X|Ys]) :- seleciona(E, Xs, Ys).

% Predicado interseção duas listas:
% Lista1, Lista2, interseção -> { V, F }
inter([], _, []).
inter([H1|T1], L2, [H1|Res]) :-
	   member(H1, L2),
	   inter(T1, L2, Res).
inter([_|T1], L2, Res) :-
	   inter(T1, L2, Res).

clear :- write('\33\[2J').

help :- write('All Functions'), nl,
				write('--------------------------------------------------------------------------------------------------------------------------------------------------'),nl,
				write('caminho2Pontos(Start,Goal,Caminho) - Calcula um trajeto entre dois pontos '),nl,
				write('--------------------------------------------------------------------------------------------------------------------------------------------------'),nl,
				write('caminhoComOperadora(Start,Goal,Operadora,Caminho) - Calcula um trajeto entre dois pontos usando apenas uma Operadora '),nl,
				write('--------------------------------------------------------------------------------------------------------------------------------------------------'),nl,
				write('caminhoComOperadoraInf(Start,Goal,Operadora,Caminho) - Calcula um trajeto entre dois pontos usando apenas uma Operadora, pesquisa informada '),nl,
				write('--------------------------------------------------------------------------------------------------------------------------------------------------'),nl,
				write('caminhoAbrigo(Start,Goal,Caminho) - Calcula um trajeto entre dois pontos usando apenas paragens abrigadas '),nl,
				write('--------------------------------------------------------------------------------------------------------------------------------------------------'),nl,
				write('caminhoAbrigoInf(Start,Goal,Caminho) - Calcula um trajeto entre dois pontos usando apenas paragens abrigadas, pesquisa informada '),nl,
				write('--------------------------------------------------------------------------------------------------------------------------------------------------'),nl,
				write('caminhoPublicidade(Start,Goal,Caminho) - Calcula um trajeto entre dois pontos usando apenas paragens com publicidade '),nl,
				write('--------------------------------------------------------------------------------------------------------------------------------------------------'),nl,
				write('caminhoPublicidadeInf(Start,Goal,Caminho) - Calcula um trajeto entre dois pontos usando apenas paragens com publicidade, pesquisa informada '),nl,
				write('--------------------------------------------------------------------------------------------------------------------------------------------------'),nl,
				write('caminhoSemOperadora(Start,Goal,[],Caminho) - Calcula um trajeto entre dois pontos excluindo o uso de X operadoras '),nl,
				write('--------------------------------------------------------------------------------------------------------------------------------------------------'),nl,
				write('caminhoSemOperadoraInf(Start,Goal,[],Caminho) - Calcula um trajeto entre dois pontos usando apenas paragens com publicidade, pesquisa informada '),nl,
				write('--------------------------------------------------------------------------------------------------------------------------------------------------'),nl,
				write('caminhoCarreira(Start,Goal,Caminho,Ordem) - Calcula um trajeto entre dois pontos e depois ordena as paragens por numero total de carreiras '),nl,
				write('--------------------------------------------------------------------------------------------------------------------------------------------------'),nl,
				write('caminhoMaisCurto(Origem, Goal, Caminho/Custo) - Calcula o trajeto mais curto entre dois pontos (em termos de distância), pesquisa informada'),nl,
				write('--------------------------------------------------------------------------------------------------------------------------------------------------'),nl,
				write('caminhoMenosParagens(Origem, Goal, Caminho/Paragens) - Calcula o trajeto com menos paragens entre dois pontos, pesquisa informada'),nl,
				write('--------------------------------------------------------------------------------------------------------------------------------------------------'),nl,
				write('caminhoComParagens(Start,Goal,Paragens,Caminho) - Calcula um trajeto que passa por todas as paragens dentro de "Paragens" '),nl,
				write('--------------------------------------------------------------------------------------------------------------------------------------------------').
%-----------------------------------------------------------------------------------------------------------------------------------------------------------
%-----------------------------------------------------------------------------------------------------------------------------------------------------------
%-----------------------------------------------------------------------------------------------------------------------------------------------------------
%-----------------------------------------------------------------------------------------------------------------------------------------------------------
%-----------------------------------------------------------------------------------------------------------------------------------------------------------
%-----------------------------------------------------------------------------------------------------------------------------------------------------------
%-----------------------------------------------------------------------------------------------------------------------------------------------------------
%Primeiro Ponto, Calcular um trajeto entre dois pontos
caminho2Pontos(Start,Goal,Caminho) :- bfs([Start],Goal,[],Caminho).

bfs([Node|_],Node,History,Caminho) :- remDupes(Node,History,[],Caminho).
bfs([Node|RestQ],Goal,History,Caminho) :- findall(NextNode , ( near(Node,NextNode),\+member(NextNode,History),\+member(NextNode,RestQ) ), Sucessores),
																					sort(Sucessores,Succ),
																					append(RestQ,Succ,Queue),
																					bfs(Queue,Goal,[Node|History],Caminho).


remDupes(Node,[],NewV,[Node|NewV]).
remDupes(Node,[Head|Tail],NewV,Caminho) :- (near(Node,Head) -> remDupes(Head,Tail,[Node|NewV],Caminho) ; remDupes(Node,Tail,NewV,Caminho) ).

near(Nodo1,Nodo2) :- nextTo(Nodo1,Nodo2) ; nextTo(Nodo2,Nodo1).

%-----------------------------------------------------------------------------------------------------------------------------------------------------------
%-----------------------------------------------------------------------------------------------------------------------------------------------------------
%-----------------------------------------------------------------------------------------------------------------------------------------------------------
%-----------------------------------------------------------------------------------------------------------------------------------------------------------
%-----------------------------------------------------------------------------------------------------------------------------------------------------------
%-----------------------------------------------------------------------------------------------------------------------------------------------------------
%-----------------------------------------------------------------------------------------------------------------------------------------------------------
%Segundo Ponto, Calcular uma travessia q só usa uma X operadoras
caminhoComOperadora(Start,Goal,Operadora,Caminho) :- bfsOperadora([Start],Goal,Operadora,[],Caminho).

bfsOperadora([Node|_],Node,Operadora,History,Caminho) :- remDupes(Node,History,[],Caminho). %	inverso([Node|History],Caminho).
bfsOperadora([Node|RestQ],Goal,Operadora,History,Caminho) :- findall(NextNode , ( near(Node,NextNode),operadoraValida(NextNode,Operadora),\+member(NextNode,History),\+member(NextNode,RestQ) ), Sucessores),
																														 sort(Sucessores,Succ),
																														 append(RestQ,Succ,Queue),
																														 bfsOperadora(Queue,Goal,Operadora,[Node|History],Caminho).

operadoraValida(Nodo,Operadora) :- paragem(Nodo,_,_,_,_,_,Operadora,_,_,_,_).

%Segundo Ponto, Calcular uma travessia q só usa uma X operadoras mas com pesquisa Informada, haha
caminhoComOperadoraInf(Origem,Goal,Operadora,Caminho) :- euclidean(Origem,Goal,Estima) , aEstrelaOp([[Origem]/0/Estima], Goal,Operadora, Path/Custo/_), inverso(Path,Caminho).

aEstrelaOp(Caminhos, Goal ,Operadora ,Caminho) :- obtem_melhor(Caminhos, Caminho, Goal),
																		 						  Caminho = [Goal|_]/_/_.
aEstrelaOp(Caminhos, Goal ,Operadora ,SolucaoCaminho) :- obtem_melhor(Caminhos, MelhorCaminho, Goal),
																												 seleciona(MelhorCaminho, Caminhos, OutrosCaminhos),
																												 expande_aestrela_op(MelhorCaminho, Goal,Operadora,ExpCaminhos),
																												 append(OutrosCaminhos, ExpCaminhos, NovoCaminhos),
        																				 				 aEstrelaOp(NovoCaminhos, Goal,Operadora ,SolucaoCaminho).

expande_aestrela_op(Caminho, Goal,Operadora ,ExpCaminhos) :- findall(NovoCaminho, adjOp(Caminho,NovoCaminho, Goal,Operadora), ExpCaminhos).

adjOp( [Nodo|Caminho]/Custo/_ , [ProxNodo,Nodo|Caminho]/NovoCusto/Est , Goal ,Operadora) :- near(Nodo, ProxNodo),\+ member(ProxNodo, Caminho), operadoraValida(ProxNodo,Operadora),
																																						 	 							euclidean(Nodo,ProxNodo,PassoCusto),
																																						 	 							NovoCusto is Custo + PassoCusto,
																																						 	 							euclidean(ProxNodo, Goal, Est).
%-----------------------------------------------------------------------------------------------------------------------------------------------------------
%-----------------------------------------------------------------------------------------------------------------------------------------------------------
%-----------------------------------------------------------------------------------------------------------------------------------------------------------
%-----------------------------------------------------------------------------------------------------------------------------------------------------------
%-----------------------------------------------------------------------------------------------------------------------------------------------------------
%-----------------------------------------------------------------------------------------------------------------------------------------------------------
%-----------------------------------------------------------------------------------------------------------------------------------------------------------
%Calcular uma travessia que passe apenas por paragens abrigadas     fechado_dos_lados    aberto_dos_lados
abrigoValido(Nodo) :- paragem(Nodo,_,_,_,fechado_dos_lados,_,_,_,_,_,_) ; paragem(Nodo,_,_,_,aberto_dos_lados,_,_,_,_,_,_).

caminhoAbrigo(Start,Goal,Caminho) :- bfsAbrigo([Start],Goal,[],Caminho).

bfsAbrigo([Node|_],Node,History,Caminho) :- remDupes(Node,History,[],Caminho).
bfsAbrigo([Node|RestQ],Goal,History,Caminho) :- findall(NextNode , ( near(Node,NextNode),abrigoValido(NextNode),\+member(NextNode,History),\+member(NextNode,RestQ) ), Sucessores),
																						    sort(Sucessores,Succ),
																								append(RestQ,Succ,Queue),
																								bfsAbrigo(Queue,Goal,[Node|History],Caminho).



%Calcular uma travessia que passe apenas por paragens abrigadas   VERSÃO INFORMADA
caminhoAbrigoInf(Start,Goal,Caminho) :- euclidean(Start,Goal,Estima) , aestrela_abrigo([[Start]/0/Estima], Goal, Path/Custo/_), inverso(Path,Caminho).

aestrela_abrigo(Caminhos, Goal ,Caminho) :- obtem_melhor(Caminhos, Caminho, Goal),
																		 				Caminho = [Goal|_]/_/_.
aestrela_abrigo(Caminhos, Goal ,SolucaoCaminho) :- obtem_melhor(Caminhos, MelhorCaminho, Goal),
																									 seleciona(MelhorCaminho, Caminhos, OutrosCaminhos),
																									 expande_aestrela_abrigo(MelhorCaminho, Goal,ExpCaminhos),
																									 append(OutrosCaminhos, ExpCaminhos, NovoCaminhos),
																					  		 	 aestrela_abrigo(NovoCaminhos, Goal ,SolucaoCaminho).


expande_aestrela_abrigo(Caminho, Goal ,ExpCaminhos) :- findall(NovoCaminho, adj_abrigo(Caminho,NovoCaminho, Goal), ExpCaminhos).


adj_abrigo( [Nodo|Caminho]/Custo/_ , [ProxNodo,Nodo|Caminho]/NovoCusto/Est , Goal) :- near(Nodo, ProxNodo),\+ member(ProxNodo, Caminho), abrigoValido(ProxNodo),
																																											euclidean(Nodo,ProxNodo,PassoCusto),
																																											NovoCusto is Custo + PassoCusto,
																																											euclidean(ProxNodo, Goal, Est).
%-----------------------------------------------------------------------------------------------------------------------------------------------------------
%-----------------------------------------------------------------------------------------------------------------------------------------------------------
%-----------------------------------------------------------------------------------------------------------------------------------------------------------
%-----------------------------------------------------------------------------------------------------------------------------------------------------------
%-----------------------------------------------------------------------------------------------------------------------------------------------------------
%-----------------------------------------------------------------------------------------------------------------------------------------------------------
%-----------------------------------------------------------------------------------------------------------------------------------------------------------
%Calcular uma travessia q passe apenas por paragens com Publicidade
caminhoPublicidade(Start,Goal,Caminho) :- bfsPublicidade([Start],Goal,[],Caminho).

publicidadeValida(Node) :- paragem(Node,_,_,_,_,yes,_,_,_,_,_).
bfsPublicidade([Node|_],Node,History,Caminho) :- remDupes(Node,History,[],Caminho).
bfsPublicidade([Node|RestQ],Goal,History,Caminho) :- findall(NextNode , ( near(Node,NextNode),publicidadeValida(NextNode),\+member(NextNode,History),\+member(NextNode,RestQ) ), Sucessores),
																										 sort(Sucessores,Succ),
																								     append(RestQ,Succ,Queue),
																							 	     bfsPublicidade(Queue,Goal,[Node|History],Caminho).


%Calcular uma travessia q passe apenas por paragens com Publicidade, agora Informado
caminhoPublicidadeInf(Start,Goal,Caminho) :- euclidean(Start,Goal,Estima) , aestrela_publicidade([[Start]/0/Estima], Goal, Path/Custo/_), inverso(Path,Caminho).

aestrela_publicidade(Caminhos, Goal ,Caminho) :- obtem_melhor(Caminhos, Caminho, Goal),
																								 Caminho = [Goal|_]/_/_.
aestrela_publicidade(Caminhos, Goal ,SolucaoCaminho) :- obtem_melhor(Caminhos, MelhorCaminho, Goal),
																												seleciona(MelhorCaminho, Caminhos, OutrosCaminhos),
																												expande_aestrela_publicidade(MelhorCaminho, Goal,ExpCaminhos),
																												append(OutrosCaminhos, ExpCaminhos, NovoCaminhos),
																										 		aestrela_publicidade(NovoCaminhos, Goal ,SolucaoCaminho).


expande_aestrela_publicidade(Caminho, Goal ,ExpCaminhos) :- findall(NovoCaminho, adj_publicidade(Caminho,NovoCaminho, Goal), ExpCaminhos).


adj_publicidade( [Nodo|Caminho]/Custo/_ , [ProxNodo,Nodo|Caminho]/NovoCusto/Est , Goal) :- near(Nodo, ProxNodo),\+ member(ProxNodo, Caminho), publicidadeValida(ProxNodo),
																										 																			 euclidean(Nodo,ProxNodo,PassoCusto),
																										 																		 	 NovoCusto is Custo + PassoCusto,
																										 																		 	 euclidean(ProxNodo, Goal, Est).
%-----------------------------------------------------------------------------------------------------------------------------------------------------------
%-----------------------------------------------------------------------------------------------------------------------------------------------------------
%-----------------------------------------------------------------------------------------------------------------------------------------------------------
%-----------------------------------------------------------------------------------------------------------------------------------------------------------
%-----------------------------------------------------------------------------------------------------------------------------------------------------------
%-----------------------------------------------------------------------------------------------------------------------------------------------------------
%-----------------------------------------------------------------------------------------------------------------------------------------------------------
%Calcular uma travessia q não use X operadoras
caminhoSemOperadora(Start,Goal,[],Caminho) :- bfs([Start],Goal,[],Caminho).
caminhoSemOperadora(Start,Goal,Operadoras,Caminho) :- bfsNoperadoras([Start],Goal,Operadoras,[],Caminho).

operadoraNope(Node,[]).
operadoraNope(Node,[Op|Cauda]) :- (paragem(Node,_,_,_,_,_,Op,_,_,_,_) -> !,fail ; operadoraNope(Node,Cauda)).

bfsNoperadoras([Node|_],Node,Operadoras,History,Caminho) :- remDupes(Node,History,[],Caminho). %	inverso([Node|History],Caminho).
bfsNoperadoras([Node|RestQ],Goal,Operadoras,History,Caminho) :- findall(NextNode , (near(Node,NextNode),operadoraNope(NextNode,Operadoras),\+member(NextNode,History),\+member(NextNode,RestQ) ), Sucessores),
																														 	 	sort(Sucessores,Succ),
																														 	 	append(RestQ,Succ,Queue),
																														 	 	bfsNoperadoras(Queue,Goal,Operadoras,[Node|History],Caminho).


%Calcular uma travessia q não use X operadoras, mas agora, INFORMADO
caminhoSemOperadoraInf(Origem,Goal,Operadora,Caminho) :- euclidean(Origem,Goal,Estima) , aEstrelaS_Op([[Origem]/0/Estima], Goal,Operadora, Path/Custo/_), inverso(Path,Caminho).

aEstrelaS_Op(Caminhos, Goal ,Operadora ,Caminho) :- obtem_melhor(Caminhos, Caminho, Goal),
																										Caminho = [Goal|_]/_/_.
aEstrelaS_Op(Caminhos, Goal ,Operadora ,SolucaoCaminho) :- obtem_melhor(Caminhos, MelhorCaminho, Goal),
																													 seleciona(MelhorCaminho, Caminhos, OutrosCaminhos),
																													 expande_aestrela_Sop(MelhorCaminho, Goal,Operadora,ExpCaminhos),
																													 append(OutrosCaminhos, ExpCaminhos, NovoCaminhos),
																													 aEstrelaS_Op(NovoCaminhos, Goal,Operadora ,SolucaoCaminho).

expande_aestrela_Sop(Caminho, Goal,Operadora ,ExpCaminhos) :- findall(NovoCaminho, adjS_Op(Caminho,NovoCaminho, Goal,Operadora), ExpCaminhos).

adjS_Op( [Nodo|Caminho]/Custo/_ , [ProxNodo,Nodo|Caminho]/NovoCusto/Est , Goal ,Operadora) :- near(Nodo, ProxNodo),\+ member(ProxNodo, Caminho), operadoraNope(ProxNodo,Operadora),
																																															euclidean(Nodo,ProxNodo,PassoCusto),
																																															NovoCusto is Custo + PassoCusto,
																																															euclidean(ProxNodo, Goal, Est).
%-----------------------------------------------------------------------------------------------------------------------------------------------------------
%-----------------------------------------------------------------------------------------------------------------------------------------------------------
%-----------------------------------------------------------------------------------------------------------------------------------------------------------
%-----------------------------------------------------------------------------------------------------------------------------------------------------------
%-----------------------------------------------------------------------------------------------------------------------------------------------------------
%-----------------------------------------------------------------------------------------------------------------------------------------------------------
%-----------------------------------------------------------------------------------------------------------------------------------------------------------
%Calcular uma travessia e descobrir qual as paragens com mais carreiras
caminhoCarreira(Start,Goal,Caminho,Ordem) :- caminho2Pontos(Start,Goal,Caminho) , ordenaC(Caminho,[],Ordem).

ordenaC([],MiddleMan,Resultado) :- inverso(MiddleMan,Resultado).
ordenaC(Caminho,MiddleMan,Resultado) :- getGreater(Caminho,-1,-1,Greatest), delete_each(Greatest,Caminho,NewCaminho) ,ordenaC(NewCaminho,[Greatest|MiddleMan],Resultado).

getGreater([],GreatestSoFar,_,GreatestSoFar).
getGreater([Nodo|Cauda],GreatestSoFar,GreatestValue,Resultado) :- paragem(Nodo,_,_,_,_,_,_,Carreiras,_,_,_),
																															    comprimento(Carreiras,Size),
																																	( Size > GreatestValue -> getGreater(Cauda,Nodo,Size,Resultado) ;
																																						 								getGreater(Cauda,GreatestSoFar,GreatestValue,Resultado)).

delete_each(X, [X|L], L).
delete_each(X, [Y|Ys], [Y|Zs]) :- delete_each(X, Ys, Zs).
%-----------------------------------------------------------------------------------------------------------------------------------------------------------
%-----------------------------------------------------------------------------------------------------------------------------------------------------------
%-----------------------------------------------------------------------------------------------------------------------------------------------------------
%-----------------------------------------------------------------------------------------------------------------------------------------------------------
%-----------------------------------------------------------------------------------------------------------------------------------------------------------
%-----------------------------------------------------------------------------------------------------------------------------------------------------------
%-----------------------------------------------------------------------------------------------------------------------------------------------------------
%Calcular a travessia mais rapida entre duas paragens com o One and Only A* (tentativa)
twicePowa(Num,Result):- Result is Num**2.
rootin(Num,Result):- Result is sqrt(Num).

euclidean(Nodo1,Nodo2,Result) :- paragem(Nodo1,Longit1,Altit1,_,_,_,_,_,_,_,_), paragem(Nodo2,Longit2,Altit2,_,_,_,_,_,_,_,_),
																 twicePowa((Longit2 - Longit1),LL) , twicePowa((Altit2 - Altit1),AA), LA is LL + AA,
																 rootin(LA,Result).

obtem_melhor([Caminho], Caminho, Goal) :- !.
obtem_melhor([Caminho1/Custo1/Est1,_/Custo2/Est2|Caminhos], MelhorCaminho, Goal) :- Custo1 + Est1 =< Custo2 + Est2, !,
																 																									  obtem_melhor([Caminho1/Custo1/Est1|Caminhos], MelhorCaminho, Goal).
obtem_melhor([_|Caminhos], MelhorCaminho, Goal) :- obtem_melhor(Caminhos, MelhorCaminho, Goal).


caminhoMaisCurto(Origem, Goal, Caminho/Custo) :- euclidean(Origem,Goal,Estima) , aestrela([[Origem]/0/Estima], Goal , Path/Custo/_), inverso(Path,Caminho).

aestrela(Caminhos, Goal ,Caminho) :- obtem_melhor(Caminhos, Caminho, Goal),
																		 Caminho = [Goal|_]/_/_.
aestrela(Caminhos, Goal ,SolucaoCaminho) :- obtem_melhor(Caminhos, MelhorCaminho, Goal),
																						seleciona(MelhorCaminho, Caminhos, OutrosCaminhos),
																						expande_aestrela(MelhorCaminho, Goal,ExpCaminhos),
																						append(OutrosCaminhos, ExpCaminhos, NovoCaminhos),
        																		aestrela(NovoCaminhos, Goal ,SolucaoCaminho).


expande_aestrela(Caminho, Goal ,ExpCaminhos) :- findall(NovoCaminho, adj(Caminho,NovoCaminho, Goal), ExpCaminhos).


adj( [Nodo|Caminho]/Custo/_ , [ProxNodo,Nodo|Caminho]/NovoCusto/Est , Goal) :- near(Nodo, ProxNodo),\+ member(ProxNodo, Caminho),
																																						 	 euclidean(Nodo,ProxNodo,PassoCusto),
																																						 	 NovoCusto is Custo + PassoCusto,
																																						 	 euclidean(ProxNodo, Goal, Est).
%-----------------------------------------------------------------------------------------------------------------------------------------------------------
%-----------------------------------------------------------------------------------------------------------------------------------------------------------
%-----------------------------------------------------------------------------------------------------------------------------------------------------------
%-----------------------------------------------------------------------------------------------------------------------------------------------------------
%-----------------------------------------------------------------------------------------------------------------------------------------------------------
%-----------------------------------------------------------------------------------------------------------------------------------------------------------
%-----------------------------------------------------------------------------------------------------------------------------------------------------------
%Calcular a travessia com menos paragens, mas não necessariamente a mais rapida (Tentar usar algoritmo greedy)
caminhoMenosParagens(Origem, Goal, Caminho/Paragens) :- greedy([[Origem]/1],Goal,[],Caminho/Paragens).

greedy([[Goal|Resto]/N|Soln],Goal,Visitados,Path/Paragens) :- inverso([Goal|Resto],Path), Paragens is N.
greedy([[Node|Resto]/N|Soln],Goal,Visitados,CP) :- findall(ProxNodo,(near(Node,ProxNodo),\+member(ProxNodo,Visitados)),Nodos),
																									 buildLists([Node|Resto]/N,Nodos,[],New),
																									 append(Soln,New,MiddleMan),
																									 mysort(MiddleMan,[],FinalList),
																									 greedy(FinalList,Goal,[Node|Visitados],CP).

mysort([],Temp,Final) :- inverso(Temp,Final).
mysort([MM/N|Resto],Temp,FList) :- getLowest(MM,N,Resto,Lowest) , delete_each(Lowest,[MM/N|Resto],MiddleMan) , mysort(MiddleMan,[Lowest|Temp],FList).

getLowest(LowestSoFar,LowestValue,[],LowestSoFar/LowestValue).
getLowest(LowestSoFar,LowestValue,[Caminho/Valor|Cauda],Lowest) :- ( Valor < LowestValue -> getLowest(Caminho,Valor,Cauda,Lowest) ;
																																														getLowest(LowestSoFar,LowestValue,Cauda,Lowest)).

buildLists(_,[],List,List).
buildLists(Lista/N,[Nodo|Resto],NewList,Resultado) :- NN is N+1 , buildLists(Lista/N,Resto,[[Nodo|Lista]/NN|NewList],Resultado).
%-----------------------------------------------------------------------------------------------------------------------------------------------------------
%-----------------------------------------------------------------------------------------------------------------------------------------------------------
%-----------------------------------------------------------------------------------------------------------------------------------------------------------
%-----------------------------------------------------------------------------------------------------------------------------------------------------------
%-----------------------------------------------------------------------------------------------------------------------------------------------------------
%-----------------------------------------------------------------------------------------------------------------------------------------------------------
%-----------------------------------------------------------------------------------------------------------------------------------------------------------
%Calcular travessia passando entre X pontos.
caminhoComParagens(Start,Goal,[],Caminho) :- bfs([Start],Goal,[],Caminho).
caminhoComParagens(Start,Goal,Paragens,Caminho) :- cpp(Start,Goal,Paragens,[],Path), rem_dupes(Path,[],Caminho).

cpp(Start,Goal,[],MiddleMan,Caminho) :- caminhoMenosParagens(Start,Goal,Path/Cost) , append(MiddleMan,Path,Caminho).
cpp(Start,Goal,[H|T],MiddleMan,Caminho) :- caminhoMenosParagens(Start,H,Path/Cost) , append(MiddleMan,Path,New) , cpp(H,Goal,T,New,Caminho).

rem_dupes([H1],MiddleMan,Final) :- inverso([H1|MiddleMan],Final).
rem_dupes([H1,H1|T],MiddleMan,Final) :- rem_dupes([H1|T],MiddleMan,Final).
rem_dupes([H1,H2|T],MiddleMan,Final) :- rem_dupes([H2|T],[H1|MiddleMan],Final).
