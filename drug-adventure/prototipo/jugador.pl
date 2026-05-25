% Maneja las reglas del inventario del jugador.
agarrar(_) :-
    estado_juego(combate),
    castigo_por_distraccion, !.

agarrar(Objeto) :-
    ubicacion(Lugar),
    objeto_en(Lugar, Objeto),
    inventario(Inv),
    length(Inv, Cantidad),
    Cantidad < 10,
    retract(objeto_en(Lugar, Objeto)),
    retract(inventario(Inv)),
    assert(inventario([Objeto|Inv])),
    write('Has recogido: '), write(Objeto), nl, !.

agarrar(_) :-
    inventario(Inv),
    length(Inv, Cantidad),
    Cantidad >= 10,
    write('Tu inventario esta lleno (Max 10).'), nl, !.

agarrar(_) :-
    write('Ese objeto no esta aqui.'), nl.

abrir_puerta :-
    estado_juego(combate),
    castigo_por_distraccion, !.

abrir_puerta :-
    ubicacion(plaza),
    inventario(Inv),
    member(llave, Inv),
    puerta_cerrada(castillo),
    retract(puerta_cerrada(castillo)),
    write('Has abierto la puerta del castillo con la llave.'), nl, !.
abrir_puerta :-
    write('No puedes abrir ninguna puerta aqui o te falta la llave.'), nl.

ver_inventario :-
    estado_juego(menu),
    write('Escribe "iniciar." para comenzar el juego.'), nl, !.

ver_inventario :-
    inventario(Inv),
    (Inv == [] ->
        write('Tu inventario esta vacio.'), nl
    ;
        write('Tu inventario: '), write(Inv), nl
    ).

% Castigo si lo intentas en combate
tirar(_) :-
    estado_juego(combate),
    castigo_por_distraccion, !.

% Tirar el objeto con exito
tirar(Objeto) :-
    inventario(Inv),
    member(Objeto, Inv), % Verificamos que lo tengas
    select(Objeto, Inv, NuevoInv), % Lo sacamos de la lista
    
    % Actualizamos el inventario
    retract(inventario(Inv)),
    assert(inventario(NuevoInv)),
    
    % Lo agregamos al mundo en la ubicacion actual
    ubicacion(Lugar),
    assert(objeto_en(Lugar, Objeto)),
    
    write('Has tirado: '), write(Objeto), write(' en '), write(Lugar), nl, !.

% Falla si no tienes el objeto
tirar(_) :-
    write('No tienes ese objeto en tu inventario para tirarlo.'), nl.

% Coleccion de efectos
% efecto_consumible(NombreObjeto, TipoEfecto, Valor)
efecto_consumible(pocion, curar, 15).
efecto_consumible(manzana, curar, 5).

usar(Objeto) :-
    inventario(Inv),
    member(Objeto, Inv),
    efecto_consumible(Objeto, Tipo, Valor),
    
    % Lo quitamos del inventario
    select(Objeto, Inv, NuevoInv),
    retract(inventario(Inv)),
    assert(inventario(NuevoInv)),
    
    % Aplicamos el efecto
    write('Has consumido: '), write(Objeto), nl,
    aplicar_efecto(Tipo, Valor),
    
    % Si lo usamos en combate, nos cuesta el turno y el enemigo ataca
    (estado_juego(combate) ->
        en_combate_con(Nombre),
        ubicacion(Lugar),
        write('Consumir te deja expuesto. El enemigo aprovecha para atacar.'), nl,
        turno_enemigo(Nombre, Lugar)
    ; 
        true % Si estamos explorando, no pasa nada malo
    ), !.

% Falla si el objeto no es consumible
usar(Objeto) :-
    inventario(Inv),
    member(Objeto, Inv),
    write('No puedes consumir o usar ese objeto asi.'), nl, !.

% Falla si no lo tienes
usar(_) :-
    write('No tienes ese objeto en tu inventario.'), nl.

% Logica de efectos
aplicar_efecto(curar, Valor) :-
    jugador(HP_J, Max_J, Dmg_J),
    % min() asegura que nunca tengamos mas vida que la Maxima
    NuevoHP is min(HP_J + Valor, Max_J),
    retract(jugador(_, _, _)),
    assert(jugador(NuevoHP, Max_J, Dmg_J)),
    write('Has recuperado salud. Tu HP ahora es '), write(NuevoHP), write('/'), write(Max_J), nl.

% Catalogo de armas
% dano_arma(Nombre, BonusDeDano)
dano_arma(espada, 10).
dano_arma(ninguna, 0).

% Reglas para equipar un objeto.
equipar(_) :-
    estado_juego(combate),
    castigo_por_distraccion, !.

equipar(Arma) :-
    inventario(Inv),
    member(Arma, Inv),
    dano_arma(Arma, _), % Verificamos que el objeto sea un arma
    
    arma_equipada(Actual),
    retract(arma_equipada(Actual)),
    assert(arma_equipada(Arma)),
    
    write('Has equipado: '), write(Arma), nl, !.

equipar(Objeto) :-
    inventario(Inv),
    member(Objeto, Inv),
    write('Ese objeto no es un arma, no puedes equiparlo.'), nl, !.

equipar(_) :-
    write('No tienes ese objeto en tu inventario.'), nl.

robos :-
    inventario(Inv),
    diinero(D),
    ( (D =< 0, Inv == []) ->
        write(' - Evento Al Azar - '), nl,
        write('Un individuo llega por detras, ve que no tienes nada y se retira'), nl
    ;
        random(1, 101, Probabilidad),
        (Probabilidad =< 40 ->
            write(' - Evento Al Azar - '), nl,
            write('Fuiste emboscado, eres acorralado por dos individuos'), nl,

            random(1, 3, TipoDeRobo),
            ejecutar_robo(TipoDeRobo)
        ;
            write(' - Evento Al Azar - '), nl,
            write('Te salvaste de un robo, pero alguien te sigue,') , nl,
            write('y logras perdert rapidamente entre la gente.'), nl   
        )    
    ).