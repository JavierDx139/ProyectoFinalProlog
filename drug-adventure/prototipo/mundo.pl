% Aqui manejamos las conexiones fisicas y la navegacion.
% Lugares plaza.
conectado(plaza, callejon).
conectado(callejon, plaza).
conectado(plaza, mercado).
conectado(mercado, plaza).
conectado(plaza, castillo).
conectado(entrada_mansion, plaza).
conectado(plaza,entrada_mansion).
conectado(plaza, entrada_neon).
    
% Lugares Mansion.
conectado(entrada_mansion, lobby).
conectado(lobby,entrada_mansion).
conectado(lobby, recamara).
conectado(recamara,lobby).
conectado(lobby, cocina).
conectado(cocina, lobby).    
conectado(lobby, escaleras).
conectado(escaleras,lobby).
conectado(escaleras, sala).
conectado(sala, escaleras).
    
% Lugares Barrio Mongrel.
conectado(callejon, centro).
conectado(centro, callejon).
conectado(centro, callejon_norte).
conectado(callejon_norte, centro).
conectado(callejon_norte, casa_desgastada).
conectado(casa_desgastada, callejon_norte).
conectado(centro, callejon_este).
conectado(callejon_este, centro).
conectado(callejon_oeste, centro).
conectado(centro, callejon_oeste).
conectado(callejon_oeste, distrito_verde).
conectado(distrito_verde, callejon_oeste).
conectado(distrito_verde, esquina_sospechosa).
conectado(esquina_sospechosa, distrito_verde).
conectado(casa_desgastada, sotano).
conectado(sotano, casa_desgastada).
conectado(sotano, fondo).
conectado(fondo, sotano).

% Lugares Cuadrante Neon.
conectado(entrada_neon, plaza).
conectado(entrada_neon, pista_baile).
conectado(pista_baile, entrada_neon).
conectado(pista_baile, sala_dj).
conectado(sala_dj, pista_baile).
conectado(pista_baile, servidores).
conectado(servidores, pista_baile).
conectado(barra, pista_baile).
conectado(pista_baile, barra).

% Lugares castillo.





    
    
    
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
    
ir(servidores) :-
    ubicacion(Actual),
    conectado(Actual, servidores),
    inventario(Inv),
    member(tarjeta_servidores, Inv),
    puerta_cerrada(servidores),
    retract(puerta_cerrada(servidores)),
    retract(ubicacion(Actual)),
    assert(ubicacion(servidores)),
    retractall(ubicacion_anterior(_)),
    assert(ubicacion_anterior(Actual)),
    write('Te has movido a: servidores'),  nl,
    mirar,
    revisar_victoria.
    
ir(castillo) :-
    ubicacion(Actual),
    conectado(Actual, castillo),
    inventario(Inv),
    member(fragmento_llave_1, Inv),
    member(fragmento_llave_2, Inv),
    member(fragmento_llave_3, Inv),
    puerta_cerrada(castillo),
    retract(puerta_cerrada(castillo)),
    retract(ubicacion(Actual)),
    assert(ubicacion(castillo)),
    retractall(ubicacion_anterior(_)),
    assert(ubicacion_anterior(Actual)),
    write('Te has movido a: castillo'), nl,
    mirar,
    revisar_victoria.

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
