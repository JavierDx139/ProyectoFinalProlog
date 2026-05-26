% Sistema de combate simplificado.
:- use_module(library(random)).
% Objetos que sueltan los enemigos al morir
drop_enemigo(capo_mayor, tommygun).
drop_enemigo(capo_mayor, fragmento_llave_1).
drop_enemigo(guardia_puerta, revolver_antiguo).
drop_enemigo(pandillero_fondo, fragmento_llave_2).
drop_enemigo(hacker_neon, fragmento_llave_3).
    
% Armas y sus probabilidades de golpe
arma(ninguna, 95).
arma(espada, 70).
arma(lanza, 85).
arma(martillo, 55).
arma(dobles_cuchillos, 75).
arma(revolver_antiguo, 80).
arma(tommygun, 65).

% Incrementos de maximos por nivel
bonos_por_nivel(0, 0) :- !.
bonos_por_nivel(1, 8) :- !.
bonos_por_nivel(2, 16) :- !.
bonos_por_nivel(3, 25) :- !.

% Logica de posturas
determinar_rangos_por_postura(
    rapido, esquivar, _MinA, MaxA, PmA, MinD, _MaxD, PmD, MinA_Fin, MaxA, MinD, PmD
) :- !, MinA_Fin is PmA + 1.

determinar_rangos_por_postura(
    lento, bloquear, _MinA, MaxA, PmA, MinD, _MaxD, PmD, MinA_Fin, MaxA, MinD, PmD
) :- !, MinA_Fin is PmA + 1.

determinar_rangos_por_postura(
    lento, esquivar, MinA, _MaxA, PmA, _MinD, MaxD, PmD, MinA, PmA, MinD_Fin, MaxD
) :- !, MinD_Fin is PmD + 1.

determinar_rangos_por_postura(
    rapido, bloquear, MinA, _MaxA, PmA, _MinD, MaxD, PmD, MinA, PmA, MinD_Fin, MaxD
) :- !, MinD_Fin is PmD + 1.

% Calculo de dano

% GOLPE FALLIDO
calcular_dano(Arma, _, _, _, _, 0) :-
    arma(Arma, ProbAcierto),
    random(0, 101, DadoAcierto),
    DadoAcierto > ProbAcierto, !,
    ProbFallo is 100 - ProbAcierto,
    format('¡El ataque con ~w fallo! Probabilidad de fallar golpe: ~w%%~n', [Arma, ProbFallo]).

% GOLPE EXITOSO
calcular_dano(_Arma, NivelAtk, NivelDef, PosturaAtk, PosturaDef, DanoFinal) :-
    % Limites de ataque usando niveles
    MinAtk is 0,
    bonos_por_nivel(NivelAtk, BonoAtk),
    MaxAtk is 75 + BonoAtk,
    PuntoMedioAtk is (MinAtk + MaxAtk) // 2,

    % Limites de defensa usando niveles
    bonos_por_nivel(NivelDef, BonoMaxDef),
    MaxDef is 75 + BonoMaxDef,
    PuntoMedioDef is MaxDef // 2,

    % Calcular rangos segun posturas
    determinar_rangos_por_postura(
        PosturaAtk, PosturaDef, 
        MinAtk, MaxAtk, PuntoMedioAtk, 
        0, MaxDef, PuntoMedioDef,
        RangoAtkMin, RangoAtkMax, 
        RangoDefMin, RangoDefMax),

    % Calcular daño final
    random(RangoAtkMin, RangoAtkMax, ValorAtaque),
    random(RangoDefMin, RangoDefMax, ValorDefensaPorcentaje),
    Reduccion is (ValorAtaque * ValorDefensaPorcentaje) // 100,
    DanoCalculado is ValorAtaque - Reduccion,
    DanoFinal is max(0, DanoCalculado).


% Cambiamos el estado a combate
iniciar_combate(Nombre) :-
    retractall(estado_juego(_)),
    assert(estado_juego(combate)),
    retractall(en_combate_con(_)),
    assert(en_combate_con(Nombre)),
    write('Has comenzado una pelea.'), nl.

% Reglas de ataque
atacar :-
    estado_juego(exploracion),
    write('No estas en combate. No hay a quien atacar.'), nl, !.

atacar :-
    estado_juego(combate),
    (postura_jugador(PJ, AJ) -> true ; (PJ=rapido, AJ=bloquear)),
    en_combate_con(Nombre),
    ubicacion(Lugar),
    enemigo(Nombre, Lugar, HP_E, Max_E, DmgBase_E, Recompensa),
    
    jugador(_, _, NivelA, _),
    arma_equipada(Arma),
    
    % Calculamos daño usando niveles
    calcular_dano(Arma, NivelA, 0, PJ, AJ, Dmg_J),
    
    (Dmg_J =:= 0 ->
        NuevoHP_E = HP_E
    ;
        write('Golpe exitoso. Haces '), write(Dmg_J), write(' de daño total al '), write(Nombre), write('.'), nl,
        NuevoHP_E is HP_E - Dmg_J
    ),
    
    retract(enemigo(Nombre, Lugar, _, _, _, _)), 
    (NuevoHP_E =< 0 ->
        victoria_combate(Nombre, Lugar, Recompensa)
    ;
        assert(enemigo(Nombre, Lugar, NuevoHP_E, Max_E, DmgBase_E, Recompensa)),
        turno_enemigo(Nombre, Lugar)
    ), !.

% Turno enemigo
turno_enemigo(Nombre, Lugar) :-
    enemigo(Nombre, Lugar, HP_E, Max_E, DmgBase_E, _),
    write('El '), write(Nombre), write(' tiene '), write(HP_E), write('/'), write(Max_E), write(' HP.'), nl,
    
    % Enemigo ataca con valores base
    calcular_dano(espada, 1, 0, lento, esquivar, Dmg_E),
    
    jugador(HP_J, Max_J, NivelA, NivelD),
    Dmg_Reducido is max(0, Dmg_E - (NivelD * 2)),
    
    (Dmg_E =:= 0 ->
        write('El '), write(Nombre), write(' fallo su ataque.'), nl
    ;
        write('El '), write(Nombre), write(' te impacta haciendo '), write(Dmg_Reducido), write(' de daño.'), nl
    ),
    
    NuevoHP_J is HP_J - Dmg_Reducido,
    (NuevoHP_J =< 0 ->
        write('HAS MUERTO. Fin del juego.'), nl, halt
    ;
        retract(jugador(_, _, _, _)),
        assert(jugador(NuevoHP_J, Max_J, NivelA, NivelD)),
        write('Te quedan '), write(NuevoHP_J), write('/'), write(Max_J), write(' HP.'), nl, nl
    ).

% Victoria y Recompensa
victoria_combate(Nombre, _Lugar, Recompensa) :-
    retractall(estado_juego(_)),
    assert(estado_juego(exploracion)),
    retractall(en_combate_con(_)),
    
    dinero(D),
    NuevoDinero is D + Recompensa,
    retract(dinero(D)),
    assert(dinero(NuevoDinero)),
    
    write('Has derrotado al '), write(Nombre), write('.'), nl,
    write('Encuentras '), write(Recompensa), write(' monedas. (Total: '), write(NuevoDinero), write(')'), nl,
    forall(
        drop_enemigo(Nombre, Objeto),
        (   inventario(Inv),
            retract(inventario(Inv)),
            assert(inventario([Objeto|Inv])),
            write('Has obtenido: '), write(Objeto), nl
        )
    ),

    write('El camino esta despejado.'), nl.

% Escapar con Probabilidad (50% de exito)
escapar :-
    estado_juego(exploracion),
    write('No estas en peligro, no hay necesidad de escapar.'), nl, !.

escapar :-
    estado_juego(combate),
    en_combate_con(Nombre),
    ubicacion(Lugar),
    random_between(1, 100, Dado),
    write('Intentas escapar... (Probabilidad 50%. Sacaste: '), write(Dado), write(')'), nl,
    (Dado >= 50 ->
        ubicacion_anterior(Ant),
        write('Lograste escapar. Corres hacia: '), write(Ant), nl,
        retract(ubicacion(Lugar)),
        assert(ubicacion(Ant)),
        retractall(estado_juego(_)),
        assert(estado_juego(exploracion)),
        retractall(en_combate_con(_))
    ;
        write('No pudiste escapar.'), nl,
        turno_enemigo(Nombre, Lugar)
    ), !.

% Funcion de castigo
castigo_por_distraccion :-
    en_combate_con(Nombre),
    ubicacion(Lugar),
    write('Le diste la espalda al '), write(Nombre), write(' al intentar hacer otra cosa.'), nl,
    write('Aprovecha tu error para atacarte gratis'), nl,
    turno_enemigo(Nombre, Lugar).
