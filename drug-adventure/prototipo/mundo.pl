% Aqui manejamos las conexiones fisicas y la navegacion.
conectado(plaza, callejon).
conectado(callejon, plaza).
conectado(plaza, mercado).
conectado(mercado, plaza).
conectado(plaza, castillo).

ir(_) :- 
    estado_juego(menu),
    write('Escribe "iniciar." para comenzar el juego.'), nl, !.

% Bloquear movimiento si estamos en combate
ir(_) :-
    estado_juego(combate),
    castigo_por_distraccion, !.

% Regla de bloqueo de tienda
ir(_) :-
    estado_juego(tienda),
    write('Estas viendo el catalogo del mercader. Usa "salir_tienda." antes de irte.'), nl, !.

ir(Lugar) :-
    ubicacion(Actual),
    conectado(Actual, Lugar),
    puerta_cerrada(Lugar),
    write('La puerta esta cerrada. Necesitas una llave para entrar.'), nl, !.

% Movimiento exitoso
ir(Lugar) :-
    ubicacion(Actual),
    conectado(Actual, Lugar),
    retract(ubicacion(Actual)),
    assert(ubicacion(Lugar)),
    % Guardar de donde venimos
    retractall(ubicacion_anterior(_)),
    assert(ubicacion_anterior(Actual)),
    write('Te has movido a: '), write(Lugar), nl,
    mirar,
    revisar_victoria.

ir(_) :-
    write('No puedes ir ahi desde aqui.'), nl.

mirar :-
    estado_juego(menu),
    write('Escribe "iniciar." para comenzar el juego.'), nl, !.

mirar :-
    ubicacion(L),
    write('---------------------------------------'), nl,
    write('Estas en: '), write(L), nl,
    
    % Buscar y mostrar lugares conectados
    findall(Destino, conectado(L, Destino), Salidas),
    write('Lugares disponibles: '), write(Salidas), nl,
    write('---------------------------------------'), nl,
    
    % Mostrar Estadisticas del Jugador
    jugador(HP_J, Max_J, _Dmg_J),
    dinero(D),
    write('Estadisticas => Salud: '), write(HP_J), write('/'), write(Max_J), write(' | Dinero: '), write(D), write(' monedas'), nl,
    write('---------------------------------------'), nl,
    
    % Buscar y mostrar objetos
    findall(Obj, objeto_en(L, Obj), Objetos),
    (Objetos \== [] ->
        write('Ves los siguientes objetos aqui: '), write(Objetos), nl
    ; 
        true
    ),
    
    % Revisar si hay enemigos
    (enemigo(N, L, _HP, _Max, _Dmg, _Recompensa) ->
        write('!!! Un '), write(N), write(' te bloquea el paso.'), nl,
        iniciar_combate(N)
    ; true).

revisar_victoria :-
    ubicacion(castillo),
    dinero(D),
    D >= 40,
    nl,
    write('               VICTORIA                      '), nl,
    write(' Has llegado al castillo con la riqueza necesaria. '), nl,
    write(' Eres el drug adventure.                 '), nl,
    halt. % Termina la ejecucion del juego

revisar_victoria :- 
    ubicacion(castillo),
    dinero(D),
    D < 40,
    write('Estas en el castillo, pero aun no tienes las 40 monedas para ganar.'), nl.

revisar_victoria.