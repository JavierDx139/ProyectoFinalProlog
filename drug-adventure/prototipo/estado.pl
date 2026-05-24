% Declaramos las cosas que cambian en el juego, y como empezamos.
:- dynamic ubicacion/1, ubicacion_anterior/1, estado_juego/1, en_combate_con/1, inventario/1, objeto_en/2, puerta_cerrada/1, jugador/3, enemigo/6, dinero/1, arma_equipada/1.

% Estados iniciales
estado_juego(menu).
ubicacion(plaza).
ubicacion_anterior(plaza). % Para no romper el juego si intentas escapar en el turno 1
inventario([]).
dinero(30).
arma_equipada(ninguna).

% jugador(HP_Actual, HP_Max, Dmg)
jugador(30, 30, 5).

% enemigo(Nombre, Ubicacion, HP_Actual, HP_Total, Dmg, Recompensa)
enemigo(ladron, callejon, 5 ,  5, 2, 20).
enemigo(guardia_puerta, entrada_mansion, 10, 10, 3, 30).
enemigo(guardia_cocina, cocina, 10, 10, 3, 30).
enemigo(capo_mayor,sala, 20, 20, 5, 40).
enemigo(pandillero,casa_desgastada, 6, 6, 4, 5).
enemigo(pandillero_entrada, sotano, 6, 6, 4, 5).
enemigo(pandillero_fondo, fondo, 6, 6, 4, 5).


    
% Objetos en el mapa
objeto_en(callejon, pocion).
objeto_en(lobby, vino).
objeto_en(recamara, revolver_antiguo).
objeto_en(sala, fragmento_llave_1).
objeto_en(esquina_sospechosa, lechuga).
objeto_en(fondo, fragmento_llave_2).


    
% Puertas
puerta_cerrada(castillo).
