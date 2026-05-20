% Carga todos los modulos desde aqui
:- consult('estado.pl').
:- consult('mundo.pl').
:- consult('jugador.pl').
:- consult('tienda.pl').
:- consult('combate.pl').

iniciar :-
    estado_juego(menu),
    retractall(estado_juego(_)),
    assert(estado_juego(exploracion)),
    write('      DRUG ADVENTURE'), nl,
    write('Comandos disponibles:'), nl,
    write(' - ir(lugar).'), nl,
    write(' - mirar.'), nl,
    write(' - agarrar(objeto) / tirar(objeto).'), nl,
    write(' - usar(objeto) / equipar(objeto).'), nl,
    write(' - ver_inventario.'), nl,
    write(' - abrir_puerta.'), nl,
    write(' - comprar(objeto) / vender(objeto).'), nl,
    write(' - atacar. / escapar.'), nl,
    write('---------------------------------------'), nl,
    mirar, !.

iniciar :-
    write('El juego ya esta en marcha. ¡Sigue jugando!'), nl.