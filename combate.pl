:- use_module(library(random)).

% -----------------------------------------REGLAS BÁSICAS-----------------------------------------

% Armas y sus probabilidades de golpe
arma(espada, 70).
arma(lanza, 85).
arma(martillo, 55).
arma(dobles_cuchillos, 75).


% Incrementos de Máximos por nivel (Ataque o Defensa)
bonos_por_nivel(0, 0) :- !.
bonos_por_nivel(1, 8) :- !.
bonos_por_nivel(2, 16) :- !.
bonos_por_nivel(3, 25) :- !.


% Mínimos de defensa otorgados por el Escudo
bono_escudo(1, 5) :- !.
bono_escudo(2, 10) :- !.
bono_escudo(_, 0).


% Lógica de posturas
% Favorece al Atacante (Rápido y Esquivo o Lento y Bloqueo)
% Ataque saca mitad superior / Defensa saca mitad inferior
determinar_rangos_por_postura(
    rapido, esquivar, _MinA, MaxA, PmA, MinD, _MaxD, PmD, MinA_Fin, MaxA, MinD, PmD
) :- !, MinA_Fin is PmA + 1.

determinar_rangos_por_postura(
    lento, bloquear, _MinA, MaxA, PmA, MinD, _MaxD, PmD, MinA_Fin, MaxA, MinD, PmD
) :- !, MinA_Fin is PmA + 1.

% Favorece al Defensor (Lento y Esquivo o Rápido y Bloqueo)
% Ataque saca mitad inferior / Defensa saca mitad superior
determinar_rangos_por_postura(
    lento, esquivar, MinA, _MaxA, PmA, _MinD, MaxD, PmD, MinA, PmA, MinD_Fin, MaxD
) :- !, MinD_Fin is PmD + 1.

determinar_rangos_por_postura(
    rapido, bloquear, MinA, _MaxA, PmA, _MinD, MaxD, PmD, MinA, PmA, MinD_Fin, MaxD
) :- !, MinD_Fin is PmD + 1.



% ----------------------------------------CÁLCULO DE DAÑO----------------------------------------

% GOLPE FALLIDO
calcular_daño(Arma, _, _, _, _, _, _, 0) :-
    arma(Arma, ProbAcierto),
    random(-1, 101, DadoAcierto),
    DadoAcierto > ProbAcierto, !,
    ProbFallo is 100 - ProbAcierto,
    format('¡El ataque con ~w falló! Probabilidad de fallar golpe: ~w%%~n', [Arma, ProbFallo]).


% GOLPE EXITOSO
calcular_daño(_Arma, NivelAtk, AmuletoFuego, NivelDef, NivelEscudo, PosturaAtk, PosturaDef, dañoFinal) :-

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
    dañoCalculado is ValorAtaque - Reduccion,
    dañoFinal is max(0, dañoCalculado).



