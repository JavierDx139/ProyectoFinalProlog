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
enemigo(ladron, callejon, 15, 15, 3, 20).

% Objetos en el mapa
objeto_en(plaza, llave).
objeto_en(callejon, pocion).

% Puertas
puerta_cerrada(castillo).