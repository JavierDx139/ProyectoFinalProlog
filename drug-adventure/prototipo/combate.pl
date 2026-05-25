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

% Minimos de defensa otorgados por el Escudo
bono_escudo(0, 0) :- !. % cuando no hay escudo
bono_escudo(1, 5) :- !.
bono_escudo(2, 10) :- !.
bono_escudo(_, 0).

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
calcular_dano(Arma, _, _, _, _, _, _, 0) :-
    arma(Arma, ProbAcierto),
    random(0, 101, DadoAcierto),
    DadoAcierto > ProbAcierto, !,
    ProbFallo is 100 - ProbAcierto,
    format('¡El ataque con ~w fallo! Probabilidad de fallar golpe: ~w%%~n', [Arma, ProbFallo]).

% GOLPE EXITOSO
calcular_dano(_Arma, NivelAtk, AmuletoFuego, NivelDef, NivelEscudo, PosturaAtk, PosturaDef, DanoFinal) :-

    % LIMITES ATAQUE
    (AmuletoFuego == 1 -> MinAtk is 15 ; MinAtk is 0),
    bonos_por_nivel(NivelAtk, BonoAtk),
    MaxAtk is 75 + BonoAtk,
    PuntoMedioAtk is (MinAtk + MaxAtk) // 2,

    % LIMITES DEFENSA
    bono_escudo(NivelEscudo, MinDef),
    bonos_por_nivel(NivelDef, BonoMaxDef),
    MaxDef is 75 + BonoMaxDef,
    PuntoMedioDef is (MinDef + MaxDef) // 2,

    % DATOS DEL COMBATE COMPLETOS
    determinar_rangos_por_postura(
        PosturaAtk, PosturaDef, 
        MinAtk, MaxAtk, PuntoMedioAtk, 
        MinDef, MaxDef, PuntoMedioDef,
        RangoAtkMin, RangoAtkMax, 
        RangoDefMin, RangoDefMax),

    % DAÑO Y MITIGACIÓN POR DEFENSA
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
    en_combate_con(Nombre),
    ubicacion(Lugar),
    enemigo(Nombre, Lugar, HP_E, Max_E, DmgBase_E, Recompensa),
    
    % Obtenemos el arma equipada, si no hay, usa 'ninguna'.
    arma_equipada(Arma),
    calcular_dano(Arma, 1, 0, 1, 0, rapido, bloquear, Dmg_J),
    
    (Dmg_J =:= 0 ->
        NuevoHP_E is HP_E % Falla el golpe
    ;
        write('Golpe exitoso. Haces '), write(Dmg_J), write(' de dano total al '), write(Nombre), write('.'), nl,
        NuevoHP_E is HP_E - Dmg_J
    ),
    
    retract(enemigo(Nombre, Lugar, _, _, _, _)), 
    (NuevoHP_E =< 0 ->
        victoria_combate(Nombre, Lugar, Recompensa)
    ;
        % Guardamos los datos actualizados
        assert(enemigo(Nombre, Lugar, NuevoHP_E, Max_E, DmgBase_E, Recompensa)),
        turno_enemigo(Nombre, Lugar)
    ).

% Turno enemigo
turno_enemigo(Nombre, Lugar) :-
    enemigo(Nombre, Lugar, HP_E, Max_E, _DmgBase_E, _),
    write('El '), write(Nombre), write(' tiene '), write(HP_E), write('/'), write(Max_E), write(' HP.'), nl,
    
    % El enemigo ataca usando el mismo sistema, asumiendo arma 'espada' y postura 'lento'
    calcular_dano(espada, 1, 0, 1, 0, lento, esquivar, Dmg_E),
    
    (Dmg_E =:= 0 ->
        write('El '), write(Nombre), write(' fallo su ataque.'), nl,
        DanoFinal_E is 0
    ;
        write('El '), write(Nombre), write(' te impacta haciendo '), write(Dmg_E), write(' de dano.'), nl,
        DanoFinal_E is Dmg_E
    ),
    
    jugador(HP_J, Max_J, Dmg_Base_J),
    NuevoHP_J is HP_J - DanoFinal_E,
    
    (NuevoHP_J =< 0 ->
        write('HAS MUERTO. Fin del juego.'), nl, halt
    ;
        retract(jugador(_, _, _)),
        assert(jugador(NuevoHP_J, Max_J, Dmg_Base_J)),
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
